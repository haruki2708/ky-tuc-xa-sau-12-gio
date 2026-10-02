# T-114 — Sửa tiếng ù đèn tuýp, vùng âm thanh và đèn tắt thì im tiếng
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-114-audio-zones`
- Phụ thuộc: T-101, T-105 (done). Đọc mục **Review** trong `docs/tasks/T-105-audio-pipeline.md` trước khi làm.

## Mục tiêu
1. Tiếng ù đèn tuýp nghe rõ trên **cả loa laptop**, không chỉ trên loa có bass (chủ dự án nghe thử: "không nghe rõ tiếng ù đèn tuýp"; các âm khác tạm ổn, giữ nguyên).
2. Có thành phần dùng lại được để đặt âm thanh theo khu vực khi dựng tầng (T-112): vùng âm môi trường và vùng reverb.
3. Đèn tắt thì tiếng ù tắt theo. Đây là chỗ "im lặng cũng là công cụ" trong GDD.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Yêu cầu
1. **Làm lại `fluorescent_hum`** trong `process.py`:
   - Giữ phần trầm 100 Hz, nhưng thêm các họa âm cao có tiếng rè của chấn lưu (vùng khoảng 300 Hz – 3 kHz), cộng một tiếng rít rất nhỏ ở tần số cao. Tiếng rè dao động nhẹ, không đều tuyệt đối.
   - **Kiểm tra trên loa nhỏ:** lọc high-pass 200 Hz rồi đo bản xuất ra. Độ to sau lọc không được thấp hơn bản gốc quá 10 LU. Ghi số đo vào `build_report.json`.
   - Vẫn là loop −24 LUFS, không có tiếng "tách" ở điểm nối.
   - Thêm biến thể `fluorescent_flicker` (one-shot, khoảng 1–2 giây): tiếng tách, tiếng chớp và tiếng rè ngắt quãng khi đèn chập chờn.
2. **`game/scripts/audio/ambient_zone.gd`** (`class_name AmbientZone`, kế thừa `Area3D`):
   - Khi Player (layer 2) vào vùng, các emitter được gán cho vùng (`@export var emitters: Array[NodePath]`) to dần lên. Khi ra khỏi vùng thì nhỏ dần đi. Thời gian chuyển là `@export var fade_time`.
   - Nhiều vùng chồng nhau không làm âm bị nhảy đột ngột.
3. **`game/scripts/audio/reverb_zone.gd`** (`class_name ReverbZone`, kế thừa `Area3D`):
   - Khi Player ở trong vùng, đổi thông số reverb của bus `SFX` theo preset của vùng (ví dụ `room`, `corridor`, `bathroom`). Ra khỏi vùng thì trả về mặc định.
   - Nếu cần thêm hiệu ứng reverb vào bus `SFX` thì sửa `default_bus_layout.tres` (trong phạm vi lane E).
4. **Đèn tắt thì im tiếng:** thêm `game/scripts/audio/light_hum.gd` gắn vào `AmbientEmitter`:
   - `@export var light: Light3D`. Khi đèn `visible = false` hoặc `light_energy` gần 0 thì tiếng ù tắt ngay, không fade. Đèn bật lại thì tiếng ù phát lại.
   - Hàm `flicker(duration)` phát `fluorescent_flicker` và cho tiếng ù ngắt quãng trong `duration` giây. Chỉ xử lý phần âm thanh; việc làm đèn nhấp nháy là của lane khác.
5. **Scene thử `game/audio/test/zones_test.tscn`:**
   - Hai phòng nối nhau bằng hành lang. Mỗi khu có vùng âm và vùng reverb riêng.
   - Một đèn có `light_hum`, phím `L` bật/tắt đèn, phím `F` gọi `flicker(1.5)`.
   - Có Player của lane A (instance `res://scenes/player/player.tscn`) để đi qua lại và nghe thử.
6. **Test `game/tests/audio/`:**
   - Hum mới load được, là loop, có số đo sau high-pass 200 Hz trong report.
   - Player vào và ra `AmbientZone` thì âm lượng emitter thay đổi đúng hướng.
   - `ReverbZone` đổi và trả lại thông số reverb của bus.
   - Tắt đèn thì emitter của `light_hum` dừng; bật lại thì phát.

## Checklist hoàn thành
- [ ] Chạy lại `process.py --regenerate-raw` ra file giống nhau; tổng audio vẫn dưới 15 MB
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Mục Handoff ghi số đo độ to của hum trước và sau high-pass 200 Hz
- [ ] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [ ] Mục Handoff đã điền, ghi rõ phần nào **chưa nghe bằng tai**

## Cách kiểm tra
```
py -3 audio_source/process.py --regenerate-raw
pwsh tools/test.ps1 -Filter audio
```
Nghe thử: mở `res://audio/test/zones_test.tscn` và bấm F6.

## Handoff (agent điền)
