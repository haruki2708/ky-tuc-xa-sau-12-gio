# T-224 — Quản lý chương 1: soi từng giường, đuổi theo, không đi xuyên đồ, đồ va vào thì đổ
- Lane: **integrator** (Claude làm thay A/B) | Trạng thái: **đang làm** | Agent: Claude Code ở máy (Opus 5.5)
- Quyết định: **D-134**. Chủ dự án báo lỗi sau khi chơi chương 1 (bản 22/10 21:51) và chọn cách làm.
- Liên quan:
  - [T-219](T-219-manager-character-pilot.md): quản lý Tripo, D-120;
  - [T-223](T-223-playtest-fixes-oct22.md): các lỗi khác chủ dự án báo cùng lúc;
  - D-069: luật quản lý ở phòng 407 hiện nay.

## Chủ dự án báo (22/10/2026)
> "quản lý đi lại khá là ngớ ngẩn (đi xuyên thùng rác, lỗi logic, lỗi động tác ...), hướng đi của quản lý tôi nghĩ cần được lập trình hướng đi (ví dụ khi tôi vẫn nằm trên giường thì lập trình hướng đi của quản lý kiểm tra tất cả giường trong phòng rồi mới đến giường cũ của tôi nằm rồi đập phá, thứ 2 khi tôi không nằm giường, lập trình quản lý đi theo tôi và chém, không lỗi logic đi xuyên vật thể, có thể va chạm vật thể và vật thể đấy đổ xuống như thùng rác, bàn học xê dịch ra)"

## D-134: chủ dự án chọn
- **Kiểm tra giường:** soi từng giường, cúi sát giường mình.
  - Quản lý lần lượt tới giường 1, 2, 4, mỗi giường dừng 2–3 giây.
  - Tới giường người chơi đang nằm thì cúi sát mặt lâu hơn.
  - Cuối cùng tới giường 3 (giường cũ của Trung): hỏi, cười, rồi đập phá.
  - Luật giữ nguyên: nằm im và tắt đèn là sống; ngồi dậy là chết.
- **Đồ va vào thì đổ:** thùng rác, túi rác; xô, chậu, dép, chai lọ; ghế đẩu, ghế nhựa. Bàn học không xê dịch (chủ dự án không chọn).
- **Lỗi động tác:** tay và cổ tay vặn xoắn; đổi động tác giật cục.
- **Lỗi logic:** đi xuyên thùng rác và vài đồ khác.

## Hiện trạng (trước T-224)
`game/scripts/core/chapter1_director.gd` `_manager_at_407`:
- Quản lý đi hành lang, gõ cửa, thử tay nắm, mở cửa từ từ, đứng ở ngưỡng cửa.
- Có đèn hoặc điện thoại đang giơ: giết.
- Người chơi không nằm giường: `_manager_hunts`, đi tới chỗ người chơi rồi giết.
- Người chơi nằm giường: đi tới giữa phòng (`MANAGER_SPOT`), hỏi giường 3, cười, chém giường 3, đi ra.

Vì sao đi xuyên đồ:
- Đồ Tripo trong phòng chỉ để nhìn, không có va chạm (`room407_furnish.gd`).
- Đường đi `ManagerNavigation` (`room_407.tscn`) dựng cho phòng cũ. Thùng rác (2,9; −5,4) và túi rác nằm trên lối ra ban công.

## Việc
1. **Va chạm cho đồ Tripo:**
   - đồ lớn (giường, bàn, tủ, tủ lạnh, giá, kệ...) chặn cứng;
   - đồ nhỏ D-134 thành vật lý: quản lý đi qua thì đá đổ, xê dịch.
2. **Đường đi dựng lại theo đồ mới:**
   - tránh đồ lớn;
   - đồ nhỏ không chặn đường mà bị đá đổ;
   - có test: không cạnh nào của đường đi cắt qua đồ lớn.
3. **Soi giường** theo D-134, test thứ tự và luật.
4. **Đuổi theo:** khi người chơi chạy, quản lý tính lại đường liên tục tới chỗ người chơi đang đứng, theo kịp rồi chém. Giữ cách mở cửa nhà tắm như cũ.
5. **Động tác:** sửa tay và cổ tay vặn xoắn, chuyển động tác mượt.
   - Tìm nguyên nhân trước: khung xương Tripo, chỉnh tay khi cầm đồ (`hand_grip_modifier.gd`, `arm_reach_modifier.gd`) hay chỗ ghép động tác.
   - Nếu do khung xương, soạn trang hướng dẫn ghép khung xương trong Blender cho chủ dự án (chủ dự án hỏi 22/10).
6. **Kiểm tra:** test, video hoặc ảnh cảnh quản lý soi giường và đuổi theo, đo FPS phòng 407 (thêm vật lý).
