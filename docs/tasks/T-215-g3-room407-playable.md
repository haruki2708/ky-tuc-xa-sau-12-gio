# T-215 — G3: đưa phòng 407 đủ đồ vào bản chơi
- Lane: integrator (Claude làm thay phần B/A/D: tích hợp hình, gắn phần động, đổi mặc định bộ lọc) | Trạng thái: doing (bước 1 xong, D-103) | Agent: Claude Code (Opus 5.5)
- Phụ thuộc: D-096…D-101 (phòng đủ đồ ở cảnh thử), **D-102** (chủ dự án duyệt; tắt bộ lọc PS1 mặc định khi G3 vào bản chơi).

## Mục tiêu
Phòng 407 trong cả 4 chương trông như cảnh thử `room407_furnished_pilot.tscn` mà **không đổi luật, cốt truyện, độ khó**: va chạm, chỗ nằm (View/Exit), xác, giấy đọc, câu đố (ổ điện, khóa số, router, ổ cắm Khoa), hiệu ứng chương 2 (vòi sen, hơi nước, gương), máu/vết rạch chương 3–4 giữ nguyên hành vi.

## Cách làm
1. **Dữ liệu dùng chung:** `placements.json`, `decals.json` chuyển vào `game/data/room407/` (bản xuất game đọc được); cảnh thử và bản chơi dựng phòng bằng cùng một hàm (`scenes/levels/room407/room407_furnish.gd`).
2. **Bản chơi:** `room407.gd` dựng phòng mới trong `_ready`; ẩn mesh PS1 cũ (giữ nguyên node, va chạm, vị trí). Giữ lại hình cũ của đồ có trạng thái cốt truyện/câu đố (Anchors, máu, vết rạch, cáp, hiệu ứng nhà tắm) trừ phần đã có bản Tripo.
3. **Phần động gắn vào node cũ:** mùng theo `BunkA/Net_*`, `BunkB/Net_*` (rung, ẩn khi lật ván ch4); cánh tủ Việt vào `Anchors/VietLocker/Pivot` (`hinged.gd`); nệm/chăn/gối Phúc vào `Anchors/PhucMattress/Pivot`; cánh cửa nhà tắm theo `Extension/BathroomDoor`; cánh quạt `fan_rotor` quay như cũ; đèn tuýp sáng theo `Room407MainLight`.
4. **Tường cửa:** tường hành lang trong bản chơi dày tới z = −0,1 (cảnh thử đặt mặt tường ở z = 0): mảng tường trước, đồ treo và decal trên tường đó dời −0,105 m trong bản chơi (cách mặt tường hành lang 5 mm, không nhấp nháy).
5. **Bộ lọc PS1:** mặc định `[video] ps1_strength` = 0 (D-102), vẫn chỉnh được trong Cài đặt.
6. **Kiểm:** test node/va chạm/phần động; ảnh chụp trong cảnh chương (Forward+); hồi quy 4 chương; xuất bản build. Chạy bot/FPS phải hỏi chủ dự án trước.

## Còn lại sau mốc này
Gương phản chiếu thật, dây điện/giấy manh mối polish. (Cánh cửa phòng 407 đã treo lên `Door407` ở bước 1.)

## Tiến độ
- **Bước 1 (D-103):** xong mục 1–5; test `game/tests/levels/test_room407_playable_furnished.gd` (va chạm/đường đi không đổi, mesh PS1 ẩn đúng danh sách, phần động, tường cửa, đèn tuýp, gương chương 2, cửa 407). Test đường đi `test_room407_fixes.gd` chờ bản đồ điều hướng đồng bộ (tầng nặng hơn cần quá 2 khung vật lý). Ảnh `art_source/graphics_upgrade/room407_furnished/previews/g3/` (30 ảnh, chụp bằng `room407_g3_capture.tscn -- --g3-capture`).- **Giới hạn đã biết:** xác, vết rạch, máu vẫn là hình PS1 (thay ở đợt nhân vật G4); hành lang vẫn PS1 nên cửa 407 nhìn từ hành lang khác phần tường quanh; đèn chính mặc định energy 0 (T-153) nên đèn tuýp chỉ sáng khi đèn chính thật sự phát sáng (nhấp nháy).
- **Tiếp:** chủ dự án chơi thử 4 chương; gương phản chiếu thật; xuất bản build; đo FPS khi được phép.
