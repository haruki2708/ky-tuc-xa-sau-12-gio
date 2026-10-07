# T-198 — Chương 4: âm thanh (chuông mồi, đập cửa, thư viện, bệnh viện, giọng y tá, nhạc kết)
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-198-ch4-audio`
- Phụ thuộc: T-186, T-194 (**hợp đồng chung**, mã jumpscare), `docs/design/CH4_DESIGN.md`, D-067. Quy tắc cũ: **âm lượng nhỏ** (chủ dự án thích yên; chưa ai nghe âm chương 3, nên giữ ngưỡng của chương 3).
- **Hạn đề xuất:** 2026-10-10.

## Việc
1. **Chuông điện thoại mồi:** nghe `EventBus.phone_decoy_thrown(at, charges_left)`: phát **chuông** (loop 6 giây, tiếng điện thoại cũ rè, vị trí 3D tại `at`, nghe được xa khoảng 30 m, nhỏ ở gần), tắt đúng sau 6 giây; tiếng **chạm sàn** lúc rơi. Hết pin (`charges_left == 0`): tiếng "bíp" yếu lúc điện thoại tắt.
2. **Đập cửa phá được:** nghe `EventBus.door_damage_changed(id, fraction)`: tiếng đập mỗi 0,7 giây tăng dần theo `fraction` (`407`, `library_back`, và cửa phòng T-190); từ 0,3 thêm **tiếng gỗ nứt**, từ 0,6 **gỗ vỡ tung**, từ 0,8 **tiếng gầm gừ** sát cửa. Khi `door_burst` (cửa vỡ) thì **tiếng nổ gỗ** lớn nhất chương (nhưng vẫn trong ngưỡng).
3. **Thư viện:** không khí yên (tiếng ù đèn, giấy, kim loại), mưa bụi xa; jumpscare `librarian_rise` (ghế kéo, tiếng thở), `books_fall` (cả dãy sách rơi), `shelf_corpse` (xác rơi từ kệ), `back_door_hit` (cửa phụ bị đập bất ngờ). Mỗi mã có tiếng riêng, ngắn.
4. **Nhà B quay về:** tiếng **cầu thang đông xác** (nhiều gầm gừ nhẹ chồng nhau, theo `StairCrowd`; dùng nhóm âm xác của T-186, nhỏ hơn sân vận động), `knife_pull` (con dao trong phòng quản lý rút ra), `stairs_turn` (cả cầu thang quay đầu: tiếng áo, gầm khẽ), `hall_lights` (đèn hành lang tầng 4 tắt lần lượt: tiếng tách, ù tắt), `door_hand` (bàn tay thò qua lỗ cửa), `neck_hand` (bàn tay máu đặt lên cổ: im lặng bất thường rồi một tiếng thở).
5. **Loa và lời ký tên:** loa cười lạnh (vòng 5, ngắn) và đọc **"Trần Trung đã đăng ký thành công. Bạn là người sống sót."** (core cung cấp key chữ `SPK_CH4_*`; **voice**: giọng loa eSpeak đã có từ T-137, file `audio_source/` theo cách chương 3: `audio_source/ch4_voice_process.py`).
6. **Cảnh kết:**
   - **tiếng cơ thể mờ dần** (xa dần, nhạc ù, nhịp tim chậm lại);
   - **bệnh viện**: máy theo dõi (bíp đều, `monitor_skip` bỏ một nhịp rồi trở lại), tiếng bước chân y tá, cửa, nhạc rất nhẹ;
   - **giọng hai y tá** (nữ, hai giọng khác nhau; lời ở `CH4_DESIGN.md` "Lời thoại chính" và key `NEAR_CH4_NURSE_*` do core thêm); **nhạc kết** ngắn (nhẹ, không hù), dùng chung khi hiện thẻ "Hết chương 4".
7. **Nhạc chương 4:** một nhạc nền khẽ cho đường ngoài trời và thư viện (căng nhưng thưa), chuyển sang **im lặng gần như hoàn toàn** ở phòng 407 chỉ còn tiếng đập cửa và hơi thở; còi cứu hộ xa **to dần** từ 8:30 tới 9:00 (từ `GameState` mốc giờ hoặc `EventBus` giờ; lane E chọn).
8. **Test** (`game/tests/audio/`): mỗi mã jumpscare và tín hiệu ở trên phát đúng bus, đúng âm lượng trần, không phát trùng; chuông tự tắt sau 6 giây; không rò rỉ player âm khi đổi cảnh.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`, card này (Handoff). Ghi nguồn asset vào `CREDITS.md` của lane (CC0/CC-BY; âm tạo bằng công cụ thì ghi rõ).

## Checklist hoàn thành
- [ ] Chuông mồi 3D 6 giây, hết pin báo hiệu
- [ ] Đập cửa theo `door_damage_changed`, nứt, vỡ, gầm
- [ ] 10 mã jumpscare của chương 4 có tiếng
- [ ] Giọng loa ký tên, giọng 2 y tá, nhạc kết, máy theo dõi
- [ ] Nhạc chương 4, còi cứu hộ to dần, im ở phòng 407
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Handoff: bảng âm và âm lượng, **nhờ chủ dự án nghe**

## Handoff (agent điền)

## Review (integrator)
