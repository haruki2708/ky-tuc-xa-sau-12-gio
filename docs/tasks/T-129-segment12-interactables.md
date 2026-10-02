# T-129 — Đồ vật tương tác cho đoạn 1–2
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-129-segment12-interactables`
- Phụ thuộc: T-125 (done), T-110 (done). Đọc `docs/design/RULES.md` mục 5 (đoạn 1–2) và `docs/design/RULE_SYSTEM.md` mục "Giấy tờ".
- Làm song song với T-111 (lane D) và T-130 (lane E). Integrator ghép tất cả ở T-117.
- Lane A được thêm thư mục `game/scenes/interaction/` (xem `AGENTS.md` §3).

## Mục tiêu
Các đồ vật người chơi dùng ở đoạn 1–2: công tắc đèn chính, chốt cửa phòng 407, giấy tờ đọc được, điện thoại rung báo 0 giờ. Mỗi đồ vật là một scene độc lập, dùng lại được. **Integrator đặt chúng vào tầng 4** tại các anchor có sẵn (`Room407LightSwitch`, `Door407`, `RulesPaper407`, `Phone_Trung`…), lane A không sửa scene tầng 4.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/`, `game/localization/strings.csv` (thêm key)

## Yêu cầu
Mỗi đồ vật kế thừa `Interactable` (`game/scripts/core/interactable.gd`), có scene trong `game/scenes/interaction/` gồm `CollisionShape3D` và một mesh tạm nhỏ (hộp) đúng cỡ. Gốc tọa độ đặt sao cho lắp thẳng vào anchor là đúng chỗ. Mọi chữ dùng key dịch, đủ `vi` và `en`.

1. **Công tắc đèn `light_switch.tscn` / `light_switch.gd`:**
   - `@export var light: Light3D`, `@export var flag: StringName = &"main_light_on"`.
   - Bấm thì bật hoặc tắt `light.visible` và đặt `GameState.set_flag(flag, đang_bật)`. `LightHum` của lane E tự tắt tiếng ù theo đèn.
   - Gợi ý đổi theo trạng thái: `PROMPT_LIGHT_OFF` ("Tắt đèn") khi đèn đang bật, `PROMPT_LIGHT_ON` ("Bật đèn") khi đang tắt. Player đã tự phát lại gợi ý khi `prompt_key` đổi.
   - Lúc vào cây scene, đặt cờ theo trạng thái đèn thật.
2. **Chốt cửa `door_latch.tscn` / `door_latch.gd`:**
   - `@export var door: Interactable` (integrator gán `Door407`), `@export var flag: StringName = &"door_locked"`.
   - Chỉ chốt được khi cửa đang đóng: đọc `door.is_open` nếu thuộc tính đó tồn tại.
   - Chốt: đặt cờ `true` và `door.enabled = false`, để cửa không mở được. Mở chốt thì làm ngược lại.
   - Gợi ý: `PROMPT_LOCK_DOOR` ("Chốt cửa") / `PROMPT_UNLOCK_DOOR` ("Mở chốt").
   - Không sửa `door407.gd` (thuộc lane B).
3. **Giấy tờ đọc được `readable.tscn` / `readable.gd`:**
   - `@export var document_id: StringName`.
   - Bấm: `DocumentData.load_by_id(document_id).mark_rules_read()`, rồi emit `EventBus.document_opened(document_id)`. Lane D hiện tờ giấy cận cảnh và tự đóng bằng `document_closed`.
   - Không tìm thấy dữ liệu thì `push_warning` và không làm gì.
   - Gợi ý: `PROMPT_READ` ("Đọc").
   - Mesh tạm: tờ giấy A4 mỏng. Có `@export var size: Vector2` để dùng cho bảng lớn (bảng nội quy hành lang).
4. **Điện thoại `phone.tscn` / `phone.gd`:**
   - Hàm `ring()`: bật rung (rung nhẹ mesh; phát `@export var vibrate_stream: AudioStream` nếu được gán, lane E làm âm ở T-130), bật `enabled`. Signal `answered`.
   - Khi không rung thì `enabled = false`, không hiện gợi ý.
   - Bấm khi đang rung: dừng rung, `GameState.set_flag(&"phone_checked", true)`, emit `answered`, và emit `EventBus.subtitle_requested("SUB_PHONE_MIDNIGHT", 4.0)`. Câu: "0 giờ. Báo thức: tắt đèn đi ngủ." / "Midnight. Alarm: lights out, go to sleep."
   - Gợi ý: `PROMPT_PHONE` ("Xem điện thoại").
5. **Test `game/tests/player/`:**
   - Công tắc: bật/tắt đèn, cờ đúng, gợi ý đổi theo trạng thái, cờ đúng ngay khi vào cây scene.
   - Chốt: không chốt được khi cửa mở; chốt thì cửa `enabled = false` và cờ `true`; mở chốt thì trả lại.
   - Giấy: bấm thì sổ tay có các dòng của tờ (dùng `game/data/rules/demo.tres` và `room_paper_407`), `document_opened` được emit đúng id; id sai thì không emit.
   - Điện thoại: chưa rung thì không tương tác được; `ring()` rồi bấm thì `answered`, cờ và phụ đề đúng.
   - Mỗi test tự dọn trạng thái của `GameState` và `RuleSystem` (`reset()`).
6. **Scene thử `game/scenes/interaction/interaction_test.tscn`:** một phòng nhỏ có Player, công tắc, đèn, cửa có chốt (dùng cửa tạm của riêng lane A), một tờ giấy, điện thoại có phím `R` để rung. Dùng để thử bằng F6.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền, kèm danh sách scene và tham số `@export` để integrator gắn vào anchor

## Handoff (agent điền)
