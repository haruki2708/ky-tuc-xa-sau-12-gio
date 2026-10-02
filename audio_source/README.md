# Pipeline âm thanh T-105

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

1. Tổng hợp 13 WAV PCM16 mono 48 kHz bằng Python `math`, `random`, `wave`, không có bản ghi âm bên ngoài. Chi tiết nguồn và công cụ ở `game/audio/CREDITS.md`.
2. Cắt theo thời lượng định nghĩa trong `ASSETS`, lọc high-pass 35 Hz và low-pass 11 kHz. One-shot qua compressor (threshold 0.025, ratio 6, attack 0.1 ms, release 80 ms) để kiểm soát đỉnh transient trước chuẩn hóa; fade đầu 8 ms, cuối 80 ms.
3. Loop: crossfade tuyến tính 1 giây giữa đuôi và đầu; xoay điểm nối để hai biên còn lại là các mẫu liền nhau từ nguồn. Hum mới chọn thêm điểm nối có độ dốc/biên độ thấp nhằm giảm sai lệch biên do codec ở phần họa âm cao. Loop quạt/đèn dài 12 giây, côn trùng và xe máy xa dài 20 giây.
4. Đo và chuẩn hóa hai lượt bằng [loudnorm](https://ffmpeg.org/ffmpeg-filters.html#loudnorm): Ambience −24 LUFS, SFX −18 LUFS, true peak mục tiêu −2 dBTP. Xuất mono OGG Vorbis quality 4, 48 kHz; bỏ metadata, bật bitexact cho muxer/encoder. Đo OGG rồi hiệu chỉnh gain tối đa hai lần nếu lệch >0.5 LU, có giới hạn theo headroom; luôn encode lại từ PCM, không nối nhiều lượt encode lossy.
5. Ghi `loop=true` cho ambience, `loop=false` cho SFX trong `.ogg.import`; bảo toàn UID/remap khi Godot đã import. Chạy test để Godot hoàn thiện metadata import; commit `.import` và `.uid`.
6. Đo lại **OGG đã encode** và ghi `build_report.json`: hash WAV/OGG, LUFS, true peak, độ dài, dung lượng, chênh hai mẫu ở biên loop. Pipeline fail nếu lệch mục tiêu >1 LU, peak >−1 dBTP, chênh biên loop >0.02 hoặc tổng WAV+OGG ≥15 MB. Những số đo này không thay thế nghe thử.
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
- `FootstepPlayer.play_footstep(&"tile")`: 4 biến thể dép lê, bỏ biến thể vừa phát, bus SFX. Surface khác im lặng; không tự suy đoán vật liệu game. Bank rỗng bỏ qua; bank chỉ có một clip duy nhất sẽ không phát lại clip đó liên tiếp. Lane A nối signal/hàm riêng trong phạm vi của Lane A.
- `default_bus_layout.tres` tự được Godot nạp theo tên chuẩn, không cần autoload hoặc sửa `project.godot`. Bus Ambience gửi về Master, reverb wet 0.12 và gain −3 dB; SFX/Voice/Music gửi về Master.

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
