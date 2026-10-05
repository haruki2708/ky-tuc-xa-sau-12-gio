"""T-165 (Claude làm thay lane B): the security-camera set for chapter 1 v2.
Four student rooms (102, 306, 209, 106), a fake floor-4 corridor and four
living students with six poses. Native Godot meshes like T-154; stdlib only.
Run: python art_source/cctv/build_cctv.py
"""
from pathlib import Path
import sys, math, random, struct, zlib
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'art_source/floor4'))
sys.path.insert(0, str(ROOT / 'art_source/ch1_models'))
import build_floor4 as base
import build_models as models
OUT = ROOT / 'game/scenes/levels/cctv'
TEX = ROOT / 'game/assets/textures/cctv'
V = base.vec
# New cloth colours; skin, hair, pants, blood, paper come from T-154.
CLOTH = {'hoodie': (.30, .31, .33), 'tee_white': (.70, .70, .66),
         'tee_green': (.16, .30, .18), 'tee_yellow': (.62, .52, .12),
         'shorts': (.20, .17, .13), 'screen': (.55, .75, .95)}
STUDENTS = {
    # who: (room, shirt, width, extra)
    'hung': ('102', 'hoodie', .40, 'hood'),
    'kiet': ('306', 'tee_white', .36, 'glasses'),
    'bao': ('209', 'tee_green', .37, 'long_hair'),
    'dang': ('106', 'tee_yellow', .46, 'shorts'),
}
POSES = ['lie_awake', 'sit_up', 'answer', 'phone_lit', 'cower', 'dead']


def texture(name, color):
    rng = random.Random(165 + list(CLOTH).index(name))
    raw = bytearray()
    for y in range(128):
        raw.append(0)
        for x in range(128):
            grain = rng.choice([-.04, 0, 0, .025])
            if name == 'hoodie':
                grain += .05 if (x * 5 + y * 2) % 53 < 3 else 0
            raw.extend(int(max(0, min(1, c + grain)) * 255) for c in color)
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data))
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>2I5B', 128, 128, 8, 2, 0, 0, 0))
    (TEX / (name + '.png')).write_bytes(png + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))


class Model(models.Model):
    def mat(self, name):
        if name not in self.materials:
            folder = 'cctv' if name in CLOTH else 'ch1_models'
            shader = self.resource('res://rendering/ps1_surface.gdshader', 'Shader')
            tex = self.resource(f'res://assets/textures/{folder}/{name}.png', 'Texture2D')
            self.materials[name] = self.subresource('ShaderMaterial', f'shader = {shader}\nshader_parameter/albedo_texture = {tex}\nshader_parameter/roughness = 0.9')
        return self.materials[name]

    def glow(self):
        if 'glow' not in self.materials:
            self.materials['glow'] = self.subresource('StandardMaterial3D',
                'shading_mode = 0\nalbedo_color = Color(0.62, 0.8, 1, 1)\nemission_enabled = true\nemission = Color(0.55, 0.75, 1, 1)\nemission_energy_multiplier = 2.0')
        return self.materials['glow']


def rot(deg):
    return (math.radians(deg), 0, 0)


