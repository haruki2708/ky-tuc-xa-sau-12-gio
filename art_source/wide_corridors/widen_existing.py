"""T-187: narrowly patch current scenes without rebuilding the legacy Room407.
Idempotent. Keeps node names, room geometry, scripts and resource references.
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]


class Scene:
    def __init__(self, path):
        self.path = ROOT / path
        self.blocks = re.split(r'(?=^\[)', self.path.read_text(encoding='utf-8'), flags=re.M)
        self.nodes = {}
        self.resources = {}
        for index, block in enumerate(self.blocks):
            if block.startswith('[node '):
                name = re.search(r'name="([^"]+)"', block).group(1)
                parent = re.search(r'parent="([^"]+)"', block.split('\n')[0])
                key = name if parent is None or parent.group(1) == '.' else parent.group(1) + '/' + name
                self.nodes[key] = index
            elif block.startswith('[sub_resource '):
                self.resources[re.search(r'id="([^"]+)"', block).group(1)] = index

    def set(self, index, key, value):
        block = self.blocks[index]
        line = key + ' = ' + value
        pattern = '^' + re.escape(key) + r' = .*'
        self.blocks[index] = re.sub(pattern, lambda _: line, block, flags=re.M) if re.search(pattern, block, re.M) else block.rstrip() + '\n' + line + '\n\n'

    def node(self, path, key, value):
        self.set(self.nodes[path], key, value)

    def size(self, parent, size):
        for suffix, prop in [('Collision', 'shape'), ('Mesh', 'mesh')]:
            path = parent + '/' + suffix
            if path in self.nodes:
                block = self.blocks[self.nodes[path]]
                resource = re.search(prop + r' = SubResource\("([^"]+)"\)', block).group(1)
                self.set(self.resources[resource], 'size', size)

    def position(self, path, z):
        block = self.blocks[self.nodes[path]]
        values = re.search(r'position = Vector3\(([^)]+)\)', block).group(1).split(',')
        values[2] = str(z)
        self.node(path, 'position', 'Vector3(' + ', '.join(v.strip() for v in values) + ')')

    def save(self):
        self.path.write_text(''.join(self.blocks), encoding='utf-8', newline='\n')


def run():
    s = Scene('game/scenes/levels/floor4/corridor.tscn')
    for name, size in [('Floor', 'Vector3(44, 0.2, 4)'), ('Roof', 'Vector3(44, 0.15, 4)'), ('WestEnd', 'Vector3(0.2, 3, 4)'), ('EastEnd', 'Vector3(0.2, 3, 4)')]:
        s.position(name, 2.0)
        s.size(name, size)
    for name in s.nodes:
        if name in ['RailingTop', 'RailingLow'] or re.fullmatch(r'RailBar_\d+', name): s.position(name, 3.99)
        elif name == 'RailingBarrier': s.position(name, 4.05)
        elif name == 'Clothesline' or re.fullmatch(r'HangingCloth_\d+', name): s.position(name, 3.87)
        elif re.fullmatch(r'CorridorLight_(\d+|Desk)', name): s.position(name, 2.0)
    for zone in ['AmbientZone', 'ReverbZone']:
        s.position(zone, 2.0)
        shape = re.search(r'shape = SubResource\("([^"]+)"\)', s.blocks[s.nodes[zone + '/Shape']]).group(1)
        s.set(s.resources[shape], 'size', 'Vector3(44, 3, 4)')
    if 'Navigation' not in s.nodes:
        mesh = '[sub_resource type="NavigationMesh" id="t187_hall_nav"]\nvertices = PackedVector3Array(0.35,0,1.1, 0.35,0,3.55, 43.65,0,3.55, 43.65,0,1.1)\npolygons = [PackedInt32Array(0,1,2,3)]\nagent_radius = 0.3\nagent_height = 1.75\n\n'
        s.blocks.insert(min(s.nodes.values()), mesh)
        s.blocks.append('\n[node name="Navigation" type="NavigationRegion3D" parent="."]\nnavigation_mesh = SubResource("t187_hall_nav")\n\n[node name="Room407Link" type="NavigationLink3D" parent="."]\nstart_position = Vector3(32,0.03,-0.7)\nend_position = Vector3(32,0,1.2)\nmetadata/requires_open_door = true\n')
    s.save()
    s = Scene('game/scenes/levels/floor4/duty_desk.tscn')
    for zone in ['AmbientZone', 'ReverbZone']:
        s.position(zone, 2.0)
        shape = re.search(r'shape = SubResource\("([^"]+)"\)', s.blocks[s.nodes[zone + '/Shape']]).group(1)
        s.set(s.resources[shape], 'size', 'Vector3(6, 3, 4)')
    s.save()
    s = Scene('game/scenes/levels/floor4/floor4.tscn')
    for name, z in [('seg1_start', 1.6), ('seg5_start', 2.0), ('ClotheslineExtraShirt', 3.87), ('DarkSection', 2.0)]:
        s.position('Anchors/' + name, z)
    s.save()
    s = Scene('game/scenes/levels/cctv/cctv_set.tscn')
    for name, size, z in [('Floor', 'Vector3(10, 0.2, 4)', 2), ('Ceiling', 'Vector3(10, 0.15, 4)', 2), ('EndWest', 'Vector3(0.2, 3, 4.2)', 2), ('EndEast', 'Vector3(0.2, 3, 4.2)', 2)]:
        s.position('Corridor/' + name, z)
        s.size('Corridor/' + name, size)
    s.position('Corridor/OuterWall', 4.1)
    s.position('Corridor/Tube', 2.0)
    s.position('Corridor/Cam', 3.7)
    # Same camera target; recalculate its orientation for the wider balcony.
    import math
    dx, dy, dz = 8.0 - .3, .9 - 2.75, .2 - 3.7
    s.node('Corridor/Cam', 'rotation_degrees', 'Vector3(%s, %s, 0)' % (math.degrees(math.atan2(dy, math.hypot(dx, dz))), math.degrees(math.atan2(-dx, -dz))))
    s.save()
    print('T187_PATCH: corridor, duty zones, four anchors and CCTV corridor updated; Room407 untouched')


if __name__ == '__main__':
    run()
