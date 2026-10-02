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

1. Tổng hợp 12 WAV PCM16 mono 48 kHz bằng Python `math`, `random`, `wave`, không có bản ghi âm bên ngoài. Chi tiết nguồn và công cụ ở `game/audio/CREDITS.md`.
2. Cắt theo thời lượng định nghĩa trong `ASSETS`, lọc high-pass 35 Hz và low-pass 11 kHz. One-shot qua compressor (threshold 0.025, ratio 6, attack 0.1 ms, release 80 ms) để kiểm soát đỉnh transient trước chuẩn hóa; fade đầu 8 ms, cuối 80 ms.
3. Loop: crossfade tuyến tính 1 giây giữa đuôi và đầu; xoay điểm nối để hai biên còn lại là các mẫu liền nhau từ nguồn. Loop quạt/đèn dài 12 giây, côn trùng và xe máy xa dài 20 giây.
4. Đo và chuẩn hóa hai lượt bằng [loudnorm](https://ffmpeg.org/ffmpeg-filters.html#loudnorm): Ambience −24 LUFS, SFX −18 LUFS, true peak mục tiêu −2 dBTP. Xuất mono OGG Vorbis quality 4, 48 kHz; bỏ metadata, bật bitexact cho muxer/encoder. Đo OGG rồi hiệu chỉnh gain tối đa hai lần nếu lệch >0.5 LU, có giới hạn theo headroom; luôn encode lại từ PCM, không nối nhiều lượt encode lossy.
5. Ghi `loop=true` cho ambience, `loop=false` cho SFX trong `.ogg.import`; bảo toàn UID/remap khi Godot đã import. Chạy test để Godot hoàn thiện metadata import; commit `.import` và `.uid`.
6. Đo lại **OGG đã encode** và ghi `build_report.json`: hash WAV/OGG, LUFS, true peak, độ dài, dung lượng, chênh hai mẫu ở biên loop. Pipeline fail nếu lệch mục tiêu >1 LU, peak >−1 dBTP, chênh biên loop >0.02 hoặc tổng WAV+OGG ≥15 MB. Những số đo này không thay thế nghe thử.

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
