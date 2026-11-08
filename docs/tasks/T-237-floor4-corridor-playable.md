# T-237 — Hành lang tầng 4 mới vào bản chơi (bốn chương)
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141)
- Nhánh: `lane-b/T-237-floor4-corridor-playable` từ `origin/main` mới nhất.
- Quyết định giao: **D-148** (08/11/2026: chủ dự án duyệt T-235, chọn biển số A và cửa 408 cũ kiểu 1, cho phép đo FPS). Tiếp nối [T-235](T-235-floor4-corridor-full-shell.md) (cả hành lang trong cảnh thử `corridor_g5_pilot`) và [báo cáo FPS](../../tools/reports/D-148-corridor-fps.md): hành lang mới ≥ 60 FPS ở 1080p, chậm hơn PS1 khoảng 0,55 ms/khung.
- Lượt này đưa hành lang mới vào **bản chơi**: `floor4.tscn` dùng chung cho cả bốn chương, nên mọi chương đổi theo.

## Chủ dự án chọn (08/11/2026)
- Biển số **A** (nhôm, số dập sơn đen); cửa 408 cũ ở X=36 **kiểu 1** (xây kín, trát vữa); lan can **A1**. Bỏ mọi biến thể khác khỏi bản chơi (giữ trong cảnh thử nếu muốn).

## Việc cần làm
1. **Cách đưa vào (lane B đề xuất, integrator duyệt trong Handoff trước khi merge):** theo mẫu phòng 407: phần dựng hiện nằm trong `corridor_g5_pilot.gd` (`build`, `set_upgraded`, `set_plates`, `set_seal`) được tách thành một script production (ví dụ `game/scenes/levels/floor4/corridor_shell.gd`), `floor4.gd` gọi nó trong `_ready`; cảnh thử cũng gọi đúng mã đó và giữ phím G so PS1. Nếu cách khác tốt hơn, ghi lý do. **Không xóa node PS1**, chỉ ẩn mesh như cảnh thử (hợp đồng `PLAN.md` mục 2).
2. **Hợp đồng gameplay giữ nguyên:** mọi node, transform, va chạm, navigation trong `PLAN.md` mục 2. Phải còn đạt: `test_floor4`, `test_wide_corridors`, tuyến quản lý chương 1, cửa 408 chương 3 (`_wave_408`), proxy chương 4, `test_room407_*`, `test_corridor_g5`.
3. **Nối Campus (chương 3–4):** hai đầu hành lang khi có Campus (cầu thang chính ở X=0, cầu thang thoát hiểm ở X=44). T-235 mới chụp ảnh; lượt này phải **đi bộ thật** bằng capsule từ hành lang xuống cả hai cầu thang ở chế độ Campus (test mới trong `game/tests/levels/`), và cửa thoát hiểm chương 3 mở được.
4. **Số liệu:** ghi số tam giác, mesh, vật liệu của cảnh chơi (Floor4 một mình và Floor4 + Campus) trong Handoff.
5. **Ảnh trong cảnh chơi thật:** chụp 1080p bằng cảnh chương (không phải cảnh thử) ở chương 1 và chương 3: dọc hành lang, trước cửa 407, chỗ nối cầu thang. Dùng chế độ chụp của T-235 hoặc cảnh chụp mới.

## Được phép sửa
- `game/scenes/levels/floor4/` (`floor4.tscn`, `floor4.gd`, `corridor_g5_pilot.*`, `corridor_capture.*`, script production mới), `art_source/graphics_upgrade/floor4_corridor/`, `game/assets/models/graphics_pilot/floor4_corridor/`, `game/rendering/` (chỉ thêm), `game/tests/levels/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa `door407.gd`, phòng 407, Campus (`game/scenes/levels/campus/`), director, `game/scripts/core/`, shader 407 đang dùng; không đổi tên, dời, xóa node hợp đồng; không thêm va chạm.
- Không tiêu credit Tripo; asset chỉ CC0, CC-BY.
- **Không đo FPS** và **không chạy bot**: D-148 chỉ cho phép đo hành lang trong cảnh thử (đã xong); đo trong chương thật và chạy lại bot phải xin chủ dự án riêng, integrator làm.

## Ghi chú đã biết (không phải việc của lượt này)
- **CCTV** (`CCTVSet/Corridor`, hình hành lang trên điện thoại ở chương 1) vẫn PS1 và sẽ lệch với hành lang mới: tách việc riêng cho integrator (`PLAN.md` mục 7.4), không tự sửa; ghi ảnh chỗ lệch trong Handoff nếu thấy.
- Còn PS1: bên trong phòng 401–406 và 408, bàn trực, nhà vệ sinh chung, đồ phơi, cầu thang (lượt sau).
- Bot chương 2–3 đi qua hành lang này; sau khi merge integrator xin chủ dự án chạy lại ca good (lane C hiện hết hạn mức).

## Checklist hoàn thành
- [ ] Hành lang mới có trong cả bốn chương, một mã dùng chung với cảnh thử
- [ ] Mọi test hợp đồng ở mục 2 đạt, không đổi node/va chạm
- [ ] Đi bộ capsule thật tới hai cầu thang ở chế độ Campus; cửa thoát hiểm mở được
- [ ] Ảnh 1080p từ cảnh chương thật (chương 1 và 3)
- [ ] Số tam giác, mesh, vật liệu trong Handoff
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot; chạy bằng tiến trình pwsh riêng ghi log)
- [ ] Handoff trung thực, có commit hash, ghi rõ chỗ chưa kiểm

## Cách kiểm tra
- Integrator xem ảnh, chạy full test và check, xin chủ dự án đo FPS trong chương thật rồi mới build `KyTucXa.exe` cho chủ dự án chơi thử.

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
