# T-242 — Cửa nhà tắm và cửa ban công mở/đóng bằng tay; Trung tự bước tránh cánh cửa (D-154, D-159)
- Lane: **integrator (Claude làm thay B, lane B hết hạn mức)** | Trạng thái: in-progress | Agent: Claude Code ở máy, Fable 5.2 high (chủ dự án đặt 11/11)
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
(integrator điền khi xong)
