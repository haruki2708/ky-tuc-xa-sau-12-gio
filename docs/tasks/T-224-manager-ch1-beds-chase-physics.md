# T-224 — Quản lý chương 1: soi từng giường, đuổi theo, không đi xuyên đồ, đồ va vào thì đổ
- Lane: **integrator** (Claude làm thay A/B) | Trạng thái: **xong (23/10/2026), chờ chủ dự án chơi bản build mới** | Agent: Claude Code ở máy (Opus 5.5)
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

## Đã làm (23/10/2026, Claude làm thay A/B)
1. **Đồ nhỏ thành vật lý** (`game/scenes/levels/room407/room407_obstacles.gd` `make_dynamic`):
   - 16 món theo D-134 thành `RigidBody3D` trên lớp vật lý 5 "props" (`DormManager.PROPS_LAYER`), có khối lượng riêng (thùng rác 1 kg, túi rác 2 kg, ghế đẩu 1,2 kg...);
   - lúc vào chương chúng nằm yên (ngủ);
   - khối va chạm cũ của ghế đẩu tắt đi;
   - người chơi vẫn đi xuyên được như trước, chỉ quản lý đá chúng.
2. **Quản lý đá đồ** (`manager.gd` `_kick_props`): một vùng quanh chân, đồ nào chạm khi ông ta đang đi thì bị đẩy chếch sang bên và hơi lên trên, nên đồ cao đổ, đồ thấp trượt. Thử đuổi ra ban công: thùng rác đổ hẳn và lăn ra ban công, ghế đẩu văng sang bên khoảng 1 m.
3. **Đường đi dựng lại khi nạp phòng** (`bake_navigation`, khoảng 10 ms):
   - sàn: mặt trên các khối sàn thật của phòng, sàn hành lang trước cửa, ngưỡng cửa;
   - vật cản: mọi khối va chạm khác trong phòng (trừ cánh cửa nhà tắm vì quản lý mở nó), tường hành lang hai bên cửa, cánh cửa phòng lúc mở, và chân mọi đồ Tripo lớn;
   - đồ nhỏ D-134 không chặn đường mà bị đá;
   - cách đồ Tripo 0,35 m (thân quản lý 0,3 m), cách khối va chạm thật 0,39 m (test thân 0,35 m của T-203 vẫn đạt), cách cánh cửa ban công 0,41 m;
   - đồ treo cao từ 0,5 m trở lên không chặn (vòi sen: chương 2 người chơi đứng dưới đó);
   - ô lưới 5 cm, bước cao 1 cm (mặt đường sát sàn);
   - ảnh nhìn từ trên: `art_source/graphics_upgrade/manager/previews/t224_nav.png`;
   - `NavigationAgent3D` `path_desired_distance` 0,25 m (ngưỡng cũ 5 cm làm ông ta đứng im khi mặt đường lệch chân vài cm).
4. **Soi từng giường** (`chapter1_director.gd` `_check_bed`, `BED_CHECK_SPOTS`, `BED_LEAN`):
   - dãy giường A: giường 1 rồi 2; dãy B: giường 4; đứng phía đầu giường, nhìn về gối;
   - nhìn mỗi giường 2,5 s, cúi 10° (giường trên) hoặc 30° (giường dưới);
   - giường người chơi đang nằm: cúi 25° hoặc 55° (sát mặt) trong 5 s;
   - xong tới giường 3: hỏi, cười, chém như cũ; ngồi dậy lúc nào cũng bị giết ngay.
   - Thân quản lý có `Lean` (`SpineBendModifier`) và `manager.gd` `lean()`, `face()`, tín hiệu `leaned`.
5. **Động tác:**
   - **Cổ tay phải** (`BoneLockModifier` `RightWristLock`, `scripts/entity/bone_lock_modifier.gd`): các động tác Tripo xoay cổ tay như tay không, nên dao lật ngược lên xuống và cổ tay trông vặn xoắn. Giờ cổ tay giữ đúng tư thế cầm dao của động tác `stand`, dao luôn đi theo cẳng tay. Ảnh: `previews/t224_lean_wrist.jpg`.
   - **Quay người** từ từ, 6 rad/s (lúc lao tới chém nhanh gấp 2,5), không còn xoay phắt mỗi lần đổi hướng.
   - **Mở cửa:** không dừng động tác nữa, chuyển sang đứng rồi với tay (thân Tripo).
   - **Chém:** động tác chém lặp liền, mỗi nhát không còn giật về đầu; chuyển động tác 0,3 s (trước 0,2 s).
   - Không phải lỗi khung xương, nên chưa cần ghép lại khung xương trong Blender.
6. **Video:** `build/graphics/manager/t224_soi_giuong.mp4` (người chơi nằm giường 2), `t224_ban_cong.mp4` (người chơi trốn ngoài ban công). Có thêm một đèn mờ cho dễ nhìn; trong game phòng tối hẳn. Ảnh: `previews/t224_beds.jpg`.
7. **Test:**
   - `test_room407_obstacles.gd`: đồ vật lý đúng lớp và khối lượng; tới được dãy giường A, B, ban công, nhà tắm từ hành lang; đường đi không nằm trên đồ lớn nào; đi vào thùng thì thùng đổ hoặc văng mà ông ta vẫn đi tiếp;
   - `test_chapter1_d069.gd` `test_he_checks_beds_1_2_4_then_cuts_3`;
   - quay người từ từ; dao giữ nguyên trong tay theo cẳng tay qua `walk` và `slash`;
   - sửa test cũ theo cách mới (chém lặp, quay từ từ, đồ vật lý trong `Furnished`);
   - cả bộ 843/843, `check.ps1` 0 lỗi.

**FPS** (23/10, chủ dự án: "đo fps"; [báo cáo mục 5](../../tools/reports/D-131-room407-t222-performance.md)): 1080p có quản lý đứng trong phòng thấp nhất 79,9 FPS (đèn trần), vẫn trên 60; quản lý tốn thêm 0,4–1,5 ms khi thấy ông ta, nhiều hơn với đèn trần và trong gương.

**Chưa làm:** người chơi chưa đẩy đồ (đi xuyên như trước).
