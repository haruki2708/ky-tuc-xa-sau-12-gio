"""Reconstruct static dependency expectations from current files, never from hash keys."""
import hashlib
import json
import posixpath
import re
import struct

from asset_qa import repo_file

RESOURCE = re.compile(r'''["'](res://[^"'\r\n]+)["']''')
RELATIVE = re.compile(r'''(?:#include\s+|extends\s+|(?:preload|load)\s*\(\s*)["']([^"'\r\n]+)["']''')
TEXT = {'.import', '.gd', '.gdshader', '.gdshaderinc', '.tscn', '.tres'}
LEAVES = {'.png', '.jpg', '.jpeg', '.webp', '.ctex', '.bin', '.ogg', '.wav'}


def inspect_dependencies(asset, measured, root):
    errors, unavailable, expected = [], [], set()
    queue = [asset['file'], asset['file'] + '.import']
    fixed = {'game/project.godot', 'game/scripts/debug/graphics_asset_probe.gd'}
    scene = asset['binding']['scene_path']
    if scene.startswith('res://'):
        queue.append('game/' + scene[6:])
    else:
        unavailable.append('dependency_closure_unproven:' + scene)
    while queue:
        name = queue.pop()
        if name in expected:
            continue
        expected.add(name)
        try:
            path = repo_file(root, name)
            data = path.read_bytes()
        except (ValueError, OSError):
            unavailable.append('missing_dependency_file:' + name)
            continue
        if (root / (name + '.import')).is_file():
            queue.append(name + '.import')
        suffix = path.suffix.lower()
        if suffix == '.glb':
            try:
                length, kind = struct.unpack_from('<II', data, 12)
                if kind != 0x4e4f534a:
                    raise ValueError('Missing JSON chunk')
                document = json.loads(data[20:20 + length])
                for item in document.get('images', []) + document.get('buffers', []):
                    uri = item.get('uri', '')
                    if uri and not uri.startswith('data:'):
                        queue.append(posixpath.normpath(posixpath.join(posixpath.dirname(name), uri)))
            except (ValueError, TypeError, AttributeError, struct.error, UnicodeError):
                unavailable.append('dependency_closure_unproven:' + name)
            continue
        if suffix in LEAVES:
            continue
        if suffix not in TEXT and suffix != '.scn':
            unavailable.append('dependency_closure_unproven:' + name)
            continue
        try:
            source = data.decode('utf-8')
        except UnicodeError:
            unavailable.append('dependency_closure_unproven:' + name)
            continue
        if suffix == '.scn' and not source.startswith('[gd_scene'):
            # Imported binary PackedScenes require Godot evidence; do not invent a parser.
            unavailable.append('dependency_closure_unproven:' + name)
            continue
        if suffix == '.import' and not all(section in source for section in ('[remap]', '[deps]')):
            unavailable.append('dependency_closure_unproven:' + name)
        references = set(RESOURCE.findall(source)) | set(RELATIVE.findall(source))
        for reference in references:
            if '%' in reference or '{' in reference:
                unavailable.append('dynamic_dependency:' + name + ':' + reference)
            elif reference.startswith('res://'):
                queue.append('game/' + reference[6:])
            elif '://' not in reference:
                queue.append(posixpath.normpath(posixpath.join(posixpath.dirname(name), reference)))
            else:
                unavailable.append('unsupported_dependency:' + name + ':' + reference)
        if suffix == '.gd' and re.search(r'\b(?:load|preload)\s*\(\s*[^\s"\']', source):
            unavailable.append('dynamic_dependency:' + name)
    expected.update(fixed)
    hashes = measured.get('dependency_hashes')
    if not isinstance(hashes, dict) or not hashes:
        unavailable.append('dependency_and_import_hashes')
        hashes = {}
    if not all(isinstance(name, str) and isinstance(value, str) for name, value in hashes.items()):
        errors.append('malformed dependency hashes')
        hashes = {}
    for name in sorted(expected - hashes.keys()):
        unavailable.append('missing_dependency_hash:' + name)
    if not any(name.startswith('game/.godot/imported/') for name in expected):
        unavailable.append('import_output_unproven:' + asset['file'] + '.import')
    for name, digest in hashes.items():
        try:
            actual = hashlib.sha256(repo_file(root, name).read_bytes()).hexdigest()
            if actual != digest:
                errors.append('stale dependency:' + name)
        except (ValueError, OSError):
            unavailable.append('missing_dependency_file:' + name)
    missing = measured.get('dependency_unavailable', [])
    if not isinstance(missing, list) or not all(isinstance(item, str) for item in missing):
        errors.append('malformed dependency_unavailable')
    else:
        unavailable.extend('probe_dependency:' + item for item in missing)
    return errors, unavailable
