"""Offline safety/negative fixtures; run with python -B -m unittest discover."""
import copy
import hashlib
import json
import os
from pathlib import Path
import struct
import tempfile
import unittest
from unittest.mock import patch

from asset_qa import validate, validate_document, validate_measurements
from meshy_dry_run import new_ledger, plan, save_event, transition
from asset_dry_run import plan as routed_plan

HERE = Path(__file__).resolve().parent


class AssetTests(unittest.TestCase):
    def setUp(self):
        scratch = HERE.parents[1] / "build" / "graphics" / "tests"
        scratch.mkdir(parents=True, exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=scratch)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.asset = copy.deepcopy(json.loads((HERE / "sample_manifest.json").read_text())["assets"][0])
        self.asset["file"] = "door.glb"
        self.asset["source"].update(uri="repo:source.py", credits_file="CREDITS.md")
        # Minimal GLB header suffices here; Godot geometry is tested separately.
        self.content = struct.pack("<4sII", b"glTF", 2, 12)
        (self.root / "door.glb").write_bytes(self.content)
        (self.root / "CREDITS.md").write_text("CC0-1.0")
        (self.root / "source.py").write_text("# fixture")
        geometry = self.asset["geometry"]
        self.measurement = {"file": "door.glb", "sha256": hashlib.sha256(self.content).hexdigest(),
                            "dimensions_m": geometry["dimensions_m"], "bounds_min_m": geometry["bounds_min_m"],
                            "root_scale": [1, 1, 1], "nodes": {}, "triangles": 12,
                            "material_count": 1, "texture_count": 0, "unavailable": []}

    def check(self):
        return validate(self.asset, self.root, [self.measurement])

    def test_valid_measurement_is_not_production_approval(self):
        result = self.check()
        self.assertEqual(result["errors"], [])
        self.assertEqual(result["status"], "INCOMPLETE")

    def test_missing_measurement_is_unavailable(self):
        result = validate(self.asset, self.root)
        self.assertEqual(result["status"], "INCOMPLETE")
        self.assertNotIn("measured", result)

    def test_malformed_metadata_fails_cleanly(self):
        self.asset["source"] = "invalid"
        self.assertEqual(self.check()["status"], "FAIL")

    def test_non_string_source_uri_fails_cleanly(self):
        for value in (None, 42, {}, []):
            with self.subTest(value=value):
                self.asset["source"]["uri"] = value
                self.assertEqual(self.check()["status"], "FAIL")

    def test_invalid_measured_counts_cannot_bypass_budget(self):
        for value in (float("nan"), float("inf"), -1, 1.5, "12", None, True):
            with self.subTest(value=value):
                self.measurement["triangles"] = value
                self.assertIn("invalid measured count:triangles", self.check()["errors"])

    def test_missing_measured_count_is_unavailable(self):
        del self.measurement["triangles"]
        self.assertIn("triangles", self.check()["unavailable"])

    def test_invalid_budget_rejected_before_measurement(self):
        self.asset["budget"]["triangle_limit_exclusive"] = "unlimited"
        result = validate(self.asset, self.root)
        self.assertIn("invalid triangle limit", result["errors"])

    def test_malformed_document_or_probe_rejected(self):
        for document in ([], None, {"schema_version": "t210-g0-proposal-1", "assets": [None]}):
            with self.assertRaises(ValueError):
                validate_document(document)
        for measurements in ({}, [None], [{"file": "door.glb", "nodes": {"Grip": None}}],
                             [{"file": "door.glb", "unavailable": "unknown"}]):
            with self.assertRaises(ValueError):
                validate_measurements(measurements)

    def test_reject_wrong_bounds_and_missing_marker(self):
        self.asset["geometry"]["dimensions_m"] = [99, 99, 99]
        self.asset["geometry"]["markers"] = {"BladeTip": [0, 1, 0]}
        errors = self.check()["errors"]
        self.assertIn("geometry mismatch:dimensions_m", errors)
        self.assertIn("missing marker:BladeTip", errors)

    def test_reject_stale_measurement(self):
        self.measurement["sha256"] = "0" * 64
        self.assertIn("stale measurement: file hash differs", self.check()["errors"])

    def test_triangle_count_comes_from_measurement(self):
        self.asset["triangles"] = 1
        self.measurement["triangles"] = 2000
        self.assertIn("triangle budget exceeded", self.check()["errors"])

    def test_private_license_rejected(self):
        self.asset["source"]["license"] = "Meshy Pro Private"
        self.assertEqual(self.check()["status"], "FAIL")

    def test_paths_cannot_escape_or_be_urls(self):
        for value in ("../door.glb", "C:/secret.glb", "https://example.org/model.glb", "missing.glb"):
            with self.subTest(value=value):
                self.asset["file"] = value
                self.assertEqual(self.check()["status"], "FAIL")

    def test_lfs_pointer_and_oversize_rejected(self):
        (self.root / "door.glb").write_text("version https://git-lfs.github.com/spec/v1")
        self.assertEqual(self.check()["status"], "FAIL")
        with (self.root / "door.glb").open("wb") as stream:
            stream.truncate(10 * 1024 * 1024 + 1)
        self.assertIn("file exceeds 10 MiB", self.check()["errors"])


