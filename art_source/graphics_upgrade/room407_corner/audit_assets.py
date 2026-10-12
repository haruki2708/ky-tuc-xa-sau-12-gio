"""Independent GLB/texture budget audit, without Blender or Godot."""
import hashlib
import io
import json
import struct
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = ROOT / "game/assets/models/graphics_pilot/room407_corner"


def inspect(path, triangle_limit, texture_limit):
    raw = path.read_bytes()
    assert raw[:4] == b"glTF" and len(raw) <= 10*1024*1024, path
    length = struct.unpack_from("<I", raw, 12)[0]
    doc = json.loads(raw[20:20+length])
    binary = raw[28+length:]
    triangles = sum(doc["accessors"][primitive["indices"]]["count"] // 3
                    for mesh in doc["meshes"] for primitive in mesh["primitives"])
    assert triangles <= triangle_limit, (path, triangles)
    assert len(doc["materials"]) <= (3 if path.stem == "bunk_a_bedding" else 2), path
    images = []
    for image in doc.get("images", []):
        view = doc["bufferViews"][image["bufferView"]]
        offset = view.get("byteOffset", 0)
        data = binary[offset:offset+view["byteLength"]]
        size = Image.open(io.BytesIO(data)).size
        assert max(size) <= texture_limit and size[0] == size[1], (path, image["name"], size)
        images.append({"name": image["name"], "size": list(size), "sha256": hashlib.sha256(data).hexdigest()})
    return {"file": path.relative_to(ROOT).as_posix(), "triangles": triangles,
            "materials": len(doc["materials"]), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest(), "textures": images}


def main():
    rows = []
    for name in ["floor", "architecture", "bunk_a", "bunk_a_bedding", "study_desk", "fixtures"]:
        rows.append(inspect(OUT / (name+".glb"), 8000 if name != "fixtures" else 5000,
                            2048 if name in ["floor", "architecture"] else 1024))
    for placement in json.loads((HERE / "placements.json").read_text()):
        path = ROOT / "game" / placement["model"].removeprefix("res://")
        large = placement["name"] == "Fridge"
        rows.append(inspect(path, 8000 if large else 5000, 2048 if large else 1024))
    unique = {image["sha256"] for row in rows for image in row["textures"]}
    for row in json.loads((HERE / "texture_sources.json").read_text()):
        for item in row["maps"]:
            assert hashlib.sha256((ROOT/item["file"]).read_bytes()).hexdigest() == item["sha256"]
    report = {"method": "GLB indexed triangle counts; embedded image decode; SHA256 dedup",
              "assets": rows, "total_triangles": sum(r["triangles"] for r in rows),
              "unique_embedded_textures": len(unique), "additional_decal_textures": 1}
    (HERE / "asset_audit.json").write_text(json.dumps(report, indent=2)+"\n", encoding="utf-8")
    print("RESULT: corner offline GLB budgets/hash/texture audit PASS")
    print(json.dumps({k:v for k,v in report.items() if k != "assets"}))


if __name__ == "__main__":
    main()
