"""Pack the unmodified CC0 Quaternius glTF into GLB for retarget comparisons."""
import json
import struct
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'build/t219/downloads/gltf-universal-animation-library-main/glTF/AnimationLibrary_Godot_Standard.gltf'
document = json.loads(SOURCE.read_text(encoding='utf-8'))
binary = (SOURCE.parent / document['buffers'][0].pop('uri')).read_bytes()
header = json.dumps(document, separators=(',', ':')).encode()
header += b' ' * (-len(header) % 4)
binary += b'\0' * (-len(binary) % 4)
payload = struct.pack('<III', 0x46546C67, 2, 28 + len(header) + len(binary))
payload += struct.pack('<II', len(header), 0x4E4F534A) + header
payload += struct.pack('<II', len(binary), 0x004E4942) + binary
output = ROOT / 'game/assets/models/characters/manager/quaternius_original.glb'
output.write_bytes(payload)
print('Original reference:', len(payload), 'bytes; animation and bind data unchanged')
official = ROOT / 'build/t219/downloads/quaternius_standard_v3/Universal Animation Library[Standard]/Unreal-Godot/UAL1_Standard.glb'
if official.exists():
    data = official.read_bytes()
    (output.parent / 'quaternius_v3_original.glb').write_bytes(data)
    print('Official Standard v3 reference:', len(data), 'bytes;', hashlib.sha256(data).hexdigest())
