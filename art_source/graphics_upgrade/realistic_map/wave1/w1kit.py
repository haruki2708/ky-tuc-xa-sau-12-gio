"""T-250 wave 1: small mesh kit for the Blender build scripts in this folder (Blender 5.2.2, bmesh only).

Frame: Blender metres, Z up. glTF export turns it to Godot's frame: Blender +X = Godot +X, Blender +Z = Godot +Y,
Blender -Y = Godot +Z (so the side of a model that faces the corridor is built facing -Y).

Materials are named placeholders (W1*): Godot swaps them for the shared materials in
game/assets/models/graphics_pilot/realistic_map/wave1/materials/ through each glb's .import (use_external),
so no texture is copied into a glb. UV1 is in metres (box projection) unless a part sets its own UVs;
each material's uv1_scale turns metres into its scan's repeat.
"""
import math
from pathlib import Path

import bmesh
import bpy
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave1"


def reset():
	bpy.ops.wm.read_factory_settings(use_empty=True)
	for block in (bpy.data.meshes, bpy.data.materials, bpy.data.objects, bpy.data.images):
		for item in list(block):
			block.remove(item)


def material(name, color=(0.8, 0.8, 0.8), rough=0.6, metal=0.0):
	found = bpy.data.materials.get(name)
	if found is not None:
		return found
	made = bpy.data.materials.new(name)
	made.use_nodes = True
	shader = made.node_tree.nodes["Principled BSDF"]
	shader.inputs["Base Color"].default_value = (*color, 1.0)
	shader.inputs["Roughness"].default_value = rough
	shader.inputs["Metallic"].default_value = metal
	made.diffuse_color = (*color, 1.0)
	return made


