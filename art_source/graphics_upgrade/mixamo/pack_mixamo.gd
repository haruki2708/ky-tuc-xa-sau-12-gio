## T-268: runs inside the throwaway project build/mixamo_pack/ (see pack_mixamo.ps1), never in game/.
##   --probe=<who>/<file>   print what Godot made of one imported FBX (tracks, skeleton, hips range)
##   --pack=trung,manager   write out/<who>_mixamo.res from clips.json
##   --hand=<who>/<file>    print the right wrist's way through one clip (to pick reach windows)
##   --body=<who>/<file>    print hips, head and feet through one clip (to plan a whole-body motion)
##   --reach=trung          write out/reach_paths.gd from clips.json's "<who>_reach" list (T-270)
## Tran Trung's library keeps the retargeted tracks as Godot made them (%GeneralSkeleton:<humanoid bone>),
## like the Quaternius libraries. The manager's skeleton is not retargeted in the game, so his clips are
## baked: played on a retargeted copy of his own GLB, then solved bone by bone onto the plain copy so
## both copies deform the mesh the same way (checked on the skinned vertices).
extends SceneTree

const FPS := 30.0
const PREFIX := "%GeneralSkeleton:"
const SOURCE_CLIP := &"mixamo_com"
var failed := false


func _initialize() -> void:
	# Nodes added here are not inside the tree until the first frame (global transforms read 0).
	_main.call_deferred()


func _main() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--probe="):
			_probe(arg.trim_prefix("--probe="))
		elif arg.begins_with("--hand="):
			_hand(arg.trim_prefix("--hand="))
		elif arg.begins_with("--body="):
			_body(arg.trim_prefix("--body="))
		elif arg.begins_with("--reach="):
			var listed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://clips.json"))
			_reach_paths(arg.trim_prefix("--reach="), listed.get(arg.trim_prefix("--reach=") + "_reach", []))
		elif arg.begins_with("--pack="):
			var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://clips.json"))
			for who: String in arg.trim_prefix("--pack=").split(","):
				if who == "trung":
					_pack_trung(manifest[who])
				elif who == "manager":
					_pack_manager(manifest[who])
	print("PACK RESULT: %s" % ("FAIL" if failed else "PASS"))
	quit(1 if failed else 0)


func _fail(text: String) -> void:
	failed = true
	print("CHECK FAIL: " + text)


## The imported FBX scene, its first AnimationPlayer and its source animation.
func _source(who: String, file: String) -> Array:
	var scene := load("res://src/%s/%s.fbx" % [who, file]) as PackedScene
	if scene == null:
		_fail("cannot load %s/%s.fbx" % [who, file])
		return []
	var node := scene.instantiate()
	var players := node.find_children("*", "AnimationPlayer", true, false)
	var skeletons := node.find_children("*", "Skeleton3D", true, false)
	if players.is_empty() or skeletons.is_empty():
		_fail("%s/%s: no AnimationPlayer or Skeleton3D" % [who, file])
		node.free()
		return []
	var player := players[0] as AnimationPlayer
	if not player.has_animation(SOURCE_CLIP):
		_fail("%s/%s: no clip %s (has %s)" % [who, file, SOURCE_CLIP, player.get_animation_list()])
		node.free()
		return []
	return [node, skeletons[0], player.get_animation(SOURCE_CLIP)]


func _probe(spec: String) -> void:
	var parts := spec.split("/")
	var got := _source(parts[0], parts[1])
	if got.is_empty():
		return
	var node: Node = got[0]
	var skeleton: Skeleton3D = got[1]
	var anim: Animation = got[2]
	print("PROBE scene root %s, children %s" % [node.name, node.get_children().map(func(c: Node) -> String: return "%s(%s)" % [c.name, c.get_class()])])
	print("PROBE skeleton %s path %s, %d bones, motion_scale %.4f" % [skeleton.name, node.get_path_to(skeleton), skeleton.get_bone_count(), skeleton.motion_scale])
	var names: Array[String] = []
	for i in skeleton.get_bone_count():
		names.append(skeleton.get_bone_name(i))
	print("PROBE bones %s" % ", ".join(names))
	var hips := skeleton.find_bone("Hips")
	if hips >= 0:
		print("PROBE Hips rest %s, global rest %s" % [skeleton.get_bone_rest(hips).origin, skeleton.get_bone_global_rest(hips).origin])
	print("PROBE clip length %.4f s, loop %d, %d tracks" % [anim.length, anim.loop_mode, anim.get_track_count()])
	var kinds := {}
	var foreign: Array[String] = []
	for t in anim.get_track_count():
		var path := String(anim.track_get_path(t))
		var kind: int = anim.track_get_type(t)
		kinds[kind] = int(kinds.get(kind, 0)) + 1
		if not path.begins_with(PREFIX):
			foreign.append(path)
		if kind == Animation.TYPE_POSITION_3D:
			var low := Vector3.INF
			var high := -Vector3.INF
			for k in anim.track_get_key_count(t):
				var v: Vector3 = anim.track_get_key_value(t, k)
				low = low.min(v)
				high = high.max(v)
			print("PROBE position track %s, %d keys, range %s .. %s" % [path, anim.track_get_key_count(t), low, high])
	print("PROBE track kinds %s (3=rot 2=pos 4=scale 0=value)" % kinds)
	print("PROBE first tracks %s" % [range(mini(6, anim.get_track_count())).map(func(t: int) -> String: return String(anim.track_get_path(t)))])
	if not foreign.is_empty():
		_fail("tracks outside %s: %s" % [PREFIX, foreign.slice(0, 8)])
	node.free()


