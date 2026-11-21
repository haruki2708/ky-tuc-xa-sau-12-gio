"""T-267 (D-188 points 1-6): hang wave 10 in game/scenes/levels/cctv/cctv_set.tscn, only in the five Room* branches.
Each Room<n> gets, after its last node (Cam):
  Real       Node3D with cctv_room_real.gd: the room and its corridor in building B's style, room 407's furniture
             (it hides the PS1 meshes at run time; no collider, light, camera or marker changes)
  Occluders  nine OccluderInstance3D boxes inside the PS1 walls' thickness, so a feed no longer draws the rooms and
             corridors behind them (the director's feeds use occlusion culling since 1324a2aa). Each box stays behind
             the new visible faces from every feed camera (the room walls' inner faces at x 0.1 / 3.9, z -0.1, the
             corridor's at z 0.1 and x -0.85 / 4.85), clear of the doorway (x 2.0..2.9 under 2.2) and of the open side
             of the corridor; none at the back wall (nothing stands behind it) nor in the open corridor side.
The Corridor branch (T-256) is not touched. Run from the repository root (idempotent):
  python -B art_source/graphics_upgrade/realistic_map/wave10/patch_cctv_set.py
"""
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
SCENE = ROOT / "game/scenes/levels/cctv/cctv_set.tscn"
ROOMS = ("102", "306", "209", "106", "310")
SCRIPT = '[ext_resource type="Script" path="res://scenes/levels/cctv/cctv_room_real.gd" id="t267_real"]'
# [name, box size, centre] in Room<n> metres: one box inside each PS1 wall collider (test_t260_occlusion: every occluder
# sits inside one solid layer-1 box), 0.16 thick inside the walls' 0.2, as high as the walls (0..3; every feed camera
# hangs under 3 m and the new set stays under 3 m, so a ray to anything behind a wall crosses the wall under its top).
BOXES = [
	("WestWall", (0.16, 3.0, 5.0), (0.0, 1.5, -2.5)),  # WestWall
	("EastWall", (0.16, 3.0, 5.0), (4.0, 1.5, -2.5)),  # EastWall
	("FrontWest", (2.0, 3.0, 0.16), (1.0, 1.5, 0.0)),  # FrontWallLeft: x 0..2.0
	("FrontEast", (1.1, 3.0, 0.16), (3.45, 1.5, 0.0)),  # FrontWallRight: x 2.9..4.0
	("Lintel", (0.9, 0.8, 0.16), (2.45, 2.6, 0.0)),  # DoorLintel: y 2.2..3.0
	("HallWallWest", (0.9, 3.0, 0.16), (-0.45, 1.5, 0.0)),  # Hall/RoomWallWest: x -0.9..0
	("HallWallEast", (0.9, 3.0, 0.16), (4.45, 1.5, 0.0)),  # Hall/RoomWallEast: x 4.0..4.9
	("HallEndWest", (0.16, 3.0, 2.5), (-0.95, 1.5, 1.25)),  # Hall/EndWest
	("HallEndEast", (0.16, 3.0, 2.5), (4.95, 1.5, 1.25)),  # Hall/EndEast
]


def fmt(v):
	return "Vector3(%s)" % ", ".join(("%g" % c) for c in v)


def main():
	text = SCENE.read_text(encoding="utf-8")
	if SCRIPT in text:
		print("T267_PATCH already applied")
		return
	lines = text.split("\n")
	last_ext = max(i for i, l in enumerate(lines) if l.startswith("[ext_resource "))
	lines.insert(last_ext + 1, SCRIPT)
	last_sub = max(i for i, l in enumerate(lines) if l.startswith("[sub_resource "))
	end = last_sub + 1
	while end < len(lines) and lines[end].strip():
		end += 1
	sizes = []
	for _, size, _ in BOXES:
		if size not in sizes:
			sizes.append(size)
	subs = []
	for k, size in enumerate(sizes):
		subs += ["", f'[sub_resource type="BoxOccluder3D" id="t267_occ{k}"]', f"size = {fmt(size)}"]
	lines[end:end] = subs
	text = "\n".join(lines)
	for number in ROOMS:
		room = f"Room{number}"
		block = [f'[node name="Real" type="Node3D" parent="{room}"]', 'script = ExtResource("t267_real")', "",
			f'[node name="Occluders" type="Node3D" parent="{room}"]', ""]
		for name, size, centre in BOXES:
			block += [f'[node name="{name}" type="OccluderInstance3D" parent="{room}/Occluders"]',
				f"position = {fmt(centre)}", f'occluder = SubResource("t267_occ{sizes.index(size)}")', ""]
		match = re.search(r'\[node name="Cam" type="Camera3D" parent="%s"\]\n(?:[^\n\[]+\n)*' % room, text)
		assert match, room
		insert = match.end()
		# A blank line, the block, then whatever followed Cam (a blank line and the next node, or the end).
		text = text[:insert] + "\n" + "\n".join(block[:-1]) + "\n" + text[insert:]
	SCENE.write_text(text.rstrip("\n") + "\n", encoding="utf-8", newline="\n")
	print("T267_PATCH", len(ROOMS), "rooms,", len(BOXES), "occluders each")


if __name__ == "__main__":
	main()
