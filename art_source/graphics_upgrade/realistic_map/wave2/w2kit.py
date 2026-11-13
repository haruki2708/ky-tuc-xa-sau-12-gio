"""T-253 wave 2: the wave-1 mesh kit (../wave1/w1kit.py: Part, material, export) plus what wave 2 adds.

Materials named W1* are wave 1's shared Godot materials (game/assets/models/graphics_pilot/realistic_map/wave1/
materials, mapped by each glb's .import); W2* are this wave's (…/wave2/materials). Frame as wave 1: G(x, y, z)
turns Godot world metres into Blender's (glTF export turns them back).
"""
import sys
from pathlib import Path

from mathutils import Vector

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE))
import w1kit  # noqa: E402,F401
from w1kit import Part, material, reset, triangles  # noqa: E402,F401
import layout as L  # noqa: E402,F401

OUT = w1kit.ROOT / "game/assets/models/graphics_pilot/realistic_map/wave2"
PLASTER = 2.0  # metres per repeat of the Painted Plaster Wall scan (the shell shader has no uv1_scale)
TERRAZZO = 1.0
# UV1 sizes for the shell-shader materials (their UV1 is in scan repeats); everything else keeps metres.
SIZES = {"W1StairWall": PLASTER, "W1StairDado": PLASTER, "W1Soffit": PLASTER, "W1StairSide": PLASTER,
	"W1Terrazzo": TERRAZZO, "W2HallWall": PLASTER, "W2HallDado": PLASTER, "W2HallCeiling": PLASTER,
	"W2HallFloor": TERRAZZO}
# Blender preview colours of the placeholders (Godot swaps every one for its .tres).
PREVIEW = {
	"W1Terrazzo": ((0.58, 0.58, 0.55), 0.45, 0.0), "W1StairSide": ((0.7, 0.68, 0.62), 0.85, 0.0),
	"W1Soffit": ((0.75, 0.73, 0.66), 0.9, 0.0), "W1StairWall": ((0.8, 0.76, 0.64), 0.85, 0.0),
	"W1StairDado": ((0.45, 0.52, 0.48), 0.8, 0.0), "W1RailWood": ((0.35, 0.2, 0.1), 0.5, 0.0),
	"W1RailSteel": ((0.18, 0.3, 0.2), 0.5, 0.5), "W1Steel": ((0.6, 0.6, 0.58), 0.38, 1.0),
	"W1Concrete": ((0.55, 0.55, 0.52), 0.9, 0.0), "W1DoorPaint": ((0.12, 0.3, 0.2), 0.6, 0.3),
	"W1Granite": ((0.3, 0.3, 0.3), 0.5, 0.0), "W1Black": ((0.03, 0.03, 0.03), 0.6, 0.0),
	"W1WoodPale": ((0.6, 0.48, 0.34), 0.78, 0.0), "W1Wood": ((0.45, 0.3, 0.2), 0.6, 0.0),
	"W1Enamel": ((0.88, 0.88, 0.84), 0.2, 0.0), "W1Alu": ((0.8, 0.8, 0.78), 0.35, 1.0),
	"W1Iron": ((0.17, 0.17, 0.16), 0.55, 0.6), "W1SpeakerPaint": ((0.74, 0.74, 0.7), 0.5, 0.0),
	"W1Brass": ((0.74, 0.58, 0.3), 0.34, 1.0), "W1Rubber": ((0.12, 0.1, 0.1), 0.85, 0.0),
	"W1Paper": ((0.84, 0.83, 0.78), 0.9, 0.0), "W1Rebar": ((0.27, 0.15, 0.08), 0.8, 0.5),
	"W2HallWall": ((0.8, 0.76, 0.64), 0.85, 0.0), "W2HallDado": ((0.45, 0.52, 0.48), 0.8, 0.0),
	"W2HallFloor": ((0.58, 0.58, 0.55), 0.45, 0.0), "W2HallCeiling": ((0.75, 0.73, 0.66), 0.9, 0.0),
	"W2Divider": ((0.35, 0.3, 0.22), 0.5, 0.6), "W2Tube": ((0.95, 0.97, 0.92), 0.3, 0.0),
	"W2Mattress": ((0.7, 0.66, 0.6), 0.9, 0.0), "W2Chieu": ((0.7, 0.6, 0.4), 0.8, 0.0),
	"W2BunkPaint": ((0.15, 0.25, 0.3), 0.55, 0.4), "W2LockerPaint": ((0.55, 0.6, 0.56), 0.5, 0.3),
	"W2Glass": ((0.5, 0.58, 0.56), 0.08, 0.0), "W2ExtRed": ((0.55, 0.04, 0.03), 0.3, 0.0),
	"W2ExtLabel": ((0.8, 0.8, 0.76), 0.5, 0.0), "W2Gauge": ((0.9, 0.9, 0.86), 0.3, 0.0),
	"W2AlarmRed": ((0.6, 0.05, 0.04), 0.4, 0.0), "W2AlarmFace": ((0.6, 0.05, 0.04), 0.5, 0.0),
	"W2AlarmButton": ((0.88, 0.86, 0.8), 0.25, 0.0), "W2Pillow": ((0.75, 0.78, 0.82), 0.85, 0.0),
	"W2Blade": ((0.7, 0.7, 0.68), 0.25, 1.0), "W2Grip": ((0.08, 0.07, 0.06), 0.6, 0.0),
}


def G(x, y, z):
	return Vector((x, -z, y))


def materials():
	for name, (colour, rough, metal) in PREVIEW.items():
		material(name, colour, rough, metal)


def export(name, objs):
	w1kit.export(OUT / name, objs)


def keep_uv(part, faces):
	"""Faces whose UV1 is set by hand. bmesh operators clear the face tag that Part.build() reads to leave a face's
	UV alone, so the faces are kept here and tagged again just before the build."""
	if not hasattr(part, "kept_uv"):
		part.kept_uv = []
	part.kept_uv.extend(faces)


def planar_uv(part, faces, *args, **kwargs):
	part.planar_uv(faces, *args, **kwargs)
	keep_uv(part, faces)


def build(part, origin=(0, 0, 0)):
	for f in getattr(part, "kept_uv", []):
		if f.is_valid:
			f.tag = True
	return part.build(origin=origin, uv_size=SIZES)


def quad(part, mat_name, a, b, c, d, facing=None):
	"""One quad (Godot points), its normal turned towards `facing` (a Godot direction) when given."""
	f = part.poly(mat_name, [G(*a), G(*b), G(*c), G(*d)], [(0, 1, 2, 3)], recalc=False)[0]
	f.normal_update()
	if facing is not None:
		want = G(*facing)
		if f.normal.dot(want) < 0:
			f.normal_flip()
	return f


def gbox(part, mat_name, lo, hi, bevel=0.0, segments=1):
	"""A box between two Godot corners."""
	return part.box(mat_name, tuple(G(*lo)), tuple(G(*hi)), bevel=bevel, segments=segments)
