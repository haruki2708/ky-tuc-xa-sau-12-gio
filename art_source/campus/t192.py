"""T-192: rebuild the stands, gates, street props and apply the narrow patch.

Run from the repo root (stdlib only):  python3 art_source/campus/t192.py

build_campus.py --detail rewrites every campus scene deterministically, but
building_b.tscn, campus.tscn and layout.json were later patched by hand
(T-190 doors, T-188 stairs, D-062, D-065), so a full regeneration would lose
that work. This script therefore:
  1. runs the generator and canteen_cn.py (stadium.tscn, props.tscn,
     outdoor_navigation.tres are generator-owned; the other scenes come out
     byte-identical),
  2. puts building_b.tscn, campus.tscn and layout.json back as they were,
  3. patches campus.tscn and layout.json narrowly: stand navigation, moved
     stadium anchors, the Bleachers zone and the Props instance.
Every node it adds carries `metadata/t192 = true` and its resources use ids
starting with `t192_`, so running it again gives the same result.
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
if '--detail' not in sys.argv:
    sys.argv.append('--detail')
import build_campus as c  # noqa: E402
import scatter  # noqa: E402
import stands  # noqa: E402

ROOT = c.ROOT
CAMPUS = ROOT / 'game/scenes/levels/campus/campus.tscn'
PRESERVED = [CAMPUS, ROOT / 'game/scenes/levels/campus/building_b.tscn', ROOT / 'art_source/campus/layout.json']
# Navigation nodes of the old stands (T-183) that this task replaces.
OLD_NAV = re.compile(r'^(Main|Secondary)(Tier\d+|BleacherRamp|RampTier\d+|RampGround)$|^UnderBleachers(Entry)?$')
NEW_NAV = re.compile(r'^(Main|South)Stand')
MOVED_ANCHORS = ['ZombieSpawns/Stadium/S03', 'ZombieSpawns/Stadium/S04', 'ZombieIdle/Stadium/I03', 'ZombieIdle/Stadium/I04', 'Clues/SirenSpot']


def key(block):
    if not block.startswith('[node '):
        return None
    name = re.search(r'name="([^"]+)"', block).group(1)
    parent = re.search(r'parent="([^"]+)"', block.split('\n')[0])
    return name if parent is None or parent.group(1) == '.' else parent.group(1) + '/' + name


class Patch:
    def __init__(self, path):
        self.path = path
        self.blocks = re.split(r'(?=^\[)', path.read_text(encoding='utf-8'), flags=re.M)
        self.blocks = [b for b in self.blocks if 'id="t192_' not in b.split('\n')[0] and 'metadata/t192 = true' not in b]

    def remove(self, predicate):
        removed = [b for b in self.blocks if predicate(key(b))]
        meshes = {m for b in removed for m in re.findall(r'navigation_mesh = SubResource\("([^"]+)"\)', b)}
        self.blocks = [b for b in self.blocks if b not in removed and not any(b.startswith('[sub_resource type="NavigationMesh" id="%s"]' % m) for m in meshes)]
        return len(removed)

    def find(self, path):
        for i, b in enumerate(self.blocks):
            if key(b) == path:
                return i
        raise KeyError(path)

    def set_position(self, path, point):
        i = self.find(path)
        self.blocks[i] = re.sub(r'^position = .*$', 'position = ' + c.V(point), self.blocks[i], count=1, flags=re.M)

    def merge(self, scene):
        def refs(text):
            return re.sub(r'(id="|Resource\(")([es]\d+)', r'\1t192_\2', text)
        ext = ['[ext_resource type="%s" path="%s" id="%s"]\n\n' % (kind, path, ident) for (path, kind), ident in scene.ext.items()]
        insert = next(i for i, b in enumerate(self.blocks) if b.startswith(('[sub_resource ', '[node ')))
        self.blocks[insert:insert] = [refs(b) for b in ext]
        insert = next(i for i, b in enumerate(self.blocks) if b.startswith('[node '))
        self.blocks[insert:insert] = [refs(b) + '\n' for b in scene.sub]
        for block in scene.nodes[1:]:
            self.blocks.append(refs(block).rstrip() + '\nmetadata/t192 = true\n\n')

    def save(self):
        self.path.write_text(''.join(self.blocks).rstrip() + '\n', encoding='utf-8', newline='\n')


def patch_campus():
    target = Patch(CAMPUS)
    removed = target.remove(lambda k: k is not None and k.startswith('Navigation/') and OLD_NAV.match(k.split('/')[1]) is not None)
    s = c.base.Scene('Patch')
    added = 0
    for name, points in c.NAV:
        if NEW_NAV.match(name):
            mesh = s.subresource('NavigationMesh', 'vertices = PackedVector3Array(' + ','.join(str(round(n, 6)) for p in points for n in p)
                                 + ')\npolygons = [PackedInt32Array(0,1,2,3)]\nagent_radius = 0.3\nagent_height = 1.75')
            s.node(name, 'NavigationRegion3D', 'Navigation', 'navigation_mesh = ' + mesh)
            added += 1
    links = 0
    for name, a, b, extra in c.LINKS:
        if NEW_NAV.match(name):
            s.node(name, 'NavigationLink3D', 'Navigation', 'start_position = %s\nend_position = %s\nbidirectional = true\n%s' % (c.V(a), c.V(b), extra))
            links += 1
    s.node('Props', parent='.', instance=s.resource('res://scenes/levels/campus/props.tscn'))
    target.merge(s)
    for name in MOVED_ANCHORS:
        parts = ('Anchors/' + name).split('/')
        target.set_position('/'.join(parts), c.ANCHORS[name])
    # The Bleachers zone box covers the new main stand (seats up to 6.8 m, roof, under-stand).
    zone = target.find('Zones/Bleachers')
    center, size = stands.BLEACHERS_ZONE
    target.blocks[zone] = re.sub(r'^position = .*$', 'position = ' + c.V(center), target.blocks[zone], count=1, flags=re.M)
    shape_id = re.search(r'shape = SubResource\("([^"]+)"\)', target.blocks[target.find('Zones/Bleachers/Collision')]).group(1)
    for i, b in enumerate(target.blocks):
        if b.startswith('[sub_resource type="BoxShape3D" id="%s"]' % shape_id):
            target.blocks[i] = re.sub(r'^size = .*$', 'size = ' + c.V(size), b, count=1, flags=re.M)
    target.save()
    return removed, added, links


def patch_layout(removed, added, links):
    path = ROOT / 'art_source/campus/layout.json'
    layout = json.loads(path.read_text(encoding='utf-8'))
    for name in MOVED_ANCHORS:
        layout['anchors'][name] = list(c.ANCHORS[name])
    layout['navigation_surfaces'] = len(c.NAV)
    layout['navigation_links'] = len(c.LINKS)
    path.write_text(json.dumps(layout, indent=2) + '\n', encoding='utf-8')


def main():
    snapshot = {p: p.read_bytes() for p in PRESERVED}
    c.main()
    import canteen_cn
    canteen_cn.write_canteen()
    for path, data in snapshot.items():
        path.write_bytes(data)
    removed, added, links = patch_campus()
    patch_layout(removed, added, links)
    print('T192_BUILD: removed %d old stand nav nodes, added %d regions + %d links; props %s; stands %s' % (
        removed, added, links, json.dumps(scatter.INFO, sort_keys=True), json.dumps(stands.INFO, sort_keys=True)))


if __name__ == '__main__':
    main()
