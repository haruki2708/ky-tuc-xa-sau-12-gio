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
- [x] Chạy lại `process.py` từ đầu thì ra đúng các file như cũ
- [x] `pwsh tools/test.ps1` PASS
- [ ] Mở `audio_test.tscn` nghe được, không bị rè hoặc nổ, loop không có tiếng "tách" ở điểm nối
- [x] Mọi file đều có dòng trong `CREDITS.md`; tổng dung lượng audio dưới 15 MB
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Phiên 2026-10-02 — Lane E / Codex

**Đã làm**
- Nhánh `lane-e/T-105-audio-pipeline`, workspace `D:\GAME_WORK\lane-e`, tạo từ `origin/main`. Commit triển khai `500613b` (`T-105: add reproducible spatial audio pipeline and sound pack`) đã push thành công; đủ 24 object LFS (12 WAV + 12 OGG).
- Cài ffmpeg 9.0.2 portable vào `D:\Tools\ffmpeg\ffmpeg-9.0.2-essentials_build\bin\ffmpeg.exe`, kiểm SHA256 ZIP; dùng Python có sẵn, không cài vào ổ C. Đường dẫn/nguồn/hash ở `audio_source/README.md`.
- `process.py`: tổng hợp nguyên bản bằng seed cố định; cắt/lọc, compressor cho SFX, loudnorm hai lượt, hiệu chỉnh theo OGG đo lại, crossfade 1 giây cho loop, mono 48 kHz, Vorbis q4 và `.import` đúng cờ loop. Có báo cáo LUFS/peak/SHA256/dung lượng tại `audio_source/build_report.json`.
- Bộ 12 âm: 3 ambience loop (quạt, đèn, côn trùng kèm xe máy xa), 3 giọt nước, 4 bước chân dép/gạch, mở và đóng cửa gỗ. Nguồn tự tổng hợp CC0, ghi công cụ AI hỗ trợ và từng WAV/OGG trong `game/audio/CREDITS.md`.
- 5 bus; Ambience có reverb nhẹ. `AmbientEmitter` hỗ trợ loop hoặc khoảng nghỉ ngẫu nhiên, pitch/volume variation và stop timer. `FootstepPlayer.play_footstep(&"tile")` không lặp clip liền trước. Scene phòng nghe thử và phím 0–7 solo nguồn; Esc thoát.
- Chỉ sửa vùng Lane E và checklist/Handoff của card này. Không sửa `STATUS.md`, `project.godot`, Player hoặc EventBus.

**Kiểm tra đã chạy**
- `py -3 audio_source/process.py --regenerate-raw` chạy lại từ đầu sau build thành công: `REBUILD RESULT: 12 WAV + 12 OGG SHA256 identical; report identical` (Python 3.14, ffmpeg 9.0.2).
- `AUDIO RESULT: 12 assets validated; raw + OGG = 6003785 bytes`. File lớn nhất 2.016.044 bytes; cả WAV và OGG cộng lại dưới 15 MB.
- Ambience −24.39 đến −23.95 LUFS; SFX −18.30 đến −17.95 LUFS; true peak toàn bộ ≤−3.65 dBTP. Chênh mẫu tại biên loop tối đa 0.008074, dưới ngưỡng tự động 0.02. Số đo không thay thế nghe bằng tai.
- `pwsh tools/test.ps1`: **`RESULT: 12 passed, 0 failed`**, exit 0 (7 test audio + 5 core). Bao gồm load/decode toàn bộ OGG và cờ loop, bus/routing/reverb, 128 bước chân không lặp và đủ 4 biến thể, bank rỗng/trùng/surface chưa hỗ trợ, emitter timer/stop/stream độc lập và scene load/phát nguồn.
- Scene chạy ngoài headless với `--audio-driver WASAPI --max-fps 30 --quit-after 180`: **`SCENE EXIT: 0`**; Vulkan Forward+, WASAPI 48 kHz/2 kênh. Không có script/runtime ERROR; có warning Vulkan loader về registry layer manifest. Đây là kiểm tra khởi chạy, **chưa nghe/duyệt chất âm bằng tai**.
- Lượt test sandbox ban đầu bị lỗi quyền ghi `user://logs` và đọc certificate store dù PASS; đã chạy lại ngoài sandbox, PASS sạch. `git diff --cached --check` không báo lỗi; WAV/OGG qua Git LFS.

**Còn dở / chưa đạt**
- Checklist nghe thử chưa đánh dấu: cần người nghe scene ≥60 giây mỗi loop để xác nhận không rè/nổ/tách, cảm nhận dép lê/gỗ/côn trùng và mức mix. Không tuyên bố test tự động đã xác nhận chất lượng cảm nhận. Bộ tổng hợp này cần được duyệt trước khi dùng làm âm thanh cuối.
- Chưa nối audio vào gameplay/main; đây là ranh giới sở hữu file, không phải lỗi pipeline. Không suy đoán luật chơi hoặc cốt truyện.

**Cách kiểm tra / tích hợp**
1. Từ gốc repo: `py -3 audio_source/process.py --regenerate-raw`, rồi `pwsh tools/test.ps1`.
2. Mở nghe: `& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/audio_test.tscn --windowed --resolution 1280x720`.
3. Phím `0` mix; `1` quạt; `2` đèn; `3` côn trùng/xe máy; `4` nước; `5` mở cửa; `6` đóng cửa; `7` bước chân. Hướng dẫn/API chi tiết ở `audio_source/README.md`.

**Yêu cầu thay đổi ngoài phạm vi**
- Lane A/Integrator nối `Player.footstep` vào `FootstepPlayer.play_footstep(&"tile")` trong scene/script người chơi thuộc Lane A. Hiện chỉ có bank `tile`; surface khác im lặng để tránh tự chọn âm vật liệu chưa được chốt.
- Lane B/Integrator đặt các `AmbientEmitter` vào level/main sau khi chốt vị trí nguồn âm. Không cần autoload, signal EventBus mới hoặc thay đổi `project.godot`; bus mặc định đã được Godot tự nạp và test xác nhận.
- Không có câu hỏi luật chơi/cốt truyện phát sinh trong task này.

**Blocked:** Không còn chặn kỹ thuật; chờ chủ dự án/QA xác nhận checklist nghe thực tế. Lỗi mạng/sandbox trong phiên đã vượt qua bằng quyền chạy ngoài sandbox, push nhánh task đã thành công.
