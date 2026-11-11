# T-243 — Thân Trần Trung ở chương 2: cầm đồ, nhét miệng xác, hích cửa kẹt, nút vòi sen, lau màn hình
- Lane: **integrator (Claude làm thay B, chủ dự án chọn 12/11)** | Trạng thái: in-progress | Agent: Claude Code ở máy, Opus 5.5 high
- Nhánh: `integrator/T-243-protagonist-chapter2` từ `main`.
- Quyết định giao: **D-161** (thân Trung cho chương 2), **D-162** (12/11/2026, kiểu động tác, mục 1).
- Bối cảnh cần đọc:
  - Chương 1 đã xong và được chủ dự án duyệt: [T-239](T-239-protagonist-hand-fixes.md) (tay), [T-241](T-241-protagonist-natural-reach.md) (lấy đồ: đứng yên gập hông ≤ 40°, đồ thấp cúi gập 1,4 s), [T-242](T-242-doors-by-hand.md) (cửa bằng tay, tự bước tránh cánh). **Giữ nguyên tất cả những gì đã duyệt.**
  - `game/scripts/player/protagonist.gd` (`Protagonist.attach`), `player_body.gd` (đầu file), `scenes/main/chapter1_main.gd` (`protagonist_body`, chương 2 dùng chung script).
  - `game/scripts/core/chapter2_director.gd` `_place_ch2_props` (chỗ đặt các thao tác chương 2), `docs/design/CH2_DESIGN.md`.
  - `game/tests/player/test_ch2_4_hand_targets.gd`: các `HandTarget` của chương 2 đã đặt sẵn (T-231).

## 1. Chủ dự án đã chốt (D-162, 12/11)
| Thao tác (chương 2) | Code hiện có | Động tác chốt |
|---|---|---|
| **Hích cửa nhà tắm kẹt** (vòng 4, 3 lần) | `StuckDoor` (`stuck_door.gd`), `player.play_door_bash()` chỉ rung camera | **Hích vai vào cửa**: nghiêng người, dồn vai vào cánh; camera rung như nay. Lần 3 cửa bung. |
| **Cầm giẻ / khăn / áo** (vòng 3) | `CarryItem` (`carry_item.gd`) treo đồ trước camera (0,24; −0,22; −0,55) | **Cầm trong tay phải**: đồ nằm trong bàn tay phải, đi theo tay khi đi lại. |
| **Nhét đồ vào miệng xác** (giường 1, 2, 4) | `GagSpot` (`gag_spot.gd`), `Chapter2Director.gag` | **Ấn đồ vào miệng xác** rồi rút tay về, **theo độ cao miệng** (bổ sung D-162): Phúc (giường 1), Đạt (giường 4) ở tầng trên, miệng ~1,8–1,9 m khi ngồi dậy: nhón chân vươn lên; Việt (giường 2) tầng dưới, miệng ngang ngực: đứng gập hông nhẹ. Không máu me thêm. |
| Đang cầm đồ mà dùng thứ khác bằng tay phải (cửa, công tắc, giấy) | — | (bổ sung D-162) **vẫn cầm, làm bằng nắm tay đang cầm**: không bỏ đồ, tay vẫn vươn tới. |
| **Đứng dưới vòi sen** (vòng 4) | `ShowerStall` | **Giữ nguyên quần áo** (áo thun, quần đùi). |
| Nút Có / Không dưới màn vòi sen | `ShowerChoice` | (integrator đặt, chủ dự án đổi được) **bấm bằng đầu ngón tay**, như công tắc đèn. |
| Lau hơi nước trên màn hình (giữ E 1 s) | `ShowerScreen` (`shower_screen.gd`) | (integrator đặt, chủ dự án đổi được) **lòng bàn tay xoa vòng tròn** trên màn suốt lúc giữ E. |

