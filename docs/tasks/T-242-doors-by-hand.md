# T-242 — Cửa nhà tắm và cửa ban công mở/đóng bằng tay; Trung tự bước tránh cánh cửa (D-154, D-159)
- Lane: **integrator (Claude làm thay B, lane B hết hạn mức)** | Trạng thái: done, merged 12/11/2026 (full test 913/0, check 0); chủ dự án chơi bản `780ed57` và chốt ("khá ổn, tôi chốt") | Agent: Claude Code ở máy, Fable 5.2 high (chủ dự án đặt 11/11)
- Nhánh: `integrator/T-242-doors-by-hand` từ `main` (`8838947`).
- Quyết định giao: **D-154** (làm sau T-239), **D-159** (11/11/2026, bốn lựa chọn của chủ dự án, mục 1).
- Bối cảnh: [T-239](T-239-protagonist-hand-fixes.md) (quy tắc chọn tay nắm theo phía cửa, `DoorHandles.sides`), [T-241](T-241-protagonist-natural-reach.md) (đứng yên gập hông khi với), D-127/D-129/D-130 (cửa ban công).
- Phạm vi: **chỉ chương 1** (chương duy nhất có thân Trần Trung, `Protagonist.attach`). Chương 2–4 không đổi.

## 1. Chủ dự án đã chốt (D-159)
| Câu hỏi | Chốt |
|---|---|
| Kéo cửa về phía mình khi đang đứng chỗ cánh quét qua | **Trung tự bước tránh**: bấm E, Trung tự bước một bước ngắn (dưới 0,6 m) sang chỗ không vướng cánh mà vẫn với tới chỗ cầm, rồi mới làm động tác cửa. |
| Cửa 407 | **Ba cửa như nhau** (cửa 407, nhà tắm, ban công). Chỉ khi chính người chơi mở/đóng; quản lý mở cửa giữ nguyên. |
| Đóng cửa ban công | **Chỉ từ ngoài ban công** (cánh mở áp tường ngoài 172°, D-127; trong phòng không với tới). Mở thì từ hai phía. |
| Cửa nhà tắm chương 1 | **Đóng sẵn lúc đầu chương, người chơi tự mở/đóng được.** Chương 1 từ nay vào được nhà tắm; trốn trong đó quản lý vẫn mở cửa vào (D-069). |

## 2. Hiện trạng đo được (probe 11/11, tọa độ phòng 407)
- **Cửa nhà tắm:** bản lề (5,35; −4,0), cánh 0,98 m, mở **vào nhà tắm** 82° (áp tường tây). Chương 1: đóng, có va chạm, không có `Interactable` → người chơi không vào được nhà tắm.
- **Cửa ban công:** bản lề (3,26; −7,075), cánh 0,92 m, mở **ra ban công** 172° (áp tường ngoài phía đông). Chương 1: mở sẵn, không đóng được.
- Cả hai đã có tay nắm Tripo hai mặt (`Lever*`), nhận `DoorHandles.take` + `DoorHandles.sides` không cần sửa.
- Tầm với (lưới 0,1 m): cửa nhà tắm đóng, với được tay nắm từ cả hai phía; mở, chỉ với được mép cánh từ trong nhà tắm. Cửa ban công đóng, với được từ hai phía; mở, chỉ với được mép cánh từ ban công.
- Kéo cửa về phía mình thì phần lớn chỗ đứng với tới tay nắm nằm trong tầm quét của cánh (nhà tắm: bán kính 0,98 m quanh bản lề; ban công 0,92 m). Luôn có chỗ đứng vừa với tới vừa ngoài tầm quét, cách không quá 0,6 m.

## 3. Việc
1. **`HingedDoor`** (`game/scripts/interaction/hinged_door.gd`): `Interactable` cưỡi trên cánh của một nút `hinged.gd` (cửa nhà tắm, cửa ban công): lời nhắc Mở cửa/Đóng cửa, cánh quay theo tay (`hand_seconds`), chỗ cầm theo quy tắc T-239.
2. **`Protagonist.attach`** gắn `HingedDoor` cho hai cửa (chỉ chương 1), gọi `DoorHandles.sides` cho cả ba cửa; `sides` ghi thêm chiều dài và bề dày cánh.
3. **Tầm quét** (`DoorSwing`): một hàm chung cho ba cửa trả lời "lần quay sắp tới có chạm người đứng ở điểm này không".
4. **Tự bước tránh:** khi bấm E mà đang vướng tầm quét, người chơi tự đi (đi bộ bình thường, có tiếng bước chân, thân chạy clip đi) tới chỗ gần nhất thỏa: thân vừa, đường đi thẳng không vướng, ngoài tầm quét, vẫn với tới chỗ cầm; mắt vẫn hướng về chỗ cầm. Tới nơi mới làm động tác cửa. Không có chỗ nào như vậy thì làm như trước (không chặn người chơi).
5. **Quản lý chương 1:** người chơi ở ban công sau cánh cửa đóng thì quản lý tới gần và mở cửa ban công, như cửa nhà tắm (D-130). Bắt đầu lại/checkpoint: cửa nhà tắm đóng, cửa ban công mở.
6. **Test:** quy tắc chỗ cầm cho hai cửa mới; tầm quét; tự bước tránh ở cả ba cửa (sau thao tác, không xương thân nào cắt cánh cửa); quản lý mở cửa ban công; chương 2 (cửa kẹt) không đổi.
7. **Ảnh:** mỗi cửa, mỗi phía, mở và đóng (`previews/t242/`).

## 4. Không đổi
- Cửa kẹt chương 2 (`StuckDoor`), góc mở hai cửa, hình cửa, âm thanh (cửa chưa có tiếng; việc của lane E nếu chủ dự án muốn).
- Đóng cửa ban công từ trong phòng: chủ dự án chọn không làm.

