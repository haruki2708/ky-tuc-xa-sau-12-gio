"""Run ../bake_prop.py for every item of bake_spec.json (Tripo batch 3, D-100).

python -B art_source/graphics_upgrade/tripo/room407_batch3/bake_batch3.py [name ...]
Sources: build/graphics/staging/room407_batch3/. Output: game/assets/models/graphics_pilot/room407_batch3/.
"""
import json
import pathlib
import subprocess
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BLENDER = pathlib.Path(r"D:\Tools\Blender\5.2.2\blender.exe")
SRC = ROOT / "build" / "graphics" / "staging" / "room407_batch3"
OUT = ROOT / "game" / "assets" / "models" / "graphics_pilot" / "room407_batch3"


def main() -> int:
    spec = json.loads((HERE / "bake_spec.json").read_text(encoding="utf-8"))
    wanted = set(sys.argv[1:])
    OUT.mkdir(parents=True, exist_ok=True)
    failed = []
    for raw in spec["items"]:
        item = {**spec["defaults"], **raw}
        if wanted and item["name"] not in wanted:
            continue
        w, h, d = item["size"]
        cmd = [str(BLENDER), "-b", "--factory-startup", "-P", str(HERE.parent / "bake_prop.py"), "--",
            "--src", str(SRC / item["src"]), "--out", str(OUT / (item["name"] + ".glb")), "--name", item["name"],
            "--min", str(-w / 2), "0", str(-d / 2), "--size", str(w), str(h), str(d),
            "--rotate", str(item["rotate"]), "--fit", item["fit"], "--tris", str(item["tris"]),
            "--tex", str(item["tex"]), "--image-format", item["image_format"], "--sharp", str(item.get("sharp", 0)),
            "--height-map", *item.get("height_map", [])]
        result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
        lines = [l for l in result.stdout.splitlines() if l.startswith("BAKE")]
        print(f"{item['name']} exit {result.returncode}", *lines, sep="\n  ", flush=True)
        if result.returncode != 0 or not any(l.startswith("BAKE wrote") for l in lines):
            failed.append(item["name"])
            print(result.stderr[-2000:], flush=True)
    print("RESULT:", "FAIL " + ", ".join(failed) if failed else "all baked", flush=True)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
