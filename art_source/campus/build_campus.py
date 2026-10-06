"""T-183 campus. Native Godot scenes, deterministic stdlib-only generation.
The legacy Floor4 and Room407 files are never written by this generator.
"""
from pathlib import Path
import sys, math, json, re
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'art_source/floor4'))
import build_floor4 as base
OUT = ROOT/'game/scenes/levels/campus'
G = -9.9
HALL_WIDTH = 4.0
V = base.vec
DETAIL = '--detail' in sys.argv
NAV = []
LINKS = []
BLOCKS = []
ANCHORS = {}
base.PALETTE.update(grass=(.13,.20,.13),track=(.32,.13,.10),concrete=(.38,.39,.35),red=(.40,.055,.04))


class Scene(base.Scene):
    vec = staticmethod(V)

    def save(self,filename,connections=''):
        super().save(filename,connections)
        path=OUT/filename
        # Godot resource text requires a leading zero on decimal literals.
        path.write_text(re.sub(r'(?<![\w./])(-?)\.(\d)',r'\g<1>0.\2',path.read_text(encoding='utf-8')),encoding='utf-8',newline='\n')

    def material(self,name):
        if not DETAIL: return super().material(name)
        if name not in self.materials:
            texture=self.resource('res://assets/textures/campus/'+name+'.png','Texture2D')
            self.materials[name]=self.subresource('StandardMaterial3D','albedo_texture = '+texture+'\ntexture_filter = 0\nroughness = .9\nuv1_triplanar = true\nuv1_world_triplanar = true\nuv1_scale = Vector3(.5,.5,.5)')
        return self.materials[name]
    def box(self, name, pos, size, material='wall', parent='.', solid=True, floor=False, visible=True):
        path=super().box(name,pos,size,material,parent,solid,floor,visible)
        return path

    def inst(self,name,file,pos=(0,0,0),parent='.',extra=''):
        return self.node(name,parent=parent,instance=self.resource('res://'+file),properties='position = '+V(pos)+'\n'+extra)


def quad(name, points):
    NAV.append((name,points))


def flat(name,x0,x1,z0,z1,y):
    quad(name,[(x0,y,z0),(x0,y,z1),(x1,y,z1),(x1,y,z0)])


def link(name,a,b,extra=''):
    LINKS.append((name,a,b,extra))


def anchor(name,point):
    ANCHORS[name]=point


def obstacle(x,z,w,d):
    BLOCKS.append((x-w/2-.4,x+w/2+.4,z-d/2-.4,z+d/2+.4))


def ramp(s,name,x0,x1,z0,z1,y0,y1,parent='.'):
    # A hidden convex ramp provides smooth capsule movement; treads are visual.
    top=[(x0,y0,z0),(x0,y1,z1),(x1,y1,z1),(x1,y0,z0)]
    points=top+[(x,y-.24,z) for x,y,z in top]
    body=s.node(name,'StaticBody3D',parent,'collision_layer = 1\ncollision_mask = 0\nmetadata/surface = &"tile"')
    shape=s.subresource('ConvexPolygonShape3D','points = PackedVector3Array('+','.join(str(round(n,6)) for p in points for n in p)+')')
    s.node('Collision','CollisionShape3D',body,'shape = '+shape)
    count=max(4,math.ceil(abs(y1-y0)/.15))
    for i in range(count):
        t=(i+.5)/count
        y=y0+(y1-y0)*t
        s.box('Tread%02d'%i,((x0+x1)/2,y-.09,z0+(z1-z0)*t),(x1-x0,.18,abs(z1-z0)/count+.01),'concrete',body,solid=False)
    quad(name,[(x0+.32,y0,z0),(x0+.32,y1,z1),(x1-.32,y1,z1),(x1-.32,y0,z0)])
    return body


