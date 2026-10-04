# Nguồn âm thanh T-105 / T-114 / T-123 / T-130 / T-131 / T-133 / T-137

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

## T-137 — giọng loa offline, khai báo AI-assisted

**Nội dung âm thanh tạo bằng quy trình có AI hỗ trợ:** OpenAI Codex viết mã chuẩn bị câu/processing/tích hợp; **eSpeak NG 1.52.0** tạo giọng máy bằng formant và quy tắc, không phải neural TTS, không clone giọng người. Text của dự án lấy từ CSV; waveform xuất và xử lý loa do Lane E/dự án tạo, phát hành phần âm thanh gốc này theo **CC0 1.0**. Công cụ/dữ liệu giọng bên dưới giữ nguyên giấy phép của họ; **không** tái cấp phép công cụ thành CC0. Engine và dữ liệu giọng chỉ ở máy build, không nằm trong repo/export của game.

| Thành phần | Tác giả/nguồn chính thức | Phiên bản, giọng và giấy phép |
|---|---|---|
| Engine eSpeak NG | Jonathan Duddington, Reece H. Dunn và eSpeak NG contributors; [release](https://github.com/espeak-ng/espeak-ng/releases/tag/1.52.0), [README](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/README.md), [COPYING](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/COPYING) | 1.52.0; **GPL-3.0-or-later**, cho phép sử dụng thương mại. Dùng executable riêng để render WAV offline, không link/đóng gói vào Godot. GPL §2 phân biệt output với phần mềm; ở đây xuất lời của dự án, không phân phối mã/dữ liệu engine. |
| Giọng Việt tích hợp | [lang/aav/vi](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/espeak-ng-data/lang/aav/vi), [vi_rules](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/dictsource/vi_rules), cùng contributors | `vi`, Vietnamese Northern, nam; dữ liệu formant/quy tắc cùng bản GPL-3.0-or-later, không có checkpoint neural hoặc điều khoản NC riêng. Không dùng giọng MBROLA. |
| Giọng Anh tích hợp | [lang/gmw/en](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/espeak-ng-data/lang/gmw/en), eSpeak NG contributors, maintainer Reece H. Dunn | `en-gb`, English Great Britain; dữ liệu formant/quy tắc cùng bản GPL-3.0-or-later; tên Việt vẫn render bằng `vi`. |
| Công cụ giải nén build | Scott Willeke/lessmsi contributors; [lessmsi](https://github.com/activescott/lessmsi), [release](https://github.com/activescott/lessmsi/releases/tag/v2.12.9) | 2.12.9, MIT; chỉ giải nén MSI vào D:\Tools, không phân phối cùng game. |
| Processing | Lane E/OpenAI Codex; [voice_process.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-137-speaker-voice/audio_source/voice_process.py) | Python 3 có sẵn, FFmpeg 9.0.2; band-pass 300–3400 Hz, méo nhẹ, vang ngắn, hiss và −26 LUFS. |

Các lựa chọn đã xét nhưng **không dùng**: Piper 2023.11.14-2 engine MIT; [vais1000 model card](https://huggingface.co/rhasspy/piper-voices/blob/main/vi/vi_VN/vais1000/medium/MODEL_CARD) ghi dataset CC BY 4.0 nhưng fine-tune từ Lessac; [Lessac medium model card](https://huggingface.co/rhasspy/piper-voices/blob/main/en/en_US/lessac/medium/MODEL_CARD) dẫn tới [giấy phép nghiên cứu](https://www.cstr.ed.ac.uk/projects/blizzard/2013/lessac_blizzard2013/license.html). Không đủ cơ sở xác nhận toàn bộ chuỗi giọng đó cho task thương mại nên không tải/dùng model; không khẳng định nhãn MIT chung của repo tự giải quyết quyền từng giọng.

Nguồn **mọi file** trong bảng: text CSV của dự án + eSpeak NG/giọng tương ứng ở trên + `voice_process.py`; tác giả waveform/processing: Lane E; **CC0 1.0**, khai báo AI-assisted như trên. Mỗi dòng đại diện cả `vi` và `en`: WAV ở `audio_source/voice/raw/<locale>/<KEY>.wav`, OGG ở `game/audio/voice/<locale>/<KEY>.ogg`. Hash/text/voice/LUFS từng file ghi trong `audio_source/voice/build_report.json`.

| KEY (cả hai locale) | Ghi chú giọng / xử lý riêng |
|---|---|
| `RULE_HEADER_5` | Giọng theo locale, bỏ phần ngoặc nếu có |
| `RULE_1` | Giọng theo locale |
| `RULE_2` | Giọng theo locale |
| `RULE_3_GARBLED` | Tạo raw đầy đủ RULE_3, loại lời hành động khỏi bản game rồi thay bằng nhiễu; không xuất bản rõ RULE_3 |
| `RULE_4` | Giọng theo locale |
| `RULE_5` | Giọng theo locale |
| `SPK_SIGN_LOG` | Bỏ tiền tố Loa/Speaker |
| `SPK_ROLLCALL_INTRO` | Bỏ tiền tố Loa/Speaker |
| `SPK_CHECK_TAPS` | Bỏ tiền tố Loa/Speaker |
| `SPK_NAME_PHUC` | Giọng `vi` cả hai bản |
| `SPK_NAME_VIET` | Giọng `vi` cả hai bản |
| `SPK_NAME_TRUNG` | Giọng `vi` cả hai bản |
| `SPK_NAME_DAT` | Giọng `vi` cả hai bản |
| `SPK_NAME_LAM` | Giọng `vi` cả hai bản |
| `SPK_NAME_TRUNG_AGAIN` | Giọng `vi`, 95 WPM thay vì 145, giữ ngắt ba chấm; bỏ chỉ dẫn chậm hơn |
| `SPK_AND_ONE_MORE` | Giọng theo locale |
| `SPK_AND_TRUNG` | Bản Anh ghép phần tên bằng `vi`, hai phần xung quanh `en-gb` |

## T-158 — Foley chương 1, nội dung AI-assisted

**Nguồn toàn bộ 29 âm mới:** [ch1_process.py của dự án](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-158-ch1-audio/audio_source/ch1_process.py). **Tác giả:** Lane E/dự án, mã tổng hợp và xử lý được **OpenAI Codex** hỗ trợ tạo; khai báo AI-assisted khi phát hành. **Giấy phép waveform gốc và bản xử lý: [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)**. Không mẫu thu, không âm trích video/game, không neural model hoặc clone giọng. Tiếng hét là tổng hợp glottal/formant, chưa được chủ dự án nghe duyệt.

Công cụ build có sẵn: Python 3.14 chuẩn và FFmpeg 9.0.2/libvorbis (bản `full_build-www.gyan.dev` ghi chính xác trong `audio_source/ch1/build_report.json`); không đóng gói công cụ vào game. Nguồn công cụ: [Python](https://www.python.org/), [FFmpeg](https://ffmpeg.org/), [Vorbis](https://xiph.org/vorbis/). Engine hiệu ứng runtime: Godot 4.7.2 có sẵn. Không cài plugin hoặc công cụ mới.

Mọi basename dưới đây ánh xạ **đủ hai file** `audio_source/ch1/raw/<name>.wav` và `game/audio/ch1/<name>.ogg`. Cùng nguồn/tác giả/CC0 như trên; seed, hash, thời lượng và LUFS từng file trong report. HP35/LP8500, fade one-shot, crossfade loop, gain đo theo LUFS; bản soft thêm LP700.

| Basename | Cách tạo âm |
|---|---|
| `manager_step_01`, `manager_step_02` | Xung trọng lượng trầm, nhiễu tiếp đất, hai cộng hưởng khác nhau |
| `manager_drag` | Ma sát noise điều biên, kim loại trượt lệch tần; loop6 s |
| `manager_knock` | Ba xung gõ trầm cách nhau |
| `slash_mattress_01`, `slash_mattress_02` | Gió chém, va đập, xé vải lọc trầm |
| `slash_wood_01`, `slash_wood_02` | Gió chém, thân gỗ cộng hưởng và vỡ ngắn |
| `manager_kill` | Ba lớp chém/va đập dồn trong2 s |
| `kill_soft`, `slash_soft` | Va đập trầm, bỏ lớp chi tiết xé/vỡ, nhỏ hơn |
| `scream_01`, `scream_02`, `scream_03`, `scream_04` | Harmonic glottal theo formant nguyên âm, pitch/duration/vibrato khác nhau, noise hơi |
| `call_ring` | Hai tiếng tít 440/660 Hz, vòng3 s |
| `call_disconnect` | Ba tiếng ngắt kết nối ngắn |
| `call_drop` | Điện thoại va gạch và13 mảnh kính tổng hợp; lọc qua PhoneSFX khi phát |
| `blood_drip` | Giọt lỏng đổi cao độ, noise va gạch không đều; loop8 s |
| `corpse_rustle` | Nhiễu ma sát vải khẽ theo envelope |
| `heartbeat` | Hai xung tim trầm; API tăng nhịp, không tăng gain |
| `breath_gasp` | Noise hơi trầm, envelope hít/thở gấp |
| `bunk_climb`, `bunk_creak` | Xung chân/tay trên sắt và cộng hưởng sắt giường |
| `wall_knock` | Ba xung gõ tường trầm |
| `locker_unlock` | Chốt/cơ cấu khóa và thân tủ kim loại |
| `charger_plug` | Tiếng cắm cơ khí ngắn |
| `pa_on`, `pa_burst` | Relay bật, noise và cộng hưởng loa cũ; không có lời thoại |

Nhạc Ch1Music dùng lại **drone_base/drone_tension của T-133**, cùng tác giả/CC0 ở mục T-133, không tạo hoặc sửa file nhạc cũ. Giọng T-159 chưa có trong task này; Speaker/ManagerAudio/PhoneCallAudio chỉ chuẩn bị API nạp clip và fallback.

## Giọng chương 1 (T-159, Claude làm thay, 2026-10-04)
- `game/audio/voice/vi/{SPK_CH1_*, RULE_CH1_*, MGR_CH1_*, CHAT_CH1_*, ROOM_CH1_*}.ogg`: 58 câu, tổng hợp offline bằng **eSpeak NG 1.52.0** (giọng `vi` với các biến thể `m1`–`m8`, `f2`), cùng công cụ và giấy phép như T-137; xử lý bằng FFmpeg. **Nội dung do AI tạo** (lời thoại do Claude viết, giọng máy tổng hợp): phải khai báo khi lên Steam (D-006).
- Tạo lại: `py -3 audio_source/ch1_voice_process.py`; báo cáo `audio_source/voice_ch1/build_report.json`.

## T-164 — Foley nhiệm vụ chương 1 bản 2 (2026-10-05)

Nguồn **mọi file trong bảng**: [ch1v2_process.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-e/T-164-ch1v2-audio/audio_source/ch1v2_process.py). Tác giả waveform/công thức: Lane E/dự án, mã có **OpenAI Codex** hỗ trợ; khai báo **AI-assisted** khi phát hành. Waveform gốc và xử lý phát hành **[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)**. Không dùng bản thu người thật, neural model, âm từ video hoặc game khác.

Công cụ có sẵn: Python 3.14 chuẩn ([Python](https://www.python.org/)); FFmpeg 9.0.2/libvorbis ([FFmpeg](https://ffmpeg.org/), [Vorbis](https://xiph.org/vorbis/)), phiên bản chính xác trong `audio_source/ch1v2/build_report.json`; Godot 4.7.2 xử lý runtime. Không tải/cài thêm gì, không đóng gói công cụ build vào game.

Mỗi basename dưới đây đại diện cả `audio_source/ch1v2/raw/<name>.wav` và `game/audio/ch1v2/<name>.ogg`; seed/hash/LUFS/thời lượng nằm trong report. Cùng nguồn/tác giả/giấy phép trên cho tất cả 20 cặp file.

| Basename | Công thức gốc |
|---|---|
| wall_tap_01, wall_tap_02, wall_tap_03 | Xung knuckle, cộng hưởng vôi/gạch tắt nhanh; ba cao độ/seed |
| router_power_off | Relay nhả và âm điện tụt cao độ |
| router_boot, router_online | Bíp sin/họa âm tăng cao độ |
| power_switch | Cơ cấu công tắc gọn, nhiễu tiếp xúc |
| power_short | Chuỗi burst điện, noise/tần số lưới và relay nhảy |
| handle_rattle, handle_stop | Kim loại lạch cạch, trục bản lề rung; loop và đuôi nhả riêng |
| lock_alarm | Tín hiệu điều tần dải trung cao, chuẩn −30 LUFS |
| kiet_ring | Hai lượt ba nốt 740/988/831 Hz; khác chuông Trung |
| call_reconnect | Hai nốt nối lại tăng cao độ |
| death_fall_back | Noise phụt, hơi nghẹn điều biên, va đập trầm trên gạch |
| death_bed_burst | Noise chất lỏng/hơi và nhiều xung sắt giường |
| death_flesh | Ma sát ướt lọc trầm và xung chém ngắn |
| death_fall_soft, death_bed_soft | Bỏ lớp máu/hơi nghẹn, lọc LP700 và giảm mức |
| cctv_static, cctv_switch | Noise band-pass khẽ, nhiễu điều biên khi đổi kênh |

Dùng lại `call_disconnect`, `manager_kill`, `kill_soft` của **T-158**, cùng nguồn/CC0 đã ghi ở trên; không sửa các waveform đó. Chưa nghe/duyệt cảm nhận cho 20 âm mới. Mọi mức LUFS là trước bus/filter/khoảng cách, không khẳng định loudness tổng mix tại tai.
