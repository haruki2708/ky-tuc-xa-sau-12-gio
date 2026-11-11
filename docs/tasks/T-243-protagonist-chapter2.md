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
(agent điền)
