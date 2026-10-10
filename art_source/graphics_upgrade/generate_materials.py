"""Create deterministic CC0 pilot textures only; never rebuild production scenes."""

import math
from pathlib import Path
import random
import struct
import zlib

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "game/assets/textures/graphics_pilot"
SIZE = 256


def png(path, pixels):
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))

    data = b"".join(b"\0" + bytes(pixels[y * SIZE * 3:(y + 1) * SIZE * 3]) for y in range(SIZE))
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0))
                     + chunk(b"IDAT", zlib.compress(data, 9)) + chunk(b"IEND", b""))


def generate(kind):
    rng = random.Random(209 + ["wall", "tile", "iron", "cloth"].index(kind))
    albedo, roughness, heights = [], [], []
    for y in range(SIZE):
        for x in range(SIZE):
            noise = rng.uniform(-1, 1)
            broad = math.sin(x * math.tau / SIZE) * math.cos(y * math.tau / SIZE)
            if kind == "wall":
                base, variation, height, rough = (155, 157, 135), noise * 3 + broad * 5, noise * .18, 224 + noise * 9
            elif kind == "tile":
                grout = min(x % 64, y % 64) < 2
                base = (79, 80, 73) if grout else (123, 132, 124)
                variation, height, rough = noise * 1.8 + broad * 3, (-.5 if grout else .1), (231 if grout else 129 + noise * 8)
            elif kind == "iron":
                base, variation, height, rough = (81, 87, 85), noise * 3 + broad * 4, noise * .08, 123 + broad * 26
            else:
                weave = math.sin(x * math.pi / 2) * math.cos(y * math.pi / 2)
                base, variation, height, rough = (121, 137, 123), weave * 5 + noise * 2, weave * .14, 236 + noise * 5
            albedo.extend(max(0, min(255, round(v + variation))) for v in base)
            roughness.extend([max(0, min(255, round(rough)))] * 3)
            heights.append(height)
    normals = []
    for y in range(SIZE):
        for x in range(SIZE):
            dx = heights[y * SIZE + (x + 1) % SIZE] - heights[y * SIZE + (x - 1) % SIZE]
            dy = heights[((y + 1) % SIZE) * SIZE + x] - heights[((y - 1) % SIZE) * SIZE + x]
            length = math.sqrt(dx * dx + dy * dy + 1)
            normals.extend(round((v / length * .5 + .5) * 255) for v in (-dx, -dy, 1))
    for suffix, pixels in [("albedo", albedo), ("roughness", roughness), ("normal", normals)]:
        png(OUTPUT / f"{kind}_{suffix}.png", pixels)


if __name__ == "__main__":
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for material in ["wall", "tile", "iron", "cloth"]:
        generate(material)
    print("RESULT: generated 12 deterministic 256x256 pilot textures")
