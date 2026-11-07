"""Turn T-234 chapter snapshots into reviewable bounds/source tables; no game writes."""
from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import math
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
ROOM = "Floor4/Room407/"
PROPS = ROOM + "Furnished/TripoProps/"


def point_box(point: list, box: dict) -> float:
    return math.sqrt(sum(max(lo - p, 0, p - hi) ** 2 for p, lo, hi in zip(point, box["min"], box["max"])))


def nearest(point: list, meshes: list, pattern: str) -> dict:
    matches = [m for m in meshes if fnmatch.fnmatchcase(m["path"], pattern)]
    if not matches:
        return {"distance_m": None, "target": pattern, "status": "chưa có mesh hiển thị", "bounds": None}
    box = min(matches, key=lambda m: point_box(point, m))
    distance = point_box(point, box)
    return {"distance_m": round(distance, 4), "target": box["path"],
            "status": "OK" if distance <= 0.15 else "lệch", "bounds": box}


def binding(path: str) -> tuple[str | None, str]:
    if "/CorridorLight_" in path:
        return path.split("/LightHum")[0] + "/Fixture/Mesh", "Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí."
    if "/WashroomLight/" in path:
        return "Floor4/Washroom/WashroomLight/Fixture/Mesh", "Đèn nhà vệ sinh chung."
    if "/Room407MainLight/" in path:
        return ROOM + "Furnished/fixtures/FluorescentTube*", "Đèn tuýp phòng 407."
    if path.endswith("/FanAmbience"):
        return PROPS + "CeilingFan/*", "Quạt trần; bounds mô hình đang hiển thị."
    if path.endswith("/FanHum"):
        return PROPS + "StandingFan/FanBody", "Quạt đứng; dùng thân tĩnh, không dùng vệt nhòe cánh quay."
    if path.startswith("FloorSpeaker") or path.endswith("/SpeakerIdle"):
        return "Floor4/DutyDesk/Speaker/*", "Loa trực tầng; idle và thoại dùng cùng hình loa."
    if path.endswith("/WaterDrips"):
        return "Floor4/Washroom/Tap_2/*", "Giọt nước cạnh vòi thứ ba; không đo tới cả phòng."
    if "/DoorLatch407/" in path:
        return "Floor4/Door407/Pivot/HandlePivot/Lever*", "Tiếng chốt bị chặn cạnh tay nắm 407."
    if "/CorpseAudio/" in path:
        return path.split("/CorpseAudio/")[0] + "/Rig/*", "Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation."
    match = re.search(r"/Gag([124])/CorpseVoice/", path)
    if match:
        return ROOM + f"Anchors/Corpse{match[1]}/Body/Rig/Hips/Chest/Head/*", "Nguồn theo Gag/Head; chỉ pose khởi tạo."
    if "/ShowerAudio/" in path:
        return None, "Nguồn chờ tại khoang; Water/Cue được _aim khi phát. Xem bảng vị trí suy từ wiring."
    if path.startswith("MissionAudio/"):
        return None, "Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước."
    if path.startswith(("ManagerAudioFar/", "KhoaTaps/")):
        return None, "Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc."
    if path.startswith("RoomDrips/"):
        return None, "Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể."
    if path.startswith("Player/"):
        return None, "Bước chân theo Player, thân người chơi chưa có trong cảnh production này."
    if path.endswith("/YardInsects"):
        return None, "Lớp nền sân ngoài hành lang, không gắn với một mô hình côn trùng."
    return None, "Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này."


def clean_bus(name: str) -> str:
    return re.sub(r"_(\d+)$", "_<instance>", name)


def source_row(chapter: dict, source: dict) -> dict:
    pattern, reason = binding(source["path"])
    measure = nearest(source["position"], chapter["meshes"], pattern) if pattern else {
        "distance_m": None, "target": "—", "status": "chưa áp dụng", "bounds": None}
    result = dict(source, chapter=chapter["chapter"], **measure, reason=reason)
    # Keep actual NodePaths for reproduction; bus IDs are useful only within the run.
    result["bus"] = clean_bus(source["bus"])
    for bus in result["bus_chain"]:
        bus["name"] = clean_bus(bus["name"])
    result["linear_bus_gain_db"] = round(sum(b["gain_db"] for b in source["bus_chain"]), 3)
    return result