# --- shared clip editing -----------------------------------------------------------------

## Resamples every bone track of a retargeted source clip at FPS over [start, end], applying the
## manifest's hips and loop options. Value and method tracks are dropped.
func _edit(source: Animation, entry: Dictionary) -> Animation:
	var start: float = 0.0
	var end: float = source.length
	if entry.has("window"):
		start = float(entry.window[0])
		end = float(entry.window[1])
	var frames := maxi(1, roundi((end - start) * FPS))
	var length := frames / FPS
	var anim := Animation.new()
	anim.length = length
	anim.loop_mode = Animation.LOOP_LINEAR if entry.get("loop", false) else Animation.LOOP_NONE
	var hips_mode: String = entry.get("hips_xz", "keep")
	var fix_loop: bool = entry.get("fix_loop", false)
	# T-272: "hips_yaw": "strip" takes the turn out of a turning clip (the game turns the model, the
	# clip keeps the steps): how far the hips have turned since the first frame, frame by frame.
	var turned: PackedFloat32Array = []
	if entry.get("hips_yaw", "keep") == "strip":
		var hips_track := source.find_track(NodePath(PREFIX + "Hips"), Animation.TYPE_ROTATION_3D)
		var first_yaw := 0.0
		var last_yaw := 0.0
		for f in frames + 1:
			var ahead := Basis(source.rotation_track_interpolate(hips_track, minf(start + f / FPS, source.length))).z
			var yaw := atan2(ahead.x, ahead.z)
			if f == 0:
				first_yaw = yaw
				last_yaw = yaw
			yaw = last_yaw + wrapf(yaw - last_yaw, -PI, PI)
			last_yaw = yaw
			turned.append(yaw - first_yaw)
		anim.set_meta(&"turn_degrees", rad_to_deg(turned[frames]))
	for t in source.get_track_count():
		var kind := source.track_get_type(t)
		if kind != Animation.TYPE_ROTATION_3D and kind != Animation.TYPE_POSITION_3D and kind != Animation.TYPE_SCALE_3D:
			continue
		var path := source.track_get_path(t)
		var values: Array = []
		for f in frames + 1:
			var at: float = minf(start + f / FPS, source.length)
			match kind:
				Animation.TYPE_ROTATION_3D: values.append(source.rotation_track_interpolate(t, at))
				Animation.TYPE_POSITION_3D: values.append(source.position_track_interpolate(t, at))
				Animation.TYPE_SCALE_3D: values.append(source.scale_track_interpolate(t, at))
		var is_hips_position := kind == Animation.TYPE_POSITION_3D and String(path).ends_with(":Hips")
		if not turned.is_empty() and String(path).ends_with(":Hips"):
			for f in frames + 1:
				var back := Quaternion(Vector3.UP, -turned[f])
				values[f] = back * (values[f] as Vector3) if is_hips_position else back * (values[f] as Quaternion)
		if is_hips_position and entry.get("hips_y", "keep") == "loop":
			# T-272: a stairs clip climbs (or goes down) all the way: without the net rise the game
			# carries the model up the stairs and the clip keeps the steps.
			var rise: float = (values[frames] as Vector3).y - (values[0] as Vector3).y
			for f in frames + 1:
				var v: Vector3 = values[f]
				v.y -= rise * float(f) / frames
				values[f] = v
		if is_hips_position and hips_mode != "keep":
			var first: Vector3 = values[0]
			var last: Vector3 = values[frames]
			for f in frames + 1:
				var v: Vector3 = values[f]
				if hips_mode == "rest":
					v.x = first.x
					v.z = first.z
				elif hips_mode == "loop":
					var drift: Vector3 = (last - first) * (float(f) / frames)
					v.x -= drift.x
					v.z -= drift.z
				values[f] = v
		if fix_loop and frames > 1:
			# Ease the tail of a cut window onto its first frame (loop_blend seconds), so the loop
			# closes without a pop while the middle of the motion stays as it was.
			var tail := clampi(roundi(float(entry.get("loop_blend", 0.3)) * FPS), 1, frames)
			for f in range(frames - tail + 1, frames + 1):
				var w := smoothstep(0.0, 1.0, float(f - (frames - tail)) / tail)
				if kind == Animation.TYPE_ROTATION_3D:
					values[f] = (values[f] as Quaternion).slerp(values[0] as Quaternion, w)
				else:
					values[f] = (values[f] as Vector3).lerp(values[0] as Vector3, w)
		var track := anim.add_track(kind)
		anim.track_set_path(track, path)
		var previous := Quaternion.IDENTITY
		for f in frames + 1:
			var value: Variant = values[f]
			if kind == Animation.TYPE_ROTATION_3D:
				var q := (value as Quaternion).normalized()
				if f > 0 and q.dot(previous) < 0.0:
					q = -q
				previous = q
				value = q
			anim.track_insert_key(track, f / FPS, value)
	return anim


func _range_of(anim: Animation, path_end: String) -> Array:
	for t in anim.get_track_count():
		if anim.track_get_type(t) == Animation.TYPE_POSITION_3D and String(anim.track_get_path(t)).ends_with(path_end):
			var low := Vector3.INF
			var high := -Vector3.INF
			for k in anim.track_get_key_count(t):
				var v: Vector3 = anim.track_get_key_value(t, k)
				low = low.min(v)
				high = high.max(v)
			var count := anim.track_get_key_count(t)
			var travel: Vector3 = (anim.track_get_key_value(t, count - 1) as Vector3) - (anim.track_get_key_value(t, 0) as Vector3)
			return [low, high, travel]
	return [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]


