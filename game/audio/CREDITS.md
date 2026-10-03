# Nguồn âm thanh T-105 / T-114 / T-123 / T-130 / T-131 / T-133

Toàn bộ WAV và OGG dưới đây được **tự tổng hợp**, không lấy mẫu từ game, thư viện hoặc bản ghi âm bên ngoài. Công thức và seed nằm trong [process.py](../../audio_source/process.py).

- Tác giả: Lane E, dự án “Ký túc xá sau 12 giờ”.
- Công cụ AI: OpenAI Codex viết mã tổng hợp/processing (T-105, T-114, T-130); Anthropic Claude viết phần bước chân T-123; Python 3 tạo waveform; FFmpeg 9.0.2 lọc và encode. Đây là nội dung âm thanh tạo bằng quy trình có AI hỗ trợ, cần khai báo tương ứng khi phát hành.
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

## T-130 — hiệu ứng đoạn 1–2

Nguồn của **từng WAV/OGG** bên dưới: [T-130/process.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-130-segment12-sounds/audio_source/process.py), hàm `synthesize_segment12`. Tác giả Lane E / dự án; giấy phép **CC0 1.0**; OpenAI Codex hỗ trợ viết công thức, Python 3 tổng hợp, FFmpeg 9.0.2 xử lý. Không dùng bản ghi, giọng nói, TTS hoặc mẫu bên thứ ba. Seed 13001–13011 cố định. Các âm trước T-130 giữ nguyên hash.

Mono PCM16/48 kHz ở `audio_source/raw/`, OGG Vorbis q4 ở `game/audio/`. Cắt theo thời lượng, lọc 35 Hz–11 kHz, đo/chuẩn hóa LUFS hai lượt và hiệu chỉnh theo OGG. One-shot qua compressor và fade 8/80 ms; hai loop crossfade 1 giây. Thời lượng trong bảng là bản OGG; raw loop dài hơn 1 giây để crossfade.

| WAV gốc | OGG | Tổng hợp / chỉnh riêng | Nguồn, tác giả, giấy phép |
|---|---|---|---|
| `knock_01.wav` | `sfx/knock_01.ogg` | 3 cú gõ đốt ngón tay, noise ngắn và cộng hưởng gỗ; cách 0.43 s; 1.5 s; −30 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `knock_02.wav` | `sfx/knock_02.ogg` | 3 cú gõ cách 0.73 s, trầm/decay dài hơn; 2.1 s; −30 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `knock_03.wav` | `sfx/knock_03.ogg` | 3 cú gõ cách 1.03 s, cộng hưởng trầm và nặng nhất; 2.9 s; −30 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `speaker_chime.wav` | `sfx/speaker_chime.ogg` | Hai âm 880/660 Hz có họa âm lệch, tanh distortion và hiss; 1.6 s; −32 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `speaker_on.wav` | `sfx/speaker_on.ogg` | Bụp 105 Hz và rè ngắn; 0.55 s; −32 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `speaker_off.wav` | `sfx/speaker_off.ogg` | Bụp 76 Hz và rè tắt dần; 0.55 s; −32 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `speaker_static.wav` | `ambience/speaker_static.ogg` | Noise dải trung biến thiên nhẹ, nền 100 Hz; loop 6 s; −32 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `speaker_static_burst.wav` | `sfx/speaker_static_burst.ogg` | Rè đặc, saturation và điều biên nhanh; 1.5 s; −32 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `phone_vibrate.wav` | `sfx/phone_vibrate.ogg` | Motor 170/340 Hz, xung rung 0.8 s và rattle kim loại 1850/2730 Hz; loop 2.4 s; −36 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `light_switch.wav` | `sfx/light_switch.ogg` | Hai xung click nhựa và cộng hưởng 1250 Hz; 0.5 s; −36 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |
| `door_latch.wav` | `sfx/door_latch.ogg` | Ma sát kéo và hai chạm kim loại 940/2300 Hz; 0.65 s; −36 LUFS | T-130/process.py trên; Lane E; CC0 1.0 |

## T-131 — hiệu ứng hù dọa và truy đuổi

Nguồn cho **từng WAV/OGG** trong bảng: [T-131/process.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-131-scare-sounds/audio_source/process.py), hàm `synthesize_scare`. Tác giả: Lane E / dự án “Ký túc xá sau 12 giờ”. Giấy phép waveform gốc và OGG: **CC0 1.0**. Khai báo AI: **OpenAI Codex** viết mã tổng hợp/processing, Python 3 tổng hợp và FFmpeg 9.0.2 xử lý. Không dùng giọng thu, TTS, âm từ game khác hoặc mẫu bên thứ ba.

