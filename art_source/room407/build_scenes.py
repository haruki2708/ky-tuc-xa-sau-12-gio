"""Generate only T-153 dressing/anchors; patch existing room without regenerating the floor."""
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "art_source/floor4"))
import build_floor4 as base

OUT = ROOT / "game/scenes/levels/room407"
base.OUT = OUT
Scene, vec = base.Scene, base.vec


def mat(s, name, cutout=False):
    shader = s.resource("res://rendering/ps1_surface_cutout.gdshader" if cutout else "res://rendering/ps1_surface.gdshader", "Shader")
    tex = s.resource(f"res://assets/textures/room407/{name}.png", "Texture2D")
    s.materials[name] = s.subresource("ShaderMaterial", f"shader = {shader}\nshader_parameter/albedo_texture = {tex}\nshader_parameter/roughness = 0.95")
    return s.materials[name]


def box(s, name, at, size, material="wood", parent="."):
    s.box(name, at, size, material, parent, solid=False)


def model(s, name, asset, at, rotation=(0, 0, 0), parent=".", props=False, scale=(1, 1, 1)):
    folder = "props" if props else "room407"
    s.node(name, parent=parent, instance=s.resource(f"res://assets/models/{folder}/{asset}.glb"),
           properties=f"position = {vec(at)}\nrotation_degrees = {vec(rotation)}\nscale = {vec(scale)}")


def plane(s, name, at, size, parent=".", rotation=(-90, 0, 0)):
    mesh = s.subresource("QuadMesh", f"size = Vector2({size[0]}, {size[1]})\nmaterial = {s.materials['blood']}")
    s.node(name, "MeshInstance3D", parent, f"position = {vec(at)}\nrotation_degrees = {vec(rotation)}\nmesh = {mesh}\ncast_shadow = 0")