# --- Tran Trung ----------------------------------------------------------------------------

func _pack_trung(entries: Array) -> void:
	var library := AnimationLibrary.new()
	for entry: Dictionary in entries:
		var got := _source("trung", entry.file)
		if got.is_empty():
			continue
		var source: Animation = got[2]
		var anim := _edit(source, entry)
		if entry.get("mirror", false):
			anim = _mirror(got[1], anim, entry.name)
		if entry.has("lower"):
			_lower(got[1], anim, float(entry.lower), entry.name)
		for t in anim.get_track_count():
			var path := String(anim.track_get_path(t))
			if not path.begins_with(PREFIX):
				_fail("trung/%s: track %s is not on the humanoid skeleton" % [entry.file, path])
			if anim.track_get_type(t) == Animation.TYPE_POSITION_3D and not path.ends_with(":Hips"):
				_fail("trung/%s: position track %s besides Hips" % [entry.file, path])
		var hips := _range_of(anim, ":Hips")
		library.add_animation(StringName(entry.name), anim)
		print("PACK trung %-15s <- %-13s %.3f s (source %.3f s), %d tracks, hips %s .. %s, first to last %s (x motion_scale)" % [
			entry.name, entry.file, anim.length, source.length, anim.get_track_count(), hips[0], hips[1], hips[2]])
		(got[0] as Node).free()
	_save(library, "res://out/trung_mixamo.res")


func _save(library: AnimationLibrary, path: String) -> void:
	var err := ResourceSaver.save(library, path, ResourceSaver.FLAG_COMPRESS)
	if err != OK:
		_fail("cannot save %s (%d)" % [path, err])
		return
	print("PACK saved %s, %d clips, %d bytes" % [path, library.get_animation_list().size(), FileAccess.get_file_as_bytes(path).size()])


# --- the manager ---------------------------------------------------------------------------

class Rig:
	var node: Node3D
	var skeleton: Skeleton3D
	var mesh: MeshInstance3D
	var bind_bone: PackedInt32Array = []


func _rig(path: String) -> Rig:
	var rig := Rig.new()
	rig.node = (load(path) as PackedScene).instantiate() as Node3D
	root.add_child(rig.node)
	rig.skeleton = rig.node.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	for found: Node in rig.node.find_children("*", "MeshInstance3D", true, false):
		if (found as MeshInstance3D).skin != null:
			rig.mesh = found as MeshInstance3D
			break
	var skin := rig.mesh.skin
	for i in skin.get_bind_count():
		var bone := skin.get_bind_bone(i)
		if bone < 0:
			bone = rig.skeleton.find_bone(skin.get_bind_name(i))
		rig.bind_bone.append(bone)
	return rig


## Skeleton-space transforms of every bone for the given local poses (parents first).
func _globals(skeleton: Skeleton3D, local: Array[Transform3D]) -> Array[Transform3D]:
	var out: Array[Transform3D] = []
	out.resize(skeleton.get_bone_count())
	var done := PackedByteArray()
	done.resize(skeleton.get_bone_count())
	for i in skeleton.get_bone_count():
		_global_of(skeleton, local, out, done, i)
	return out


func _global_of(skeleton: Skeleton3D, local: Array[Transform3D], out: Array[Transform3D], done: PackedByteArray, i: int) -> Transform3D:
	if done[i] == 1:
		return out[i]
	var parent := skeleton.get_bone_parent(i)
	out[i] = local[i] if parent < 0 else _global_of(skeleton, local, out, done, parent) * local[i]
	done[i] = 1
	return out[i]


## Local poses of the retargeted skeleton at time `at` of a %GeneralSkeleton clip (rest where untracked).
func _pose_at(skeleton: Skeleton3D, anim: Animation, at: float) -> Array[Transform3D]:
	var local: Array[Transform3D] = []
	for i in skeleton.get_bone_count():
		local.append(skeleton.get_bone_rest(i))
	for t in anim.get_track_count():
		var path := String(anim.track_get_path(t))
		var bone := skeleton.find_bone(path.get_slice(":", 1))
		if bone < 0:
			continue
		var pose := local[bone]
		match anim.track_get_type(t):
			Animation.TYPE_ROTATION_3D:
				pose.basis = Basis(anim.rotation_track_interpolate(t, at))
			Animation.TYPE_POSITION_3D:
				pose.origin = anim.position_track_interpolate(t, at) * skeleton.motion_scale
		local[bone] = pose
	return local