class MeshyTests(unittest.TestCase):
    def setUp(self):
        self.request = json.loads((HERE / "sample_request.json").read_text())
        self.proposal = plan(self.request)
        self.ledger = new_ledger(self.proposal, 100)

    def apply(self, event, **kwargs):
        # Simulate persistence and a new process after every event.
        self.ledger = json.loads(json.dumps(transition(self.ledger, self.proposal, event, **kwargs)))

    def test_default_no_network_or_secret_access(self):
        with patch("socket.socket", side_effect=AssertionError("Network forbidden")):
            with patch.dict(os.environ, {"MESHY_API_KEY": "fixture_secret_not_for_output"}):
                output = json.dumps(plan(self.request))
        self.assertNotIn("fixture_secret_not_for_output", output)
        self.assertIn('"network_calls": 0', output)

    def test_budget_and_balance_preflight(self):
        self.request["ceiling_credits"] = 1
        with self.assertRaises(ValueError):
            plan(self.request)
        with self.assertRaises(ValueError):
            new_ledger(self.proposal, 1)

    def test_unknown_submit_timeout_never_reposts(self):
        self.apply("reserve_submit")
        self.apply("timeout")
        for event in ("reserve_submit", "resume"):
            with self.assertRaises(ValueError):
                self.apply(event)
        self.assertEqual(self.ledger["attempts"], 1)

    def test_accepted_timeout_resume_success_charged_once(self):
        self.apply("reserve_submit")
        self.apply("accepted", task_id="fixture-001")
        self.apply("timeout")
        self.apply("resume")
        self.apply("succeeded", consumed=30, balance_after=70)
        self.assertEqual(self.ledger["consumed_credits"], 30)
        self.assertTrue(self.ledger["reconciled"])
        with self.assertRaises(ValueError):
            self.apply("succeeded", consumed=30, balance_after=70)
        with self.assertRaises(ValueError):
            self.apply("reserve_submit")

    def test_failed_task_can_still_cost_credits(self):
        self.apply("reserve_submit")
        self.apply("accepted", task_id="fixture-002")
        self.apply("failed", consumed=10, balance_after=90)
        self.assertEqual(self.ledger["state"], "failed")
        self.assertEqual(self.ledger["consumed_credits"], 10)

    def test_resume_has_bounded_poll_count(self):
        self.apply("reserve_submit")
        self.apply("accepted", task_id="fixture-004")
        for _ in range(3):
            self.apply("resume")
        with self.assertRaises(ValueError):
            self.apply("resume")

    def test_actual_cost_above_reservation_stops(self):
        self.apply("reserve_submit")
        self.apply("accepted", task_id="fixture-005")
        self.apply("succeeded", consumed=70, balance_after=30)
        self.assertEqual(self.ledger["state"], "reconciliation_required")
        self.assertTrue(self.ledger["over_budget"])

    def test_balance_discrepancy_stops(self):
        self.apply("reserve_submit")
        self.apply("accepted", task_id="fixture-003")
        self.apply("succeeded", consumed=20, balance_after=70)
        self.assertEqual(self.ledger["state"], "reconciliation_required")

    def test_changed_request_and_private_license_rejected(self):
        changed = dict(self.proposal, fingerprint="different")
        with self.assertRaises(ValueError):
            transition(self.ledger, changed, "reserve_submit")
        self.request["license"] = "Private"
        with self.assertRaises(ValueError):
            plan(self.request)

    def test_unknown_fields_rejected_without_echoing_secrets(self):
        self.request["api_key"] = "fixture-secret"
        with self.assertRaisesRegex(ValueError, "Unexpected or missing"):
            plan(self.request)


