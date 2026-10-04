"""D-041 room expansion and T-162 mission props. Python stdlib, native Godot scenes."""
from pathlib import Path
import sys,re,math
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'art_source/ch1_models'))
import build_models as old
M,V=old.Model,old.V
OUT=ROOT/'game/scenes/levels/ch1v2'
old.base.OUT=OUT


def script(s,name):
    s.nodes[0]+='script = '+s.resource('res://scenes/levels/ch1v2/'+name+'.gd','Script')+'\n'


def anchor(s):
    s.nodes[0]=s.nodes[0].replace('type="Node3D"','type="Marker3D"')


def solid(s,name,at,size,mat='uniform',parent='.',floor=False):
    path=s.node(name,'StaticBody3D',parent,'position = '+V(at)+'\ncollision_layer = 1\ncollision_mask = 0'+ ('\nmetadata/surface = &"tile"\nmetadata/is_floor = true' if floor else ''))
    shape=s.subresource('BoxShape3D','size = '+V(size))
    s.node('Collision','CollisionShape3D',path,'shape = '+shape)
    s.part('Mesh',(0,0,0),size,mat,path)
    return path


def inst(s,name,file,at=(0,0,0),parent='.',rotation=(0,0,0),extra=''):
    return s.node(name,parent=parent,instance=s.resource(file),properties='position = '+V(at)+'\nrotation_degrees = '+V(rotation)+'\n'+extra)


def marker(s,name,at,parent='.'):
    return s.node(name,'Marker3D',parent,'position = '+V(at))