func _pack_manager(entries: Array) -> void:
	var plain := _rig("res://manager/manager_plain.glb")
	var ret := _rig("res://manager/manager_ret.glb")
	print("PACK manager plain skeleton %s (%d bones, motion_scale %.3f), retargeted %s (%d bones, motion_scale %.3f)" % [
		plain.node.get_path_to(plain.skeleton), plain.skeleton.get_bone_count(), plain.skeleton.motion_scale,
		ret.node.get_path_to(ret.skeleton), ret.skeleton.get_bone_count(), ret.skeleton.motion_scale])
	print("PACK manager mesh %s vs skeleton %s (plain), %s vs %s (retargeted)" % [
		plain.mesh.global_transform.origin, plain.skeleton.global_transform.origin, ret.mesh.global_transform.origin, ret.skeleton.global_transform.origin])
	if plain.mesh.skin.get_bind_count() != ret.mesh.skin.get_bind_count():
		_fail("manager skins differ: %d vs %d binds" % [plain.mesh.skin.get_bind_count(), ret.mesh.skin.get_bind_count()])
		return
	# The manager's own clips name their tracks; the baked ones use the same paths.
	var player := plain.node.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	var own := player.get_animation(&"stand")
	var prefix := String(own.track_get_path(0)).get_slice(":", 0)
	print("PACK manager track prefix %s (stand: %d tracks)" % [prefix, own.get_track_count()])
	# Per bind: plain bone global = toward * retargeted bone global * bind_r * bind_p^-1.
	var toward := plain.mesh.global_transform.affine_inverse() * ret.mesh.global_transform
	var carry: Array[Transform3D] = []
	var owner_bind := PackedInt32Array()
	owner_bind.resize(plain.skeleton.get_bone_count())
	owner_bind.fill(-1)
	for i in plain.mesh.skin.get_bind_count():
		carry.append(ret.mesh.skin.get_bind_pose(i) * plain.mesh.skin.get_bind_pose(i).affine_inverse())
		owner_bind[plain.bind_bone[i]] = i
	var library := AnimationLibrary.new()
	for entry: Dictionary in entries:
		var got := _source("manager", entry.file)
		if got.is_empty():
			continue
		var source := _edit(got[2] as Animation, entry)
		(got[0] as Node).free()
		var baked := _bake(plain, ret, source, toward, carry, owner_bind, prefix)
		var stride := _stride(plain, baked)
		if stride > 0.0:
			# manager_body.gd reads this to play a walk at the pace its feet need (no sliding).
			baked.set_meta(&"stride_speed", stride)
		library.add_animation(StringName(entry.name), baked)
		print("PACK manager %-8s <- %-15s %.3f s, %d tracks, planted-foot speed %.3f m/s" % [entry.name, entry.file, baked.length, baked.get_track_count(), stride])
		var slide := _foot_slide(plain, baked)
		print("PACK manager %-8s planted feet slide per cycle: left %.3f m, right %.3f m" % [entry.name, slide.x, slide.y])
		var limit: float = float(entry.get("max_slide", -1.0))
		if limit >= 0.0 and maxf(slide.x, slide.y) > limit:
			_fail("manager %s: a planted foot slides %.3f m a cycle (limit %.3f)" % [entry.name, maxf(slide.x, slide.y), limit])
		if entry.has("print_hand"):
			_print_hand(plain, baked, prefix)
	_save(library, "res://out/manager_mixamo.res")


func _bake(plain: Rig, ret: Rig, source: Animation, toward: Transform3D, carry: Array[Transform3D], owner_bind: PackedInt32Array, prefix: String) -> Animation:
	var bones := plain.skeleton.get_bone_count()
	var frames := roundi(source.length * FPS)
	var rotations: Array = []
	var positions: Array = []
	for b in bones:
		rotations.append([])
		positions.append([])
	var worst_offset := 0.0
	for f in frames + 1:
		var at: float = minf(f / FPS, source.length)
		var g_ret := _globals(ret.skeleton, _pose_at(ret.skeleton, source, at))
		var g_plain: Array[Transform3D] = []
		g_plain.resize(bones)
		var done := PackedByteArray()
		done.resize(bones)
		for b in bones:
			_solve(plain, ret, b, g_ret, toward, carry, owner_bind, g_plain, done)
		for b in bones:
			var parent := plain.skeleton.get_bone_parent(b)
			var local: Transform3D = g_plain[b] if parent < 0 else g_plain[parent].affine_inverse() * g_plain[b]
			var q := local.basis.orthonormalized().get_rotation_quaternion()
			var list: Array = rotations[b]
			if not list.is_empty() and q.dot(list[-1]) < 0.0:
				q = -q
			list.append(q)
			(positions[b] as Array).append(local.origin)
			if parent >= 0:
				worst_offset = maxf(worst_offset, local.origin.distance_to(plain.skeleton.get_bone_rest(b).origin))
	if worst_offset > 0.002:
		_fail("manager bake: a bone left its rest offset by %.4f m" % worst_offset)
	var anim := Animation.new()
	anim.length = frames / FPS
	anim.loop_mode = source.loop_mode
	for b in bones:
		var path := NodePath("%s:%s" % [prefix, plain.skeleton.get_bone_name(b)])
		var track := anim.add_track(Animation.TYPE_POSITION_3D)
		anim.track_set_path(track, path)
		var list: Array = positions[b]
		if plain.skeleton.get_bone_parent(b) < 0:
			for f in list.size():
				anim.track_insert_key(track, f / FPS, list[f])
		else:
			anim.track_insert_key(track, 0.0, plain.skeleton.get_bone_rest(b).origin)
		track = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(track, path)
		list = rotations[b]
		for f in list.size():
			anim.track_insert_key(track, f / FPS, list[f])
	# Read back what was written (the plain rig posed by the new clip's own tracks) and skin the
	# mesh with it: it must land where the retargeted rig puts it.
	for f: int in [0, frames / 3, frames / 2, frames]:
		var at: float = minf(f / FPS, source.length)
		_check_skin(plain, ret, _plain_globals(plain, anim, at), _globals(ret.skeleton, _pose_at(ret.skeleton, source, at)), f)
	return anim