def student(who):
    room, shirt, width, extra = STUDENTS[who]
    s = Model('Student' + who.title())
    s.nodes[0] += 'script = ' + s.resource('res://scenes/levels/cctv/student_body.gd', 'Script') + '\n'
    # Same lying rig as T-154's corpses: origin on the mattress, head to +Z.
    rig = s.joint('Rig', (0, .145, -.82), rotation=(90, 0, 0))
    hips = s.joint('Hips', (0, .85, 0), rig)
    chest = s.joint('Chest', (0, 0, 0), hips)
    s.part('Shirt', (0, .265, 0), (width, .50, width * .81), shirt, chest, 'cone', 'scale = Vector3(1,1,0.65)')
    s.part('Hem', (0, .03, 0), (width * .9, .12, .24), shirt, chest)
    s.part('Neck', (0, .56, 0), (.115, .14, .11), 'skin', chest, 'cone')
    head = s.joint('Head', (0, .63, 0), chest)
    s.part('Face', (0, .08, 0), (.225, .28, .20), 'skin', head, 'cone', 'scale = Vector3(1,1,0.90)')
    s.part('Hair', (0, .19, .025), (.235, .13, .195), 'hair', head)
    s.part('Nose', (0, .067, -.10), (.046, .065, .049), 'skin', head, 'wedge')
    s.part('Mouth', (0, .006, -.094), (.084, .012, .012), 'hair', head)
    for side in [-1, 1]:
        s.part('Ear' + str(side), (side * .113, .075, 0), (.035, .07, .048), 'skin', head)
    eyes = s.joint('Eyes', (0, 0, 0), head)
    for side in [-1, 1]:
        s.part('Eye' + str(side), (side * .052, .092, -.093), (.041, .024, .012), 'paper', eyes)
        s.part('Pupil' + str(side), (side * .052, .092, -.101), (.017, .026, .005), 'hair', eyes)
        s.part('Lid' + str(side), (side * .052, .09, -.102), (.056, .007, .006), 'hair', head)
    # Distinct silhouettes (card: shape, shirt, hair).
    if extra == 'hood':
        s.part('Hood', (0, .50, .10), (width * .75, .16, .14), shirt, chest)
    if extra == 'glasses':
        s.part('Glasses', (0, .094, -.108), (.17, .035, .012), 'hair', head)
    if extra == 'long_hair':
        s.part('HairBack', (0, .03, .09), (.24, .26, .06), 'hair', head)
    arms, legs, elbows, knees = [], [], [], []
    for side, label in [(-1, 'Left'), (1, 'Right')]:
        arm = s.joint(label + 'Arm', (side * (width / 2 + .035), .45, 0), chest)
        s.part('Sleeve', (0, -.14, 0), (.16, .28, .12), shirt, arm, 'cone')
        elbow = s.joint('Elbow', (0, -.28, 0), arm)
        s.part('Forearm', (0, -.135, 0), (.115, .27, .085), 'skin', elbow, 'cone')
        hand = s.joint('Hand', (0, -.30, 0), elbow)
        s.part('Fingers', (0, -.035, -.01), (.086, .11, .077), 'skin', hand)
        leg = s.joint(label + 'Leg', (side * .105, 0, 0), hips)
        s.part('Trouser', (0, -.23, 0), (.21, .46, .16), 'shorts' if extra == 'shorts' else 'pants', leg, 'cone')
        knee = s.joint('Knee', (0, -.46, 0), leg)
        s.part('Shin', (0, -.155, 0), (.15, .31, .13), 'skin' if extra == 'shorts' else 'pants', knee, 'cone')
        s.part('Foot', (0, -.302, -.055), (.17, .15, .29), 'skin', knee)
        arms.append(arm); legs.append(leg); elbows.append(elbow); knees.append(knee)
    # Phone in the right hand; its screen glows (Kiệt's beat, D-041).
    phone = s.joint('Phone', (0, -.09, -.05), arms[1] + '/Elbow/Hand')
    s.part('Body', (0, 0, 0), (.075, .15, .012), 'hair', phone)
    screen = s.subresource('BoxMesh', f'size = {V((.066, .135, .004))}\nmaterial = {s.glow()}')
    s.node('Screen', 'MeshInstance3D', phone, f'position = {V((0, 0, -.008))}\nmesh = {screen}')
    s.node('ScreenLight', 'OmniLight3D', phone, 'position = Vector3(0, 0, -0.12)\nlight_color = Color(0.6, 0.78, 1, 1)\nlight_energy = 0.9\nomni_range = 1.4\nshadow_enabled = false')
    blood = s.joint('Blood', (0, 0, 0), chest)
    s.part('Stain', (0, .31, -.141), (.16, .14, .006), 'blood', blood, 'wedge')
    s.part('Neckcut', (0, .53, -.07), (.13, .03, .012), 'blood', blood)
    for i, node in enumerate(s.nodes):
        if node.startswith('[node name="Eyes"') or node.startswith('[node name="Blood"') or node.startswith('[node name="Phone"'):
            s.nodes[i] += 'visible = false\n'
    defaults = {rig + ':position': (0, .145, -.82), chest + ':rotation': (0, 0, 0), head + ':rotation': (0, 0, 0),
                eyes + ':visible': False, blood + ':visible': False, phone + ':visible': False}
    for joint in arms + legs + elbows + knees:
        defaults[joint + ':rotation'] = (0, 0, 0)
    awake = {eyes + ':visible': [(0, True)]}
    clips = {
        'RESET': (.01, False, {}),
        'lie_awake': (.01, False, {**awake, head + ':rotation': [(0, (0, .35, 0))]}),
        'sit_up': (.01, False, {**awake, chest + ':rotation': [(0, rot(-75))]}),
        # "Dạ có": one hand up to the ceiling from the bed.
        'answer': (.01, False, {**awake, arms[1] + ':rotation': [(0, rot(90))], elbows[1] + ':rotation': [(0, rot(-15))]}),
        'phone_lit': (.01, False, {**awake, phone + ':visible': [(0, True)],
                                   arms[1] + ':rotation': [(0, rot(115))], elbows[1] + ':rotation': [(0, rot(-75))],
                                   arms[0] + ':rotation': [(0, rot(100))], elbows[0] + ':rotation': [(0, rot(-70))]}),
        # Curled up against the wall, knees up, arms round them, head down.
        'cower': (.01, False, {**awake, chest + ':rotation': [(0, rot(-80))], head + ':rotation': [(0, rot(-25))],
                               legs[0] + ':rotation': [(0, rot(85))], legs[1] + ':rotation': [(0, rot(85))],
                               knees[0] + ':rotation': [(0, rot(-150))], knees[1] + ':rotation': [(0, rot(-150))],
                               arms[0] + ':rotation': [(0, rot(70))], arms[1] + ':rotation': [(0, rot(70))],
                               elbows[0] + ':rotation': [(0, (0, 0, -1.2))], elbows[1] + ':rotation': [(0, (0, 0, 1.2))]}),
        'dead': (.01, False, {blood + ':visible': [(0, True)], head + ':rotation': [(0, (0, -.9, 0))],
                              arms[1] + ':rotation': [(0, (-1.10, 0, .65))]}),
    }
    s.animations(clips, defaults, 'lie_awake')
    s.save('student_' + who + '.tscn')


