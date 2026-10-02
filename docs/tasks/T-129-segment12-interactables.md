# T-129 — Đồ vật tương tác cho đoạn 1–2
- Lane: A (Gameplay) | Trạng thái: done | Agent:
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền, kèm danh sách scene và tham số `@export` để integrator gắn vào anchor

## Handoff (agent điền)

### Phiên 2026-10-02 — Lane A
- Đã thêm bốn scene tái sử dụng, kế thừa `Interactable`, layer 3 (giá trị 4), mask 0, có collider và mesh hộp. Công tắc đồng bộ cờ/gợi ý ngay khi ready và khi visibility của đèn đổi; chốt kiểm tra `is_open` nếu có, khóa/mở bằng `door.enabled`; giấy ghi luật trước khi mở document, id sai chỉ warning; điện thoại rung mesh ±2 mm, phát/lặp stream được gán, trả lời thì dừng rung/âm, đặt cờ và phát signal/phụ đề.
- Thêm phòng thử `res://scenes/interaction/interaction_test.tscn`: Player, sàn/tường, đèn/công tắc, cửa tạm riêng Lane A với chốt, giấy `room_paper_407`, điện thoại trên bàn, HUD và menu pause có sẵn. R gọi `Phone.ring()` bằng phím debug trong scene, không thêm input action. Phòng thử tự nạp `demo.tres`; không đặt thời điểm hay phán định cốt truyện.
- Thêm 8 key vi/en vào cuối CSV, không sửa key cũ. Thêm 12 test và commit các UID do Godot sinh.
- Commit code `5dfefba` — `T-129: Add reusable segment one and two interactables and test room`; đã push `origin/lane-a/T-129-segment12-interactables` trước khi cập nhật Handoff.

### Scene và tham số cho integrator
Các scene nằm trong `res://scenes/interaction/`, script cùng tên nằm trong `res://scripts/interaction/`. Gán tham chiếu trước khi scene vào cây. Các export kế thừa `enabled` và `prompt_key` vẫn có; gợi ý của công tắc/chốt được cập nhật theo trạng thái, điện thoại tự quản lý `enabled`.

| Scene | Export cần gán | Anchor / hệ tọa độ và kích thước |
|---|---|---|
| `light_switch.tscn` | `light: Light3D`; `flag: StringName = &"main_light_on"` | Gắn `Room407LightSwitch`, gán đèn chính thực tế. Gốc là tâm mặt lưng; hộp 0,08 × 0,12 × 0,025 m theo XYZ, nhô về local +Z. Cờ khởi tạo theo `light.visible`, không theo cờ lưu trước đó. |
| `door_latch.tscn` | `door: Interactable`; `flag: StringName = &"door_locked"` | Gán node cửa 407 thật, không gán marker. Gốc theo anchor `Door407` ở bản lề/chân cửa; tâm chốt local `(-0.78, 1.05, -0.16)`, hộp 0,18 × 0,06 × 0,06 m ở mặt trong phòng. Parent theo `Door407/Pivot` để chốt đi theo cánh cửa. Khởi tạo mở chốt/cờ false. |
| `readable.tscn` | `document_id: StringName`; `size: Vector2 = Vector2(0.21, 0.297)` | Gán `&"room_paper_407"`, đặt theo `RulesPaper407` và cho đi theo cánh cửa. Gốc ở tâm mặt lưng, giấy nằm trên XY, dày 0,004 m nhô local +Z. Bảng lớn chỉnh `size` theo mét; collider/mesh riêng từng instance, đổi size lúc chạy cũng cập nhật. |
| `phone.tscn` | `vibrate_stream: AudioStream` (có thể để null) | Gắn `Phone_Trung`, gốc ở đáy điện thoại. Hộp 0,075 × 0,012 × 0,15 m theo XYZ, nằm trên XZ. Sau ready, luồng game gọi `ring()` rồi nghe `answered`; audio qua node `Vibration` trên bus `SFX`, clip không loop tự phát lại khi còn rung. |

