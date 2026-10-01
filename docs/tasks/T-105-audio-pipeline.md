# T-105 — Pipeline âm thanh và bộ âm môi trường đầu tiên
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-105-audio-pipeline`
- Phụ thuộc: P0 (xong)
- Loại: task thử tuần đầu

## Mục tiêu
Có quy trình lặp lại được: **file âm thanh gốc → xử lý → .ogg trong Godot**. Có bộ âm môi trường đầu tiên tạo được không khí "ký túc xá lúc nửa đêm". Đồng thời có hệ thống phát âm thanh 3D.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Yêu cầu
1. **Cài ffmpeg dạng portable** vào `D:\Tools\ffmpeg\`. Ghi đường dẫn vào `audio_source/README.md`.
2. **Nguồn âm thanh:** chỉ dùng **CC0**, CC-BY, hoặc **tự tổng hợp** bằng ffmpeg/Python (tiếng ù, tiếng ồn, tiếng gió đều làm được bằng bộ lọc).
   - Nguồn không cần đăng nhập: Kenney, OpenGameArt (lọc CC0).
   - Freesound cần tài khoản. Nếu cần file từ Freesound, liệt kê link vào Handoff để chủ dự án tải giúp.
3. **Bộ âm đầu tiên**, file gốc đặt trong `audio_source/raw/`:
   | Âm | Loại | Ghi chú |
   |---|---|---|
   | Quạt trần | Loop | |
   | Tiếng ù đèn tuýp | Loop | Có thể tự tổng hợp |
   | Dế hoặc côn trùng đêm, có xe máy xa | Loop | |
   | Nước nhỏ giọt | One-shot | Nhiều biến thể |
   | Bước chân dép lê trên gạch | One-shot | ≥4 biến thể |
   | Cửa gỗ cũ mở và đóng | One-shot | |
4. **Script xử lý `audio_source/process.py`** (Python 3 + ffmpeg), chạy lại được từ đầu:
   - Cắt và chuẩn hóa độ to theo LUFS: âm môi trường khoảng −24, SFX khoảng −18.
   - Loop có crossfade ở điểm nối.
   - SFX 3D xuất mono.
   - Xuất OGG Vorbis vào `game/audio/<ambience|sfx>/<tên>.ogg`.
   - Đặt `loop` cho các file loop trong file `.import`.
5. **Bus âm thanh:** tạo `game/default_bus_layout.tres` gồm `Master`, `Ambience`, `SFX`, `Voice`, `Music`. Bus `Ambience` có reverb nhẹ.
6. **Script trong `game/scripts/audio/`:**
   - `ambient_emitter.gd`: dựa trên `AudioStreamPlayer3D`, có chế độ loop, hoặc phát ngẫu nhiên theo khoảng thời gian, kèm biến thiên cao độ và âm lượng.
   - `footstep_player.gd`: hàm `play_footstep(surface: StringName)`, chọn ngẫu nhiên biến thể và không lặp lại biến thể vừa phát. Lane A sẽ nối hàm này vào `Player.footstep`.
7. **Scene nghe thử `game/audio/test/audio_test.tscn`:** một phòng tối, đặt các nguồn âm ở các vị trí khác nhau.
8. **`game/audio/CREDITS.md`:** ghi từng file: nguồn (URL), tác giả, giấy phép, đã chỉnh gì.
9. **Test `game/tests/audio/`:**
   - Mọi `.ogg` load được.
   - Bus layout có đủ 5 bus.
   - `footstep_player` không phát cùng một biến thể hai lần liên tiếp.

## Checklist hoàn thành
- [ ] Chạy lại `process.py` từ đầu thì ra đúng các file như cũ
- [ ] `pwsh tools/test.ps1` PASS
- [ ] Mở `audio_test.tscn` nghe được, không bị rè hoặc nổ, loop không có tiếng "tách" ở điểm nối
- [ ] Mọi file đều có dòng trong `CREDITS.md`; tổng dung lượng audio dưới 15 MB
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
