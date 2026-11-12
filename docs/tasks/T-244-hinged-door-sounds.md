# T-244 — Tiếng mở/đóng cửa nhà tắm và cửa ban công (chương 1)
- Lane: E (Âm thanh) | Trạng thái: merged 12/11/2026 (full test 932/0, check 0), chủ dự án chơi thử bản `04ddc7d` đạt 13/11 | Agent: tài khoản GPT lane E (D-141), Codex CLI, `D:\GAME_WORK\lane-e2`
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
- [x] Bốn tiếng (gỗ mở/đóng, nhôm kính mở/đóng), số đo LUFS/true peak, nguồn ghi CREDITS
- [x] Script gắn tiếng theo tín hiệu `swung`/`settled`, có hàm để integrator gọi một dòng
- [x] Test `game/tests/audio/` đạt
- [x] Cảnh nghe thử có phím, hướng dẫn nghe cho chủ dự án
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [x] Handoff trung thực, commit hash, "chưa nghe bằng tai, chờ chủ dự án nghe"

## 6. Handoff (agent điền)

### Lane E — 12/11/2026, T-244 (D-164 chạy ngầm)

- Nhánh: `lane-e/T-244-hinged-door-sounds`, từ `origin/main` `24f6da1`; workspace ban đầu sạch, đã fetch, fast-forward main, LFS pull. Kiểm `signal swung` đúng một dòng, `hinged_door.gd:10`.
- Đã tạo bốn WAV nguồn và OGG riêng trong `audio_source/hinged_doors/` và `game/audio/hinged_doors/`; tổng hợp Python theo seed cố định, FFmpeg có sẵn, CC0 và khai báo Codex AI-assisted trong `game/audio/CREDITS.md`. Không đổi bank/mức âm cũ.
- Số đo **OGG**: gỗ mở **−36,05 LUFS / −24,54 dBTP**, gỗ đóng **−42,12 / −20,73**, nhôm kính mở **−36,25 / −22,92**, nhôm kính đóng **−42,13 / −21,75**. Chi tiết hash/thời lượng/dung lượng: `audio_source/hinged_doors/build_report.json`. Tiếng đóng giảm thêm để đỉnh va chạm nhỏ; nguồn 3D gain −6 dB, max_db −6 dB, tầm 8 m, bus SFX, một tiếng mỗi cửa.
- `HingedDoorAudio.attach_all(room)` gắn một nguồn vào tay nắm từng cánh, đi theo cánh; attach lại không nhân đôi. Mở có thời lượng dương phát ngay; đóng chỉ phát khi `settled(false)`. Chọn **im lặng hoàn toàn khi seconds = 0**, gồm quản lý mở nhà tắm/đặt lại chương; dừng tiếng cũ và hủy tiếng chốt chờ khi ngắt/đảo chiều. Mở clip ngắn 0,5 giây ở đầu lượt quay, không đổi pitch theo thời gian. Không phát noise gameplay hay đổi luật.
- Test dựng chương 1 `auto_start=false`, kiểm vật liệu, playback bắt đầu/kết thúc, vị trí tay nắm khi quay, attach lặp, đặt tức thời, ngắt bằng `set_open`, đảo chiều, phòng chưa có HingedDoor, phím cảnh nghe và ba chỗ listener. Lượt đầu 4/0, sau thêm kiểm cảnh nghe và chạy lại đạt **`RESULT: 5 passed, 0 failed`**, log `build/t244-targeted.log`. Full test sau sửa: **`RESULT: 930 passed, 0 failed`**, log `build/t244-full-test.log`. Check: **`RESULT: check 0 error(s)`**, log `build/t244-check.log`; cả hai exit 0 (`build/t244-validation-exit.txt`).
- Đã lấy khóa `D:\GAME_WORK\GODOT_DANG_CHAY.txt` bằng CreateNew, ghi lane E/T-244/giờ, chạy tuần tự và nhả khóa trong finally. Đã khôi phục `game/default_bus_layout.tres` do Godot tự ghi lại, không đổi bus. SHA256 của 4 OGG + 4 WAV khớp báo cáo, mọi file dưới 10 MB (`build/t244-artifact-verification.log`), binary đi qua LFS; log chỉ ở build/, không commit. Không chạy bot riêng, không đo FPS.
- Lượt full đầu phát hiện thiếu bốn file mới trong kiểm kê toàn bộ OGG của `game/tests/audio/test_audio.gd`; đã dừng riêng tiến trình T-244 được xác minh bằng PID/command line (không đụng tiến trình lane khác), lưu `build/t244-full-first-aborted.log`. Đã bổ sung kiểm kê, kiểm loop/thời lượng và giải mã tín hiệu nhỏ cho cả bốn file, không nới test cũ. Chạy lại riêng kiểm kê: **`RESULT: 10 passed, 0 failed`**, log `build/t244-inventory.log`; chạy lại test cửa rồi full/check từ đầu. Camera điểm C được đặt ở phía phòng trước cửa nhà tắm (5,8; 1,6; −3,0), tránh vách x=5,3.
- Cảnh nghe: `res://audio/test/hinged_door_audio_test.tscn`, F6. `1/2`: mở/đóng gỗ; `3/4`: mở/đóng nhôm kính; `5`: yêu cầu quản lý mở ban công 0,5 giây; `C/B/V`: đứng phòng/nhà tắm/ban công; `R`: đặt lại im lặng; `Space`: dừng; `Esc`: thoát. Hướng dẫn đầy đủ: `audio_source/hinged_doors/README.md`. Cảnh riêng tắt âm nền để nghe hai cửa, không director/save/bot/FPS.
- **Chưa nghe bằng tai, chờ chủ dự án nghe.** D-164: tự chọn phương án nhỏ an toàn; độ tự nhiên, phân biệt gỗ với nhôm kính, độ sắc kính và mức nghe thực tế **chờ chủ dự án chọn/nghe**. Test/headless và LUFS không xác nhận chất lượng cảm nhận. Chưa nghe mix bản chơi chương 1 vì lời gọi tích hợp thuộc integrator.

