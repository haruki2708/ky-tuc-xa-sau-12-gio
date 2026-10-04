# T-164 — Chương 1 bản 2: âm thanh nhiệm vụ mới
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-164-ch1v2-audio`
- Phụ thuộc: T-158. **Đọc `docs/design/CH1_V2_MISSIONS.md`** (D-039). Chủ dự án thích âm **nhỏ**; ghi LUFS.
- **Hạn: hết ngày 2026-10-06.**

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`

## Yêu cầu
1. **Gõ tường** (`wall_tap`): tiếng gõ khớp ngón tay lên tường vôi dày, 2–3 biến thể. API cho integrator phát một chuỗi gõ ở một vị trí 3D, ví dụ `WallTaps.play_sequence(position, groups: Array[int], gap_digit, gap_letter)`, với `groups` là số lần gõ của từng con số, kèm signal `sequence_finished`. Phía bên kia tường thì lọc trầm hơn.
2. **Cục phát wifi:** tiếng tắt nguồn; tiếng bíp khởi động; tiếng bíp báo có mạng.
3. **Ổ điện:** tiếng bật công tắc; **tiếng chập và tóe lửa** khi bật công tắc 3.
4. **Tay nắm cửa bị vặn mạnh:** vòng lặp tay nắm kim loại lạch cạch, bản lề rung; có phần kết thúc khi dừng.
5. **Khóa số kẹt:** chuông báo động ngắn, chói, nhưng vẫn trong mức đã duyệt (tham chiếu −30 LUFS).
6. **Chuông điện thoại của Kiệt nghe qua cuộc gọi** (một đoạn chuông khác chuông của Trung).
7. **Mất kết nối:** dùng lại `call_disconnect` của T-158; thêm tiếng nối lại.
8. **Cảnh chết (D-042):** nghe `EventBus.player_death_started(kind)`.
   - `fall_back`: máu phụt, thở hắt nghẹn, thân người đập xuống sàn gạch.
   - `bed_burst`: máu trào, co giật trên giường sắt.
   - `manager_kill`: dùng `manager_kill` của T-158 (đừng phát trùng nếu `Ch1PlayerAudio` đã phát), thêm tiếng thịt bị chém sát tai.
   - "Giảm hù dọa": nhẹ và ít chi tiết hơn.
9. **Camera an ninh:** tiếng rè nền rất khẽ khi xem tab Camera; tiếng nhiễu chuyển kênh. Cảnh giết trên camera nghe qua cuộc gọi (đã có), không cần thêm âm cho từng cảnh.
10. Ghi `CREDITS.md`, LUFS từng âm; cảnh thử nghe từng âm.
11. **Test:** đủ file, đúng bus, API chuỗi gõ đúng số nhịp và thứ tự.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: danh sách âm, LUFS, API

## Handoff (agent điền)
