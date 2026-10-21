# Tripo: cửa và tay nắm cho phòng 407 (T-222, D-126)

> Integrator (Claude, Opus 5.5), 20/10/2026.
> - **Người bấm tạo:** chủ dự án. Không giới hạn lượt (D-095); credit chỉ ghi khi chủ dự án báo.
> - **Cài đặt:** giữ như đợt 2 ([`TRIPO_DOT2_PHONG407.md`](TRIPO_DOT2_PHONG407.md) mục 1–3): Text to 3D, **H3.1**, Ultra mesh, texture **4K**, PBR, Remove lighting. Ra kiểu hoạt hình thì làm như lần quản lý: tạo ảnh mẫu trong Tripo (Nano Banana) rồi Image to 3D.
> - **Tải GLB về** `D:\GAME_DEMO\build\graphics\staging\doors\`, tên theo cột "File"; lượt sau thêm `_r2`, `_r3`.
> - **Chỉ tạo cánh cửa, không kèm khung, không kèm tường.** Khung cửa Claude dựng bằng Blender để khớp đúng lỗ cửa trong phòng.
> - **Kích thước:** tạo đúng tỉ lệ ghi trong bảng. Claude chỉnh lại cỡ thật khi nướng.

## 1. Mức cũ bẩn (cùng mức với đồ trong phòng)
- Ký túc xá đã dùng nhiều năm.
- Sơn bong ở mép và quanh tay nắm, vết tay mờ, trầy xước, bụi bám ở ô pano.
- Không mục nát, không thủng, không vết máu (phần kinh dị do code dựng theo truyện).
- Không chữ, không số phòng, không logo (số phòng và giấy dán do code đặt).

## 2. Các món

| # | Món | File | Kích thước (rộng × cao × dày) | Prompt |
|---|---|---|---|---|
| 1 | Cánh cửa phòng 407 | `door_room.glb` | 0,89 × 2,10 × 0,04 m | `Single interior wooden door leaf only, no frame, old Vietnamese university dormitory room door, four raised rectangular panels, painted dark green with chipped and peeling paint at the edges and around the handle area, faint hand marks, scratches, dust in the panel grooves, two steel hinges on one long edge, no handle, no lock, no number, no text, flat front view, photorealistic, PBR` |
| 2 | Cánh cửa nhà tắm | `door_bathroom.glb` | 0,98 × 2,20 × 0,04 m | `Single bathroom door leaf only, no frame, old cream white PVC plastic door common in Vietnamese dormitories, yellowed and water-stained near the bottom, a louvred ventilation grille in the lower part, light scratches, two hinges on one long edge, no handle, no text, flat front view, photorealistic, PBR` |
| 3 | Cánh cửa ban công | `door_balcony.glb` | 0,92 × 2,24 × 0,05 m | `Single balcony door leaf only, no frame, old aluminium framed door with a frosted glass upper panel and a solid aluminium lower panel, dull grey aluminium with oxidation spots and grime in the corners, slightly dirty glass, two hinges on one long edge, no handle, no lock, no text, flat front view, photorealistic, PBR` |
| 4 | Tay nắm cửa gạt | `door_lever.glb` | cần gạt dài khoảng 12 cm, đế tròn | `Single door lever handle with a round rose plate, old worn brushed stainless steel, light scratches, dull grime around the rose, slightly tarnished, typical Vietnamese apartment or dormitory interior door hardware, lever about 12 cm long, photorealistic, PBR, no text, no keyhole, isolated object` |

- **Cửa ban công:** cửa cánh có tay nắm gạt, chủ dự án đã chốt (D-127). Prompt món 3 giữ nguyên.
- **Tay nắm:** chọn kiểu **đế tròn**. Đế dài hình chữ nhật thì Claude phải tách đế khỏi cần gạt (vẫn làm được nhưng lâu hơn).

## 2b. Lượt 1 (22/10) và lượt 2

Integrator xem lượt 1 (ảnh xem nhanh trong Blender, mặt trước, mặt sau, cạnh):

| File | Kết quả | Việc tiếp |
|---|---|---|
| `door_lever.glb` | **Đạt**: cần gạt, đế tròn 3 lỗ vít, thép cũ trầy | Claude giảm lưới, nướng |
| `door_balcony.glb` | **Đạt**: khung nhôm, kính mờ trên, tấm nhôm dưới, hai mặt đều có chi tiết | Claude cắt tay nắm nhỏ dính trên cánh, bóp ngang cho vừa 0,92 m |
| `door_bathroom.glb` | **Dùng được**: lá sách, ố chân cửa đẹp; nhưng dính khung bao, có tay nắm, mặt sau trơn | Claude cắt khung, bỏ tay nắm, lấy mặt trước làm luôn mặt sau. Anh/chị muốn thì tạo lại bằng prompt dưới |
| `door_room.glb` | **Không đạt**: ra **cửa hai cánh**, dính khung, có tay nắm và ổ khóa, mặt sau trơn | **Tạo lại**, file `door_room_r2.glb` |
| `door_room_r2.glb` (22/10) | **Đạt**: một cánh, 5 ô pano; còn dính khung, tay nắm, mặt sau trơn | Claude cắt khung, bỏ tay nắm, lấy mặt trước làm mặt sau; đã gắn vào cảnh thử |

**Lượt 2, cánh cửa phòng (`door_room_r2.glb`):** nên làm như lần quản lý: tạo ảnh mẫu trong Tripo trước, thấy đúng một cánh rồi mới Image to 3D.

- Prompt ảnh mẫu / Text to 3D: `One single interior door leaf, ONE leaf only, not a double door, tall narrow rectangle about 0.9 m wide and 2.1 m tall, solid wood, four raised rectangular panels arranged two above two, painted dark green with chipped and peeling paint at the edges, faint hand marks, scratches, dust in the panel grooves, no frame, no casing, no handle, no lock, no keyhole, no hinges, no number, no text, straight flat front view on a plain background, photorealistic, PBR`
- Mặt sau trơn cũng không sao: Claude lấy mặt trước làm mặt sau (cửa phòng thật hai mặt giống nhau).
- (Tuỳ chọn) cửa nhà tắm lượt 2 (`door_bathroom_r2.glb`): `One single bathroom door leaf only, old cream white PVC plastic door common in Vietnamese dormitories, a louvred ventilation grille in the lower part that goes through the door, yellowed and water-stained near the bottom, light scratches, no frame, no casing, no handle, no lock, no hinges, no text, straight flat front view, photorealistic, PBR`

## 3. Kiểm trước khi tải
1. Chỉ có cánh cửa, không dính khung hay tường.
2. Hai mặt cánh đều có chi tiết, không bị mặt sau trơn hoặc rỗng.
3. Cạnh cửa thẳng, không cong vênh, không lỗ thủng.
4. Không chữ, số, logo.
5. Mức cũ đúng mục 1: cũ nhưng còn dùng được.

**Sửa:**
- Sai màu hoặc quá sạch: AI Texturing với phần mô tả màu và vết bẩn của prompt.
- Một chỗ hỏng (mép, ô kính): Magic Brush vùng đó.
- Hình sai hẳn: tạo lại, hoặc tạo ảnh mẫu rồi Image to 3D.

## 4. Báo lại integrator
- Tên file, lượt thứ mấy, đã sửa bằng gì.
- Báo ngay trong lúc trò chuyện với integrator. Không cần ghi file; bằng chứng giấy phép D-084 do Claude lưu khi đóng gói (gói Pro, ngày tạo, prompt, điều khoản, hash file gốc).
