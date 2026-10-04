"""T-154: deterministic native Godot meshes, joint rigs and AnimationLibraries.
Run with portable Blender's bundled Python; stdlib only, no addons.
"""
from pathlib import Path
import sys, math, json, random, struct, zlib
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'art_source/floor4'))
import build_floor4 as base
OUT = ROOT / 'game/scenes/levels/ch1_models'
TEX = ROOT / 'game/assets/textures/ch1_models'
base.OUT = OUT
V = base.vec
PALETTE = {'uniform':(.20,.25,.20), 'skin':(.57,.51,.40), 'hair':(.055,.05,.047),
           'red':(.40,.055,.04), 'stripes':(.43,.48,.45), 'sport':(.055,.07,.085),
           'pants':(.12,.15,.17), 'metal':(.39,.42,.40), 'paper':(.76,.73,.61),
           'blood':(.23,.018,.025), 'foam':(.52,.48,.26), 'wood':(.30,.16,.07),
           'rag':(.28,.33,.29)}


def texture(name, color):
    rng = random.Random(154 + list(PALETTE).index(name))
    raw = bytearray()
    for y in range(128):
        raw.append(0)
        for x in range(128):
            grain = rng.choice([-.04, 0, 0, .025])
            shade = .50 if name == 'stripes' and y % 24 < 9 else 1
            if name in ('uniform', 'sport', 'red', 'rag'):
                grain += .045 if (x * 7 + y * 3) % 71 < 3 else 0
            if name == 'wood':
                grain += .08 if (y + x // 11) % 17 < 2 else 0
            raw.extend(int(max(0, min(1, c * shade + grain)) * 255) for c in color)
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data))
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>2I5B',128,128,8,2,0,0,0))
    (TEX / (name + '.png')).write_bytes(png + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))


class Model(base.Scene):
    def mat(self, name):
        if name not in self.materials:
            shader = self.resource('res://rendering/ps1_surface.gdshader', 'Shader')
            tex = self.resource('res://assets/textures/ch1_models/' + name + '.png', 'Texture2D')
            self.materials[name] = self.subresource('ShaderMaterial', f'shader = {shader}\nshader_parameter/albedo_texture = {tex}\nshader_parameter/roughness = 0.9')
        return self.materials[name]

    def part(self, name, at, size, mat, parent='.', shape='box', extra=''):
        if shape == 'box':
            mesh = self.subresource('BoxMesh', f'size = {V(size)}\nmaterial = {self.mat(mat)}')
        elif shape == 'wedge':
            mesh = self.subresource('PrismMesh', f'size = {V(size)}\nmaterial = {self.mat(mat)}')
        else:
            mesh = self.subresource('CylinderMesh', f'top_radius = {size[0]/2}\nbottom_radius = {size[2]/2}\nheight = {size[1]}\nradial_segments = 6\nrings = 1\nmaterial = {self.mat(mat)}')
        return self.node(name, 'MeshInstance3D', parent, f'position = {V(at)}\nmesh = {mesh}\n' + extra)

    def joint(self, name, at, parent='.', rotation=(0,0,0)):
        return self.node(name, parent=parent, properties=f'position = {V(at)}\nrotation_degrees = {V(rotation)}')

    def script(self, name):
        self.nodes[0] += 'script = ' + self.resource('res://scenes/levels/ch1_models/' + name + '.gd', 'Script') + '\n'

    def animations(self, clips, defaults, autoplay=''):
        resources = {}
        for name, (duration, loop, changes) in clips.items():
            props = f'resource_name = "{name}"\nlength = {duration}\nloop_mode = {1 if loop else 0}'
            for i, (path, default) in enumerate(defaults.items()):
                keys = changes.get(path, [(0, default)])
                values = [str(v).lower() if isinstance(v, bool) else V(v) for t,v in keys]
                props += f'\ntracks/{i}/type = "value"\ntracks/{i}/path = NodePath("{path}")\ntracks/{i}/interp = 1\ntracks/{i}/enabled = true\ntracks/{i}/keys = {{\n"times": PackedFloat32Array({", ".join(str(t) for t,v in keys)}),\n"transitions": PackedFloat32Array({", ".join("1" for _ in keys)}),\n"update": {1 if isinstance(default,bool) else 0},\n"values": [{", ".join(values)}]\n}}'
            resources[name] = self.subresource('Animation', props)
        library = self.subresource('AnimationLibrary', '_data = {\n' + ',\n'.join(f'&"{n}": {r}' for n,r in resources.items()) + '\n}')
        self.node('AnimationPlayer', 'AnimationPlayer', properties=f'libraries = {{\n&"": {library}\n}}\nautoplay = "{autoplay}"')