class Part:
	"""One output object: a bmesh plus its material slots. Every add_* returns the new faces."""

	def __init__(self, name):
		self.name = name
		self.bm = bmesh.new()
		self.uv = self.bm.loops.layers.uv.new("UVMap")
		self.slots = []

	def slot(self, mat_name):
		if mat_name not in self.slots:
			self.slots.append(mat_name)
		return self.slots.index(mat_name)

	def _finish(self, faces, mat_name, smooth=False):
		index = self.slot(mat_name)
		for face in faces:
			face.material_index = index
			face.smooth = smooth
		return faces

	def box(self, mat_name, lo, hi, bevel=0.0, segments=1, matrix=None):
		a, b = Vector(lo), Vector(hi)
		lo = Vector((min(a.x, b.x), min(a.y, b.y), min(a.z, b.z)))
		hi = Vector((max(a.x, b.x), max(a.y, b.y), max(a.z, b.z)))
		result = bmesh.ops.create_cube(self.bm, size=1.0)
		verts = result["verts"]
		size = hi - lo
		centre = (hi + lo) * 0.5
		for v in verts:
			v.co = Vector((v.co.x * size.x, v.co.y * size.y, v.co.z * size.z)) + centre
		faces = list({f for v in verts for f in v.link_faces})
		# Faces rebuilt by the bevel inherit this index, so set it first.
		index = self.slot(mat_name)
		for f in faces:
			f.material_index = index
		if bevel > 0.0:
			edges = list({e for f in faces for e in f.edges})
			bevelled = bmesh.ops.bevel(self.bm, geom=edges + verts, offset=min(bevel, min(size) * 0.45),
				segments=segments, affect="EDGES", profile=0.5, clamp_overlap=True)
			touched = [v for v in verts if v.is_valid] + list(bevelled["verts"])
			faces = list({f for v in touched for f in v.link_faces})
		if matrix is not None:
			bmesh.ops.transform(self.bm, matrix=matrix, verts=list({v for f in faces for v in f.verts}))
		return self._finish(faces, mat_name)

	def cylinder(self, mat_name, centre, radius, depth, axis="Z", segments=16, cap=True, radius2=None,
			smooth=True, matrix=None):
		"""A cylinder (or cone with radius2) along a local axis, centred at `centre`."""
		r2 = radius if radius2 is None else radius2
		result = bmesh.ops.create_cone(self.bm, cap_ends=cap, cap_tris=False, segments=segments,
			radius1=radius, radius2=r2, depth=depth)
		verts = result["verts"]
		rot = {"Z": Matrix.Identity(4), "X": Matrix.Rotation(math.pi / 2, 4, "Y"),
			"Y": Matrix.Rotation(-math.pi / 2, 4, "X")}[axis]
		full = Matrix.Translation(Vector(centre)) @ rot
		if matrix is not None:
			full = matrix @ full
		bmesh.ops.transform(self.bm, matrix=full, verts=verts)
		faces = list({f for v in verts for f in v.link_faces})
		caps = [f for f in faces if len(f.verts) > 4]
		self._finish(faces, mat_name, smooth)
		for f in caps:
			f.smooth = False
		return faces

	def lathe(self, mat_name, profile, segments=32, matrix=None, smooth=True, close_ends=True):
		"""Revolves (radius, height) points about local Z. Returns faces."""
		rings = []
		for r, z in profile:
			ring = []
			for i in range(segments):
				a = i / segments * math.tau
				ring.append(self.bm.verts.new((math.cos(a) * r, math.sin(a) * r, z)))
			rings.append(ring)
		faces = []
		for a, b in zip(rings, rings[1:]):
			for i in range(segments):
				j = (i + 1) % segments
				faces.append(self.bm.faces.new((a[i], a[j], b[j], b[i])))
		if close_ends:
			if profile[0][0] > 1e-5:
				faces.append(self.bm.faces.new(list(reversed(rings[0]))))
			if profile[-1][0] > 1e-5:
				faces.append(self.bm.faces.new(rings[-1]))
		verts = [v for ring in rings for v in ring]
		if matrix is not None:
			bmesh.ops.transform(self.bm, matrix=matrix, verts=verts)
		self._finish(faces, mat_name, smooth)
		for f in faces:
			if len(f.verts) > 4:
				f.smooth = False
		return faces

	def tube(self, mat_name, points, radius, segments=8, smooth=True, cap=True):
		"""A round tube along a polyline of Vectors."""
		pts = [Vector(p) for p in points]
		rings = []
		prev_side = None
		for i, p in enumerate(pts):
			ahead = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
			side = ahead.cross(Vector((0, 0, 1)))
			if side.length < 1e-4:
				side = ahead.cross(Vector((1, 0, 0)))
			side.normalize()
			if prev_side is not None and side.dot(prev_side) < 0:
				side = -side
			prev_side = side
			up = side.cross(ahead).normalized()
			ring = []
			for k in range(segments):
				a = k / segments * math.tau
				ring.append(self.bm.verts.new(p + (side * math.cos(a) + up * math.sin(a)) * radius))
			rings.append(ring)
		faces = []
		for a, b in zip(rings, rings[1:]):
			for k in range(segments):
				m = (k + 1) % segments
				faces.append(self.bm.faces.new((a[k], a[m], b[m], b[k])))
		if cap:
			faces.append(self.bm.faces.new(list(reversed(rings[0]))))
			faces.append(self.bm.faces.new(rings[-1]))
		self._finish(faces, mat_name, smooth)
		if cap:
			faces[-1].smooth = False
			faces[-2].smooth = False
		return faces

	def poly(self, mat_name, verts, faces_idx, smooth=False, recalc=True):
		"""Faces from index lists; closed solids get outward normals (recalc), open sheets keep their winding."""
		made = [self.bm.verts.new(v) for v in verts]
		faces = [self.bm.faces.new([made[i] for i in face]) for face in faces_idx]
		if recalc:
			bmesh.ops.recalc_face_normals(self.bm, faces=faces)
		return self._finish(faces, mat_name, smooth)

	def planar_uv(self, faces, origin, u_axis, v_axis, u_range=(0.0, 1.0), v_range=(0.0, 1.0), size=(1.0, 1.0)):
		"""Maps faces onto a UV rectangle: a point at origin + s*u_axis*size.x + t*v_axis*size.y -> (s, t)."""
		o, ua, va = Vector(origin), Vector(u_axis), Vector(v_axis)
		for f in faces:
			for loop in f.loops:
				d = loop.vert.co - o
				s = d.dot(ua) / size[0]
				t = d.dot(va) / size[1]
				loop[self.uv].uv = (u_range[0] + s * (u_range[1] - u_range[0]), v_range[0] + t * (v_range[1] - v_range[0]))
			f.tag = True

	def set_uv2(self, faces, fn):
		"""UV2 (glTF TEXCOORD_1, Godot UV2: the shell shader's mask) from fn(vertex co) -> (u, v)."""
		if not hasattr(self, "uv2"):
			self.uv2 = self.bm.loops.layers.uv.new("UV2")
			self.uv2_faces = set()
		for f in faces:
			self.uv2_faces.add(f)
			for loop in f.loops:
				loop[self.uv2].uv = fn(loop.vert.co)

	def build(self, origin=(0, 0, 0), collection=None, uv_size=None):
		"""Box-projected metric UVs on untagged faces (divided by uv_size[material] for scans whose shader has no
		uv1_scale), then the object."""
		uv_size = uv_size or {}
		if hasattr(self, "uv2"):
			# Faces without their own mask UV sample the masks' clean top-right corner.
			for f in self.bm.faces:
				if f not in self.uv2_faces:
					for loop in f.loops:
						loop[self.uv2].uv = (0.995, 0.995)
		for f in self.bm.faces:
			if f.tag:
				continue
			n = f.normal if f.normal.length > 0 else Vector((0, 0, 1))
			ax = max(range(3), key=lambda i: abs(n[i]))
			k = 1.0 / uv_size.get(self.slots[f.material_index], 1.0)
			for loop in f.loops:
				c = loop.vert.co
				if ax == 2:
					uv = (c.x, c.y if n.z > 0 else -c.y)
				elif ax == 1:
					uv = (-c.x if n.y > 0 else c.x, c.z)
				else:
					uv = (c.y if n.x > 0 else -c.y, c.z)
				loop[self.uv].uv = (uv[0] * k, uv[1] * k)
		self.bm.normal_update()
		mesh = bpy.data.meshes.new(self.name)
		self.bm.to_mesh(mesh)
		self.bm.free()
		for name in self.slots:
			mesh.materials.append(bpy.data.materials.get(name) or material(name))
		obj = bpy.data.objects.new(self.name, mesh)
		(collection or bpy.context.scene.collection).objects.link(obj)
		if Vector(origin).length > 0:
			mesh.transform(Matrix.Translation(-Vector(origin)))
			obj.location = origin
		return obj


def triangles(objs):
	total = 0
	for obj in objs:
		if obj.type == "MESH":
			total += sum(len(p.vertices) - 2 for p in obj.data.polygons)
	return total


def export(path, objs):
	path = Path(path)
	path.parent.mkdir(parents=True, exist_ok=True)
	bpy.ops.object.select_all(action="DESELECT")
	for obj in objs:
		obj.select_set(True)
		for child in obj.children_recursive:
			child.select_set(True)
	bpy.context.view_layer.objects.active = objs[0]
	bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_yup=True,
		export_apply=True, export_materials="EXPORT", export_image_format="AUTO", export_animations=False,
		export_texcoords=True, export_normals=True)
	print("T250_EXPORT %s %d tris" % (path.name, triangles([o for obj in objs for o in [obj, *obj.children_recursive]])))
