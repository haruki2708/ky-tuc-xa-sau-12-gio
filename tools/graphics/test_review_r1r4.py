"""Reproduce D-082 review cases offline; --snapshot records actual validator output."""
import hashlib
import json
import struct
import sys
import unittest

import test_offline


def fixture():
    case = test_offline.G1Tests()
    case.setUp()
    case.asset['asset_id'] = 'room407_backpack'
    case.asset['budget']['triangle_limit_exclusive'] = 3001
    case.asset['binding']['scene_path'] = 'res://wrapper.tscn'
    files = {
        'door.glb.import': '[remap]\npath="res://.godot/imported/fixture.scn"\n[deps]\n'
                           'dest_files=["res://.godot/imported/fixture.scn"]\n[params]\n'
                           'import_script/path="res://importer.gd"\n',
        'game/importer.gd': 'extends "res://base_importer.gd"\nconst M = preload("res://material.tres")\n',
        'game/base_importer.gd': 'extends EditorScenePostImport\n',
        'game/material.tres': '[gd_resource type="ShaderMaterial" format=3]\n'
                              '[ext_resource path="res://texture.png" type="Texture2D" id="1"]\n'
                              '[ext_resource path="res://surface.gdshader" type="Shader" id="2"]\n',
        'game/surface.gdshader': 'shader_type spatial;\n#include "res://surface.gdshaderinc"\n',
        'game/surface.gdshaderinc': '// fixture include\n',
        'game/wrapper.tscn': '[gd_scene format=3]\n'
                             '[ext_resource type="Script" path="res://wrapper.gd" id="1"]\n',
        'game/wrapper.gd': 'extends Node3D\n',
        'game/.godot/imported/fixture.scn': '[gd_scene format=3]\n',
    }
    for name, content in files.items():
        (case.root / name).write_text(content, encoding='utf-8')
    payload = json.dumps({'asset': {'version': '2.0'}}).encode()
    payload += b' ' * (-len(payload) % 4)
    content = struct.pack('<4sII', b'glTF', 2, 20 + len(payload)) + struct.pack('<II', len(payload), 0x4e4f534a) + payload
    (case.root / 'door.glb').write_bytes(content)
    case.measurement['sha256'] = hashlib.sha256(content).hexdigest()
    paths = set(case.measurement['dependency_hashes']) | files.keys()
    case.measurement['dependency_hashes'] = {
        name: hashlib.sha256((case.root / name).read_bytes()).hexdigest() for name in paths}
    return case


CASES = []


def add(name, mutate, expected='FAIL', detail=None):
    CASES.append((name, mutate, expected, detail))


def double_root(case):
    for record in (case.asset['geometry'], case.measurement):
        record['root_scale'] = [2, 2, 2]
        record['dimensions_m'] = [v * 2 for v in record['dimensions_m']]


def loose_tolerance(case):
    case.asset['geometry'].update(tolerance_m=100, dimensions_m=[99, 99, 99])


add('r1_double_root_and_dimensions', double_root, detail='root_scale')
add('r1_tolerance_100_and_size_99', loose_tolerance, detail='tolerance_m')
add('r1_scale_cannot_borrow_position_tolerance',
    lambda c: c.measurement.update(root_scale=[1.0005, 1, 1]), detail='root_scale')
for label, value in [('negative', -1), ('nan', float('nan')), ('infinite', float('inf'))]:
    add('r1_tolerance_' + label, lambda c, v=value: c.asset['geometry'].update(tolerance_m=v), detail='tolerance_m')


def inflate(case):
    case.asset['budget'].update(triangle_limit_exclusive=100001, material_limit=999, texture_edge_limit=8192)
    case.measurement.update(triangles=99999, material_count=999, texture_count=1,
                            textures={'map': {'width': 8192, 'height': 8192}})


add('r2_self_declared_inflated_limits', inflate, detail='budget')
for key, value in [('triangle_limit_exclusive', 100001), ('material_limit', 999), ('texture_edge_limit', 8192)]:
    add('r2_inflated_' + key, lambda c, k=key, v=value: c.asset['budget'].update({k: v}), detail=key)


DEPENDENCIES = {'importer': 'game/importer.gd', 'material': 'game/material.tres',
                'texture': 'game/texture.png', 'include': 'game/surface.gdshaderinc', 'wrapper': 'game/wrapper.gd'}
