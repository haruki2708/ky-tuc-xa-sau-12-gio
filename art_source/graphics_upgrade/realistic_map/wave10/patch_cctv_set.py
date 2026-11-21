"""T-267 (D-188 points 1-6): hang wave 10 in game/scenes/levels/cctv/cctv_set.tscn, only in the five Room* branches.
Each Room<n> gets, after its last node (Cam):
  Real       Node3D with cctv_room_real.gd: the room and its corridor in building B's style, room 407's furniture
             (it hides the PS1 meshes at run time; no collider, light, camera or marker changes)
  Occluders  seven OccluderInstance3D boxes inside the PS1 walls' thickness, so a feed no longer draws the rooms and
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
# [name, box size, centre] in Room<n> metres. Thickness 0.16 inside the PS1 walls' 0.2; heights from under the floor
# slab (-0.2) to the top of the ceiling slab (3.15) so a ray over a wall's top edge still meets a box.
BOXES = [
	("WestWall", (0.16, 3.35, 5.0), (0.0, 1.475, -2.5)),
	("EastWall", (0.16, 3.35, 5.0), (4.0, 1.475, -2.5)),
	("FrontWest", (2.9, 3.35, 0.16), (0.55, 1.475, 0.0)),  # FrontWallLeft and Hall/RoomWallWest: x -0.9..2.0
	("FrontEast", (2.0, 3.35, 0.16), (3.9, 1.475, 0.0)),  # FrontWallRight and Hall/RoomWallEast: x 2.9..4.9
	("Lintel", (0.9, 0.95, 0.16), (2.45, 2.675, 0.0)),  # DoorLintel: y 2.2..3.15
	("HallEndWest", (0.16, 3.35, 2.5), (-0.95, 1.475, 1.25)),
	("HallEndEast", (0.16, 3.35, 2.5), (4.95, 1.475, 1.25)),
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
