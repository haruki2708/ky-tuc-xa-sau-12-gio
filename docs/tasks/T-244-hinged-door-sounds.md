# T-244 — Tiếng mở/đóng cửa nhà tắm và cửa ban công (chương 1)
- Lane: E (Âm thanh) | Trạng thái: todo | Agent: tài khoản GPT lane E (D-141), Codex CLI, `D:\GAME_WORK\lane-e2`
- Nhánh: `lane-e/T-244-hinged-door-sounds` từ `origin/main` mới nhất (phải có tín hiệu `HingedDoor.swung`/`settled`, xem mục 1).
- Quyết định giao: **D-161** (12/11/2026): chủ dự án chơi T-242 và chốt; chọn giao lane E làm tiếng cho hai cửa. **Tiếng để nhỏ, chủ dự án nghe rồi mới chốt.**
- Bối cảnh: [T-242](T-242-doors-by-hand.md) (cửa nhà tắm và cửa ban công mở/đóng bằng tay ở chương 1, Trung tự bước tránh cánh cửa). Hiện hai cửa này **im lặng** khi mở/đóng.

## 1. Hiện trạng (integrator đã chuẩn bị)
- `game/scripts/interaction/hinged_door.gd` (`HingedDoor`, của integrator): mỗi cửa có hai tín hiệu dành cho âm thanh:
  - `swung(open: bool, seconds: float)`: cánh **bắt đầu** quay, mở (`open = true`) hay đóng, trong `seconds` giây. `seconds = 0` nghĩa là bật ngay (chương hoặc quản lý đặt cửa, không có tay).
  - `settled(open: bool)`: cánh **đã tới** chỗ (mở hẳn hay đóng sập vào khung).
- Tìm cửa: `HingedDoor.of(room.get_node("Extension/BathroomDoor"))`, `HingedDoor.of(room.get_node("Extension/BalconyDoor"))` (room = `Floor4/Room407`). Chỉ chương 1 có (`Protagonist.attach`); chương 2–4 trả về null.
- Ai làm cửa quay:
  - người chơi (tay Trần Trung): `seconds` khoảng 0,5–0,9 s; cửa ban công quay 172° nên lâu hơn (tối đa ~0,9 s);
  - quản lý mở cửa ban công khi săn người chơi: `seconds` 0,5;
  - quản lý mở cửa nhà tắm, chương đặt lại cửa khi chơi lại: `seconds` 0 (bật ngay).
- Tiếng cửa có sẵn trong repo: `game/audio/sfx/wood_door_open.ogg`, `wood_door_close.ogg`, `door_latch.ogg` (xem `game/audio/CREDITS.md`). **Cửa nhà tắm là cửa gỗ; cửa ban công là cửa khung nhôm kính** (D-127), nên cần tiếng khác cửa gỗ.
- Cửa 407 hiện cũng chưa có tiếng mở/đóng (chỉ có tiếng rung tay nắm). **Không làm trong card này**; ghi nhận xét vào Handoff nếu thấy cần.

## 2. Việc
1. **Chọn hoặc tạo tiếng** (CC0/CC-BY hoặc tự tổng hợp, ghi `CREDITS.md`, đưa qua pipeline `audio_source/`):
   - cửa gỗ nhà tắm: mở (bản lề kẽo kẹt nhẹ), đóng (chạm khung + chốt);
   - cửa nhôm kính ban công: mở, đóng (khung nhôm chạm, kính rung nhẹ).
   - Mức: theo `audio_source/README.md` (SFX −18 LUFS) **hoặc nhỏ hơn**; chủ dự án thích âm nhỏ.
2. **Gắn tiếng** bằng script mới trong `game/scripts/audio/` (ví dụ `hinged_door_audio.gd`):
   - nguồn âm 3D đặt ở tay nắm hoặc mép cánh (đi theo cánh);
   - `swung(true, s > 0)`: tiếng mở; `settled(false)`: tiếng đóng/chốt; `seconds = 0` (đặt cửa không tay): **không phát** hoặc phát rất nhỏ, ghi lựa chọn vào Handoff;
   - có hàm tĩnh kiểu `HingedDoorAudio.attach_all(room)` để integrator gọi **một dòng** trong `chapter1_main.gd` khi merge (file đó không thuộc lane E: ghi vào "Yêu cầu thay đổi").
3. **Test** trong `game/tests/audio/`: dựng chương 1 (`auto_start = false`), gọi `swing()` trên từng cửa, kiểm tiếng đúng phát, đúng chỗ, không phát khi `seconds = 0` (nếu chọn vậy).
4. **Cảnh nghe thử** có phím bấm (mẫu T-218): mở/đóng từng cửa, đứng trong phòng, trong nhà tắm, ngoài ban công.

## 3. Được phép sửa
- `audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`, `game/default_bus_layout.tres` (chỉ khi cố ý).
- Card này: chỉ Checklist và Handoff.

## 4. Không được
- Không sửa `hinged_door.gd`, `chapter1_main.gd`, director, level, scene phòng. Cần gì thì ghi "Yêu cầu thay đổi" trong Handoff.
- Không đổi tiếng hay mức âm đã duyệt khác. Không chạy bot, không đo FPS.

## 5. Checklist
- [ ] Bốn tiếng (gỗ mở/đóng, nhôm kính mở/đóng), số đo LUFS/true peak, nguồn ghi CREDITS
- [ ] Script gắn tiếng theo tín hiệu `swung`/`settled`, có hàm để integrator gọi một dòng
- [ ] Test `game/tests/audio/` đạt
- [ ] Cảnh nghe thử có phím, hướng dẫn nghe cho chủ dự án
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [ ] Handoff trung thực, commit hash, "chưa nghe bằng tai, chờ chủ dự án nghe"

## 6. Handoff (agent điền)
