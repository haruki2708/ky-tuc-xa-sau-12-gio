"""T-263: scene patches for wave 6 (canteen, kitchen, store, the A16 strip round the canteen). Steps run in the order given:
  python -B art_source/graphics_upgrade/realistic_map/wave6/patch_canteen.py heads

- heads (round 1, step 0; HARU allowed it, card T-263 section 2.0): T-259 hid props.tscn Parts/P_paper_box_p0_p0 whole
  (wave3/garden_layout.py A16_HIDE "all"), and with it the heads of six static corpses in the garden (instances #1-3 and
  #10-12, the skin-tinted 0.22 m boxes). The node is shown again and only its seven other instances, the ones T-259
  replaced (#0 a rice tray, #4-9 the notice board's six sheets), are scaled to 0, entries kept. wave3/build_garden.py no
  longer lays a paper card where those heads are (strip_props.glb rebuilt).
"""
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
LEVELS = ROOT / "game/scenes/levels/campus"
SKIN = (0.9, 0.7, 0.6)
HEAD_CHUNK = "P_paper_box_p0_p0"


def read(path):
	return path.read_text(encoding="utf-8")


def write(path, text):
	path.write_text(text, encoding="utf-8", newline="\n")


def node_block(text, name, parent):
	head = '[node name="%s" type="Node3D" parent="%s"]' % (name, parent)
	start = text.index(head)
	end = text.find("\n[", start + len(head))
	return start, (len(text) if end < 0 else end + 1)


def step_heads():
	path = LEVELS / "props.tscn"
	text = read(path)
	start, end = node_block(text, HEAD_CHUNK, "Parts")
	block = text[start:end]
	assert "\nvisible = false" in block, "already shown"
	block = block.replace("\nvisible = false", "", 1)
	m = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
	values = m.group(1).split(",")
	assert len(values) == 13 * 16, len(values)
	heads = zeroed = 0
	for k in range(0, len(values), 16):
		if tuple(round(float(v), 3) for v in values[k + 12:k + 15]) == SKIN:
			heads += 1
			continue
		for c in range(9):
			values[k + c] = "0"
		zeroed += 1
	assert heads == 6 and zeroed == 7, (heads, zeroed)
	block = block[:m.start(1)] + ",".join(values) + block[m.end(1):]
	write(path, text[:start] + block + text[end:])
	print("patched props.tscn: %s shown, %d heads back, %d replaced instances scaled to 0" % (HEAD_CHUNK, heads, zeroed))


if __name__ == "__main__":
	steps = {"heads": step_heads}
	for key in sys.argv[1:]:
		steps[key]()