Định dạng raw mono PCM16/48 kHz, OGG mono Vorbis q4/48 kHz. Lọc 35 Hz–11 kHz, chuẩn hóa và đo OGG theo pipeline; one-shot fade 8/80 ms. Các âm tên `slipper_` không qua compressor để giữ tiếp đất/đế vỗ; các one-shot khác dùng compressor đã có. Breath crossfade 1 s, raw 9 s thành loop 8 s. Mức ghi dưới đây là mục tiêu; số đo thật và hash nằm trong `audio_source/build_report.json`.

| WAV gốc | OGG | Công thức / seed / mục tiêu | Nguồn, tác giả, giấy phép |
|---|---|---|---|
| `sting_low.wav` | `sfx/sting_low.ogg` | Nốt 64 Hz, họa âm/rung nhẹ, attack 0.5 s, decay mềm; 13101; −32 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `sting_hit.wav` | `sfx/sting_hit.ogg` | Cộng hưởng kim loại 147/431/1037/2213 Hz, tanh distortion và burst nhiễu, đuôi ngân; 13102; −20 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `slipper_place.wav` | `sfx/slipper_place.ogg` | Hai tiếp đất mềm cách 0.215 s, noise lọc thấp và thân 185 Hz; 13103; −32 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `tube_cut.wav` | `sfx/tube_cut.ogg` | Bụp 110 Hz decay ngắn và tách nhiễu cao nhỏ; 13104; −32 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `breath_close.wav` | `ambience/breath_close.ogg` | Nhiễu dải trung/cao với envelope hít/thở và rasp 31/47.3 Hz; 13105; −36 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `slipper_rush_01.wav` | `sfx/slipper_rush_01.ogg` | Tiếp đất trầm, noise ma sát, vỗ đế sau 0.074 s; 13106; −34 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `slipper_rush_02.wav` | `sfx/slipper_rush_02.ogg` | Biến thể cộng hưởng/độ trễ 0.077 s; 13107; −34 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `slipper_rush_03.wav` | `sfx/slipper_rush_03.ogg` | Biến thể cộng hưởng/độ trễ 0.080 s; 13108; −34 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `slipper_rush_04.wav` | `sfx/slipper_rush_04.ogg` | Biến thể cộng hưởng/độ trễ 0.083 s; 13109; −34 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `whisper_co.wav` | `sfx/whisper_co.ogg` | Phụ âm hơi ngắn, nhiễu qua cộng hưởng 480/850/2400 Hz tạo hơi nguyên âm, không voiced pitch; 13110; −30 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |
| `net_billow.wav` | `sfx/net_billow.ogg` | Nhiễu vải phồng gió, attack mềm và rung vải tăng tốc; 13111; −32 LUFS | T-131/process.py trên; Lane E; CC0 1.0 |

## T-133 — nhạc nền tối giản

Nguồn của từng WAV/OGG: [T-133/process.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-133-music-drone/audio_source/process.py), hàm `synthesize_music`. Tác giả **Lane E / dự án “Ký túc xá sau 12 giờ”**, giấy phép waveform gốc và bản OGG **CC0 1.0**. Khai báo AI: **OpenAI Codex** viết công thức và processing; Python 3 tạo waveform, FFmpeg 9.0.2 xử lý. Không lấy nhạc/mẫu/giọng bên thứ ba; không có giai điệu từ tác phẩm khác.

Raw PCM16 mono 48 kHz; OGG Vorbis q4 mono 48 kHz, lọc 35 Hz–11 kHz và loudnorm hai lượt/hiệu chỉnh theo OGG đo lại. Loop crossfade 1 s, end tone dùng compressor và fade 8/80 ms của pipeline; envelope mềm dài nằm trong công thức gốc. Tất cả đi bus Music tại player, không nhúng bus vào OGG.

| WAV gốc | OGG | Công thức / seed / mục tiêu | Nguồn, tác giả, giấy phép |
|---|---|---|---|
| `drone_base.wav` | `music/drone_base.ogg` | Họa âm 55/55.1875/110 Hz, noise trầm và kim loại xa rất nhỏ, drift 8/16 s; loop 32 s; 13301; −42 LUFS | T-133/process.py trên; Lane E; CC0 1.0 |
| `drone_tension.wav` | `music/drone_tension.ogg` | Drone cộng lệch tần 58.25/116.75 Hz, noise dải trung và kim loại 731.125 Hz; loop 16 s; 13302; −36 LUFS | T-133/process.py trên; Lane E; CC0 1.0 |
| `chase_pulse.wav` | `music/chase_pulse.ogg` | Xung trầm attack tròn, ma sát/kim loại, 112.5 BPM và 30 nhịp/loop 16 s; 13303; −30 LUFS | T-133/process.py trên; Lane E; CC0 1.0 |
| `end_tone.wav` | `music/end_tone.ogg` | Drone attack 1.2 s, decay trầm/kim loại tắt dần, one-shot 10 s; 13304; −32 LUFS | T-133/process.py trên; Lane E; CC0 1.0 |