def door(s,name,pos,width=1.6,yaw=0):
    p=s.node(name,properties=f'position = {V(pos)}\nrotation_degrees = Vector3(0,{yaw},0)\nscript = '+s.resource('res://scenes/levels/campus/door.gd','Script'))
    leaf=s.box('Leaf',(-width/2,1.2,0),(width,2.4,.12),'iron',p)
    for i,n in enumerate(s.nodes):
        if 'parent="'+leaf+'"' in n:
            s.nodes[i]+='position = '+V((width/2,0,0))+'\n'
    return p


def stairs(s,side,x0):
    p=s.node(side)
    for floor in [1,2,3,4]:
        y=(floor-4)*3.3
        s.box('Landing%d'%floor,(x0+2.5,y-.12,2.0),(5,.24,HALL_WIDTH),'concrete',p,floor=True)
        flat(side+'Landing%d'%floor,x0+.32,x0+4.68,.32,3.68,y)
        if floor<4:
            link(side+'Hall%d'%floor,(x0+(.4 if side=='FireStairs' else 4.6),y,2.0),(43.5 if side=='FireStairs' else .5,y,2.0))
    for upper in [4,3,2]:
        y=(upper-4)*3.3
        if side=='FireStairs' and upper==2:
            s.box('Collapse',(x0+2.5,y+1,-2.1),(5,2,4.2),'concrete',p)
            anchor('Collapse2F',(x0+2.5,y,-1.0))
            continue
        a=side+'Down%dA'%upper
        b=side+'Down%dB'%upper
        ramp(s,a,x0+.12,x0+2.28,0,-4.8,y,y-1.65,p)
        s.box('Turn%d'%upper,(x0+2.5,y-1.77,-5.5),(5,.24,1.4),'concrete',p,floor=True)
        flat(side+'Turn%d'%upper,x0+.32,x0+4.68,-5.85,-4.85,y-1.65)
        ramp(s,b,x0+2.72,x0+4.88,-4.8,0,y-1.65,y-3.3,p)
        link(a+'Top',(x0+1.2,y,.5),(x0+1.2,y-.07,-.2))
        link(a+'Bottom',(x0+1.2,y-1.58,-4.6),(x0+1.2,y-1.65,-5.2))
        link(b+'Top',(x0+3.8,y-1.65,-5.2),(x0+3.8,y-1.72,-4.6))
        link(b+'Bottom',(x0+3.8,y-3.23,-.2),(x0+3.8,y-3.3,.5))
    for x in [x0-.08,x0+5.08]:
        # Leave the landing side open to each existing corridor.
        inner = (side=='MainStairs' and x>x0) or (side=='FireStairs' and x<x0)
        s.box('Wall'+str(x),(x,-4,-3.2 if inner else -1.2),(.16,13.5,6 if inner else 10.0),'wall',p)
    s.box('Back',(x0+2.5,-4,-6.3),(5.2,13.5,.2),'wall',p)
    s.box('FrontRail',(x0+2.5,-4,4.1),(5.2,13.5,.15),'wall',p)
    s.box('UpperRubble',(x0+2.5,4.2,-1.2),(5,2,2.4),'concrete',p)


