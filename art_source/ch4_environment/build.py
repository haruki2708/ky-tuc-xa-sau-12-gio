"""T-196: deterministic native geometry; never run the legacy campus generator."""
from pathlib import Path
import sys, math, re, json, struct, zlib, random
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'art_source/floor4'))
from build_floor4 import Scene, vec, PALETTE
PALETTE.update(plaster=(.48,.49,.43), cream=(.79,.78,.64), oak=(.30,.23,.16),
               book=(.23,.30,.29), red=(.44,.18,.16), faded_ink=(.52,.32,.26), clean=(.88,.91,.88),
               sheet=(.67,.79,.81), screen=(.13,.29,.28))
OUT = ROOT / 'game/scenes/levels'
COUNTS = {}
ANCHORS = {}

def save(s, path):
    p = OUT / path
    p.parent.mkdir(parents=True, exist_ok=True)
    lines = ['[gd_scene format=3]\n']
    lines += [f'[ext_resource type="{kind}" path="{path}" id="{id}"]' for (path,kind),id in s.ext.items()]
    text = '\n'.join(lines + [''] + s.sub + s.nodes)
    text = re.sub(r'(?<=[(,= -])\.(\d)', r'0.\1', text)
    p.write_text(text, encoding='utf-8', newline='\n')
    COUNTS[path] = sum('type="BoxMesh"' in x for x in s.sub) * 12

def mark(s, name, pos, parent='.'):
    return s.node(name, 'Marker3D', parent, 'position = '+vec(pos))

def nav(s, name, points):
    mesh = s.subresource('NavigationMesh', 'vertices = PackedVector3Array('+','.join(str(round(c,5)) for p in points for c in p)+')\npolygons = [PackedInt32Array(0,1,2,3)]\nagent_radius = 0.3')
    s.node(name, 'NavigationRegion3D', properties='navigation_mesh = '+mesh)

def flat(s, name, x0,x1,z0,z1,y):
    nav(s,name,[(x0,y,z0),(x0,y,z1),(x1,y,z1),(x1,y,z0)])

def link(s, name, a,b):
    s.node(name,'NavigationLink3D',properties='start_position = '+vec(a)+'\nend_position = '+vec(b))

def table(s, name, pos, width=2.4, depth=1.1):
    p=s.node(name,properties='position = '+vec(pos))
    s.box('Top',(0,.78,0),(width,.12,depth),'oak',p)
    for i,(x,z) in enumerate([(-1,-1),(-1,1),(1,-1),(1,1)]):
        s.box('Leg%d'%i,(x*(width/2-.12),.35,z*(depth/2-.12)),(.08,.7,.08),'iron',p,solid=False)
    return p

def chair(s,name,pos,parent='.'):
    p=s.node(name,parent=parent,properties='position = '+vec(pos))
    s.box('Seat',(0,.46,0),(.5,.08,.48),'oak',p,solid=False)
    s.box('Back',(0,.77,.21),(.5,.6,.07),'oak',p,solid=False)
    for i,(x,z) in enumerate([(-1,-1),(-1,1),(1,-1),(1,1)]):
        s.box('Leg%d'%i,(x*.2,.21,z*.18),(.05,.42,.05),'iron',p,solid=False)
    return p

def shelf(s,name,pos):
    p=s.node(name,properties='position = '+vec(pos)+'\nmetadata/triangle_budget = 1500')
    s.box('Back',(0,1.1,.26),(3,2.2,.08),'oak',p)
    for x in [-1.48,1.48]:
        s.box('Side'+str(x),(x,1.1,0),(.08,2.2,.6),'oak',p)
    for row in range(4):
        y=.1+row*.56
        s.box('Shelf%d'%row,(0,y,0),(3,.07,.6),'oak',p)
        for book in range(9):
            s.box('Book%d_%d'%(row,book),(-1.28+book*.31,y+.2,-.03),(.23,.30+(book%3)*.035,.39),['book','red','cream'][book%3],p,solid=False)
    return p