def dressing():
    s = Scene("Details")
    for name in ("wood", "paper", "cloth", "ink", "moss"):
        mat(s, name)
    mat(s, "blood", True)
    for person in ("Phuc", "Viet", "Trung", "Dat"):
        s.node(person)
    # Narrow wall shelves keep personal objects out of the central passage.
    for person, x, height in (("Phuc", .30, 1.9), ("Viet", .30, .88), ("Dat", 3.70, 1.9)):
        box(s, "Shelf", (x, height, -1.84), (.40, .035, .80), parent=person)
    model(s, "Textbooks", "books", (.30, 1.92, -1.84), (0, 90, 0), "Phuc")
    model(s, "Headphones", "headphones", (.30, 1.92, -1.52), (0, 90, 0), "Phuc")
    model(s, "InstantNoodles", "noodles", (.30, 1.92, -2.15), parent="Phuc")
    model(s, "FootballPoster", "football_poster", (.105, 2.26, -2.82), (0, -90, 0), "Phuc")
    model(s, "OldLaptop", "laptop", (.30, .90, -1.82), (0, -90, 0), "Viet")
    model(s, "FamilyPhoto", "family_photo", (.16, .90, -2.22), (0, -90, 0), "Viet")
    model(s, "Guitar", "guitar", (.19, .06, -1.80), (-80, -90, 0), "Viet")
    model(s, "Backpack", "backpack", (3.78, .02, -4.52), (0, 90, 0), "Trung")
    model(s, "PowerStrip", "power_strip", (2.17, .77, -4.67), parent="Trung")
    model(s, "ChargingCableNoAdapter", "charging_cable", (1.66, .78, -4.51), parent="Trung")
    model(s, "Notebook", "notebook", (1.27, .77, -4.53), (0, -12, 0), "Dat")
    model(s, "Trainers", "trainers", (3.63, .015, -1.87), (0, 15, 0), "Dat")
    model(s, "Books", "books", (3.70, 1.92, -1.84), (0, 90, 0), "Dat")
    s.node("Slippers")
    for person, x, color in (("Phuc",.67,"0.55,0.055,0.045"),("Viet",1.0,"0.055,0.20,0.55"),("Trung",3.0,"0.08,0.35,0.14"),("Dat",3.33,"0.04,0.045,0.05")):
        s.node(person,parent="Slippers",instance=s.resource("res://scenes/levels/props/slippers_pair.tscn"),properties=f"position = Vector3({x},0.005,-0.18)\nrotation_degrees = Vector3(0,180,0)\ncolor = Color({color},1)")
    box(s, "RouterShelf", (3.77, 2.11, -.55), (.25, .025, .44))
    model(s, "Router", "router", (3.78, 2.13, -.55), (0, 90, 0))
    box(s, "ClothesLine", (2, 2.58, -3.90), (3.42, .012, .012), "ink")
    for i in range(3):
        model(s, "HangingShirt_%d" % i, "shirt", (1.2 + i * .78, 2.50, -3.90), (0, 12 - i * 8, 0), props=True, scale=(.8, .8, .8))
    model(s, "Bucket", "bucket", (.50, .015, -4.60), props=True)
    model(s, "FoldedTowel", "towel", (.49, .40, -4.60), (90, 0, 0), props=True, scale=(.5, .5, .5))
    # Separate blankets can be stained while T-154 bodies remain replaceable.
    for number, x, y in ((1, .65, 1.43), (2, .65, .66), (4, 3.35, 1.43)):
        box(s, "Blanket%d" % number, (x, y, -2.98), (.64, .16, 1.15), "cloth")
    s.node("BloodSeep", properties="visible = false")
    s.node("BloodPools", properties="visible = false")
    for number, x, y in ((1, .65, 1.515), (2, .65, .745), (4, 3.35, 1.515)):
        plane(s, "BlanketStain%d" % number, (x, y, -2.98), (.62, 1.08), "BloodSeep")
        edge_x = x + (.34 if x < 2 else -.34)
        plane(s, "HangingStain%d" % number, (edge_x, y - .17, -2.8), (.35, .28), "BloodSeep", (0, 90, 0))
        plane(s, "Droplet%d" % number, (edge_x + (.025 if x < 2 else -.025), y - .25, -2.8), (.018, .09), "BloodSeep", (0, 90, 0))
        plane(s, "SmallStain%d" % number, (edge_x, .009 + number * .001, -2.8), (.20, .27), "BloodSeep")
        plane(s, "Pool%d" % number, (edge_x + (.08 if x < 2 else -.08), .005 + number * .001, -2.75 - number * .15), (.9, 1.1), "BloodPools")
    s.node("TrungBedding")
    # Eight independent strips expose the wooden board as damage rises.
    for i in range(8):
        z = -3.84 + i * .235
        s.node("Section%d" % i, parent="TrungBedding")
        box(s, "Mattress", (3.35, .405, z), (.80, .05, .23), "paper", "TrungBedding/Section%d" % i)
        box(s, "Quilt", (3.35, .438, z), (.77, .014, .229), "moss", "TrungBedding/Section%d" % i)
    box(s, "TrungPillow", (3.35, .475, -2.3), (.54, .06, .3), "cloth")
    s.node("SlashRips", properties="visible = false")
    s.node("Debris", properties="visible = false")
    for i in range(8):
        box(s, "Rip%d" % i, (3.35, .45, -3.83 + i * .235), (.79, .009, .018), "ink", "SlashRips")
        mesh = s.subresource("PrismMesh", f"size = Vector3(0.16,0.025,0.19)\nmaterial = {s.materials['paper' if i % 2 else 'moss']}")
        s.node("Scrap%d" % i,"MeshInstance3D","Debris",f"position = {vec((2.57 + (i * 7 % 5) * .125,.014 + (i % 2)*.007,-3.72 + (i*11%9)*.17))}\nrotation_degrees = {vec((0,i*47,0))}\nmesh = {mesh}")
    s.save("room407_details.tscn")