## 2. Việc
1. **Bật thân ở chương 2:** `chapter2.tscn` đặt `protagonist_body = true` (như chương 1). Mọi thứ chương 1 cũng có ở chương 2 (giấy, giường, công tắc, ổ điện, cửa 407, cửa ban công…) phải chạy y như chương 1.
2. **Cửa nhà tắm chương 2 giữ là cửa kẹt.** `Protagonist.attach` hiện gắn `HingedDoor` (mở bằng tay) cho cửa nhà tắm ở mọi chương có thân: ở chương 2 phải **không** gắn (hoặc tắt) để câu đố 3 lần hích không bị phá. Vòng 3 cửa mở sẵn (`_bathroom_door(true)`), vòng 4 kẹt.
3. **Hích vai:** mỗi lần bấm E vào `StuckDoor`, thân hích vai vào cánh (chân không trượt qua cửa, không xuyên cánh), rồi về đứng. Có thể dùng `Hit_Knockback` đảo chiều hoặc dựng tư thế bằng `BodyLeanModifier`. Đẩy trong lúc đang hích: bỏ qua lần bấm.
4. **Cầm đồ trong tay phải:** nhặt bằng tay (như T-241, đồ trên cao `Carry_towel` 2,14 m: với lên), đồ gắn vào bàn tay phải; đi lại dùng `Walk_Carry` hay giữ tay ôm trước bụng, chọn cái nhìn tự nhiên; thả lại (`drop`) và đổi đồ chạy đúng.
5. **Nhét miệng:** từ chỗ đứng cạnh giường, theo luật T-241 (tầng trên: nhón; tầng dưới: đứng gập hông) đưa tay cầm đồ tới miệng xác, ấn, buông đồ ở đó (`consume`), rút tay. Tay không xuyên khung giường, đầu không xuyên song giường. Kiểm thời gian: lấy đồ rồi nhét kịp trong lượt nói của xác (`CORPSE_MUMBLE_SECONDS` 4 s).
6. **Nút và lau màn:** bấm nút Có/Không như công tắc; lau: tay áp màn, xoa vòng tròn đều suốt lúc giữ E, nhả E thì tay về.
7. **Test** (chương 2 thật, `auto_start = false`, đo trên xương đã dựng như T-241): mỗi thao tác hết lời nhắc là hết động tác; không ngồi xổm; tay đúng chỗ; cửa kẹt vẫn cần đúng 3 lần; chương 2 bot/luật không đổi (`test_ch2_*` vẫn đạt).
8. **Ảnh/clip:** mỗi thao tác 3–5 khung (như `previews/t242/`), lưu `art_source/graphics_upgrade/protagonist/previews/t243/`.

## 3. Không đổi
- Luật, thời gian các vòng, độ khó chương 2. Thời gian 1 giây mỗi thao tác tay (D-121), cúi 1,4 s (D-157).
- Chương 1, 3, 4.
- Âm thanh (lane E).

## 4. Câu hỏi để hỏi chủ dự án khi làm (nếu gặp)
- Hích vai có kèm tiếng thở dốc hay chỉ tiếng cửa (đã có `door_push` của lane E).
- Cầm đồ khi đi lại: tay buông xuôi cầm đồ, hay ôm trước ngực.

## 5. Handoff
Nhánh `integrator/T-243-protagonist-chapter2`, integrator (Opus 5.5 high) làm thay B. Commit: `cca5bb3` (bước 1: thân vào chương 2), `9f68d61` (bước 2: các thao tác), `e9fc76a` (gỡ cảnh thử khỏi git).

**Đã làm:**
- **Thân ở chương 2:** `chapter2.tscn` `protagonist_body = true`. `Protagonist.attach(..., hinged_doors)`: chương 2 chỉ gắn `HingedDoor` cho cửa ban công; **cửa nhà tắm vẫn là cửa kẹt** (vòng 4, đúng 3 lần hích; test kiểm).
- **Cầm đồ tay phải** (`PlayerBody.take_item`, `_tick_carry`, `_place_held`; `CarryItem` gọi khi tay chạm đồ):
  - nhặt bằng tay theo luật T-241; đồ là bản sao mô hình thật trong nắm tay (không còn hộp tạm trước camera), vải gấp phẳng (giẻ, áo) rủ xuống từ nắm tay;
  - giữa các thao tác tay giữ đồ trước hông phải (cúi nhìn 60° là thấy); đi lại vẫn giữ;
  - lấy đồ khác thì đổi (đồ cũ về chỗ cũ); dùng thứ khác (cửa, công tắc, giấy) thì **làm bằng nắm tay đang cầm** (D-162).
