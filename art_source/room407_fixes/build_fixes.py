"""Rebuild T-203's authored navigation strips and recessed outlet (stdlib only)."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
LEVELS = ROOT / "game/scenes/levels"
vertices = []
polygons = []


def polygon(points):
    indices = []
    for point in points:
        if point not in vertices:
            vertices.append(point)
        indices.append(vertices.index(point))
    polygons.append(indices)


# Centre-space corridors include clearance for a 0.35 m radius actor.
# Shared edges are split explicitly so every branch joins the same mesh.
polygon([(1.94, .3), (2.03, .3), (2.03, -1.25), (1.94, -1.25)])
polygon([(1.94, -1.25), (2.03, -1.25), (2.5, -1.6), (1.5, -1.6)])
polygon([(1.5, -1.6), (2.5, -1.6), (2.5, -2.5), (1.5, -2.5)])
for left, right in [(2.5, 3.5), (3.5, 3.7), (3.7, 5.7), (5.7, 6.5)]:
    polygon([(left, -1.6), (right, -1.6), (right, -2.5), (left, -2.5)])
polygon([(5.7, -2.5), (6.5, -2.5), (6.5, -3.5), (5.7, -3.5)])
polygon([(5.7, -3.5), (6.5, -3.5), (5.95, -3.55), (5.75, -3.55)])
polygon([(5.75, -3.55), (5.95, -3.55), (5.95, -4.5), (5.75, -4.5)])
polygon([(5.75, -4.5), (5.95, -4.5), (6.85, -4.6), (6.7, -5.2), (5.85, -5.2)])
polygon([(5.85, -5.2), (6.7, -5.2), (6.7, -6.4), (5.85, -6.4)])
polygon([(3.5, -2.5), (3.7, -2.5), (3.7, -4.9), (3.5, -4.9)])
polygon([(3.5, -4.9), (3.7, -4.9), (2.9, -5.5), (2.7, -5.5)])
polygon([(2.7, -5.5), (2.9, -5.5), (2.9, -7.5), (2.7, -7.5)])
polygon([(2.7, -7.5), (2.9, -7.5), (4.75, -7.6), (4.75, -8.05), (.45, -8.05), (.45, -7.6)])
nav = "vertices = PackedVector3Array(" + ", ".join(f"{x}, 0.03, {z}" for x, z in vertices) + ")\n"
nav += "polygons = [" + ", ".join("PackedInt32Array(" + ",".join(map(str, p)) + ")" for p in polygons) + "]"
path = LEVELS / "floor4/room_407.tscn"
text = path.read_text(encoding="utf-8")
text = re.sub(r"vertices = PackedVector3Array\([^\n]+\)\npolygons = \[[^\n]+\]", nav, text)
path.write_text(text, encoding="utf-8", newline="\n")

# Depth runs along local X, with the finished wall face at room X=0.10.
# Four trim pieces surround a dark recess; the cover leaves a real bottom gap.
parts = [
    ("Recess", (.102, 0, 0), (.004, .15, .13), "dark"),
    ("TopTrim", (.112, .086, 0), (.024, .022, .174), "ivory"),
    ("BottomTrim", (.112, -.086, 0), (.024, .022, .174), "ivory"),
    ("LeftTrim", (.112, 0, -.076), (.024, .15, .022), "ivory"),
    ("RightTrim", (.112, 0, .076), (.024, .15, .022), "ivory"),
    ("Cover", (.119, .008, 0), (.018, .12, .12), "ivory"),
    ("ContactLeft", (.129, .02, -.025), (.003, .031, .009), "dark"),
    ("ContactRight", (.129, .02, .025), (.003, .031, .009), "dark"),
    ("ScrewTop", (.129, .056, 0), (.003, .007, .007), "dark"),
]
scene = '[gd_scene format=3]\n\n'
scene += '[ext_resource type="Shader" path="res://rendering/ps1_surface.gdshader" id="shader"]\n'
for name, color in [("ivory", "0.65, 0.64, 0.51, 1"), ("dark", "0.035, 0.031, 0.025, 1")]:
    scene += f'\n[sub_resource type="ShaderMaterial" id="{name}"]\nshader = ExtResource("shader")\nshader_parameter/albedo_color = Color({color})\n'
for name, pos, size, material in parts:
    scene += f'\n[sub_resource type="BoxMesh" id="{name}"]\nsize = Vector3{size}\nmaterial = SubResource("{material}")\n'
scene += '\n[node name="KhoaOutlet" type="Node3D"]\n'
for name, pos, size, material in parts:
    scene += f'\n[node name="{name}" type="MeshInstance3D" parent="."]\nposition = Vector3{pos}\nmesh = SubResource("{name}")\n'
(LEVELS / "room407/khoa_outlet.tscn").write_text(scene, encoding="utf-8", newline="\n")
