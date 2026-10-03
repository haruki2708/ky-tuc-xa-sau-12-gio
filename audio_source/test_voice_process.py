"""Semantic checks for transcript cleanup and irreversible rule-action masking."""
import sys
import unittest

sys.dont_write_bytecode = True
from voice_process import clean_text, mask_and_hiss, parts_for, read_lines


class VoiceProcessingTests(unittest.TestCase):
    def test_cleanup_removes_only_stage_directions_and_speaker_prefix(self):
        self.assertEqual(clean_text("Loa (chậm hơn): Trần… Trung."), "Trần… Trung.")
        self.assertEqual(clean_text("Speaker: Roll call (static), room 407."), "Roll call , room 407.")

    def test_actual_csv_names_stay_vietnamese_in_english(self):
        lines = read_lines()
        for key in ["SPK_NAME_PHUC", "SPK_NAME_VIET", "SPK_NAME_TRUNG", "SPK_NAME_DAT", "SPK_NAME_LAM", "SPK_NAME_TRUNG_AGAIN"]:
            self.assertEqual(parts_for(key, "en", lines), parts_for(key, "vi", lines))
        parts = parts_for("SPK_AND_TRUNG", "en", lines)
        self.assertEqual(parts[1], ("Trần Trung", "vi"))

    def test_rule3_action_removed_not_just_mixed_under_noise(self):
        boundary = 1200
        original = [.1] * boundary + [.9] * 1800
        changed = [.1] * boundary + [-.7] * 1800
        # Replacing every hidden sample cannot change the rendered output at all.
        self.assertEqual(mask_and_hiss(original, boundary, 137), mask_and_hiss(changed, boundary, 137))
        self.assertNotEqual(mask_and_hiss(original, None, 137), mask_and_hiss(changed, None, 137))
        for locale in ["vi", "en"]:
            parts = parts_for("RULE_3_GARBLED", locale, read_lines())
            self.assertEqual(len(parts), 2)
            self.assertIn("không quay lại" if locale == "vi" else "do not turn around", parts[1][0])


if __name__ == "__main__":
    unittest.main()
