# T-212 — G0 âm thanh của lane F

Ứng viên chuông riêng, chưa tích hợp core và **chưa được chủ dự án nghe**. Bảng nguồn/marker và yêu cầu G1 nằm trong Handoff `docs/tasks/T-212-graphics-audio-anchors.md`.

## Tái tạo và số đo

Tại `D:\GAME_WORK\lane-f`:

```powershell
py -3 audio_source/graphics_upgrade/fire_bell_process.py
```

Python stdlib và FFmpeg đã có trong `D:\Tools`, không cài thêm. Script dùng lại helper E trong `audio_source/process.py`, chỉ ghi bank mới. Tổng hợp 16 nhát chuông trong 4 giây, nhịp 0,25 giây, cộng họa âm kim loại 840/1325/1870/2535 Hz với attack 3 ms và decay 85 ms. Sóng tuần hoàn giữ đuôi nhát trước qua biên; không chứa lời. Vorbis q4, mono 48 kHz, gain hiệu chỉnh từ phép đo OGG, không đổi bus toàn game.

`build_report.json`: −35,97 LUFS, true peak −22,14 dBTP, chênh mẫu ở biên 0,0015163; WAV 384.044 byte, OGG 17.756 byte. Mục tiêu −36 ±1 LUFS, peak ≤−2 dBTP, chênh biên <0,01. Những ngưỡng này chỉ kiểm tín hiệu, không chứng nhận chất âm hay mức nghe trên loa. Công thức quyết định hoàn toàn, không seed ngẫu nhiên; byte tái tạo cần cùng Python/FFmpeg. Hash lưu trong report.

Nguồn/license và khai báo AI: [CREDITS](../../game/audio/graphics_upgrade/CREDITS.md). Các credits cũ của E giữ nguyên.

## Fixture nghe

F6 `res://audio/graphics_upgrade/fire_bell_preview.tscn`, hoặc chạy từ gốc repo sau khi được xếp lượt dùng Godot:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/graphics_upgrade/fire_bell_preview.tscn --windowed --resolution 960x540
```

Fixture chỉ có listener/camera và âm, màn hình nền trống, vào cảnh im lặng. Không ghi settings; bus hiện có được giữ nguyên. Cả mẫu mới và tham chiếu phát qua SFX, gain −4 dB, unit_size 8 m, nguồn mặc định trước listener 8 m để so sánh cùng điều kiện. Không có room reverb/môi trường thật nên chưa đại diện mix chương 3.

| Phím | Tác dụng |
|---|---|
| 1 | Mẫu mới 4 giây một lượt |
| 2 | Mẫu mới loop liên tục; nghe ≥60 giây để đánh giá biên nối |
| 3 | Chuông cũ `ch1v2/lock_alarm.ogg`, không sửa tài nguyên gốc |
| 4 | Loop mẫu mới, dừng sau 20 giây hoạt động của fixture |
| P | Pause/unpause cả scene và đồng hồ fixture |
| 0 | Dừng và giải phóng nguồn, thoát pause nếu đang pause |
| Trái / phải | Đổi x nguồn thành −4 / +4 m |
| Lên / xuống | Nguồn thẳng trước listener 2 / 20 m |
| C | Trở về nguồn (0, 0, −8) |
| R | Dừng và nạp lại fixture, phải im lặng |
| Esc | Dừng và thoát qua App.quit |

Mỗi lần đổi clip chỉ giữ một player. Chọn clip mới đưa fixture ra khỏi pause. Loop chỉ bật trên bản `duplicate()` của stream. `stop_preview()` dừng timer, dừng/gỡ player; unload dừng player. Phím 4 minh họa việc dừng loop bằng deadline độc lập, **không phải triển khai timer D-075 của core**.

## Đường nối đề nghị, chờ G1/core

- Stream: `res://audio/graphics_upgrade/fire_bell_soft.ogg`, import **loop=false**. Caller có thể chờ `finished` cho một lượt. Nếu cần vòng liên tục thì duplicate stream, bật loop ở bản sao, gọi `stop()` theo lifecycle/deadline do core quản lý; không chờ `finished` để cắt loop.
- `Chapter3Director._ring_bell()` hiện lặp `play()`/`await finished` dựa wall clock, chỉ kiểm hết hạn/chết giữa clip. Mẫu mới dài 4 giây có thể tăng sai số cắt; core phải review deadline 20 giây, pause/death/reload trước khi nối. Không thay trực tiếp `FIRE_BELL_STREAM` trong G0.
- Chỉ một nguồn chuông ở đầu xa hành lang, không phát thêm ở nút bấm `FireAlarm1F`. Core giữ một sự kiện noise 45 m và kéo xác. F không phát sự kiện noise, không đồng bộ AI theo nhát chuông hay animation.

## Danh sách còn chờ nghe

- [ ] Chuông mới/cũ ở 8 m, mẫu mới ở 2/20 m và trái/phải; âm lượng nhỏ nhưng nhận diện được, không chói/rè.
- [ ] Loop ≥60 giây: không click, nhịp đều; phím 4/P/0/R cắt và resume như mô tả.
- [ ] Sau G1/G3: chuông tầng 1 cảnh thật chương 3, 20 giây, không phát ở chương 4, một sự kiện mồi; chủ dự án nghe lại trong mix.
- [ ] Quản lý: kéo dao theo đầu dao, tiếng nói/nhịp bước; không phát đôi từ animation.
- [ ] Bình chữa cháy: core chốt wiring SFX trước, sau đó nghe tại bình tầng 2.
- [ ] Giọng/foley xác và cửa 407, kim loại/vải/bước chân trong phòng mẫu; giữ nguyên lời đã duyệt.
- [ ] Cuộc gọi/loa chương 2–4, năm câu T-205, hai giọng y tá và âm chương 3–4 còn chờ nghe theo STATUS/T-200; không thu lại trong G0.

