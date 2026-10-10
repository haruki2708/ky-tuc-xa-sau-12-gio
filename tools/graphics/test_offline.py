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


if __name__ == "__main__":
    unittest.main()
