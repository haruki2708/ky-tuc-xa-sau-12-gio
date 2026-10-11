"""G0 proposal validator; stdlib only, no network or production writes."""
import argparse
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LIMIT = 10 * 1024 * 1024


def repo_file(root, value):
    if not isinstance(value, str) or not value or "\\" in value or ":" in value:
        raise ValueError("Use a repository-relative POSIX path")
    candidate = Path(value)
    if candidate.is_absolute() or ".." in candidate.parts:
        raise ValueError("Unsafe relative path")
    path = (root / candidate).resolve()
    if not path.is_relative_to(root.resolve()) or not path.is_file():
        raise ValueError("Missing file or path outside repository")
    return path


def vector(value):
    return (isinstance(value, list) and len(value) == 3
            and all(type(v) in (int, float) and math.isfinite(v) for v in value))


def count(value):
    return (type(value) in (int, float) and math.isfinite(value)
            and value >= 0 and value == int(value))


def validate_document(document):
    if not isinstance(document, dict) or document.get("schema_version") not in ("t210-g0-proposal-1", "t210-g1-static-1"):
        raise ValueError("Unsupported proposal document/version")
    assets = document.get("assets")
    if not isinstance(assets, list) or not assets or not all(isinstance(asset, dict) for asset in assets):
        raise ValueError("Assets must be a nonempty array of objects")
    ids = [asset.get("asset_id") for asset in assets]
    if not all(isinstance(value, str) and value.strip() for value in ids) or len(set(ids)) != len(ids):
        raise ValueError("Invalid or duplicate asset ID")
    return assets


def validate_measurements(measurements):
    if not isinstance(measurements, list):
        raise ValueError("Probe result must be an array")
    for measured in measurements:
        if not isinstance(measured, dict) or not isinstance(measured.get("file"), str):
            raise ValueError("Invalid probe entry")
        unavailable = measured.get("unavailable", [])
        if not isinstance(unavailable, list) or not all(isinstance(value, str) for value in unavailable):
            raise ValueError("Invalid probe unavailable list")
        nodes = measured.get("nodes", {})
        if not isinstance(nodes, dict) or not all(isinstance(value, dict) for value in nodes.values()):
            raise ValueError("Invalid probe nodes")
    return measurements