def humanoid(manager=False, who='phuc'):
    s = Model('ManagerBody' if manager else 'Corpse' + who.title())
    if not manager:
        s.script('corpse_body')
    rig = s.joint('Rig', (0,0,0) if manager else (0,.145,-.82), rotation=(0,0,0) if manager else (90,0,0))
    hips = s.joint('Hips', (0,1.0 if manager else .85,0), rig)
    width = .43 if manager else {'phuc':.39,'viet':.34,'dat':.42}[who]
    shirt = 'uniform' if manager else {'phuc':'red','viet':'stripes','dat':'sport'}[who]
    chest = s.joint('Chest', (0,0,0), hips)
    s.part('Shirt', (0,.265,0), (width,.50,width*.81), shirt, chest, 'cone', 'scale = Vector3(1,1,0.65)')
    s.part('Hem', (0,.03,0), (width*.9,.12,.24), shirt, chest)
    s.part('Neck', (0,.56,0), (.115,.14,.11),'hair' if manager else 'skin',chest,'cone')
    head = s.joint('Head', (0,.63,0), chest)
    s.part('Face', (0,.08,0), (.225,.28,.20),'hair' if manager else 'skin',head,'cone', 'scale = Vector3(1,1,0.90)')
    s.part('Hair', (0,.19,.025), (.235,.13,.195), 'hair', head)
    s.part('Nose', (0,.067,-.10), (.046,.065,.049),'hair' if manager else 'skin',head,'wedge')
    s.part('Mouth', (0,.006,-.094), (.084,.012,.012),'skin' if manager else 'hair',head)
    for side in [-1,1]:
        s.part('Ear' + str(side), (side*.113,.075,0), (.035,.07,.048),'hair' if manager else 'skin',head)
    eyes = s.joint('Eyes', (0,0,0), head)
    for side in [-1,1]:
        s.part('Eye' + str(side), (side*.052,.092,-.093), (.041,.024,.012),'paper',eyes)
        s.part('Pupil' + str(side), (side*.052,.092,-.101), (.017,.026,.005),'hair',eyes)
        s.part('Lid' + str(side), (side*.052,.09,-.102), (.056,.007,.006),'hair',head)
    # Eyes are a separate pose channel. Manager's upper face is deliberately opaque.
    for i, node in enumerate(s.nodes):
        if node.startswith('[node name="Eyes"'):
            s.nodes[i] += 'visible = false\n'
    if manager:
        s.part('FaceShadow', (0,.128,-.109), (.232,.19,.017),'hair',head)
        s.part('Cap', (0,.256,.015), (.275,.066,.23),'uniform',head)
        s.part('CapBrim', (0,.224,-.105), (.29,.018,.19),'hair',head)
        s.part('Belt', (0,.005,0), (.41,.055,.26),'hair',hips)
        s.part('Buckle', (0,.005,-.138), (.058,.049,.013),'metal',hips)
        for side in [-1,1]:
            s.part('Pocket' + str(side), (side*.112,.27,-.133), (.122,.12,.025),'uniform',chest)
            s.part('Collar' + str(side), (side*.067,.477,-.10), (.096,.102,.035),'uniform',chest,'wedge')
        for y in [.15,.26,.37,.46]:
            s.part('Button' + str(y), (0,y,-.14), (.019,.019,.012),'metal',chest)
    if who == 'dat' and not manager:
        for x in [-.16,.16]:
            s.part('SportStripe' + str(x), (x,.26,-.112), (.032,.39,.006),'paper',chest)
    arms, legs = [], []
    for side, label in [(-1,'Left'),(1,'Right')]:
        arm = s.joint(label+'Arm', (side*(width/2+.035),.45,0), chest)
        s.part('Sleeve', (0,-.14,0), (.16,.28,.12),shirt,arm,'cone')
        elbow = s.joint('Elbow',(0,-.28,0),arm)
        s.part('Forearm', (0,-.135,0), (.115,.27,.085),'uniform' if manager else 'skin',elbow,'cone')
        hand = s.joint('Hand',(0,-.30,0),elbow)
        s.part('Fingers', (0,-.035,-.01), (.086,.11,.077),'skin',hand)
        leg = s.joint(label+'Leg',(side*.105,0,0),hips)
        s.part('Trouser', (0,-.23,0), (.21,.46,.16),'pants',leg,'cone')
        knee = s.joint('Knee',(0,-.46,0),leg)
        length = .46 if manager else .31
        s.part('Shin',(0,-length/2,0),(.15,length,.13),'pants',knee,'cone')
        s.part('Foot',(0,-length+.008,-.055),(.17,.15,.29),'hair' if manager else 'skin',knee)
        arms.append(arm); legs.append(leg)
    defaults = {rig+':position':(0,0,0) if manager else (0,.145,-.82), chest+':rotation':(0,0,0), head+':rotation':(0,0,0), eyes+':visible':False}
    for joint in arms+legs:
        defaults[joint+':rotation'] = (0,0,0)
    def rot(deg): return (math.radians(deg),0,0)
    if manager:
        hand = arms[1]+'/Elbow/Hand'
        s.part('Grip', (0,-.09,0),(.055,.23,.06),'wood',hand)
        s.part('Guard', (0,-.19,0),(.15,.035,.075),'metal',hand)
        # Hand at y=.87; blade tip exactly touches y=.015 at rest.
        s.part('LongCleaver', (0,-.515,-.015),(.19,.63,.032),'metal',hand,'wedge')
        s.part('BladeEdge', (-.087,-.505,-.018),(.018,.61,.04),'paper',hand)
        s.node('BladeTip','Marker3D',hand,'position = Vector3(0,-0.855,0)')
        s.node('BladeTip','Marker3D',properties='script = ' + s.resource('res://scenes/levels/ch1_models/blade_tip.gd','Script') + '\nsource = NodePath("../'+hand+'/BladeTip")')
        clips = {'RESET':(.01,False,{}),'stand':(2.4,True,{head+':rotation':[(0,(0,0,-.09)),(1.2,(.035,0,-.12)),(2.4,(0,0,-.09))]}),
            'walk':(1.6,True,{legs[0]+':rotation':[(0,rot(-16)),(.8,rot(16)),(1.6,rot(-16))],legs[1]+':rotation':[(0,rot(16)),(.8,rot(-16)),(1.6,rot(16))],arms[0]+':rotation':[(0,rot(12)),(.8,rot(-12)),(1.6,rot(12))],head+':rotation':[(0,(.07,0,-.08))]}),
            'ask':(2.0,False,{head+':rotation':[(0,(0,0,-.09)),(.55,(.15,-.35,-.23)),(1.55,(.15,-.35,-.23)),(2,(0,0,-.09))]}),
            'slash':(1.2,False,{arms[1]+':rotation':[(0,rot(0)),(.40,rot(155)),(.57,rot(155)),(.77,rot(65)),(1.2,rot(0))],chest+':rotation':[(0,rot(0)),(.4,rot(-10)),(.77,rot(22)),(1.2,rot(0))]}),
            'lunge':(.65,False,{chest+':rotation':[(0,rot(0)),(.25,rot(-24)),(.65,rot(-10))],rig+':position':[(0,(0,0,0)),(.35,(0,-.04,-.36)),(.65,(0,0,-.26))],arms[0]+':rotation':[(0,rot(0)),(.35,rot(65))]}),
            'kill':(.9,False,{arms[1]+':rotation':[(0,rot(150)),(.25,rot(165)),(.46,rot(85)),(.9,rot(0))],chest+':rotation':[(0,rot(-8)),(.46,rot(-25)),(.9,rot(0))]})}
        s.animations(clips, defaults, 'stand')
        s.save('manager_body.tscn')
    else:
        blood = s.joint('Blood',(0,0,0),chest)
        s.part('Stain',(0,.31,-.141),(.14,.12,.006),'blood',blood,'wedge')
        for i,node in enumerate(s.nodes):
            if node.startswith('[node name="Blood"'): s.nodes[i] += 'visible = false\n'
        turn = -1 if who == 'dat' else 1
        hang = arms[0] if who == 'dat' else arms[1]
        changes = {hang+':rotation':[(0,(-1.10,0,turn*.65))]}
        head_turn = {**changes,head+':rotation':[(0,(0,-turn*.90,0))]}
        eyes_open = {**head_turn,eyes+':visible':[(0,True)]}
        s.animations({'RESET':(.01,False,{}),'dead_a':(.01,False,{}),'dead_b':(.01,False,changes),'head_turn':(.01,False,head_turn),'eyes_open':(.01,False,eyes_open),
                      'sit_up':(.01,False,{chest+':rotation':[(0,rot(-75))],eyes+':visible':[(0,True)]})}, defaults)
        s.save('corpse_'+who+'.tscn')


