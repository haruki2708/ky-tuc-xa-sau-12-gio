"""T-190 room geometry/nav helpers and narrow patch of the integrated scenes.
No whole-campus regeneration; T-188 stairs and T-189 canteen stay untouched.
408 moves beyond Room407 v2 with the owner's explicit layout authorization.
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'art_source/floor4'))
import build_floor4 as base

ROOMS = [(n, 8 + (n - 401) * 4, 0) for n in range(401, 407)]
ROOMS += [(408, 42, 0)]
ROOMS += [(f * 100 + i + 1, 2.75 + i * 5.5, (f - 4) * 3.3)
          for f in [3, 2] for i in range(8) if not (f == 2 and i == 2)]
IDLE = [(1 + (i % 3) * 1.6, 0, 1.6 + (i // 3) * 1.1) for i in range(6)]


def room_door(s, name, room, x, y, parent='.', kit=False):
    width = .88 if kit else 1.7
    p = s.node(name, parent=parent, properties=f'position = {base.vec((x, y, 0))}\n'
               f'script = {s.resource("res://scenes/levels/room_door.gd", "Script")}\nroom = &"{room}"')
    s.box('Blocker', (0, 1.2, 0), (width, 2.4, .12), parent=p, visible=False)
    hinge = s.node('Hinge', parent=p, properties='position = ' + base.vec((width / 2, .01, 0)))
    if kit:
        # Preserve the existing wooden leaf; imported colliders are disabled by
        # a visual-only extraction script, so Blocker is the sole door collider.
        leaf = s.kit('Leaf', 'door', parent=hinge)
        s.nodes[-1] += 'script = ' + s.resource('res://scenes/levels/room_door_visual.gd', 'Script') + '\n'
    else:
        s.box('Leaf', (-width / 2, 1.19, 0), (width, 2.4, .10), 'wood', hinge, solid=False)
    return p


def interior(s, name, x, y, parent='.', narrow=False):
    p = s.node(name, parent=parent)
    side = 1.35 if narrow else 1.8
    # Keep the spawn area and the straight door approach empty.
    for height in [.4, 1.45]:
        s.box('Bunk' + str(height), (x - side, y + height, -3.45), (.85, .16, 1.95), 'iron', p)
    for z in [-4.35, -2.55]:
        s.box('Post' + str(z), (x - side, y + .9, z), (.08, 1.8, .08), 'iron', p)
    s.box('Locker', (x + side, y + .85, -3.9), (.7, 1.7, .65), 'wood', p)


def nav_names(room):
    floor, index = room // 100, room % 100 - 1
    if floor in [2, 3] and index in [1, 4, 6]:
        return f'Alcove{floor}_{index}', f'AlcoveLink{floor}_{index}'
    return f'Room{room}', f'Room{room}Link'


def register_navigation(c, rooms=ROOMS):
    for room, x, y in rooms:
        region, link = nav_names(room)
        c.flat(region, x - .65, x + .65, -2.5, -.5, y)
        c.link(link, (x, y, -.6), (x, y, 1.2))
        c.anchor(f'RoomSpawns/B{room // 100}/R{room}', (x, y, -1.5))


def room408(s):
    # Room407 v2 occupies x=30..38. Seal its former 408 entrance, and build
    # the independent room at x=38..44 without changing Room407 itself.
    s.kit('Former408Wall', 'wall_straight', (36, 0, 0), scale=(2, 1, 1))
    s.kit('Doorway_408', 'wall_door', (42, 0, 0))
    s.kit('Facade_408_W', 'wall_straight', (40.5, 0, 0), scale=(.5, 1, 1))
    s.kit('Facade_408_E', 'wall_straight', (43.5, 0, 0), scale=(.5, 1, 1))
    s.kit('Room408FrontWest', 'wall_straight', (39, 0, 0))
    s.box('Floor_408', (41, -.1, -2.5), (6, .2, 5), 'tile', floor=True)
    s.box('Room408BackWall', (41, 1.5, -5), (6, 3, .2))
    s.box('Ceiling_408', (41, 3.075, -2.5), (6, .15, 5))
    s.box('Room408EastWall', (44, 1.5, -2.5), (.2, 3, 5))


def key(block):
    if not block.startswith('[node '):
        return None
    name = re.search(r'name="([^"]+)"', block).group(1)
    parent = re.search(r'parent="([^"]+)"', block.split('\n')[0])
    return name if parent is None or parent.group(1) == '.' else parent.group(1) + '/' + name


class Patch:
    def __init__(self, path):
        self.path = ROOT / path
        self.blocks = re.split(r'(?=^\[)', self.path.read_text(encoding='utf-8'), flags=re.M)
        # All generated nodes/resources carry a private tag for repeatable patches.
        self.blocks = [b for b in self.blocks if 'id="t190_' not in b.split('\n')[0]
                       and 'metadata/t190 = true' not in b]

    def remove(self, path):
        self.blocks = [b for b in self.blocks if not (key(b) == path or (key(b) or '').startswith(path + '/'))]

    def merge(self, scene):
        def refs(text):
            return re.sub(r'(id="|Resource\(")([es]\d+)', r'\1t190_\2', text)
        ext = [f'[ext_resource type="{kind}" path="{path}" id="{ident}"]\n\n'
               for (path, kind), ident in scene.ext.items()]
        insert = next(i for i, b in enumerate(self.blocks) if b.startswith(('[sub_resource ', '[node ')))
        self.blocks[insert:insert] = [refs(b) + '\n' for b in ext]
        insert = next(i for i, b in enumerate(self.blocks) if b.startswith('[node '))
        self.blocks[insert:insert] = [refs(b) + '\n' for b in scene.sub]
        for block in scene.nodes[1:]:
            self.blocks.append(refs(block).rstrip() + '\nmetadata/t190 = true\n\n')

    def save(self):
        self.path.write_text(''.join(self.blocks).rstrip() + '\n', encoding='utf-8', newline='\n')


def patch():
    # Owner explicitly authorized this extra file on 2026-10-07. Only the
    # obsolete stair alcove is replaced; the desk/props/key anchors stay put.
    duty = Patch('game/scenes/levels/floor4/duty_desk.tscn')
    for name in ['NorthWall', 'GateWestPier', 'GateEastPier', 'GateLintel',
                 'LockedStairGate', 'Chain', 'Padlock', 'GateSign',
                 'StairLanding', 'StairBack'] + [f'GateBar_{i}' for i in range(9)]:
        duty.remove(name)
    duty.save()
    for floor4 in [True, False]:
        path = 'floor4/corridor.tscn' if floor4 else 'campus/building_b.tscn'
        target = Patch('game/scenes/levels/' + path)
        s = base.Scene('Patch')
        if floor4:
            for name in ['Doorway_408', 'Facade_408_W', 'Facade_408_E', 'Sealed408']:
                target.remove(name)
            room408(s)
            # T-206: panel back at z=.105 clears Former408Wall's front at z=.10.
            s.node('Sealed408', 'MeshInstance3D', properties='position = Vector3(36,1.02,0.13)\nmesh = SubResource("v2_seal")')
            for i, block in enumerate(target.blocks):
                if key(block) == 'RoomPlate_408':
                    target.blocks[i] = re.sub(r'^position = .*', 'position = Vector3(42, 2.42, 0.13)', block, flags=re.M)
        for room, x, y in ROOMS:
            if (room // 100 == 4) != floor4:
                continue
            name = f'LockedDoor_{room}' if floor4 else f'Door{room % 100 - 1}'
            parent = '.' if floor4 else f'Floor{room // 100}'
            target.remove(name if floor4 else parent + '/' + name)
            room_door(s, name, room, x, y, parent, kit=floor4)
            interior(s, f'RoomInterior_{room}', x, y, parent, narrow=floor4)
        target.merge(s)
        target.save()

    target = Patch('game/scenes/levels/campus/campus.tscn')
    s = base.Scene('Patch')
    nav_script = s.resource('res://scenes/levels/campus_room_navigation.gd', 'Script')
    for i, block in enumerate(target.blocks):
        if key(block) == 'Navigation':
            block = re.sub(r'^script = .*\n', '', block, flags=re.M)
            target.blocks[i] = block.rstrip() + '\nscript = ' + nav_script.replace('"e', '"t190_e') + '\n\n'
    for room, x, y in ROOMS:
        region, link = nav_names(room)
        target.remove('Navigation/' + region)
        target.remove('Navigation/' + link)
        points = [(x - .65, y, -2.5), (x - .65, y, -.5), (x + .65, y, -.5), (x + .65, y, -2.5)]
        mesh = s.subresource('NavigationMesh', 'vertices = PackedVector3Array(' + ','.join(str(round(v, 5)) for p in points for v in p)
                             + ')\npolygons = [PackedInt32Array(0,1,2,3)]\nagent_radius = 0.3\nagent_height = 1.6')
        s.node(region, 'NavigationRegion3D', 'Navigation', 'navigation_mesh = ' + mesh)
        s.node(link, 'NavigationLink3D', 'Navigation', 'start_position = ' + base.vec((x, y, -.6))
               + '\nend_position = ' + base.vec((x, y, 1.2)) + '\nbidirectional = true\nenabled = true')
    s.node('RoomSpawns', parent='Anchors')
    for floor in [4, 3, 2]:
        s.node('B' + str(floor), parent='Anchors/RoomSpawns')
    for room, x, y in ROOMS:
        s.node('R' + str(room), 'Marker3D', f'Anchors/RoomSpawns/B{room // 100}', 'position = ' + base.vec((x, y, -1.5)))
    for i, point in enumerate(IDLE):
        target.remove(f'Anchors/ZombieIdle/B4/I{i + 1:02}')
        s.node(f'I{i + 1:02}', 'Marker3D', 'Anchors/ZombieIdle/B4', 'position = ' + base.vec(point) + '\nrotation_degrees = Vector3(0,-90,0)')
    target.merge(s)
    target.save()
    manifest = {'base_commit': 'bc0e770', 'layout_authorization': 'Owner approved adjusting 407/408 on 2026-10-07; 408 moved to x=38..44, door x=42; Room407 unchanged',
                'rooms': [{'room': str(room), 'door': f'Floor4/Corridor/LockedDoor_{room}' if room // 100 == 4 else f'Campus/BuildingB/Floor{room // 100}/Door{room % 100 - 1}',
                           'anchor': f'Campus/Anchors/RoomSpawns/B{room // 100}/R{room}', 'position': [x, y, -1.5]} for room, x, y in ROOMS],
                'idle_b4': {f'I{i+1:02}': p for i, p in enumerate(IDLE)}}
    (ROOT / 'art_source/campus/room_doors.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    layout_path = ROOT / 'art_source/campus/layout.json'
    layout = json.loads(layout_path.read_text(encoding='utf-8'))
    if not any(name.startswith('RoomSpawns/') for name in layout['anchors']):
        layout['navigation_surfaces'] += len(ROOMS) - 6
        layout['navigation_links'] += len(ROOMS) - 6
    for entry in manifest['rooms']:
        layout['anchors'][entry['anchor'].removeprefix('Campus/Anchors/')] = entry['position']
    for name, point in manifest['idle_b4'].items():
        layout['anchors']['ZombieIdle/B4/' + name] = point
    layout_path.write_text(json.dumps(layout, indent=2) + '\n', encoding='utf-8')
    print(f'T190_PATCH: {len(ROOMS)} doors, room regions/links/spawns; 6 distant idle markers; independent room 408')


if __name__ == '__main__':
    patch()