def anchors():
    s = Scene("Anchors")
    s.node("Bunks")
    for number, x, y, owner in ((1, .65, 1.20, "Phuc"), (2, .65, .43, "Viet"), (3, 3.35, .43, "Trung"), (4, 3.35, 1.20, "Dat")):
        root = s.node("Bunk%d" % number, "Marker3D", "Bunks", f"position = {vec((x,y,-3))}\nmetadata/bed_number = {number}\nmetadata/owner_name = &\"{owner}\"")
        s.node("View", "Marker3D", root, "position = Vector3(0, 0.43, 0.64)\nrotation_degrees = Vector3(15, 0, 0)")
        s.node("Exit", "Marker3D", root, f"position = {vec(((1.5 if x < 2 else 2.5) - x,.03-y,.70))}")
        if number != 3:
            s.node("Corpse%d" % number, "Marker3D", properties=f"position = {vec((x,y,-3))}\nmetadata/bed_number = {number}")
    entries = {"PhucBooks":(.20,1.98,-1.84), "PhucPoster":(.15,2.26,-2.82), "VietLaptop":(.3,1.03,-1.82), "VietPhoto":(.20,1.05,-2.22), "TrungChargingCable":(1.66,.80,-4.51), "DatNote":(1.27,.80,-4.53), "Router":(3.66,2.22,-.55), "WallKnock406":(.12,1.3,-1.65), "WallKnock408":(3.88,1.3,-1.65)}
    for name, pos in entries.items():
        s.node(name,"Marker3D", properties=f"position = {vec(pos)}")
    s.node("DatLocker", "Marker3D", properties="position = Vector3(3.41, 1.24, -0.45)\nrotation_degrees = Vector3(0, -90, 0)\nscript = " + s.resource("res://scenes/levels/room407/dat_locker.gd", "Script"))
    mat(s, "ink")
    mat(s, "paper")
    box(s, "CombinationLock", (0, 0, 0), (.11, .075, .035), "ink", "DatLocker")
    for i in range(3):
        box(s, "Wheel%d" % i, ((i-1)*.03,0,.022), (.018,.052,.01), "paper", "DatLocker")
    s.node("Shackle", parent="DatLocker")
    box(s, "Top", (0,.07,0), (.09,.01,.012), "paper", "DatLocker/Shackle")
    for x in (-.04,.04):
        box(s,"Leg%s" % x,(x,.05,0),(.01,.04,.012),"paper","DatLocker/Shackle")
    s.save("room407_anchors.tscn")


def append_once(path, marker, resources, nodes):
    content = path.read_text(encoding="utf-8")
    if marker in content:
        return
    index = content.index("[sub_resource")
    content = content[:index] + resources + "\n" + content[index:] + "\n" + nodes + "\n"
    path.write_text(content, encoding="utf-8", newline="\n")


def patch_room():
    path = ROOT / "game/scenes/levels/floor4/room_407.tscn"
    append_once(path, 'id="t153_details"',
        '[ext_resource type="PackedScene" path="res://scenes/levels/room407/room407_details.tscn" id="t153_details"]\n'
        '[ext_resource type="PackedScene" path="res://scenes/levels/room407/room407_anchors.tscn" id="t153_anchors"]\n'
        '[ext_resource type="PackedScene" path="res://assets/models/room407/bunk_trung.glb" id="t153_bunk"]\n'
        '[ext_resource type="Script" path="res://scenes/levels/room407/room407.gd" id="t153_room"]\n'
        '[ext_resource type="Script" path="res://scenes/levels/room407/flicker_light.gd" id="t153_flicker"]\n',
        '[node name="Details" parent="." instance=ExtResource("t153_details")]\n\n'
        '[node name="Anchors" parent="." instance=ExtResource("t153_anchors")]\n\n'
        '[node name="WindowBlue" type="OmniLight3D" parent="."]\nposition = Vector3(2, 2.1, -4.5)\nlight_color = Color(0.29,0.46,0.78,1)\nlight_energy = 0.7\nomni_range = 4.5\nshadow_enabled = true\n\n'
        '[node name="DoorGapLight" type="OmniLight3D" parent="."]\nposition = Vector3(2,0.10,-0.18)\nlight_color = Color(0.75,0.69,0.40,1)\nlight_energy = 0.22\nomni_range = 1.5\n')
    content = path.read_text(encoding="utf-8")
    content = content.replace('[node name="Room407" type="Node3D"]\n', '[node name="Room407" type="Node3D"]\nscript = ExtResource("t153_room")\n') if 'script = ExtResource("t153_room")' not in content else content
    content = content.replace('[node name="BunkB" parent="." instance=ExtResource("e1")]', '[node name="BunkB" parent="." instance=ExtResource("t153_bunk")]')
    for name in ("Room407MainLight", "Room407DeskLamp"):
        header = f'[node name="{name}" type="OmniLight3D" parent="."]'
        if header + '\nscript' not in content:
            content = content.replace(header, header + '\nscript = ExtResource("t153_flicker")')
    # Keep the Light node visible for legacy switches; zero energy is the 4 AM off state.
    start = content.index('[node name="Room407MainLight"')
    end = content.index('[node name="Fixture"', start)
    content = content[:start] + content[start:end].replace('light_energy = 1.0','light_energy = 0.0') + content[end:]
    start = content.index('[node name="Room407DeskLamp"')
    end = content.index('[node name="Fixture"', start)
    content = content[:start] + content[start:end].replace('light_color = Color(0.82, 0.90, 0.76, 1)', 'light_color = Color(1.0, 0.73, 0.43, 1)') + content[end:]
    path.write_text(content, encoding="utf-8", newline="\n")


