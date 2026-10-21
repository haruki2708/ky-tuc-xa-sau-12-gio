"""Download the CC0 surface maps of the T-222 room shell from Poly Haven's public asset API.
Maps the corner pilot already has (painted_plaster_wall, interior_tiles, plastered_wall_04,
wood_table_worn) are read from ../room407_corner/textures and not downloaded again.
"""
import hashlib
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "room407_corner"))
from fetch_textures import ROOT, fetch  # noqa: E402

DEST = HERE / "textures"
SETS = {
    "peeling_painted_wall": "2k",  # paint flaking off plaster: damp corners, balcony, bathroom side
    "distressed_painted_planks": "1k",  # chipped paint over wood: door frames
    "anti_skid_tiles": "1k",  # bathroom floor
    "floor_tiles_08": "1k",  # balcony floor
    "plastered_wall_02": "2k",  # exterior render: balcony walls, facade, the block opposite
}


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    records = []
    for asset, size in SETS.items():
        info = json.loads(fetch("https://api.polyhaven.com/info/" + asset))
        files = json.loads(fetch("https://api.polyhaven.com/files/" + asset))
        row = {"asset": asset, "url": "https://polyhaven.com/a/" + asset, "authors": info["authors"],
               "license": "CC0-1.0", "license_url": "https://polyhaven.com/license", "resolution": size,
               "source_width_mm": info.get("dimensions"), "maps": []}
        for channel, suffix in [("Diffuse", "color"), ("nor_gl", "normal"), ("arm", "arm")]:
            entry = files[channel][size]["jpg"]
            target = DEST / f"{asset}_{suffix}.jpg"
            data = target.read_bytes() if target.exists() else fetch(entry["url"])
            assert hashlib.md5(data).hexdigest() == entry["md5"], target
            target.write_bytes(data)
            row["maps"].append({"channel": channel, "file": str(target.relative_to(ROOT)).replace("\\", "/"),
                                "url": entry["url"], "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)})
        records.append(row)
        print("Downloaded", asset, flush=True)
    (HERE / "texture_sources.json").write_bytes((json.dumps(records, indent=2) + "\n").encode("utf-8"))


if __name__ == "__main__":
    main()