def texture():
    # 128px wood with intentionally illegible ink strokes; no story text.
    p=ROOT/'game/assets/textures/ch4/slat_ink.png'; p.parent.mkdir(parents=True,exist_ok=True)
    rng=random.Random(196)
    pixels=[[[117+rng.randrange(14),91+rng.randrange(12),60+rng.randrange(10)] for x in range(128)] for y in range(128)]
    for row in range(4):
        for char in range(12):
            x0=8+char*9; y0=20+row*24+rng.randrange(6)
            for k in range(16):
                x=x0+rng.randrange(7); y=y0+rng.randrange(9)
                pixels[y][x]=[60,52,39]
    raw=b''.join(b'\0'+bytes(c for px in row for c in px) for row in pixels)
    def chunk(tag,data): return struct.pack('>I',len(data))+tag+data+struct.pack('>I',zlib.crc32(tag+data)&0xffffffff)
    p.write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',128,128,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b''))

def library():
    s=Scene('Library')
    s.nodes[0]+='position = Vector3(45,-9.9,195)\n'
    # A 5m stairwell is left open in both upper floor plates.
    for level in range(3):
        y=level*3.3
        s.box('Floor%d_Main'%level,(17,y-.12,15),(34,.24,30),'tile',floor=True)
        for tag,z,d in [('South',2,4),('North',22,16)]:
            s.box('Floor%d_%s'%(level,tag),(37,y-.12,z),(6,.24,d),'tile',floor=True)
        if level==0: s.box('StairBase',(37,-.12,9),(6,.24,10),'tile',floor=True)
        s.box('West%d'%level,(0,y+1.65,15),(.22,3.3,30),'plaster')
        s.box('East%d'%level,(40,y+1.65,15),(.22,3.3,30),'plaster')
        for tag,z in [('Front',0),('Back',30)]:
            if level==0:
                for side,x,w in [('W',9.5,19),('E',30.5,19)]:
                    s.box(tag+side,(x,1.65,z),(w,3.3,.22),'plaster')
                s.box(tag+'Lintel',(20,2.85,z),(2,.9,.22),'plaster')
            else: s.box(tag+str(level),(20,y+1.65,z),(40,3.3,.22),'plaster')
        for x in [5,13,27,35]:
            for z in [.13,29.87]:
                s.box('Window%d_%d_%s'%(level,x,z),(x,y+1.8,z),(3,1.35,.025),'glass',solid=False)
                s.box('Sill%d_%d_%s'%(level,x,z),(x,y+1.1,z),(3.15,.07,.25),'cream',solid=False)
        for x in [9,25]:
            s.lamp('Light%d_%d'%(level,x),(x,y+2.8,16),energy=.65,radius=16)
        # Navigation follows broad aisles; shelves occupy the side bays.
        flat(s,'Cross%d'%level,1,33,14,18,y)
        link(s,'CrossLink%d'%level,(20,y,13.5),(20,y,15))
        # Overlapping polygons are avoided by splitting the long aisle.
        flat(s,'SouthAisle%d'%level,17,23,1,13.8,y)
        flat(s,'NorthAisle%d'%level,17,23,18.2,29,y)
        link(s,'NorthLink%d'%level,(20,y,17),(20,y,19))
        flat(s,'StairAccess%d'%level,33.2,38.8,14.5,18,y)
        link(s,'StairAccessLink%d'%level,(32,y,16),(34,y,16))
        # Side path returns from the upper landing to the next flight's foot.
        flat(s,'StairSide%d'%level,32,33,1,13.8,y)
        flat(s,'StairFoot%d'%level,33.2,38.8,1,3.5,y)
        link(s,'StairSideLink%d'%level,(32.5,y,13),(32.5,y,15))
        link(s,'StairFootLink%d'%level,(32.5,y,2),(35,y,2))
        for x in [6,12,28]:
            shelf(s,'Shelf%d_%d'%(level,x),(x,y,23 if level!=1 else 7))
        if level==1:
            for x in [8,13,27]:
                p=table(s,'ReadingTable%d'%x,(x,y,21),3,1.4)
                for side in [-1,1]: chair(s,'Chair%d_%d'%(x,side),(x,y,21+side*1.2))
                s.box('Book',(0,.89,0),(.45,.1,.32),'red',p,solid=False)
            flat(s,'ReadingDeskApproach',14.9,16.8,18.2,22,y)
            link(s,'ReadingDeskLink',(16,y,17),(16,y,19))
        if level==0:
            flat(s,'CounterApproach',12.8,16.8,12,13.8,y)
            link(s,'CounterLink',(15,y,13),(15,y,15))
    s.box('Roof',(20,9.95,15),(40,.2,30),'plaster')
    for level in range(2):
        y=level*3.3
        top=[(34,y,4),(34,y+3.3,14),(39,y+3.3,14),(39,y,4)]
        p=s.node('Stairs%d'%level,'StaticBody3D',properties='collision_layer = 1\ncollision_mask = 0')
        shape=s.subresource('ConvexPolygonShape3D','points = PackedVector3Array('+','.join(str(c) for point in top+[(x,y-.2,z) for x,y,z in top] for c in point)+')')
        s.node('Collision','CollisionShape3D',p,'shape = '+shape)
        for i in range(22): s.box('Step%d'%i,(36.5,y+(i+.5)*.15-.08,4+(i+.5)*10/22),(5,.16,10/22+.01),'tile',p,solid=False)
        nav(s,'StairNav%d'%level,[(34.4,y,4),(34.4,y+3.3,14),(38.6,y+3.3,14),(38.6,y,4)])
        link(s,'StairBottom%d'%level,(36,y,3),(36,y,4.1))
        link(s,'StairTop%d'%level,(36,y+3.3,13.9),(36,y+3.3,15))
        # Full-height side guards prevent stepping off the upper flight.
        for x in [34,39]:
            guard=s.box('Rail%d_%d'%(level,x),(x,y+2.4,9),(.08,1,10.53),'iron',solid=False)
            # Guard collision follows the stair slope rather than blocking it.
            s.node('RailCollision%d_%d'%(level,x),'StaticBody3D',properties='collision_layer = 1\ncollision_mask = 0')
            vertices=[(xx,yy+h,zz) for xx in [x-.05,x+.05] for yy,zz in [(y,4),(y+3.3,14)] for h in [0,1.1]]
            shape=s.subresource('ConvexPolygonShape3D','points = PackedVector3Array('+','.join(str(c) for point in vertices for c in point)+')')
            # Visual rail above is tilted to match the climb.
            for idx,n in enumerate(s.nodes):
                if n.startswith('[node name="Rail%d_%d"'%(level,x)): s.nodes[idx]+='rotation_degrees = Vector3(-18.2629,0,0)\n'
            s.node('Shape','CollisionShape3D','RailCollision%d_%d'%(level,x),'shape = '+shape)
    # Furniture closes the front opening permanently.
    s.box('FrontDoor',(20,1.2,0),(1.95,2.4,.12),'oak')
    table(s,'Barricade',(20,0,1),2.6,1.3)
    for i in range(3): chair(s,'BarricadeChair%d'%i,(19.2+i*.8,.85,1))
    p=table(s,'Counter',(12,0,11),5,1.4)
    s.box('Panel',(0,.4,.6),(5,.7,.12),'oak',p)
    s.node('IronBar',parent=p,instance=s.resource('res://scenes/interaction/iron_bar.tscn'),properties='position = Vector3(1,.9,0)')
    chair(s,'LibrarianChair',(12,0,12.5))
    p=s.node('MapBoard',properties='position = Vector3(.15,1.8,16)\nrotation_degrees = Vector3(0,90,0)')
    s.box('Frame',(0,0,0),(3.1,2.1,.08),'oak',p,solid=False)
    s.box('Paper',(0,0,.05),(2.9,1.9,.01),'cream',p,solid=False)
    # North-up diagram: B to the north, A east of B, library southwest.
    for name,x,z,w,d in [('DormB',-.7,.57,.8,.22),('DormA',.6,.45,.7,.28),('Library',-.7,-.55,.5,.35),('Canteen',.8,-.1,.4,.26),('Stadium',.7,-.65,.55,.42)]:
        s.box(name,(x,z,.07),(w,d,.015),'book',p,solid=False)
    for i,x in enumerate([-.7,.6]):
        for j in range(26):
            a=j*math.tau/26; b=(j+1)*math.tau/26
            x0=x+(.51+.008*math.sin(a*7))*math.cos(a); y0=(.57 if i==0 else .45)+.24*math.sin(a)
            x1=x+(.51+.008*math.sin(b*7))*math.cos(b); y1=(.57 if i==0 else .45)+.24*math.sin(b)
            q=s.box('FadedCircle%d_%d'%(i,j),((x0+x1)/2,(y0+y1)/2,.082),(math.hypot(x1-x0,y1-y0),.008+.003*(j%3),.004),'faded_ink',p,solid=False)
            for idx,n in enumerate(s.nodes):
                if n.startswith('[node name="'+q.split('/')[-1]+'"'): s.nodes[idx]+='rotation_degrees = '+vec((0,0,math.degrees(math.atan2(y1-y0,x1-x0))))+'\n'
    door=s.node('BackDoor',properties='position = Vector3(20,0,30)\nscript = '+s.resource('res://scenes/levels/room_door.gd','Script')+'\nroom = &"library_back"')
    s.box('Blocker',(0,1.2,0),(1.94,2.4,.16),'oak',door,visible=False)
    hinge=s.node('Hinge',parent=door,properties='position = Vector3(-.97,0,0)')
    s.box('Leaf',(.97,1.2,0),(1.94,2.4,.1),'oak',hinge,solid=False)
    s.box('Handle',(1.72,1.1,-.09),(.18,.05,.08),'iron',hinge,solid=False)
    flat(s,'DoorThreshold',19.4,20.6,29.2,30.8,0)
    link(s,'DoorInside',(20,0,28.5),(20,0,29.5))
    link(s,'DoorOutside',(20,0,30.5),(20,0,32))
    save(s,'library/library.tscn')