- **Nhét miệng xác** (`gag_spot.tscn` có `HandTarget` kiểu đầu ngón tay ở miệng, đi theo đầu xác): tay cầm đồ vươn tới ấn vào, đồ biến vào miệng (`consume`), tay về. Theo độ cao miệng: Việt (tầng dưới) đứng; Phúc, Đạt (tầng trên, miệng 1,94 m) **kiễng chân**, chỉ từ một vùng nhỏ sát mép giường (đo: 53–66 ô lưới 5 cm). **Xác nằm thì miệng ngoài tầm với, không hiện lời nhắc** (chủ dự án chọn).
- **Hích vai cửa kẹt** (`_start_shove`, `_tick_shove`): lùi đà, cả người lao tới (tối đa 0,4 m, không vào cánh: tâm người cách mặt cửa ≥ 0,33 m), vai phải dẫn (ngực xoay 42°), chạm ở 0,34 s thì tính 1 lần, rồi bật về chỗ cũ; 0,8 s mỗi cú. Bấm dồn trong lúc hích không tính.
- **Lau màn:** tay áp lòng bàn tay, xoa vòng tròn (5 cm, 1,6 vòng/s) **suốt lúc giữ E**; lau xong hoặc nhả E thì tay về. Nhả sớm: không tính (như cũ).
- **Nút Có/Không:** bấm bằng tay như công tắc. Bấm "Có" xong vẫn còn thời gian bước vào buồng tắm trước khi nước chạy (test kiểm dư > 0,3 s).
- **Sửa chỗ đặt để có thân vẫn chơi được** (trước đây bấm xuyên được, giờ tay phải tới):
  - **tủ Việt mở sẵn** ở chương 2 (chủ dự án chọn): áo trong tủ;
  - **khăn cầm ở phần rủ** (0,4 m dưới dây phơi, ~1,77 m): dây 2,15 m ngoài tầm với cả khi kiễng chân; hình không đổi;
  - **hộp nhìn của cửa kẹt phủ đúng cánh cửa:** trước nằm ở bản lề, nửa trong tường, dưới tay nắm (lỗi có từ trước, có thân mới lộ).

**Test:**
- Mới `test_t243_chapter2.gd` 7 test: thân ở chương 2; cửa nhà tắm vẫn kẹt; giẻ/khăn/áo trong nắm tay (đo trên xương đã vẽ), đi vẫn giữ, đổi đồ, thả; nhét miệng Việt và Phúc bằng tay, xác nằm không với tới; hích 3 cú (tính đúng lúc chạm, bấm dồn không tính, không vào cánh, về chỗ cũ); bấm nút kịp vào buồng tắm; lau giữ E (nhả sớm không tính, giữ đủ thì lau được 1 lần).
- Sửa: `test_protagonist_chapter1` (chương 1 và 2 có thân), `test_ch2_4_hand_targets` (chương 2 có thân: cửa 407 và cửa ban công có chỗ cầm; `gag_spot` kiểu đầu ngón tay; khăn 1,74–1,79 m).

**Ảnh:** `art_source/graphics_upgrade/protagonist/previews/t243/` (mỗi thao tác 4–7 khung; `1_lay_gie` có thêm khung đi cầm đồ và nhìn bằng mắt Trung).

**Chủ dự án xem khi chơi:**
- Xác chương 2 vẫn là hình khối PS1 (chưa có xác Tripo, T-221): tay ấn vào miệng khối vuông.
- Phúc/Đạt chỉ nhét được khi đứng sát mép giường, ngay dưới đầu xác (vùng nhỏ). Nếu khó tìm chỗ, có thể nới.
- Hích vai: lao người tới ~0,4 m rồi về; xem có đủ "mạnh" chưa.
- Đồ cầm tay: vải gấp được xoay cho rủ xuống, có thể trông hơi cứng (mô hình là tấm vải gấp, không phải vải mềm).