Test mới: `game/tests/audio/test_graphics_fire_bell.gd` kiểm decode/hash/biên, stream dùng chung không bị bật loop, phát qua cuối clip, pause/stop/disposal/tạo lại và deadline fixture. Full test/check và kết quả thực tế ghi tại Handoff; không lấy fixture thay nghiệm thu cảnh thật.

# T-218 — Âm thanh phòng 407 khớp đồ G3

Không thêm file âm mới: chỉ dời nguồn âm có sẵn cho khớp quạt trần, đèn tuýp, vòi sen và gương mới (D-103…D-109). Âm lượng không đổi. Bảng đo lệch trước/sau nằm trong Handoff `docs/tasks/T-218-room407-object-audio.md`.

## Cảnh nghe thử

F6 `res://audio/graphics_upgrade/room407_audio_preview.tscn`, hoặc chạy từ gốc repo trên Windows:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/graphics_upgrade/room407_audio_preview.tscn --windowed --resolution 960x540
```

Dựng phòng 407 đủ đồ (bản chơi), mở im lặng, người nghe là camera cố định. Cảnh không có người chơi nên không có vùng âm: phím bật từng nguồn trực tiếp. Không ghi settings, không phát noise cho AI. Tiêu đề cửa sổ hiện trạng thái hiện tại (vị trí mới/cũ, quạt, đèn, nước, hơi nước).

| Phím | Tác dụng |
|---|---|
| F | Bật/tắt tiếng quạt trần |
| L | Bật/tắt đèn tuýp (tiếng ù đèn đi theo đèn) |
| K | Bật/tắt chập chờn bằng `flicker_light.gd` thật của đèn mới (tiếng ù tắt/bật đúng nhịp đèn) |
| 1 / 2 / 3 | Nước lạnh (1 °C) / ấm (37 °C) / sôi (81 °C) |
| 0 | Tắt nước |
| S | Bật/tắt tiếng hơi nước |
| M | `mirror_shiver` (cue ở gương, chương 2 slot 12) |
| T | Đổi **vị trí mới ↔ cũ** của nguồn, để so trước/sau cùng một âm |
| C | Người nghe ở giữa phòng (3,5; 1,6; −3,0) |
| B | Người nghe ở cửa nhà tắm (5,3; 1,6; −4,4), nhìn về phía vòi sen |
| Space | Tắt hết |
| R | Nạp lại cảnh (phải im lặng) |
| Esc | Tắt hết và thoát qua `App.quit` |

Vị trí "cũ" là trước T-218: quạt (2; 2,4; −2,5), tiếng ù đèn đúng tâm bóng PS1, nước và cue ở giữa khoang tắm (6,18; 1,2; −6,32).

## Những gì đổi trong code

- `room_407.tscn` (chỉ hai node âm): `FanAmbience` y 2,4 → 2,54 (tâm cánh quạt mới); `LightHum` cao hơn tâm đèn 6 cm (tâm hai bóng tuýp mới). `volume_db`, `unit_size`, `max_distance`, stream giữ nguyên.
- `shower_audio.gd`: tiếng nước phát từ `Ch2Bathroom/Water` (chỗ nước rơi thấy được); `mirror_shiver` phát từ `Ch2Bathroom/Reflection` (chỗ bóng quản lý hiện ra trên gương nhỏ), dự phòng `ReflectiveMirrorSmall`. Tìm node từ Room407 chứa ShowerStall; thiếu thì giữ chỗ cũ (giữa khoang tắm), không bao giờ về gốc thế giới. Đẩy cửa và `door_burst` giữ chỗ cũ. `follow_fixtures = false` đưa mọi nguồn về chỗ cũ (dùng cho so sánh). API `set_water`, `set_steam`, `play_cue`, `play_door_push` không đổi.
- `light_hum.gd` không đổi: tiếng ù đã bám năng lượng thật của đèn, nhịp chập chờn của đèn mới (D-104) không đổi nên không cần sửa.

## Danh sách còn chờ nghe (T-218)

- [ ] Quạt (F, C): vẫn nhỏ, không đổi tông; từ giữa phòng nghe như treo trên đầu.
- [ ] Đèn (L, K): ù và chập chờn khít nhịp đèn, không click lạ khi bật lại (hum khởi động lại mỗi lần đèn sáng, như trước).
- [ ] Nước (1/2/3, B vs C, T): từ vòi sen mới thay vì giữa khoang; không to hơn, không chói.
- [ ] `mirror_shiver` (M, T): lệch về phía gương nhỏ, tai nghe thấy từ phía tường tây nhà tắm.
- [ ] Cảnh thật: chương 1 phòng 407 khi đèn chập (tiếng ù đúng nhịp), chương 1–4 tiếng quạt trong phòng, chương 2 nhà tắm (tắm nước lạnh/ấm/sôi, slot 12 bóng quản lý trong gương).
