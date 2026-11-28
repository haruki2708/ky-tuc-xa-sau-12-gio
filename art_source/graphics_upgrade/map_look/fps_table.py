"""T-273: table of FPS with the look off and on, both rounds averaged per view (frame time averaged, then FPS).

    python -I fps_table.py <chapter> [tag]

Reads build/integrator/t273_fps_ch<chapter>[_<tag>]_<off|on>_r<1|2>.json written by fps.gd in this folder.
"""
import json
import os
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', 'build', 'integrator'))


def main() -> None:
    chapter = sys.argv[1]
    tag = ('_' + sys.argv[2]) if len(sys.argv) > 2 else ''
    rows = {}
    rounds = {}
    for mode in ('off', 'on'):
        for r in (1, 2):
            path = os.path.join(ROOT, 't273_fps_ch%s%s_%s_r%d.json' % (chapter, tag, mode, r))
            if not os.path.exists(path):
                continue
            rounds.setdefault(mode, []).append(r)
            for x in json.load(open(path))['results']:
                rows.setdefault(x['view'], {}).setdefault(mode, []).append(x)
    print('rounds', rounds)
    print('| View | Off FPS | On FPS | Off ms | On ms | Change ms | On 1% low |')
    print('|---|---:|---:|---:|---:|---:|---:|')
    for view, d in rows.items():
        if 'off' not in d or 'on' not in d:
            continue
        a = sum(x['mean_ms'] for x in d['off']) / len(d['off'])
        b = sum(x['mean_ms'] for x in d['on']) / len(d['on'])
        low = min(x['low1_fps'] for x in d['on'])
        print('| %s | %.1f | %.1f | %.2f | %.2f | %+.2f | %.1f |' % (view, 1000 / a, 1000 / b, a, b, b - a, low))


if __name__ == '__main__':
    main()
