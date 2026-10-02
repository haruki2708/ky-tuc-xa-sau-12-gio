# T-114 — Sửa tiếng ù đèn tuýp, vùng âm thanh và đèn tắt thì im tiếng
- Lane: E (Âm thanh) | Trạng thái: done | Agent:
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
- [x] Chạy lại `process.py --regenerate-raw` ra file giống nhau; tổng audio vẫn dưới 15 MB
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Mục Handoff ghi số đo độ to của hum trước và sau high-pass 200 Hz
- [x] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [x] Mục Handoff đã điền, ghi rõ phần nào **chưa nghe bằng tai**

## Cách kiểm tra
```
py -3 audio_source/process.py --regenerate-raw
pwsh tools/test.ps1 -Filter audio
```
Nghe thử: mở `res://audio/test/zones_test.tscn` và bấm F6.

## Handoff (agent điền)

### Phiên 2026-10-02 — Lane E / Codex

**Đã làm**
- Workspace `D:\GAME_WORK\lane-e`; nhánh `lane-e/T-114-audio-zones` tạo từ `origin/main` tại `fc7cee2`. Đã đọc Review T-105. Commit triển khai **`fbfedad`** (`T-114: add audio zones and light-driven fluorescent ambience`) đã push thành công, gồm 4 object LFS mới/thay đổi. Không push main.
- Hum giữ 100 Hz, thêm rè chấn lưu ở 300–2900 Hz có biến thiên nhẹ không đều và rít nhỏ 6.2 kHz; loop 12 giây với crossfade/căn điểm nối. Thêm `fluorescent_flicker` one-shot 1.5 giây, click và rè ngắt quãng; nguồn tự tổng hợp, CC0, khai báo AI trong `CREDITS.md`.
- `AmbientZone` kế thừa `Area3D` qua lớp chung `AudioZone`, phát hiện body layer 2, fade gain theo `fade_time`; emitter dùng mức lớn nhất của các zone để không cộng dồn hoặc bị zone khác ghi đè. Đảo fade từ gain hiện tại; giữ mute khi phát clip mới. Theo dõi nhiều body, xử lý body bị xóa và dọn contribution khi zone bị xóa.
- `ReverbZone` đổi SFX reverb theo ROOM/CORRIDOR/BATHROOM. Vùng có `mix_priority` cao hơn thắng; cùng ưu tiên thì vùng vào gần nhất thắng. Tween chung chuyển từ thông số hiện tại; rời vùng trả về vùng đang chiếm còn lại hoặc baseline; unload cuối trả baseline và hủy tween. SFX mặc định wet=0, giữ âm dry ngoài vùng.
- `LightHum` kế thừa AmbientEmitter, gắn thay script trên player 3D và gán `light: Light3D`. Visibility=false dừng ngay qua signal; energy≤0.001/ancestor ẩn/light bị xóa dừng ở process frame kế tiếp, không fade. Bật lại phát hum; `flicker(duration)` có playback 3D riêng, ngắt hum và giữ gain của zone; tắt đèn hủy cả hai âm. Không thay đổi ánh sáng để tự tạo nhấp nháy thị giác.
- `zones_test.tscn`: hai phòng, hành lang, ba cặp vùng ambience/reverb, Player Lane A, sàn có metadata tile và bước chân; phím L/F. Geometry chỉ nằm trong fixture thuộc `game/audio/test/`.
- README có API, giới hạn và cách nghe thử; `.import`/`.uid` đã commit. Không cài thêm công cụ, plugin hoặc phần mềm trên ổ C.

**Số đo và kiểm tra**
- Hum OGG: **−23.97 LUFS**; sau `highpass=f=200:p=2`: **−25.99 LUFS**; suy giảm **2.02 LU**, đạt ≤10 LU. Đo input của loudnorm sau lọc, không chuẩn hóa lại để che suy giảm. `build_report.json` lưu hai số đo và SHA256 khớp asset.
- Hum true peak **−15.04 dBTP**, chênh mẫu hai biên **0.0066025** (<0.02); flicker **−18.01 LUFS**, **−7.02 dBTP**, dài **1.5 s**, không loop. Đây là phép đo tín hiệu, không khẳng định bằng tai là không có tiếng tách.
- `py -3 audio_source/process.py --regenerate-raw`: **`AUDIO RESULT: 13 assets validated; raw + OGG = 6173525 bytes`**, dưới 15 MB.
- Chạy lại từ đầu, so report/hash: **`REBUILD RESULT: 13 WAV + 13 OGG SHA256 identical; report identical`**. So với report `origin/main`: **`PRESERVATION RESULT: 11 approved WAV/OGG pairs unchanged from origin/main`**. Các âm đã được duyệt ngoài hum giữ nguyên byte.
- `pwsh tools/test.ps1 -Filter audio`: **`RESULT: 15 passed, 0 failed`**, exit 0, không lỗi cleanup.
- `pwsh tools/test.ps1`: **`RESULT: 57 passed, 0 failed`**, exit 0.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0.
- Test mới kiểm tra HP200/hash/import, body vào/ra/đảo fade, overlap dùng chung emitter và phát lại không làm mất mute, layer khác/multiple bodies/body bị xóa, reverb priority/restore/unload, đèn visibility/energy/ancestor/flicker, Player thật đi qua fixture và phím L/F.
- Khởi chạy `zones_test.tscn` ngoài headless với Vulkan Forward+ và WASAPI 48 kHz/2 kênh, `--max-fps 30 --quit-after 180`: **`SCENE RESULT: exit 0`**. Không có ERROR script/runtime; warning Vulkan loader về registry layer manifest có sẵn trong môi trường.
- Kiểm tra danh sách file staged nằm đúng vùng được phép; `git diff --cached --check` sạch. Card này chỉ đổi checklist/Handoff.

