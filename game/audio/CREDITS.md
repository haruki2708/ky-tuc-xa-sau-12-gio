# Nguồn âm thanh T-105

Toàn bộ WAV và OGG dưới đây được **tự tổng hợp**, không lấy mẫu từ game, thư viện hoặc bản ghi âm bên ngoài. Công thức và seed nằm trong [process.py](../../audio_source/process.py).

- Tác giả: Lane E, dự án “Ký túc xá sau 12 giờ”.
- Công cụ AI: OpenAI Codex viết mã tổng hợp/processing; Python 3 tạo waveform; FFmpeg 9.0.2 lọc và encode. Đây là nội dung âm thanh tạo bằng quy trình có AI hỗ trợ, cần khai báo tương ứng khi phát hành.
- Giấy phép cho các waveform gốc và bản OGG được tạo trong task này: **CC0 1.0**, theo [CC0 Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).
- URL nguồn của từng dòng: repository riêng của dự án, đường dẫn tới mã tổng hợp [T-105/process.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-105-audio-pipeline/audio_source/process.py). Không yêu cầu đăng nhập để tải nguồn âm bên thứ ba vì không dùng nguồn bên thứ ba.
- Mọi file: mono 48 kHz, cắt theo thời lượng trong script, lọc 35 Hz–11 kHz, loudnorm hai lượt và hiệu chỉnh gain theo OGG đo lại, Vorbis q4. Loop thêm crossfade 1 giây, −24 LUFS; SFX thêm compressor kiểm soát transient và fade 8/80 ms, −18 LUFS. `raw` bên dưới tương đối với `audio_source/raw/`, `OGG` tương đối với `game/audio/`.

| WAV gốc | OGG | Cách tạo / chỉnh riêng | Nguồn, tác giả, giấy phép |
|---|---|---|---|
| `ceiling_fan.wav` | `ambience/ceiling_fan.ogg` | Noise lọc thấp, điều biên nhịp cánh quạt, nền động cơ 60/120 Hz; loop | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `fluorescent_hum.wav` | `ambience/fluorescent_hum.ogg` | Họa âm 100/200/400 Hz, dao động nhẹ; loop | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `night_insects_motorbike.wav` | `ambience/night_insects_motorbike.ogg` | Chirp 4.2/5.1 kHz, xung côn trùng và động cơ xa đổi tần số/envelope; loop | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `water_drip_01.wav` | `sfx/water_drip_01.ogg` | Sin giảm tần, decay ngắn và noise, seed 10511; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `water_drip_02.wav` | `sfx/water_drip_02.ogg` | Biến thể tần số/seed 10512; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `water_drip_03.wav` | `sfx/water_drip_03.ogg` | Biến thể tần số/seed 10513; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `slipper_tile_01.wav` | `sfx/slipper_tile_01.ogg` | Cú đập mềm, noise ma sát kéo dép, cộng hưởng gạch, seed 10521 | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `slipper_tile_02.wav` | `sfx/slipper_tile_02.ogg` | Biến thể decay/tần số/ma sát, seed 10522 | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `slipper_tile_03.wav` | `sfx/slipper_tile_03.ogg` | Biến thể decay/tần số/ma sát, seed 10523 | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `slipper_tile_04.wav` | `sfx/slipper_tile_04.ogg` | Biến thể decay/tần số/ma sát, seed 10524 | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `wood_door_open.wav` | `sfx/wood_door_open.ogg` | Tiếng chốt đầu, kẽo kẹt họa âm điều tần và ma sát gỗ; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |
| `wood_door_close.wav` | `sfx/wood_door_close.ogg` | Kẽo kẹt, tiếng đập gỗ cuối chuyển động; one-shot | Mã nguồn T-105 trên; Lane E; CC0 1.0 |

Các hình học trong scene nghe thử là primitive Godot, không có model/texture tải ngoài.
