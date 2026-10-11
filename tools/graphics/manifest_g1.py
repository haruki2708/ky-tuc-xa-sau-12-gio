"""Static-asset G1 metadata and evidence checks; no service calls or scene writes."""
import math

from asset_qa import repo_file, vector, count
from dependency_evidence import inspect_dependencies
from schema_rules import schema_errors

SCALE_EPSILON = 0.00001  # Dimensionless float/import comparison; never a position tolerance.
BACKPACK_LIMITS = {"triangle_limit_exclusive": 3001, "material_limit": 2, "texture_edge_limit": 1024}


def inspect_g1(asset, measured, root):
    errors, unavailable = schema_errors(asset), []
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
    if any(not 1.0 - SCALE_EPSILON <= value <= 1.0 + SCALE_EPSILON for value in geometry["root_scale"]):
        errors.append("geometry.root_scale must be unit scale")
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
    # D-079 limits come from the approved contract, not from the asset's claims.
    limits = dict(budget)
    if asset['asset_id'] == 'room407_backpack':
        for key, approved in BACKPACK_LIMITS.items():
            limits[key] = min(budget[key], approved)
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
    scale = measured.get('root_scale')
    if not vector(scale):
        unavailable.append('measurement:root_scale')
    elif any(not 1.0 - SCALE_EPSILON <= value <= 1.0 + SCALE_EPSILON for value in scale):
        errors.append('measurement.root_scale must be unit scale')
    if asset['asset_id'] == 'room407_backpack' and count(measured.get('triangles')) and measured['triangles'] >= limits['triangle_limit_exclusive']:
        errors.append('triangle budget exceeded (D-079)')
    for key in ("coordinate_space", "pose", "visibility_policy"):
        if key not in measured:
            unavailable.append("measurement:" + key)
        elif measured[key] != geometry.get(key):
            errors.append("measurement policy mismatch:" + key)
    dependency_errors, dependency_unavailable = inspect_dependencies(asset, measured, root)
    errors.extend(dependency_errors)
    unavailable.extend(dependency_unavailable)
    if not isinstance(measured.get("engine"), str) or not measured["engine"].startswith("4.7.2"):
        unavailable.append("pinned_engine_evidence")
    materials = measured.get("material_count")
    if count(materials) and materials > limits["material_limit"]:
        errors.append("material budget exceeded")
    textures = measured.get("textures")
    if not isinstance(textures, dict) or not count(measured.get("texture_count")) or len(textures) != measured["texture_count"]:
        unavailable.append("texture_dimensions")
    else:
        for texture in textures.values():
            if not isinstance(texture, dict) or not all(count(texture.get(v)) and texture[v] > 0 for v in ("width", "height")):
                unavailable.append("texture_dimensions")
            elif max(texture["width"], texture["height"]) > limits["texture_edge_limit"]:
                errors.append("texture budget exceeded")
    return errors, unavailable