func _solve(plain: Rig, ret: Rig, b: int, g_ret: Array[Transform3D], toward: Transform3D, carry: Array[Transform3D], owner_bind: PackedInt32Array, out: Array[Transform3D], done: PackedByteArray) -> Transform3D:
	if done[b] == 1:
		return out[b]
	var i := owner_bind[b]
	if i >= 0 and ret.bind_bone[i] >= 0:
		out[b] = toward * g_ret[ret.bind_bone[i]] * carry[i]
	else:
		var parent := plain.skeleton.get_bone_parent(b)
		var above := Transform3D.IDENTITY if parent < 0 else _solve(plain, ret, parent, g_ret, toward, carry, owner_bind, out, done)
		out[b] = above * plain.skeleton.get_bone_rest(b)
	done[b] = 1
	return out[b]


## Skins a sample of the mesh with both rigs: the plain pose read back from the baked clip must put
## the vertices where the retargeted pose does (catches a wrong bind pairing, a track on the wrong
## bone, a lost root position or a flipped key).
func _check_skin(plain: Rig, ret: Rig, g_plain: Array[Transform3D], g_ret: Array[Transform3D], frame: int) -> void:
	var worst := 0.0
	for s in mini(plain.mesh.mesh.get_surface_count(), ret.mesh.mesh.get_surface_count()):
		var a := plain.mesh.mesh.surface_get_arrays(s)
		var b := ret.mesh.mesh.surface_get_arrays(s)
		var verts_a: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		var verts_b: PackedVector3Array = b[Mesh.ARRAY_VERTEX]
		if verts_a.size() != verts_b.size():
			_fail("manager meshes differ in surface %d" % s)
			return
		var per := (a[Mesh.ARRAY_BONES] as PackedInt32Array).size() / maxi(1, verts_a.size())
		var step := maxi(1, verts_a.size() / 400)
		for v in range(0, verts_a.size(), step):
			var pa := _skinned(plain, g_plain, verts_a[v], a, v, per)
			var pb := _skinned(ret, g_ret, verts_b[v], b, v, per)
			worst = maxf(worst, pa.distance_to(pb))
	print("PACK manager skin check frame %d: worst vertex gap %.5f m" % [frame, worst])
	if worst > 0.003:
		_fail("manager bake: skinned vertices %.4f m apart at frame %d" % [worst, frame])


func _skinned(rig: Rig, g: Array[Transform3D], vertex: Vector3, arrays: Array, v: int, per: int) -> Vector3:
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var sum := Vector3.ZERO
	for k in per:
		var w := weights[v * per + k]
		if w <= 0.0:
			continue
		var i := bones[v * per + k]
		sum += (g[rig.bind_bone[i]] * rig.mesh.skin.get_bind_pose(i) * vertex) * w
	return rig.mesh.global_transform * sum


## Skeleton-space transforms of the plain rig posed by one of its own (baked) clips.
func _plain_globals(plain: Rig, anim: Animation, at: float) -> Array[Transform3D]:
	var local: Array[Transform3D] = []
	for b in plain.skeleton.get_bone_count():
		local.append(plain.skeleton.get_bone_rest(b))
	for t in anim.get_track_count():
		var bone := plain.skeleton.find_bone(String(anim.track_get_path(t)).get_slice(":", 1))
		var pose := local[bone]
		if anim.track_get_type(t) == Animation.TYPE_ROTATION_3D:
			pose.basis = Basis(anim.rotation_track_interpolate(t, at))
		elif anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
			pose.origin = anim.position_track_interpolate(t, at)
		local[bone] = pose
	return _globals(plain.skeleton, local)


## The right hand's height and reach over a clip, to pick a slash window (skeleton space: he faces +Z).
func _print_hand(plain: Rig, anim: Animation, _prefix: String) -> void:
	var hand := plain.skeleton.find_bone("mixamorig_RightHand")
	var lines: Array[String] = []
	for f in roundi(anim.length * FPS / 2.0) + 1:
		var at := f * 2.0 / FPS
		var p := _plain_globals(plain, anim, at)[hand].origin
		lines.append("%.2f:y%.2f,z%.2f" % [at, p.y, p.z])
	print("PACK manager hand " + " ".join(lines))


## For a clip played in place: how far each foot drifts over the ground while planted (ankle within
## 2 cm of its lowest), summed over one cycle (x left, y right). A stepping foot does not count.
func _foot_slide(plain: Rig, anim: Animation) -> Vector2:
	var frames := roundi(anim.length * FPS)
	var out := Vector2.ZERO
	for side in 2:
		var foot := plain.skeleton.find_bone("mixamorig_LeftFoot" if side == 0 else "mixamorig_RightFoot")
		var points: Array[Vector3] = []
		var lowest := INF
		for f in frames + 1:
			var p := _plain_globals(plain, anim, f / FPS)[foot].origin
			points.append(p)
			lowest = minf(lowest, p.y)
		var drift := 0.0
		for f in frames:
			if points[f].y < lowest + 0.02 and points[f + 1].y < lowest + 0.02:
				drift += Vector2(points[f + 1].x - points[f].x, points[f + 1].z - points[f].z).length()
		out[side] = drift
	return out


