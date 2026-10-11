"""Static-asset G1 metadata and evidence checks; no service calls or scene writes."""
import hashlib
import json
import math
from pathlib import Path

from asset_qa import repo_file, vector, count


def inspect_g1(asset, measured, root):
    errors, unavailable = [], []
    definition = json.loads(Path(__file__).with_name("manifest.schema.json").read_text())["$defs"]["asset"]
    for section in definition["required"]:
        if section not in asset:
            errors.append("G1 missing:" + section)
        requirements = definition["properties"][section].get("required", [])
        if requirements:
            if not isinstance(asset.get(section), dict):
                errors.append("G1 object required:" + section)
            else:
                for field in requirements:
                    if field not in asset[section]:
                        errors.append("G1 missing:" + section + "." + field)
    if errors:
        return errors, unavailable
    binding = asset.get("binding")
    if not isinstance(binding, dict):
        errors.append("G1 binding object required")
        binding = {}
    for field in ("scene_path", "node_path", "root_class"):
        if not isinstance(binding.get(field), str) or not binding[field]:
            errors.append("binding missing:" + field)
    if binding.get("collider_policy") != "preserve_gameplay":
        errors.append("G1 must preserve gameplay collider/nav")
    placement = asset.get("placement", {})
    for field in ("position_m", "rotation_degrees", "scale"):
        if not vector(placement.get(field)):
            errors.append("placement invalid:" + field)
    unavailable.append("scene_placement_requires_integration_check")
    geometry = asset.get("geometry", {})
    if geometry.get("coordinate_space") != "selected_root_local":
        errors.append("geometry must use selected_root_local")
    if geometry.get("pose") != "rest" or geometry.get("visibility_policy") != "include_hidden":
        errors.append("G1 probe requires explicit rest pose and include_hidden policy")
    required_markers = binding.get("required_markers")
    if not isinstance(required_markers, list) or not all(isinstance(v, str) for v in required_markers):
        errors.append("binding required_markers must be a list of node paths")
    elif any(marker not in geometry.get("markers", {}) for marker in required_markers):
        unavailable.append("required_marker_positions")
    generation = asset.get("generation", {})
    provider, channel = generation.get("provider"), generation.get("channel")
    wallet = generation.get("wallet_id")
    if provider == "self_authored":
        if channel != "local" or wallet is not None:
            errors.append("self-authored assets require local channel and no service wallet")
    elif provider in ("tripo", "meshy"):
        if channel not in ("studio", "api"):
            errors.append("service generation must identify Studio or API")
        if not isinstance(wallet, str) or not wallet.startswith(f"{provider}:{channel}:"):
            errors.append("generation wallet/provider/channel mismatch")
        if generation.get("tier") not in (None, "unknown", "free", "paid"):
            errors.append("invalid generation tier")
        for field in ("tier", "model_version", "model_id", "created_on"):
            if generation.get(field) in (None, "", "unknown"):
                unavailable.append("generation:" + field)
        if channel == "api" and not generation.get("task_id"):
            unavailable.append("generation:task_id")
        evidence = generation.get("rights_evidence")
        if not isinstance(evidence, list) or not evidence:
            unavailable.append("paid_plan_and_input_rights_evidence")
        else:
            for path in evidence:
                try:
                    repo_file(root, path)
                except ValueError as exc:
                    errors.append("rights evidence:" + str(exc))
        # Paid only describes the account at creation; source.license is still checked independently.
    else:
        errors.append("generation provider must be explicit")
    budget = asset.get("budget", {})
    if budget.get("wallet_id") != wallet:
        errors.append("budget and generation wallets differ")
    before, after, consumed = (budget.get(key) for key in ("balance_before", "balance_after", "consumed_credits"))
    if provider != "self_authored":
        if any(value is None for value in (before, after, consumed)):
            unavailable.append("credit_reconciliation")
        elif not all(type(v) in (int, float) and math.isfinite(v) and v >= 0 for v in (before, after, consumed)):
            errors.append("invalid credit balance")
        elif abs((before - after) - consumed) > 0.000001:
            errors.append("credit reconciliation mismatch; operator review required")
    for key in ("material_limit", "texture_edge_limit"):
        if type(budget.get(key)) is not int or budget[key] <= 0:
            errors.append("invalid G1 limit:" + key)
    if not isinstance(measured, dict):
        unavailable.append("G1_measurement_and_dependency_hashes")
        return errors, unavailable
    for key in ("coordinate_space", "pose", "visibility_policy"):
        if key not in measured:
            unavailable.append("measurement:" + key)
        elif measured[key] != geometry.get(key):
            errors.append("measurement policy mismatch:" + key)
    hashes = measured.get("dependency_hashes")
    if not isinstance(hashes, dict) or not hashes:
        unavailable.append("dependency_and_import_hashes")
    elif not all(isinstance(path, str) and isinstance(value, str) for path, value in hashes.items()):
        errors.append("malformed dependency hashes")
    else:
        mandatory = {asset["file"], asset["file"] + ".import", "game/project.godot",
                     "game/scripts/debug/graphics_asset_probe.gd"}
        if not mandatory <= hashes.keys() or not any(path.startswith("game/.godot/imported/") for path in hashes):
            unavailable.append("incomplete_dependency_and_import_hashes")
        for path, expected in hashes.items():
            try:
                actual = hashlib.sha256(repo_file(root, path).read_bytes()).hexdigest()
                if actual != expected:
                    errors.append("stale dependency:" + path)
            except ValueError as exc:
                errors.append("dependency:" + str(exc))
    if measured.get("dependency_unavailable"):
        unavailable.append("unresolved_dependency_closure")
    if not isinstance(measured.get("engine"), str) or not measured["engine"].startswith("4.7.2"):
        unavailable.append("pinned_engine_evidence")
    materials = measured.get("material_count")
    if count(materials) and type(budget.get("material_limit")) is int and materials > budget["material_limit"]:
        errors.append("material budget exceeded")
    textures = measured.get("textures")
    if not isinstance(textures, dict) or not count(measured.get("texture_count")) or len(textures) != measured["texture_count"]:
        unavailable.append("texture_dimensions")
    elif type(budget.get("texture_edge_limit")) is int:
        for texture in textures.values():
            if not isinstance(texture, dict) or not all(count(texture.get(v)) and texture[v] > 0 for v in ("width", "height")):
                unavailable.append("texture_dimensions")
            elif max(texture["width"], texture["height"]) > budget["texture_edge_limit"]:
                errors.append("texture budget exceeded")
    return errors, unavailable
