"""T-192 helpers: rotation maths and batched MultiMesh primitives (stdlib only).

Every repeated primitive (stand treads, seats, fence pickets, street props)
is collected in a Batch and written as a few `boxes.gd` MultiMesh nodes (one
per texture, shape and 40 m chunk, so frustum and distance culling keep
working). Colours differ per instance, so a prop's tint costs no extra node.
"""
import math

CHUNK = 40.0
IDENTITY = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]


def mmul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]


def mvec(m, v):
    return tuple(sum(m[i][k] * v[k] for k in range(3)) for i in range(3))


def rot_x(deg):
    a = math.radians(deg)
    return [[1, 0, 0], [0, math.cos(a), -math.sin(a)], [0, math.sin(a), math.cos(a)]]


def rot_y(deg):
    a = math.radians(deg)
    return [[math.cos(a), 0, math.sin(a)], [0, 1, 0], [-math.sin(a), 0, math.cos(a)]]


def rot_z(deg):
    a = math.radians(deg)
    return [[math.cos(a), -math.sin(a), 0], [math.sin(a), math.cos(a), 0], [0, 0, 1]]


def euler(yaw=0.0, pitch=0.0, roll=0.0):
    """Godot's default YXZ order: yaw about y, then pitch about x, then roll about z."""
    return mmul(rot_y(yaw), mmul(rot_x(pitch), rot_z(roll)))


class Frame:
    """A local coordinate frame: parts are placed relative to a prop's origin."""

    def __init__(self, batch, origin, rotation=IDENTITY):
        self.batch, self.origin, self.rotation = batch, origin, rotation

    def add(self, texture, kind, center, size, rot=IDENTITY, tint=(1.0, 1.0, 1.0)):
        world = mvec(self.rotation, center)
        position = (self.origin[0] + world[0], self.origin[1] + world[1], self.origin[2] + world[2])
        self.batch.add(texture, kind, position, size, mmul(self.rotation, rot), tint)

    def box(self, texture, center, size, rot=IDENTITY, tint=(1.0, 1.0, 1.0)):
        self.add(texture, 'box', center, size, rot, tint)

    def cyl(self, texture, center, size, rot=IDENTITY, tint=(1.0, 1.0, 1.0)):
        self.add(texture, 'cylinder', center, size, rot, tint)

    def cone(self, texture, center, size, rot=IDENTITY, tint=(1.0, 1.0, 1.0)):
        self.add(texture, 'cone', center, size, rot, tint)

    def quad(self, texture, center, size, rot=IDENTITY, tint=(1.0, 1.0, 1.0)):
        self.add(texture, 'quad', center, size, rot, tint)


class Batch:
    def __init__(self, chunk=CHUNK):
        self.groups = {}
        self.triangles = 0
        self.chunk = chunk

    TRIANGLES = {'box': 12, 'cylinder': 36, 'cone': 30, 'quad': 2}

    def add(self, texture, kind, position, size, rot=IDENTITY, tint=(1.0, 1.0, 1.0)):
        sx, sy, sz = size
        # Basis columns: rotation folded with the scale of each local axis, then the
        # origin, then the instance colour (a tint of the base texture, 0..1).
        cols = [[rot[r][c] * (sx, sy, sz)[c] for r in range(3)] for c in range(3)]
        floats = [v for col in cols for v in col] + list(position) + [min(1.0, t) for t in tint] + [1.0]
        chunk = (math.floor(position[0] / self.chunk), math.floor(position[2] / self.chunk))
        self.groups.setdefault((texture, kind), {}).setdefault(chunk, []).extend(floats)
        self.triangles += self.TRIANGLES[kind]

    def frame(self, origin, rotation=IDENTITY):
        return Frame(self, origin, rotation)

    def emit(self, s, parent, script, prefix, cull=125.0):
        """Write one `boxes.gd` node per (texture, shape, chunk) under `parent`."""
        parts = 0
        for (texture, kind), chunks in sorted(self.groups.items()):
            tex = s.resource('res://assets/textures/campus/%s.png' % texture, 'Texture2D')
            for (cx, cz), floats in sorted(chunks.items()):
                data = ','.join(('%.4f' % v).rstrip('0').rstrip('.') or '0' for v in floats)
                name = '%s_%s_%s_%s%d_%s%d' % (prefix, texture, kind, 'm' if cx < 0 else 'p', abs(cx), 'm' if cz < 0 else 'p', abs(cz))
                props = ('script = %s\ntexture = %s\nkind = "%s"\ncull_distance = %s\ndata = PackedFloat32Array(%s)'
                         % (script, tex, kind, cull, data))
                s.node(name, 'Node3D', parent, props)
                parts += 1
        return parts
