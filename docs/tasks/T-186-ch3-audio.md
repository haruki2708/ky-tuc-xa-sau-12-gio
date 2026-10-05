# T-186 — Chương 3: tiếng xác sống, thanh sắt, thở dốc, ngoài trời, nhạc chương 3
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-186-ch3-audio`
- Phụ thuộc: T-164, T-175, T-178. **Đọc `docs/design/CH3_DESIGN.md`** (D-052, D-054).
- **Hạn đề xuất: hết ngày 2026-10-08.**

## Mục tiêu
Âm thanh cho chương ngoài trời đông xác. Chủ dự án **thích âm nhỏ**: tiếng nền khẽ, căng thẳng đến từ bước chân và tiếng lạ.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Hợp đồng có sẵn (core, không sửa). Đọc chú thích trong `event_bus.gd`, mục "Chapter 3"
- `zombie_woke`, `zombie_stunned`, `bar_picked`, `bar_swung(hit, hits_left)`, `bar_broken`, `stamina_changed(value, exhausted)`, `companion_state_changed`, `guard_warned`, `player_death_started(&"zombie_grab"|&"guard_shock")`, `scare_triggered`, `noise_emitted`.
- Lane A (T-182) cho node xác `Zombie`. Gắn rig âm thanh theo cách của T-175 (core gọi `new()` rồi gắn), ghi API vào Handoff.

## Yêu cầu
1. **Xác sống** (rig gắn vào từng xác, tối đa khoảng 40 xác; chỉ 6–8 xác gần nhất được phát âm):
   - gầm gừ khàn, thở rít khi săn, im khi ngủ;
   - bước chân lê;
   - tiếng **bầy** xa: một vòng lặp chung, to dần theo số xác đang săn;
   - tiếng đập cửa (cửa 407, 203).
2. **Thanh sắt:** vung (vút), trúng đầu (bịch nặng, không quá máu), trượt, tiếng cong kim loại khi gần gãy, tiếng gãy.
3. **Người chơi:** thở dốc theo `stamina_changed` (nặng dần, gấp khi cạn), tim đập khi cạn; bước chân chạy trên gạch, cỏ, bê tông.
4. **Môi trường ngoài trời:**
   - gió nhẹ, côn trùng tắt hẳn (thế giới chết);
   - xa xa thỉnh thoảng có tiếng hét;
   - **còi cứu hộ rất nhỏ** (manh mối động đất), chỉ nghe ở chỗ cao khán đài (`Clues/SirenSpot` của lane B), rất khẽ, dễ bỏ qua;
   - mỗi khu một nền riêng: sân vận động vang rộng, nhà ăn kín, cầu thang dội.
5. **Bảo vệ:** tiếng điện rè của dùi cui khi `guard_warned`.
6. **Nhạc chương 3** (theo kiểu `Ch2Music`):
   - nền căng khi chạy, dồn khi đợt xác tràn vào sân vận động;
   - lặng khi ở nhà ăn;
   - cuối chương một nốt dài.
7. **Cảnh chết:** `zombie_grab` (vồ, xé, cắn sát tai), `guard_shock` (điện giật, ngã). Có bản nhẹ cho "Giảm hù dọa".
8. **Âm lượng:** đo LUFS như các đợt trước; **giữ mức nhỏ**. Ghi "chưa nghe bằng tai" nếu chưa nghe.
9. **Test và cảnh nghe thử** `audio/test/ch3_audio_test.tscn`: phím cho từng nhóm âm; test giới hạn số xác phát âm, thở theo thể lực, còi chỉ ở chỗ cao.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] CREDITS ghi nguồn (tự tổng hợp hoặc CC0/CC-BY)
- [ ] Handoff: rig, API, cách nghe thử, đã nghe hay chưa

## Handoff (agent điền)
