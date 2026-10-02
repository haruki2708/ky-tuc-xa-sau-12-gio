# Backlog P1 (prototype greybox)

Mỗi việc sẽ được tách thành task card chi tiết khi đến lượt. Thứ tự ưu tiên từ trên xuống.

| ID | Việc | Lane | Phụ thuộc |
|---|---|---|---|
| T-110 | **Xong.** Kiến trúc lõi: `GameState`, `RuleSystem`, `Checkpoint` (`T-110-rule-system.md`, thiết kế `docs/design/RULE_SYSTEM.md`) | core (Claude) | P0 |
| T-113 | **Xong (D-020).** Bộ luật, câu chữ, cốt truyện, sơ đồ tầng → `docs/design/RULES.md`, `LAYOUT.md`, dữ liệu `game/data/rules/demo.tres` | Chủ dự án + Claude | — |
| T-111 | Màn xem giấy cận cảnh và sổ tay theo nguồn (`T-111-document-view-notebook.md`) | **D** | T-128, T-110 |
| T-112 | Dựng greybox tầng 4 theo `LAYOUT.md` (`T-112-floor4-greybox.md`); làm trước T-118 | B | T-102, T-121, T-113 |
| T-114 | Sửa tiếng ù đèn tuýp; vùng âm môi trường, vùng reverb; đèn tắt thì im tiếng (`T-114-audio-zones.md`). Bước chân đã được integrator nối ở `main.tscn` | E | T-101, T-105 |
| T-115 | Kịch bản chơi tự động "từ đầu đến luật số 1", chạy được trong CI hoặc trên máy | C | T-103, T-117 |
| T-116 | Menu tạm dừng và cài đặt, script `Settings` (`T-116-pause-settings.md`, hợp đồng `docs/SETTINGS.md`) | D | T-104, T-105; merge trước T-125 |
| T-117 | **Luật đầu tiên chạy trọn vòng** (đoạn 1–2, `T-117-first-rule-loop.md`) | core | T-129, T-111, T-130 |
| T-118 | (`T-118-ps1-filter.md`) Filter PS1: render độ phân giải thấp, dithering, rung đỉnh nhẹ; trừ phần UI và giấy tờ. Kèm sửa import texture kit: `detect_3d/compress_to=0` để editor không tự nén và bật mipmap | B | T-102 |
| T-121 | Cập nhật bộ kit: ghế nhựa kiểu Việt Nam, mùng, collision, bỏ texture trùng (`T-121-kit-update.md`) | B | T-102 |
| T-122 | Nhịp bước chân tự nhiên theo tốc độ, signal `footstep(surface, intensity)`; dọn việc tồn T-101 (`T-122-natural-footsteps.md`) | A | T-101; merge sau T-123 |
| T-123 | Âm dép lê mềm hơn, bank đi/chạy, `play_footstep(surface, intensity)` (`T-123-softer-footsteps-audio.md`) | E | T-114 |
| T-124 | Dọn công cụ QA, lọc file khi xuất bản build (`T-124-qa-followups.md`) | C | T-103 |
| T-125 | Player làm theo menu tạm dừng và đọc cài đặt (`T-125-player-settings.md`) | A | T-122; merge sau T-116 |
| T-126 | Bus `Footsteps` riêng cho bước chân (`T-126-footsteps-bus.md`) | E | T-123 |
| T-127 | Công cụ QA thoát qua `App.quit()`; package và verify-capture PASS (`T-127-qa-clean-quit.md`) | C | T-124 |
| T-128 | Nút Thoát qua `App.quit()`; key dịch biển tầng 4 (`T-128-menu-quit-signs.md`) | D | T-116, T-112 |
| T-129 | Đồ vật tương tác đoạn 1–2: công tắc, chốt cửa, giấy đọc được, điện thoại (`T-129-segment12-interactables.md`) | A | T-125, T-110 |
| T-130 | Âm thanh đoạn 1–2: gõ cửa, loa, điện thoại, công tắc, chốt (`T-130-segment12-sounds.md`) | E | T-126 |
| T-131 | Âm hù dọa và truy đuổi (`T-131-scare-sounds.md`, D-024) | E | T-130 |
| T-132 | Tùy chọn "Giảm hù dọa" (`T-132-reduce-scares-setting.md`) | D | T-116 |
| T-133 | **Nhạc nền / drone** cho các khoảnh khắc căng thẳng (đèn tắt, sau khi làm sai, truy đuổi), bus `Music`, có lớp im lặng (D-025) | E | T-131 |
| T-134 | Thực thể truy đuổi và phát hiện ánh nhìn (`T-134-pursuer-gaze.md`) | A | T-131, T-132 |
| T-135 | Bóng người và gương phản chiếu chậm (`T-135-silhouette-mirror.md`) | B | T-112, T-118 |
| T-136 | **Đoạn 3–5 và cái kết** (`T-136-segments-3-5.md`) | core | T-117, T-134, T-135 |
| T-120 | **Cổng kiểm tra P1:** chủ dự án chơi bản v0.1 và đánh giá theo `docs/design/GDD.md` | Chủ dự án | Tất cả ở trên |