def projected(chapter: dict, name: str, source: str, anchor: str, pattern: str, reason: str) -> dict:
    nodes = {n["path"]: n for n in chapter["nodes"]}
    point = nodes[anchor]["position"]
    return dict(chapter=chapter["chapter"], name=name, source=source, anchor=anchor,
                position=point, reason=reason, **nearest(point, chapter["meshes"], pattern))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", type=Path, default=ROOT / "build/t234/spatial_raw.json")
    parser.add_argument("--output", type=Path, default=ROOT / "audio_source/reports/t234")
    args = parser.parse_args()
    out = args.output.resolve()
    if not any(out.is_relative_to((ROOT / p).resolve()) for p in ["build", "audio_source/reports"]):
        parser.error("Output must stay in this workspace's build/ or audio_source/reports/")
    data = json.loads(args.snapshot.read_text(encoding="utf-8"))
    sources, zones, projections = [], [], []
    for chapter in data["chapters"]:
        sources.extend(source_row(chapter, source) for source in chapter["sources"])
        zones.extend(dict(z, chapter=chapter["chapter"]) for z in chapter["zones"])
        if chapter["chapter"] == 1:
            for name, target, pattern, reason in [
                ("router_power_off / boot / online", "router", PROPS + "Router/*", "_mission_cue → _router_position; đúng đồ phát bíp."),
                ("power_switch / power_short", "ổ cắm dưới sàn", ROOM + "Anchors/PowerStrip/*", "_mission_cue dùng vị trí router cho cả tiếng ổ điện."),
                ("handle_rattle / handle_stop sau cue router", "tay nắm 407", "Floor4/Door407/Pivot/HandlePivot/Lever*", "_hold_the_door chỉ gọi set_handle_rattling, không đặt lại rig sau nhiệm vụ router."),
            ]:
                projections.append(projected(chapter, name + " → " + target, "MissionAudio", ROOM + "Anchors/Router", pattern, reason))
            projections.append(projected(chapter, "handle_rattle khi bắt đầu riêng nhiệm vụ cửa", "MissionAudio/HandleLoop", "MissionAudio", "Floor4/Door407/Pivot/HandlePivot/Lever*", "Vị trí mặc định trước mọi cue; cũng không ở tay nắm."))
            projections.append(projected(chapter, "FlickerBuzz lúc đèn chập chương 1", ROOM + "Room407MainLight/FlickerBuzz", ROOM + "Room407MainLight", ROOM + "Furnished/fixtures/FluorescentTube*", "Nguồn tạo lúc _set_flicker; suy vị trí con local zero, không phát sự kiện."))
        if chapter["chapter"] == 2:
            for name, source, anchor, pattern in [
                ("set_water → đầu vòi", "Water", "Ch2Bathroom/Water", PROPS + "Shower/*"),
                ("mirror_shiver → gương nhỏ", "Cue", "Ch2Bathroom/Reflection", PROPS + "MirrorSmall/*"),
                ("play_door_push / door_burst → tay nắm nhà tắm", "Cue", "Extension/BathroomDoor/Pivot/Handle", ROOM + "Extension/BathroomDoor/Pivot/BathroomDoor/Lever*"),
            ]:
                projections.append(projected(chapter, name, ROOM + "Anchors/ShowerStall/ShowerAudio/" + source, ROOM + anchor, pattern, "ShowerAudio._aim resolve anchor hiện có khi API được gọi; không gọi phát hoặc dời nguồn trong khảo sát."))
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    result = {"revision": revision, "snapshot_sha256": hashlib.sha256(args.snapshot.read_bytes()).hexdigest(),
              "threshold_m": 0.15, "method": "minimum point-to-world-AABB over visible target meshes; not triangle or acoustic distance",
              "sources": sources, "zones": zones, "wiring_projections": projections}
    out.mkdir(parents=True, exist_ok=True)
    (out / "spatial.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    lines = ["# T-234 — bảng nguồn âm và vùng âm", "", "Tự tạo bằng `audio_source/audit_audio_spatial.py`. Node path tương đối với root ChapterN. "
             "Khoảng cách là tới AABB world của mesh hiển thị gần nhất thuộc đúng đồ; không phải khoảng cách tới tam giác. "
             "Ngưỡng khảo sát đề xuất 0,15 m. `—` là chưa áp dụng, không phải 0 m. Mọi đánh giá chất âm: chưa nghe bằng tai, chờ chủ dự án nghe.", ""]
    for number in range(1, 5):
        rows = [s for s in sources if s["chapter"] == number]
        lines += [f"## Chương {number}: {len(rows)} nguồn 3D", "", "| Node path | Đồ / mesh | m | Đánh giá / lý do | Bus; gain player gốc; gain bus tổng |", "|---|---|---:|---|---|"]
        for row in rows:
            dist = "—" if row["distance_m"] is None else f"{row['distance_m']:.4f}"
            lines.append(f"| `{row['path']}` | `{row['target']}` | {dist} | {row['status']}: {row['reason']} | {row['bus']}; {row['base_volume_db']:g}; {row['linear_bus_gain_db']:g} dB |")
    lines += ["", "## Vị trí khi phát, suy từ wiring", "", "Không di chuyển nguồn hay gọi phát âm. Lấy tọa độ anchor thật rồi đối chiếu code caller. Chưa xác nhận bằng chơi tay.", "", "| Chương | Cue / nguồn | Anchor | Mesh gần nhất | m | Kết quả / căn cứ |", "|---|---|---|---|---:|---|"]
    for row in projections:
        lines.append(f"| {row['chapter']} | {row['name']} — `{row['source']}` | `{row['anchor']}` | `{row['target']}` | {row['distance_m']} | {row['status']}: {row['reason']} |")
    lines += ["", "## Vùng âm", "", "Vùng âm là thể tích, không phải nguồn điểm. OK dưới đây chỉ có nghĩa vùng có BoxShape, không xác nhận vùng nghe bao phủ mọi chỗ đứng.", "", "| Chương | Node path | Bounds world min → max | Preset / emitters |", "|---|---|---|---|"]
    for row in zones:
        lines.append(f"| {row['chapter']} | `{row['path']}` | {row['shapes']} | {row['preset']}; {row['emitters']} |")
    (out / "spatial.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"RESULT: spatial audit {len(sources)} sources, {len(zones)} zones, {len(projections)} wiring projections")


if __name__ == "__main__":
    main()
