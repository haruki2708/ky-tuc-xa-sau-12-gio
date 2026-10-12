# Nguồn màn hình chính T-139

- `corridor.png`: ảnh chụp tầng 4 của chính dự án, qua filter PS1, bằng Godot 4.7.2 Forward+ và `tools/capture.ps1`; không chỉnh sửa ảnh. Lane D, CC0-1.0 theo nguồn kit/tầng 4 của Lane B trong [art_source/CREDITS.md](../../../art_source/CREDITS.md). Scene chụp: `background_test.tscn`; camera `(32, 1.65, 1.1)`, hướng dọc hành lang về phía −X.
- URL giấy phép ảnh/asset kit: https://creativecommons.org/publicdomain/zero/1.0/. Công cụ: https://godotengine.org/ và https://www.blender.org/.
- Tiếng ù: dùng lại `game/audio/ambience/fluorescent_hum.ogg`, Lane E, CC0 1.0; chi tiết tổng hợp và tác giả ở [game/audio/CREDITS.md](../../audio/CREDITS.md). Title phát ở −12 dB trên bus Ambience, tôn trọng âm lượng/mute trong Cài đặt.
- Font dùng lại Be Vietnam Pro Regular: The Be Vietnam Pro Project Authors, SIL OFL 1.1; [nguồn font](../../assets/fonts/CREDITS.md).
- Màn credits dùng các key `UI_CREDITS_*` trong CSV, tổng hợp từ ba file nguồn trên tại base `7dbce51`. Chưa có TTS/credits T-137 ở base này; cần cập nhật khi tích hợp asset mới.
- Khai báo AI: OpenAI Codex hỗ trợ viết mã UI, shader và scene chụp. Ảnh render từ asset nội bộ có mã tạo bằng AI hỗ trợ như khai báo của Lane B; không sử dụng mô hình sinh ảnh hay nguồn ảnh bên ngoài. Credits âm thanh cũng ghi Anthropic Claude cho phần bước chân T-123 theo nguồn Lane E.

Chụp lại nền: `pwsh tools/capture.ps1 -Scene res://ui/title/background_test.tscn -Frames 5 -Resolution 1920x1080 -Out build/T-139/background`. Dùng user data riêng để filter lấy mặc định cường độ/độ sáng 1.0. Ảnh bằng chứng UI nằm trong `previews/`, chụp qua `title_test.tscn`.

T-155 bổ sung `previews/chapters_vi.png`, `chapters_en.png`, `warning_ch1_vi.png` và `warning_ch1_en.png`: ảnh render UI bằng Godot 4.7.2, 1920×1080, cùng nền/font nêu trên. Mã chọn chương và cảnh báo được viết với hỗ trợ của OpenAI Codex; không thêm nguồn artwork bên ngoài.

## T-214 — 12/10/2026

- `corridor_night.png`: ảnh gốc 1920×1080 từ `corridor_still.tscn`, instance tầng 4 của dự án ở base `25e3bfe`; Godot 4.7.2, Forward+, RTX 3050 Laptop. Camera `(32, 1.65, 1.1)`, hướng −X, FOV 68; thêm một đèn bù xanh lạnh trong scene chụp riêng. Không gắn filter PS1 vào camera chụp, không sửa cảnh tầng 4 hoặc cấu hình game. Không chỉnh ảnh sau render. Nguồn kit và CC0 1.0 giữ như trên; bản giấy phép ở `../theme/textures/CC0-1.0.txt`. SHA-256 `42e8582503e047fc222e636767410a0c254756f06336603944eeb6906a61c8ed`.
- Bản title dùng ảnh này với shader trôi UV rất chậm, dao động sáng nhẹ, grain và viền tối; `reduce_scares` tắt chuyển động/dao động. Đây là phương án ảnh chụp được prompt T-214 cho phép; chưa phải bản nâng vật liệu hành lang của lane B và chưa có số đo FPS để so với nền 3D sống.
- Logo dùng chữ dịch `UI_GAME_TITLE` và Be Vietnam Pro SemiBold OFL; chỉ thay cách dàn trang, không đổi nội dung/key. Nguồn ở [fonts/CREDITS.md](../../assets/fonts/CREDITS.md).
- Bộ ảnh trước/sau và nguồn giấy/icon/theme tại [theme/CREDITS.md](../theme/CREDITS.md), [trang đối chiếu](../theme/previews/index.html).
