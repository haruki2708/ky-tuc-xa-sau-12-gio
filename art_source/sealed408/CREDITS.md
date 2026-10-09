# T-206 — ảnh so sánh tấm bịt 408

- Tác giả/công cụ: Lane B, Codex (OpenAI), Godot 4.7.2, Forward+ / Vulkan trên NVIDIA GeForce RTX 3050 Laptop GPU.
- File: `previews/front_before.png`, `front_after.png`, `oblique_before.png`, `oblique_after.png`; giấy phép CC0-1.0, ảnh render từ tài nguyên CC0 sẵn có của dự án.
- Nguồn: [capture.gd](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-b/T-206-sealed-408-flicker/art_source/sealed408/capture.gd), [tài nguyên gốc](../CREDITS.md). Không tải asset ngoài, không sinh ảnh bằng AI. Codex viết mã kiểm tra và script chụp ảnh.

Ảnh **before** chụp scene tại base `f468ffa` trước khi dịch tấm (z = 0,075); ảnh **after** chụp sau sửa (z = 0,13). Hai góc nhìn giữ cùng vị trí, FOV 70°, độ phân giải 1280×720 và ánh sáng sẵn có của `floor4.tscn`; không thêm đèn. Góc chính diện: mắt `(36,1.6,2.6)`, đích `(36,1.2,0.1)`; góc xiên: mắt `(33.8,1.6,1.5)`, đích `(36,1.15,0.1)`.

Chụp lại bản hiện tại từ gốc repo:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script D:/GAME_WORK/lane-b/art_source/sealed408/capture.gd --rendering-method forward_plus --audio-driver Dummy -- --phase=after
```

Tham số `--phase` chỉ đặt tên ảnh, không sửa tọa độ scene hay dựng lại trạng thái cũ. Muốn tái tạo ảnh trước phải dùng scene của base nói trên.

## Rà hình học

- `Floor4/Corridor/Sealed408`: phát hiện hai mặt trước trùng tại z = 0,10. Dịch tâm thêm 0,055 m theo z; mặt sau mới 0,105 và mặt trước mới 0,155, cách tường lần lượt 0,005 và 0,055 m. Giữ nguyên x/y, kích thước, chất liệu và collision của tường.
- Tầng 4: 8 `RoomPlate_401…408` ở z = 0,13, dày 0,035; mặt sau 0,1125, cách khung cửa 0,0125 m. Các module `Doorway_*`/`Facade_*` nối tại mép theo generator, không đặt biển/tấm thứ hai trùng mặt tường. Không phát hiện thêm tấm bịt tương tự.
- Nhà B tầng 2–3: 16 biển `KitDetail2…3/Plate0…7` có mặt sau 0,1025, cách mặt trước khung 0,0025 m; mặt trước biển ở 0,1375. 16 `Frame0…7` có mặt trước 0,10; tường `Facade*` và `Lintel*` ở 0,08, chênh 0,02 m. Hai nhóm đã được đo từ mesh trên scene trong test, không cần sửa.
- Cập nhật cả hai nơi sinh `Sealed408`: `art_source/campus/room_doors.py` và `art_source/ch1v2_props/build_room.py`. Không chạy lại toàn bộ generator để tránh ghi đè các sửa tích hợp khác.
- Phạm vi rà tự động là tấm bịt, biển phòng và khung cửa nêu trên; không khẳng định đã kiểm mọi cặp tam giác hoặc mặt phẳng toàn tầng.
