# T-170 — Chương 2: kịch bản, kho từ nối, luồng 2 vòng, ghép
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude
- Phụ thuộc: `docs/design/CH2_DESIGN.md` (D-046, D-047)
- **Hạn:** kịch bản 2026-10-06; ghép 2026-10-08; **bản chơi thử 2026-10-09**.

## Việc
- **Hợp đồng chung (xong):** EventBus `chain_turn_started`, `chain_word_spoken`, `chain_choice_requested`, `chain_choice_made`, `chain_choice_blocked`, `corpse_state_changed`, `shower_choice_requested`, `shower_choice_made`, `shower_slot_finished`, `shower_steam_changed`; `player_death_started` thêm kind `corpse_lunge`, `scald`.
- **Kịch bản:** `docs/design/ch2/build_ch2_script.py` sinh `strings.csv` (tiền tố `*_CH2_`, `WORD_CH2_*`), tin nhắn, `docs/design/CH2_SCRIPT.md`; giọng eSpeak cho câu mới và cho mọi từ nối.
- **Kho từ nối:** 150–250 từ hai tiếng; đồ thị nối; từ láy cụt (bẫy); vòng 8 từ về chữ "học"; bộ sinh 4 phương án (1 đúng, 3 bẫy); kiểm tra tự động không có từ nào làm người chơi bí khi chọn đúng.
- **Dãy nhiệt độ:** 30 lượt của Trung và dãy của Ngư (cùng quy luật), kiểm tra tự động.
- **Luồng** `chapter2_director.gd` và `scenes/main/chapter2.tscn`: mở đầu 6:00, vòng 3 (N1–N5), vòng 4 (N6–N10), kết 8:00, checkpoint `ch2_r3`, `ch2_r4`, cắt thời gian trống, chọn chương 2 ở màn tiêu đề.
- **Ghép** T-171…T-175; bot; xuất bản build chơi thử.

## Handoff
### Phiên 2026-10-05 (Claude): kịch bản, kho từ, luồng 2 vòng
- **Kịch bản** `docs/design/ch2/build_ch2_script.py` sinh `CH2_SCRIPT.md`, 350 chuỗi, 25 tin nhắn, `data/rules/ch2.tres`. Chờ chủ dự án duyệt lời.
- **Kho từ** `docs/design/ch2/word_bank.py`:
  - 266 từ, 7 từ cụt, 21 từ bẫy;
  - tự kiểm tra: mọi từ (trừ từ cụt) đều nối tiếp được và lái được vào vòng lặp, xa nhất 17 lượt;
  - xuất `data/ch2/word_bank.json` (từ, vòng lặp, mở đầu, bảng lái `steer`).
- **Nhiệt độ** `data/ch2/shower.json`: dãy 30 lượt và dãy của Ngư, kiểm tra đúng quy luật và còn đúng một lượt dư.
- **Giọng:** `audio_source/ch2_voice_process.py`, 320 file (loa, Minh Nhật, Ngư, 287 từ cho xác, giọng trung tính để lane E làm méo).
- **Luồng** `scripts/core/chapter2_director.gd`, `class Chapter2Director extends Chapter1Director`:
  - director chương 1 được tách các phần riêng của chương thành hàm ảo: `_stages`, `_run_stage`, `_checkpoints`, `_death_checkpoints`, `_death_kinds`, `_chapter`, tiền tố tin nhắn;
  - vòng 3: lượt theo chiều kim đồng hồ; xác nói, ú ớ khi bị bịt, bí ở từ cụt thì gục 10 giây rồi bắt đầu chuỗi mới; lượt của Trung có 4 phương án và 15 giây, chỉ trả lời được trong `Zones/Bedroom`; `gag(bed)`; vòng lặp đi trọn thì kết vòng sớm;
  - vòng 4: 30 lượt; cứu Ngư ở lượt 20; đủ 25 phút thì kết sớm;
  - cảnh chết `corpse_lunge`, `scald`;
  - ghép sẵn theo tên: `carry_item.tscn`, `gag_spot.tscn` (A), anchor `RagSpot`, `TowelSpot`, `ShirtSpot`, `Gag1/2/4`, `Zones/Bedroom`, `Room407.set_water`, `set_steam`, `Room310` (B).
- **Scene** `scenes/main/chapter2.tscn` (chung `chapter1_main.gd`); `App.start_game(continue, chapter)` mở đúng scene; "Tiếp tục" theo tiền tố checkpoint `ch2_`.
- **Test:** `test_chapter2.gd` 10 test (dữ liệu, phương án luôn có từ đúng, sai dấu, lặp, im lặng, từ sai, bịt miệng và vòng lặp, tắm theo quy luật tới hết chương, bỏng, bước ra, khuyên sai Ngư). Toàn bộ 424/424.
- **Chưa làm:** ghép thật với T-171…T-175 khi các lane giao; cửa nhà vệ sinh kẹt (chờ A); camera phòng 310 (chờ B); nút nhảy giữa vòng cho menu F9.