# --- The set --------------------------------------------------------------------

def look(eye, target):
    dx, dy, dz = (t - e for t, e in zip(target, eye))
    yaw = math.degrees(math.atan2(-dx, -dz))
    pitch = math.degrees(math.atan2(dy, math.hypot(dx, dz)))
    return f'position = {V(eye)}\nrotation_degrees = {V((pitch, yaw, 0))}'


def label(s, name, text, pos, yaw, parent, size=48):
    s.node(name, 'Label3D', parent, f'position = {V(pos)}\nrotation_degrees = {V((0, yaw, 0))}\ntext = "{text}"\n'
           f'font_size = {size}\npixel_size = 0.004\nmodulate = Color(0.85, 0.85, 0.78, 1)\noutline_size = 0\nshaded = true')


def cctv_room(s, number, x):
    # T-172: reused student mesh only; Room310 does not assign a story identity.
    who = 'kiet' if number == '310' else next(w for w, v in STUDENTS.items() if v[0] == number)
    room = s.node('Room' + number, properties=f'position = {V((x, 0, 0))}')
    s.box('Floor', (2, -.1, -2.5), (4, .2, 5), 'tile', parent=room, floor=True)
    # D-044: a stretch of corridor outside every door, with its own camera.
    hall = s.node('Hall', parent=room)
    s.box('Floor', (2, -.1, 1.25), (5.8, .2, 2.3), 'tile', parent=hall, floor=True)
    s.box('OuterWall', (2, 1.5, 2.45), (5.8, 3, .2), parent=hall)
    s.box('Ceiling', (2, 3.075, 1.25), (5.8, .15, 2.3), parent=hall)
    for name, ex in (('EndWest', -.95), ('EndEast', 4.95)):
        s.box(name, (ex, 1.5, 1.25), (.2, 3, 2.5), parent=hall)
    for name, wx in (('RoomWallWest', -.45), ('RoomWallEast', 4.45)):
        s.box(name, (wx, 1.5, 0), (.9, 3, .2), parent=hall)
    s.node('Tube', 'OmniLight3D', hall, 'position = Vector3(2.8, 2.8, 1.25)\nlight_color = Color(0.82, 0.9, 0.76, 1)\nlight_energy = 0.6\nomni_range = 5.0\nshadow_enabled = false')
    s.node('Start', 'Marker3D', hall, 'position = Vector3(4.45, 0.05, 1.3)')
    s.node('Cam', 'Camera3D', hall, look((-.7, 2.65, 2.2), (3.0, .9, .5)) + '\nfov = 70.0\nfar = 30.0')
    for name, wx in (('WestWall', 0), ('EastWall', 4)):
        s.box(name, (wx, 1.5, -2.5), (.2, 3, 5), parent=room)
    s.box('BackWall', (2, 1.5, -5), (4, 3, .2), parent=room)
    s.box('FrontWallLeft', (1.0, 1.5, 0), (2.0, 3, .2), parent=room)
    s.box('FrontWallRight', (3.45, 1.5, 0), (1.1, 3, .2), parent=room)
    s.box('DoorLintel', (2.45, 2.6, 0), (.9, .8, .2), parent=room)
    s.box('Ceiling', (2, 3.075, -2.5), (4, .15, 5), parent=room)
    for label_, bx in (('A', .65), ('B', 3.35)):
        bed = s.kit('Bunk' + label_, 'bunk_bed', (bx, 0, -3), parent=room)
        for tier in ('Lower', 'Upper'):
            if number == '310':
                continue  # Clear camera view of all four occupants in round 3.
            upper = tier == 'Upper'
            victim_bed = (label_ == 'A' and upper) or number == '310'
            s.kit('Net' + tier, 'mosquito_net_open' if victim_bed else 'mosquito_net_closed',
                  (0, .8800379 if upper else 0, 0), parent=bed, scale=(1, .7348485 if upper else 1, 1))
    for i, (lx, lz, yaw) in enumerate(((.3, -.45, -90), (.3, -1.25, -90), (3.7, -.45, 90), (3.7, -1.25, 90))):
        s.kit(f'Locker{i + 1}', 'locker', (lx, 0, lz), yaw, parent=room)
    s.prop('Desk', 'desk', (1.8, 0, -4.55), 180, parent=room, scale=(1, .95, 1))
    s.kit('Stool', 'plastic_stool', (2.95, 0, -4.5), parent=room)
    s.kit('CeilingFan', 'ceiling_fan', (2, 2.28, -2.5), parent=room)
    # Night: a dim blue cast so the grey camera picture still reads.
    s.node('NightLight', 'OmniLight3D', room, 'position = Vector3(1.5, 2.5, -2.6)\nlight_color = Color(0.62, 0.7, 0.9, 1)\nlight_energy = 1.1\nomni_range = 7.0\nshadow_enabled = false')
    # Per-room dressing (card: different objects in every room).
    if number == '102':
        s.prop('Shirt', 'shirt', (3.35, 1.25, -2.2), 0, parent=room)
        s.prop('Slippers', 'slippers_pair', (1.4, 0, -3.4), 30, parent=room)
        s.box('Poster', (3.89, 1.7, -3.6), (.02, .6, .45), 'blue', parent=room, solid=False)
    elif number == '306':
        s.prop('Towel', 'towel', (3.6, 1.6, -4.85), 0, parent=room)
        s.prop('Bucket', 'bucket', (3.4, 0, -4.4), 0, parent=room)
        s.prop('DeskItems', 'desk_items', (1.8, .76, -4.5), 180, parent=room)
    elif number == '209':
        for i in range(4):
            s.box(f'Book{i}', (1.3 + i * .09, .76 + .04, -4.55), (.07, .08 + (i % 2) * .04, .22), 'paper' if i % 2 else 'cloth', parent=room, solid=False)
        s.box('Laundry', (3.3, .45, -1.6), (.5, .12, .35), 'cloth', parent=room, solid=False)
    elif number == '106':
        # Đăng sits up under the only lit lamp (card).
        s.node('DeskLamp', 'OmniLight3D', room, 'position = Vector3(1.3, 1.02, -4.4)\nlight_color = Color(1, 0.86, 0.6, 1)\nlight_energy = 0.9\nomni_range = 3.2\nshadow_enabled = false')
        s.prop('Fixture', 'desk_lamp', (0, 0, 0), 180, parent=room + '/DeskLamp')
        s.prop('DeskItems', 'desk_items', (2.1, .76, -4.5), 180, parent=room)
    label(s, 'NumberInside', number, (2.45, 2.42, -.11), 180, room)
    label(s, 'NumberOutside', number, (2.45, 2.42, .11), 0, room)
    # Anchors for core (T-160): manager comes in at Door, stops at ManagerSpot.
    s.node('Door', 'Marker3D', room, 'position = Vector3(2.45, 0.05, 1.2)')
    s.node('ManagerSpot', 'Marker3D', room, 'position = Vector3(1.55, 0.05, -2.35)\nrotation_degrees = Vector3(0, -60, 0)')
    s.node('VictimBed', 'Marker3D', room, 'position = Vector3(0.65, 1.2, -3)')
    s.node('Victim', parent=room, instance=s.resource(f'res://scenes/levels/cctv/student_{who}.tscn'),
           properties='position = Vector3(0.65, 1.2, -3)')
    if number == '310':
        for index, model, position in [(1,'phuc',(.65,.43,-3)), (2,'viet',(3.35,.43,-3)), (4,'dat',(3.35,1.2,-3))]:
            s.node('Corpse'+str(index), parent=room,
                   instance=s.resource(f'res://scenes/levels/ch1_models/corpse_{model}.tscn'),
                   properties=f'position = {V(position)}\ninitial_state = &"sit_play"\nseat_side = {1.0 if index == 1 else -1.0}')
    view = look((2,2.6,-.35), (2,.95,-3)) if number == '310' else look((3.72, 2.78, -4.72), (1.45, .95, -1.7))
    s.node('Cam', 'Camera3D', room, view + '\nfov = 66.0\nfar = 30.0')


