# T-160 — Chương 1 bản 2: luồng 8 nhiệm vụ, Insane, cắt thời gian trống, ghép
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude
- Phụ thuộc: `docs/design/CH1_V2_MISSIONS.md` (D-039, D-040)
- **Hạn: bản chơi thử 2026-10-07.**

## Việc
- **Hợp đồng chung (xong):** `phone_call_lost`, `phone_call_restored`, `wall_tapped`; `PuzzleData.max_attempts`, `lockout_seconds`.
- **Dữ liệu và lời thoại:**
  - sổ Đạt mới, thẻ Phúc, ảnh đội bóng, bảng mã gõ, 3 mảnh biên bản và biên bản ghép;
  - lời thoại mới: mất mạng, Kiệt/Đăng để lộ dấu vết, Khoa (tiếng gõ), 4 lựa chọn cứu Minh Nhật;
  - 3 lý do chết mới;
  - giọng cho câu mới (pipeline T-159).
- **Luồng:**
  - Insane: checkpoint đầu vòng, nín thở 6 giây, bỏ suy nghĩ gợi ý, quản lý nghe cử động;
  - giải mã tiếng gõ;
  - mất mạng 4:28 và tự nối lại lúc 4:48;
  - giữ cửa 10 giây;
  - ghép biên bản;
  - kiểm tra dấu vết khi quản lý mở cửa;
  - cứu Minh Nhật;
  - cắt thời gian trống khi xong nhiệm vụ.
- **Ghép** T-161…T-164; bot (cập nhật kịch bản C); xuất bản build chơi thử.

## Handoff
### Phiên 2026-10-05 (Claude): luồng bản 2 xong phía core, chờ hàng của các lane
- **Kịch bản và dữ liệu** (D-043 tạm duyệt): sổ Đạt mới, mã `2109` (sai 3 lần thì kẹt 60 giây, không có gợi ý), thẻ Phúc, thẻ Việt, ảnh đội bóng, bảng mã gõ, 3 mảnh biên bản và bản ghép, lời thoại mới, 3 lý do chết mới, giọng cho câu mới.
- **Luồng (`chapter1_director.gd`):**
  - **Insane:** checkpoint chỉ ở đầu vòng (chết trong cảnh quản lý thì về `ch1_r2`); nín thở tối đa 6 giây (`Player.max_breath_seconds`); bỏ suy nghĩ gợi ý; quản lý nghe cử động (`hear_movement_while_present`).
  - **D-040:** `_gap()` cắt chờ khi xong hết nhiệm vụ của vòng.
  - **N1:** cục sạc.
  - **N2:** `phone_call_lost`, ổ điện (công tắc 3 chập, chờ 20 giây; công tắc 2 khởi động cục phát 8 giây), dây xanh; quá 150 giây thì nối lại từ xa; câu nói trong lúc mất mạng thì bỏ.
  - **N3:** mã gõ (`encode_taps`/`decode_taps`), "CON SONG", trả lời "CO", rồi "SO GIUONG".
  - **N4:** 10 giây chốt cửa, không kịp thì chết `DEATH_DRAGGED_OUT`.
  - **N5:** đủ 3 mảnh thì tự mở biên bản ghép.
  - **N6:** đèn bàn, điện thoại giơ hoặc đèn pin bật lúc cửa mở thì chết `DEATH_SEEN`.
  - **N7:** 10 giây, chọn sai thì chết `DEATH_LOST_NHAT`.
  - **Camera an ninh:** `CctvFeed` (SubViewport, group `cctv_feed`), `cctv_unlocked`, `cctv_focus_requested`, dàn cảnh 4 vụ giết (`_cctv_scene`, `_cctv_kill`).
  - **Cảnh chết:** `player_death_started(kind)` trước `player_failed`.
- **Test:** `test_chapter1.gd` 21 test (thêm: mã gõ, giữ cửa trễ, khuyên sai, đèn bàn, sửa mạng, ghép biên bản, cắt thời gian trống). Toàn bộ 362/362 PASS.
- **Điểm ghép đang chờ:**
  - **A:** `search_spot.tscn` (`spot_id`, `prompt_key`, `document_id`, signal `searched`), `wall_knock.tscn` (`wall_id`), `power_strip.gd` (`switch_toggled`, `trip`, `set_locked`), `lan_cable.gd` (`plugged`, `unplugged`, `unplug`), chốt cửa (`set_locked` nếu có), `max_breath_seconds`, `death_animation_finished`, cờ `desk_lamp_on`.
  - **B:** `Room407/Bounds`, `Anchors/PowerStrip` (`spark`), `Router/Model` (`set_power`, `set_network`), `VietLocker.set_open`, `PhucMattress.set_lifted`, `TrashBin`, `Door407.rattle/stop_rattle`, `PhucCard`, `TeamPhoto`, `GuitarSongbook`, `cctv_set.tscn` (phòng có số, `Cam`, `Door`, `VictimBed`, `ManagerSpot`), `student_*.tscn` (`set_pose`).
  - **E:** group `wall_taps` (`play_tap(position)`); các âm `door_rattle`, `router_off`, `router_boot`, `strip_spark`, `kiet_ringtone` (core tìm trong `res://audio/sfx/`; chỉnh đường dẫn khi ghép).
  - **D:** tab Camera đọc `cctv_feed`; mất kết nối.

