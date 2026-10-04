# Pipeline âm thanh T-105

Bộ âm chương 1 T-158: [ch1/README.md](ch1/README.md), lệnh `py -3 audio_source/ch1_process.py`; ngân sách riêng 15 MB. Không ghi đè hai bank cũ bên dưới.

Giọng loa T-137 có pipeline riêng: [voice/README.md](voice/README.md), lệnh `py -3 audio_source/voice_process.py`. Bank 43 hiệu ứng/nhạc bên dưới giữ ngân sách riêng 20 MB; bank giọng có raw/report và ngân sách riêng 20 MB. Tổng hai bank dưới 40 MB, mỗi file dưới 10 MB.

Chạy từ gốc repo, Python 3 chuẩn (không cần pip hoặc plugin):

```powershell
py -3 audio_source/process.py --regenerate-raw
pwsh tools/test.ps1
```

- `--regenerate-raw`: tổng hợp lại toàn bộ WAV từ seed cố định rồi xử lý lại OGG.
- Không có cờ: dùng WAV hiện có trong `raw/`; tự tạo file còn thiếu.
- ffmpeg portable đã cài tại `D:\Tools\ffmpeg\ffmpeg-9.0.2-essentials_build\bin\ffmpeg.exe`. Có thể truyền `--ffmpeg <đường-dẫn>` hoặc biến môi trường `FFMPEG`. Script tìm trong `D:\Tools\ffmpeg` nếu PATH không có ffmpeg.
- Python có sẵn trên máy qua `py -3`; không cài thêm phần mềm vào ổ C.
- Bản ffmpeg: 9.0.2 essentials, nguồn [Gyan Windows builds](https://www.gyan.dev/ffmpeg/builds/), được dẫn từ [trang tải FFmpeg](https://ffmpeg.org/download.html). ZIP: `https://www.gyan.dev/ffmpeg/builds/packages/ffmpeg-9.0.2-essentials_build.zip`; SHA256 đã đối chiếu với file `.sha256`: `60f467265b1e312373dbcd92200c2618a74850f98d3d078e94296bb3fa2047ba`.

## Các bước và kiểm chứng

1. Tổng hợp 43 WAV PCM16 mono 48 kHz bằng Python `math`, `random`, `wave`, không có bản ghi âm bên ngoài. Chi tiết nguồn và công cụ ở `game/audio/CREDITS.md`.
2. Cắt theo thời lượng định nghĩa trong `ASSETS`, lọc high-pass 35 Hz và low-pass 11 kHz. One-shot qua compressor (threshold 0.025, ratio 6, attack 0.1 ms, release 80 ms) để kiểm soát đỉnh transient trước chuẩn hóa; fade đầu 8 ms, cuối 80 ms.
3. Loop: crossfade tuyến tính 1 giây giữa đuôi và đầu; xoay điểm nối để hai biên còn lại là các mẫu liền nhau từ nguồn. Hum mới chọn thêm điểm nối có độ dốc/biên độ thấp nhằm giảm sai lệch biên do codec ở phần họa âm cao. Loop quạt/đèn dài 12 giây, côn trùng và xe máy xa dài 20 giây.
4. Đo và chuẩn hóa hai lượt bằng [loudnorm](https://ffmpeg.org/ffmpeg-filters.html#loudnorm): Ambience −24 LUFS, SFX −18 LUFS (ngoại lệ trong `TARGET_OVERRIDES`: hum −44, dép đi −56, dép chạy −53), true peak mục tiêu −2 dBTP. Xuất mono OGG Vorbis quality 4, 48 kHz; bỏ metadata, bật bitexact cho muxer/encoder. Đo OGG rồi hiệu chỉnh gain tối đa hai lần nếu lệch >0.5 LU, có giới hạn theo headroom; luôn encode lại từ PCM, không nối nhiều lượt encode lossy.
5. Ghi `loop=true` cho ambience, `sfx/phone_vibrate` và ba file thuộc `MUSIC_LOOPS`; `loop=false` cho các one-shot, gồm `music/end_tone`, trong `.ogg.import`; bảo toàn UID/remap khi Godot đã import. Chạy test để Godot hoàn thiện metadata import; commit `.import` và `.uid`.
6. Đo lại **OGG đã encode** và ghi `build_report.json`: hash WAV/OGG, LUFS, true peak, độ dài, dung lượng, chênh hai mẫu ở biên loop. Pipeline fail nếu lệch mục tiêu >1 LU, peak >−1 dBTP, chênh biên loop >0.02 hoặc tổng WAV+OGG ≥20 MB. T-133 nâng giới hạn tổng từ 15 lên 20 MB để chứa loop nhạc 32/16/16 s và end tone 10 s ở PCM16/48 kHz; vẫn giữ giới hạn 10 MB mỗi file của dự án. Những số đo này không thay thế nghe thử.
7. T-114: hum giữ nền 100 Hz, thêm rè chấn lưu 300/500/700/1100/1900/2900 Hz dao động chậm không đều và rít nhỏ 6.2 kHz. Đo OGG qua `highpass=f=200:p=2` **trước** phép đo loudnorm, không chuẩn hóa lại bản lọc để che mất mức suy giảm. Report có `highpass_200hz_lufs` và `highpass_200hz_loss_lu`; fail nếu mất >10 LU. Kết quả: −23.97 → −25.99 LUFS, mất 2.02 LU. Flicker là one-shot 1.5 giây gồm relay click và rè ngắt quãng; 11 âm khác giữ nguyên hash so với T-105.

Tái tạo byte giống nhau yêu cầu cùng phiên bản Python/ffmpeg. Để đối chiếu, lưu bản `build_report.json`, chạy lại `--regenerate-raw` rồi so SHA256 từng WAV và OGG. Báo cáo không chứa timestamp hay đường dẫn tuyệt đối. Script chỉ tạo file tạm bên trong `audio_source/` và tự dọn thư mục tạm của lần chạy đó.

## Nghe thử

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/audio_test.tscn --windowed --resolution 1280x720
```

Scene tự phát âm khi vào phòng; camera cố định làm listener. Quạt ở trên đầu, đèn bên trái, côn trùng và xe máy xa bên cửa sổ trái, giọt nước bên phải, cửa phía cuối phòng. Bước chân chạy ngang phía trước. Các marker sáng chỉ phục vụ scene thử; không thêm chữ hiển thị hoặc luật chơi.

- `0`: mix toàn bộ; `1`: quạt; `2`: đèn; `3`: côn trùng/xe máy; `4`: giọt nước; `5`: mở cửa; `6`: đóng cửa; `7`: bước chân; `Esc`: thoát.
- Nghe mỗi loop ít nhất 60 giây, thử tai nghe để kiểm tra trái/phải; kiểm tra tiếng tách ở điểm nối, rè, âm lượng tổng và chất âm dép/cửa. Đây là asset tổng hợp ban đầu, cần chủ dự án duyệt cảm nhận trước khi coi là bản âm thanh cuối.
- Test headless kiểm tra load/decode, không xác nhận có âm ở loa hoặc chất lượng cảm nhận.

## API tích hợp

- `AmbientEmitter` kế thừa `AudioStreamPlayer3D`. Gán stream hoặc `clips`, bus, vị trí và gain ở scene. `LOOP` phát ngay; `RANDOM_INTERVAL` đợi khoảng ngẫu nhiên trước lần đầu và sau mỗi one-shot kết thúc. Có biến thiên pitch/volume quanh giá trị gốc, không tích lũy; `stop_emitting()` hủy cả timer và playback. Stream được duplicate trước khi đổi loop để không ảnh hưởng emitter khác. Dùng OGG/WAV cho loop liền mạch.
- `FootstepPlayer.play_footstep(surface, intensity = 0.5)`: `intensity` 0–1 (đi bộ khoảng 0,6, chạy 1). Dưới 0,8 dùng bank đi `slipper_tile_01…04` (−56 LUFS), từ 0,8 dùng bank chạy `slipper_run_01…04` (−53 LUFS). Âm lượng cộng thêm −3…+3 dB theo `intensity`, biến thiên ±1,5 dB, cao độ ±4%. Mỗi bank không phát lại biến thể vừa phát. Gọi một tham số vẫn chạy (Player cũ). Chỉ hỗ trợ surface `tile`; surface khác im lặng. Bus `Footsteps` gửi vào `SFX`, nên vẫn nhận reverb của ReverbZone. Bước chân không qua compressor để giữ hai nhịp "lẹp"/"xẹp".
- `default_bus_layout.tres` tự được Godot nạp theo tên chuẩn, không cần autoload hoặc sửa `project.godot`. Có 6 bus: `Master`, `Ambience`, `SFX`, `Voice`, `Music`, `Footsteps`. Ambience gửi về Master, reverb wet 0.12 và gain −3 dB; SFX/Voice/Music gửi về Master. `Footsteps` mặc định 0 dB, không mute, không có effect riêng; đường phát là `FootstepPlayer → Footsteps → SFX (reverb) → Master`.
- T-126 giữ nguyên WAV/OGG và gain của player đã được duyệt. Thanh trượt Bước chân do Lane D áp dụng vào bus `Footsteps` theo `[audio] footsteps_db` trong `docs/SETTINGS.md` (mặc định 0 dB, khoảng −40…+6 dB); âm lượng/mute của bus cha SFX và Master vẫn tác động lên bước chân. Lane E không đọc/ghi settings hoặc thêm UI trong task này.

## T-114: vùng âm và đèn

Mở `res://audio/test/zones_test.tscn` bằng F6 hoặc:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/zones_test.tscn --windowed --resolution 1280x720
```

Player của Lane A bắt đầu ở phòng có quạt và đèn (z=8), nhìn dọc hành lang tới phòng thứ hai. WASD/Shift/chuột/Esc theo Player có sẵn. `L` bật/tắt đèn phòng đầu; `F` gọi `flicker(1.5)` chỉ cho âm thanh. Đi qua hai cửa để nghe chuyển ambience và reverb của bước chân/giọt nước; mỗi khu có AmbientZone và ReverbZone. Sàn fixture có metadata `surface=tile`. Mọi geometry của fixture tạo trong script dưới `game/audio/test/`; không đổi level/main hoặc Player gốc.

- `AmbientZone` là `Area3D` (qua lớp chung `AudioZone`), cần `CollisionShape3D`. `emitters: Array[NodePath]` trỏ tương đối từ zone tới các `AmbientEmitter`/`LightHum`; `fade_time` mặc định 1 giây. Chỉ body thuộc layer 2 kích hoạt, nhiều body phải ra hết mới tắt. Gain tuyến tính từ 0 đến 1, đảo hướng từ giá trị hiện tại khi đổi vùng giữa fade. Emitter dùng gain lớn nhất trong các zone đang gán; không cộng dồn/ghi đè khi chồng vùng. Bắt đầu ngoài vùng thì mute, playback loop tiếp tục để giữ pha; lần phát clip mới vẫn giữ gain của zone. Xóa zone gỡ contribution; xóa zone cuối trả emitter về gain độc lập. Gán đường dẫn trước khi node vào cây.
- `ReverbZone` có preset `ROOM`, `CORRIDOR`, `BATHROOM`; thông số `(room_size, damping, wet)` lần lượt `(0.35, 0.65, 0.12)`, `(0.7, 0.45, 0.22)`, `(0.85, 0.2, 0.32)`. `mix_priority` cao hơn thắng, cùng ưu tiên thì vùng vào gần nhất thắng. Có một tween dùng chung để chuyển từ giá trị hiện tại trong `fade_time` (mặc định 0.35 giây), tránh các zone tranh ghi bus. Rời vùng thắng sẽ về vùng còn chiếm; rời hết trả bộ thông số chụp ban đầu; unload zone cuối trả ngay và hủy tween. SFX có reverb sẵn, wet mặc định 0 nên ngoài vùng vẫn dry như trước. Không đổi volume bus/dry hoặc hiệu ứng Ambience. Thiết kế áp dụng cho một listener và bus SFX chung, không hỗ trợ split-screen hay runtime thay bus layout trong lúc zone đang hoạt động.
- `LightHum` **kế thừa AmbientEmitter**: gắn `light_hum.gd` thay script emitter trên cùng `AudioStreamPlayer3D`, gán export `light: Light3D` trước `_ready`. Không gắn đồng thời hai script lên một node. Hum mặc định tự chọn file mới; đặt bus Ambience ở scene. `visible=false` tắt playback đồng bộ theo signal; `light_energy <= 0.001`, ancestor ẩn hoặc light bị xóa được kiểm tra mỗi process frame, dừng ngay lần cập nhật đó, không fade. Bật lại phát lại hum và giữ gain của zone.
- `flicker(duration)` phát one-shot bằng player 3D con cùng bus/attenuation, ngắt hum bằng các khoảng 40–160 ms. Hết thời gian dừng flicker và khôi phục hum; gọi lại bắt đầu lại thời lượng; duration không dương/không hữu hạn hoặc light đang tắt thì bỏ qua. Nếu duration dài hơn clip, retrigger one-shot đến hết thời lượng. Tắt đèn hủy cả flicker lẫn hum; không tự sửa visibility/energy để tạo nhấp nháy thị giác. Volume flicker đi theo gain zone của hum.

Đã test tự động phản ứng vùng, overlap, đảo fade, Player bị xóa, reverb restore/unload, đèn và phím L/F. **Chưa nghe hum mới, flicker và mix chuyển vùng bằng tai hoặc trên loa laptop thật.** Phép lọc HP200 là kiểm tra tín hiệu mô phỏng giới hạn bass, không phải chứng nhận cảm nhận nghe. Tài liệu tham khảo API: [Area3D](https://docs.godotengine.org/en/stable/classes/class_area3d.html), [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html), [Node3D visibility](https://docs.godotengine.org/en/stable/classes/class_node3d.html).

## T-130: âm đoạn 1–2 và Speaker

11 âm mới nằm trong `ASSETS` với seed 13001–13011 và hàm `synthesize_segment12`. `TARGET_OVERRIDES` thêm `knock_` −30 LUFS, `speaker_` −32 LUFS, điện thoại/công tắc/chốt −36 LUFS. Không thay công thức, filter hoặc mức mục tiêu của các âm đã duyệt. `phone_vibrate` là ngoại lệ loop trong thư mục SFX (`LOOP_SFX`); loop raw 3.4 giây thành 2.4 giây sau crossfade. `speaker_static` raw 7 giây thành loop 6 giây. Ba file knock mỗi file chứa đúng ba cú gõ; khoảng cách lần lượt 0.43/0.73/1.03 giây, âm 03 trầm và decay dài nhất. Mọi nguồn, xử lý và giấy phép được ghi từng file trong `game/audio/CREDITS.md`.

Gắn `game/scripts/audio/speaker.gd` lên `AudioStreamPlayer3D` ở vị trí loa. Script chọn bus `Voice` và tạo hai player 3D con cùng vị trí: `BackgroundStatic`, `StaticBurst`; các thiết lập khoảng cách, hướng phát, pitch và volume đi theo player cha.

```gdscript
speaker.play_announcement([
	{"text_key": "RULE_1", "garbled": false},
	{"text_key": "RULE_3_GARBLED", "garbled": true},
	{"text_key": "RULE_2", "garbled": false},
], 4.0)
```

Đây là lượt **fixture thử 3 dòng**, không phải thứ tự nội dung đầy đủ của đoạn 2. T-117 cấp danh sách chính thức. Với dòng bị rè, caller phải truyền key che phần bị mất (`RULE_3_GARBLED` đã có), không truyền `RULE_3` rồi mong âm thanh che chữ. Speaker không tự đổi key, không quyết định luật hoặc cập nhật sổ tay.

- Trình tự: phát on xong → chime xong → bật static nền, phát từng `EventBus.subtitle_requested(text_key, line_seconds)` → mỗi dòng giữ đủ thời gian → tắt nền và phát off → dừng tất cả, emit `announcement_finished` đúng một lần. Chưa có giọng đọc TTS.
- `static_gain_db` mặc định −12 dB so với gain cha để rè nằm dưới giọng đọc tương lai; burst giữ gain cha nên rõ hơn nền khoảng 12 dB. Asset loa vẫn −32 LUFS theo card. Burst phát từ đầu dòng `garbled`; dừng ở biên dòng để không tràn sang dòng rõ nếu `line_seconds` ngắn hơn 1.5 giây.
- `play_announcement` mới hủy chuỗi cũ rồi phát chuỗi mới; sao chép key/cờ của đầu vào. `stop_emitting()` hủy lịch và cả ba lớp âm, không emit hoàn tất; tương thích quy trình `App.quit()`. Khi unload cũng dừng phát. Mặc định kế thừa pause của scene tree; không đặt Speaker ở process mode Always nếu muốn dừng khi mở menu.
- Dictionary thiếu `garbled` hiểu là false. Bỏ qua phần tử sai kiểu, key rỗng hoặc cờ không phải bool. Danh sách rỗng/hết phần tử hợp lệ emit hoàn tất ngay, không có âm. `line_seconds <= 0`, NaN/Inf hoặc gọi trước `_ready` thì bỏ qua. Chỉ lịch tương lai được hủy; phụ đề đã gửi thuộc HUD và hết hạn theo thời lượng đã gửi.

Mở `res://audio/test/segment12_test.tscn`, F6, hoặc:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/segment12_test.tscn --windowed --resolution 1280x720
```

| Phím | Âm thử |
|---|---|
| F1 / F2 / F3 | Ba lượt gõ: thường / chậm / chậm và nặng nhất |
| F4 | Chuông loa |
| F5 / F6 | Bật / tắt loa |
| F7 | Static nền loop |
| F8 | Static burst 1.5 giây |
| F9 | Điện thoại rung loop |
| F10 / F11 | Công tắc / chốt cửa |
| Space | Chuỗi loa thử 3 dòng với HUD dịch sẵn |
| 0 | Dừng mọi nguồn fixture |
| Esc | Thoát qua `App.quit()` |

Đổi phím thử dừng âm trước để nghe riêng. Static khi solo F7 phát ở gain gốc; trong chuỗi Speaker nó có gain nền −12 dB. Tham số QA `-- --segment12-preview --quit-after-frames=210` tự chạy lượt thử với 0.6 giây/dòng rồi thoát sạch qua App; chỉ phục vụ kiểm tra khởi chạy. **Chưa nghe 11 âm mới và mix Speaker bằng tai**; phép đo/headless không thay cho chủ dự án duyệt chất âm, mức âm thực và độ liền của loop.

## T-131: âm hù dọa và truy đuổi

11 âm mới dùng `synthesize_scare`, seed 13101–13111. `SEGMENT12_NAMES` giới hạn riêng dải 13000–13099 để công thức mới không đổi âm T-130. Không đổi bus layout, mức âm hay công thức của 28 âm đã duyệt. Bản raw/OGG tái tạo bằng cùng lệnh ở đầu tài liệu.

Mở `res://audio/test/scare_test.tscn` bằng F6 trong editor, hoặc:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/scare_test.tscn --windowed --resolution 960x540
```

| Phím | File (bỏ đuôi .ogg) | Thời lượng OGG | Mục tiêu LUFS | Bus tích hợp |
|---|---|---|---|---|
| F1 | `sfx/sting_low` | 3 s | −32 | SFX |
| F2 | `sfx/sting_hit` | 2 s | −20 | SFX |
| F3 | `sfx/slipper_place` | 0.9 s | −32 | SFX |
| F4 | `sfx/tube_cut` | 0.5 s | −32 | SFX |
| F5 | `ambience/breath_close` | 8 s, loop | −36 | SFX |
| F6–F9 | `sfx/slipper_rush_01…04` | 0.6 s mỗi file | −34 | SFX |
| F10 | `sfx/whisper_co` | 1.5 s | −30 | Voice |
| F11 | `sfx/net_billow` | 1.1 s | −32 | SFX |
| 0 / Esc | Dừng / thoát qua App | | | |

Fixture không tự phát; mỗi phím dừng âm trước, phát một file ở gain 0 dB, pitch 1 qua `AudioStreamPlayer` để nghe mức asset không bị suy hao khoảng cách. Không có chữ mới trên màn hình; bảng phím ở đây. F5 lặp đến khi bấm 0 hoặc chọn âm khác. Nghe loop ít nhất 60 giây để đánh giá nhịp thở và điểm nối. F2 là âm lớn nhất theo card (hơn F1 khoảng 12 LU).

Sting là hiệu ứng nên chọn SFX; tiếng thì thầm là hơi giọng nên chọn Voice, thuận tiện điều chỉnh riêng. Hơi thở và bước chân thực thể là âm truy đuổi nên cũng dùng SFX, **không dùng Footsteps**. Dù breath lưu dưới ambience để pipeline tạo loop, bus phát vẫn do node quyết định. OGG không tự chứa bus: Integrator/Lane A phải gán bus khi tạo player. Có thể dùng `AudioStreamPlayer3D` ở vị trí thực thể; không dùng `FootstepPlayer` của người chơi cho bank rush. Caller quyết định thời điểm, nhịp bước, khoảng cách, dừng breath khi kết thúc truy đuổi và biến thể không lặp liên tiếp; task này không thêm các quyết định gameplay đó.

`sting_low` có attack mềm 0.5 s, nốt 64 Hz với họa âm/rung nhẹ rồi tắt dần; hit gồm kim loại méo và burst nhiễu. Dép đặt gồm hai xung 0.025/0.24 s, rush có tiếp đất trầm và đế vỗ sát hơn bank người chơi. Hơi thở là nhiễu điều biên khàn theo chu kỳ 4 s; raw 9 s crossfade thành loop 8 s. `whisper_co` là hơi nhiễu qua cộng hưởng nguyên âm, không TTS, không giọng nói thu âm và chưa xác nhận nghe ra chữ “Có”. Phụ đề và xử lý `reduce_scares` thuộc bên tích hợp theo D-024, không tự nối settings/StoryDirector ở lane E.

Test kiểm tra decode/loop toàn bộ 39 OGG, hash file khớp report, LUFS của 11 âm mới trong ±1 LU, hit lớn hơn low, phím thử và bus. **Chưa nghe bằng tai cả 11 âm T-131**; số đo và test không xác nhận chất âm, độ giật mình, âm giống dép/vải hay tiếng thì thầm. Cần chủ dự án nghe thử trước khi duyệt cảm nhận.

## T-133: nhạc nền và MusicDirector

Thêm bốn âm tự tổng hợp, seed 13301–13304; không thay công thức/target/hash 39 âm đã có. Drone gồm họa âm trầm quanh 55/110 Hz, nhiễu lọc và tiếng kim loại xa 731.125 Hz, không chuỗi giai điệu. Tension thêm dao động lệch tần; chase có 112.5 BPM (30 nhịp trong loop 16 s), attack tròn. Ba loop crossfade 1 s; raw dài hơn OGG 1 s. End tone attack mềm, tắt dần trong 10 s. Mono 48 kHz, cùng pipeline bitexact cũ.

| File dưới `game/audio/music/` | OGG | LUFS mục tiêu / đo thật | Chênh biên loop |
|---|---|---|---|
| `drone_base.ogg` | 32 s loop | −42 / −41.96 | 0.0007746 |
| `drone_tension.ogg` | 16 s loop | −36 / −35.99 | 0.0015736 |
| `chase_pulse.ogg` | 16 s loop, 112.5 BPM | −30 / −29.96 | 0.0012073 |
| `end_tone.ogg` | 10 s one-shot | −32 / −32.49 | Không loop |

Gắn script `res://scripts/audio/music_director.gd` lên một `Node` tên `MusicDirector` trong main. Node tự tạo bốn `AudioStreamPlayer`, tất cả bus **Music**, không chỉnh volume bus (slider Music/Master vẫn thuộc Lane D). Đặt node trước nơi khởi động StoryDirector để kết nối xong trước signal `segment_changed`; khi resume, caller phải phát segment và deviation hiện tại qua EventBus. Director không đọc GameState/StoryDirector, không quyết định cốt truyện và không là autoload.

- `seg1`/segment ngoài seg2–5: fade về im lặng. `seg2`–`seg5`: base vào 2 s, reset chase/khoảng im/lịch transient cũ. Ba loop chạy cùng lúc, layer chưa cần có gain tuyến tính 0 để giữ pha khi đưa lên lại. `end`: fade loop 0.8 s, sau 0.85 s dừng loop và phát end tone một lần. Đổi đoạn trong lúc chờ end hủy lịch đó.
- Consequence thường: tension lên 2 s, giữ 15 s rồi về mức nền trong 8 s. Gọi lại kéo dài lượt mới, tween tiếp từ gain hiện tại. Mức transient theo deviation 0–4: −8/−6/−4/−2/0 dB so với asset; không vượt −36 LUFS mục tiêu của riêng layer. Mức nền: level 0 im; level 1–4 là −12/−10/−8/−6 dB. Tổng mix nhiều layer có thể lớn hơn một layer đơn.
- `corridor_light_flicker`: ramp toàn bộ nhạc về **0 tuyến tính trong 10 ms**, giữ 3 s, sau đó tension lên 2 s/giữ 15 s/fade 8 s. `scare_triggered`: ramp 10 ms về 0, giữ khoảng 1.5 s, trả mix trong 0.3 s. Release 10 ms để tránh cắt waveform ở mẫu khác 0; đây là lựa chọn kỹ thuật cho yêu cầu vừa cắt ngay vừa tránh tiếng bụp. Hai khoảng im được giữ riêng: khoảng ngắn hết không phá khoảng dài đang còn.
- `chase_started(id)`: pulse vào 0.5 s; `chase_ended(id, false)` ra 1.5 s; caught ra 10 ms. Bỏ qua end của chase id khác. Nếu chase kết thúc trong khoảng im, nó không tự phát lại khi hết im.
- Node và các tween dùng process Always để nhạc tiếp tục trong menu. `game_paused` duck 10 dB trong 0.2 s; bỏ pause trả lại. Đồng hồ hold/silence/end chờ trong lúc pause; các fade ngắn vẫn chạy mượt. Không thay tree pause hoặc settings.
- Chỉ đọc bool `[accessibility] reduce_scares` lúc ready và khi đúng `settings_changed`; sai kiểu/thiếu file là false. Khi bật, pulse giảm riêng 6 dB, hủy/bỏ khoảng im của scare, giữ khoảng im do đèn tắt theo D-024. Thay đổi giảm âm và pause độc lập, không ghi đè gain transient; pause + reduction cho chase là −16 dB.
- `stop_emitting()` hủy tween/lịch, dừng cả bốn player và khóa phát lại; dùng lúc App.quit hoặc unload. Muốn tạo lượt chơi mới sau shutdown, tạo node mới. `seg1` là cách reset nhẹ trong fixture.

Scene nghe thử vẫn là `res://audio/test/scare_test.tscn`. F1–F11 giữ các âm T-131. Phím **1/2/3/4** nghe riêng base/tension/chase/end ở gain 0 dB qua Music. Phím **M** giả lập: bắt đầu seg2 → sau 3 s làm sai (level 2) → sau 4 s bắt đầu đuổi → sau 5 s thoát. Sau đó nhạc nền tiếp tục. **L** giả lập đèn tắt; **H** hù; **P** giả lập signal pause/unpause cho MusicDirector; **E** giả lập end. Dùng M trước L/H/P để có nhạc đang chạy. **0** dừng solo, hủy chuỗi và fade director về seg1; **Esc** thoát sạch. Chuyển solo có thể nghe đuôi fade director 0.8 s. Phím P không pause cả cây và không tác động solo; thử pause thật bằng test tự động hoặc main sau tích hợp. Fixture không ghi settings; thiết lập “Giảm hù dọa” có sẵn được đọc khi mở scene.

**Giới hạn tích hợp:** core hiện emit `scare_triggered` cùng frame phát sting/whisper; MusicDirector chỉ bảo đảm im nhạc từ khi nhận signal. Để có 1.5 s im **trước** cú hù, Integrator cần dời signal sớm tương ứng ở core, xử lý nhánh reduce_scares và đồng bộ hình/sting. Không tự trì hoãn sting, mute SFX/Voice hoặc sửa core ở lane E.

`corridor_light_flicker` hiện được phát lúc bắt đầu nhấp nháy đèn; lần tắt giữ lâu xảy ra sau chuỗi nhấp nháy. Director cắt nhạc theo signal ngay từ lần tắt đầu. Nếu muốn 3 s được tính từ lần tắt giữ lâu, Integrator cần đồng bộ cue tại core; không hardcode độ dài nhấp nháy vào nhạc.

**Chưa nghe bằng tai bốn âm mới, loop nối dài, mix với hum/dép, fade/duck hay chuỗi truy đuổi.** Test kiểm tra decode, bus, LUFS/hash, vòng đời signal và tham số tween; không xác nhận chất lượng cảm nhận hay hứa không có tiếng bụp trên mọi thiết bị. Chủ dự án cần nghe thử và duyệt mix sau khi gắn main.