**Chưa nghe bằng tai / giới hạn**
- **Chưa nghe hum mới, flicker hoặc chuyển vùng/reverb bằng tai; chưa xác nhận trên loa laptop thật.** HP200 đạt yêu cầu mô phỏng tín hiệu; cần chủ dự án nghe lại để duyệt độ rõ/chất âm và điểm nối loop.
- Reverb tác động lên bus SFX toàn cục cho một listener; chưa hỗ trợ split-screen hoặc thay bus layout trong lúc zone đang hoạt động. Các NodePath và `light` gán trước khi vào cây scene. Preset/ưu tiên là lựa chọn kỹ thuật của fixture, không áp đặt bố trí tầng hay luật chơi.
- Không thêm bank bước chân bê tông/sàn ướt: card yêu cầu giữ các âm khác và chưa có yêu cầu asset mới cho các bề mặt này.

**Cách kiểm tra**
1. Chạy pipeline và hai lệnh test/check như trên từ gốc repo.
2. Mở `res://audio/test/zones_test.tscn`, F6. WASD/Shift/chuột/Esc theo Player; đi từ phòng đầu qua hành lang sang phòng thứ hai. L bật/tắt đèn phòng đầu; F gọi flicker 1.5 giây (chỉ âm thanh). Nghe rõ nhất hum khi đứng trong phòng đầu.
3. Nghe hum trên loa laptop và tai nghe; kiểm tra nhiều chu kỳ loop. Nghe fade/reverb khi qua cửa, bật/tắt và flicker cả lúc ở trong/ngoài vùng. Chi tiết API ở `audio_source/README.md`.

**Yêu cầu thay đổi ngoài phạm vi**
- Integrator đổi emitter hum ở `game/scenes/main/main.tscn` sang script `light_hum.gd` và gán Light3D tương ứng để đèn hành lang chính cũng điều khiển hum; file OGG hum đã được thay nên main hiện dùng chất âm mới nhưng chưa có liên kết bật/tắt đèn.
- Lane B/Integrator đặt AmbientZone/ReverbZone, shape và NodePath emitter vào level T-112 theo bố trí đã chốt. Phần hình ảnh chập chờn gọi `LightHum.flicker(duration)` từ lane sở hữu đèn; Lane E không tự sửa light controller, level hoặc Player.
- Không cần thêm autoload, signal EventBus, input action toàn cục hoặc sửa `project.godot`. Không phát sinh câu hỏi luật chơi/cốt truyện.

**Blocked:** Không còn chặn kỹ thuật; chờ chủ dự án nghe duyệt chất âm. Các lần chạy sandbox bị lỗi credential LFS, log/certificate/editor settings; đã chạy lại ngoài sandbox thành công. Checkout LFS dừng giữa chừng đã được lưu bằng stash dự phòng tên `T-114: preserve files from interrupted LFS checkout` trước khi chuyển nhánh lại; stash chỉ là trạng thái checkout lỗi, không cần áp vào nhánh task.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`.** Sau merge: `test.ps1` → `RESULT: 62 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi. Hum mới đạt yêu cầu loa nhỏ: sau high-pass 200 Hz chỉ giảm **2,02 LU** (giới hạn 10 LU). 11 âm đã được duyệt giữ nguyên byte.
- `AmbientZone` dùng mức lớn nhất giữa các vùng chồng nhau, nên âm không bị cộng dồn. `ReverbZone` có ưu tiên và trả về mặc định đúng. `LightHum` xử lý đủ các trường hợp đèn ẩn, đèn tắt năng lượng, node cha bị ẩn.
- Test rất kỹ (15 test audio), gồm cả Player thật đi qua fixture.
- Handoff trung thực: ghi rõ **chưa nghe bằng tai**.
- Integrator đã xử lý yêu cầu thay đổi: `HumNear`/`HumFar` trong `main.tscn` dùng `light_hum.gd`, gán `TubeLight1`/`TubeLight2`. Test core kiểm tra tắt đèn thì hum dừng, bật lại thì phát.

**Ghi chú (không chặn):**
1. Điểm nối loop của hum mới có chênh mẫu 0,0066, cao hơn bản cũ (0,0003) nhưng dưới ngưỡng 0,02. Chủ dự án nghe kỹ chỗ nối, khoảng mỗi 12 giây.
2. `ReverbZone` sửa trực tiếp hiệu ứng reverb của bus SFX. Khi có menu âm thanh (T-116), lane D không được thay bus layout trong lúc đang chơi.

**Chấm điểm (1–5):** phạm vi 5 · checklist 4 (thiếu nghe thử, đã ghi trung thực) · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