## How fast a planted foot moves backwards under him (m/s), as player_body.gd measures Tran Trung's
## clips: frames where the left foot is within 2 cm of its lowest, over one cycle.
func _stride(plain: Rig, anim: Animation) -> float:
	var foot := plain.skeleton.find_bone("mixamorig_LeftFoot")
	var frames := roundi(anim.length * FPS)
	var points: Array[Vector3] = []
	var lowest := INF
	for f in frames + 1:
		var p := _plain_globals(plain, anim, f / FPS)[foot].origin
		points.append(p)
		lowest = minf(lowest, p.y)
	var distance := 0.0
	var time := 0.0
	for f in frames:
		if points[f].y < lowest + 0.02 and points[f + 1].y < lowest + 0.02:
			distance += Vector2(points[f + 1].x - points[f].x, points[f + 1].z - points[f].z).length()
			time += 1.0 / FPS
	return distance / time if time > 0.1 else 0.0


# --- T-270: the right wrist's way to a thing and back, from a clip ---------------------------

## The right wrist at `at` seconds of a retargeted source clip (metres; skeleton space, from over
## where the hips are: a clip that steps toward its door does not count the step as the hand's way).
func _wrist(skeleton: Skeleton3D, anim: Animation, at: float) -> Vector3:
	var posed := _globals(skeleton, _pose_at(skeleton, anim, at))
	var hips: Vector3 = posed[skeleton.find_bone("Hips")].origin
	return posed[skeleton.find_bone("RightHand")].origin - Vector3(hips.x, 0.0, hips.z)


func _hand(spec: String) -> void:
	var parts := spec.split("/")
	var got := _source(parts[0], parts[1])
	if got.is_empty():
		return
	var skeleton: Skeleton3D = got[1]
	var anim: Animation = got[2]
	var first := _wrist(skeleton, anim, 0.0)
	var lines: Array[String] = []
	for f in range(0, roundi(anim.length * FPS) + 1, 2):
		var p := _wrist(skeleton, anim, f / FPS)
		lines.append("%.2f:d%.2f,y%.2f,z%.2f" % [f / FPS, p.distance_to(first), p.y, p.z])
	print("PROBE hand %s (%.2f s; d = from the first frame, y up, z ahead) %s" % [spec, anim.length, " ".join(lines)])
	(got[0] as Node).free()


const REACH_SAMPLES := 24


## One leg of the way (from `start` to `end` seconds) as REACH_SAMPLES + 1 points: x how far along
## the straight line from its first to its last point, y how far above that line, z how far to the
## right of the way, all in lengths of the line.
func _reach_leg(skeleton: Skeleton3D, anim: Animation, start: float, end: float) -> Array[Vector3]:
	var from := _wrist(skeleton, anim, start)
	var to := _wrist(skeleton, anim, end)
	var chord := to - from
	var length := chord.length()
	var along := chord / length
	var up := (Vector3.UP - along * along.dot(Vector3.UP)).normalized()
	var side := along.cross(up)
	var out: Array[Vector3] = []
	for i in REACH_SAMPLES + 1:
		var d := _wrist(skeleton, anim, lerpf(start, end, float(i) / REACH_SAMPLES)) - from
		out.append(Vector3(d.dot(along), d.dot(up), d.dot(side)) / length)
	out[0] = Vector3.ZERO
	out[REACH_SAMPLES] = Vector3(1, 0, 0)
	return out