for kind, path in DEPENDENCIES.items():
    add('r3_missing_' + kind, lambda c, p=path: c.measurement['dependency_hashes'].pop(p),
        'INCOMPLETE', path)
    add('r3_stale_' + kind, lambda c, p=path: (c.root / p).write_bytes((c.root / p).read_bytes() + b'changed'),
        detail=path)


def removed_then_changed(case):
    case.measurement['dependency_hashes'].pop('game/importer.gd')
    (case.root / 'game/importer.gd').write_text('extends EditorScenePostImport\n# changed')


add('r3_removed_importer_then_changed', removed_then_changed, 'INCOMPLETE', 'game/importer.gd')
def opaque_cache(case):
    name = 'game/.godot/imported/fixture.scn'
    (case.root / name).write_bytes(b'RSCC\x00')
    case.measurement['dependency_hashes'][name] = hashlib.sha256(b'RSCC\x00').hexdigest()


add('r3_opaque_cache_closure', opaque_cache, 'INCOMPLETE', 'game/.godot/imported/fixture.scn')


def provider(case, name):
    if name != 'self_authored':
        case.asset['generation'].update(provider=name, channel='studio', wallet_id=name + ':studio:fixture', tier='paid')
        case.asset['budget'].update(wallet_id=name + ':studio:fixture', balance_before=10, balance_after=10)


for name in ('self_authored', 'tripo', 'meshy'):
    def bad_rights(c, p=name):
        provider(c, p)
        c.asset['generation']['rights_evidence'] = 42
    add('r4_rights_evidence_42_' + name, bad_rights, detail='generation.rights_evidence')
    def bad_parameters(c, p=name):
        provider(c, p)
        c.asset['generation']['parameters'] = ['not', 'an', 'object']
    add('r4_parameters_array_' + name, bad_parameters, detail='generation.parameters')
for name, section, key, value in [
    ('const', 'geometry', 'pose', 'animated'),
    ('range', 'budget', 'balance_before', -1),
    ('bool_number', 'placement', 'position_m', [True, 0, 0]),
    ('array_length', 'placement', 'scale', [1, 1]),
    ('nested_parameters', 'generation', 'parameters', {'nested': [float('nan')]}),
]:
    add('r4_schema_' + name, lambda c, s=section, k=key, v=value: c.asset[s].update({k: v}), detail=section + '.' + key)

add('positive_complete_static_graph', lambda c: None, 'VALID')
add('positive_unit_scale_epsilon', lambda c: c.measurement.update(root_scale=[1.00001, 0.99999, 1]), 'VALID')
add('positive_tolerance_boundary', lambda c: c.asset['geometry'].update(tolerance_m=0.001), 'VALID')
add('positive_other_asset_own_budget', lambda c: (inflate(c), c.asset.update(asset_id='other_contract_asset')), 'VALID')
for name in ('self_authored', 'tripo', 'meshy'):
    add('positive_metadata_' + name, lambda c, p=name: provider(c, p), 'VALID')


def run_case(entry):
    name, mutate, expected, detail = entry
    case = fixture()
    try:
        mutate(case)
        result = case.check_g1()
        return {'fixture': name, 'expected': expected, 'detail': detail,
                'status': result['status'], 'errors': result['errors'], 'unavailable': result['unavailable']}
    finally:
        case.doCleanups()


class ReviewTests(unittest.TestCase):
    pass


for entry in CASES:
    def test(self, item=entry):
        result = run_case(item)
        if item[2] == 'VALID':
            self.assertEqual(result['errors'], [], result)
            if item[0] == 'positive_complete_static_graph':
                self.assertFalse(any(message.startswith(('missing_dependency_', 'dependency_closure_unproven:',
                                                         'dynamic_dependency:', 'import_output_unproven:'))
                                     for message in result['unavailable']), result)
        else:
            self.assertEqual(result['status'], item[2], result)
            messages = result['errors'] if item[2] == 'FAIL' else result['unavailable']
            self.assertTrue(any(item[3] in message for message in messages), result)
    setattr(ReviewTests, 'test_' + entry[0], test)


if __name__ == '__main__':
    if '--snapshot' in sys.argv:
        print(json.dumps([run_case(entry) for entry in CASES], indent=2))
    else:
        unittest.main()
