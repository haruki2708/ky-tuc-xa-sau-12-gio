# Nguồn âm thanh T-105 / T-114

Toàn bộ WAV và OGG dưới đây được **tự tổng hợp**, không lấy mẫu từ game, thư viện hoặc bản ghi âm bên ngoài. Công thức và seed nằm trong [process.py](../../audio_source/process.py).

- Tác giả: Lane E, dự án “Ký túc xá sau 12 giờ”.
- Công cụ AI: OpenAI Codex viết mã tổng hợp/processing (T-105, T-114); Anthropic Claude viết phần bước chân T-123; Python 3 tạo waveform; FFmpeg 9.0.2 lọc và encode. Đây là nội dung âm thanh tạo bằng quy trình có AI hỗ trợ, cần khai báo tương ứng khi phát hành.
- Giấy phép cho các waveform gốc và bản OGG được tạo trong task này: **CC0 1.0**, theo [CC0 Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).
- URL nguồn của từng dòng: repository riêng của dự án, đường dẫn tới mã tổng hợp [T-105/process.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-105-audio-pipeline/audio_source/process.py). Không yêu cầu đăng nhập để tải nguồn âm bên thứ ba vì không dùng nguồn bên thứ ba.
- Riêng hum cập nhật và flicker mới: [T-114/process.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-114-audio-zones/audio_source/process.py), cùng tác giả Lane E, CC0 1.0, OpenAI Codex hỗ trợ viết công thức, Python 3 tổng hợp và FFmpeg 9.0.2 xử lý; không dùng mẫu bên ngoài. Các âm khác giữ nguyên.
- Mọi file: mono 48 kHz, cắt theo thời lượng trong script, lọc 35 Hz–11 kHz, loudnorm hai lượt và hiệu chỉnh gain theo OGG đo lại, Vorbis q4. Loop thêm crossfade 1 giây, −24 LUFS; SFX thêm compressor kiểm soát transient và fade 8/80 ms, −18 LUFS. `raw` bên dưới tương đối với `audio_source/raw/`, `OGG` tương đối với `game/audio/`.

| WAV gốc | OGG | Cách tạo / chỉnh riêng | Nguồn, tác giả, giấy phép |
|---|---|---|---|
| `ceiling_fan.wav` | `ambience/ceiling_fan.ogg` | Noise lọc thấp, điều biên nhịp cánh quạt, nền động cơ 60/120 Hz; loop | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `fluorescent_hum.wav` | `ambience/fluorescent_hum.ogg` | Nền 100 Hz, rè 300–2900 Hz biến thiên nhẹ không đều, rít nhỏ 6200 Hz; crossfade và căn điểm nối; đo HP200. **−44 LUFS** theo chủ dự án (D-017) | Mã nguồn T-114 trên; Lane E; CC0 1.0 |
| `fluorescent_flicker.wav` | `sfx/fluorescent_flicker.ogg` | Click relay, burst rè chấn lưu ngắt quãng, seed 11401; one-shot 1.5 giây, compressor/fade/−18 LUFS | Mã nguồn T-114 trên; Lane E; CC0 1.0 |
| `night_insects_motorbike.wav` | `ambience/night_insects_motorbike.ogg` | Chirp 4.2/5.1 kHz, xung côn trùng và động cơ xa đổi tần số/envelope; loop | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `water_drip_01.wav` | `sfx/water_drip_01.ogg` | Sin giảm tần, decay ngắn và noise, seed 10511; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `water_drip_02.wav` | `sfx/water_drip_02.ogg` | Biến thể tần số/seed 10512; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `water_drip_03.wav` | `sfx/water_drip_03.ogg` | Biến thể tần số/seed 10513; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `slipper_tile_01.wav` | `sfx/slipper_tile_01.ogg` | **T-123, làm lại:** dép tổ ong/dép lào đi bộ trên gạch men. Tiếng "lẹp" gót chạm sàn (noise lọc thấp 1,4 kHz, attack 7 ms, thân 170–230 Hz rất nhẹ), tiếng "xẹp" đế dép đập lại gót 0,13–0,19 s sau (noise dải 1,2–2,5 kHz, có rung kép), ma sát nhẹ ở giữa. Không compressor, −56 LUFS, seed 12301 | Mã nguồn T-105 trên; Lane E (Claude, integrator, làm thay theo yêu cầu chủ dự án); CC0 1.0 |
| `slipper_tile_02.wav` | `sfx/slipper_tile_02.ogg` | T-123: biến thể thời điểm và độ mạnh "lẹp"/"xẹp", seed 12302 | Mã nguồn T-105 trên; Lane E (Claude); CC0 1.0 |
| `slipper_tile_03.wav` | `sfx/slipper_tile_03.ogg` | T-123: biến thể thời điểm và độ mạnh "lẹp"/"xẹp", seed 12303 | Mã nguồn T-105 trên; Lane E (Claude); CC0 1.0 |
| `slipper_tile_04.wav` | `sfx/slipper_tile_04.ogg` | T-123: biến thể thời điểm và độ mạnh "lẹp"/"xẹp", seed 12304 | Mã nguồn T-105 trên; Lane E (Claude); CC0 1.0 |
| `slipper_run_01.wav` | `sfx/slipper_run_01.ogg` | T-123, mới: bước chạy nhẹ; "xẹp" sát hơn (0,075–0,105 s) và mạnh hơn, −53 LUFS, seed 12311 | Mã nguồn T-105 trên; Lane E (Claude); CC0 1.0 |
| `slipper_run_02.wav` | `sfx/slipper_run_02.ogg` | T-123, mới: bước chạy nhẹ; "xẹp" sát hơn (0,075–0,105 s) và mạnh hơn, −53 LUFS, seed 12312 | Mã nguồn T-105 trên; Lane E (Claude); CC0 1.0 |
| `slipper_run_03.wav` | `sfx/slipper_run_03.ogg` | T-123, mới: bước chạy nhẹ; "xẹp" sát hơn (0,075–0,105 s) và mạnh hơn, −53 LUFS, seed 12313 | Mã nguồn T-105 trên; Lane E (Claude); CC0 1.0 |
| `slipper_run_04.wav` | `sfx/slipper_run_04.ogg` | T-123, mới: bước chạy nhẹ; "xẹp" sát hơn (0,075–0,105 s) và mạnh hơn, −53 LUFS, seed 12314 | Mã nguồn T-105 trên; Lane E (Claude); CC0 1.0 |
| `wood_door_open.wav` | `sfx/wood_door_open.ogg` | Tiếng chốt đầu, kẽo kẹt họa âm điều tần và ma sát gỗ; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `wood_door_close.wav` | `sfx/wood_door_close.ogg` | Kẽo kẹt, tiếng đập gỗ cuối chuyển động; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |

Các hình học trong scene nghe thử là primitive Godot, không có model/texture tải ngoài.
