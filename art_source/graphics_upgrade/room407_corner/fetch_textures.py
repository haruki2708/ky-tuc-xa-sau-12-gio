"""Download selected CC0 surface maps from Poly Haven's public asset API."""
import hashlib
import json
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
DEST = HERE / "textures"  # source maps; the GLBs embed what Godot needs
SETS = {"plastered_wall_04": "2k", "interior_tiles": "2k", "wood_table_worn": "1k",
        # Integrator rework: aged paint, painted bed steel, sleeping mat and bedding.
        "painted_plaster_wall": "2k", "green_metal_rust": "1k", "tatami_mat": "1k",
        "rough_linen": "1k", "fabric_pattern_05": "1k", "polar_fleece": "1k",
        # D-100 lived-in room: old white wall tiles for the bathroom.
        "long_white_tiles": "2k"}


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": "Room407-art-pilot/1.0"})
    with urllib.request.urlopen(request, timeout=90) as response:
        return response.read()


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    records = []
    for asset, size in [*SETS.items(), ("plastered_wall_04", "1k")]:
        info = json.loads(fetch("https://api.polyhaven.com/info/" + asset))
        files = json.loads(fetch("https://api.polyhaven.com/files/" + asset))
        row = {"asset": asset, "url": "https://polyhaven.com/a/" + asset,
               "authors": info["authors"], "license": "CC0-1.0",
               "license_url": "https://polyhaven.com/license", "resolution": size,
               "source_width_mm": info.get("dimensions"), "maps": []}
        for channel, suffix in [("Diffuse", "color"), ("nor_gl", "normal"), ("arm", "arm")]:
            if channel not in files:  # colour variants, e.g. fabric_pattern_05 col_01
                channel = sorted(k for k in files if k.startswith("col_"))[0]
            entry = files[channel][size]["jpg"]
            stem = asset + ("_small" if asset == "plastered_wall_04" and size == "1k" else "")
            target = DEST / (stem + "_" + suffix + ".jpg")
            data = target.read_bytes() if target.exists() else fetch(entry["url"])
            assert hashlib.md5(data).hexdigest() == entry["md5"], target
            target.write_bytes(data)
            row["maps"].append({"channel": channel, "file": str(target.relative_to(ROOT)).replace("\\", "/"),
                                "url": entry["url"], "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)})
        records.append(row)
        print("Downloaded", asset, flush=True)
    (HERE / "texture_sources.json").write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