def building():
    s=Scene('BuildingB')
    for floor in [1,2,3]:
        y=(floor-4)*3.3
        p=s.node('Floor%d'%floor)
        s.box('Slab',(22,y-.12,-1.8),(44,.24,11.6),'tile',p,floor=True)
        s.box('Ceiling',(22,y+3.12,-1.8),(44,.18,11.6),'wall',p)
        s.box('Rail',(22,y+.65,4.02),(44,1.3,.15),'iron',p)
        # Manager window interrupts the ground-floor back wall.
        if floor==1:
            for label,x,w in [('West',1,2),('East',24.65,38.7)]:
                s.box('Back'+label,(x,y+1.5,-7.6),(w,3,.2),'wall',p)
            s.box('WindowSill',(3.65,y+.5,-7.6),(3.3,1,.22),'wall',p)
            s.box('WindowHeader',(3.65,y+2.72,-7.6),(3.3,.56,.22),'wall',p)
        else:
            s.box('Back',(22,y+1.5,-7.6),(44,3,.2),'wall',p)
        s.box('West',(0,y+1.5,-3.8),(.2,3,7.6),'wall',p)
        s.box('East',(44,y+1.5,-3.8),(.2,3,7.6),'wall',p)
        for i in range(8):
            x=2.75+i*5.5
            opening=(floor==2 and i==2) or (floor==1 and i in [0,3])
            for label,xx in [('L',x-1.8),('R',x+1.8)]:
                s.box('Facade%d%s'%(i,label),(xx,y+1.5,0),(1.9,3,.16),'wall',p)
            s.box('Lintel%d'%i,(x,y+2.75,0),(1.7,.5,.16),'wall',p)
            if not opening:
                s.box('Door%d'%i,(x,y+1.2,0),(1.7,2.4,.10),'wood',p)
            # Spawn alcoves open to the hall; actors/core can stage door breaking.
            if i in [1,4,6]:
                s.nodes=[n.replace('collision_layer = 1','collision_layer = 0') if n.startswith('[node name="Door%d"'%i) else n for n in s.nodes]
                s.nodes=[n+'visible = false\n' if n.startswith('[node name="Door%d"'%i) else n for n in s.nodes]
                flat('Alcove%d_%d'%(floor,i),x-.65,x+.65,-2,.9,y)
                link('AlcoveLink%d_%d'%(floor,i),(x,y,-.5),(x,y,1.2))
            if i<7:
                s.box('Partition%d'%i,(x+2.75,y+1.5,-3.8),(.16,3,7.6),'wall',p)
        flat('Hall%d'%floor,.35,43.65,.5,3.55,y)
        if floor==2:
            flat('Room203',11.4,16.1,-2.1,-.4,y)
            flat('Room203Aisle',13.15,14.05,-6.8,-2.1,y)
            link('Room203Link',(13.75,y,-1),(13.75,y,1.2))
            anchor('Room203Door',(13.75,y,0))
            anchor('Extinguisher2F',(20,y+1.1,.25))
    # A free-standing ground-floor lobby lies on the corridor's north face.
    # Its sill window provides the only initially available outdoor route.
    door(s,'MainDoor',(19.25,G,4.1),3)
    s.node('Chains',parent='MainDoor')
    for angle in [-30,30]:
        chain=s.box('Chain'+str(angle),(0,1.1,.1),(2.9,.06,.07),'iron','MainDoor/Chains',solid=False)
        s.nodes[-2]+='rotation_degrees = Vector3(0,0,%d)\n'%angle
    anchor('MainDoor1F',(19.25,G,4.1))
    # Remove only the ground-floor rail segment at the main door; use split rails.
    s.nodes=[n.replace('collision_layer = 1','collision_layer = 0')+'visible = false\n' if n.startswith('[node name="Rail"') and 'parent="Floor1"' in n else n for n in s.nodes]
    s.box('LobbyRailWest',(8.825,G+.65,4.02),(17.65,1.3,.15),'iron')
    s.box('LobbyRailEast',(32.325,G+.65,4.02),(23.35,1.3,.15),'iron')
    flat('ManagerRoom',.6,5.05,-2,-.5,G)
    flat('ManagerApproach',2.8,5.05,-4.5,-2,G)
    link('ManagerEntry',(2.75,G,1.2),(2.75,G,-1))
    ramp(s,'WindowApproach',3.1,4.9,-4.5,-7.2,G,G+1)
    ramp(s,'WindowExit',3.1,4.9,-8.0,-10.7,G+1,G)
    s.box('WindowBridge',(4,G+.9,-7.6),(1.8,.2,.8),'concrete',floor=True)
    flat('WindowSill',3.42,4.58,-8.0,-7.2,G+1)
    link('WindowInside',(4,G,-4),(4,G+.12,-4.82))
    link('WindowCross',(4,G+.93,-7),(4,G+1,-7.5),'metadata/requires_crouch = true')
    link('WindowCrossOut',(4,G+1,-7.7),(4,G+.93,-8.2),'metadata/requires_crouch = true')
    link('WindowOutside',(4,G+.07,-10.5),(4,G,-12))
    anchor('ManagerWindow',(4,G+1,-7.6))
    anchor('ManagerKnife',(1.4,G+.95,-3.2))
    s.prop('ManagerDesk','desk',(1.4,G,-3.2))
    s.box('ManagerDeskBody',(1.4,G+.4,-3.2),(1.5,.8,.7),visible=False)
    stairs(s,'MainStairs',-5)
    stairs(s,'FireStairs',44)
    door(s,'FireDoor',(44,0,2.0),3.8,90)
    link('FireDoorLink',(43.5,0,2.0),(44.5,0,2.0),'enabled = false')
    link('MainStairsHall4',(.5,0,2.0),(-.5,0,2.0))
    link('MainDoorLink',(19.25,G,3.5),(19.25,G,6),'enabled = false')
    flat('Hall4',.35,43.65,1.1,3.55,0)
    link('Room407Link',(32,.03,-.7),(32,0,1.2),'metadata/requires_open_door = true')
    for floor in [5,6]:
        y=(floor-4)*3.3
        s.box('UpperFloor%d'%floor,(22,y+1.5,-1.8),(44,3,11.6),'wall')
        for i in range(11):
            s.box('UpperWindow%d_%d'%(floor,i),(2+i*4,y+1.65,4.02),(1.8,1.5,.06),'glass',solid=False)
    for key,p in {'FireDoor':(44,0,2.0),'FireKey':(39.8,.66,.42),'Clues/Clock4F':(40,2.05,.18),'Clues/CrackStair':(49,-2,-3)}.items():
        anchor(key,p)
    if DETAIL: detail.building(s,sys.modules[__name__])
    s.save('building_b.tscn')
    obstacle(22,-1.8,54,12.6)


