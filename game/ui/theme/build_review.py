"""Package unedited Godot screenshots and measured typography for T-214 review."""

import csv
import hashlib
import json
from pathlib import Path
import shutil


REPO = Path(__file__).resolve().parents[3]
OUTPUT = Path(__file__).resolve().parent / "previews"
LABELS = {
    "title": "Tiêu đề", "warning": "Cảnh báo", "credits": "Ghi công",
    "chapters": "Chọn chương", "pause": "Tạm dừng", "settings": "Cài đặt",
    "settings_bottom": "Cài đặt — cuối vùng cuộn", "settings_reset": "Xác nhận reset hình ảnh",
    "phone": "Điện thoại — cuộc gọi", "phone_map": "Điện thoại — sơ đồ",
    "phone_camera": "Điện thoại — camera", "phone_choices": "Điện thoại — lựa chọn",
    "phone_prediction": "Điện thoại — dự đoán", "phone_last_message": "Điện thoại — tin cuối",
    "paper": "Giấy đánh máy", "handwritten": "Giấy viết tay", "notebook": "Sổ quy tắc",
    "notebook_compare": "Sổ — đối chiếu chương 4", "hud": "Phụ đề và phím E",
    "chain": "Bảng nối từ chương 2",
    "death": "Màn chết", "chapter": "Thẻ chương 3", "chapter4": "Thẻ chương 4",
    "chapter4_credits": "Ghi công cuối chương 4",
}


def main():
    OUTPUT.mkdir(exist_ok=True)
    (OUTPUT / ".gdignore").touch()
    manifest = []
    metrics = []
    for phase in ("before", "after"):
        source = REPO / "build" / "T214" / phase
        destination = OUTPUT / phase
        destination.mkdir(exist_ok=True)
        for screen in LABELS:
            for locale in ("vi", "en"):
                for size in ("1280x720", "1920x1080"):
                    stem = f"{screen}_{locale}_{size}"
                    for suffix in (".png", ".json"):
                        path = source / (stem + suffix)
                        if not path.is_file():
                            raise FileNotFoundError(path)
                        if path.stat().st_size > 10 * 1024 * 1024:
                            raise ValueError(f"Oversized artifact: {path}")
                        shutil.copyfile(path, destination / path.name)
                    picture = destination / (stem + ".png")
                    manifest.append({"file": f"{phase}/{picture.name}",
                                     "sha256": hashlib.sha256(picture.read_bytes()).hexdigest()})
                    data = json.loads((source / (stem + ".json")).read_text(encoding="utf-8"))
                    text = [item for item in data["text"] if item["text"].strip()]
                    minimum = min(item["output_px"] for item in text)
                    metrics.append({"phase": phase, "screen": screen, "locale": locale,
                                    "resolution": size, "minimum_output_px": round(minimum, 3),
                                    "text_items": len(text),
                                    "below_16_px": sum(item["output_px"] < 15.99 for item in text)})
    (OUTPUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    with (OUTPUT / "typography.csv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(metrics[0]))
        writer.writeheader()
        writer.writerows(metrics)
    failures = [item for item in metrics if item["phase"] == "after" and item["below_16_px"]]
    if failures:
        raise ValueError(f"Text below 16 px in final captures: {failures}")
    page = HTML.replace("__SCREENS__", json.dumps(LABELS, ensure_ascii=False))
    (OUTPUT / "index.html").write_text(page, encoding="utf-8")
    print(f"RESULT: T214 review PASS ({len(manifest)} images; final captured text >=16px)")


HTML = """<!doctype html>
<html lang="vi"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>T-214 — Đối chiếu giao diện</title>
<style>
@font-face{font-family:BeVietnam;src:url('../../../assets/fonts/be_vietnam_pro_regular.ttf')}
*{box-sizing:border-box}body{margin:0;background:#0c1515;color:#ecead8;font:16px BeVietnam,sans-serif}
header{padding:24px;position:sticky;top:0;background:#13201fee;border-bottom:1px solid #718d79;z-index:1}
h1{font-size:26px;margin:0 0 10px}p{max-width:95ch;line-height:1.6}a{color:#cfddb3}
nav{display:flex;gap:16px;flex-wrap:wrap;align-items:center}select{font:inherit;padding:8px;background:#21352e;color:inherit;border:1px solid #9bad96}
label{display:flex;gap:8px;align-items:center}.frames{display:grid;grid-template-columns:1fr 1fr;gap:20px;padding:20px}
figure{margin:0;min-width:0}figcaption{margin-bottom:12px}figure div{overflow:auto;border:1px solid #43584b}
img{display:block;width:100%;height:auto}body.pixels .frames{grid-template-columns:1fr}body.pixels img{width:auto;max-width:none}
footer{padding:0 24px 24px}code{font-size:15px}select:focus-visible,a:focus-visible,input:focus-visible{outline:3px solid #f1dba2;outline-offset:3px}
@media(max-width:900px){.frames{grid-template-columns:1fr}}
</style>
<header><h1>T-214 — Đối chiếu giao diện</h1>
<p>Ảnh gốc từ Godot 4.7.2 / Forward+ / RTX 3050 Laptop. Trước: main <code>25e3bfe</code>.
Ảnh fixture UI, không là lượt chơi hết chương hoặc kiểm FPS. Hộp reset hình ảnh chưa có ở bản trước.</p>
<nav><label>Màn <select id="screen"></select></label>
<label>Ngôn ngữ <select id="locale"><option value="vi">Tiếng Việt</option><option value="en">English</option></select></label>
<label>Độ phân giải <select id="resolution"><option>1280x720</option><option>1920x1080</option></select></label>
<label><input id="pixels" type="checkbox">Xem đúng kích thước ảnh</label></nav></header>
<main class="frames"><figure><figcaption>Trước — <a id="before-link">mở PNG gốc</a> · <a id="before-json">cỡ chữ</a></figcaption><div><img id="before" alt="Giao diện trước thay đổi"></div></figure>
<figure><figcaption>Sau — <a id="after-link">mở PNG gốc</a> · <a id="after-json">cỡ chữ</a></figcaption><div><img id="after" alt="Giao diện sau thay đổi"></div></figure></main>
<footer><p><a href="../READABILITY.md">Phạm vi kiểm và bảng cỡ chữ</a> · <a href="../CREDITS.md">Font / texture / giấy phép</a> · <a href="typography.csv">Số đo từng ảnh</a> · <a href="manifest.json">SHA-256 ảnh gốc</a></p></footer>
<script>
const screens=__SCREENS__;
const screen=document.querySelector('#screen'),locale=document.querySelector('#locale'),resolution=document.querySelector('#resolution');
for(const [key,label] of Object.entries(screens)){const option=new Option(label,key);screen.add(option)}
function refresh(){for(const phase of ['before','after']){const path=`${phase}/${screen.value}_${locale.value}_${resolution.value}`;document.querySelector('#'+phase).src=path+'.png';document.querySelector('#'+phase+'-link').href=path+'.png';document.querySelector('#'+phase+'-json').href=path+'.json'}}
for(const control of [screen,locale,resolution])control.addEventListener('change',refresh);
document.querySelector('#pixels').addEventListener('change',event=>document.body.classList.toggle('pixels',event.target.checked));refresh();
</script></html>
"""


if __name__ == "__main__":
    main()
