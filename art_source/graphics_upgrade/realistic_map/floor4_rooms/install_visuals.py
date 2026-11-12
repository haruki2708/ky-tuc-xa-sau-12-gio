"""Apply only the A03 visual nodes; preserve all original gameplay node blocks."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
SCENE = ROOT / 'game/scenes/levels/floor4/corridor.tscn'
SCRIPT = 'res://assets/models/graphics_pilot/realistic_map/floor4_rooms/room_visual.gd'
ROOMS = [401, 402, 403, 404, 405, 406, 408]


def target(path):
    return (any(path.startswith(f'RoomInterior_{room}/') for room in ROOMS)
            or re.match(r'(Floor|BackWall|Ceiling)_40[1-68]/Mesh$', path)
            or re.match(r'RoomPartition_(6|10|14|18|22|26|38)/Mesh$', path)
            or path in ['Room408BackWall/Mesh', 'Room408EastWall/Mesh'])


def main():
    text = SCENE.read_text(encoding='utf-8')
    if 'id="t252_visual"' in text:
        raise SystemExit('T-252 already installed; refusing to append duplicate nodes')
    text = re.sub(r'load_steps=(\d+)', lambda m: f'load_steps={int(m[1])+1}', text, count=1)
    first = text.index('[sub_resource')
    text = text[:first] + f'[ext_resource type="Script" path="{SCRIPT}" id="t252_visual"]\n\n' + text[first:]
    blocks = re.split(r'(?=\[node )', text)
    for i, block in enumerate(blocks):
        match = re.match(r'\[node name="([^"]+)" type="MeshInstance3D" parent="([^"]+)"\]', block)
        if match and target(match[2]+'/'+match[1]):
            blocks[i] = block.replace('\n', '\nvisible = false\n', 1)
    text = ''.join(blocks)
    for room in ROOMS:
        center = 41 if room == 408 else 8+4*(room-401)
        width = 6 if room == 408 else 4
        text += (f'\n[node name="T252Visual" type="Node3D" parent="RoomInterior_{room}"]\n'
                 f'position = Vector3({center}, 0, 0)\nscript = ExtResource("t252_visual")\n'
                 f'room = "{room}"\nwidth = {width}\n')
    SCENE.write_text(text, encoding='utf-8', newline='\n')


if __name__ == '__main__':
    main()