def corridor(s, x):
    path = s.node('Corridor', properties=f'position = {V((x, 0, 0))}')
    s.box('Floor', (5, -.1, 1.0), (10, .2, 2.4), 'tile', parent=path, floor=True)
    s.box('RoomWall', (5, 1.5, -.1), (10, 3, .2), parent=path)
    s.box('OuterWall', (5, 1.5, 2.3), (10, 3, .2), parent=path)
    s.box('Ceiling', (5, 3.075, 1.0), (10, .15, 2.4), parent=path)
    for name, ex in (('EndWest', -.1), ('EndEast', 10.1)):
        s.box(name, (ex, 1.5, 1.0), (.2, 3, 2.6), parent=path)
    for i, number in enumerate(('405', '406', '407')):
        dx = 1.5 + i * 3.2
        s.kit('Door' + number, 'door', (dx, .01, 0), 0, parent=path)
        label(s, 'Number' + number, number, (dx + .44, 2.3, .02), 0, path, 40)
    s.node('Tube', 'OmniLight3D', path, 'position = Vector3(5, 2.8, 1.0)\nlight_color = Color(0.82, 0.9, 0.76, 1)\nlight_energy = 0.55\nomni_range = 7.0\nshadow_enabled = false')
    s.node('Cam', 'Camera3D', path, look((.3, 2.75, 2.0), (8.0, .9, .2)) + '\nfov = 75.0\nfar = 30.0')


def cctv_set():
    s = Model('CctvSet')
    # Far below the building (card: Y = -60), out of every gameplay view.
    s.nodes[0] += 'position = Vector3(0, -60, 0)\n'
    for i, number in enumerate(('102', '306', '209', '106')):
        cctv_room(s, number, i * 6.0)
    corridor(s, 26.0)
    cctv_room(s, '310', 40.0)
    s.save('cctv_set.tscn')


def material_compat():
    # build_floor4's box() uses its own StandardMaterial palette.
    for key in ('cloth', 'blue', 'paper', 'tile', 'wall'):
        assert key in base.PALETTE, key


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True); TEX.mkdir(parents=True, exist_ok=True)
    base.OUT = OUT
    material_compat()
    for name, color in CLOTH.items():
        texture(name, color)
    for who in STUDENTS:
        student(who)
    cctv_set()
    print('CCTV_BUILD: 4 students, cctv_set (5 rooms + corridor), %d textures' % len(CLOTH))
