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