### Kiểm tra và phần chưa thử
- Nền: `origin/main` tại `6cf176c`.
- `pwsh tools/test.ps1 -Filter segment12`: **`RESULT: 12 passed, 0 failed`**, exit code 0.
- `pwsh tools/test.ps1`: **`RESULT: 146 passed, 0 failed`**, exit code 0.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit code 0. `git diff --cached --check` sạch trước commit code.
- Test bao phủ trạng thái/cờ/gợi ý đèn, cờ tùy chỉnh, disabled, chốt với chính script `door407.gd` hiện có, cửa thiếu thuộc tính/không còn tồn tại, đọc đúng luật/nguồn/id/thứ tự signal, đọc lại không trùng, id sai, kích thước giấy độc lập, điện thoại chưa rung/rung/trả lời/rung lại, stream được gán phát và dừng, bản dịch, wiring phòng thử/phím R và ray mask 5 chạm đúng cả bốn đồ vật. Mỗi test mới reset `GameState`/`RuleSystem` trước và sau.
- Lượt test đầu trong sandbox có 11 test hành vi đạt nhưng launcher trả FAIL do Godot không đọc được kho chứng chỉ Windows. Đã chạy lại ngoài sandbox qua cơ chế cấp quyền, rồi thêm test ray và chạy các lượt PASS phía trên. Warning của id giấy sai là ca kiểm tra có chủ ý; smoke test mở công tắc riêng lẻ chưa gán đèn cũng phát warning cấu hình, không phải lỗi parse/runtime.
- **Chưa chơi F6 bằng chuột/phím thật, chưa chụp hình hoặc nghe âm thật.** Âm điện thoại mới kiểm tra bằng stream WAV im lặng tạo trong test; chưa có clip T-130 được gán. Chưa có màn xem giấy T-111 trong phòng thử, nên đọc giấy hiện ghi sổ tay/phát signal, chưa hiện cận cảnh. Chưa kiểm tra bốn scene sau khi gắn vào tầng 4.
- Cách thử tiếp: mở `interaction_test.tscn`, F6; WASD đến gần đồ vật, E tương tác, Esc mở menu, R rung điện thoại. Thử chốt khi cửa mở/đóng, bật/tắt đèn, đọc giấy và trả lời điện thoại; gán `Phone.vibrate_stream` để nghe rung. Sau T-111, gắn màn xem giấy để nhận `document_opened` và đóng qua `document_closed`.

### Yêu cầu thay đổi / chặn
- T-117/integrator đặt bốn scene vào anchor, gán đèn/cửa thật, nạp `demo.tres` trước khi đọc giấy, nối màn xem giấy T-111 và gán âm rung T-130; luồng game quyết định lúc gọi `ring()`. Lane A không sửa tầng 4, main, core hay file các lane khác.
- **Xử lý vùng tương tác cửa 407 khi gắn giấy:** từ cấu trúc hiện tại, `Door407/InteractShape` dày 0,25 m (mép phía phòng z = −0,125), trong khi anchor giấy ở z ≈ −0,023. Ray từ trong phòng sẽ chạm proxy cửa trước giấy. Integrator/Lane B cần thu hoặc bố trí lại collider tương tác cửa để giấy/chốt được nhắm riêng, đồng thời giữ collision world của cánh cửa; thay mesh giấy tạm cũ và bảo đảm giấy/chốt đi theo pivot. Chưa kiểm chứng thay đổi này trong scene tầng 4 vì ngoài phạm vi.
- Không có blocker code/test/push của T-129, không còn code dở. Phần ghép tầng 4 và xem/nghe thật chờ T-117/T-111/T-130. Không thêm luật, cốt truyện, plugin, phần mềm hoặc input action mới.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`.** Sau merge và gắn vào tầng 4: `test.ps1` → `RESULT: 150 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi. Bốn đồ vật gọn, dùng lại được; bảng tham số và hệ tọa độ trong Handoff giúp ghép rất nhanh. 12 test, gồm cả tia nhắm thật.
- **Phát hiện trước khi ghép, rất đáng giá:** vùng tương tác của cửa 407 che tờ giấy dán ở mặt trong. Integrator xử lý trong `main.gd`, không sửa file lane A hay lane B: vùng bấm của tờ giấy kéo dài 0,15 m vào phòng (`PAPER_PICK_DEPTH`), mặt giấy vẫn sát cánh cửa.
- `strings.csv`: trùng `SUB_PHONE_MIDNIGHT` với key integrator đã thêm ở T-117 (cùng nội dung), đã bỏ bản trùng khi merge.
- **Đã gắn (T-117):** công tắc ở `Room407LightSwitch` (gán `Room407MainLight`); chốt và tờ `room_paper_407` gắn vào `Door407/Pivot` nên đi theo cánh cửa; điện thoại ở `Phone_Trung`, nối vào `StoryDirector.phone_path`. Test core `test_room_407_interactables_are_reachable_from_inside` bắn tia từ trong phòng: giấy, cửa, chốt, công tắc đều trúng đúng vật; chốt làm cửa không mở được; đọc giấy ghi điều 3 giả vào sổ tay.

**Việc nhỏ cho lần sau (không chặn):**
1. Thêm `@export var pick_depth` vào `readable.gd` để integrator không phải sửa collision từ ngoài.
2. Cửa 407 vẫn hiện gợi ý chung "Tương tác". Nên có `PROMPT_OPEN_DOOR` và `PROMPT_CLOSE_DOOR` (cửa thuộc lane B, `door407.gd`).

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