def shells():
    s=Scene('Shells')
    specs=[('BuildingA',0,54,44,10,6),('Lecture',-50,180,80,20,5),('Library',45,195,40,30,3),('Gym',-60,90,60,40,1)]
    for name,x,z,w,d,floors in specs:
        p=s.node(name)
        h=3.3*floors if floors>1 else 10
        s.box('Shell',(x+w/2,G+h/2,z+d/2),(w,h,d),'wall',p)
        obstacle(x+w/2,z+d/2,w,d)
        for f in range(floors):
            for i in range(int(w/5)):
                s.box('Window%d_%d'%(f,i),(x+2.5+i*5,G+f*3.3+1.8,z-.11),(2,1.5,.05),'glass',p,solid=False)
        s.box('LockedDoor',(x+w/2,G+1.4,z-.16),(3,2.8,.1),'iron',p,solid=False)
    if DETAIL: detail.shells(s,sys.modules[__name__])
    s.save('shells.tscn')


def garden():
    s=Scene('Garden')
    s.box('Paving',(22,G-.03,28),(44,.06,40),'tile',floor=True)
    for row in range(4):
        for col in range(3):
            x,z=6+col*16,12+row*10
            p=s.box('Bed%d_%d'%(row,col),(x,G+.25,z),(6,.5,4),'concrete')
            s.box('Soil',(0,.28,0),(5.7,.08,3.7),'grass',p,solid=False)
            obstacle(x,z,6,4)
    s.box('NguBench',(22,G+.48,28),(2.4,.18,.7),'concrete')
    obstacle(22,28,2.4,.7)
    anchor('NguBench',(22,G+.57,28))
    anchor('Start_garden',(22,G,8))
    s.box('FallenBunk',(8,G+.45,37),(2,.9,2),'iron')
    obstacle(8,37,2,2)
    if DETAIL: detail.garden(s,sys.modules[__name__])
    s.save('garden.tscn')


