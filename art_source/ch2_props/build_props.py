"""T-172 deterministic additions. Run after T-162 when rebuilding the room."""
from pathlib import Path
import sys, re
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'art_source/ch1_models'))
import build_models as old
M, V = old.Model, old.V
OUT = ROOT / 'game/scenes/levels/ch2'


def write(path, text):
    path.write_text(text, encoding='utf-8', newline='\n')


def resource(text, kind, path, key):
    line = f'[ext_resource type="{kind}" path="res://{path}" id="{key}"]\n\n'
    if line not in text:
        index = text.index('[sub_resource') if '[sub_resource' in text else text.index('[node')
        text = text[:index] + line + text[index:]
    return text


def area(s, name, position, size, parent='.'):
    node = s.node(name, 'Area3D', parent, f'position = {V(position)}\ncollision_layer = 0\ncollision_mask = 2\nmonitorable = false')
    shape = s.subresource('BoxShape3D', 'size = ' + V(size))
    s.node('Collision', 'CollisionShape3D', node, 'shape = ' + shape)
    return node


def props():
    s = M('Towel')
    for i in range(7):
        s.part('Fold' + str(i), ((i-3)*.075, -.32, (i % 2)*.024), (.09,.64,.02), 'rag')
    for y in [-.06, -.57]:
        s.part('Hem' + str(y), (0,y,-.014), (.54,.023,.02), 'paper')
    s.save('towel.tscn')
    s = M('Shirt')
    s.part('Torso', (0,.025,0), (.29,.04,.31), 'stripes')
    for side in [-1, 1]:
        s.part('Sleeve'+str(side), (side*.18,.027,-.08), (.12,.036,.12), 'stripes', extra=f'rotation_degrees = Vector3(0,{side*20},0)')
    s.part('Collar', (0,.05,-.13), (.1,.012,.05), 'hair')
    s.save('shirt.tscn')
    s = M('Clothesline')
    s.part('Line', (0,0,0), (3.8,.012,.012), 'paper')
    for x in [-1.9, 1.9]:
        s.part('Post'+str(x), (x,-.90,0), (.035,1.8,.035), 'metal')
    for x in [-.19,.19]:
        s.part('Peg'+str(x), (x,-.01,-.025), (.018,.065,.015), 'wood')
    s.save('clothesline.tscn')


def bathroom():
    s = M('Ch2Bathroom')
    s.nodes[0] += 'script = ' + s.resource('res://scenes/levels/ch2/bathroom_effects.gd', 'Script') + '\n'
    water_mat = s.subresource('StandardMaterial3D', 'shading_mode = 0\ntransparency = 1\nalbedo_color = Color(0.62,0.78,0.83,0.48)')
    water_mesh = s.subresource('BoxMesh', 'size = Vector3(0.008,0.11,0.008)\nmaterial = '+water_mat)
    s.node('Water', 'CPUParticles3D', properties='position = Vector3(6.18,2.17,-6.65)\nvisible = false\nemitting = false\namount = 96\nlifetime = 0.48\nmesh = '+water_mesh+'\nemission_shape = 3\nemission_box_extents = Vector3(0.075,0.008,0.09)\ndirection = Vector3(0,-1,0)\nspread = 3.0\ngravity = Vector3(0,-3,0)\ninitial_velocity_min = 3.6\ninitial_velocity_max = 4.2')
    s.node('Steam', properties='visible = false')
    shader = s.resource('res://scenes/levels/ch2/steam.gdshader', 'Shader')
    sheet = s.subresource('QuadMesh', 'size = Vector2(2.5,2.5)')
    for i in range(8):
        mat = s.subresource('ShaderMaterial', f'resource_local_to_scene = true\nshader = {shader}\nshader_parameter/level = 0.0\nshader_parameter/phase = {i*1.7}')
        pos = (6.65,1.35,-4.6-i*.29) if i < 4 else (5.65+(i-4)*.56,1.35,-5.55)
        s.node('Sheet'+str(i),'MeshInstance3D','Steam',f'position = {V(pos)}\nrotation_degrees = Vector3(0,{0 if i<4 else 90},0)\nmesh = {sheet}\nmaterial_override = {mat}\ncast_shadow = 0')
    frost = s.subresource('StandardMaterial3D','resource_local_to_scene = true\nshading_mode = 0\ntransparency = 1\nalbedo_color = Color(0.75,0.8,0.78,0)\ncull_mode = 2')
    mirror = s.subresource('QuadMesh','size = Vector2(0.5,0.65)')
    s.node('MirrorFog','MeshInstance3D',properties='position = Vector3(5.423,1.55,-5)\nrotation_degrees = Vector3(0,90,0)\nmesh = '+mirror+'\nmaterial_override = '+frost+'\nvisible = false\ncast_shadow = 0')
    s.node('Reflection', properties='visible = false\nposition = Vector3(5.437,1.26,-5)\nrotation_degrees = Vector3(0,-90,0)\nscale = Vector3(0.26,0.26,0.025)')
    s.node('Manager',parent='Reflection',instance=s.resource('res://scenes/levels/ch1_models/manager_body.tscn'))
    s.save('bathroom_effects.tscn')
    s = M('Zones')
    area(s,'Bedroom',(4,1.5,-2),(7.8,3,4))
    shape=s.subresource('BoxShape3D','size = Vector3(5.2,3,3)')
    s.node('Rear','CollisionShape3D','Bedroom',f'position = Vector3(-1.35,0,-3.5)\nshape = {shape}')
    area(s,'Bathroom',(6.65,1.5,-5.5),(2.65,3,3))
    area(s,'Balcony',(2.6,1.5,-7.75),(5.2,3,1.5))
    s.save('zones.tscn')