#### Yêu cầu thay đổi (integrator)

- Trong `_ready()` của `game/scenes/main/chapter1_main.gd`, **sau `Protagonist.attach(...)`**, thêm lời gọi (một dòng):

  ```gdscript
  if has_node("Chapter1Director"): HingedDoorAudio.attach_all($Floor4/Room407 as Node3D)
  ```

  **Phải giới hạn chương 1:** main hiện tại đã merge T-243, chương 2 cũng có thân và HingedDoor **ban công**, khác mục hiện trạng cũ của card nói chương 2–4 đều null. Script main dùng chung; không gọi chỉ theo `protagonist_body`, không tự áp âm mới sang chương 2. API không tự quyết chương được dùng.
- Lane E không sửa `hinged_door.gd`, main, director, level, scene phòng, STATUS hay DECISIONS. Cửa 407 vẫn ngoài phạm vi (chưa có tiếng mở/đóng theo card), không thêm trong T-244.
- Không bị chặn triển khai lane E; còn integrator ghép lời gọi trên và chủ dự án nghe duyệt. Commit triển khai: **`f308c9e`** — `T-244: add quiet wood and aluminium glass door audio`; commit Handoff riêng theo sau. Chỉ push nhánh task, không push main, không mở PR.

## Review integrator (12/11/2026)
- Đạt. Lane E chạy ngầm (D-164) từ 16:22 đến 17:18, không hỏi giữa chừng, không bị chặn. Không đụng file ngoài phạm vi, không đổi mức âm cũ, `default_bus_layout.tres` không commit.
- Integrator làm "Yêu cầu thay đổi": `chapter1_main.gd` gọi `HingedDoorAudio.attach_all` sau `Protagonist.attach`, chỉ khi có `Chapter1Director` (chương 2 im). Test `game/tests/player/test_t244_door_audio_wiring.gd`.
- Sau merge: full test 932/0, check 0.
- **Chờ chủ dự án nghe** trong chương 1: mở/đóng cửa nhà tắm (gỗ) và cửa ban công (nhôm kính); có thể nghe riêng ở cảnh `res://audio/test/hinged_door_audio_test.tscn` (phím 1–4).

## Chơi thử
- 13/11/2026: chủ dự án chơi bản `04ddc7d` (gồm T-244, T-246, T-249, T-251) và xác nhận: "ok tôi đã chơi thử rồi, ổn đấy".
