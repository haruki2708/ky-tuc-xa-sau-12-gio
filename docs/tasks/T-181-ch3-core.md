# T-181 — Chương 3: hợp đồng chung, kịch bản, luồng 4 khu, ghép (core)
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude
- Phụ thuộc: `docs/design/CH3_DESIGN.md` (D-052, D-053, D-054).
- **Hạn đề xuất:** kịch bản 2026-10-07; ghép 2026-10-09; bản chơi thử khoảng 2026-10-10.

## Việc
- **Hợp đồng chung (xong 2026-10-06):** EventBus mục "Chapter 3" (`zombie_woke`, `zombie_stunned`, `bar_picked`, `bar_swung`, `bar_broken`, `stamina_changed`, `companion_state_changed`, `guard_warned`); dùng lại `noise_emitted`, `player_caught(&"zombie"|&"guard")`, `player_death_started(&"zombie_grab"|&"guard_shock")`. Tên scene, node, anchor ghi trong các card T-182…T-186.
- **Kịch bản** `docs/design/ch3/build_ch3_script.py`: lời loa vòng 5, chat (Minh Nhật, Ngư), lời nói trực tiếp của đồng đội, suy nghĩ của Trung, lý do chết `DEATH_CH3_*`, giấy tờ (sổ trực, biển báo), sổ quy tắc `data/rules/ch3.tres`, `CH3_SCRIPT.md`; giọng eSpeak.
- **Luồng** `scripts/core/chapter3_director.gd` (kế thừa `Chapter1Director` như chương 2) và `scenes/main/chapter3.tscn` (Floor4 + Campus + UI):
  - 4 khu, checkpoint `ch3_b`, `ch3_garden`, `ch3_stadium`, `ch3_gate`;
  - đợt xác theo khu và theo giờ, giới hạn số xác hoạt động;
  - dẫn đồng đội theo đường của lane B;
  - cắt thời gian trống; kết chương mở khóa chương 4.
- **Ghép** T-182…T-186, test, export.

## Handoff