def ch4():
    s=Scene('Ch4')
    positions={'Start_split':(167,-9.9,40.5),'Start_library':(65,-9.9,223),'Start_return':(4,-9.9,2),'Start_407':(32,0.03,-.85),
      'Counter':(58,-9.0,206),'MapBoard':(45.25,-8.1,211),'ReadingDesk':(58,-5.71,216),
      'LibrarianSeat':(57,-9.44,207.5),'ScareShelf3F':(57,-3.3,218),'ThrownBook3F':(73,-1.1,218)}
    for name,pos in positions.items(): mark(s,name,pos); ANCHORS[name]=pos
    s.node('LibraryZombieSpawn')
    for i in range(6):
        pos=(62+(i%3)*3,-9.9,228+(i//3)*3)
        mark(s,'S%02d'%(i+1),pos,'LibraryZombieSpawn'); ANCHORS['LibraryZombieSpawn/S%02d'%(i+1)]=pos
    s.node('StairCrowd')
    for floor in range(1,5):
        for i in range(1 if floor==4 else 3):
            pos=(-4+i*1.5,(floor-4)*3.3,2.8 if i!=1 else 1.4)
            name='L%d_%02d'%(floor,i+1);mark(s,name,pos,'StairCrowd');ANCHORS['StairCrowd/'+name]=pos
    p=s.node('Room407',properties='position = Vector3(30,0,0)')
    for bed,pos in [(1,(.65,1.18,-3)),(2,(.65,.41,-3)),(4,(7.35,1.18,-2.7))]:
        q=mark(s,'Slat%d'%bed,pos,p)
        s.nodes[-1]+='script = '+s.resource('res://scenes/levels/ch4/slat_visual.gd','Script')+'\nbed = %d\n'%bed
        direction=-1 if bed==4 else 1
        hinge=s.node('Hinge',parent=q,properties='position = '+vec((-.43*direction,0,0)))
        s.box('Board',(.43*direction,0,0),(.86,.035,1.45),'oak',hinge,solid=False)
        mat=s.subresource('StandardMaterial3D','albedo_texture = '+s.resource('res://assets/textures/ch4/slat_ink.png','Texture2D')+'\ntexture_filter = 0\ncull_mode = 2')
        mesh=s.subresource('QuadMesh','size = Vector2(.80,1.38)\nmaterial = '+mat)
        s.node('Ink','MeshInstance3D',hinge,'position = '+vec((.43*direction,-.019,0))+'\nrotation_degrees = Vector3(90,0,0)\nmesh = '+mesh)
        ANCHORS['Room407/Slat%d'%bed]=tuple(a+b for a,b in zip(pos,(30,0,0)))
    for name,pos in [('FakeLocker',(.65,1.1,-.45)),('FakeCeiling',(3,2.92,-2)),('FakeVent',(7.8,2.35,-1))]:
        mark(s,name,pos,p);ANCHORS['Room407/'+name]=tuple(a+b for a,b in zip(pos,(30,0,0)))
    s.box('CeilingPanel',(3,2.96,-2),(.8,.035,.8),'cream',p,solid=False)
    s.box('VentFrame',(7.88,2.35,-1),(.04,.45,.65),'iron',p,solid=False)
    for i in range(6): s.box('VentSlat%d'%i,(7.84,2.17+i*.065,-1),(.045,.026,.59),'cream',p,solid=False)
    d=s.node('Door',parent=p,properties='position = Vector3(2.44,.01,0)\nscript = '+s.resource('res://scenes/levels/ch4/door407_proxy.gd','Script'))
    s.box('Blocker',(-.44,1.05,0),(.88,2.1,.08),'oak',d,visible=False)
    damage=s.node('Damage',parent=d)
    for layer in ['Cracks','Hole','Hand']: s.node(layer,parent=damage,properties='visible = false')
    for i in range(7):
        s.box('Crack%d'%i,(-.7+i*.07,.6+i*.14,-.047),(.025,.2,.01),'iron',damage+'/Cracks',solid=False)
    for name,pos,size in [('Left',(-.82,1.05,0),(.12,2.1,.075)),('Right',(-.06,1.05,0),(.12,2.1,.075)),('Top',(-.44,1.64,0),(.64,.92,.075)),('Bottom',(-.44,.32,0),(.64,.64,.075))]:
        s.box(name,pos,size,'oak',damage+'/Hole',solid=False)
    s.box('Forearm',(-.43,.96,-.22),(.16,.17,.55),'skin',damage+'/Hand',solid=False)
    s.box('Palm',(-.43,.96,-.55),(.23,.08,.22),'skin',damage+'/Hand',solid=False)
    for i in range(4): s.box('Finger%d'%i,(-.515+i*.057,.94,-.72),(.039,.06,.20-i*.02),'skin',damage+'/Hand',solid=False)
    save(s,'ch4/ch4_anchors.tscn')

def hospital():
    s=Scene('HospitalRoom')
    s.nodes[0]+='script = '+s.resource('res://scenes/levels/hospital/hospital_room.gd','Script')+'\n'
    s.box('Floor',(0,-.1,0),(5,.2,6),'clean',floor=True)
    s.box('Ceiling',(0,3.1,0),(5,.2,6),'clean')
    for name,pos,size in [('West',(-2.55,1.5,0),(.1,3,6)),('East',(2.55,1.5,0),(.1,3,6)),('HeadWall',(0,1.5,-3),(5,3,.1)),('FootWall',(0,1.5,3),(5,3,.1))]: s.box(name,pos,size,'clean')
    for name,x in [('Trung',0),('Nhat',-1.65),('Ngu',1.65)]:
        p=s.node('Bed_'+name,properties='position = '+vec((x,0,0)))
        s.box('Frame',(0,.42,0),(1.05,.12,2.1),'iron',p)
        s.box('Mattress',(0,.57,0),(.98,.19,2),'clean',p)
        s.box('Pillow',(0,.71,-.76),(.62,.14,.35),'clean',p,solid=False)
        for z in [-1.04,1.04]:
            s.box('End'+str(z),(0,.64,z),(1.08,.1,.05),'sheet',p,solid=False)
            for xleg in [-.48,.48]: s.box('Leg'+str(z)+str(xleg),(xleg,.35,z),(.045,.7,.045),'iron',p,solid=False)
        body=s.node('Patient',parent=p)
        s.box('Blanket',(0,.78,.15),(.67,.23,1.45),'sheet',body,solid=False)
        s.box('Head',(0,.82,-.68),(.25,.25,.28),'cream',body,solid=False)
        mark(s,'Card',(0,.88,1.08),p)
        s.box('Cabinet_'+name,(x,.48,-2),(1,.96,.65),'clean')
        iv=s.node('IV_'+name,properties='position = '+vec((x+.57,0,-.6)))
        s.box('Pole',(0,1.05,0),(.035,2.1,.035),'iron',iv,solid=False)
        s.box('Base',(0,.06,0),(.35,.05,.35),'iron',iv,solid=False)
        s.box('Hook',(0,2.07,0),(.35,.035,.035),'iron',iv,solid=False)
        s.box('Bag',(.12,1.84,0),(.18,.3,.07),'sheet',iv,solid=False)
    s.box('Monitor',(0,1.2,-2),(.7,.42,.18),'iron')
    s.box('Screen',(0,1.21,-1.902),(.61,.31,.01),'screen',solid=False)
    for i in range(10): s.box('Trace%d'%i,(-.25+i*.055,1.2+(.06 if i in [4,6] else 0),-1.891),(.05,.012,.004),'sheet',solid=False)
    mark(s,'MonitorAudio',(0,1.2,-1.85))
    s.box('Window',(2.485,1.9,-.7),(.02,1.6,2.5),'sheet',solid=False)
    s.box('WindowCross',(2.46,1.9,-.7),(.04,1.6,.07),'clean',solid=False)
    mark(s,'Nurse1',(-.72,0,1.9)); mark(s,'Nurse2',(.72,0,1.9))
    s.node('Camera_Wake','Camera3D',properties='position = Vector3(0,.94,-.64)\nrotation_degrees = Vector3(24,180,0)\nfov = 78\ncurrent = true')
    env=s.subresource('Environment','background_mode = 1\nbackground_color = Color(.85,.9,.94,1)\nambient_light_source = 2\nambient_light_color = Color(.94,.97,1,1)\nambient_light_energy = .75\ntonemap_mode = 2')
    s.node('Environment','WorldEnvironment',properties='environment = '+env)
    s.lamp('CeilingLight',(0,2.8,0),energy=1.4,radius=8)
    s.nodes=[n.replace('Color(0.82, 0.90, 0.76, 1)','Color(0.94, 0.97, 1, 1)') for n in s.nodes]
    save(s,'hospital/hospital_room.tscn')

def integrate():
    p=OUT/'campus/shells.tscn';text=p.read_text(encoding='utf-8')
    # Remove only the obsolete Library node subtree; leave all other shells.
    blocks=re.split(r'(?=\[node )',text)
    blocks=[b for b in blocks if not re.match(r'\[node name="Library".*parent="\."',b) and not re.match(r'\[node [^\n]*parent="Library(?:/[^\"]*)?"',b)]
    p.write_text(''.join(blocks),encoding='utf-8',newline='\n')
    p=OUT/'campus/campus.tscn';text=p.read_text(encoding='utf-8')
    if 'id="t196_library"' not in text:
        at=text.index('[sub_resource')
        text=text[:at]+'[ext_resource type="PackedScene" path="res://scenes/levels/library/library.tscn" id="t196_library"]\n[ext_resource type="PackedScene" path="res://scenes/levels/ch4/ch4_anchors.tscn" id="t196_anchors"]\n\n'+text[at:]
        text+='\n[node name="Library" parent="." instance=ExtResource("t196_library")]\n\n[node name="Ch4" parent="Anchors" instance=ExtResource("t196_anchors")]\n'
    p.write_text(text,encoding='utf-8',newline='\n')

def canteen_exit():
    # The approved west exit did not exist in T-192. Replace only Side170.
    s=Scene('WestExit')
    s.box('SouthWall',(170,-7.6,29.75),(.25,4.6,19.5),'wall')
    s.box('NorthWall',(170,-7.6,42.75),(.25,4.6,2.5),'wall')
    s.box('Lintel',(170,-6.4,40.5),(.25,2.2,2),'wall')
    for z in [39.5,41.5]: s.box('Jamb'+str(z),(170,-8.7,z),(.32,2.4,.08),'oak',solid=False)
    flat(s,'Threshold',169,171,40,41,-9.9)
    link(s,'Outside',(167,-9.9,40.5),(169.5,-9.9,40.5))
    link(s,'Inside',(170.5,-9.9,40.5),(172,-9.9,40.5))
    save(s,'ch4/canteen_west_exit.tscn')
    p=OUT/'campus/canteen.tscn'; text=p.read_text(encoding='utf-8')
    blocks=re.split(r'(?=\[node )',text)
    blocks=[b for b in blocks if not re.match(r'\[node name="Side170".*parent="\."',b) and not re.match(r'\[node [^\n]*parent="Side170(?:/[^\"]*)?"',b)]
    text=''.join(blocks)
    if 'id="t196_exit"' not in text:
        at=text.index('[sub_resource')
        text=text[:at]+'[ext_resource type="PackedScene" path="res://scenes/levels/ch4/canteen_west_exit.tscn" id="t196_exit"]\n\n'+text[at:]
        text+='\n[node name="WestExit" parent="." instance=ExtResource("t196_exit")]\n'
    p.write_text(text,encoding='utf-8',newline='\n')

if __name__=='__main__':
    texture();library();ch4();hospital();integrate();canteen_exit()
    (Path(__file__).parent/'manifest.json').write_text(json.dumps({'box_triangles':COUNTS,'world_anchors':ANCHORS},indent=2)+'\n')
