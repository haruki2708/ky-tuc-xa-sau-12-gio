"""Fetch selected CC0 system assets without downloading the full 268 MiB pack.

The server supports HTTP byte ranges. ZIP metadata and each selected member are
read with zipfile, which also checks the member's CRC. Downloads stay on D:.
"""
import argparse
import io
import json
import urllib.request
import zipfile
from pathlib import Path

URL = "https://files.makehumancommunity.org/asset_packs/makehuman_system_assets/makehuman_system_assets_cc0.zip"


class RemoteZip(io.RawIOBase):
    def __init__(self, url):
        self.url = url
        request = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(request, timeout=60) as response:
            self.length = int(response.headers["Content-Length"])
        self.pos = 0
        self.cache = []

    def seekable(self):
        return True

    def seek(self, offset, whence=0):
        self.pos = offset if whence == 0 else self.pos + offset if whence == 1 else self.length + offset
        return self.pos

    def tell(self):
        return self.pos

    def read(self, size=-1):
        end = self.length if size < 0 else min(self.length, self.pos + size)
        if end <= self.pos:
            return b""
        for start, data in self.cache:
            if start <= self.pos and end <= start + len(data):
                result = data[self.pos - start:end - start]
                self.pos = end
                return result
        # Read ahead enough to cover the local ZIP header and short asset files.
        fetch_end = min(self.length, max(end, self.pos + 8192))
        request = urllib.request.Request(self.url, headers={"Range": f"bytes={self.pos}-{fetch_end - 1}"})
        with urllib.request.urlopen(request, timeout=120) as response:
            if response.status != 206:
                raise RuntimeError("Server did not honor byte range")
            data = response.read()
        self.cache.append((self.pos, data))
        result = data[:end - self.pos]
        self.pos = end
        return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--prefix", action="append", default=[])
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(RemoteZip(URL)) as archive:
        entries = [{"name": x.filename, "bytes": x.file_size} for x in archive.infolist()]
        (args.output / "pack_index.json").write_text(json.dumps(entries, indent=2), encoding="utf-8")
        for entry in archive.infolist():
            if entry.is_dir() or not any(entry.filename.startswith(p) for p in args.prefix):
                continue
            target = (args.output / entry.filename).resolve()
            if not target.is_relative_to(args.output.resolve()):
                raise RuntimeError("Unsafe archive path")
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(archive.read(entry))
            print(entry.filename, entry.file_size, flush=True)


if __name__ == "__main__":
    main()
