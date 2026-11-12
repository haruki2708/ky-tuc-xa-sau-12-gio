"""Optional Blender material/geometry inspection; NOT a chapter screenshot.
Writes only build/t252/blender_inspection.png. Official comparisons use capture.gd.
"""
import math
import sys
from pathlib import Path
import bpy
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0, str(HERE.parents[1] / 'room407_corner'))
import build_corner as bc

bpy.ops.wm.read_factory_settings(use_empty=True)
assets = ROOT / 'game/assets/models/graphics_pilot/realistic_map/floor4_rooms'
materials = {}
for label, scan, color in [
    ('Plaster', 'painted_plaster_wall', 'painted_plaster_wall_cream'),
    ('Tile', 'interior_tiles', None), ('Steel', 'green_metal_rust', None),
    ('Wood', 'wood_table_worn', None), ('Linen', 'rough_linen_square', None),
    ('Check', 'fabric_pattern_05', None), ('Blanket', 'polar_fleece_square', None),
]:
    materials[label] = bc.material('Preview_'+label, scan, color_asset=color, strength=.65)
dark = bpy.data.materials.new('Preview_Dark')
dark.use_nodes = True
dark.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (.045,.06,.065,1)
materials['Dark'] = dark
for asset, position, yaw in [('shell_4', (0,0,0),0), ('curtains',(0,0,0),0), ('bunk',(-1.33,0,-3.45),0),
                            ('bunk',(1.33,0,-1.45),math.pi), ('desk',(.16,0,-4.48),0),
                            ('locker',(1.35,0,-3.9),0), ('stool',(.23,0,-3.68),.26)]:
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(assets/f'{asset}.glb'))
    objects = set(bpy.context.scene.objects)-before
    pivot = bpy.data.objects.new('Part', None)
    bpy.context.collection.objects.link(pivot)
    for obj in objects:
        if obj.parent is None:
            obj.parent = pivot
        if obj.type == 'MESH':
            for slot in obj.material_slots:
                slot.material = materials[slot.material.name.split('.')[0]]
    pivot.location = bc.point(position)
    pivot.rotation_euler.z = yaw
# A doorway mask gives the same viewing constraint as the game, without importing G5.
for x in [-1.225, 1.225]:
    bc.box('FrontMask', (x,1.5,0), (1.55,3,.2), materials['Plaster'], 0, 2)
bc.box('Lintel', (0,2.55,0), (.9,.9,.2), materials['Plaster'], 0, 2)
camera_data = bpy.data.cameras.new('Camera')
camera = bpy.data.objects.new('Camera',camera_data)
bpy.context.collection.objects.link(camera)
camera.location = bc.point((-.12,1.62,.85))
camera.rotation_euler = (bc.point((-.28,1.25,-3.8))-camera.location).to_track_quat('-Z','Y').to_euler()
camera_data.lens = 28
bpy.context.scene.camera = camera
light_data = bpy.data.lights.new('InspectionTorch','SPOT')
light_data.energy = 100
light_data.spot_size = math.radians(56)
light_data.spot_blend = .5
light = bpy.data.objects.new('InspectionTorch', light_data)
bpy.context.collection.objects.link(light)
light.location = camera.location + Vector((.1,.15,-.08))
light.rotation_euler = camera.rotation_euler
world = bpy.data.worlds.new('DimNight')
world.use_nodes = True
world.node_tree.nodes['Background'].inputs['Color'].default_value = (.12,.15,.22,1)
world.node_tree.nodes['Background'].inputs['Strength'].default_value = .12
scene = bpy.context.scene
scene.world = world
scene.render.engine = 'CYCLES'
scene.cycles.samples = 24
scene.cycles.use_denoising = True
scene.render.resolution_x, scene.render.resolution_y = 1280,720
scene.render.resolution_percentage = 100
scene.render.filepath = str(ROOT/'build/t252/blender_inspection.png')
scene.render.image_settings.file_format = 'PNG'
bpy.ops.render.render(write_still=True)
