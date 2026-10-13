# Tripo đợt 2: toàn bộ đồ phòng 407 (D-093)

> Integrator (Claude, Opus 5.5), 13/10/2026.
> - Chủ dự án duyệt hướng phòng; mọi đồ dùng trong phòng làm bằng Tripo (D-093).
> - Người bấm tạo: **chủ dự án**. Integrator chuẩn hóa bằng `art_source/graphics_upgrade/tripo/bake_prop.py` rồi đặt vào góc phòng làm thử. Bản chơi chưa đổi cho tới G3.
> - Đợt 1 (7 món + balo) đã xong: `TRIPO_DOT1_PHONG407.md`.

## 1. Cài đặt tạo (giữ như lượt 2 đợt 1, D-088)
- Tripo Studio, **Text to 3D**, model **H3.1**, Triangle.
- **Ultra mesh bật**, polycount **cao nhất**, texture **4K**, **PBR bật**, **Remove lighting bật**.
- **Generate in parts tắt**, trừ các món ghi "tách phần" ở bảng.
- Ô negative prompt (nếu có), dán chung cho mọi món:
  `text, letters, logo, brand, label, watermark, sticker, floating parts, disconnected pieces, baked shadows, base platform, ground plane, cartoon, toy, stylized`
- **Không giới hạn lượt** tạo hình hay sửa (D-095, thay trần 3 lượt của D-087): làm tới khi đẹp. Tải GLB về `D:\GAME_DEMO\build\graphics\staging\room407_batch2\`, đặt tên theo bảng; lượt sau thêm `_r2`, `_r3`.
- Kích thước và hướng không cần đúng; integrator khớp theo số đo cột "Đồ cũ".

## 2. Kiểm nhanh trên Tripo trước khi tải
Xoay quanh và kiểm năm điểm:
1. Có đáy kín.
2. Không chữ hoặc logo.
3. Không mảnh bay.
4. Đúng số chân, thanh, cánh.
5. Bề mặt có vết dùng (xước, bụi, ố), không trơn như đồ chơi.

Nếu hình đúng mà chỉ texture sai thì **đừng tạo lại hình**; sửa theo mục 3.

## 3. Chỉnh sửa bằng công cụ của Tripo (kết hợp với tạo)
Thứ tự ưu tiên, rẻ và giữ hình trước:

| Lỗi thấy | Công cụ Tripo | Cách làm |
|---|---|---|
| Texture phẳng, sai màu, quá sạch | **AI Texturing** (tạo lại texture, giữ hình) | Dán dòng **"Texture"** của món đó (có sẵn dưới mỗi prompt) |
| Một chỗ hỏng: chữ giả, vệt lạ, thiếu gỉ hoặc ố | **Magic Brush** | Tô vùng đó, gõ yêu cầu ngắn, ví dụ `remove text, plain painted metal` hoặc `add light rust and dust along edges` |
| Cần tách phần động (cánh cửa, cánh quạt, nắp) | **Segmentation** (tách phần) | Tách rồi tải GLB có các phần riêng. Nếu tách không sạch thì cứ tải bản liền; integrator cắt trong Blender |
| Hình sai hẳn (thiếu chân, méo, mảnh rời) | Tạo lại (lượt mới) | Dùng dòng **"Nếu bản đầu hỏng"** của món (nếu có) hoặc tạo lại |
| Text to 3D làm mãi không giống | **Image to 3D** / nhiều góc | Chỉ dùng **ảnh anh/chị tự chụp** đồ thật (điện thoại) hoặc ảnh tạo ngay trong Tripo. Không dùng ảnh mạng (D-084: nguồn đầu vào phải hợp lệ). Ghi rõ ảnh nào vào phiếu |

- Tạo hình và sửa không giới hạn số lần (D-095).
- Mỗi lần sửa, tải lại GLB với hậu tố `_tex1`, `_brush1`… để integrator biết bản nào mới nhất.

## 4. Món nào làm Tripo, món nào không
**Chủ dự án duyệt (D-095):** các món dưới đây không làm Tripo. Integrator dựng bằng Blender, **chân thật và cùng mức chi tiết với đồ Tripo**:
- vật liệu ảnh chụp CC0;
- vết dùng, bụi, ố;
- normal map;
- cùng ngân sách tam giác và texture như đồ Tripo.

Danh sách:
- **Lưới mùng.** Tripo ra lưới đục, không trong suốt. Integrator dựng lưới bằng mô phỏng vải và texture lưới có alpha. Riêng khung treo và dây buộc mùng thì có trong prompt giường.
- **Đồ phẳng có nội dung cốt truyện:**
  - giấy xé, thẻ của Phúc, sổ hợp âm, giấy dán trong tủ;
  - mặt ảnh đội bóng, ảnh gia đình;
  - poster.
  Chữ và hình là manh mối và phải đọc được, nên giữ node Godot hiện có. Tripo chỉ làm **khung ảnh trống**; integrator làm hình in trên poster (tránh logo câu lạc bộ thật).
- **Dây điện, dây phơi, cáp sạc** (dải dài và mảnh): dùng đường cong Blender.
- **Nệm và chăn bị rạch của Trung, vết máu, mảnh vụn.** Đây là hiệu ứng truyện do code dựng; integrator chỉ thay texture bằng vải của nệm/chăn Tripo.
- **Vỏ phòng, cửa, đèn tuýp:** giữ bản Blender của T-213 đã duyệt.
- **Xác nhân vật:** để đợt riêng, anh/chị quyết sau.

Phần tương tác giữ nguyên trong Godot. Đồ Tripo chỉ là vỏ nhìn thấy:
- công tắc bập bênh, đèn LED, số mờ trên ổ điện;
- bản lề cửa tủ Việt;
- nệm lật của Phúc;
- va chạm, chỗ nằm, View/Exit, Corpse.

## 5. Danh sách và thứ tự làm
Số đo lấy từ GLB và cảnh hiện hành (rộng × cao × sâu, m). Tên file tải về: cột "File".

### Nhóm A: đồ lớn (làm trước)
| # | Món | File | Đồ cũ / số đo | Ghi chú |
|---|---|---|---|---|
| A1 | Khung giường tầng sắt | `bunk_frame_r1.glb` | `kit/bunk_bed.glb`, `bunk_trung.glb` 0,90 × 1,70 × 2,00; mặt nằm y=0,43 / 1,20 | Một khung dùng cho cả giường A và B. **Không có nệm** |
| A2 | Nệm mỏng + chiếu | `mattress_r1.glb` | 0,80 × 0,05 × 1,90 | 4 tấm. Nệm Phúc lật lên được (pivot Godot) |
| A3 | Gối | `pillow_r1.glb` | khoảng 0,50 × 0,12 × 0,35 | 4 cái |
| A4 | Chăn gấp | `blanket_folded_r1.glb` | khoảng 0,70 × 0,15 × 0,40 | Đặt cuối giường |
| A5 | Chăn tung | `blanket_messy_r1.glb` | phủ khoảng 0,80 × 1,20 | Giường có người vừa dậy |
| A6 | Bàn học gỗ | `desk_r1.glb` | `props/desk.glb` 1,50 × 0,76 × 0,65 | 4 chỗ (bàn chung + 3 bàn ở phần mở rộng) |
| A7 | Tủ sắt đóng | `locker_closed_r1.glb` | `kit/locker.glb` 0,76 × 1,77 × 0,56 | Tủ Phúc, Đạt, Trung |
| A8 | Tủ sắt mở cửa | `locker_open_r1.glb` | `viet_locker` 0,60 × 1,70 × 0,45, 3 ngăn | Tủ Việt; **tách phần** cánh cửa |
| A9 | Quạt trần | `ceiling_fan_r1.glb` | `kit/ceiling_fan.glb` 1,02 × 0,56 × 1,18 | **Tách phần** cánh quạt (quay) |

### Nhóm B: đồ tường, kệ, phần mở rộng
| # | Món | File | Đồ cũ / số đo | Ghi chú |
|---|---|---|---|---|
| B1 | Kệ gỗ treo tường | `wall_shelf_r1.glb` | `Details/*/Shelf`, khoảng 0,60 × 0,02 × 0,20 | 3 kệ + kệ router |
| B2 | Kệ sách nhỏ | `bookshelf_r1.glb` | `Extension/Bookshelf` | Không xếp sách sẵn (sách là món C4) |
| B3 | Kệ giày 3 tầng | `shoe_rack_r1.glb` | tầng y=0,08 / 0,27 / 0,46 | |
| B4 | Quạt đứng | `standing_fan_r1.glb` | quạt cây ở phần mở rộng | **Tách phần** cánh |
| B5 | Bồn cầu | `toilet_r1.glb` | `ToiletBase` + `Seat` + `Cistern` | Giữ va chạm cũ |
| B6 | Bồn rửa mặt | `sink_r1.glb` | `props/sink.glb` | |
| B7 | Bộ vòi sen | `shower_r1.glb` | ống + bát sen + van trộn | |
| B8 | Gương soi dài | `mirror_full_r1.glb` | `FullMirror` | Mặt gương: integrator gán vật liệu phản chiếu |
| B9 | Chậu cây ban công | `plant_pot_r1.glb` | 2 chậu ở x=0,45 / 4,75 | |
| B10 | Áo phông treo móc | `shirt_hanging_r1.glb` | `props/shirt.glb` 0,66 × 0,78 × 0,05 | 3 cái trong phòng + 3 ở ban công |

### Nhóm C: đồ nhỏ
| # | Món | File | Đồ cũ / số đo | Ghi chú |
|---|---|---|---|---|
| C1 | Đèn bàn | `desk_lamp_r1.glb` | 0,21 × 0,36 × 0,25 | |
| C2 | Laptop cũ (mở) | `laptop_r1.glb` | 0,33 × 0,25 × 0,23 | Của Việt |
| C3 | Chồng sách giáo trình | `books_r1.glb` | 0,28 × 0,11 × 0,34 | Phúc, Đạt. Gáy sách trơn |
| C4 | Sách đứng trên kệ | `books_row_r1.glb` | 8 cuốn `Book0…7` | |
| C5 | Vở / sổ | `notebook_r1.glb` | 0,18 × 0,04 × 0,25 | Sổ Đạt; nội dung vẫn đọc từ node Godot |
| C6 | Tai nghe | `headphones_r1.glb` | 0,24 × 0,20 × 0,07 | |
| C7 | Mì gói (thùng/gói) | `noodles_r1.glb` | 0,17 × 0,15 × 0,14 | Không chữ hoặc nhãn hiệu |
| C8 | Router wifi | `router_r1.glb` | 0,20 × 0,23 × 0,12 | |
| C9 | Ổ điện kéo dài | `power_strip_r1.glb` | vỏ khoảng 0,30 × 0,05 × 0,06 | Chỉ vỏ; công tắc và LED giữ của Godot |
| C10 | Khung ảnh để bàn | `photo_frame_r1.glb` | 0,21 × 0,24 × 0,05 | Mặt ảnh trống; ảnh gia đình và ảnh đội bóng dán sau |
| C11 | Đàn guitar | `guitar_r1.glb` | 0,36 × 0,11 × 1,09 | Của Việt |
| C12 | Thùng rác | `trash_bin_r1.glb` | `ch1v2/trash_bin` | Rác bên trong và giấy manh mối giữ của Godot |
| C13 | Ấm siêu tốc | `kettle_r1.glb` | `Kettle` + quai + vòi | |
| C14 | Móc treo quần áo | `hanger_r1.glb` | | |
| C15 | Khung đèn bàn trực / đế đèn tuýp | | | Không làm (giữ Blender) |

Ước lượng: **nhóm A 9 món, B 10, C 14** (C15 bỏ), tổng **33 món**, số lượt tùy ý. Mỗi đợt nên làm khoảng 5 món, báo integrator nướng và đặt vào phòng rồi làm tiếp, để sửa prompt sớm nếu cả nhóm cùng một kiểu lỗi.

## 6. Prompt (dán nguyên đoạn)
Bối cảnh chung (đã nằm sẵn trong mỗi prompt, không cần dán thêm): ký túc xá sinh viên Việt Nam cũ, đồ rẻ tiền, dùng nhiều năm, ánh sáng sẽ do game lo.

### Nhóm A

**A1. Khung giường tầng sắt** → `bunk_frame_r1.glb`
```text
Photorealistic old steel bunk bed frame from a Vietnamese university dormitory, two sleeping levels, about 2 m long, 0.9 m wide and 1.7 m tall. Four vertical round steel tube posts, horizontal side rails and head and foot rails made of 25 mm round tubes, flat steel slat bed bases on both levels, a vertical steel ladder with four round rungs welded to one long side, a short safety rail along the upper level, small welded joints and visible bolt heads. Thick glossy green enamel paint, chipped on the edges and corners showing dark metal, light rust spots near the welds and at the feet, dusty. No mattress, no bedding, no mosquito net. Single solid object standing on the floor. High detail, realistic materials, PBR.
```
Texture: `chipped glossy green enamel paint on steel tubes, dark metal showing at worn edges, light orange rust near welds and feet, dust in corners`
Nếu bản đầu hỏng: bỏ câu thang, thêm `simple symmetrical frame, all tubes connected, no missing posts`.

**A2. Nệm mỏng + chiếu** → `mattress_r1.glb`
```text
Photorealistic thin foam mattress for a dormitory bunk bed, 190 cm long, 80 cm wide and 5 cm thick, covered with faded beige linen fabric with slightly rounded edges and a stitched seam around the border. A woven Vietnamese sedge sleeping mat (chieu) lies flat on top, covering almost the whole mattress, natural straw color with fine woven texture and a cloth edge binding, slightly worn in the middle where people sleep. Single object, flat, resting on a surface. High detail, realistic materials, PBR.
```
Texture: `faded beige linen cover, woven straw sedge mat with fine weave and darker cloth border, slight body wear and stains in the middle`

**A3. Gối** → `pillow_r1.glb`
```text
Photorealistic soft bed pillow for a student dormitory, about 50 by 35 cm and 12 cm thick, puffy in the middle with pinched corners, cotton pillowcase with a faded blue and white checked pattern, slightly creased and used, a little flattened where the head rests. Single object resting flat. High detail, realistic fabric, PBR.
```
Texture: `faded blue and white gingham cotton pillowcase, soft creases, slight yellowing and wear`

**A4. Chăn gấp** → `blanket_folded_r1.glb`
```text
Photorealistic thick fleece blanket folded into a neat rectangular stack at the foot of a bed, about 70 cm wide, 40 cm deep and 15 cm high, soft rounded folded edges, plush polar fleece texture, muted dark green with a small subtle pattern, slightly pilled and used. Single solid object resting flat, no loose flaps. High detail, realistic fabric, PBR.
```
Texture: `muted dark green polar fleece, soft plush fibers, slight pilling and lint`

**A5. Chăn tung** → `blanket_messy_r1.glb`
```text
Photorealistic thick fleece blanket thrown back and crumpled on a single bed mattress as if someone just got up, covering about 80 by 120 cm, deep natural folds and wrinkles, one corner turned over, plush polar fleece texture, muted dark red with a faint pattern, used and slightly pilled. The blanket shape only, lying on an invisible flat surface, no bed, no mattress. High detail, realistic fabric, PBR.
```
Texture: `muted dark red polar fleece, plush fibers, pilling, slightly faded on the folds`

**A6. Bàn học gỗ** → `desk_r1.glb`
```text
Photorealistic old wooden study desk from a Vietnamese dormitory, 150 cm wide, 65 cm deep and 76 cm tall, flat laminated wood top with worn edges and a few scratches and pen marks, a front modesty panel, one drawer under the top on the right side with a simple metal pull handle, four square steel tube legs painted dark gray, light dust. No objects on the desk. Single solid object standing on the floor. High detail, realistic materials, PBR.
```
Texture: `medium brown wood grain laminate, worn and lighter at the front edge, scratches, faded pen marks, dark gray painted steel legs with chips`

**A7. Tủ sắt đóng** → `locker_closed_r1.glb`
```text
Photorealistic tall single-door steel locker cabinet from a Vietnamese university dormitory, about 76 cm wide, 177 cm tall and 56 cm deep, flat front door with a vertical recessed handle and a small hasp for a padlock, rows of stamped ventilation slots near the top and bottom of the door, folded sheet-metal edges, short feet. Powder-coated light gray-blue paint, dented in a few places, scratched near the handle, faint rust at the bottom edge, dusty top. Door closed. No text, no stickers. Single solid object standing on the floor. High detail, realistic materials, PBR.
```
Texture: `light gray-blue powder-coated steel, scratches around the handle, small dents, faint rust along the bottom edge, dust on top`

**A8. Tủ sắt mở cửa (tủ Việt)** → `locker_open_r1.glb`. Tách phần: bật **Segmentation** để tách cánh cửa
```text
Photorealistic tall single-door steel locker cabinet from a Vietnamese dormitory, about 60 cm wide, 170 cm tall and 45 cm deep, the door swung fully open at 90 degrees on its hinges, showing an empty interior with two flat steel shelves dividing it into three compartments and a hanging rail at the top. Door has stamped ventilation slots and a recessed handle. Powder-coated light gray-blue paint, scratched and slightly dented, faint rust at the bottom, dusty interior. No clothes, no objects, no text. Single object standing on the floor. High detail, realistic materials, PBR.
```
Texture: như A7 để hai tủ cùng màu.

**A9. Quạt trần** → `ceiling_fan_r1.glb`. Tách phần: bật **Segmentation** để tách cụm cánh
```text
Photorealistic old ceiling fan common in Vietnamese homes and dormitories, three long flat metal blades about 1 m total span, round motor housing in off-white painted metal, a short downrod to a ceiling canopy at the top, simple blade brackets. Paint slightly yellowed, dust and grime along the leading edge of each blade, small rust spots on the screws. No text, no logo. Single object, hanging orientation with canopy at the top. High detail, realistic materials, PBR.
```
Texture: `yellowed off-white painted metal, gray dust buildup along blade edges, small rust spots on screws`

### Nhóm B

**B1. Kệ gỗ treo tường** → `wall_shelf_r1.glb`
```text
Photorealistic simple wooden wall shelf, a single plank about 60 cm long, 20 cm deep and 2 cm thick, supported underneath by two black metal L brackets with visible screws, worn light wood with scratches and a few cup rings. Empty shelf. Single object. High detail, realistic materials, PBR.
```

**B2. Kệ sách nhỏ** → `bookshelf_r1.glb`
```text
Photorealistic small cheap bookshelf made of particle board with light wood veneer, about 60 cm wide, 90 cm tall and 28 cm deep, three open shelves, back panel of thin fiberboard, chipped veneer on the edges and slightly sagging middle shelf. Empty, no books. Single object standing on the floor. High detail, realistic materials, PBR.
```

**B3. Kệ giày 3 tầng** → `shoe_rack_r1.glb`
```text
Photorealistic cheap three-tier shoe rack, about 60 cm wide, 50 cm tall and 25 cm deep, thin chrome-plated steel tube frame with slightly angled shelves made of parallel metal rods, black plastic corner connectors, chrome partly dull and spotted with rust, dusty. Empty. Single object standing on the floor. High detail, realistic materials, PBR.
```

**B4. Quạt đứng** → `standing_fan_r1.glb`. Tách phần: bật **Segmentation** để tách cánh
```text
Photorealistic old electric standing pedestal fan common in Vietnam, round heavy base, adjustable vertical pole about 1.2 m tall, round wire safety guard in front of three translucent pale blue plastic blades, motor housing at the back, small control knob on the base. Off-white plastic slightly yellowed, dust on the guard and blades. No text, no logo. Single object standing on the floor. High detail, realistic materials, PBR.
```

**B5. Bồn cầu** → `toilet_r1.glb`
```text
Photorealistic old white ceramic western-style toilet in a cheap dormitory bathroom, toilet bowl with a plastic seat and lid closed, a separate ceramic cistern tank on the back with a push button on top, slightly yellowed glaze, limescale and grime stains near the base and the water line. No text. Single object standing on the floor. High detail, realistic materials, PBR.
```

**B6. Bồn rửa mặt** → `sink_r1.glb`
```text
Photorealistic small wall-mounted white ceramic wash basin from an old dormitory bathroom, about 45 cm wide, single chrome tap on top with a lever handle, exposed chrome drain pipe underneath going to the wall, limescale around the tap, water stains and slight yellowing. No text. Single object. High detail, realistic materials, PBR.
```

**B7. Bộ vòi sen** → `shower_r1.glb`
```text
Photorealistic simple wall-mounted shower set from a cheap Vietnamese bathroom: a wall mixer valve with one lever, a vertical chrome slide rail about 70 cm tall, a handheld shower head on a metal hose resting in its holder. Chrome partly dull with limescale spots and water stains. No text. Single object, flat back mounted to a wall. High detail, realistic materials, PBR.
```

**B8. Gương soi dài** → `mirror_full_r1.glb`
```text
Photorealistic tall full-length mirror for a dorm room, about 35 cm wide and 120 cm tall, thin black plastic frame, leaning style with a small fold-out stand at the back, plain flat mirror surface, frame scratched and dusty. No text. Single object. High detail, realistic materials, PBR.
```

**B9. Chậu cây ban công** → `plant_pot_r1.glb`
```text
Photorealistic small potted plant on a dormitory balcony: a cracked terracotta pot about 25 cm tall with a slightly neglected leafy green plant like a pothos or small aloe, some yellowing leaves, dry soil, dirt stains on the pot. Single object. High detail, realistic materials, PBR.
```

**B10. Áo phông treo móc** → `shirt_hanging_r1.glb`
```text
Photorealistic plain cotton t-shirt hanging on a simple plastic clothes hanger, natural vertical folds and slight wrinkles from drying, faded light gray color, no print, no text. Shirt and hanger only, hanger hook at the top. Single object. High detail, realistic fabric, PBR.
```
Texture: game có thể tô màu từng áo, nên giữ xám nhạt.

### Nhóm C

**C1. Đèn bàn** → `desk_lamp_r1.glb`
```text
Photorealistic cheap student desk lamp, round weighted base, flexible gooseneck arm about 30 cm, small conical metal shade, a rocker switch on the base and a short power cord stub. Matte black paint slightly scratched, dusty base. No text, no logo. Single object. High detail, realistic materials, PBR.
```

**C2. Laptop cũ** → `laptop_r1.glb`
```text
Photorealistic old budget laptop, opened at about 110 degrees, 33 cm wide, dark gray plastic body with worn palm rests and shiny keys, screen dark and off, a few scratches on the lid edges, small sticker residue marks. No logo, no text on keys or body. Single object resting on a surface. High detail, realistic materials, PBR.
```

**C3. Chồng sách giáo trình** → `books_r1.glb`
```text
Photorealistic stack of four thick university textbooks lying flat, slightly misaligned, plain colored covers in faded blue, red and beige, worn corners, page edges yellowed, no readable text on covers or spines. Single object resting on a surface. High detail, realistic materials, PBR.
```

**C4. Sách đứng trên kệ** → `books_row_r1.glb`
```text
Photorealistic row of eight used books and notebooks standing upright side by side, different heights and thicknesses, plain faded covers in muted colors, one slightly leaning, worn spines with no readable text. Single object resting on a surface. High detail, realistic materials, PBR.
```

**C5. Vở / sổ** → `notebook_r1.glb`
```text
Photorealistic closed spiral-bound student notebook, about 18 by 25 cm and 1.5 cm thick, plain dark blue cardboard cover with bent corners, slightly wavy pages from humidity. No text, no printed design. Single object lying flat. High detail, realistic materials, PBR.
```

**C6. Tai nghe** → `headphones_r1.glb`
```text
Photorealistic cheap over-ear headphones lying on a desk, black plastic headband with worn padding, two round ear cups with faux leather cushions slightly peeling, a short coiled cable stub. No logo, no text. Single object. High detail, realistic materials, PBR.
```

**C7. Mì gói** → `noodles_r1.glb`
```text
Photorealistic small open cardboard box holding a pile of instant noodle packets, about 17 by 15 by 14 cm, the packets have plain colored plastic wrappers in red and yellow with crinkles, no readable text, no brand. Single object resting on a surface. High detail, realistic materials, PBR.
```

**C8. Router wifi** → `router_r1.glb`
```text
Photorealistic cheap home wifi router, flat white plastic box about 20 by 12 cm with two black antennas standing up at a slight angle, a row of small indicator lights on the front edge, ventilation slots on top, yellowed and dusty plastic. No logo, no text. Single object. High detail, realistic materials, PBR.
```

**C9. Ổ điện kéo dài** → `power_strip_r1.glb`
```text
Photorealistic cheap Vietnamese extension power strip, long white plastic body about 30 by 6 by 5 cm with three sockets in a row, each socket with its own small rocker switch beside it, the plastic yellowed, scorched brown near one socket, dirty and scratched. Short cut cable stub at one end. No text, no logo. Single object resting on the floor. High detail, realistic materials, PBR.
```
Ghi chú: integrator bỏ công tắc của Tripo và gắn công tắc, LED Godot đúng chỗ cũ.

**C10. Khung ảnh để bàn** → `photo_frame_r1.glb`
```text
Photorealistic small wooden standing picture frame, about 21 by 24 cm, simple dark brown wood border with worn corners, a fold-out stand at the back, the photo area is a plain flat blank light gray surface behind glass. No picture, no text. Single object standing upright. High detail, realistic materials, PBR.
```

**C11. Đàn guitar** → `guitar_r1.glb`
```text
Photorealistic used acoustic guitar, natural spruce top with a dark rosewood fingerboard, six metal strings, black pickguard, tuning pegs on the headstock, scratches around the sound hole and worn finish on the body edge, slight dust. No logo, no text. Single object. High detail, realistic materials, PBR.
```

**C12. Thùng rác** → `trash_bin_r1.glb`
```text
Photorealistic cheap round plastic waste basket for a dorm room, about 25 cm diameter and 30 cm tall, open top, sides made of vertical slats with gaps, faded dark gray plastic with scuffs and grime. Empty inside. No text. Single object standing on the floor. High detail, realistic materials, PBR.
```

**C13. Ấm siêu tốc** → `kettle_r1.glb`
```text
Photorealistic cheap electric kettle on its round power base, stainless steel body with a black plastic handle, lid and spout, about 22 cm tall, limescale stains near the spout, fingerprints and small dents on the steel. No text, no logo. Single object. High detail, realistic materials, PBR.
```

**C14. Móc treo quần áo** → `hanger_r1.glb`
```text
Photorealistic simple plastic clothes hanger, about 40 cm wide, curved shoulders, a metal hook at the top, faded pastel blue plastic with small scratches. Single object. High detail, realistic materials, PBR.
```

## 7. Báo lại cho integrator
Nhắn: `Đã tạo <mã món> (lượt n), file ở build/graphics/staging/room407_batch2/...`. Có thể gửi nhiều món một lần. Integrator làm:
1. Lưu hash nguồn.
2. Nướng bản nhẹ: đồ nhỏ ≤ 5.000 tam giác, đồ lớn ≤ 8.000 (D-088); ≤ 2 vật liệu; texture ≤ 2048.
3. Khớp số đo cột "Đồ cũ".
4. Đặt vào góc phòng làm thử và chụp ảnh trước/sau cho anh/chị duyệt.
5. Ghi phiếu dưới đây.

Credit không cần theo dõi chặt (12/10). Chỉ ghi nếu anh/chị báo.

## Phiếu đợt 2 (integrator điền)

Ngày 13/10/2026, chủ dự án tạo đủ 33 món lượt 1 rồi tạo lại 4 món (khung giường, nệm, chăn tung, bàn). Integrator kiểm từng bản gốc (ảnh `art_source/graphics_upgrade/tripo/room407_batch2/previews/`), nướng bằng `bake_batch2.py` theo `bake_spec.json` (mọi món xoay 180° vì Tripo quay mặt trước về +Z; bàn r2 xoay −90°). Hash nguồn: `SHA256SUMS.txt`. Credit không theo dõi (D-095).

| Món | Lượt / sửa | File | Bản game (tam giác, texture) | Kết quả |
|---|---|---|---|---|
| A1 bunk_frame | r2 | `bunk_frame.glb` | ≤ 8.000, 2048 | r1 thanh vạt chảy ngay trong bản gốc → r2 ván ép; giữ cạnh sắc 40°; co chiều đứng để ván ở 0,38 / 1,15 m |
| A5 blanket_messy | r2 | `blanket_messy.glb` | ≤ 8.000, 2048 | r1 kèm nệm, gần vuông → r2 |
| A3 pillow | r1 | `pillow.glb` | ≤ 5.000, 1024 | Đạt |
| A4 blanket_folded | r1 | `blanket_folded.glb` | ≤ 5.000, 1024 | File `fleece blanket 3d model.glb` |
| A6 desk | r2 | `desk.glb` | ≤ 8.000, 2048 | r1 chỉ rộng 1 m → r2 dài, 2 ngăn kéo |
| A7 locker_closed | r1 | `locker_closed.glb` | ≤ 8.000, 2048 | Đạt |
| A8 locker_open | r1 | `locker_open.glb` | ≤ 8.000, 2048 | Tủ 2 cánh, 1 cánh mở; cánh chưa tách (cắt ở G3 cho tủ Việt) |
| A9 ceiling_fan | r1 | `ceiling_fan.glb` | ≤ 8.000, 2048 | 4 cánh liền khối; tách cánh quay ở G3 |
| B1 wall_shelf | r1 | `wall_shelf.glb` | ≤ 5.000, 1024 | Đạt |
| B2 bookshelf | r1 | `bookshelf.glb` | ≤ 8.000, 2048 | Đạt |
| B3 shoe_rack | r1 | `shoe_rack.glb` | ≤ 8.000, 1024 | Đạt |
| B4 standing_fan | r1 | `standing_fan.glb` | ≤ 8.000, 2048 | Cánh liền khối |
| B5 toilet | r1 | `toilet.glb` | ≤ 8.000, 2048 | Đạt |
| B6 sink | r1 | `sink.glb` | ≤ 5.000, 1024 | Đạt |
| B7 shower | r1 | `shower.glb` | ≤ 5.000, 1024 | Đạt |
| B8 mirror_full | r1 | `mirror_full.glb` | ≤ 5.000, 1024 | Đạt |
| B9 plant_pot | r1 | `plant_pot.glb` | ≤ 5.000, 1024 | Đạt |
| B10 shirt_hanging | r1 | `shirt_hanging.glb` | ≤ 5.000, 1024 | Đạt |
| C1 desk_lamp | r1 | `desk_lamp.glb` | ≤ 5.000, 1024 | Đạt |
| C2 laptop | r1 | `laptop.glb` | ≤ 5.000, 1024 | Đạt |
| C3 books | r1 | `books.glb` | ≤ 5.000, 1024 | Đạt |
| C4 books_row | r1 | `books_row.glb` | ≤ 5.000, 1024 | Đạt |
| C5 notebook | r1 | `notebook.glb` | ≤ 5.000, 1024 | Đạt |
| C6 headphones | r1 | `headphones.glb` | ≤ 5.000, 1024 | Đạt |
| C7 noodles | r1 | `noodles.glb` | ≤ 5.000, 1024 | Đạt |
| C8 router | r1 | `router.glb` | ≤ 5.000, 1024 | Đạt |
| C9 power_strip | r1 | `power_strip.glb` | ≤ 5.000, 1024 | Đạt |
| C10 photo_frame | r1 | `photo_frame.glb` | ≤ 5.000, 1024 | Đạt |
| C11 guitar | r1 | `guitar.glb` | ≤ 5.000, 1024 | Đạt |
| C12 trash_bin | r1 | `trash_bin.glb` | ≤ 5.000, 1024 | Đạt |
| C13 kettle | r1 | `kettle.glb` | ≤ 5.000, 1024 | Đạt |
| C14 hanger | r1 | `hanger.glb` | ≤ 5.000, 1024 | Đạt |
| A2 mattress | r1, r2 | — | — | **Không dùng** (tỉ lệ gần vuông, dày); chủ dự án chọn nệm + chiếu Blender (D-095 cách a): `game/assets/models/graphics_pilot/room407_furnished/bunk_mattress.glb`, 142 tam giác |

Đặt cả phòng: `game/scenes/levels/graphics_pilot/room407_furnished_pilot.tscn` (D-096), 19 ảnh ở `art_source/graphics_upgrade/room407_furnished/previews/`.