def stadium():
    s=Scene('Stadium')
    s.box('TrackBounds',(198,G-.025,166),(176,.05,92),'track',floor=True)
    s.box('Grass',(198,G+.005,166),(100,.01,58),'grass',solid=False)
    for side,x0,z0,width,steps in [('Main',158,216,80,10),('Secondary',168,108,60,4)]:
        p=s.node(side+'Bleachers')
        for i in range(steps):
            s.box('Tier%d'%i,(x0+width/2,G+.3*(i+1)-.09,z0+1.2*i),(width,.18,1.2),'concrete',p)
            flat(side+'Tier%d'%i,x0+.4,x0+width-.4,z0+1.2*i-.25,z0+1.2*i+.25,G+.3*(i+1))
        # Wide continuous access ramp next to the seats, headroom below main stand.
        ramp(s,side+'BleacherRamp',x0-3,x0+.4,z0-1.2,z0+(steps-1)*1.2,G,G+.3*steps)
        for i in range(steps):
            t=(1.2+1.2*i)/(1.2*steps)
            link(side+'RampTier%d'%i,(x0-1.7,G+.3*steps*t,z0+1.2*i),(x0+.6,G+.3*(i+1),z0+1.2*i))
        link(side+'RampGround',(x0-1.7,G,z0-2),(x0-1.7,G+.025,z0-1.1))
        obstacle(x0+width/2,z0+(steps-1)*.6,width,steps*1.2)
    anchor('Clues/SirenSpot',(198,G+3,226.8))
    for side,x,z in [('W',110,166),('E',286,166),('S',198,120),('N',198,212)]:
        for offset in [-4,4]:
            s.box('GatePost'+side+str(offset),(x+(offset if side in ['S','N'] else 0),G+1.8,z+(offset if side in ['W','E'] else 0)),(.35,3.6,.35),'iron')
    s.node('Floodlights',properties='visible = false')
    for i,(x,z) in enumerate([(112,122),(284,122),(112,210),(284,210)]):
        s.box('Pole%d'%i,(x,G+9,z),(.3,18,.3),'iron')
        s.node('Light%d'%i,'OmniLight3D','Floodlights',f'position = {V((x,G+15,z))}\nlight_energy = 12.0\nomni_range = 145.0\nshadow_enabled = false\nlight_color = Color(0.78,0.83,0.72,1)')
    anchor('Start_stadium',(115,G,166))
    if DETAIL: detail.stadium(s,sys.modules[__name__])
    s.save('stadium.tscn')


def gate():
    s=Scene('Gate')
    s.box('Court',(220,G-.02,-40),(60,.04,40),'concrete',floor=True)
    for x in [209,231]:
        p=s.box('Pillar'+str(x),(x,G+3,-59),(1.4,6,1.4),'concrete')
        if x==209:
            s.nodes[-3]+='rotation_degrees = Vector3(0,0,7)\n'
    s.box('Gate',(220,G+2,-59),(20,4,.18),'iron')
    s.box('Booth',(240,G+1.5,-54),(5,3,4),'wall')
    obstacle(240,-54,5,4)
    for i in range(12): anchor('GuardLine/G%02d'%(i+1),(210+i*20/11,G,-54))
    anchor('GuardBooth',(240,G,-51))
    anchor('Clues/GatePillar',(209,G,-58))
    anchor('Start_gate',(220,G,-25))
    if DETAIL: detail.gate(s,sys.modules[__name__])
    s.save('gate.tscn')


