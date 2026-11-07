"""Read-only OGG loudness audit. Never renders, normalizes, or rewrites audio."""
from __future__ import annotations

import argparse
import ast
import csv
import hashlib
import json
import math
import os
from pathlib import Path
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_overrides() -> dict:
    # Read literals without importing or executing any asset generator.
    result = {}
    tree = ast.parse((ROOT / "audio_source/process.py").read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(t, ast.Name) and t.id == "TARGET_OVERRIDES" for t in node.targets
        ):
            result.update(ast.literal_eval(node.value))
        if isinstance(node, ast.Expr) and isinstance(node.value, ast.Call):
            call = node.value
            if (isinstance(call.func, ast.Attribute) and call.func.attr == "update"
                    and isinstance(call.func.value, ast.Name)
                    and call.func.value.id == "TARGET_OVERRIDES"):
                result.update(ast.literal_eval(call.args[0]))
    return result


def report_index() -> dict:
    index = {}
    overrides = read_overrides()
    for path in sorted((ROOT / "audio_source").rglob("build_report.json")):
        report = json.loads(path.read_text(encoding="utf-8-sig"))
        for item in report.get("assets", []):
            file = item["file"]
            target = item.get("target_lufs", report.get("target_lufs"))
            origin = path.relative_to(ROOT).as_posix()
            target_origin = origin
            if target is None and item.get("who") in report.get("voices", {}):
                target = report["voices"][item["who"]][-1]
                target_origin += ":voices/" + item["who"]
            if path == ROOT / "audio_source/build_report.json":
                name = Path(file).stem
                target = next((value for key, value in overrides.items() if name.startswith(key)),
                              -24 if item["loop"] else -18)
                target_origin = "audio_source/process.py:target_lufs (README + overrides)"
            entry = dict(item, report=origin, target_lufs=target, target_origin=target_origin)
            index.setdefault(file, []).append(entry)
    return index


def finite(value: str) -> float | None:
    number = float(value)
    return number if math.isfinite(number) else None


def measure(ffmpeg: str, path: Path) -> dict:
    # Only input_* measurements are used. The filter output is discarded.
    # I=-24 is a legal analysis setting even for files whose target is below -70.
    command = [ffmpeg, "-hide_banner", "-nostdin", "-threads", "1", "-i", str(path),
               "-vn", "-af", "loudnorm=I=-24:TP=-2:LRA=7:print_format=json",
               "-filter_threads", "1", "-f", "null", "-"]
    proc = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if proc.returncode:
        raise RuntimeError(f"ffmpeg failed for {path}: {proc.stderr[-2000:]}")
    blocks = re.findall(r'\{\s*"input_i".*?\}', proc.stderr, re.S)
    if len(blocks) != 1:
        raise RuntimeError(f"Expected one loudnorm measurement: {path}")
    data = json.loads(blocks[0])
    return {"lufs": finite(data["input_i"]), "true_peak_db": finite(data["input_tp"]),
            "lra": finite(data["input_lra"])}