def props():
    s=M('PowerStrip'); anchor(s); script(s,'power_strip')
    s.part('Case',(0,.035,0),(.43,.07,.16),'paper')
    led=s.subresource('StandardMaterial3D','shading_mode = 0\nalbedo_color = Color(0.95,0.19,0.025,1)')
    for i in range(1,4):
        p=marker(s,'Switch%d'%i,((i-2)*.135,.075,0))
        s.joint('Rocker',(0,0,-.035),p)
        s.part('Button',(0,0,0),(.067,.017,.045),'hair',p+'/Rocker')
        mesh=s.subresource('BoxMesh','size = Vector3(0.042,0.005,0.018)\nmaterial = '+led)
        s.node('LED','MeshInstance3D',p,'position = Vector3(0,0.011,-0.035)\nmesh = '+mesh)
        for x in [-.013,.013]: s.part('Socket'+str(x),(x,0,.035),(.007,.002,.02),'hair',p)
        s.node('WornNumber','Label3D',p,'position = Vector3(0,0.002,0.063)\nrotation_degrees = Vector3(-90,0,0)\ntext = "'+str(i)+'"\nfont_size = 22\npixel_size = 0.001\nmodulate = Color(0.35,0.32,0.27,0.48)\noutline_size = 0\ntexture_filter = 0')
    s.part('RedPaint',(0,.081,-.063),(.035,.004,.022),'red')
    s.part('RouterPlug',(0,.098,.032),(.051,.034,.042),'hair')
    s.part('RedTape',(0,.12,.032),(.053,.012,.044),'red')
    s.node('Sparks',properties='visible = false')
    glow=s.subresource('StandardMaterial3D','shading_mode = 0\nalbedo_color = Color(1,0.75,0.20,1)')
    for i in range(7):
        mesh=s.subresource('PrismMesh','size = Vector3(0.008,0.055,0.008)\nmaterial = '+glow)
        s.node('Spark%d'%i,'MeshInstance3D','Sparks','position = '+V((.14+(i%3)*.02,.12+i*.012,-.01))+'\nrotation_degrees = '+V((i*29,0,i*47))+'\nmesh = '+mesh)
    s.node('Flash','OmniLight3D','Sparks','position = Vector3(0.15,0.2,0)\nlight_color = Color(1,0.45,0.1,1)\nlight_energy = 0.7\nomni_range = 0.7')
    s.save('power_strip.tscn')
    s=M('VietLocker'); anchor(s); script(s,'hinged')
    for n,p,z in [('Back',(0,.85,.22),(.60,1.7,.035)),('West',(-.29,.85,0),(.035,1.7,.45)),('East',(.29,.85,0),(.035,1.7,.45))]:solid(s,n,p,z)
    for y in [.08,.82,1.69]:solid(s,'Shelf'+str(y),(0,y,0),(.57,.035,.44))
    s.joint('Pivot',(-.3,0,-.24))
    solid(s,'Door',(.3,.85,0),(.60,1.7,.035),'uniform','Pivot')
    s.part('Handle',(.51,.88,-.03),(.025,.15,.025),'metal','Pivot')
    inst(s,'Paper1','res://scenes/levels/ch1v2/torn_paper.tscn',(0,.844,0),extra='fragment_id = 1')
    s.save('viet_locker.tscn')
    s=M('PhucMattress'); anchor(s); script(s,'mattress')
    s.joint('Pivot',(-.40,0,0))
    s.part('Mattress',(.40,.018,0),(.8,.06,1.90),'paper','Pivot')
    inst(s,'Paper2','res://scenes/levels/ch1v2/torn_paper.tscn',(0,-.025,-.1),extra='fragment_id = 2')
    s.save('phuc_mattress.tscn')
    s=M('BunkAFrame')
    for x in [-.43,.43]:
        for z in [-.98,.98]:solid(s,'Post%s%s'%(x,z),(x,.85,z),(.04,1.7,.04),'metal')
    for y in [.36,1.14]:solid(s,'Board'+str(y),(0,y,0),(.87,.06,1.98),'wood')
    s.part('LowerMattress',(0,.405,0),(.8,.05,1.9),'paper')
    s.part('LowerPillow',(0,.475,.7),(.54,.06,.3),'stripes')
    s.part('UpperPillow',(0,1.26,.7),(.54,.06,.3),'stripes')
    s.save('bunk_a_frame.tscn')
    s=M('TrashBin'); anchor(s)
    s.part('Base',(0,.02,0),(.27,.035,.27),'hair',shape='cone')
    for i in range(10):
        a=i*math.tau/10
        s.part('Slat%d'%i,(math.cos(a)*.13,.16,math.sin(a)*.13),(.014,.30,.035),'metal',extra='rotation_degrees = '+V((0,-i*36,0)))
    for i in range(3):s.part('Waste%d'%i,((i-1)*.04,.08,0),(.07,.025,.10),'paper',shape='wedge')
    inst(s,'Paper3','res://scenes/levels/ch1v2/torn_paper.tscn',(0,.13,0),extra='fragment_id = 3')
    s.save('trash_bin.tscn')
    s=M('TornPaper'); anchor(s); script(s,'torn_paper')
    s.node('Mesh','MeshInstance3D')
    marker(s,'ReadSurface',(0,.005,0))
    s.save('torn_paper.tscn')
    s=M('TeamPhoto'); anchor(s)
    s.part('Frame',(0,.15,0),(.34,.3,.035),'wood')
    s.part('Photo',(0,.15,-.02),(.30,.26,.004),'paper')
    for i,mat in [(-1,'red'),(1,'sport')]:
        s.part('Jersey'+str(i),(i*.066,.132,-.024),(.092,.13,.003),mat)
        s.part('Head'+str(i),(i*.066,.223,-.027),(.052,.058,.004),'skin')
    s.part('ArmOverShoulder',(-.012,.185,-.03),(.168,.022,.004),'skin')
    marker(s,'BackText',(0,.15,.021))
    s.save('team_photo.tscn')
    s=M('GuitarSongbook'); anchor(s)
    inst(s,'Book','res://scenes/levels/ch1_models/dat_notebook.tscn')
    for i in range(6):s.part('ChordString%d'%i,(-.044+i*.018,.027,-.04),(.002,.001,.08),'hair')
    for i in range(4):s.part('ChordFret%d'%i,(0,.027,-.08+i*.025),(.095,.001,.002),'hair')
    marker(s,'CodeSheet',(0,.03,.08))
    s.save('guitar_songbook.tscn')
    s=M('PhucCard'); anchor(s)
    s.part('Card',(0,0,0),(.09,.002,.06),'paper')
    s.part('Photo',(-.026,.002,0),(.024,.002,.033),'red')
    s.part('Head',(-.026,.003,-.012),(.012,.002,.01),'skin')
    marker(s,'ReadSurface',(.015,.003,0))
    s.save('phuc_card.tscn')
    s=M('BathroomDoor'); anchor(s); script(s,'hinged')
    s.joint('Pivot',(0,0,0));solid(s,'Leaf',(.49,1.02,0),(.98,2.04,.035),'paper','Pivot')
    s.part('Handle',(.84,1.0,.045),(.12,.025,.03),'metal','Pivot')
    s.save('bathroom_door.tscn')