def canteen():
    s=Scene('Canteen')
    # Width 40 x depth 24, front at Z=20, with an 8 m door in the middle.
    s.box('Floor',(190,G-.1,32),(40,.2,24),'tile',floor=True)
    s.box('Roof',(190,G+4.1,32),(40,.2,24),'wall')
    for x in [170,210]: s.box('Side'+str(x),(x,G+2,32),(.2,4,24),'wall')
    for x in [178,202]: s.box('Front'+str(x),(x,G+2,20),(16,4,.2),'wall')
    for x,w in [(178,16),(199.5,3),(206.5,7)]: s.box('Back'+str(x),(x,G+2,44),(w,4,.2),'wall')
    s.box('KitchenFloor',(192,G-.1,48),(12,.2,8),'tile',floor=True)
    for x in [186,198]: s.box('KitchenSide'+str(x),(x,G+2,48),(.2,4,8),'wall')
    s.box('KitchenBack',(192,G+2,52),(12,4,.2),'wall')
    s.box('StoreFloor',(204,G-.1,48),(12,.2,8),'tile',floor=True)
    s.box('StoreSide',(210,G+2,48),(.2,4,8),'wall')
    for x,w in [(199,2),(207,6)]: s.box('StoreBack'+str(x),(x,G+2,52),(w,4,.2),'wall')
    s.node('TV',properties='position = Vector3(170.2,%s,32)'%(G+2.4))
    s.box('Case',(0,0,0),(.16,.8,1.2),'iron','TV',solid=False)
    s.box('Screen',(.09,0,0),(.015,.66,1.04),'white','TV',solid=False)
    if DETAIL:
        # 1 m cells with clearance around table/chair footprints and counter.
        # Exact shared edges retain connectivity around the furniture.
        for x in range(171,209):
            for z in range(21,43):
                if any(x < tx+1.9 and x+1 > tx-1.9 and z < tz+1.6 and z+1 > tz-1.6 for tx in [174,181,199,206] for tz in [27,36]):continue
                if x<182 and z>=40:continue
                flat('Dining_%d_%d'%(x,z),x,x+1,z,z+1,G)
    else: flat('CanteenMain',170.5,209.5,20.5,43.5,G)
    flat('Kitchen',190,197.5,44.5,49.8,G)
    flat('Store',200,208,44.5,51.5,G)
    link('CanteenEntry',(190,G,18),(190,G,21))
    link('KitchenEntry',(192,G,43),(192,G,45))
    link('StoreEntry',(202,G,43),(202,G,45))
    link('StoreExit',(202,G,51),(202,G,54))
    anchor('CanteenTV',(170.3,G+2.4,32))
    anchor('CanteenClock',(192,G+2.5,51.85))
    anchor('CanteenExit',(202,G,52))
    obstacle(190,32,40,24)
    obstacle(198,48,24,8)
    if DETAIL: detail.canteen(s,sys.modules[__name__])
    s.save('canteen.tscn')


def navigation(s):
    p=s.node('Navigation')
    for name,points in NAV:
        mesh=s.subresource('NavigationMesh','vertices = PackedVector3Array('+','.join(str(round(n,6)) for point in points for n in point)+')\npolygons = [PackedInt32Array(0,1,2,3)]\nagent_radius = 0.3\nagent_height = 1.75')
        s.node(name,'NavigationRegion3D',p,'navigation_mesh = '+mesh)
    # Outdoor lattice excludes solid shells/props and the building interior.
    verts=[]; polys=[]; indices={}
    for x in range(-78,418,2):
        free=[z for z in range(-58,288,2) if not any(x<b and x+2>a and z<d and z+2>c for a,b,c,d in BLOCKS)]
        runs=[]
        for z in free:
            if runs and runs[-1][-1]+2==z: runs[-1].append(z)
            else: runs.append([z])
        for run in runs:
            # Merge cells into convex strips. Keep collinear boundary vertices so
            # adjacent strips share exact edges, including alongside obstacles.
            zs=run+[run[-1]+2]
            poly=[]
            for point in [(x,G,z) for z in zs]+[(x+2,G,z) for z in reversed(zs)]:
                if point not in indices:
                    indices[point]=len(verts);verts.append(point)
                poly.append(indices[point])
            polys.append(poly)
    navpath=OUT/'outdoor_navigation.tres'
    navpath.write_text('[gd_resource type="NavigationMesh" format=3]\n\n[resource]\nagent_radius = 0.3\nagent_height = 1.75\nvertices = PackedVector3Array('+','.join(str(n) for point in verts for n in point)+')\npolygons = ['+','.join('PackedInt32Array('+','.join(map(str,p))+')' for p in polys)+']\n',encoding='utf-8')
    s.node('Outdoor','NavigationRegion3D',p,'navigation_mesh = '+s.resource('res://scenes/levels/campus/outdoor_navigation.tres','NavigationMesh'))
    for name,a,b,extra in LINKS:
        s.node(name,'NavigationLink3D',p,f'start_position = {V(a)}\nend_position = {V(b)}\nbidirectional = true\n{extra}')


