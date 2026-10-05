# T-165 — Khu camera an ninh (Claude làm thay lane B)

Tạo lại: `python art_source/cctv/build_cctv.py`, rồi import Godot (`--headless --editor --import`). Generator dùng helper của T-153 (`floor4/build_floor4.py`) và T-154 (`ch1_models/build_models.py`).

## `res://scenes/levels/cctv/cctv_set.tscn`
Gốc ở Y = −60. Bốn phòng 4×5 m, cách nhau 6 m theo X:

| Node | Sinh viên | Bày đồ |
|---|---|---|
| `Room102` | Hùng (áo hoodie xám, mũ trùm) | áo phơi, dép, poster |
| `Room306` | Kiệt (áo trắng, kính) | khăn, xô, đồ trên bàn |
| `Room209` | Bảo (áo xanh, tóc dài) | chồng sách, đồ giặt |
| `Room106` | Đăng (áo vàng, quần đùi, người to) | **đèn bàn sáng** (`DeskLamp`) |

Mỗi phòng có:
- `Cam`: Camera3D ở góc trần, FOV 66, thấy cửa và giường nạn nhân;
- `Door`: ngoài cửa, chỗ quản lý xuất hiện;
- `ManagerSpot`: cạnh giường nạn nhân;
- `VictimBed`: tầng trên giường dãy A, màn mở để camera nhìn thấy;
- `Victim`: sinh viên của phòng, sẵn tư thế `lie_awake`;
- `NightLight` xanh mờ, để ảnh camera đen trắng vẫn đọc được.

`Corridor`: đoạn hành lang tầng 4 giả với cửa 405, 406, 407; có `Cam` nhìn dọc hành lang.

## Sinh viên `student_{hung,kiet,bao,dang}.tscn`
Rig giống xác T-154: gốc ở mặt nệm, đầu về +Z. Dưới 650 tam giác. API `set_pose(pose) -> bool`, danh sách `POSES`:

| Tư thế | Mô tả |
|---|---|
| `lie_awake` | nằm, mở mắt, nghiêng đầu |
| `sit_up` | ngồi dậy |
| `answer` | nằm giơ tay "dạ có" |
| `phone_lit` | hai tay cầm điện thoại trên mặt, màn hình phát sáng (`Phone`, có OmniLight nhỏ) |
| `cower` | ngồi co chân, tay ôm, cúi đầu |
| `dead` | gục, vệt máu ngực và cổ, tay buông |

## Ảnh preview (`previews/`)
- `cam_<phòng>_*.png`: nhìn từ từng `Cam`;
- `pose_*.png`: cận từng tư thế;
- `phone_cam_102_*.png`: tab Camera thật trên điện thoại khi chạy chương 1, quản lý vào và giết.
