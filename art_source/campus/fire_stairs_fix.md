# T-188 — lane E làm thay lane B (D-060)

Sửa hẹp khối sập cầu thang thoát hiểm, không dựng lại Campus/Floor4.

| Thành phần | Trước | Sau |
|---|---|---|
| `FireStairs/Collapse` tâm | (46,5; −5,6; −2,1) | (45,25; −5,6; −2,1) |
| Collision `s462`, mesh `s463` | (5; 2; 4,2) | (2,5; 2; 4,2) |
| Khoảng x của khối sập | 44…49 | 44…46,5 |
| `FireRubbleDetail` | transform đơn vị | position (22; 0; 0), scale (0,5; 1; 1) |

Transform chi tiết đổ nát tương ứng `x_mới = 44 + (x_cũ − 44)/2`, chỉ thu
phần Fire về nửa A. Các chunk/rebar vốn là mesh trang trí không có collision.
Tên node/anchor, y/z của khối sập, vế thang 3B, hành lang rộng 4 m và toàn bộ
phần khác của map giữ nguyên. `build_campus.py` và nhánh Fire trong `detail.py`
được đồng bộ với scene; không chạy generator ghi lại toàn bộ bản đồ.

Không cần thêm rào hoặc collision mới: đã kiểm tra người thật ở bảy vị trí
theo bề ngang chiếu nghỉ, và sáu lượt đi/nhảy ngang từ ba điểm trên 3B.
Không lượt nào xuống thấp hơn y=−6,9; tầng 1 ở y=−9,9. Test nhảy dùng xung
4,5 m/s (cao khoảng 1 m) để thử thêm khe hở; **không thêm cơ chế nhảy vào game**.
Đây là các trường hợp regression xác định, không khẳng định đã thử mọi
quỹ đạo hay chơi thủ công cả chương.

## Test

`game/tests/levels/test_fire_stairs.gd` dựng Floor4 + Campus, mở cửa qua API
`set_fire_door_open(true)`, thêm nguyên scene `scenes/player/player.tscn`.
Capsule thật cao 1,75 m, bán kính 0,3 m; giữ mask/collision/floor snap mặc định.
Chỉ tắt đọc input và điều khiển bằng velocity, trọng lực và `move_and_slide`.
Player không được teleport giữa các điểm mốc của tuyến đi bộ.

- Tuyến liên tục: hành lang tầng 4 → cửa → 4A → chiếu nghỉ giữa → 4B → tầng 3
  → 3A → chiếu nghỉ giữa → 3B → chiếu nghỉ tầng 2 → hành lang tầng 2.
  Mỗi điểm giới hạn 360 physics frame (~6 giây ở 60 Hz), tốc độ đi 2,2 m/s.
- Bảy điểm xuất phát trên chiếu nghỉ tầng 2: x=44,35 / 45,25 / 46,35 / 46,6 /
  46,9 / 47,8 / 48,65, thử đi về đoạn sập với tốc độ chạy 3,6 m/s.
- Đi ngược lên 3B từ tầng 2 tới z=−0,6 / −2,4 / −4,5, rồi thử đi ngang trái
  và nhảy ngang trái để tìm khe rơi. Chỉ teleport để khởi tạo từng trường hợp
  độc lập, không teleport qua vật cản.

Trên hình học cũ, test đi bộ FAIL tại chân đoạn 3B, feet khoảng
(47,678; −5,031; −4,513), collider `Collapse`. Sau sửa, tới hành lang tầng 2
ở (42,118; −6,600; 1,997), cả ba test PASS.

```powershell
pwsh tools/test.ps1 -Filter fire_stairs
pwsh tools/test.ps1
pwsh tools/check.ps1
```

Kết quả full/check cuối ghi trong Handoff T-188. Lượt baseline đầu trong
sandbox còn có lỗi kho chứng chỉ Windows của Godot; lượt xác nhận bản sửa
chạy ngoài sandbox, không có lỗi đó. Không chạy bot playthrough chương 2/3.

## Ảnh thật từ chiếu nghỉ tầng 2

[Ảnh 1280×720](previews/fire_stairs_floor2_fixed.png): camera ở
(47,6; −5; 2,3), cao 1,6 m trên sàn tầng 2; nhìn về (45,9; −5,9; −2).
Khối sập ở nửa bên trái; vế 3B bên phải vẫn thông tới chiếu nghỉ.
Giữ ánh sáng và vật liệu Campus thật, không chèn hình minh họa.

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/campus/fire_stairs_capture.gd --resolution 1280x720 --audio-driver Dummy
```

Đã xem ảnh render. **Chưa chơi thủ công trong bản tích hợp, chưa export bản
Windows mới**; integrator merge rồi export để chủ dự án thử lại. Không có
thay đổi luật chơi/cốt truyện hoặc yêu cầu sửa gameplay.
