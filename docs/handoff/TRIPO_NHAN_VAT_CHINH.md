# Tripo: nhân vật chính Trần Trung (T-227, D-137)

> Integrator (Claude, Opus 5.5), 23/10/2026.
> - Người bấm tạo: **chủ dự án**. Không giới hạn lượt (D-095). Credit chỉ ghi khi chủ dự án báo.
> - Cách làm giống quản lý ([`TRIPO_QUAN_LY.md`](TRIPO_QUAN_LY.md)): anh/chị tạo thân, gắn xương, tải động tác. Claude ghép vào game ([T-227](../tasks/T-227-protagonist-tripo-body-motions.md)).
> - Tải về `D:\GAME_DEMO\build\graphics\staging\protagonist\`, đặt tên theo bảng. Lượt sau thêm `_r2`, `_r3`; bản sửa thêm `_tex1`, `_brush1`.

## 1. Ngoại hình (chủ dự án chốt, D-137)
- Nam sinh viên **khoảng 20 tuổi**, cao **1,70 m**, **gầy vừa**.
- **Mặt bình thường, mệt mỏi:** tóc đen ngắn hơi rối, quầng thâm mắt, không đeo kính. Người chơi chỉ thấy rõ mặt trong gương.
- **Đồ ngủ:** áo phông xám cũ rộng (trơn, không chữ), quần đùi vải tối màu tới trên gối, **dép tổ ong** trắng ngà.

## 2. Cài đặt tạo
- Giống quản lý:
  - Tripo Studio, **Text to 3D**, model **H3.1**, Triangle;
  - Ultra mesh bật, texture **4K**, PBR bật, Remove lighting bật, Generate in parts tắt.
- Đứng **A-pose** (hai tay dang chéo xuống khoảng 45°, chân hơi tách), **tay không cầm gì**, để gắn xương được.
- Ô negative prompt (nếu có), dán chung:
  `text, letters, logo, print on shirt, watermark, holding object, phone in hand, T-pose with fists, floating parts, base platform, ground plane, cartoon, anime, stylized, toy, chibi, baked shadows, glasses`

## 2b. Cách tạo đã chọn: ảnh Gemini trước, rồi Tripo dựng từ ảnh (D-138)
- **Bước 1, ảnh trên Gemini:**
  - tạo ảnh chính diện bằng prompt dưới;
  - sửa đi sửa lại tới khi mặt, tóc, áo, quần, dép, tư thế chữ A đúng ý (rẻ hơn thử trên Tripo);
  - rồi hỏi tiếp trong cùng cuộc trò chuyện ảnh nhìn nghiêng trái và ảnh sau lưng.
- **Bước 2, Tripo:**
  - **Multiview to 3D** với ảnh trước, nghiêng, sau; không có thì **Image to 3D** với ảnh chính diện;
  - cài đặt như mục 2 (H3.1, Ultra mesh, 4K, PBR, Remove lighting);
  - prompt ở mục 3 dùng làm mô tả kèm (nếu ô có) và cho AI Texturing hoặc Magic Brush khi cần sửa.
- **Ảnh đạt khi:**
  - ảnh chụp kiểu studio, nền xám trơn, ánh sáng đều, không bóng gắt;
  - đủ người từ đầu tới dép, có khoảng trống quanh người;
  - camera ngang ngực, không chụp gần;
  - hai bàn tay mở rõ 5 ngón, không cầm gì;
  - không chữ; góc ảnh có logo hay hình mờ thì cắt bỏ.
- **Lưu bằng chứng (D-084):** để cùng thư mục `build/graphics/staging/protagonist/`:
  - các ảnh gốc Gemini: `trung_ref_front.png`, `trung_ref_left.png`, `trung_ref_back.png`;
  - một tệp `trung_ref_gemini.txt` ghi prompt đã dùng, ngày tạo, tên và phiên bản Gemini.

**Prompt ảnh chính diện:**
```text
Full-body character reference photo of a Vietnamese male university student, about 20 years old, 170 cm, average slim build, standing in a neutral A-pose facing the camera: arms straight and angled down about 45 degrees away from the body, open relaxed hands with five separated fingers, feet shoulder-width apart. Short black slightly messy hair, ordinary friendly face, tired expression, faint dark circles under the eyes, no glasses. Old loose plain light grey cotton t-shirt with no print, dark navy cotton shorts ending just above the knees, white Vietnamese honeycomb foam slippers on bare feet. Photorealistic studio photo, plain light grey seamless background, soft even front lighting, no harsh shadows, whole body in frame from head to toes with margin, camera at chest height, 50mm lens, no perspective distortion, no text, no logo, nothing in the hands.
```
**Ảnh nghiêng và sau lưng** (mỗi lần một ảnh, trong cùng cuộc trò chuyện):
```text
Same person, same clothes, same pose, same lighting and background, seen exactly from his left side.
```
```text
Same person, same clothes, same pose, same lighting and background, seen exactly from behind.
```
Điện thoại (mục 5) vẫn tạo thẳng trên Tripo bằng prompt chữ, vì đồ vật đơn giản không cần ảnh trước.

## 3. Thân Trần Trung: `trung_body.glb`

**Prompt:**
```text
Full body photorealistic 3D character of a Vietnamese male university student about 20 years old, standing in a relaxed A-pose with arms angled down 45 degrees away from the body, empty open hands, feet slightly apart. Average slim build, about 170 cm tall. Short black hair, slightly messy as if just woken up. Ordinary friendly face, tired expression, faint dark circles under the eyes, no glasses. Wearing an old loose plain light grey cotton t-shirt with no print, dark navy cotton shorts ending just above the knees, and white Vietnamese honeycomb foam slippers (dep to ong) on bare feet. Slightly wrinkled worn clothes. Realistic skin pores, realistic fabric folds, PBR.
```
**Texture** (dùng cho AI Texturing khi hình đúng mà màu hoặc da sai):
```text
Photorealistic young Asian skin with faint dark circles under the eyes, short messy black hair, plain light grey worn cotton t-shirt with soft wrinkles, dark navy cotton shorts, off-white honeycomb foam slippers, no text, no logo
```

**Kiểm trước khi tải:**
1. Mặt rõ, tự nhiên, không méo hay nhòe; không kính.
2. Đủ 5 ngón mỗi bàn tay, tay không dính vào hông, ngón chân và dép tách khỏi sàn (không có đế hay mặt đất dính dưới chân).
3. A-pose, không cầm gì.
4. Áo trơn, không chữ, không logo.
5. Quần áo không thủng, không có mảnh bay.

**Sửa:**

| Lỗi | Cách sửa |
|---|---|
| Mặt nhòe, méo hoặc già quá | Magic Brush vùng mặt: `sharp realistic young face, tired eyes, faint dark circles, no glasses` |
| Ngón tay dính hoặc thiếu | Magic Brush bàn tay: `five separate fingers, open relaxed hand` |
| Dép dính thành khối với sàn hoặc chân | Magic Brush bàn chân: `white honeycomb foam slippers on bare feet, separate toes` |
| Có chữ trên áo | Magic Brush ngực áo: `plain light grey cotton t-shirt, no print` |
| Hình sai hẳn | Tạo lại. Text to 3D làm mãi không đạt thì tạo ảnh ngay trong Tripo (nếu Studio có) bằng chính prompt trên, chọn ảnh **chính diện, A-pose, toàn thân**, rồi **Image to 3D**. Không dùng ảnh trên mạng (D-084) |

**Gắn xương (sau khi hình đạt):**
1. Nếu Studio có giảm lưới (Low Poly / Retopology / giới hạn mặt): giảm còn **khoảng 15.000–20.000 tam giác** trước khi gắn xương.
2. Dùng **Auto Rig** loại người (humanoid), loại **có xương ngón tay** (như quản lý). Xem thử một động tác mẫu: vai, khuỷu, đầu gối không gãy, áo không rách.
3. **Tải cả bản chưa gắn xương** `trung_body.glb`.
4. **Không cần tải** bản gắn xương không kèm động tác. Bài học từ quản lý: file đó dồn mọi xương về một điểm. Động tác tải ở mục 4 đã kèm xương.

## 4. Động tác (mục quan trọng nhất)
Chủ dự án muốn **đủ động tác như người bình thường**.
- Trong Tripo, mở thư viện động tác (Animation) của thân đã gắn xương.
- **Chụp màn hình cả danh sách động tác Tripo có**, để Claude chọn thêm.
- Với mỗi dòng dưới đây, chọn động tác **gần nhất** trong thư viện rồi tải GLB (có xương, có động tác) đúng tên file.
- Không có thì bỏ qua, ghi "không có". Claude làm bù bằng IK hoặc chuyển động CC0.

| Nhóm | File | Động tác cần | Dùng ở đâu |
|---|---|---|---|
| **1. Đi lại (bắt buộc)** | `trung_idle.glb` | đứng thở tự nhiên | mọi lúc |
| | `trung_walk.glb` | đi bộ thường | đi lại (2,2 m/s) |
| | `trung_run.glb` | chạy | chạy trốn (3,6 m/s) |
| | `trung_crouch_walk.glb` | đi khom hoặc đi lén | đi khi cúi (1,2 m/s) |
| | `trung_crouch_idle.glb` | ngồi xổm hoặc khom đứng yên | nấp, cúi |
| | `trung_turn_left.glb`, `trung_turn_right.glb` | xoay tại chỗ | quay người khi đứng |
| | `trung_walk_back.glb` | đi lùi | lùi lại khi sợ |
| | `trung_strafe_left.glb`, `trung_strafe_right.glb` | bước ngang | đi ngang |
| **2. Tay** | `trung_pickup.glb` | cúi nhặt đồ dưới thấp | nhặt giấy, đồ |
| | `trung_reach.glb` | với lấy đồ trước mặt hoặc trên cao | lấy đồ trên kệ, giường trên |
| | `trung_open_door.glb` | mở cửa, đẩy cửa | cửa 407, nhà tắm, ban công |
| | `trung_push.glb` | đẩy vật nặng hoặc huých vai | cửa nhà tắm bị kẹt (chương 2) |
| | `trung_phone_look.glb` | đứng nhìn điện thoại, nhắn tin | khung điện thoại |
| | `trung_look_around.glb` | nhìn quanh dò xét | đứng yên lâu |
| **3. Giường, nấp** | `trung_lie.glb` | nằm ngủ hoặc nằm im | nằm giường (luật chương 1) |
| | `trung_get_up.glb` | ngồi dậy hoặc đứng dậy | rời giường |
| | `trung_sit.glb` | ngồi ghế hoặc ngồi mép giường | ghế, giường dưới |
| | `trung_climb.glb` | leo thang hoặc trèo lên | giường tầng trên, cầu thang |
| | `trung_crawl.glb` | bò | chui dưới gầm (nếu có) |
| **4. Sợ hãi, chết** | `trung_scared.glb` | giật mình, lùi lại sợ hãi | jumpscare |
| | `trung_hit.glb` | trúng đòn, đau | bị chém hoặc cắn |
| | `trung_death.glb` | ngã ra chết | chết |
| | `trung_fall.glb` | ngã hoặc té | trượt, động đất (chương 4) |
| **5. Chương 3–4** | `trung_stairs_up.glb`, `trung_stairs_down.glb` | lên, xuống cầu thang | chạy khỏi tầng |
| | `trung_jump.glb` | nhảy | vượt chướng ngại |
| | `trung_swing.glb` | vung gậy hoặc vật bằng hai tay | thanh sắt đánh xác sống |
| | `trung_carry.glb` | cầm hoặc ôm đồ khi đi | mang khăn, giẻ (chương 2) |

## 5. Đồ đi kèm

| File | Prompt | Kiểm |
|---|---|---|
| `trung_phone.glb` | `A single thin budget Android smartphone, one flat rectangular slab with slightly rounded corners, very slim like a thin sheet of glass: 15 cm tall, 7 cm wide and only 8 mm thick, thickness about one twentieth of the height. Flat black glass screen covering the whole front with a thin black bezel and a small hairline crack in one top corner. Matte dark grey plastic back with light scuffs, one small round camera lens in the top corner. Thin straight side edges with two tiny buttons. Photorealistic, PBR, no case, no stand, no text, no logo` | Màn hình đen phẳng; nhìn nghiêng máy phải mỏng, dày khoảng 1/20 chiều cao; không chữ, không logo |

- Lượt 1 (23/10) ra máy dày, to; prompt trên là bản viết lại cho mỏng.
- Negative prompt (nếu có ô): `thick, bulky, chunky, brick, box, rugged case, phone case, flip phone, keypad, stand, base, holder, hand, cartoon, toy, text, logo`
- Kích thước thật trong Tripo không quan trọng, Claude chỉnh về 15 cm khi ghép. Nếu hình và màu đúng mà chỉ hơi dày, Claude ép mỏng lại trong Blender được.

Hiện điện thoại trên tay người chơi vẫn là khối hộp. Với tay thật cầm máy, nó sẽ lộ ra suốt.

## 6. Báo lại integrator
Báo theo mẫu:
- tên file đã tải và các dòng "không có";
- **ảnh chụp danh sách động tác Tripo**;
- lượt thứ mấy, đã sửa bằng gì;
- số credit trước và sau (nếu muốn ghi);
- mặt và dép có đạt chưa, theo ý anh/chị.

Claude chuẩn hóa thân, ghép động tác, thay thân tạm trong cảnh thử nhân vật chính. Sau đó Claude gửi ảnh và video để anh/chị duyệt trước khi đưa vào bản chơi ([T-227](../tasks/T-227-protagonist-tripo-body-motions.md)).
