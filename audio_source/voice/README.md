# Giọng loa T-137

Giọng máy offline **eSpeak NG 1.52.0**, `vi` (Vietnamese Northern, nam) và `en-gb` (English Great Britain). Đây là tổng hợp formant/quy tắc, **không phải mô hình neural và không dùng bản ghi giọng người/MBROLA**. Chọn công cụ này vì chạy tại máy, giấy phép công cụ/dữ liệu giọng cho phép thương mại; chất giọng khá máy, cần chủ dự án nghe duyệt. Công cụ GPL-3.0-or-later chỉ phục vụ build ở D:\Tools, không đóng gói engine/data vào game. Nguồn, giấy phép và khai báo AI-assisted đầy đủ tại `game/audio/CREDITS.md`.

## Tạo lại

Chạy từ gốc repo, không cần pip, API TTS, tài khoản hoặc plugin:

```powershell
# Chỉ lần đầu cần mạng để lấy công cụ chính thức, giải nén vào D:\Tools.
pwsh audio_source/voice/setup.ps1
# Từ đây chạy hoàn toàn offline, luôn tạo lại raw lẫn OGG từ CSV.
py -3 audio_source/voice_process.py
py -3 audio_source/test_voice_process.py
pwsh tools/test.ps1 -Filter audio
```

`setup.ps1` dùng lessmsi portable 2.12.9 để đọc/giải nén MSI, không chạy installer, không đăng ký SAPI. MSI administrative extraction thử ban đầu bị Windows trả 1625; quy trình tái tạo chính thức dùng giải nén archive. SHA256 archive cố định trong script (giá trị đo từ bản tải chính thức, không phải chữ ký nhà phát hành). Bản exe eSpeak SHA256 `3080ec3822c1b266ef557c710bc79a97d20a7ab133a34bac308b81ab0afc733e`. Không cài công cụ vào C:.

Mặc định TTS ở `D:\Tools\espeak-ng\1.52.0\portable\SourceDir\eSpeak NG\espeak-ng.exe`, FFmpeg 9.0.2 ở `D:\Tools\ffmpeg\ffmpeg-9.0.2-essentials_build\bin\ffmpeg.exe`. Có thể truyền `--tts`/`--ffmpeg`; script yêu cầu version eSpeak 1.52.0, chỉ định cả `--path` và `ESPEAK_DATA_PATH` để không tìm dữ liệu trong Program Files. File tạm chỉ trong `audio_source/voice/processing_*`, tự dọn cuối lượt.

## Nội dung và xử lý

- Đủ **17 key × 2 locale = 34 file**. `KEYS` trong `voice_process.py` là danh sách card; văn bản lấy trực tiếp CSV mỗi lần chạy. Bỏ phần ngoặc rồi bỏ tiền tố Loa/Speaker; không tự viết lại nội quy, thông báo, tên hoặc thêm câu.
- Sáu key `SPK_NAME_*`, gồm tên Trung gọi lại, dùng văn bản/giọng Việt cho cả hai locale. `SPK_AND_TRUNG` tiếng Anh chia ba phần theo tên lấy từ CSV, phần tên đọc bằng `vi`, phần còn lại `en-gb`. Report ghi text/voice từng phần để review.
- Nhịp eSpeak 145 WPM, pitch 42. `SPK_NAME_TRUNG_AGAIN` dùng 95 WPM, giữ dấu ba chấm của CSV để chậm/ngắt/kéo dài; không sửa bản dịch. WAV thô PCM16 mono 22,050 Hz được lưu ở `raw/<locale>/<KEY>.wav`, OGG mono 48 kHz ở `game/audio/voice/<locale>/<KEY>.ogg`.
- Lọc high-pass 300 Hz/low-pass 3400 Hz, tanh soft-clip nhẹ; ba phản xạ ngắn 47/89/137 ms với gain 0.13/0.08/0.04; hiss dải thoại rất nhỏ, seed theo locale/key. Fade đầu 5 ms/cuối 50 ms. Loudnorm hai lượt, đo lại OGG và hiệu chỉnh về −26 LUFS (±1 LU), true peak ≤−1 dBTP. Vorbis q4 bitexact. Vang đã nằm trong clip, cùng nguồn 3D/đặc tính không gian của loa.
- **Điều 3:** raw là **đầy đủ `RULE_3`** được tạo thành phần tiền đề và hành động riêng để có mốc mẫu chính xác. Sau xử lý loa/reverb, từ trước mốc hành động 10 ms chuyển sang nhiễu; từ mốc đó đến cuối clip, hệ số của tín hiệu lời gốc **bằng 0**. Nhiễu thay thế toàn bộ phần hành động, không chỉ cộng rè lên lời còn nghe được. Chỉ `RULE_3_GARBLED.ogg` vào game; không xuất `RULE_3.ogg`. Burst runtime vẫn chồng như trước, nhưng việc bảo vệ lời giải không phụ thuộc burst. Test Python thay mọi mẫu lời ẩn bằng tín hiệu khác mà output không đổi.
- `build_report.json` riêng ghi SHA256 raw/OGG, LUFS/peak/thời lượng, text/voice, tốc độ, mốc che và hidden gain. Ngân sách voice raw+OGG <20 MB; ngân sách 43 âm cũ vẫn <20 MB, tính riêng trong `process.py`. Cả hai bank <40 MB tổng, mỗi file vẫn <10 MB.

## Speaker và thử trong Godot

`Speaker` tự dùng clip khi key được allowlist và file của locale tồn tại. Mặc định `voice_locale="Settings"`, đọc `[ui] locale` bằng ConfigFile ở đầu từng dòng, thiếu/sai kiểu/không hỗ trợ → `vi`. Dòng đang phát giữ giọng hiện tại, đổi locale có tác dụng ở dòng kế. `voice_directory="res://audio/voice"`; thư mục trống/thiếu file/key ngoài allowlist quay về cách cũ, không báo lỗi load.

Player con `Speech` là AudioStreamPlayer3D ở gốc loa, bus Voice, theo gain/pitch/attenuation của Speaker. Không phát TTS thời gian thực. Dòng có giọng giữ `max(clip.get_length() + 0.4, line_seconds)`, vẫn đúng **một** subtitle lúc dòng bắt đầu, sau khi voice đã bắt đầu. Hoàn tất vẫn chờ power-off; stop/restart/unload/reentrant cancellation dừng cả speech lẫn rè. Với pitch khác 1, thời lượng vẫn theo công thức độ dài clip của card, không tự chia pitch.

F6 `res://audio/test/segment12_test.tscn`: **V** nghe lần lượt 17 key tiếng Việt; **B** tiếng Anh; **Space** chuỗi cũ theo locale settings; **0** dừng; **Esc** thoát sạch. F1–F11 giữ các hiệu ứng cũ. V/B chỉ chọn locale cố định trên node thử, không ghi settings hoặc đổi ngôn ngữ UI. Phụ đề vẫn theo locale UI hiện tại; muốn chữ và giọng cùng ngôn ngữ, chọn ngôn ngữ trong menu game trước rồi mở scene, hoặc thử Space. Cả lượt khoảng một phút rưỡi; tên và câu cuối xuất hiện theo thứ tự card để kiểm duyệt asset, không phải diễn biến game.

**Chưa nghe bằng tai** phát âm Việt/Anh, dấu/tên riêng, mức rè, vang, chất loa và độ rõ của lời. Che phần hành động được kiểm tra bằng tín hiệu/mẫu; vẫn cần nghe tiền đề và mốc chuyển rè. Test headless không thay thế duyệt giọng hoặc chơi thử điểm danh.
