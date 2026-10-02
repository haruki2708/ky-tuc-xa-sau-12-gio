# T-110 — Lõi luật chơi: GameState, RuleSystem, Checkpoint
- Lane: core (Claude) | Trạng thái: done | Agent: Claude (integrator)
- Nhánh: `core/T-110-rule-system`
- Phụ thuộc: P0

## Mục tiêu
Có nền dữ liệu và logic cho cơ chế "nội quy có bản bị sửa" (D-002): giờ trong game, đoạn chơi, mức "lệch", luật thật và giả, phán định, hậu quả, sổ tay đã đọc và nghi ngờ, checkpoint. Chưa có nội dung luật thật; nội dung được chốt ở T-113.

## Handoff
### Phiên 2026-10-02 — Claude
**Đã làm**
- `game/scripts/core/rule_data.gd` (`RuleData`), `rule_set.gd` (`RuleSet` kèm `validate()`).
- Autoload `GameState` (`game_state.gd`): giờ (mặc định 23:50, giờ chỉ chạy theo cốt truyện hoặc chạy thực khi `minutes_per_second > 0`), đoạn chơi, mức "lệch" 0–5, cờ (bool/int/float/String), `to_dict`/`from_dict`.
- Autoload `RuleSystem` (`rule_system.gd`): nạp bộ luật (dữ liệu lỗi thì trả lỗi về và giữ bộ cũ), `resolve()` theo bảng trong `docs/design/RULE_SYSTEM.md`, đã đọc theo thứ tự, nghi ngờ, kết quả từng tình huống, `to_dict`/`from_dict`.
- `Checkpoint` (`checkpoint.gd`): lưu và tải JSON có `version`, giữ đúng kiểu của cờ (int vẫn là int sau khi tải).
- `EventBus`: 11 signal mới cho trạng thái, luật và checkpoint.
- `project.godot`: autoload `GameState`, `RuleSystem` sau `EventBus`.
- Dữ liệu sai do người viết (luật lỗi, file lưu hỏng) chỉ báo `push_warning` hoặc trả lỗi về, không `push_error`, để `test.ps1` không coi là lỗi engine.
- Tài liệu cho các lane: `docs/design/RULE_SYSTEM.md`.

**Kiểm tra**
- `tests/core/test_rule_system.gd`: 13 test, gồm validate, phán định đủ 5 trường hợp, luật gây thua, mức "lệch" bị kẹp, sổ tay, giờ, cờ, checkpoint khứ hồi, file lưu thiếu hoặc hỏng.
- `pwsh tools/test.ps1`: `RESULT: 83 passed, 0 failed`. `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`.

**Còn lại (task khác)**
- T-113: chốt bộ luật, sau đó viết `game/data/rules/demo.tres` và các key `RULE_*`.
- T-117: luồng game nạp bộ luật, nghe `player_failed` rồi tải lại checkpoint, đặt người chơi theo `checkpoint_loaded`.
- T-111 (lane A): sổ tay dùng `read_rules()` và `set_suspected()`.