class LedgerFileTests(unittest.TestCase):
    def setUp(self):
        scratch = HERE.parents[1] / "build" / "graphics" / "fixture-ledgers"
        scratch.mkdir(parents=True, exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=scratch)
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / "ledger.json"
        self.proposal = plan(json.loads((HERE / "sample_request.json").read_text()))

    def test_persisted_unknown_submit_survives_restart(self):
        save_event(self.path, self.proposal, "init")
        save_event(self.path, self.proposal, "reserve_submit")
        save_event(self.path, self.proposal, "timeout")
        with self.assertRaises(ValueError):
            save_event(self.path, self.proposal, "reserve_submit")
        self.assertEqual(json.loads(self.path.read_text())["attempts"], 1)

    def test_existing_ledger_cannot_be_reset(self):
        save_event(self.path, self.proposal, "init")
        with self.assertRaises(ValueError):
            save_event(self.path, self.proposal, "init")

    def test_second_operator_cannot_advance_locked_ledger(self):
        save_event(self.path, self.proposal, "init")
        self.path.with_suffix(".lock").write_text("fixture lock")
        with self.assertRaises(FileExistsError):
            save_event(self.path, self.proposal, "reserve_submit")
        self.assertEqual(json.loads(self.path.read_text())["attempts"], 0)

    def test_ledger_outside_staging_rejected(self):
        with self.assertRaises(ValueError):
            save_event(HERE / "forbidden-ledger.json", self.proposal, "init")
        self.assertFalse((HERE / "forbidden-ledger.json").exists())