def doorway_and_washroom():
    s = Scene("DoorGap")
    light = s.subresource("StandardMaterial3D", "shading_mode = 0\nalbedo_color = Color(0.23,0.20,0.09,1)")
    shadow = s.subresource("StandardMaterial3D", "shading_mode = 0\nalbedo_color = Color(0.014,0.018,0.019,1)")
    for name, at, size, material, parent in [
        ("LightSlit",(0,.012,-.15),(.86,.30),light,"."),
        ("FootLeft",(-.11,.014,-.15),(.13,.29),shadow,"UnderDoorShadow"),
        ("FootRight",(.11,.014,-.15),(.13,.29),shadow,"UnderDoorShadow")]:
        if name == "FootLeft":
            s.node("UnderDoorShadow", properties="visible = false")
        mesh = s.subresource("QuadMesh", f"size = Vector2{size}\nmaterial = {material}")
        s.node(name,"MeshInstance3D",parent,f"position = {vec(at)}\nrotation_degrees = Vector3(-90,0,0)\nmesh = {mesh}\ncast_shadow = 0")
    s.save("door_gap.tscn")
    floor = ROOT / "game/scenes/levels/floor4/floor4.tscn"
    append_once(floor, 'id="t153_gap"',
        '[ext_resource type="PackedScene" path="res://scenes/levels/room407/door_gap.tscn" id="t153_gap"]\n',
        '[node name="DoorGap" parent="." instance=ExtResource("t153_gap")]\nposition = Vector3(32,0,0)\n\n'
        '[node name="Threshold" type="Area3D" parent="."]\nposition = Vector3(32,1,0.30)\ncollision_layer = 0\ncollision_mask = 2\n\n'
        '[node name="Shape" type="CollisionShape3D" parent="Threshold"]\nshape = SubResource("t153_threshold")\n')
    content = floor.read_text(encoding="utf-8")
    if '[sub_resource type="BoxShape3D" id="t153_threshold"]' not in content:
        content = content.replace('[node name="Floor4"', '[sub_resource type="BoxShape3D" id="t153_threshold"]\nsize = Vector3(0.90,2.0,0.36)\n\n[node name="Floor4"')
        floor.write_text(content, encoding="utf-8", newline="\n")
    s = Scene("WashroomDetails")
    for name in ("ink","paper","moss","wood"):
        mat(s,name)
    for i in range(3):
        box(s,"SoapTray%d" % i,(.47,.895,-.63-i),(.13,.02,.08),"paper")
        box(s,"Soap%d" % i,(.47,.919,-.63-i),(.10,.028,.056),"moss")
    box(s,"TowelRail",(.14,1.40,-3.26),(.045,.022,.32),"ink")
    model(s,"HandTowel","towel",(.17,1.35,-3.25),(0,90,0),props=True,scale=(.7,.7,.7))
    model(s,"CleaningBucket","bucket",(5.5,.01,-.45),props=True)
    box(s,"MopHandle",(5.67,.69,-.42),(.023,1.37,.023),"wood")
    box(s,"MopHead",(5.67,.04,-.42),(.24,.055,.09),"paper")
    s.save("washroom_details.tscn")
    append_once(ROOT / "game/scenes/levels/floor4/washroom.tscn", 'id="t153_washroom"',
        '[ext_resource type="PackedScene" path="res://scenes/levels/room407/washroom_details.tscn" id="t153_washroom"]\n',
        '[node name="Details" parent="." instance=ExtResource("t153_washroom")]\n')
    # Retain legacy paths used by demo code while Chapter 1 pairs live inside.
    path = ROOT / "game/scenes/levels/floor4/corridor.tscn"
    content = path.read_text(encoding="utf-8")
    content = re.sub(r'(\[node name="Slippers_[0-3]"[^\n]+\]\n)(?!visible = false)', r'\1visible = false\n', content)
    path.write_text(content, encoding="utf-8", newline="\n")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    dressing()
    anchors()
    patch_room()
    doorway_and_washroom()
    for filename in ("floor4.tscn", "room_407.tscn", "washroom.tscn"):
        path = ROOT / "game/scenes/levels/floor4" / filename
        path.write_text(path.read_text(encoding="utf-8").rstrip() + "\n", encoding="utf-8", newline="\n")
    print("ROOM407_SCENES_RESULT: dressing, anchors and room wiring generated")