def props():
    s=Model('Charger')
    s.part('Case',(0,.037,0),(.045,.065,.038),'paper')
    for x in [-.011,.011]: s.part('Pin'+str(x),(x,.082,0),(.005,.027,.007),'metal')
    s.part('USBPort',(0,.041,-.020),(.025,.009,.003),'hair')
    s.part('Seam',(0,.015,-.02),(.039,.003,.002),'metal')
    s.save('charger.tscn')
    s=Model('Router'); s.script('router')
    s.part('Case',(0,.032,0),(.21,.064,.135),'paper')
    for x in [-.08,.08]:
        s.part('Antenna'+str(x),(x,.15,.052),(.009,.24,.009),'hair','.', 'cone')
    for i in range(7): s.part('Vent'+str(i),(-.075+i*.025,.065,0),(.012,.002,.07),'hair')
    led = s.subresource('StandardMaterial3D','shading_mode = 0\nalbedo_color = Color(0.1,1,0.24,1)\ntexture_filter = 0')
    mesh=s.subresource('BoxMesh','size = Vector3(0.009,0.007,0.003)\nmaterial = '+led)
    s.node('LED','MeshInstance3D',properties='position = Vector3(-0.07,0.034,-0.069)\nmesh = '+mesh)
    s.save('router.tscn')
    s=Model('DatNotebook'); s.script('dat_notebook')
    s.part('Cover',(0,.008,0),(.20,.016,.28),'sport')
    s.part('Page',(0,.02,0),(.18,.009,.26),'paper')
    for i in range(7): s.part('Binding'+str(i),(-.093,.026,-.11+i*.036),(.026,.005,.009),'metal')
    font=s.resource('res://assets/fonts/be_vietnam_pro_regular.ttf','FontFile')
    for name, z, size in [('Title',-.074,36),('Name',-.012,30),('BirthDate',.056,32)]:
        s.node(name,'Label3D',properties=f'position = Vector3(0,0.026,{z})\nrotation_degrees = Vector3(-90,0,0)\nfont = {font}\nfont_size = {size}\npixel_size = 0.00032\nmodulate = Color(0.04,0.05,0.05,1)\noutline_size = 0\ntexture_filter = 0\nshaded = false\nno_depth_test = false')
    s.save('dat_notebook.tscn')
    s=Model('PhoneViewmodel'); s.script('phone_viewmodel')
    s.part('Case',(0,0,0),(.078,.158,.011),'hair')
    s.part('Frame',(0,0,-.006),(.073,.151,.004),'metal')
    screenmat=s.subresource('StandardMaterial3D','resource_local_to_scene = true\nshading_mode = 0\nalbedo_color = Color(0.035,0.06,0.07,1)\ntexture_filter = 0')
    screen=s.subresource('QuadMesh','size = Vector2(0.064,0.127)\nmaterial = '+screenmat)
    s.node('Screen','MeshInstance3D',properties='position = Vector3(0,0,-0.009)\nrotation_degrees = Vector3(0,180,0)\nmesh = '+screen)
    s.part('Speaker',(0,.07,-.009),(.024,.003,.003),'hair')
    s.part('Button',(0,-.070,-.009),(.012,.004,.003),'hair')
    s.save('phone_viewmodel.tscn')
    s=Model('BedDebris')
    for i in range(9):
        angle=i*2.4
        s.part('Scrap'+str(i),(math.cos(angle)*.18,.015+(i%3)*.01,math.sin(angle)*.21),(.08+(i%3)*.026,.025,.045),['foam','wood','stripes'][i%3],shape='wedge',extra='rotation_degrees = '+V((0,i*31,8)))
    s.save('bed_debris.tscn')
    s=Model('Rag')
    for i in range(5): s.part('Fold'+str(i),((i-2)*.042,.013+(i%2)*.008,0),(.05,.026,.19),'rag',shape='wedge',extra='rotation_degrees = '+V((0,4*i,0)))
    s.save('rag.tscn')