def validate(asset, root=ROOT, measurements=(), schema_version="t210-g0-proposal-1"):
    errors, unavailable = [], []
    if not isinstance(asset, dict):
        return {"status": "FAIL", "errors": ["asset must be an object"], "unavailable": []}
    result = {"asset_id": asset.get("asset_id"), "scope": asset.get("scope")}
    if schema_version == "t210-g1-static-1":
        from schema_rules import schema_errors
        errors.extend(schema_errors(asset))
        if errors:
            return dict(result, status="FAIL", errors=errors, unavailable=[])
    for key in ("asset_id", "file", "source", "geometry", "generation", "budget", "approval"):
        if not asset.get(key):
            errors.append("missing:" + key)
    for key in ("source", "geometry", "generation", "budget", "approval"):
        if not isinstance(asset.get(key), dict):
            errors.append("must be an object:" + key)
    if errors:
        return dict(result, status="FAIL", errors=errors, unavailable=[])
    if not isinstance(asset["asset_id"], str) or not asset["asset_id"].strip():
        errors.append("invalid asset ID")
    if asset.get("scope") not in ("prototype", "production"):
        errors.append("scope must be prototype or production")
    source = asset.get("source", {})
    for key in ("uri", "author", "license", "credits_file", "ai_tool", "input_rights"):
        if not isinstance(source.get(key), str) or not source[key].strip():
            errors.append("source missing:" + key)
    if source.get("license") not in ("CC0-1.0", "CC-BY-4.0", "CC-BY-3.0"):
        errors.append("license not allowlisted; integrator review required")
    try:
        repo_file(root, source.get("credits_file"))
    except ValueError as exc:
        errors.append("credits:" + str(exc))
    uri = source.get("uri")
    if isinstance(uri, str) and uri.startswith("repo:"):
        try:
            repo_file(root, source["uri"][5:])
        except ValueError as exc:
            errors.append("source:" + str(exc))
    elif not isinstance(uri, str) or not uri.startswith("https://"):
        errors.append("source URI must be repo: or https://")
    geometry = asset.get("geometry", {})
    for key in ("dimensions_m", "bounds_min_m", "root_scale"):
        if not vector(geometry.get(key)):
            errors.append("geometry invalid:" + key)
    tolerance = geometry.get("tolerance_m", 0.001)
    if type(tolerance) not in (int, float) or not math.isfinite(tolerance) or tolerance < 0:
        errors.append("invalid tolerance")
    markers = geometry.get("markers")
    if not isinstance(markers, dict) or not all(vector(v) for v in markers.values()):
        errors.append("markers must map relative node paths to positions")
    generation = asset.get("generation", {})
    for key in ("tool", "model_id", "task_id", "created_on", "parameters"):
        if key not in generation:
            errors.append("generation missing:" + key)
    if not generation.get("created_on"):
        unavailable.append("generation_date")
    budget = asset.get("budget", {})
    limit = budget.get("triangle_limit_exclusive")
    if limit is not None and (type(limit) is not int or limit <= 0):
        errors.append("invalid triangle limit")
    for key in ("estimated_credits", "consumed_credits"):
        value = budget.get(key)
        if value is None and schema_version == "t210-g1-static-1":
            unavailable.append("budget:" + key)
        elif type(value) not in (int, float) or not math.isfinite(value) or value < 0:
            errors.append("invalid budget:" + key)
    approval = asset.get("approval", {})
    if approval.get("status") not in ("pending", "approved", "rejected"):
        errors.append("invalid approval status")
    if not approval.get("reviewer"):
        unavailable.append("approval_reviewer")
    if approval.get("status") != "approved":
        unavailable.append("asset_approval")
    path = None
    try:
        path = repo_file(root, asset.get("file"))
        result["bytes"] = path.stat().st_size
        if result["bytes"] > LIMIT:
            errors.append("file exceeds 10 MiB")
        if path.suffix.lower() != ".glb":
            unavailable.append("format: only GLB probe supported in G0")
        else:
            with path.open("rb") as stream:
                header = stream.read(12)
            if len(header) != 12 or header[:4] != b"glTF" or int.from_bytes(header[4:8], "little") != 2 or int.from_bytes(header[8:12], "little") != result["bytes"]:
                errors.append("invalid GLB header/version/length (or unresolved LFS pointer)")
        if result["bytes"] <= LIMIT:
            result["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
    except ValueError as exc:
        errors.append(str(exc))
    matched = [m for m in measurements if m.get("file") == asset.get("file")]
    if len(matched) > 1:
        errors.append("duplicate measurement")
    measured = matched[0] if len(matched) == 1 else None
    if measured is None:
        unavailable.append("imported_geometry_material_texture_scale_markers")
    elif measured.get("sha256") != result.get("sha256") or not result.get("sha256"):
        errors.append("stale measurement: file hash differs")
    else:
        result["measured"] = measured
        unavailable.extend(measured.get("unavailable", []))
        if not errors:
            fields = ("dimensions_m", "bounds_min_m") if schema_version == "t210-g1-static-1" else ("dimensions_m", "bounds_min_m", "root_scale")
            for key in fields:
                actual = measured.get(key)
                if not vector(actual):
                    unavailable.append(key)
                elif any(abs(a - b) > tolerance for a, b in zip(actual, geometry[key])):
                    errors.append("geometry mismatch:" + key)
            for marker, expected in markers.items():
                actual = measured.get("nodes", {}).get(marker, {}).get("position_m")
                if not vector(actual):
                    errors.append("missing marker:" + marker)
                elif any(abs(a - b) > tolerance for a, b in zip(actual, expected)):
                    errors.append("marker position mismatch:" + marker)
            for key in ("triangles", "material_count", "texture_count"):
                if key not in measured:
                    unavailable.append(key)
                elif not count(measured[key]):
                    errors.append("invalid measured count:" + key)
            if limit is None:
                unavailable.append("triangle_budget_pending_G1")
            elif count(measured.get("triangles")) and measured["triangles"] >= limit:
                errors.append("triangle budget exceeded")
    unavailable.append("provenance_manual_verification")
    if asset.get("scope") == "prototype":
        unavailable.append("G1_contract_and_G3_production_approval")
    if schema_version == "t210-g1-static-1":
        from manifest_g1 import inspect_g1
        new_errors, new_unavailable = inspect_g1(asset, measured, root)
        errors.extend(new_errors)
        unavailable.extend(new_unavailable)
    result.update(errors=errors, unavailable=sorted(set(unavailable)),
                  status="FAIL" if errors else "INCOMPLETE" if unavailable else "PASS")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--probe-log", type=Path)
    args = parser.parse_args()
    document = json.loads(args.manifest.read_text(encoding="utf-8-sig"))
    assets = validate_document(document)
    measurements = []
    if args.probe_log:
        lines = args.probe_log.read_text(encoding="utf-8-sig").splitlines()
        payloads = [line.split("=", 1)[1] for line in lines if line.startswith("GRAPHICS_PROBE_JSON=")]
        if len(payloads) != 1 or any("ERROR:" in line for line in lines):
            raise ValueError("Probe log must contain one result and no engine errors")
        measurements = validate_measurements(json.loads(payloads[0]))
    results = [validate(asset, measurements=measurements, schema_version=document["schema_version"]) for asset in assets]
    print(json.dumps({"schema_version": document["schema_version"], "assets": results}, indent=2))
    return 1 if any(r["errors"] for r in results) else 2 if any(r["unavailable"] for r in results) else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, KeyError, TypeError, OSError) as exc:
        print(json.dumps({"status": "FAIL", "error": str(exc)}))
        raise SystemExit(1)