def integrate():
    path = ROOT/'game/scenes/levels/room407/room407_anchors.tscn'
    text = path.read_text(encoding='utf-8').split('\n; T172 additions')[0]
    for key, kind, file in [('t172_rag','PackedScene','ch1_models/rag.tscn'),('t172_towel','PackedScene','ch2/towel.tscn'),('t172_shirt','PackedScene','ch2/shirt.tscn'),('t172_gag','Script','ch2/gag_anchor.gd')]:
        text = resource(text,kind,'scenes/levels/'+file,key)
    if 'id="t172_screen"' not in text:
        index=text.index('[node')
        text=text[:index]+'''[sub_resource type="StandardMaterial3D" id="t172_screen_mat"]
shading_mode = 0
albedo_color = Color(0.045,0.095,0.10,1)
texture_filter = 0

[sub_resource type="QuadMesh" id="t172_screen"]
size = Vector2(0.4,0.3)
material = SubResource("t172_screen_mat")

[sub_resource type="BoxMesh" id="t172_button"]
size = Vector3(0.11,0.05,0.035)

[sub_resource type="BoxShape3D" id="t172_stall"]
size = Vector3(1.05,2.4,1.05)

'''+text[index:]
    text += '\n; T172 additions\n'
    for name,position,key,rotation in [('RagSpot',(5.65,.88,-5),'t172_rag',0),('TowelSpot',(2.8,1.80,-8.12),'t172_towel',0),('ShirtSpot',(.3,.87,-1.25),'t172_shirt',-90)]:
        text+=f'\n[node name="{name}" type="Marker3D" parent="."]\nposition = {V(position)}\nrotation_degrees = Vector3(0,{rotation},0)\n\n[node name="Model" parent="{name}" instance=ExtResource("{key}")]\n'
    for number in [1,2,4]:
        text+=f'\n[node name="Gag{number}" type="Marker3D" parent="."]\nscript = ExtResource("t172_gag")\nbody_path = NodePath("../Corpse{number}/Body")\n'
    text+='''
[node name="ShowerScreen" type="Marker3D" parent="."]
position = Vector3(6.18,1.45,-6.78)
metadata/size = Vector2(0.4,0.3)

[node name="Surface" type="MeshInstance3D" parent="ShowerScreen"]
mesh = SubResource("t172_screen")

[node name="ShowerYes" type="Marker3D" parent="."]
position = Vector3(6.07,1.20,-6.76)

[node name="Button" type="MeshInstance3D" parent="ShowerYes"]
mesh = SubResource("t172_button")

[node name="ShowerNo" type="Marker3D" parent="."]
position = Vector3(6.29,1.20,-6.76)

[node name="Button" type="MeshInstance3D" parent="ShowerNo"]
mesh = SubResource("t172_button")

[node name="ShowerStall" type="Area3D" parent="."]
position = Vector3(6.18,1.2,-6.32)
collision_layer = 0
collision_mask = 2
monitorable = false

[node name="Collision" type="CollisionShape3D" parent="ShowerStall"]
shape = SubResource("t172_stall")
'''
    write(path,text)
    path=ROOT/'game/scenes/levels/floor4/room_407.tscn'
    text=path.read_text(encoding='utf-8').split('\n; T172 additions')[0]
    for key,file in [('t172_bath','bathroom_effects'),('t172_zones','zones'),('t172_line','clothesline')]:
        text=resource(text,'PackedScene','scenes/levels/ch2/'+file+'.tscn',key)
    text+='''
; T172 additions
[node name="Ch2Bathroom" parent="." instance=ExtResource("t172_bath")]

[node name="Zones" parent="." instance=ExtResource("t172_zones")]

[node name="Clothesline" parent="." instance=ExtResource("t172_line")]
position = Vector3(2.8,1.8,-8.12)
'''
    write(path,text)
    path=ROOT/'game/scenes/levels/ch1v2/bathroom_door.tscn'
    text=path.read_text(encoding='utf-8').replace('ch1v2/hinged.gd','ch2/bathroom_door.gd').replace('ch1_models/paper.png','ch1_models/wood.png')
    text=re.sub(r'\n; T172 swelling.*', '', text, flags=re.S)
    text+='''
; T172 swelling: layered wood at the wet lower edge.
[node name="SwollenEdge" type="MeshInstance3D" parent="Pivot/Leaf"]
position = Vector3(0,-0.78,0.01)
scale = Vector3(1.018,0.24,1.65)
mesh = SubResource("s3")
'''
    write(path,text)


if __name__ == '__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    old.base.OUT=OUT
    props(); bathroom(); integrate()
    print('T172_BUILD: props, bathroom, zones and room anchors')