class G1Tests(unittest.TestCase):
    def setUp(self):
        AssetTests.setUp(self)
        proposal = json.loads((HERE / "sample_g1_manifest.json").read_text())["assets"][0]
        for key in ("binding", "placement", "generation"):
            self.asset[key] = copy.deepcopy(proposal[key])
        self.asset["geometry"].update(coordinate_space="selected_root_local", pose="rest", visibility_policy="include_hidden")
        self.asset["budget"].update(material_limit=2, texture_edge_limit=1024, wallet_id=None,
                                     balance_before=None, balance_after=None)
        self.measurement.update(coordinate_space="selected_root_local", pose="rest", visibility_policy="include_hidden",
                                textures={}, engine="4.7.2-stable", dependency_unavailable=[])
        paths = ["door.glb", "door.glb.import", "game/project.godot", "game/scripts/debug/graphics_asset_probe.gd",
                 "game/.godot/imported/fixture.scn", "game/importer.gd", "game/base_importer.gd",
                 "game/surface.gdshaderinc", "game/texture.png"]
        hashes = {}
        for name in paths:
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            if not path.exists():
                path.write_bytes(b"fixture evidence")
            hashes[name] = hashlib.sha256(path.read_bytes()).hexdigest()
        self.measurement["dependency_hashes"] = hashes

    def check_g1(self):
        return validate(self.asset, self.root, [self.measurement], "t210-g1-static-1")

    def test_g1_reference_evidence_has_no_errors_but_needs_review(self):
        result = self.check_g1()
        self.assertEqual(result["errors"], [])
        self.assertEqual(result["status"], "INCOMPLETE")

    def test_dependency_import_texture_or_importer_change_invalidates_report(self):
        for name in ("door.glb.import", "game/importer.gd", "game/base_importer.gd", "game/surface.gdshaderinc",
                     "game/texture.png", "game/.godot/imported/fixture.scn"):
            with self.subTest(name=name):
                path = self.root / name
                original = path.read_bytes()
                path.write_bytes(original + b"changed")
                self.assertIn("stale dependency:" + name, self.check_g1()["errors"])
                path.write_bytes(original)

    def test_missing_dependency_evidence_stays_incomplete(self):
        del self.measurement["dependency_hashes"]
        result = self.check_g1()
        self.assertEqual(result["errors"], [])
        self.assertIn("dependency_and_import_hashes", result["unavailable"])

    def test_old_coordinate_system_is_rejected(self):
        self.measurement["coordinate_space"] = "root_transform_included"
        self.assertIn("measurement policy mismatch:coordinate_space", self.check_g1()["errors"])

    def test_backpack_prototype_limits_are_enforced(self):
        self.asset["budget"]["triangle_limit_exclusive"] = 3001
        self.measurement.update(triangles=3000, material_count=2, texture_count=1, textures={"map": {"width":1024,"height":1024}})
        self.assertEqual(self.check_g1()["errors"], [])
        self.measurement.update(triangles=3001, material_count=3, textures={"map": {"width":2048,"height":1024}})
        errors = self.check_g1()["errors"]
        for error in ("triangle budget exceeded", "material budget exceeded", "texture budget exceeded"):
            self.assertIn(error, errors)

    def set_tripo(self):
        self.asset["generation"].update(provider="tripo", channel="studio", wallet_id="tripo:studio:fixture", tier="paid")
        self.asset["budget"].update(wallet_id="tripo:studio:fixture", balance_before=100, balance_after=90, consumed_credits=10)

    def test_studio_manual_does_not_require_api_task_or_key(self):
        self.set_tripo()
        result = self.check_g1()
        self.assertEqual(result["errors"], [])
        self.assertNotIn("generation:task_id", result["unavailable"])
        self.assertIn("paid_plan_and_input_rights_evidence", result["unavailable"])

    def test_paid_is_not_a_license_exception(self):
        self.set_tripo()
        self.asset["source"]["license"] = "Tripo Paid"
        self.assertEqual(self.check_g1()["status"], "FAIL")

    def set_d084(self):
        self.set_tripo()
        evidence = self.root / "evidence" / "terms.pdf"
        evidence.parent.mkdir(parents=True, exist_ok=True)
        evidence.write_bytes(b"terms snapshot")
        self.asset["source"]["license"] = "LicenseRef-Tripo-Paid-D-084"
        self.asset["generation"]["rights_evidence"] = ["evidence/terms.pdf"]

    def test_d084_paid_tripo_exception_accepted_with_evidence(self):
        self.set_d084()
        result = self.check_g1()
        self.assertEqual(result["errors"], [])
        self.assertNotIn("paid_plan_and_input_rights_evidence", result["unavailable"])

    def test_d084_exception_rejected_without_paid_tripo_evidence(self):
        cases = {
            "free tier": lambda g: g.update(tier="free"),
            "unknown tier": lambda g: g.update(tier="unknown"),
            "no evidence": lambda g: g.update(rights_evidence=[]),
            "missing evidence file": lambda g: g.update(rights_evidence=["evidence/absent.pdf"]),
        }
        for name, mutate in cases.items():
            with self.subTest(name):
                self.set_d084()
                mutate(self.asset["generation"])
                self.assertEqual(self.check_g1()["status"], "FAIL")

    def test_d084_label_rejected_for_other_providers(self):
        self.set_d084()
        self.asset["generation"].update(provider="meshy", channel="studio", wallet_id="meshy:studio:fixture")
        self.asset["budget"].update(wallet_id="meshy:studio:fixture")
        self.assertIn("D-084 license exception requires provider tripo", self.check_g1()["errors"])

    def test_mixed_wallet_and_credit_discrepancy_fail(self):
        self.set_tripo()
        self.asset["budget"].update(wallet_id="tripo:api:fixture", balance_after=80)
        errors = self.check_g1()["errors"]
        self.assertIn("budget and generation wallets differ", errors)
        self.assertIn("credit reconciliation mismatch; operator review required", errors)

    def test_sample_mapping_keeps_B_id_and_placement(self):
        document = json.loads((HERE / "sample_g1_manifest.json").read_text())
        assets = validate_document(document)
        self.assertEqual(assets[0]["asset_id"], "room407_backpack")
        self.assertEqual(assets[0]["placement"]["position_m"], [33.78, 0.02, -4.52])
        self.assertEqual(assets[0]["generation"]["provider"], "self_authored")
        reference = json.loads((HERE.parents[1] / "art_source/graphics_upgrade/measured_assets.json").read_text())
        backpack = next(asset for asset in reference["assets"] if asset["id"] == "room407_backpack")
        for field, target in (("bounds_local_size_m", "dimensions_m"), ("bounds_local_min_m", "bounds_min_m")):
            self.assertEqual(assets[0]["geometry"][target], backpack[field])
        self.assertEqual(assets[0]["binding"]["node_path"], backpack["node"])
        self.assertEqual(assets[0]["placement"]["position_m"], backpack["position_in_scene_m"])
        self.assertEqual(assets[0]["placement"]["rotation_degrees"], backpack["local_rotation_degrees"])

    def test_malformed_dependency_evidence_fails_cleanly(self):
        self.measurement["dependency_hashes"] = {42: None}
        self.assertIn("malformed dependency hashes", self.check_g1()["errors"])