def extension():
    s=M('Extension')
    # The enlarged main floor is in Room407; only balcony adds another floor.
    solid(s,'FloorBalcony',(2.6,-.1,-7.75),(5.2,.2,1.5),'paper',floor=True)
    for n,p,z in [('BalconyWest',(0,1,-7.75),(.12,2,1.5)),('BalconyEast',(5.2,1,-7.75),(.12,2,1.5)),('BalconyRail',(2.6,.55,-8.5),(5.2,1.1,.10))]:
        solid(s,n,p,z,'uniform')
    for n,p,z in [('BackWest',(1.15,1.5,-7),(2.3,3,.15)),('BackEast',(4.25,1.5,-7),(1.9,3,.15)),('BalconyLintel',(2.8,2.65,-7),(1.0,.7,.15)),('BathroomBack',(6.65,1.5,-7),(2.7,3,.15)),('BathroomSide',(5.3,1.5,-5.5),(.15,3,3)),('BathFrontW',(5.825,1.5,-4),(1.05,3,.15)),('BathFrontE',(7.675,1.5,-4),(.65,3,.15)),('BathLintel',(6.85,2.6,-4),(1,0.8,.15))]:
        solid(s,n,p,z,'paper')
    inst(s,'BathroomDoor','res://scenes/levels/ch1v2/bathroom_door.tscn',(6.35,0,-4))
    # Shower, toilet and basin; no gameplay or temperature logic.
    s.part('ToiletBase',(7.38,.22,-6.5),(.40,.44,.55),'paper',shape='cone')
    s.part('ToiletSeat',(7.38,.45,-6.45),(.44,.07,.56),'paper',shape='cone')
    s.part('BowlOpening',(7.38,.49,-6.43),(.28,.012,.36),'hair',shape='cone')
    s.part('Cistern',(7.38,.70,-6.83),(.45,.48,.20),'paper')
    solid(s,'ToiletCollision',(7.38,.40,-6.57),(.5,.8,.72),'paper')
    # Hide simple collision envelope mesh; visible toilet remains separate.
    s.nodes[-1]+='visible = false\n'
    inst(s,'Basin','res://assets/models/props/sink.glb',(5.65,0,-5.0),rotation=(0,180,0))
    s.part('Mirror',(5.4,1.55,-5.0),(.025,.65,.5),'metal')
    s.part('ShowerPipe',(6.18,1.42,-6.86),(.022,1.65,.022),'metal')
    s.part('ShowerHead',(6.18,2.2,-6.65),(.19,.035,.24),'metal',shape='cone')
    s.part('ShowerMixer',(6.18,1.05,-6.81),(.20,.035,.04),'metal')
    marker(s,'Shower',(6.18,1.05,-6.7))
    inst(s,'Bucket','res://assets/models/props/bucket.glb',(5.65,0,-6.45))
    # Three extra desks plus Trung's original desk make four workstations.
    for n,p,r in [('PhucDesk',(.50,0,-5.8),(0,90,0)),('VietDesk',(4.55,0,-.65),(0,180,0)),('DatDesk',(4.2,0,-5.9),(0,0,0))]:
        inst(s,n,'res://assets/models/props/desk.glb',p,rotation=r)
        solid(s,n+'Collision',(p[0],.38,p[2]),(.65,.76,1.5) if r[1]==90 else (1.5,.76,.65),'wood')
        s.nodes[-1]+='visible = false\n'
    for n,p in [('MiniFridge',(4.95,.42,-3.30)),('Bookshelf',(4.20,.72,-6.7))]:
        solid(s,n,p,(.58,.84,.58) if n=='MiniFridge' else (1.3,1.44,.28),'paper' if n=='MiniFridge' else 'wood')
    s.part('FridgeHandle',(4.65,.52,-3.08),(.025,.23,.035),'metal')
    for i in range(8):s.part('Book%d'%i,(3.7+i*.13,1.10,-6.5),(.065,.31,.13),'red' if i%2 else 'sport')
    s.part('RiceCooker',(4.95,.99,-3.3),(.38,.28,.38),'paper',shape='cone')
    s.part('CookerLid',(4.95,1.145,-3.3),(.39,.035,.39),'metal',shape='cone')
    s.part('CookerGrip',(4.95,1.18,-3.3),(.11,.04,.03),'hair')
    s.part('Kettle',(5.05,.94,-.65),(.19,.28,.23),'metal',shape='cone')
    s.part('KettleHandle',(5.19,.97,-.65),(.045,.18,.055),'hair')
    s.part('KettleSpout',(4.93,1.04,-.65),(.11,.06,.07),'metal',shape='wedge')
    for y in [.08,.27,.46]:s.part('ShoeRack'+str(y),(5.9,y,-.4),(.65,.035,.30),'wood')
    inst(s,'Shoes','res://assets/models/room407/trainers.glb',(5.9,.30,-.4))
    inst(s,'SpareBag','res://assets/models/room407/backpack.glb',(4.1,.0,-5.0))
    s.part('StandingFanBase',(4.5,.03,-4.35),(.34,.06,.34),'hair',shape='cone')
    s.part('StandingFanPole',(4.5,.58,-4.35),(.035,1.1,.035),'metal')
    s.part('FanGuard',(4.5,1.16,-4.35),(.44,.025,.44),'metal',shape='cone',extra='rotation_degrees = Vector3(90,0,0)')
    for i in range(3):s.part('FanBlade%d'%i,(4.5,1.16,-4.38),(.32,.045,.015),'paper',extra='rotation_degrees = '+V((0,0,i*60)))
    # Balcony laundry, plants, extra snacks and mirror.
    s.part('Clothesline',(2.6,2.15,-7.85),(4.9,.009,.009),'hair')
    for i in range(3):inst(s,'BalconyShirt%d'%i,'res://assets/models/props/shirt.glb',(1+i*1.2,1.9,-7.85))
    for x in [.45,4.75]:
        s.part('Pot'+str(x),(x,.16,-8.12),(.30,.32,.24),'red',shape='cone')
        for j in range(3):s.part('Leaf%s%s'%(x,j),(x+(j-1)*.09,.48,-8.12),(.10,.39,.02),'uniform',shape='wedge',extra='rotation_degrees = '+V((0,j*60,j*20-20)))
    inst(s,'Snacks','res://assets/models/room407/noodles.glb',(.5,.79,-5.8))
    s.part('FullMirror',(7.86,1.35,-3.40),(.015,.9,.46),'metal')
    s.node('BathLight','OmniLight3D',properties='position = Vector3(6.6,2.5,-5.5)\nlight_color = Color(0.5,0.62,0.56,1)\nlight_energy = 0.3\nomni_range = 2.8')
    s.save('extension.tscn')
    s=M('Cables');script(s,'cables');s.save('cables.tscn')


