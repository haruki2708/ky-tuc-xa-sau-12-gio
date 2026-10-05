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
