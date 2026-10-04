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
