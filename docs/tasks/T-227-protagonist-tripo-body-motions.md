# T-227 — Nhân vật chính Trần Trung trên Tripo: thân thật và đủ động tác
- Lane: **chủ dự án + Claude** (như T-219: chủ dự án tạo trên Tripo, Claude làm phần còn lại, ghi "Claude làm thay A/B") | Trạng thái: **chờ chủ dự án tạo thân và động tác theo phiếu** | Agent: chủ dự án + Claude Code ở máy (Opus 5.5)
- Quyết định: **D-137**.
- Phiếu Tripo: [`TRIPO_NHAN_VAT_CHINH.md`](../handoff/TRIPO_NHAN_VAT_CHINH.md).
- Nối tiếp [T-220](T-220-protagonist-body-hands-pilot.md):
  - bước 1 xong trên thân tạm CC0 (D-123, D-124): thấy chân, bóng, gương; 3 thao tác tay 1 giây bằng IK;
  - D-130: tự mở/đóng cửa ban công làm cùng bước 5.

## Chủ dự án chọn (23/10/2026)
> "Làm nhân vật chính có thân, có thể dùng tripo AI: đầy đủ động tác như người bình thường"

**D-137:**
- Trần Trung làm trên Tripo, như quản lý.
- Nguồn chuyển động chính đổi sang **động tác có sẵn của Tripo** (trước là CC0 trên thân tạm, D-121 cách c). Thiếu động tác nào thì Claude bù bằng IK hoặc CC0.
- **Ngoại hình:**
  - đồ ngủ: áo phông xám cũ, quần đùi tối màu, dép tổ ong;
  - nam khoảng 20 tuổi, 1,70 m, gầy vừa, tóc đen ngắn hơi rối, mặt mệt mỏi, quầng thâm, không kính.
- **Giữ nguyên D-121:**
  - thấy cả người: chân, bóng, gương;
  - mỗi thao tác tay 1 giây, hiện đủ động tác;
  - 1 giây đó tính vào thời gian luật.

## Việc của chủ dự án
Tạo theo phiếu, tải về `build/graphics/staging/protagonist/`, báo lại kèm ảnh chụp danh sách động tác Tripo:
- thân;
- động tác nhóm 1 bắt buộc, các nhóm 2–5 càng nhiều càng tốt;
- điện thoại.

## Việc của Claude (sau khi có file)
1. **Đóng gói** (`art_source/graphics_upgrade/protagonist/pack_tripo_protagonist.py`, theo `pack_tripo_manager.py`):
   - gom động tác vào một GLB;
   - đặt tên clip theo game;
   - bỏ trôi hông cho đi, chạy, đi khom;
   - cắt đoạn;
   - cao 1,70 m, nhìn −Z, texture ≤ 2048².
2. **Thân trong game:** thay thân tạm CC0 của `protagonist_pilot.tscn` (cùng hợp đồng `body_scene` của T-220):
   - đầu ẩn với camera chính, vẫn đổ bóng và hiện trong gương;
   - camera ở giữa hai mắt;
   - tay trái cầm điện thoại Tripo; đèn pin theo điện thoại.
3. **Chuyển động:**
   - **đi lại:** trộn đứng, đi, chạy, đi khom theo tốc độ thật (2,2 / 3,6 / 1,2 m/s), chân không trượt, xoay tại chỗ, đi lùi, bước ngang;
   - **bước chân:** tiếng dép (`slipper_*`) khớp lúc bàn chân chạm đất;
   - **thao tác tay** (T-220): với tới, nhặt, mở cửa, đẩy cửa kẹt, bấm công tắc, cầm điện thoại. Động tác Tripo cho thân và đầu, IK đặt tay đúng `HandTarget`, vẫn 1 giây;
   - **giường và nấp:** leo lên giường tầng, nằm, ngồi dậy, khom nấp; giữ `View`/`Exit` của chỗ nấp (T-208);
   - **sợ, ngã, chết:** giật mình, trúng đòn, ngã chết. Camera chết hiện tại giữ nguyên trừ khi chủ dự án muốn đổi.
4. **Cảnh thử trước, bản chơi sau:**
   - ảnh 1080p và video Movie Maker từng nhóm động tác để chủ dự án duyệt;
   - duyệt xong mới đưa vào 4 chương (T-220 bước 5, cửa ban công D-130);
   - chạy lại 4 chương cần chạy bot, phải hỏi chủ dự án trước.
5. **Test** (mở rộng `test_protagonist_body.gd`):
   - đủ clip theo bảng, độ cao camera, đầu ẩn và gương;
   - chân không trượt, thao tác 1 giây ± 1 khung;
   - interactable chưa có `HandTarget` vẫn chạy.
6. **FPS:** đo phòng 407 có thân người chơi. Hỏi chủ dự án trước khi đo.