## 5. Handoff
Nhánh `integrator/T-242-doors-by-hand`. Phần lớn code viết bằng Fable 5.2 high, phần cuối (sửa quản lý, kiểm, merge) bằng Opus 5.5 high. Commit: `3de713e` (code + test), `32bf33d` (quản lý mở cửa gần nhất, ảnh).

**Đã làm:**
- **`HingedDoor`** (`game/scripts/interaction/hinged_door.gd`): `Interactable` cưỡi trên cánh của `hinged.gd`; lời nhắc Mở cửa/Đóng cửa theo trạng thái; cánh quay theo tay, không nhanh hơn 200°/s (cửa ban công 172° quay tiếp sau khi tay buông); `set_open` của chương hay quản lý vẫn thắng nếu gọi giữa lúc cánh đang quay. `HingedDoor.of(door)` tìm lại nó.
- **`Protagonist.attach`** gắn `HingedDoor` cho cửa nhà tắm và cửa ban công (`HINGED_DOORS`). Chỉ chương 1 có thân nên chương 2–4 không đổi (test kiểm).
- **`DoorHandles.sides`** đo cánh cửa thành một tấm (chiều dài, bề dày) cho **`DoorSwing`** (`game/scripts/interaction/door_swing.gd`): khoảng cách gần nhất từ một điểm tới cánh trong lúc cánh quay, tính đúng công thức, không lấy mẫu.
- **Tự bước tránh** (`PlayerBody.clear_spot`, `player.gd` `_tick_clear_step`):
  - bấm E khi thân nằm trong tầm quét thì tìm trên lưới 6 cm, bán kính 1,2 m, chỗ cánh không chạm (cách thân ≥ 4 cm), thân vừa, đi thẳng tới được, vẫn với tới chỗ cầm, kể cả khi người hơi lắc;
  - ưu tiên chỗ đi ít và **chỗ cầm gần** (không phải rướn): ảnh đầu tiên cho thấy đóng cửa ban công phải gập người sâu, đã sửa;
  - đi bộ thật (clip đi, tiếng bước chân) 1,8 m/s, mắt giữ nguyên hướng nhìn chỗ cầm; tới nơi mới làm động tác cửa;
  - không thấy chỗ nào thì không làm gì (không chặn người chơi);
  - tìm chậm nhất 7 ms (một lần mỗi lần bấm E).
- **Cửa 407** có `swing_angle()`/`pivot()` nên dùng chung cách tránh (D-159 (2)).
- **Quản lý chương 1** (`chapter1_director.gd`): Trung ở ban công sau cánh cửa đóng thì quản lý tới gần và quay cánh mở (0,5 s). Trước đây mặt phẳng của cửa nhà tắm kéo dài ra tới ban công nên cũng bị coi là "chắn giữa": quản lý giờ mở cửa nào anh ta tới gần trước, hết giờ thì mở những cửa còn lại (như cũ).

**Đo trong chương 1 (lưới 10 cm quanh bản lề, mọi chỗ có lời nhắc):**

| Cửa | Đang | Chỗ vướng cánh | Chỗ không vướng | Bước xa nhất |
|---|---|---|---|---|
| 407 | đóng | 43 | 31 | 1,15 m |
| 407 | mở | 43 | 57 | 1,03 m |
| Nhà tắm | đóng | 30 | 25 | 0,91 m |
| Nhà tắm | mở | 36 | 21 | 0,97 m |
| Ban công | đóng | 30 | 15 | 0,97 m |
| Ban công | mở | 36 | 21 | 1,03 m |

- Mọi chỗ vướng đều tìm được chỗ để bước.
- Bấm E thật từ 18 chỗ vướng (3 mỗi cửa mỗi trạng thái): đều bước rồi mới làm động tác cửa, cửa đổi trạng thái; cánh đang quay cách thân (capsule) ≥ 2,6 cm và không cắt xương nào; sát nhất là tay trái lướt sát cánh (0 cm) một lần ở cửa 407 đang mở.
- **Lệch so với lúc hỏi (D-159):** tôi nói "một bước ngắn, dưới 0,6 m". Đo thật: phần lớn dưới 0,6 m nhưng có chỗ phải đi tới 1,15 m (đứng sát bản lề, phải vòng ra ngoài tầm quét cả mét).

**Test:**
- Mới: `test_t242_doors.gd` 8 test (cửa có tay ở chương 1, không có ở chương khác; mỗi phía cầm đúng tay nắm hoặc mép; công thức tầm quét; mọi chỗ vướng có chỗ bước; bấm E bước rồi dùng cửa, cánh không chạm thân; không vướng thì dùng ngay; cửa không có tay và chương tự đặt).
- `test_chapter1_d069.gd`: thêm `test_hiding_on_the_balcony_behind_its_shut_door_is_hunted` (22/22).
- T-241 7/7, T-239 6/6 sau thay đổi.

**Ảnh:** `art_source/graphics_upgrade/protagonist/previews/t242/` (mỗi ảnh 5 khung: trước khi bấm E, đang bước, tay chạm chỗ cầm, cánh đang quay, xong).

**Chưa làm / chủ dự án xem khi chơi:**
- Cửa chưa có tiếng (như trước). Muốn có thì giao lane E.
- Chương 1 giờ vào được nhà tắm; người chơi có thể đóng cửa nhà tắm hay cửa ban công rồi trốn sau đó. Quản lý vẫn mở cửa vào bắt (D-069), nhưng anh/chị nên chơi thử xem nhịp có ổn không.
- Đứng sát bản lề mà bấm E thì Trung có thể đi gần 1 m mới nắm cửa. Nếu thấy lâu, có thể chặn: xa quá thì hiện lời nhắc "lùi ra" thay vì tự đi.