def setprop(text,name,key,value,parent=None):
    pattern=r'(\[node name="'+re.escape(name)+r'"'+(r'[^\n]*parent="'+re.escape(parent)+r'"' if parent else r'[^\n]*')+r'[^\n]*\]\n)([^\[]*)'
    def replace(m):
        body=m[2]
        body=re.sub(r'^'+re.escape(key)+r' = .*\n','',body,flags=re.M)
        return m[1]+key+' = '+value+'\n'+body
    return re.sub(pattern,replace,text)


def addresource(text,id,file,kind='PackedScene'):
    if 'id="'+id+'"' not in text:
        at=text.index('[sub_resource')
        text=text[:at]+f'[ext_resource type="{kind}" path="{file}" id="{id}"]\n\n'+text[at:]
    return text


def write(path,text):path.write_text(text.rstrip()+'\n',encoding='utf-8',newline='\n')


def patch():
    path=ROOT/'game/scenes/levels/floor4/room_407.tscn';text=path.read_text(encoding='utf-8')
    text=text.replace('res://assets/models/kit/bunk_bed.glb','res://scenes/levels/ch1v2/bunk_a_frame.tscn')
    for name,pos in {'Floor':(4,-.1,-3.5),'Ceiling':(4,3.075,-3.5),'WestWall':(0,1.5,-3.5),'EastWall':(8,1.5,-3.5),'BunkB':(7.35,0,-2.7),'Locker_Dat':(7.7,0,-.45),'Locker_Trung':(7.7,0,-1.25),'WindowBlue':(2.8,2.1,-6.9),'ReverbZone':(4,1.5,-3.5),'AmbientZone':(4,1.5,-3.5)}.items():text=setprop(text,name,'position',V(pos),'.')
    for id,size in [('s1',(8,.2,7)),('s3',(8,.2,7)),('s4',(.2,3,7)),('s6',(.2,3,7)),('s7',(.2,3,7)),('s8',(.2,3,7)),('s9',(8,.15,7)),('s10',(8,.15,7)),('s37',(7.8,3,6.9))]:
        text=re.sub(r'(\[sub_resource[^\n]*id="'+id+r'"\]\n)size = [^\n]*',r'\g<1>size = '+V(size),text)
    # Remove old window wall/collision that would cut the enlarged floor in half.
    text=re.sub(r'\[node name="(?:WindowPier_[^"]+|WindowSill|WindowLintel|WindowBarrier|WindowBar_[^"]+)"[^\n]*\]\n[^\[]*','',text)
    text=re.sub(r'\[node [^\n]*parent="(?:WindowPier_[^"]+|WindowSill|WindowLintel|WindowBarrier|WindowBar_[^"]+)"[^\n]*\]\n[^\[]*','',text)
    text=setprop(text,'Locker_Viet','visible','false','.')
    # Remove the opaque old locker collider by replacing the instance with an empty legacy marker.
    text=text.replace('[node name="Locker_Viet" parent="." instance=ExtResource("e4")]','[node name="Locker_Viet" type="Node3D" parent="."]')
    for id,file in [('v2_ext','extension'),('v2_cables','cables')]:text=addresource(text,id,'res://scenes/levels/ch1v2/'+file+'.tscn')
    if '[node name="Extension"' not in text:
        text+='\n[node name="Extension" parent="." instance=ExtResource("v2_ext")]\n\n[node name="Cables" parent="." instance=ExtResource("v2_cables")]\n'
    if 'id="v2_bounds"' not in text:
        index=text.index('[node name="Room407"')
        text=text[:index]+'[sub_resource type="BoxShape3D" id="v2_bounds"]\nsize = Vector3(8,3.2,7)\n\n[sub_resource type="BoxShape3D" id="v2_balcony"]\nsize = Vector3(5.2,3.2,1.5)\n\n'+text[index:]
        text+='\n[node name="Bounds" type="Area3D" parent="."]\ncollision_layer = 0\ncollision_mask = 2\n\n[node name="Main" type="CollisionShape3D" parent="Bounds"]\nposition = Vector3(4,1.5,-3.5)\nshape = SubResource("v2_bounds")\n\n[node name="Balcony" type="CollisionShape3D" parent="Bounds"]\nposition = Vector3(2.6,1.5,-7.75)\nshape = SubResource("v2_balcony")\n'
    # Authored corridor mesh: door -> central aisle -> approach in front of Trung's bed.
    if 'id="v2_nav"' not in text:
        nav='[sub_resource type="NavigationMesh" id="v2_nav"]\n\n'
        at=text.index('[node name="Room407"');text=text[:at]+nav+text[at:]
        text+='\n[node name="ManagerNavigation" type="NavigationRegion3D" parent="."]\nnavigation_mesh = SubResource("v2_nav")\n'
    nav='[sub_resource type="NavigationMesh" id="v2_nav"]\nvertices = PackedVector3Array(1.5,0.03,0.3, 2.5,0.03,0.3, 2.5,0.03,-1.6, 1.5,0.03,-1.6, 2.5,0.03,-2.5, 1.5,0.03,-2.5, 5.7,0.03,-1.6, 5.7,0.03,-2.5, 6.5,0.03,-1.6, 6.5,0.03,-2.5, 5.7,0.03,-3.5, 6.5,0.03,-3.5)\npolygons = [PackedInt32Array(0,1,2,3), PackedInt32Array(3,2,4,5), PackedInt32Array(2,6,7,4), PackedInt32Array(6,8,9,7), PackedInt32Array(7,9,11,10)]\nagent_radius = 0.35\nagent_height = 1.9\n\n'
    text=re.sub(r'\[sub_resource type="NavigationMesh" id="v2_nav"\].*?(?=\[(?:sub_resource|node) )',lambda m:nav,text,flags=re.S)
    write(path,text)
    path=ROOT/'game/scenes/levels/floor4/corridor.tscn';text=path.read_text(encoding='utf-8')
    for name in ['Floor_408','BackWall_408','Ceiling_408']:
        text=re.sub(r'\[node name="'+name+r'"[^\n]*\]\n[^\[]*','',text)
        text=re.sub(r'\[node [^\n]*parent="'+name+r'"[^\n]*\]\n[^\[]*','',text)
    # Retain facade and static locked door; opaque panel makes the former entrance visibly sealed.
    if 'id="v2_seal"' not in text:
        at=text.index('[node name="Corridor"');text=text[:at]+'[sub_resource type="BoxMesh" id="v2_seal"]\nsize = Vector3(0.85,1.7,0.05)\n\n'+text[at:]
        text+='\n[node name="Sealed408" type="MeshInstance3D" parent="."]\nposition = Vector3(36,1.02,0.075)\nmesh = SubResource("v2_seal")\n'
    write(path,text)
    path=ROOT/'game/scenes/levels/room407/room407_anchors.tscn';text=path.read_text(encoding='utf-8')
    positions={'Bunk3':(7.35,.43,-2.7),'Bunk4':(7.35,1.2,-2.7),'Corpse4':(7.35,1.2,-2.7),'DatLocker':(7.41,1.24,-.45),'WallKnock408':(7.88,1.3,-1.65),'Router':(4.6,1.5,-.18),'VietLaptop':(4.45,.91,-.65),'VietPhoto':(4.05,.93,-.60)}
    for name,pos in positions.items():text=setprop(text,name,'position',V(pos))
    text=setprop(text,'Model','rotation_degrees',V((0,0,0)),'Router')
    entries=[('PowerStrip','power_strip',(.95,.02,-2.35),(0,0,0)),('VietLocker','viet_locker',(.3,0,-1.25),(0,-90,0)),('PhucMattress','phuc_mattress',(.65,1.2,-3),(0,0,0)),('TrashBin','trash_bin',(2.9,0,-5.4),(0,0,0)),('TeamPhoto','team_photo',(7.67,1.94,-1.30),(0,90,0)),('GuitarSongbook','guitar_songbook',(4.05,.80,-.85),(0,0,0)),('PhucCard','phuc_card',(.45,2.055,-1.86),(0,0,0))]
    for name,file,pos,rot in entries:
        text=addresource(text,'v2_'+file,'res://scenes/levels/ch1v2/'+file+'.tscn')
        if '[node name="'+name+'"' not in text:text+='\n[node name="'+name+'" parent="." instance=ExtResource("v2_'+file+'") ]\nposition = '+V(pos)+'\nrotation_degrees = '+V(rot)+'\n'
        text=setprop(text,name,'position',V(pos),'.')
        text=setprop(text,name,'rotation_degrees',V(rot),'.')
    for name,pos in {'LanBlueEnd':(4.35,.035,-1.35),'LanGrayEnd':(4.85,.035,-1.30),'LanWallPort':(5.45,.35,-.12),'DeskLampSwitch':(1.80,.83,-4.43),'ManagerApproach':(6.25,.03,-2.55),'BalconyView':(2.8,1.6,-7.8),'BathroomEntry':(6.85,.03,-4.6)}.items():
        if '[node name="'+name+'"' not in text:text+='\n[node name="'+name+'" type="Marker3D" parent="."]\nposition = '+V(pos)+'\n'
        text=setprop(text,name,'position',V(pos),'.')
    write(path,text)
    path=ROOT/'game/scenes/levels/room407/room407_details.tscn';text=path.read_text(encoding='utf-8')
    for name in ['Dat','TrungBedding','TrungPillow','SlashRips','Debris']:
        if name=='TrungPillow':text=setprop(text,name,'position',V((7.35,.475,-2.0)),'.')
        else:text=setprop(text,name,'position',V((4,0,.3)),'.')
    text=setprop(text,'Blanket4','position',V((7.35,1.43,-2.68)),'.')
    for name,pos in {'BlanketStain4':(7.35,1.515,-2.68),'HangingStain4':(7.01,1.345,-2.5),'Droplet4':(6.985,1.265,-2.5),'SmallStain4':(7.01,.013,-2.5),'Pool4':(6.93,.009,-3.05)}.items():text=setprop(text,name,'position',V(pos))
    text=setprop(text,'OldLaptop','position',V((4.45,.79,-.65)),'Viet');text=setprop(text,'OldLaptop','rotation_degrees',V((0,0,0)),'Viet')
    text=setprop(text,'FamilyPhoto','position',V((4.05,.79,-.4)),'Viet');text=setprop(text,'FamilyPhoto','rotation_degrees',V((0,0,0)),'Viet')
    text=setprop(text,'Guitar','position',V((3.65,.06,-.75)),'Viet')
    text=setprop(text,'RouterShelf','position',V((4.6,1.48,-.18)),'.')
    write(path,text)
    path=ROOT/'game/scenes/levels/floor4/floor4.tscn';text=path.read_text(encoding='utf-8')
    for name,pos in {'Bed_Trung':(37.35,.43,-2.7),'Bed_Dat':(37.35,1.2,-2.7),'Phone_Trung':(37.35,.46,-2.15),'Locker_Trung':(37.7,0,-1.25)}.items():text=setprop(text,name,'position',V(pos),'Anchors')
    if 'id="v2_handle"' not in text:
        at=text.index('[node name="Floor4"');text=text[:at]+'[sub_resource type="BoxMesh" id="v2_handle"]\nsize = Vector3(0.16,0.035,0.04)\n\n'+text[at:]
        text+='\n[node name="HandlePivot" type="Node3D" parent="Door407/Pivot"]\nposition = Vector3(-0.73,1.055,-0.067)\n\n[node name="Grip" type="MeshInstance3D" parent="Door407/Pivot/HandlePivot"]\nposition = Vector3(0.04,0,0)\nmesh = SubResource("v2_handle")\n'
    write(path,text)


if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    props();extension();patch()
    print('T162_BUILD: room 8x7, bathroom, balcony, mission props and anchors')
