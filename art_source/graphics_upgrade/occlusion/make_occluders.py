"""T-260: write the core occluder scenes (game/scenes/main/occlusion/) from a survey of the real chapters.

Each occluder is a BoxOccluder3D inside one solid layer-1 collision box of a wall, floor slab or closed block, picked
by name below: 4 cm thick on the box's middle plane (walls, slabs), its ends 0.1 m in from the box's ends (so 0.1 m
clear of any doorway beside it). Closed blocks (upper floors of building B, the campus shells) shrink 0.3-0.5 m
on every side. Not used: back walls (balcony doors, bathroom windows), stairwells, the retired PS1 walls, windows,
railings, doors.

Survey first (Godot lock): copy survey.gd to game/_probe_tmp/t260_survey.gd with a t260_survey.tscn whose root
Node3D carries it, then
    godot --headless --path game res://_probe_tmp/t260_survey.tscn -- --chapter=1   (and --chapter=3)
which writes build/haru/t260_survey_ch1.json and _ch3.json. Then:
    python -B art_source/graphics_upgrade/occlusion/make_occluders.py
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
SURVEY = ROOT / "build/haru"
OUT = ROOT / "game/scenes/main/occlusion"
THIN = 0.04
INSET = 0.1

# (regex on the collision shape's path in the chapter, kind). kind: "plane" (wall or slab), or "solid:<inset m>".
FLOOR4 = [
	(r"Floor4/Corridor/Floor/Collision", "plane"),
	(r"Floor4/Rooms/Room\d+/RoomFloor/Room", "plane"),
	(r"Floor4/Room407/Floor/Collision", "plane"),
	(r"Floor4/Washroom/Floor/Collision", "plane"),
	(r"Floor4/Corridor/(Facade_\d+_[WE]|Former408Wall|Room408FrontWest)/WorldCollision/Bounds", "plane"),
	(r"Floor4/Corridor/Doorway_\d+/WorldCollision/Lintel", "plane"),
	(r"Floor4/Rooms/Room\d+/Collision/(WestWall|EastWall)", "plane"),
	(r"Floor4/Room407/(WestWall|EastWall)/Collision", "plane"),
	(r"Floor4/Washroom/(WestWall|EastWall|BackWall|EntranceWest|EntranceEast|EntranceLintel)/Collision", "plane"),
]
CAMPUS = [
	(r"Campus/BuildingB/Floor[23]/Slab/Collision", "plane"),
	(r"Campus/BuildingB/Floor3/Ceiling/Collision", "plane"),
	# Not floor 1's Partition0: the manager room's window (W2ManagerWindow) is drawn across it.
	(r"Campus/BuildingB/Floor[123]/(West|East|Partition[1-9]\d*)/Collision", "plane"),
	(r"Campus/BuildingB/Floor[23]/Partition0/Collision", "plane"),
	(r"Campus/BuildingB/Floor[123]/(Facade\d+[LR]|Lintel\d+)/Collision", "plane"),
	(r"Campus/BuildingB/UpperFloor[56]/Collision", "solid:0.3"),
	(r"Campus/Shells/(BuildingA|Lecture|Gym)/Shell/Collision", "solid:0.5"),
]


def pick(survey, rules):
	"""The boxes matching `rules`, one per place (two rooms share a partition: the first one wins)."""
	boxes = []
	seen = set()
	for box in survey["boxes"]:
		for pattern, kind in rules:
			if re.fullmatch(pattern, box["path"]) and box["layer"] & 1:
				if max(abs(r) for r in box["rot"]) > 0.5:
					raise SystemExit(f"rotated box, not handled: {box['path']} {box['rot']}")
				key = (tuple(round(v, 2) for v in box["origin"]), tuple(round(abs(v), 2) for v in box["size"]))
				if key not in seen:
					seen.add(key)
					boxes.append((box, kind))
				break
	return boxes


def occluder(box, kind):
	size = [abs(s) for s in box["size"]]
	if kind.startswith("solid:"):
		inset = float(kind.split(":")[1])
		return box["origin"], [s - 2 * inset for s in size]
	thin = size.index(min(size))
	out = [s - 2 * INSET for s in size]
	out[thin] = THIN
	return box["origin"], out


def node_name(path):
	parts = [p for p in path.split("/") if p not in ("Collision", "WorldCollision", "Bounds", "Floor4", "Campus")]
	return re.sub(r"[^A-Za-z0-9_]", "_", "_".join(parts))


def write(name, boxes, path):
	lines = ["[gd_scene format=3]", ""]
	for i, (box, kind) in enumerate(boxes):
		_, size = occluder(box, kind)
		lines += [f'[sub_resource type="BoxOccluder3D" id="Box_{i}"]', "size = Vector3(%.3f, %.3f, %.3f)" % tuple(size), ""]
	lines += [f'[node name="{name}" type="Node3D"]', ""]
	used = set()
	for i, (box, kind) in enumerate(boxes):
		origin, _ = occluder(box, kind)
		node = node_name(box["path"])
		assert node not in used, node
		used.add(node)
		lines += [f'[node name="{node}" type="OccluderInstance3D" parent="."]',
			"transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %.3f, %.3f, %.3f)" % tuple(origin),
			f'occluder = SubResource("Box_{i}")', ""]
	path.write_text("\n".join(lines), encoding="utf-8", newline="\n")
	print(f"T260_OCCLUDERS {path.name}: {len(boxes)}")


def main():
	ch1 = json.loads((SURVEY / "t260_survey_ch1.json").read_text(encoding="utf-8"))
	ch3 = json.loads((SURVEY / "t260_survey_ch3.json").read_text(encoding="utf-8"))
	OUT.mkdir(parents=True, exist_ok=True)
	write("OccludersFloor4", pick(ch1, FLOOR4), OUT / "occluders_floor4.tscn")
	write("OccludersCampus", pick(ch3, CAMPUS), OUT / "occluders_campus.tscn")


if __name__ == "__main__":
	main()
