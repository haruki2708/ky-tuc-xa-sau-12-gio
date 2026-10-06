"""CC0 campus detail meshes; procedural geometry and 64 px texture sources."""
from pathlib import Path
import math, random, struct, zlib


def textures(root, palette):
    dest=root/'game/assets/textures/campus'
    dest.mkdir(parents=True,exist_ok=True)
    for name,color in palette.items():
        raw=bytearray(); rng=random.Random('T183'+name)
        for y in range(64):
            raw.append(0)
            for x in range(64):
                grain=rng.choice([-.055,-.02,0,0,.03])
                if name in ['tile','concrete','wall'] and (y%16==0 or (x+(8 if y//16%2 else 0))%32==0):grain-=.1
                if name=='wood' and (x+y//11)%7==0:grain-=.06
                if name in ['iron','glass'] and (x*5+y*9)%71<3:grain+=.13
                raw.extend(round(max(0,min(1,c+grain))*255) for c in color)
        def chunk(kind,data): return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data))
        png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>2I5B',64,64,8,2,0,0,0))
        (dest/(name+'.png')).write_bytes(png+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b''))


def rotate(s,path,angles):
    name=path.split('/')[-1];parent='/'.join(path.split('/')[:-1]) or '.'
    for i,n in enumerate(s.nodes):
        if n.startswith('[node name="'+name+'"') and 'parent="'+parent+'"' in n:
            s.nodes[i]+='rotation_degrees = Vector3(%s)\n'%','.join(map(str,angles));return


def part(s,name,pos,size,mat='iron',parent='.',shape='box',angles=None):
    if shape=='box': p=s.box(name,pos,size,mat,parent,solid=False)
    else:
        mesh=s.subresource('CylinderMesh',f'top_radius = {size[0]/2}\nbottom_radius = {size[2]/2}\nheight = {size[1]}\nradial_segments = 8\nrings = 1\nmaterial = '+s.material(mat))
        p=s.node(name,'MeshInstance3D',parent,'position = '+s.vec(pos)+'\nmesh = '+mesh)
    if angles: rotate(s,p,angles)
    return p


def bench(s,name,pos,parent='.'):
    p=s.node(name,parent=parent,properties='position = '+s.vec(pos))
    part(s,'Seat',(0,.5,0),(2.4,.16,.6),'concrete',p)
    for x in [-.85,.85]:part(s,'Leg'+str(x),(x,.24,0),(.15,.48,.5),'concrete',p)
    part(s,'Back',(0,.86,.24),(2.4,.5,.12),'concrete',p)
    return p


def clock(s,name,pos,yaw=0):
    p=s.node(name,properties='position = '+s.vec(pos)+f'\nrotation_degrees = Vector3(0,{yaw},0)\nmetadata/stopped_hour = 4')
    part(s,'Case',(0,0,0),(.56,.56,.08),'iron',p)
    part(s,'Dial',(0,0,.047),(.48,.48,.012),'paper',p)
    for i in range(12):
        a=i*math.tau/12
        part(s,'Tick%d'%i,(math.sin(a)*.19,math.cos(a)*.19,.06),(.018,.035,.012),'iron',p,angles=(0,0,-i*30))
    part(s,'Minute',(0,.092,.077),(.014,.18,.014),'iron',p)
    part(s,'Hour',(.057,-.033,.08),(.018,.13,.018),'iron',p,angles=(0,0,-120))


def crack(s,name,pos,length=2,parent='.',vertical=False):
    p=s.node(name,parent=parent,properties='position = '+s.vec(pos))
    for i in range(7):
        dx=(i%3-1)*.09
        at=(dx, -i*length/7, 0) if vertical else (dx,.018,i*length/7)
        size=(.03,length/6,.014) if vertical else (.04,.009,length/6)
        part(s,'Branch%d'%i,at,size,'iron',p,angles=(0,0,(i%2*2-1)*17) if vertical else (0,(i%2*2-1)*17,0))
    return p


def cluster(s,name,points,kind='tree',parent='.'):
    # 40 m cells preserve useful culling bounds for long avenues.
    chunks={}
    for p in points:chunks.setdefault((int(p[0]//40),int(p[2]//40)),[]).append(p)
    for (x,z),positions in chunks.items():
        props='script = '+s.resource('res://scenes/levels/campus/foliage.gd','Script')+'\nkind = "'+kind+'"\npoints = PackedVector3Array('+','.join(str(round(n,5)) for p in positions for n in p)+')'
        s.node(name+'_%d_%d'%(x,z),parent=parent,properties=props)


def building(s,c):
    g=c.G
    # Reuse the established floor-4 modular meshes on the lower floors.
    for floor in [1,2,3]:
        y=(floor-4)*3.3
        p=s.node('KitDetail%d'%floor)
        for i in range(8):
            x=2.75+i*5.5
            s.kit('Frame%d'%i,'wall_door',(x,y,0),parent=p)
            plaque=part(s,'Plate%d'%i,(x,y+2.6,.12),(.42,.22,.035),'blue',p)
            s.node('Number','Label3D',plaque,f'text = "{floor*100+i+1}"\nfont_size = 32\npixel_size = 0.004\noutline_size = 0\nposition = Vector3(0,0,.025)\ntexture_filter = 0')
            part(s,'RailingTop%d'%i,(x,y+1.3,4.02),(5.5,.055,.06),'iron',p)
            for j in range(11):part(s,'Railing%d_%d'%(i,j),(x-2.5+j*.5,y+.65,4.02),(.04,1.3,.04),'iron',p)
            part(s,'Tube%d'%i,(x,y+2.85,2.0),(1.15,.08,.13),'paper',p)
        for x in [1,10,21,32,43]:
            s.node('Light'+str(x),'OmniLight3D',p,'position = '+s.vec((x,y+2.65,2.0))+'\nlight_energy = .6\nomni_range = 7\nshadow_enabled = false\nlight_color = Color(.65,.7,.52,1)')
        # Thin collision rails were greybox solids; maintain a transparent barrier.
        for i,n in enumerate(s.nodes):
            if n.startswith('[node name="Mesh"') and 'parent="Floor%d/Rail"'%floor in n:s.nodes[i]+='visible = false\n'
    # Bars protruding from the collapsed slab, chipped rubble chunks, cracks.
    for side,x,y in [('Fire',46.5,-6.6),('Upper',-2.5,3.2)]:
        p=s.node(side+'RubbleDetail')
        if side == 'Fire':
            # Match the narrowed collapse without moving the usable flight B.
            s.nodes[-1] += 'position = Vector3(22,0,0)\nscale = Vector3(.5,1,1)\n'
        for i in range(7):
            part(s,'Chunk%d'%i,(x+(i%3-1)*1.25,y+.3+(i%2)*.4,-.6-i*.43),(1.4,.45,1),'concrete',p,angles=(i*13,i*29,17))
            part(s,'Rebar%d'%i,(x+(i%3-1)*.8,y+1.25,-.8-i*.31),(.035,1.5,.035),'iron',p,angles=(35,i*31,22))
    crack(s,'StairCrack',(48.88,-.4,-3),2.3,vertical=True)
    for x in [-4.9,48.9]:
        for y in [0,-3.3,-6.6]:part(s,'Handrail_%s_%s'%(x,y),(x,y-.1,-2.4),(.05,.05,5),'iron',angles=(-19,0,0))
    # The desk already exists; the blade is visibly planted in its top.
    p=s.node('Knife',properties='position = '+s.vec((1.4,g+.82,-3.2)))
    part(s,'Blade',(0,.12,0),(.12,.24,.018),'white',p,angles=(0,0,-12))
    part(s,'Grip',(.046,.31,0),(.045,.18,.045),'wood',p,angles=(0,0,-12))
    for i in range(9):part(s,'GlassShard%d'%i,(2.2+i*.64,g+1.04,-7.6),(.20,.12,.025),'glass',angles=(0,0,i*39))
    # No shards intersect the 1.8 m traversal opening at x=4.
    for i,n in enumerate(s.nodes):
        if n.startswith('[node name="GlassShard'):
            index=int(n.split('GlassShard')[1].split('"')[0])
            if 1<=index<=4:s.nodes[i]+='visible = false\n'
    part(s,'FireExtinguisher',(48.86,-5.8,2.4),(.2,.55,.2),'red',shape='cone')
    part(s,'ExtinguisherHandle',(48.86,-5.5,2.4),(.17,.055,.07),'iron')
    clock(s,'DeskClock',(40,2.05,.18))
    # Key is visual only; ownership and interaction stay with core.
    part(s,'KeyStem',(39.8,.66,.42),(.13,.018,.023),'white')
    part(s,'KeyTooth',(39.85,.66,.44),(.022,.018,.04),'white')
    for i in range(14):part(s,'ChainLink%d'%i,(-1.15+i*.16,1.25+(i%2)*.04,.13),(.21,.045,.07),'iron','MainDoor/Chains',angles=(0,0,(-1)**i*24))
    s.kit('Room203Bed','bunk_bed',(12.1,-6.6,-4.6))
    s.prop('Room203Desk','desk',(15.2,-6.6,-5.8))
    s.box('Room203BedBody',(12.1,-5.75,-4.6),(1.1,1.7,2.0),visible=False)
    s.box('Room203DeskBody',(15.2,-6.2,-5.8),(1.5,.8,.7),visible=False)


def garden(s,c):
    g=c.G
    for row in range(4):
        for col in range(3):
            x,z=6+col*16,12+row*10
            for i in range(4):
                part(s,'Bush%d_%d_%d'%(row,col,i),(x-1.9+i*1.3,g+.7,z),(.9,1.0,1.3),'tree',shape='cone')
                for j in range(3):part(s,'Flower%d_%d_%d_%d'%(row,col,i,j),(x-1.9+i*1.3+(j-1)*.2,g+1.1,z+.1*j),(.1,.1,.1),'paper')
            part(s,'LowTrunk%d_%d'%(row,col),(x,g+1.0,z),(.16,1.6,.2),'wood',shape='cone')
            part(s,'LowCrown%d_%d'%(row,col),(x,g+2.0,z),(.35,1.6,2.2),'tree',shape='cone')
    # Detail around the collision seat.
    for x in [21.15,22.85]:part(s,'NguBenchLeg'+str(x),(x,g+.22,28),(.15,.44,.5),'concrete')
    for i,(x,z) in enumerate([(2,22),(42,22),(6,47),(38,47)]):
        bench(s,'Bench%d'%i,(x,g,z));s.box('BenchCollision%d'%i,(x,g+.4,z),(2.4,.8,.6),visible=False);c.obstacle(x,z,2.4,.6)
    # Fallen bunk reused from the same kit as Room407; hidden greybox remains collision.
    for i,n in enumerate(s.nodes):
        if n.startswith('[node name="Mesh"') and 'parent="FallenBunk"' in n:s.nodes[i]+='visible = false\n'
    p=s.kit('BrokenBunk','bunk_bed',(8,g+.5,37))
    # kit() already writes rotation_degrees; replace the authored value.
    for i,n in enumerate(s.nodes):
        if n.startswith('[node name="BrokenBunk"'):s.nodes[i]=n.replace('rotation_degrees = Vector3(0, 0, 0)','rotation_degrees = Vector3(0, 0, 90)')
    for i in range(4):part(s,'DetachedRail%d'%i,(7.6+i*.3,g+.12,36.8),(.035,.035,1.2),'iron',angles=(0,20+i*7,0))
    points=[(x,g,z) for x in [1.0,43.0] for z in [10,24,40]]
    cluster(s,'GardenLights',points,'garden')
    for i,p in enumerate(points):
        s.node('Flicker%d'%i,'OmniLight3D',properties='position = '+s.vec((p[0],g+2.9,p[2]))+'\nscript = '+s.resource('res://scenes/levels/campus/flicker.gd','Script')+f'\nphase = {i*1.9}\nomni_range = 5.0\nshadow_enabled = false\nlight_color = Color(.7,.72,.45,1)')


def track_strip(s,name,inner,outer,material,y):
    # A running oval with two 84.39 m straights and r=36.8 m bends.
    # 2*84.39+2*pi*36.8 = 400.00 m, measured at lane-1 centerline.
    vertices=[];faces=[]
    for side in [1,-1]:
        cx=198+side*84.39/2
        start=-math.pi/2 if side==1 else math.pi/2
        for i in range(33):
            angle=start+i*math.pi/32
            vertices.append((cx+math.cos(angle)*inner,y,166+math.sin(angle)*inner))
            vertices.append((cx+math.cos(angle)*outer,y,166+math.sin(angle)*outer))
    for i in range(len(vertices)//2):
        a=i*2;b=((i+1)%(len(vertices)//2))*2
        faces.extend([a,a+1,b,a+1,b+1,b])
    # A SurfaceTool builder keeps indexed points editable instead of opaque buffers.
    s.node(name,properties='script = '+s.resource('res://scenes/levels/campus/strip.gd','Script')+'\nvertices = PackedVector3Array('+','.join(str(round(n,6)) for p in vertices for n in p)+')\nindices = PackedInt32Array('+','.join(map(str,faces))+')\nmaterial = '+s.material(material))


def stadium(s,c):
    g=c.G
    # Remove grey rectangular track coloration; grass apron defines full envelope.
    for i,n in enumerate(s.nodes):
        if n.startswith('[node name="Mesh"') and 'parent="TrackBounds"' in n:s.nodes[i]+='visible = false\n'
    track_strip(s,'RunningSurface',36.19,44.73,'track',g+.027)
    for lane in range(8):track_strip(s,'Lane%d'%lane,36.19+lane*1.22-.025,36.19+lane*1.22+.025,'paper',g+.034)
    for side in [-1,1]:
        part(s,'Goal'+str(side),(198+side*48,g+1.22,166),(.08,2.44,7.32),'white')
        # Replace solid-looking face with three slim bars.
        for i,n in enumerate(s.nodes):
            if n.startswith('[node name="Mesh"') and 'parent="Goal'+str(side)+'"' in n:s.nodes[i]+='visible = false\n'
        for z in [162.34,169.66]:part(s,'GoalPost%s_%s'%(side,z),(198+side*48,g+1.22,z),(.09,2.44,.09),'white')
        part(s,'GoalCross'+str(side),(198+side*48,g+2.44,166),(.09,.09,7.32),'white')
    for x in [150,198,246]:part(s,'PitchLine'+str(x),(x,g+.021,166),(.08,.012,58),'paper')
    for z in [137,195]:part(s,'PitchEdge'+str(z),(198,g+.021,z),(96,.012,.08),'paper')
    for i in range(7):part(s,'StartLane%d'%i,(175+i*.8,g+.045,126-i*1.22),(.13,.012,1.1),'paper')
    # T-192: fences, gate posts, stands, seats and the pipes under the stand are in stands.py.
    for i,(x,z) in enumerate([(112,122),(284,122),(112,210),(284,210)]):
        for j in range(4):part(s,'FloodHousing%d_%d'%(i,j),(x+(j-1.5)*.65,g+17,z),(.56,.6,.22),'paper')


def shells(s,c):
    for i,x in enumerate([7,18,31]):
        p=s.node('WindowSilhouette%d'%i,properties='position = '+s.vec((x,c.G+8,53.8)))
        mat=s.subresource('StandardMaterial3D','albedo_color = Color(.025,.028,.025,1)\nbillboard_mode = 1\nshading_mode = 0')
        for name,pos,size in [('Head',(0,.45,0),(.24,.27)),('Body',(0,0,0),(.46,.68))]:
            mesh=s.subresource('QuadMesh','size = Vector2(%s,%s)\nmaterial = %s'%(size[0],size[1],mat))
            s.node(name,'MeshInstance3D',p,'position = '+s.vec(pos)+'\nmesh = '+mesh)
    for name,x,z,w,floors in [('A',0,54,44,6),('Lecture',-50,180,80,5),('Library',45,195,40,3),('Gym',-60,90,60,1)]:
        for f in range(floors):part(s,name+'Band%d'%f,(x+w/2,c.G+f*3.3,z-.18),(w,.14,.3),'concrete')


def gate(s,c):
    g=c.G
    for i,n in enumerate(s.nodes):
        if n.startswith('[node name="Mesh"') and 'parent="Gate"' in n:s.nodes[i]+='visible = false\n'
    for x in range(210,231):part(s,'GateBar%d'%x,(x,g+2,-59),(.08,4,.1),'iron')
    for y in [.5,3.4]:part(s,'GateCross'+str(y),(220,g+y,-59),(20,.09,.1),'iron')
    sign=part(s,'HalfFallenSign',(219,g+5.8,-59),(18,1.5,.18),'blue',angles=(0,0,-13))
    # Empty name plate deliberately avoids inventing the school's name.
    for i in range(9):part(s,'SignScar%d'%i,(213+i*1.3,g+5.4+(i%2)*.3,-58.85),(.5,.09,.014),'paper')
    part(s,'BoothWindow',(240,g+1.7,-51.97),(3.6,1.1,.04),'glass')
    part(s,'BoothRoof',(240,g+3.12,-54),(5.5,.22,4.5),'iron')
    for x in [212,222,233]:crack(s,'RoadCrack'+str(x),(x,g+.02,-54),8)
    crack(s,'PillarCrack',(208.9,g+4.5,-58.27),3,vertical=True)


def canteen(s,c):
    g=c.G
    for x in [174,181,199,206]:
        for z in [27,36]:
            p=s.node('Table%d_%d'%(x,z),properties='position = '+s.vec((x,g,z)))
            toppled=(x+z)%2==0
            part(s,'Top',(0,.78 if not toppled else .4,0),(2.2,.09,.8),'concrete',p,angles=(0,0,65) if toppled else None)
            for dx in [-.8,.8]:part(s,'Leg'+str(dx),(dx,.4,0),(.07,.75,.6),'iron',p,angles=(0,0,65) if toppled else None)
            s.box('Collision',(0,.45,0),(2.5,.9,1.4),parent=p,visible=False)
            # Interior nav is authored as a grid excluding these footprints.
            for dz in [-1,1]:
                chair=part(s,'Chair'+str(dz),(0,.25,dz),(.5,.09,.5),'wood',p,angles=(0,0,80))
                part(s,'ChairBack'+str(dz),(.2,.3,dz),(.08,.5,.5),'wood',p,angles=(0,0,80))
    s.box('Counter',(176,g+.48,42),(10,.96,1.2),'concrete')
    part(s,'CounterTop',(176,g+1.0,42),(10.2,.1,1.4),'white')
    for i in range(5):
        part(s,'Tray%d'%i,(174+i*.9,g+1.07,42),(.6,.025,.38),'iron',angles=(0,i*15,0))
    for i in range(3):
        part(s,'Pot%d'%i,(187.3+i*.8,g+.25,49),(.6,.5,.6),'iron',shape='cone',angles=(0,0,90))
        part(s,'PotLid%d'%i,(187+i*.9,g+.03,50),(.64,.045,.64),'concrete',shape='cone')
    s.box('Cooktop',(192,g+.45,51),(8,.9,1.1),'iron')
    part(s,'KitchenRoof',(198,g+4.1,48),(24,.2,8),'wall')
    clock(s,'KitchenClock',(192,g+2.5,51.85),180)
    for x in [199,209]:
        for y in [.5,1.4,2.3]:part(s,'Shelf%s_%s'%(x,y),(x,g+y,48),(.6,.09,5),'wood')
    for i in range(6):part(s,'StoreBox%d'%i,(199,g+.7+(i%2)*.9,46+i*.6),(.5,.4,.5),'paper')
    for z in [25,38]:s.node('CeilingLight'+str(z),'OmniLight3D',properties='position = '+s.vec((190,g+3.6,z))+'\nlight_energy = 1.2\nomni_range = 19.0\nshadow_enabled = false\nlight_color = Color(.64,.69,.54,1)')


SKIP_LAMPS=[(60,-20),(120,-20),(180,-20),(86,45),(86,125)]  # T-192: these lamps fell or lean (scatter.py)


def outdoors(s,c):
    g=c.G
    trees=[]
    for x in range(-65,411,16):
        for z in [-50,280]:
            if z==-50 and 190<=x<=250:continue
            trees.append((x,g,z))
    for z in range(-30,280,16):
        for x in [-70,410]:trees.append((x,g,z))
    for x in range(56,209,16):trees.append((x,g,-7))
    for z in range(12,166,16):trees.append((72,g,z))
    cluster(s,'Trees',trees,parent='Road')
    for i,(x,y,z) in enumerate(trees):
        s.box('TreeTrunk%d'%i,(x,y+1.5,z),(.5,3,.5),parent='Road',visible=False)
        c.obstacle(x,z,.5,.5)
    lamps=[(x,g,-20) for x in range(0,221,20)]+[(86,g,z) for z in range(5,166,20)]
    cluster(s,'StreetLights',[l for l in lamps if (l[0],l[2]) not in SKIP_LAMPS],'lamp','Road')
    for i,x in enumerate([62,102,148]):
        bench(s,'RoadBench%d'%i,(x,g,-22),'Road');c.obstacle(x,-22,2.4,.6)
        s.box('BenchBody%d'%i,(x,g+.4,-22),(2.4,.8,.6),parent='Road',visible=False)
    for i,(x,z) in enumerate([(61,-11),(145,-18),(225,-25)]):
        p=s.node('FallenMoped%d'%i,parent='Road',properties='position = '+s.vec((x,g+.25,z))+'\nrotation_degrees = Vector3(0,25,75)')
        for dx in [-.65,.65]:part(s,'Wheel'+str(dx),(dx,.31,0),(.55,.14,.55),'iron',p,'cone',(90,0,0))
        part(s,'Frame',(0,.5,0),(1.4,.18,.25),'red',p)
        part(s,'Seat',(-.12,.8,0),(.65,.12,.34),'iron',p)
        part(s,'Handle',(.6,1.0,0),(.08,.06,.68),'iron',p)
        part(s,'Fork',(.63,.65,0),(.07,.7,.08),'concrete',p)
        s.box('MopedBody%d'%i,(x,g+.3,z),(1.8,.6,1.1),parent='Road',visible=False);c.obstacle(x,z,1.8,1.1)


def actors(c):
    dest=c.ROOT/'game/assets/models/campus';dest.mkdir(parents=True,exist_ok=True)
    sources=['cctv/student_'+n for n in ['hung','kiet','bao','dang']]+['ch1_models/corpse_'+n for n in ['phuc','viet','dat']]
    configs=[('nhat',sources[1],'nhat',False,(1,1,1)),('ngu',sources[2],'ngu',False,(.7,.85,.8)),('guard','ch1_models/manager_body','guard',False,(.7,.8,.65))]
    for i in range(10):configs.append(('zombie_%02d'%(i+1),sources[i%7],'student',True,[(.7,.9,.8),(1,.7,.7),(.7,.75,1),(1,.9,.6)][i%4]))
    for name,source,role,zombie,tint in configs:
        text='[gd_scene format=3]\n\n[ext_resource type="Script" path="res://scenes/levels/campus/actor.gd" id="script"]\n[ext_resource type="PackedScene" path="res://scenes/levels/'+source+'.tscn" id="model"]\n\n'
        text+='[node name="'+name.title()+'" type="Node3D"]\nscript = ExtResource("script")\nrole = "'+role+'"\nzombie = '+str(zombie).lower()+'\nshirt_color = Color('+','.join(map(str,tint))+',1)\nhair_color = Color(.8,.65,.6,1)\n\n[node name="Model" parent="." instance=ExtResource("model")]\n'
        hair=[(0.8,0.65,0.6),(0.4,0.4,0.4),(1.6,1.2,0.8),(0.7,0.8,1.1)][len(name)%4 if not zombie else int(name[-2:])%4]
        (dest/(name+'.tscn')).write_text(text.replace('Color(.8,.65,.6,1)','Color('+','.join(map(str,hair))+',1)'),encoding='utf-8')