def write_table(result: dict, output: Path) -> None:
    lines = ["# T-234 — số đo toàn bộ OGG", "",
             f"{result['count']} file; `{result['ffmpeg']}`; base `{result['revision']}`.", "",
             "Đo loudnorm input_i/input_tp, không prefilter và không ghi lại âm. "
             "Mục tiêu theo report riêng từng bank; bank gốc dùng README và TARGET_OVERRIDES hiện hành. "
             "Bốn chunk âm tiết dùng mục tiêu pipeline −30 LUFS, chưa có build_report. "
             "Đây là mức file, chưa cộng bus/gain/khoảng cách; xem bảng nguồn và bảng mix trong báo cáo chính. "
             "Chưa nghe bằng tai, chờ chủ dự án nghe.", "",
             "| File dưới game/audio/ | LUFS | dBTP | Mục tiêu | Δ mục tiêu (LU) | Δ report (LU) | Report / SHA256 |",
             "|---|---:|---:|---:|---:|---:|---|"]
    for row in result["assets"]:
        report = "; ".join(r["report"] for r in row["reports"]) or "THIẾU report"
        match = "khớp" if row["hash_matches"] else "chưa có" if row["hash_matches"] is None else "KHÁC"
        delta = ", ".join(str(x) for x in row["report_deltas_lu"]) or "—"
        lines.append(f"| `{row['file'].removeprefix('game/audio/')}` | {row['lufs']} | {row['true_peak_db']} | "
                     f"{row['target_lufs']} | {row['delta_target_lu']} | {delta} | {report}; hash {match} |")
    (output / "loudness.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg", default=os.environ.get("FFMPEG"))
    parser.add_argument("--output", type=Path, default=ROOT / "build/t234")
    args = parser.parse_args()
    candidates = sorted(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe"))
    ffmpeg = args.ffmpeg or shutil.which("ffmpeg") or (str(candidates[0]) if candidates else None)
    if not ffmpeg:
        parser.error("Use --ffmpeg, FFMPEG, PATH, or the existing D:/Tools/ffmpeg installation")
    output = args.output.resolve()
    allowed = [ROOT / "build", ROOT / "audio_source/reports"]
    if not any(output.is_relative_to(parent.resolve()) for parent in allowed):
        parser.error("Output must stay under this workspace's build/ or audio_source/reports/")
    output.mkdir(parents=True, exist_ok=True)
    index = report_index()
    paths = sorted((ROOT / "game/audio").rglob("*.ogg"))
    results = []
    for number, path in enumerate(paths, 1):
        file = path.relative_to(ROOT).as_posix()
        before = sha256(path)
        data = measure(ffmpeg, path)
        if sha256(path) != before:
            raise RuntimeError(f"Audio changed during analysis: {file}")
        reports = index.get(file, [])
        target = reports[0]["target_lufs"] if len(reports) == 1 else None
        target_origin = reports[0]["target_origin"] if len(reports) == 1 else None
        if not reports and path.stem.startswith("ch2_syllables_"):
            target = -30
            target_origin = "audio_source/ch2_syllable_voices.py -> ch2_voice_process.py:VOICES/corpse"
        delta = round(data["lufs"] - target, 2) if data["lufs"] is not None and target is not None else None
        row = dict(file=file, sha256=before, bytes=path.stat().st_size, **data,
                   target_lufs=target, target_origin=target_origin, delta_target_lu=delta,
                   reports=reports, missing_report=not reports, duplicate_reports=len(reports) > 1,
                   over_1_lu=delta is not None and abs(delta) > 1,
                   unmeasurable=data["lufs"] is None,
                   hash_matches=all(r.get("sha256") == before for r in reports) if reports else None,
                   report_deltas_lu=[round(data["lufs"] - r["lufs"], 2) if data["lufs"] is not None else None
                                     for r in reports])
        results.append(row)
        if number % 25 == 0 or number == len(paths):
            print(f"Measured {number}/{len(paths)} OGG files", flush=True)
    version = subprocess.check_output([ffmpeg, "-version"], text=True, encoding="utf-8").splitlines()[0]
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    result = {"revision": revision, "ffmpeg": version,
              "method": "loudnorm input_i/input_tp; no prefilter; output discarded; no audio writes",
              "count": len(results), "assets": results,
              "orphan_report_files": sorted(set(index) - {r["file"] for r in results})}
    (output / "loudness.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_table(result, output)
    fields = ["file", "lufs", "true_peak_db", "target_lufs", "delta_target_lu", "target_origin",
              "over_1_lu", "missing_report", "hash_matches", "sha256"]
    with (output / "loudness.csv").open("w", newline="", encoding="utf-8-sig") as file:
        writer = csv.DictWriter(file, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(results)
    print(f"RESULT: audit measured {len(results)} files; "
          f"{sum(r['over_1_lu'] for r in results)} target deviations; "
          f"{sum(r['missing_report'] for r in results)} missing reports; "
          f"{sum(r['unmeasurable'] for r in results)} unmeasurable")


if __name__ == "__main__":
    main()