class RoutedLedgerTests(unittest.TestCase):
    def setUp(self):
        self.request = json.loads((HERE / "tripo_studio_request.json").read_text())

    def test_provider_and_wallet_are_part_of_resume_identity(self):
        studio = routed_plan(self.request)
        ledger = new_ledger(studio, 100)
        self.request.update(channel="api", wallet_id="tripo:api:fixture")
        with self.assertRaises(ValueError):
            transition(ledger, routed_plan(self.request), "reserve_submit")
        self.request.update(provider="meshy", wallet_id="meshy:api:fixture")
        with self.assertRaises(ValueError):
            transition(ledger, routed_plan(self.request), "reserve_submit")

    def test_api_cannot_claim_studio_wallet(self):
        self.request["channel"] = "api"
        with self.assertRaises(ValueError):
            routed_plan(self.request)

    def test_tripo_offline_does_not_read_key_or_network(self):
        with patch("socket.socket", side_effect=AssertionError("Network forbidden")):
            with patch.dict(os.environ, {"TRIPO_API_KEY":"fixture-secret"}):
                output = json.dumps(routed_plan(self.request))
        self.assertNotIn("fixture-secret", output)
        self.assertIn("manual_export_glb_blender_godot", output)

    def test_legacy_unscoped_ledger_is_not_silently_migrated(self):
        proposal = plan(json.loads((HERE / "sample_request.json").read_text()))
        ledger = new_ledger(proposal, 100)
        del ledger["wallet_id"]
        with self.assertRaises(ValueError):
            transition(ledger, proposal, "reserve_submit")


if __name__ == "__main__":
    unittest.main()
