"""Generate editable greybox scenes from the approved LAYOUT.md (D-020)."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "game/scenes/levels/floor4"
PALETTE = {
    "wall": (0.47, 0.49, 0.40), "tile": (0.34, 0.38, 0.36),
    "wet_tile": (0.28, 0.35, 0.35), "iron": (0.10, 0.15, 0.15),
    "wood": (0.25, 0.15, 0.085), "paper": (0.73, 0.71, 0.56),
    "cloth": (0.29, 0.37, 0.42), "skin": (0.13, 0.09, 0.07),
    "white": (0.74, 0.79, 0.72), "blue": (0.12, 0.25, 0.33),
    "tree": (0.035, 0.065, 0.045), "glass": (0.18, 0.27, 0.28),
}


def vec(values):
    return "Vector3(" + ", ".join(str(round(v, 7)) for v in values) + ")"


class Scene:
    def __init__(self, name):
        self.name, self.ext, self.sub, self.nodes = name, {}, [], []
        self.materials = {}
        self.node(name, "Node3D", None)

    def resource(self, path, kind="PackedScene"):
        key = (path, kind)
        if key not in self.ext:
            self.ext[key] = f"e{len(self.ext) + 1}"
        return f'ExtResource("{self.ext[key]}")'

    def subresource(self, kind, properties):
        name = f"s{len(self.sub) + 1}"
        self.sub.append(f'[sub_resource type="{kind}" id="{name}"]\n{properties}\n')
        return f'SubResource("{name}")'

    def material(self, name):
        if name not in self.materials:
            color = PALETTE[name]
            extra = "\nmetallic = 0.65" if name == "glass" else ""
            self.materials[name] = self.subresource("StandardMaterial3D",
                "albedo_color = Color(%s, 1)\nroughness = %s\ntexture_filter = 0%s" %
                (", ".join(map(str, color)), 0.18 if name in ("wet_tile", "glass") else 0.85, extra))
        return self.materials[name]

    def node(self, name, kind="Node3D", parent=".", properties="", instance=None, paths=None):
        header = f'[node name="{name}"'
        if instance is None:
            header += f' type="{kind}"'
        if parent is not None:
            header += f' parent="{parent}"'
        if instance is not None:
            header += f' instance={instance}'
        if paths:
            header += ' node_paths=PackedStringArray(' + ", ".join(json.dumps(p) for p in paths) + ')'
        self.nodes.append(header + "]\n" + properties + "\n")
        return name if parent == "." else f"{parent}/{name}"

    def box(self, name, pos, size, material="wall", parent=".", solid=True, floor=False, visible=True):
        props = "position = " + vec(pos)
        if floor:
            props += '\nmetadata/surface = &"tile"\nmetadata/is_floor = true'
        path = self.node(name, "StaticBody3D" if solid else "Node3D", parent, props)
        if solid:
            self.nodes[-1] += "collision_layer = 1\ncollision_mask = 0\n"
            shape = self.subresource("BoxShape3D", "size = " + vec(size))
            self.node("Collision", "CollisionShape3D", path, "shape = " + shape)
        if visible:
            mesh = self.subresource("BoxMesh", "size = " + vec(size) + "\nmaterial = " + self.material(material))
            self.node("Mesh", "MeshInstance3D", path, "mesh = " + mesh)
        return path

    def kit(self, name, model, pos=(0, 0, 0), yaw=0, parent=".", scale=(1, 1, 1)):
        resource = self.resource(f"res://assets/models/kit/{model}.glb")
        return self.node(name, parent=parent, instance=resource,
            properties=f"position = {vec(pos)}\nrotation_degrees = {vec((0, yaw, 0))}\nscale = {vec(scale)}")

    def lamp(self, name, pos, tube=True, energy=1.0, radius=4.0):
        self.node(name, "OmniLight3D", properties=f"position = {vec(pos)}\nlight_energy = {energy}\n"
                  f"light_color = Color(0.82, 0.90, 0.76, 1)\nomni_range = {radius}\nshadow_enabled = false")
        self.box("Fixture", (0, 0.08, 0), (1.15, 0.08, 0.13) if tube else (0.22, 0.1, 0.2),
                 "white", parent=name, solid=False)
        if not tube:
            self.box("Stem", (0, -.10, 0), (.035, .3, .035), "iron", parent=name, solid=False)
            self.box("Base", (0, -.245, 0), (.18, .035, .16), "iron", parent=name, solid=False)
        if tube:
            script = self.resource("res://scripts/audio/light_hum.gd", "Script")
            self.node("LightHum", "AudioStreamPlayer3D", name,
                f'script = {script}\nlight = NodePath("..")\nbus = &"Ambience"\n'
                'unit_size = 2.0\nmax_distance = 6.0\nvolume_db = -10.0\npitch_variation = 0.0\nvolume_variation_db = 0.0', paths=["light"])

    def emitter(self, name, pos, stream, volume=-8, random=False):
        script = self.resource("res://scripts/audio/ambient_emitter.gd", "Script")
        audio = self.resource("res://audio/" + stream, "AudioStream")
        return self.node(name, "AudioStreamPlayer3D", properties=f"position = {vec(pos)}\nscript = {script}\n"
            f'stream = {audio}\nbus = &"Ambience"\nvolume_db = {volume}\nunit_size = 4.0\nmax_distance = 22.0\n'
            + ("playback_mode = 1\ninterval_min = 2.0\ninterval_max = 6.0" if random else ""))

    def zones(self, pos, size, preset, emitters):
        shape = self.subresource("BoxShape3D", "size = " + vec(size))
        for name, script_name in (("ReverbZone", "reverb_zone"), ("AmbientZone", "ambient_zone")):
            script = self.resource(f"res://scripts/audio/{script_name}.gd", "Script")
            props = f"position = {vec(pos)}\nscript = {script}\ncollision_layer = 0\ncollision_mask = 2\n"
            props += f"preset = {preset}\nmix_priority = {2 if preset == 2 else 1}" if name == "ReverbZone" else (
                'emitters = Array[NodePath]([' + ", ".join(f'NodePath("../{e}")' for e in emitters) + "])" )
            self.node(name, "Area3D", properties=props)
            self.node("Shape", "CollisionShape3D", name, "shape = " + shape)

    def save(self, filename, connections=""):
        lines = ['[gd_scene format=3]\n']
        lines += [f'[ext_resource type="{kind}" path="{path}" id="{id}"]' for (path, kind), id in self.ext.items()]
        lines += [""] + self.sub + self.nodes + [connections]
        (OUT / filename).write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8", newline="\n")


def corridor():
    s = Scene("Corridor")
    s.box("Floor", (22, -.1, 1.2), (44, .2, 2.4), "tile", floor=True)
    s.box("Roof", (22, 3.075, 1.2), (44, .15, 2.4))
    s.box("WestEnd", (-.1, 1.5, 1.2), (.2, 3, 2.4))
    s.box("EastEnd", (44.1, 1.5, 1.2), (.2, 3, 2.4))
    s.box("RailingBarrier", (22, 1, 2.45), (44, 2, .1), visible=False)
    s.box("RailingTop", (22, 1.07, 2.39), (44, .06, .06), "iron")
    s.box("RailingLow", (22, .18, 2.39), (44, .06, .06), "iron")
    for i in range(89):
        s.box(f"RailBar_{i:02}", (i * .5, .62, 2.39), (.035, .95, .035), "iron", solid=False)
    emitters = []
    for i in range(8):
        number, x = 401 + i, 8 + i * 4
        s.kit(f"Doorway_{number}", "wall_door", (x, 0, 0))
        for side in (-1, 1):
            s.kit(f"Facade_{number}_{'W' if side < 0 else 'E'}", "wall_straight", (x + side * 1.5, 0, 0), scale=(.5, 1, 1))
        if number != 407:
            s.kit(f"LockedDoor_{number}", "door", (x + .44, .01, 0))
            s.box(f"Floor_{number}", (x, -.1, -2.5), (4, .2, 5), "tile", floor=True)
            s.box(f"BackWall_{number}", (x, 1.5, -5), (4, 3, .2))
            s.box(f"Ceiling_{number}", (x, 3.075, -2.5), (4, .15, 5))
        plaque = s.box(f"RoomPlate_{number}", (x, 2.42, .13), (.40, .20, .035), "blue", solid=False)
        s.nodes[-1] += f"metadata/room_number = {number}\n"
        s.lamp(f"CorridorLight_{number}", (x, 2.80, 1.2), radius=4.7)
        emitters.append(f"CorridorLight_{number}/LightHum")
    for x in (6, 10, 14, 18, 22, 26, 38):
        s.box(f"RoomPartition_{x}", (x, 1.5, -2.5), (.2, 3, 5))
    s.lamp("CorridorLight_Desk", (40, 2.80, 1.2), radius=4.7)
    emitters.append("CorridorLight_Desk/LightHum")
    s.box("Clothesline", (24, 2.15, 2.27), (16, .018, .018), "iron", solid=False)
    for i, x in enumerate((17, 20, 23, 27, 30)):
        s.box(f"HangingCloth_{i}", (x, 1.76, 2.27), (.48, .72, .025), "cloth", solid=False)
    for i in range(4):
        for side in (-1, 1):
            s.box(f"Slippers_{i}_{side}", (30.5 + i * .35 + side * .065, .025, .35), (.10, .05, .25), "blue", solid=False)
    for x in (11, 19, 35):
        s.box(f"Bucket_{x}", (x, .18, .35), (.3, .36, .3), "blue")
    s.emitter("YardInsects", (23, -1, 9), "ambience/night_insects_motorbike.ogg", -5)
    emitters.append("YardInsects")
    s.zones((22, 1.5, 1.2), (44, 3, 2.4), 1, emitters)
    for i, x in enumerate((5, 18, 31, 43)):
        s.box(f"YardTree_{i}", (x, -3.0, 12 + i % 2 * 3), (5, 5, 4), "tree", solid=False)
    s.lamp("DistantStreetLamp", (15, -1, 19), tube=False, energy=.5, radius=7)
    s.save("corridor.tscn")


def room():
    s = Scene("Room407")
    s.box("Floor", (2, -.1, -2.5), (4, .2, 5), "tile", floor=True)
    for name, x in (("WestWall", 0), ("EastWall", 4)):
        s.box(name, (x, 1.5, -2.5), (.2, 3, 5))
    s.box("Ceiling", (2, 3.075, -2.5), (4, .15, 5))
    for x in (.5, 3.5):
        s.box(f"WindowPier_{x}", (x, 1.5, -5), (1, 3, .2))
    s.box("WindowSill", (2, .5, -5), (2, 1, .2))
    s.box("WindowLintel", (2, 2.7, -5), (2, .6, .2))
    s.box("WindowBarrier", (2, 1.7, -5), (2, 1.4, .1), visible=False)
    for i in range(9):
        s.box(f"WindowBar_{i}", (1 + i * .25, 1.7, -5), (.025, 1.4, .03), "iron", solid=False)
    for label, x in (("A", .65), ("B", 3.35)):
        bed = s.kit(f"Bunk{label}", "bunk_bed", (x, 0, -3))
        for tier, person in (("Lower", "Viet" if label == "A" else "Trung"), ("Upper", "Phuc" if label == "A" else "Dat")):
            upper = tier == "Upper"
            s.kit(f"Net_{person}", "mosquito_net_open" if person == "Trung" else "mosquito_net_closed",
                  (0, .8800379 if upper else 0, 0), parent=bed,
                  scale=(1, .7348485 if upper else 1, 1))
            if person != "Trung":
                mesh = s.subresource("CapsuleMesh", f"radius = 0.16\nheight = 1.55\nmaterial = {s.material('skin')}")
                s.node(f"Sleeper_{person}", "MeshInstance3D", bed,
                    f"position = {vec((0, 1.38 if upper else .61, 0))}\nrotation_degrees = Vector3(90, 0, 0)\nmesh = {mesh}")
    for person, x, z, yaw in (("Phuc", .3, -.45, -90), ("Viet", .3, -1.25, -90),
                               ("Dat", 3.7, -.45, 90), ("Trung", 3.7, -1.25, 90)):
        s.kit(f"Locker_{person}", "locker", (x, 0, z), yaw)
    s.box("StudyDesk", (1.8, .38, -4.55), (1.5, .76, .65), "wood")
    s.kit("StudyStool", "plastic_stool", (2.95, 0, -4.5))
    s.kit("CeilingFan", "ceiling_fan", (2, 2.28, -2.5))
    s.box("LightSwitch", (2.72, 1.35, -.12), (.10, .16, .04), "white", solid=False)
    s.box("Phone", (3.35, .445, -2.45), (.075, .022, .15), "iron", solid=False)
    s.lamp("Room407MainLight", (2, 2.78, -1.2), radius=4)
    s.lamp("Room407DeskLamp", (1.8, 1.02, -4.6), tube=False, energy=.5, radius=2.4)
    s.emitter("FanAmbience", (2, 2.4, -2.5), "ambience/ceiling_fan.ogg", -12)
    s.zones((2, 1.5, -2.5), (3.8, 3, 4.9), 0, ["Room407MainLight/LightHum", "FanAmbience"])
    s.save("room_407.tscn")


def washroom():
    s = Scene("Washroom")
    s.box("Floor", (3, -.1, -2.5), (6, .2, 5), "wet_tile", floor=True)
    s.box("WestWall", (0, 1.5, -2.5), (.2, 3, 5))
    s.box("BackWall", (3, 1.5, -5), (6, 3, .2))
    s.box("EastWall", (6, 1.5, -2.5), (.2, 3, 5))
    s.box("Ceiling", (3, 3.075, -2.5), (6, .15, 5))
    # 1.2 m opening centered at X=3, deliberately wider than the room doors.
    s.box("EntranceWest", (1.2, 1.5, 0), (2.4, 3, .2))
    s.box("EntranceEast", (4.8, 1.5, 0), (2.4, 3, .2))
    s.box("EntranceLintel", (3, 2.65, 0), (1.2, .7, .2))
    for i, x in enumerate((1, 3, 5)):
        s.box(f"StallDoor_{i}", (x, 1.1, -3.55), (1.94, 2.2, .08), "blue")
        s.box(f"StallPartition_{i}", (i * 2, 1.25, -4.25), (.08, 2.5, 1.5))
    for i, z in enumerate((-.85, -1.85, -2.85)):
        s.box(f"Sink_{i}", (.42, .43, z), (.65, .86, .72), "white")
        s.box(f"Tap_{i}", (.35, 1.03, z), (.09, .25, .05), "iron", solid=False)
    s.box("Mirror", (.125, 1.62, -1.85), (.03, .95, 2.8), "glass", solid=False)
    s.box("Notice", (.125, 1.55, -3.25), (.035, .42, .28), "paper", solid=False)
    s.lamp("WashroomLight", (3, 2.8, -2), energy=1.2, radius=5)
    s.emitter("WaterDrips", (.35, .9, -2.85), "sfx/water_drip_01.ogg", -8, random=True)
    s.zones((3, 1.5, -2.5), (5.8, 3, 4.9), 2, ["WashroomLight/LightHum", "WaterDrips"])
    s.save("washroom.tscn")


def duty_desk():
    s = Scene("DutyDesk")
    s.box("NorthWall", (1.35, 1.5, 0), (2.7, 3, .2))
    s.box("GateWestPier", (3.0, 1.5, 0), (.6, 3, .2))
    s.box("GateEastPier", (5.3, 1.5, 0), (1.4, 3, .2))
    s.box("GateLintel", (3.95, 2.8, 0), (1.3, .4, .2))
    s.box("LockedStairGate", (3.95, 1.3, 0), (1.3, 2.6, .1), "iron", visible=False)
    for i in range(9):
        s.box(f"GateBar_{i}", (3.35 + i * .15, 1.3, 0), (.04, 2.6, .07), "iron", solid=False)
    s.box("Chain", (3.95, 1.3, .10), (1.3, .04, .05), "iron", solid=False)
    s.box("Padlock", (3.95, 1.24, .13), (.11, .15, .06), "iron", solid=False)
    s.box("GateSign", (3.95, 2.0, .10), (.7, .25, .03), "paper", solid=False)
    s.box("StairLanding", (3.95, -.1, -1.2), (2, .2, 2.4), "tile", floor=True)
    s.box("StairBack", (3.95, 1.5, -2.4), (2, 3, .2))
    s.box("Desk", (2, .4, .42), (1.5, .8, .65), "wood")
    s.box("DutyLog", (1.8, .825, .42), (.33, .045, .25), "paper", solid=False)
    s.box("DeskTelephone", (2.4, .88, .42), (.22, .16, .18), "iron", solid=False)
    s.kit("DutyStool", "plastic_stool", (3, 0, .5))
    s.box("HallBoard", (.5, 1.6, .14), (.75, .90, .06), "wood", solid=False)
    s.box("HallBoardPaper", (.5, 1.6, .18), (.67, .82, .015), "paper", solid=False)
    s.box("Speaker", (2, 2.45, .2), (.5, .35, .3), "iron", solid=False)
    s.lamp("DutyDeskLamp", (1.5, 1.06, .42), tube=False, energy=.6, radius=2)
    # Existing electrical crackle is a quiet temporary idle-speaker cue.
    s.emitter("SpeakerIdle", (2, 2.45, .3), "sfx/fluorescent_flicker.ogg", -28, random=True)
    s.zones((3, 1.5, 1.2), (6, 3, 2.4), 1, ["SpeakerIdle"])
    s.save("duty_desk.tscn")


ANCHORS = {
    "seg1_start": ((32, .03, 1.15), 0), "seg2_start": ((32.95, .03, -.75), 0),
    "seg3_start": ((32, .03, -1.2), 180), "seg4_start": ((32.9, .03, -1.25), -90),
    "seg5_start": ((32, .03, 1.15), 90), "Door407": ((32.44, .01, 0), 0),
    "Room407LightSwitch": ((32.72, 1.35, -.16), 180), "RulesPaper407": ((32, 1.40, -.023), 180),
    "Locker_Trung": ((33.7, 0, -1.25), 90), "Phone_Trung": ((33.35, .46, -2.45), 0),
    "Bed_Phuc": ((30.65, 1.20, -3), 0), "Bed_Viet": ((30.65, .43, -3), 0),
    "Bed_Dat": ((33.35, 1.20, -3), 0), "Bed_Trung": ((33.35, .43, -3), 0),
    "Slippers407": ((31.025, .05, .35), 0), "HallBoard": ((38.5, 1.6, .19), 0),
    "HallBoardNote": ((38.7, 1.9, .205), 0), "DutyLog": ((39.8, .85, .42), 0),
    "Speaker": ((40, 2.45, .37), 0), "WashroomTapRunning": ((.35, 1.03, -2.85), 0),
    "WashroomMirror": ((.15, 1.62, -1.85), -90), "WashroomNotice": ((.15, 1.55, -3.25), -90),
    "ClotheslineExtraShirt": ((25.5, 1.76, 2.27), 0), "DarkSection": ((16, 1.5, 1.2), 0),
}


def floor4():
    s = Scene("Floor4")
    s.nodes[0] += "script = " + s.resource("res://scenes/levels/floor4/floor4.gd", "Script") + "\n"
    for name, path, pos in (("Corridor", "corridor", (0, 0, 0)), ("Room407", "room_407", (30, 0, 0)),
                            ("Washroom", "washroom", (0, 0, 0)), ("DutyDesk", "duty_desk", (38, 0, 0))):
        s.node(name, instance=s.resource(f"res://scenes/levels/floor4/{path}.tscn"), properties="position = " + vec(pos))
    door_script = s.resource("res://scenes/levels/floor4/door407.gd", "Script")
    s.node("Door407", "Area3D", properties=f"position = Vector3(32.44, 0.01, 0)\nscript = {door_script}")
    s.node("Pivot", parent="Door407")
    s.kit("Leaf", "door", parent="Door407/Pivot")
    s.box("RulesPaper", (-.44, 1.39, -.025), (.28, .4, .008), "paper", "Door407/Pivot", solid=False)
    shape = s.subresource("BoxShape3D", "size = Vector3(1.1, 2.2, 0.25)")
    s.node("InteractShape", "CollisionShape3D", "Door407", f"position = Vector3(-0.44, 1.04, 0)\nshape = {shape}")
    s.node("Anchors")
    for name, (pos, yaw) in ANCHORS.items():
        s.node(name, "Marker3D", "Anchors", f"position = {vec(pos)}\nrotation_degrees = {vec((0, yaw, 0))}")
    environment = s.subresource("Environment", "background_mode = 1\nbackground_color = Color(0.012, 0.02, 0.027, 1)\n"
        "ambient_light_source = 2\nambient_light_color = Color(0.30, 0.39, 0.47, 1)\nambient_light_energy = 0.40\n"
        "tonemap_mode = 2\nfog_enabled = true\nfog_light_color = Color(0.06, 0.09, 0.10, 1)\nfog_density = 0.012")
    s.node("Environment", "WorldEnvironment", properties="environment = " + environment)
    s.save("floor4.tscn")
    s = Scene("Floor4Playtest")
    s.node("Floor4", instance=s.resource("res://scenes/levels/floor4/floor4.tscn"))
    s.node("Player", instance=s.resource("res://scenes/player/player.tscn"), properties="position = Vector3(32, 0.03, 1.15)")
    s.node("Footsteps", "AudioStreamPlayer3D", "Player", "script = " + s.resource("res://scripts/audio/footstep_player.gd", "Script"))
    s.node("HUD", instance=s.resource("res://ui/hud/hud.tscn"))
    s.node("PauseMenu", instance=s.resource("res://ui/pause/pause_menu.tscn"))
    s.save("floor4_playtest.tscn", '[connection signal="footstep" from="Player" to="Player/Footsteps" method="play_footstep"]')


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    corridor()
    room()
    washroom()
    duty_desk()
    floor4()
    print("FLOOR4_BUILD: 6 editable scenes generated")
