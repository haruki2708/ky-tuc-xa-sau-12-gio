"""Execute every validation keyword used by the published local schema, offline."""
import json
import math
from pathlib import Path

SCHEMA = json.loads(Path(__file__).with_name('manifest.schema.json').read_text(encoding='utf-8'))


def check_supported(rule):
    supported = {'$schema', '$defs', '$ref', 'title', 'description', 'default', 'type', 'const', 'enum',
                 'anyOf', 'allOf', 'if', 'then', 'required', 'properties', 'additionalProperties',
                 'minItems', 'maxItems', 'items', 'minLength', 'minimum', 'maximum', 'exclusiveMinimum'}
    unknown = set(rule) - supported
    if unknown:
        raise ValueError('Unsupported local schema keywords: ' + ', '.join(sorted(unknown)))
    for key in ('$defs', 'properties'):
        for child in rule.get(key, {}).values():
            check_supported(child)
    for key in ('anyOf', 'allOf'):
        for child in rule.get(key, []):
            check_supported(child)
    for key in ('items', 'additionalProperties', 'if', 'then'):
        if isinstance(rule.get(key), dict):
            check_supported(rule[key])


check_supported(SCHEMA)


def matches_type(value, kind):
    numeric = type(value) in (int, float) and (type(value) is int or math.isfinite(value))
    return {'null': value is None, 'boolean': type(value) is bool,
            'string': isinstance(value, str), 'object': isinstance(value, dict),
            'array': isinstance(value, list), 'number': numeric,
            'integer': numeric and (type(value) is int or value.is_integer())}.get(kind, False)


def schema_errors(value, rule=None, path='asset'):
    rule = SCHEMA['$defs']['asset'] if rule is None else rule
    errors = []
    if '$ref' in rule:
        target = SCHEMA
        for part in rule['$ref'].removeprefix('#/').split('/'):
            target = target[part]
        errors.extend(schema_errors(value, target, path))
    kinds = rule.get('type', [])
    kinds = [kinds] if isinstance(kinds, str) else kinds
    if kinds and not any(matches_type(value, kind) for kind in kinds):
        return errors + [f'{path}: expected type {"/".join(kinds)}']
    if 'const' in rule and value != rule['const']:
        errors.append(f'{path}: must equal {rule["const"]!r}')
    if 'enum' in rule and value not in rule['enum']:
        errors.append(f'{path}: not in allowed enum')
    if 'anyOf' in rule and not any(not schema_errors(value, choice, path) for choice in rule['anyOf']):
        errors.append(f'{path}: no allowed type/shape matched')
    for child in rule.get('allOf', []):
        errors.extend(schema_errors(value, child, path))
    if 'if' in rule and not schema_errors(value, rule['if'], path):
        errors.extend(schema_errors(value, rule.get('then', {}), path))
    if isinstance(value, dict):
        for key in rule.get('required', []):
            if key not in value:
                errors.append(f'{path}.{key}: required')
        properties = rule.get('properties', {})
        for key, item in value.items():
            if not isinstance(key, str):
                errors.append(f'{path}: object keys must be strings')
                continue
            if key in properties:
                errors.extend(schema_errors(item, properties[key], path + '.' + key))
            elif isinstance(rule.get('additionalProperties'), dict):
                errors.extend(schema_errors(item, rule['additionalProperties'], path + '.' + key))
            elif rule.get('additionalProperties') is False:
                errors.append(f'{path}.{key}: unknown property')
    if isinstance(value, list):
        if len(value) < rule.get('minItems', 0) or len(value) > rule.get('maxItems', len(value)):
            errors.append(f'{path}: invalid array length')
        for index, item in enumerate(value):
            errors.extend(schema_errors(item, rule.get('items', {}), f'{path}[{index}]'))
    if isinstance(value, str) and len(value) < rule.get('minLength', 0):
        errors.append(f'{path}: string too short')
    if type(value) in (int, float):
        if type(value) is float and not math.isfinite(value):
            errors.append(f'{path}: number must be finite')
        else:
            for keyword, violated in [('minimum', lambda bound: value < bound),
                                      ('maximum', lambda bound: value > bound),
                                      ('exclusiveMinimum', lambda bound: value <= bound)]:
                if keyword in rule and violated(rule[keyword]):
                    errors.append(f'{path}: {keyword} {rule[keyword]} violated')
    return errors
