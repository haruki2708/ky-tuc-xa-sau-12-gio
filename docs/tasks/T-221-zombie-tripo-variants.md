# T-221 — G4 xác sống Tripo: mẫu gốc và 10 dạng cho chương 3–4
- Lane: **chủ dự án + Claude** (chủ dự án tạo mẫu gốc trên Tripo; Claude đóng gói, làm biến thể, nối gameplay, ghi "Claude làm thay A/B") | Trạng thái: **mới (D-122), chờ chủ dự án tạo mẫu m1** | Agent: chủ dự án + Claude
- Quyết định:
  - **D-121**: xác sống làm trước trong nhóm nhân vật khác.
  - **D-122**: kiểu A xác vừa chết. Chủ dự án: "1: A xác sống vừa chế, 2 : như quản lý ( tôi tạo Trung trên tripo, các xác sống làm tripo khoảng vài mẫu xong bạn bắt chước mà sản xuất hàng loạt xác sống theo kiểu đó)".
- Phụ thuộc:
  - D-120: quy trình Tripo → Godot (`art_source/graphics_upgrade/manager/`; cách tô mắt `paint_milky_eyes`);
  - T-182: AI xác sống `game/scripts/entity/zombie.gd`, `zombie_horde.gd`;
  - T-183: 10 mô hình PS1 `game/assets/models/campus/zombie_01…10.tscn` (wrapper `scenes/levels/campus/actor.gd`);
  - T-208: bảng hợp đồng (`Ch3Actor.set_body/play_pose/head_position`, HeadHitbox của thanh sắt, `DoorBurst`, camera chết);
  - `chapter3_director.gd`: `ROOMMATES = {1: zombie_01, 2: zombie_02, 4: zombie_03}`, `ZOMBIE_MODELS = 10`.

## Mục tiêu
Thay 10 xác sống PS1 bằng xác sống Tripo kiểu A. Giữ nguyên AI, luật, tốc độ và thời gian của chương 3–4.

## Việc cần làm
1. **Chủ dự án:**
   - tạo m1 theo [`TRIPO_XAC_SONG.md`](../handoff/TRIPO_XAC_SONG.md), kèm đủ preset động tác;
   - xem quy trình chạy thử trên m1 (ảnh trong game), duyệt xong mới làm m2–m4 (chỉ cần `idle`, `walk`).
2. **Đóng gói:**
   - tách phần chung của `pack_tripo_manager.py` thành công cụ cho mọi nhân vật Tripo;
   - texture ≤ 1024;
   - mắt đỏ phát sáng nhẹ: tô texture, thêm map phát sáng;
   - giữ dưới 10 MiB một file.
3. **Động tác:**
   - tên clip đúng `Ch3Actor.play_pose`: `idle`, `walk`, `stunned` (gục 5 s), `grab` (vồ), `sit`, `lie`, `wake` (đứng dậy);
   - dùng chung qua `SkeletonProfileHumanoid`;
   - Tripo thiếu thì lấy CC0 rồi chỉnh tay (D-121 cách c);
   - đi chậm khoảng 2/3 tốc độ người chơi, chân không trượt.
4. **10 dạng `zombie_01`–`10`:**
   - 01–03 là Phúc, Việt, Đạt (m1–m3);
   - 04–10 làm từ các mẫu:
     - đổi màu áo, quần, tóc theo vùng cơ thể (vùng lấy từ trọng số xương của texel);
     - đổi chỗ máu và vết thương, sắc da;
     - chiều cao ±5 %;
     - lệch nhịp đi.
5. **Hợp đồng gameplay** (không đổi số nào):
   - node `Head` bám xương đầu: `head_position`, HeadHitbox thanh sắt, đường nhìn;
   - `DoorBurst` dùng `zombie_01` với `grab`/`walk`;
   - cảnh chết `zombie_grab` ngắm vào đầu.
6. **Hiệu năng:**
   - khoảng 40 con cùng lúc; dùng chung texture và khung xương;
   - LOD tự động khi import; con ở xa đã cập nhật thưa (thiết kế chương 3);
   - đo FPS phải hỏi chủ dự án trước.
7. **Cảnh xem thử và ảnh:** 10 dạng đứng hàng dưới đèn pin, cận mặt, đang đi. Chủ dự án duyệt **trước khi vào bản chơi**.
8. **Test:**
   - đủ clip;
   - `Head` bám đầu khi đi, gục, nằm;
   - ngân sách tam giác, vật liệu, texture;
   - `Ch3Actor.play_pose` với thân mới;
   - bầy xác chương 3 chạy với thân mới.

## Để sau
- **Xác 3 bạn cùng phòng ở chương 1–2** (`ch1_models/corpse_body`): dùng chung mô hình Phúc, Việt, Đạt; làm sau khi `zombie_01`–`03` đạt. Cần giữ bịt miệng, máu và các tư thế của `corpse_body.gd`.
- **2 bạn học** (Minh Nhật, Ngư) và **bảo vệ**.

## Handoff (người làm điền)
