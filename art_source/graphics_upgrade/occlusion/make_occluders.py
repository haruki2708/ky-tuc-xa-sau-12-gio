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

# (regex on the collision shape's path in the chapter, kind). kind: "plane" (wall or slab, ends 0.1 m in),
# "plane:<end inset m>", or "solid:<inset m>" (optionally "|zmax=<world z>").
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
	# T-264 (D-182): floors 5-6 get a blocked corridor drawn inside this block's front 4 m (z 0..4), so the occluder
	# stops at the corridor's back wall (z 0) instead of 0.3 m inside the front face (z 3.7).
	(r"Campus/BuildingB/UpperFloor[56]/Collision", "solid:0.3|zmax=0.0"),
	(r"Campus/Shells/(BuildingA|Lecture|Gym)/Shell/Collision", "solid:0.5"),
	# The canteen (T-263, D-181): its closed walls and roof. Not the front wall (ten clear-glass windows and the main
	# door) nor the floor; the west wall's two boxes stop at the west exit's doorway, the back wall's three at the
	# kitchen's and the store's.
	(r"Campus/Canteen/(Roof|Side210|Back178|Back199\.5|Back206\.5)/Collision", "plane"),
	(r"Campus/Canteen/(KitchenSide186|KitchenSide198|KitchenBack|StoreSide)/Collision", "plane"),
	# The store's back door frame (Real/Store/BackDoor) laps 0.3 m over the wall either side of its doorway.
	(r"Campus/Canteen/(StoreBack199|StoreBack207)/Collision", "plane:0.4"),
	(r"Campus/Canteen/WestExit/(SouthWall|NorthWall)/Collision", "plane"),
]
# The library (after T-265, D-185/D-186), written after CAMPUS so the boxes above keep their ids. Lane B's "Mặt đặc kín":
# the four outer walls have no real hole but the front and back doorways (x 64..66, y -9.9..-7.5), every window is dark
# glass (W7GlassDark, opaque) in the wall's thickness, the slabs are open only over the stair well (x 79..85,
# z 199..209), which their three pieces per floor leave out, and the roof is closed. The front and back walls' occluders
# sit in the walls' outer half ("at=": in front of the panes on the middle plane), clear of the shells' window dressing
# ("Windows", from the panes inward). Not the ground slabs (nothing under them), nor the lintels over the doorways
# (2 cm from the door frames).
LIBRARY = [
	(r"Campus/Library/(West|East)[012]/Collision", "plane"),
	(r"Campus/Library/(FrontW|FrontE|Front1|Front2)/Collision", "plane|at=194.97"),
	(r"Campus/Library/(BackW|BackE|Back1|Back2)/Collision", "plane|at=225.03"),
	(r"Campus/Library/Floor[12]_(Main|South|North)/Collision", "plane"),
	(r"Campus/Library/Roof/Collision", "plane"),
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
	# "...|zmax=<world z>": the box is cut off at that z (what is drawn in front of it stays visible).
	kind, _, clip = kind.partition("|")
	if kind.startswith("solid:"):
		inset = float(kind.split(":")[1])
		origin = list(box["origin"])
		out = [s - 2 * inset for s in size]
		if clip.startswith("zmax="):
			top = min(float(clip.split("=")[1]), origin[2] + out[2] / 2)
			bottom = origin[2] - out[2] / 2
			origin[2], out[2] = (top + bottom) / 2, top - bottom
		return origin, out
	# "plane" or "plane:<end inset m>" (a doorway's frame reaching over the wall beside it); "...|at=<world>" puts the
	# plane there across the box's thickness instead of on its middle.
	inset = float(kind.split(":")[1]) if ":" in kind else INSET
	thin = size.index(min(size))
	out = [s - 2 * inset for s in size]
	out[thin] = THIN
	origin = list(box["origin"])
	if clip.startswith("at="):
		origin[thin] = float(clip.split("=")[1])
		assert abs(origin[thin] - box["origin"][thin]) + THIN / 2 <= size[thin] / 2, box["path"]
	return origin, out


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
	write("OccludersCampus", pick(ch3, CAMPUS) + pick(ch3, LIBRARY), OUT / "occluders_campus.tscn")


if __name__ == "__main__":
	main()