def integrate():
    # Preserve all legacy paths; use authored anchor instances and hide old placeholders.
    path=ROOT/'game/scenes/levels/room407/room407_anchors.tscn'
    text=path.read_text(encoding='utf-8')
    additions=[]
    for who,number in [('phuc',1),('viet',2),('dat',4)]:
        resource=f'[ext_resource type="PackedScene" path="res://scenes/levels/ch1_models/corpse_{who}.tscn" id="t154_{who}"]'
        if resource not in text: text=text.replace('[sub_resource',resource+'\n\n[sub_resource',1)
        additions.append(f'[node name="Body" parent="Corpse{number}" instance=ExtResource("t154_{who}")]\n')
    for name in ['router','dat_notebook','charger']:
        resource=f'[ext_resource type="PackedScene" path="res://scenes/levels/ch1_models/{name}.tscn" id="t154_{name}"]'
        if resource not in text: text=text.replace('[sub_resource',resource+'\n\n[sub_resource',1)
    additions += ['[node name="Model" parent="Router" instance=ExtResource("t154_router")]\nrotation_degrees = Vector3(0,-90,0)\n',
                  '[node name="Model" parent="DatNote" instance=ExtResource("t154_dat_notebook")]\nposition = Vector3(0,-0.027,0)\n',
                  '[node name="Charger" parent="DatLocker" instance=ExtResource("t154_charger")]\nposition = Vector3(0,-0.30,-0.28)\n']
    for a in additions:
        if a.split('\n')[0] not in text: text += '\n'+a
    path.write_text(text.rstrip()+'\n',encoding='utf-8',newline='\n')
    path=ROOT/'game/scenes/levels/floor4/room_407.tscn'
    text=path.read_text(encoding='utf-8')
    for who,bunk in [('Phuc','A'),('Viet','A'),('Dat','B')]:
        header=f'[node name="Sleeper_{who}" type="MeshInstance3D" parent="Bunk{bunk}"]'
        if header+'\nvisible = false' not in text: text=text.replace(header,header+'\nvisible = false')
    path.write_text(text,encoding='utf-8',newline='\n')
    path=ROOT/'game/scenes/levels/room407/room407_details.tscn'
    text=path.read_text(encoding='utf-8')
    import re
    for name in ['Router','Notebook']:
        text=re.sub(r'(\[node name="'+name+r'"[^\n]*\]\n)(?!visible = false)',r'\1visible = false\n',text)
    for name,node,parent,pos in [('bed_debris','RichDebris','Debris',(3.02,.018,-2.18)),('rag','CleaningRag','.',(1.22,.016,-4.30))]:
        resource=f'[ext_resource type="PackedScene" path="res://scenes/levels/ch1_models/{name}.tscn" id="t154_{name}"]'
        if resource not in text: text=text.replace('[sub_resource',resource+'\n\n[sub_resource',1)
        header=f'[node name="{node}" parent="{parent}" instance=ExtResource("t154_{name}")]'
        if header not in text: text+='\n'+header+'\nposition = '+V(pos)+'\n'
    path.write_text(text,encoding='utf-8',newline='\n')


if __name__ == '__main__':
    OUT.mkdir(parents=True,exist_ok=True); TEX.mkdir(parents=True,exist_ok=True)
    for name,color in PALETTE.items(): texture(name,color)
    humanoid(True)
    for who in ['phuc','viet','dat']: humanoid(False,who)
    props(); integrate()
    print('CH1_MODELS_BUILD: 10 native scenes, 13 textures')
