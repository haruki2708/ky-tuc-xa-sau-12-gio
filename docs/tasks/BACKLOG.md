# Backlog P1 (prototype greybox)

Mỗi việc sẽ được tách thành task card chi tiết khi đến lượt. Thứ tự ưu tiên từ trên xuống.

| ID | Việc | Lane | Phụ thuộc |
|---|---|---|---|
| T-110 | **Xong.** Kiến trúc lõi: `GameState`, `RuleSystem`, `Checkpoint` (`T-110-rule-system.md`, thiết kế `docs/design/RULE_SYSTEM.md`) | core (Claude) | P0 |
| T-113 | **Chốt bộ luật demo, câu chữ nội quy, sơ đồ tầng** (cùng chủ dự án) → `docs/design/RULES.md`, `docs/design/LAYOUT.md` | Chủ dự án + Claude | — |
| T-111 | Xem giấy tờ cận cảnh (chữ sắc nét, lấy từ file dịch) và sổ tay (các luật đã đọc, đánh dấu nghi ngờ) | A | T-101, T-104, T-110 |
| T-112 | Dựng greybox tầng ký túc xá theo `LAYOUT.md`, mỗi phòng là một scene con, dùng bộ module của T-102. Mọi sàn phải có metadata `surface` (xem Review T-105) | B | T-102, T-113 |
| T-114 | Sửa tiếng ù đèn tuýp; vùng âm môi trường, vùng reverb; đèn tắt thì im tiếng (`T-114-audio-zones.md`). Bước chân đã được integrator nối ở `main.tscn` | E | T-101, T-105 |
| T-115 | Kịch bản chơi tự động "từ đầu đến luật số 1", chạy được trong CI hoặc trên máy | C | T-103, T-117 |
| T-116 | Menu tạm dừng và cài đặt, script `Settings` (`T-116-pause-settings.md`, hợp đồng `docs/SETTINGS.md`) | D | T-104, T-105; merge trước T-125 |
| T-117 | **Luật đầu tiên chạy trọn vòng:** loa đọc luật → tình huống → người chơi chọn → hậu quả | core + A | T-110, T-111 |
| T-118 | (`T-118-ps1-filter.md`) Filter PS1: render độ phân giải thấp, dithering, rung đỉnh nhẹ; trừ phần UI và giấy tờ. Kèm sửa import texture kit: `detect_3d/compress_to=0` để editor không tự nén và bật mipmap | B | T-102 |
| T-121 | Cập nhật bộ kit: ghế nhựa kiểu Việt Nam, mùng, collision, bỏ texture trùng (`T-121-kit-update.md`) | B | T-102 |
| T-122 | Nhịp bước chân tự nhiên theo tốc độ, signal `footstep(surface, intensity)`; dọn việc tồn T-101 (`T-122-natural-footsteps.md`) | A | T-101; merge sau T-123 |
| T-123 | Âm dép lê mềm hơn, bank đi/chạy, `play_footstep(surface, intensity)` (`T-123-softer-footsteps-audio.md`) | E | T-114 |
| T-124 | Dọn công cụ QA, lọc file khi xuất bản build (`T-124-qa-followups.md`) | C | T-103 |
| T-125 | Player làm theo menu tạm dừng và đọc cài đặt (`T-125-player-settings.md`) | A | T-122; merge sau T-116 |
| T-126 | Bus `Footsteps` riêng cho bước chân (`T-126-footsteps-bus.md`) | E | T-123 |
| T-120 | **Cổng kiểm tra P1:** chủ dự án chơi bản v0.1 và đánh giá theo `docs/design/GDD.md` | Chủ dự án | Tất cả ở trên |
