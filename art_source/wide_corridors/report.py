"""Compare captured global anchor coordinates without changing scenes."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
before = json.loads((ROOT / 'anchors_before.json').read_text(encoding='utf-8'))
after = json.loads((ROOT / 'anchors_after.json').read_text(encoding='utf-8'))
assert before.keys() == after.keys(), 'Anchor names were added or removed'
changed = [name for name in sorted(before) if before[name] != after[name]]


def point(values):
    return '(' + ', '.join(f'{value:g}' for value in values) + ')'


lines = [
    '# T-187 — Tọa độ anchor trước/sau', '',
    'Tọa độ global trong fixture Floor4 + Campus, đơn vị mét. '
    'Bản trước: `8110f4b`; bản sau: scene T-187. Không đổi tên anchor.', '',
    f'{len(changed)} / {len(before)} anchor đã dời; '
    f'{len(before) - len(changed)} anchor giữ nguyên.', '',
    '| Anchor | Cũ (x, y, z) | Mới (x, y, z) |',
    '|---|---|---|',
]
for name in changed:
    lines.append(f'| `{name}` | `{point(before[name])}` | `{point(after[name])}` |')
lines += ['', 'Nguồn: [trước](anchors_before.json), [sau](anchors_after.json). '
          'Dựng lại bảng bằng `python art_source/wide_corridors/report.py`.', '']
(ROOT / 'anchor_changes.md').write_text('\n'.join(lines), encoding='utf-8')
print(f'ANCHORS: {len(changed)} moved, {len(before) - len(changed)} unchanged; identical names')