func _reach_paths(who: String, entries: Array) -> void:
	var lines: PackedStringArray = []
	lines.append("class_name ReachPaths")
	lines.append("## Generated by art_source/graphics_upgrade/mixamo/pack_mixamo.gd (--reach) from clips.json: do not edit.")
	lines.append("## T-270: the right wrist's way to a thing (&\"reach\") and back (&\"back\"), measured on Mixamo clips. Each")
	lines.append("## point: x how far along the straight line from start to end, y how far above that line, z how far to")
	lines.append("## the right of the way, all in lengths of the line. point() lays a path between two points of the game.")
	lines.append("")
	lines.append("const PATHS := {")
	for entry: Dictionary in entries:
		var got := _source(who, entry.file)
		if got.is_empty():
			continue
		var skeleton: Skeleton3D = got[1]
		var anim: Animation = got[2]
		lines.append("\t&\"%s\": {  # %s" % [entry.name, entry.file])
		for leg: String in ["reach", "back"]:
			if not entry.has(leg):
				continue
			var window: Array = entry[leg]
			var points := _reach_leg(skeleton, anim, float(window[0]), float(window[1]))
			var high := 0.0
			var wide := 0.0
			var written: PackedStringArray = []
			for point: Vector3 in points:
				high = maxf(high, absf(point.y))
				wide = maxf(wide, absf(point.z))
				written.append("Vector3(%.3f, %.3f, %.3f)" % [point.x, point.y, point.z])
			lines.append("\t\t&\"%s\": [%s]," % [leg, ", ".join(written)])
			print("PACK reach %s %s: %.2f-%.2f s, line %.2f m, at most %.2f above and %.2f beside it (in lengths)" % [entry.name, leg,
				float(window[0]), float(window[1]), _wrist(skeleton, anim, float(window[0])).distance_to(_wrist(skeleton, anim, float(window[1]))), high, wide])
			if high > 0.6 or wide > 0.6:
				_fail("reach %s %s strays too far from its line" % [entry.name, leg])
		lines.append("\t},")
		(got[0] as Node).free()
	lines.append("}")
	lines.append("")
	lines.append("")
	lines.append("## The point `u` (0..1) of the way along `path`, laid from `from` to `to`.")
	lines.append("static func point(path: Array, from: Vector3, to: Vector3, u: float) -> Vector3:")
	lines.append("\tvar chord: Vector3 = to - from")
	lines.append("\tvar length: float = chord.length()")
	lines.append("\tif path.size() < 2 or length < 0.001:")
	lines.append("\t\treturn from.lerp(to, clampf(u, 0.0, 1.0))")
	lines.append("\tvar at: float = clampf(u, 0.0, 1.0) * (path.size() - 1)")
	lines.append("\tvar index: int = mini(int(at), path.size() - 2)")
	lines.append("\tvar sample: Vector3 = (path[index] as Vector3).lerp(path[index + 1] as Vector3, at - index)")
	lines.append("\tvar along: Vector3 = chord / length")
	lines.append("\tvar up: Vector3 = Vector3.UP - along * along.dot(Vector3.UP)")
	lines.append("\tif up.length() < 0.01:")
	lines.append("\t\treturn from + chord * sample.x")
	lines.append("\tup = up.normalized()")
	lines.append("\t# Straight up or down there is no \"above the line\": the bow fades out as the way steepens.")
	lines.append("\tvar bow: float = length * (1.0 - smoothstep(0.85, 0.98, absf(along.dot(Vector3.UP))))")
	lines.append("\treturn from + chord * sample.x + (up * sample.y + along.cross(up) * sample.z) * bow")
	var file := FileAccess.open("res://out/reach_paths.gd", FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("PACK saved res://out/reach_paths.gd, %d paths" % entries.size())


# --- T-271: the whole body through a clip (hips, head, feet), to plan getting out of bed -------

func _body(spec: String) -> void:
	# <who>/<file> or <who>/<file>@<start>,<end> (seconds; then every frame is printed).
	var window := spec.get_slice("@", 1).split(",") if spec.contains("@") else PackedStringArray()
	var parts := spec.get_slice("@", 0).split("/")
	var got := _source(parts[0], parts[1])
	if got.is_empty():
		return
	var skeleton: Skeleton3D = got[1]
	var anim: Animation = got[2]
	var lines: Array[String] = []
	var frames: int = roundi(anim.length * FPS)
	var step: int = maxi(1, frames / 40)
	var first: int = 0
	if window.size() == 2:
		first = roundi(float(window[0]) * FPS)
		frames = mini(frames, roundi(float(window[1]) * FPS))
		step = 2
	for f in range(first, frames + 1, step):
		var posed := _globals(skeleton, _pose_at(skeleton, anim, f / FPS))
		var hips: Transform3D = posed[skeleton.find_bone("Hips")]
		var head: Vector3 = posed[skeleton.find_bone("Head")].origin
		var left: Vector3 = posed[skeleton.find_bone("LeftFoot")].origin
		var right: Vector3 = posed[skeleton.find_bone("RightFoot")].origin
		var trunk: Vector3 = (head - hips.origin).normalized()
		var ahead: Vector3 = hips.basis.z
		lines.append("%.2f: hips(%.2f,%.2f,%.2f) head(%.2f,%.2f,%.2f) L(%.2f,%.2f,%.2f) R(%.2f,%.2f,%.2f) lean%.0f yaw%.0f" % [f / FPS,
			hips.origin.x, hips.origin.y, hips.origin.z, head.x, head.y, head.z, left.x, left.y, left.z, right.x, right.y, right.z,
			rad_to_deg(acos(clampf(trunk.y, -1.0, 1.0))), rad_to_deg(atan2(ahead.x, ahead.z))])
	print("PROBE body %s (%.2f s; skeleton space: x left of the model, y up, z ahead; lean = trunk from upright)
%s" % [spec, anim.length, "
".join(lines)])
	(got[0] as Node).free()


# --- T-271: a clip mirrored left to right -----------------------------------------------------

## `anim` (a %GeneralSkeleton clip) as its mirror image: what the left side did the right side
## does. Each bone's turn away from its rest (in the skeleton's space) is mirrored and laid on the
## rest of the bone across from it, so the rests of the two sides need not match.
func _mirror(skeleton: Skeleton3D, anim: Animation, label: String) -> Animation:
	var count := skeleton.get_bone_count()
	var across := PackedInt32Array()
	across.resize(count)
	var rest_local: Array[Transform3D] = []
	for i in count:
		var bone := skeleton.get_bone_name(i)
		var other := bone
		if bone.begins_with("Left"):
			other = "Right" + bone.trim_prefix("Left")
		elif bone.begins_with("Right"):
			other = "Left" + bone.trim_prefix("Right")
		across[i] = skeleton.find_bone(other) if skeleton.find_bone(other) >= 0 else i
		rest_local.append(skeleton.get_bone_rest(i))
	var rest := _globals(skeleton, rest_local)
	var flip := Basis(Vector3(-1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1))
	var out := Animation.new()
	out.length = anim.length
	out.loop_mode = anim.loop_mode
	var rotation_of := {}
	var position_of := {}
	for t in anim.get_track_count():
		var bone := skeleton.find_bone(String(anim.track_get_path(t)).get_slice(":", 1))
		if bone < 0:
			continue
		var track := out.add_track(anim.track_get_type(t))
		out.track_set_path(track, anim.track_get_path(t))
		if anim.track_get_type(t) == Animation.TYPE_ROTATION_3D:
			rotation_of[bone] = track
		elif anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
			position_of[bone] = track
	var frames := roundi(anim.length * FPS)
	var last := {}
	var worst := 0.0
	for f in frames + 1:
		var posed := _globals(skeleton, _pose_at(skeleton, anim, f / FPS))
		var mirrored: Array[Transform3D] = []
		mirrored.resize(count)
		for i in count:
			var turn := posed[i].basis.orthonormalized() * rest[i].basis.orthonormalized().inverse()
			var origin := posed[i].origin
			mirrored[across[i]] = Transform3D((flip * turn * flip) * rest[across[i]].basis.orthonormalized(), Vector3(-origin.x, origin.y, origin.z))
		for i in count:
			var parent := skeleton.get_bone_parent(i)
			var local := mirrored[i] if parent < 0 else mirrored[parent].affine_inverse() * mirrored[i]
			if rotation_of.has(i):
				var q := local.basis.get_rotation_quaternion()
				if last.has(i) and q.dot(last[i]) < 0.0:
					q = -q
				last[i] = q
				out.track_insert_key(rotation_of[i], f / FPS, q)
			if position_of.has(i):
				out.track_insert_key(position_of[i], f / FPS, local.origin / skeleton.motion_scale)
		# The check: played back, each bone stands where its twin stood, mirrored.
		if f % 5 == 0:
			var back := _globals(skeleton, _pose_at(skeleton, out, f / FPS))
			for name: String in ["Head", "LeftFoot", "RightFoot", "LeftHand", "RightHand"]:
				var i := skeleton.find_bone(name)
				var twin := posed[across[i]].origin
				worst = maxf(worst, back[i].origin.distance_to(Vector3(-twin.x, twin.y, twin.z)))
	print("PACK mirror %s: head, feet and hands at most %.1f mm from the mirror image" % [label, worst * 1000.0])
	if worst > 0.03:
		_fail("mirror %s: %.1f mm from the mirror image (the two sides of the rest pose differ too much)" % [label, worst * 1000.0])
	return out


# --- T-272: a clip crouched deeper ------------------------------------------------------------

## Lower the hips of `anim` by `drop` metres (the pack skeleton's) and bend the legs to it: each
## ankle stays where it was and the foot keeps its own turn; the knee keeps the side it bent to.
func _lower(skeleton: Skeleton3D, anim: Animation, drop: float, label: String) -> void:
	var hips := skeleton.find_bone("Hips")
	var hips_position := anim.find_track(NodePath(PREFIX + "Hips"), Animation.TYPE_POSITION_3D)
	var frames := roundi(anim.length * FPS)
	var worst := 0.0
	var short := 0
	for f in frames + 1:
		var local := _pose_at(skeleton, anim, f / FPS)
		var posed := _globals(skeleton, local)
		var down := Vector3(0.0, drop, 0.0)
		for side: String in ["Left", "Right"]:
			var upper := skeleton.find_bone(side + "UpperLeg")
			var lower := skeleton.find_bone(side + "LowerLeg")
			var foot := skeleton.find_bone(side + "Foot")
			var hip := posed[upper].origin
			var knee := posed[lower].origin
			var ankle := posed[foot].origin
			var thigh := knee.distance_to(hip)
			var shin := ankle.distance_to(knee)
			var hip_now := hip - down
			var reach := ankle - hip_now
			var far := clampf(reach.length(), absf(thigh - shin) + 0.005, thigh + shin - 0.002)
			if reach.length() < absf(thigh - shin) + 0.005:
				short += 1
			var along := reach.normalized()
			var bent := (knee - hip) - (ankle - hip).normalized() * (knee - hip).dot((ankle - hip).normalized())
			if bent.length() < 0.01:
				bent = posed[hips].basis.z
			bent = (bent - along * bent.dot(along)).normalized()
			var to_knee := (thigh * thigh - shin * shin + far * far) / (2.0 * far)
			var knee_now := hip_now + along * to_knee + bent * sqrt(maxf(thigh * thigh - to_knee * to_knee, 0.0))
			var ankle_now := hip_now + along * far
			var upper_now := Basis(Quaternion((knee - hip).normalized(), (knee_now - hip_now).normalized())) * posed[upper].basis
			var lower_now := Basis(Quaternion((ankle - knee).normalized(), (ankle_now - knee_now).normalized())) * posed[lower].basis
			var turns := {upper: posed[hips].basis.inverse() * upper_now, lower: upper_now.inverse() * lower_now, foot: lower_now.inverse() * posed[foot].basis}
			for bone: int in turns:
				var track := anim.find_track(NodePath(PREFIX + skeleton.get_bone_name(bone)), Animation.TYPE_ROTATION_3D)
				var q := (turns[bone] as Basis).orthonormalized().get_rotation_quaternion()
				if f > 0 and q.dot(anim.track_get_key_value(track, f - 1)) < 0.0:
					q = -q
				anim.track_set_key_value(track, f, q)
		anim.track_set_key_value(hips_position, f, (anim.track_get_key_value(hips_position, f) as Vector3) - down / skeleton.motion_scale)
		# The check: played back, the ankles are where they were.
		var back := _globals(skeleton, _pose_at(skeleton, anim, f / FPS))
		for name: String in ["LeftFoot", "RightFoot"]:
			worst = maxf(worst, back[skeleton.find_bone(name)].origin.distance_to(posed[skeleton.find_bone(name)].origin))
	print("PACK lower %s: hips %.2f m down, ankles at most %.1f mm off, %d leg frames folded as far as they go" % [label, drop, worst * 1000.0, short])
