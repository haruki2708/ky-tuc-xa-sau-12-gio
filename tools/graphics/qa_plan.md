# T-210 — Chuẩn bị ảnh và hồi quy, chưa thực thi G2

Không chạy render/FPS/bot trong G0. Tất cả mục dưới đây **chưa kiểm trên visual mới**; scene mẫu B và hợp đồng G1 chưa có trên baseline. Không dùng fixture làm bằng chứng cảnh thật.

## Góc cố định đề xuất

Ba góc dưới lấy nguyên tọa độ world/FOV từ `game/scenes/levels/room407/room407_fixes_capture.gd` (T-203), chưa chụp lại. Scene nền `res://scenes/levels/floor4/floor4.tscn` có root phòng ở (30,0,0). Không tự chạy script T-203 vì script đó ghi ảnh vào vùng B.

| ID | Eye XYZ (m) | Target XYZ (m) | FOV |
|---|---|---|---|
| bunk_b | 35.8, 1.55, -1.4 | 37.35, 0.9, -2.7 | 65° |
| bunk_a | 32.15, 1.55, -1.7 | 30.65, 0.9, -3 | 65° |
| khoa_outlet | 30.95, 0.66, -1.95 | 30.12, 0.27, -1.8 | 65° |

G2 bổ sung cửa 407/hành lang 10–15 m/đạo cụ/nhân vật sau khi B cung cấp scene và marker; chưa tự bịa vị trí. Tạo capture fixture trong vùng C, output riêng `build/graphics/captures/<run>/`. Cặp trước/sau phải cùng scene state, camera, resolution 1920×1080, FOV, renderer, settings đã chốt, thời điểm đèn và animation; lưu commit + hash model + engine. T-203 có đèn kiểm riêng nên ảnh đó chỉ là tham chiếu góc, không chứng minh ánh sáng gameplay. Chụp gameplay giữ đèn thật; bộ inspection light phải ghi nhãn riêng. Ảnh capture fixed-fps không phải benchmark.

## Ma trận bốn chương (toàn bộ pending G1/G2)

| Cảnh thật | Tình huống giữ nguyên | Bằng chứng cần |
|---|---|---|
| `res://scenes/main/chapter1.tscn` | InteractRay cửa 407/giường/ổ điện; góc nằm và collider; quản lý bước tới/hunt/open_door, BladeTip; luật/gõ tường không đổi | Người chơi đi/ngắm/bấm thật; ảnh cùng góc; đối chiếu marker và thời điểm trước/sau |
| `res://scenes/main/chapter2.tscn` | Cửa/giường/phòng dùng chung; rig xác/giẻ tại miệng; chữ/tài liệu vi/en đọc được | Kiểm ray qua visual; pose/mouth marker; không thay từ nối, số vòng hay lời thoại |
| `res://scenes/main/chapter3.tscn` | Phòng/tầng 4 dùng chung; cửa 408; đường 207→203; bình cứu hỏa/FireAlarm1F; đường cầu thang/khuôn viên; head_position và nguồn âm | Chơi tay/kiểm mục tiêu khi được xếp lượt; nav/collision/timing giữ nguyên; không chạy bot |
| `res://scenes/main/chapter4.tscn` | Phòng 407 cuối; vạt giường/thanh chắn; cửa phá/door_burst; thư viện/bệnh viện, chữ và marker thoại | Chơi tay/ảnh; tương tác và đường đi, âm cần chủ dự án nghe; không chạy bot |

Không sửa luật, lời thoại hoặc timing để làm kiểm tra đạt. Lỗi ngoài phạm vi báo integrator với scene/commit/bước tái hiện/expected/actual.

## Benchmark: chờ quyền riêng

Chưa chạy FPS, chưa có kết quả 1080p/60. Khi được phép: integrator xếp lượt độc quyền GPU; ghi CPU, GPU, VRAM/RAM, nguồn điện/chế độ máy, driver, Godot/renderer, commit, preset Medium đã chốt, resolution viewport/render thực 1920×1080 và render scale, VSync/cap, warm-up và thời lượng. Ghi mean FPS, mean/p95/max frame time, RAM/VRAM và cách lấy mẫu; p95 là frame time, không suy từ FPS trung bình. Chạy 0/20/40 xác chỉ khi scene/công cụ hỗ trợ và có quyền; tách số 720p cũ. Không tự sửa settings để tạo preset khi G1 chưa chốt.

## Xếp lượt Windows

Lượt C sau B ngày 11/10 đã hoàn tất: full test **725/725 PASS**, check **0 lỗi / 336 script parse PASS**; **C đã nhả lượt Godot**. Giờ và bằng chứng tại `reports/g0_validation.md`. Các lượt tiếp theo vẫn cần integrator xác nhận bàn giao, chạy tuần tự, ghi thời gian/RESULT, kiểm tiến trình trước lượt và không kill process lane khác. Chưa có slot thì làm offline; quyền render/FPS/bot không được suy ra từ lượt test/check.