def anchors(s):
    anchor('Start_garden',(22,G,8))
    for i,p in enumerate([(8,G+.25,37),(154,G,221),(164,G+.08,225.5),(64,G,-10),(228,G,-29),(194,G,40)]):anchor('BarSpawns/B%02d'%(i+1),p)
    areas={'B4':(8,0,2.1),'B3':(8,-3.3,2.1),'B2':(8,-6.6,2.1),'B1':(8,G,2.1),'Road':(65,G,-12),'Garden':(18,G,18),'Stadium':(115,G,166),'Gate':(196,G,-30),'Canteen':(178,G,24)}
    for area,(x,y,z) in areas.items():
        for i in range(6):
            point=(x+i*4,y,z) if area.startswith('B') or area=='Road' else (x+(i%3)*4,y,z+(i//3)*5)
            if area=='Stadium':point=[(112,G,166),(284,G,166),(198,G,122),(198,G,210),(112,G,170),(284,G,170)][i]
            if area=='Garden':point=(12+(i%3)*16,G,17+(i//3)*10)
            anchor('ZombieSpawns/%s/S%02d'%(area,i+1),point)
            anchor('ZombieIdle/%s/I%02d'%(area,i+1),point if area.startswith('B') else (point[0],y,point[2]+1))
    route=[(13.75,-6.6,-2),(13.75,-6.6,2.0),(-1.2,-6.6,2.0),(-3.8,-8.25,-5.3),(-1.2,G,2.0),(2.75,G,2.0),(2.75,G,-3),(4,G,-4),(4,G+1,-7.6),(4,G,-12),(-8,G,-12),(-8,G,8),(22,G,8),(22,G,26),(48,G,28),(80,G,28),(80,G,166),(115,G,166),(150,G,166),(198,G,135),(250,G,166),(198,G,195),(115,G,166),(80,G,166),(80,G,-15),(220,G,-15),(220,G,-30),(220,G,10),(190,G,18),(190,G,32),(202,G,43),(202,G,48),(202,G,54)]
    for who,start in [('Nhat',0),('Ngu',13)]:
        points=route[start:] if who=='Nhat' else [(22,G+.57,28),(23.8,G,28),(23.8,G,26)]+route[start:]
        for i,p in enumerate(points):
            suffix='_Wait_garden' if p==(22,G,26) else '_Wait_stadium' if p==(115,G,166) else '_Wait_gate' if p==(220,G,-30) else '_Wait_canteen' if p==(190,G,32) else ''
            anchor('Paths/%s/P%02d%s'%(who,i+1,suffix),p)
    parents={'.'}
    for path,point in ANCHORS.items():
        parts=('Anchors/'+path).split('/')
        for i in range(1,len(parts)):
            prefix='/'.join(parts[:i])
            if prefix not in parents:
                s.node(parts[i-1],parent='/'.join(parts[:i-1]) or '.');parents.add(prefix)
        s.node(parts[-1],'Marker3D','/'.join(parts[:-1]),'position = '+V(point))


def zones(s):
    p=s.node('Zones')
    data={'BuildingB':((22,-4,-1.2),(54,14,13.6)),'Road':((110,G+2,-15),(220,4,10)),'Garden':((22,G+2,28),(44,4,40)),'Stadium':((198,G+6,166),(176,12,120)),'Gate':((220,G+2,-40),(60,4,40)),'Canteen':((194,G+2,36),(48,4,32)),'GuardRadius':((220,G+1.5,-52.5),(22,3,3)),'Bleachers':((198,G+2,221.4),(86,5,16))}
    for name,(pos,size) in data.items():
        area=s.node(name,'Area3D',p,'position = '+V(pos)+'\ncollision_layer = 0\ncollision_mask = 2')
        shape=s.subresource('BoxShape3D','size = '+V(size))
        s.node('Collision','CollisionShape3D',area,'shape = '+shape)


def campus():
    s=Scene('Campus')
    s.nodes[0]+='script = '+s.resource('res://scenes/levels/campus/campus.gd','Script')+'\nmetadata/size = Vector2(500,350)\nmetadata/greybox = '+str(not DETAIL).lower()+'\n'
    for name,file in [('BuildingB','building_b'),('Shells','shells'),('Garden','garden'),('Stadium','stadium'),('Gate','gate'),('Canteen','canteen')]:s.inst(name,'scenes/levels/campus/'+file+'.tscn')
    terrain=s.node('Ground')
    for x in range(-80,420,50):
        for z in range(-60,290,50):s.box('Tile_%d_%d'%(x,z),(x+25,G-.19,z+25),(50,.3,50),'grass',terrain,floor=True)
    road=s.node('Road')
    for name,pos,size in [('Avenue',(110,G+.015,-15),(220,.03,8)),('WestBranch',(80,G+.015,77),(8,.03,184)),('EastBranch',(310,G+.015,68),(8,.03,196)),('StadiumWestAccess',(96,G+.015,166),(32,.03,6)),('StadiumEastAccess',(298,G+.015,166),(28,.03,6))]:s.box(name,pos,size,'concrete',road,solid=False)
    if DETAIL: detail.outdoors(s,sys.modules[__name__])
    fence=s.node('Fence')
    for label,pos,size in [('W',(-80,G+1.5,115),(.3,3,350)),('E',(420,G+1.5,115),(.3,3,350)),('N',(170,G+1.5,290),(500,3,.3)),('S',(170,G+1.5,-60),(500,3,.3))]:s.box(label,pos,size,'wall',fence)
    anchors(s);zones(s);navigation(s)
    env=s.subresource('Environment','background_mode = 1\nbackground_color = Color(0.13,0.055,0.06,1)\nambient_light_source = 2\nambient_light_color = Color(0.48,0.43,0.45,1)\nambient_light_energy = 0.65\ntonemap_mode = 2\nfog_enabled = true\nfog_light_color = Color(0.18,0.10,0.11,1)\nfog_density = 0.018\nfog_sky_affect = 1.0')
    s.node('Environment','WorldEnvironment',properties='environment = '+env)
    s.node('Dawn','DirectionalLight3D',properties='rotation_degrees = Vector3(-22,-35,0)\nlight_color = Color(0.70,0.39,0.32,1)\nlight_energy = 0.65\nshadow_enabled = false')
    s.save('campus.tscn')
    (ROOT/'art_source/campus/layout.json').write_text(json.dumps({'ground_y':G,'bounds':[-80,420,-60,290],'anchors':ANCHORS,'navigation_surfaces':len(NAV),'navigation_links':len(LINKS)},indent=2)+'\n',encoding='utf-8')


if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    base.OUT=OUT
    if DETAIL:
        import detail
        detail.textures(ROOT,base.PALETTE)
        detail.actors(sys.modules[__name__])
    building();shells();garden();stadium();gate();canteen();campus()
    print('T183_BUILD: %s campus, %d anchors, %d navigation surfaces, %d links'%('detailed' if DETAIL else 'greybox',len(ANCHORS),len(NAV),len(LINKS)))
