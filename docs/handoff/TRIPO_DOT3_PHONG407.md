# Tripo đợt 3: đồ sinh hoạt cho phòng 407 bớt trống (D-100)

> Integrator (Claude, Opus 5.5), 14/10/2026.
> - Chủ dự án thấy phòng đủ đồ (D-096…D-099) còn hơi trống. Quyết định: **mức bừa vừa**, **làm đợt 3 Tripo trước G3** (D-100).
> - Người bấm tạo: **chủ dự án**. Integrator nướng bản nhẹ, đặt vào cảnh thử `room407_furnished_pilot.tscn`, chụp ảnh cho anh/chị duyệt rồi mới vào G3.
> - Cài đặt tạo, cách kiểm nhanh và cách sửa bằng AI Texturing / Magic Brush / Segmentation: **giữ nguyên mục 1–3 của [`TRIPO_DOT2_PHONG407.md`](TRIPO_DOT2_PHONG407.md)** (H3.1, Ultra mesh, polycount cao nhất, texture 4K, PBR, Remove lighting; không giới hạn lượt, D-095).
> - Tải GLB về **`D:\GAME_DEMO\build\graphics\staging\room407_batch3\`**, tên theo cột "File"; lượt sau thêm `_r2`, `_r3`.

## 1. "Bừa vừa" nghĩa là gì (để mọi món cùng một mức)
Phòng của 4 nam sinh đã ở vài tháng, chưa dọn trước kỳ thi, **không** phải phòng bỏ hoang:
- Mỗi người có 3–5 món cá nhân để lung tung quanh giường và bàn của mình.
- Sàn: đồ chỉ nằm **sát tường, gầm giường, cạnh bàn**. Lối đi rộng ≥ 1 m từ cửa tới từng giường, tới nhà tắm, tới ban công và tới các tủ, vì người chơi, quản lý và xác sống đều đi qua đó.
- Giữa phòng: một chiếu trải sàn và bàn gấp thấp có bát đũa của bữa khuya (đồ duy nhất ở giữa, không chắn lối).
- Có: một đống quần áo, một chậu đồ chưa giặt, một túi rác cạnh thùng rác, vài chai lon. Không có: rác ngập sàn, đồ ăn thối, đồ vỡ. Phần kinh dị (máu, vết chém, mảnh vụn) vẫn do code dựng theo cốt truyện.
- Trên giường chỉ có chăn, gối, quần áo vắt, vì giường là chỗ người chơi nằm (luật chương 1).

## 2. Món nào làm Tripo, món nào không
**Tripo (30 món, mục 4):** đồ rời có hình khối rõ. Nhà tắm được thêm đồ theo góp ý của chủ dự án (chậu, sữa tắm, xà phòng, khăn, cọ bồn cầu, giấy vệ sinh, nước giặt, dầu gội, lược, bàn chải, kem đánh răng).

**Integrator dựng bằng Blender / Godot (không cần anh/chị tạo):**
- Chiếu trải sàn giữa phòng: dùng lại vật liệu chiếu CC0 của nệm (Tripo làm đồ dài phẳng hay bị méo, như nệm đợt 2).
- Vết bẩn, ẩm mốc chân tường và góc trần, vệt nước trên trần, sơn bong, vết tay quanh công tắc và khung cửa, bụi bẩn ở mạch gạch sàn góc phòng: decal và texture CC0.
- Gạch men ốp tường nhà tắm, ga thoát nước sàn: texture CC0 + mesh Blender.
- Ống điện đi nổi trên tường: đường cong Blender.
- Đồ giấy có chữ: lịch treo tường, thời khóa biểu, giấy nhớ dán bàn/tủ. Integrator tự vẽ nội dung, không chữ nhãn hiệu.
- Rèm cửa ra ban công: mô phỏng vải Blender như mùng (D-098).
- Đồ đã có thì dùng lại thêm bản sao: ghế nhựa đỏ, dép, giày, khăn, balo (đợt 1), áo treo, mì gói, móc áo, sách (đợt 2).

## 3. Thứ tự làm
| Nhóm | Nội dung | Số món |
|---|---|---|
| **D** | Sàn, giữa phòng, gầm giường | 11 |
| **E** | Bàn, giường, tường | 7 |
| **F** | Nhà tắm, ban công | 12 |

Nên gửi theo nhóm (D trước), integrator nướng và đặt thử rồi mới làm nhóm sau, để sửa prompt sớm nếu cả nhóm cùng một kiểu lỗi.

### Nhóm D: sàn, giữa phòng, gầm giường
| # | Món | File | Số đo (rộng × cao × sâu, m) | Đặt ở |
|---|---|---|---|---|
| D1 | Bàn gấp thấp | `folding_table_r1.glb` | 0,70 × 0,30 × 0,50 | Giữa phòng, trên chiếu |
| D2 | Mâm bữa khuya | `meal_tray_r1.glb` | 0,40 × 0,10 × 0,40 | Trên bàn gấp |
| D3 | Nồi nhôm có quai | `pot_r1.glb` | 0,24 × 0,16 × 0,24 | Cạnh mâm |
| D4 | Bình nước 19 lít trên giá | `water_dispenser_r1.glb` | 0,30 × 0,75 × 0,30 | Góc cạnh bàn học chung |
| D5 | Chồng thùng các-tông | `cardboard_boxes_r1.glb` | 0,50 × 0,45 × 0,35 | Gầm giường, trên tủ |
| D6 | Vali | `suitcase_r1.glb` | 0,45 × 0,25 × 0,65 (nằm) | Gầm giường |
| D7 | Hộp nhựa có nắp | `storage_box_r1.glb` | 0,55 × 0,30 × 0,40 | Gầm giường |
| D8 | Chậu nhựa có quần áo | `basin_clothes_r1.glb` | Ø 0,50 × 0,20 | Cạnh cửa nhà tắm |
| D9 | Đống quần áo | `clothes_pile_r1.glb` | 0,60 × 0,25 × 0,50 | Chân giường B |
| D10 | Túi rác buộc miệng | `trash_bag_r1.glb` | 0,35 × 0,45 × 0,35 | Cạnh thùng rác |
| D11 | Chai lon rỗng | `bottles_cans_r1.glb` | cụm 0,40 × 0,25 × 0,30 | Cạnh bàn, góc tường |

### Nhóm E: bàn, giường, tường
| # | Món | File | Số đo | Đặt ở |
|---|---|---|---|---|
| E1 | Mũ bảo hiểm nửa đầu | `helmet_r1.glb` | 0,25 × 0,18 × 0,30 | 2 cái: trên tủ, móc cạnh cửa |
| E2 | Quả bóng đá cũ | `football_r1.glb` | Ø 0,22 | Gầm giường Phúc |
| E3 | Cốc cắm bút | `pen_cup_r1.glb` | Ø 0,08 × 0,12 | Bàn Đạt, bàn chung |
| E4 | Hộp xốp đồ ăn | `takeaway_box_r1.glb` | 0,20 × 0,07 × 0,15 | Bàn Việt |
| E5 | Áo khoác treo móc tường | `jacket_hook_r1.glb` | 0,50 × 0,80 × 0,15 | Tường cạnh cửa |
| E6 | Khăn vắt thành giường | `towel_draped_r1.glb` | 0,60 × 0,40 × 0,06 | Thành giường A, B |
| E7 | Mặt ổ cắm + công tắc âm tường | `wall_socket_r1.glb` | 0,12 × 0,12 × 0,03 | Cạnh cửa, cạnh bàn (chỉ vỏ; công tắc đèn và ổ mạng tương tác giữ node Godot) |

### Nhóm F: nhà tắm, ban công
| # | Món | File | Số đo | Đặt ở |
|---|---|---|---|---|
| F1 | Kệ góc nhà tắm có chai lọ | `bath_shelf_r1.glb` | 0,25 × 0,45 × 0,25 | Góc nhà tắm |
| F2 | Cốc bàn chải | `toothbrush_cup_r1.glb` | Ø 0,08 × 0,20 | Bồn rửa mặt |
| F3 | Gương nhỏ treo tường | `mirror_small_r1.glb` | 0,40 × 0,55 × 0,03 | Trên bồn rửa (mặt gương integrator gán vật liệu phản chiếu) |
| F4 | Cây lau nhà | `mop_r1.glb` | 0,30 × 1,25 × 0,25 | Dựng góc nhà tắm |
| F5 | Móc inox treo khăn | `towel_rack_r1.glb` | 0,45 × 0,35 × 0,10 | Tường nhà tắm |
| F6 | Giá phơi đồ gấp inox | `drying_rack_r1.glb` | 1,20 × 1,00 × 0,55 | Ban công |
| F7 | Chồng chậu nhựa + gáo | `bath_basins_r1.glb` | Ø 0,45 × 0,25 | Sàn nhà tắm cạnh vòi sen |
| F8 | Cọ bồn cầu có ống đựng | `toilet_brush_r1.glb` | Ø 0,12 × 0,40 | Cạnh bồn cầu |
| F9 | Giấy vệ sinh trên giá + cuộn dự phòng | `toilet_paper_r1.glb` | 0,15 × 0,15 × 0,12 | Tường cạnh bồn cầu |
| F10 | Can nước giặt + túi bột giặt | `laundry_detergent_r1.glb` | 0,30 × 0,30 × 0,15 | Sàn góc nhà tắm |
| F11 | Đồ cá nhân trên bồn rửa: lược, xà phòng bánh, dao cạo | `sink_toiletries_r1.glb` | 0,30 × 0,05 × 0,15 | Mép bồn rửa |
| F12 | Chai dầu gội, sữa tắm cỡ lớn | `shower_bottles_r1.glb` | 0,25 × 0,30 × 0,10 | Sàn hoặc bậu cạnh vòi sen |

Nhà tắm còn dùng lại: **xô nhựa** và **khăn** (đợt 1), **dép** (đợt 1). Ước lượng: **30 món** (D 11, E 7, F 12), số lượt tùy ý.

## 4. Prompt (dán nguyên đoạn)
Bối cảnh chung đã nằm trong mỗi prompt: ký túc xá sinh viên Việt Nam cũ, đồ rẻ tiền, dùng nhiều, ánh sáng do game lo. Món nào ra **có chữ hoặc logo** thì dùng Magic Brush `remove text, plain surface`.

### Nhóm D

**D1. Bàn gấp thấp** → `folding_table_r1.glb`
```text
Photorealistic low folding table used for eating on the floor in Vietnamese homes and dormitories, rectangular top about 70 by 50 cm, only 30 cm tall, thin wood-grain laminate top with a rolled metal edge, two pairs of folding steel legs painted dark brown, worn edges, scratches, a few sticky stains and cup rings. Legs unfolded, standing on the floor. Nothing on top. Single solid object. High detail, realistic materials, PBR.
```
Texture: `wood-grain laminate with worn lighter edges, scratches, faint sticky stains and cup rings, dark brown painted steel legs with chips`

**D2. Mâm bữa khuya** → `meal_tray_r1.glb`
```text
Photorealistic late-night student meal on a round aluminum tray about 40 cm wide: two white ceramic rice bowls, one with leftover instant noodles and broth, a small plate, two pairs of wooden chopsticks lying across the bowls, a stainless steel spoon, a small dipping sauce dish. Slightly messy, used, a few noodle strands on the tray. No text, no logo. Single object resting flat. High detail, realistic materials, PBR.
```
Texture: `dull scratched aluminum tray, white glazed ceramic with small chips, yellow noodles in light broth, light wooden chopsticks`

**D3. Nồi nhôm có quai** → `pot_r1.glb`
```text
Photorealistic small dented aluminum cooking pot with two side handles and a loose lid, about 24 cm wide and 16 cm tall, dull gray metal blackened on the bottom from a gas stove, small dents, water stains, a little grease on the rim. No text. Single object standing on a surface. High detail, realistic materials, PBR.
```
Texture: `dull dented aluminum, sooty black bottom, water spots, grease near the rim`

**D4. Bình nước 19 lít trên giá** → `water_dispenser_r1.glb`
```text
Photorealistic 19 liter blue plastic drinking water jug placed upside down on a simple cheap stand with a small push tap, total height about 75 cm, jug in pale translucent blue polycarbonate about two thirds full, stand made of white plastic with a drip tray, slightly yellowed and dusty. No text, no label, no logo. Single object standing on the floor. High detail, realistic materials, PBR.
```
Texture: `pale blue plastic jug, yellowed white plastic stand, water stains on the drip tray, dust`
Ghi chú: Tripo ra nhựa đục; integrator chỉnh vật liệu bình cho hơi trong trong Godot.

**D5. Chồng thùng các-tông** → `cardboard_boxes_r1.glb`
```text
Photorealistic stack of three plain brown corrugated cardboard boxes of different sizes, the biggest about 50 by 35 cm at the bottom, total height about 45 cm, closed with worn brown packing tape, crushed corners, dents and scuffs, one box slightly open at the top. No printing, no text, no logo. Single solid object resting on the floor. High detail, realistic materials, PBR.
```
Texture: `plain brown corrugated cardboard, worn tape, crushed corners, scuffs and dust`

**D6. Vali** → `suitcase_r1.glb`
```text
Photorealistic medium hard-shell travel suitcase lying flat on its back, about 65 cm long, 45 cm wide and 25 cm thick, dark navy blue ribbed plastic shell, telescopic handle retracted, carry handle on the side, four small wheels at one end, zipper around the middle. Scuffed and scratched, dust on top. No text, no logo, no tags. Single object. High detail, realistic materials, PBR.
```
Texture: `dark navy ribbed plastic with white scuff marks and scratches, black zipper, dust`

**D7. Hộp nhựa có nắp** → `storage_box_r1.glb`
```text
Photorealistic plastic storage box with a snap-on lid, about 55 by 40 cm and 30 cm tall, translucent milky white plastic body with a faded blue lid and side clip handles, folded clothes and a few items faintly visible inside, scratched, dusty lid. No text, no label. Single solid object resting on the floor. High detail, realistic materials, PBR.
```
Texture: `milky semi-transparent white plastic, faded blue lid, scratches, dust`

**D8. Chậu nhựa có quần áo** → `basin_clothes_r1.glb`
```text
Photorealistic round red plastic washing basin about 50 cm wide and 20 cm deep, filled with crumpled unwashed clothes: t-shirts, a pair of jeans and socks in muted colors, some clothes hanging over the rim. Basin slightly faded and scratched. No text, no logo. Single solid object resting on the floor. High detail, realistic materials, PBR.
```
Texture: `faded red plastic basin with scratches, crumpled cotton and denim clothes in gray, navy and white`

**D9. Đống quần áo** → `clothes_pile_r1.glb`
```text
Photorealistic messy pile of worn clothes dropped on the floor, about 60 by 50 cm and 25 cm high: a gray hoodie, two t-shirts, a pair of shorts and a towel tangled together, natural folds and creases. Muted everyday colors. No text, no prints, no logo. Single solid object resting on the floor, closed bottom. High detail, realistic fabric, PBR.
```
Texture: `worn cotton and fleece in gray, faded black, navy and white, creases and lint`

**D10. Túi rác buộc miệng** → `trash_bag_r1.glb`
```text
Photorealistic full black plastic garbage bag tied in a knot at the top, about 35 cm wide and 45 cm tall, bulging with irregular lumps from the trash inside, shiny thin plastic with wrinkles and stretched areas. Standing on the floor. No text. Single solid object. High detail, realistic materials, PBR.
```
Texture: `thin black plastic, glossy wrinkles, lighter stretched areas`

**D11. Chai lon rỗng** → `bottles_cans_r1.glb`
```text
Photorealistic small group of empty drink containers left on the floor: two crushed aluminum soda cans in plain colors, one empty clear plastic water bottle lying on its side, one standing plastic tea bottle with a little liquid left. Group about 40 by 30 cm. No text, no labels, no logo. Single object made of touching pieces. High detail, realistic materials, PBR.
```
Texture: `plain red and silver aluminum cans with dents, clear plastic bottles, light dust`
Nếu bản đầu có mảnh rời: thêm `all items touching each other, one connected group`.

### Nhóm E

**E1. Mũ bảo hiểm nửa đầu** → `helmet_r1.glb`
```text
Photorealistic cheap half-face motorbike helmet commonly worn in Vietnam, glossy plastic shell in faded dark red, short clear plastic visor flipped up, black chin strap with plastic buckle hanging down, foam lining visible inside. Scratched and scuffed shell. No text, no stickers, no logo. Single object resting on a surface. High detail, realistic materials, PBR.
```
Texture: `faded glossy dark red plastic with scratches and scuffs, black webbing strap, black foam lining`

**E2. Quả bóng đá cũ** → `football_r1.glb`
```text
Photorealistic old used soccer ball, standard size 22 cm, classic white and black pentagon panel pattern, stitched seams, scuffed and dirty with grass and mud stains, slightly soft. No text, no logo, no brand. Single object. High detail, realistic materials, PBR.
```
Texture: `scuffed white and black synthetic leather panels, mud and grass stains, worn seams`

**E3. Cốc cắm bút** → `pen_cup_r1.glb`
```text
Photorealistic old ceramic mug used as a pen holder, about 8 cm wide and 10 cm tall, plain cream glaze with a chipped rim and coffee stains, filled with a few ballpoint pens, a pencil, a ruler and a pair of scissors. No text, no logo. Single object standing on a desk. High detail, realistic materials, PBR.
```
Texture: `cream glazed ceramic with chips and brown stains, plain blue and black pens, yellow pencil, clear ruler`

**E4. Hộp xốp đồ ăn** → `takeaway_box_r1.glb`
```text
Photorealistic white styrofoam takeaway food box with a hinged lid half open, about 20 by 15 cm, leftover rice and a few pieces of food inside, plastic spoon in the box, a rubber band around it, slightly crushed corner. No text, no logo. Single object resting flat. High detail, realistic materials, PBR.
```
Texture: `white styrofoam with fine bead texture and grease spots, white rice, brown food bits`

**E5. Áo khoác treo móc tường** → `jacket_hook_r1.glb`
```text
Photorealistic plain dark green zip-up windbreaker jacket hanging by its collar loop from a small metal wall hook, sleeves hanging down, natural folds, slightly creased and worn, total height about 80 cm. The back of the object is flat for mounting on a wall. No text, no logo, no wall. Single object. High detail, realistic fabric, PBR.
```
Texture: `faded dark green nylon fabric with creases, black zipper, small steel hook`

**E6. Khăn vắt thành giường** → `towel_draped_r1.glb`
```text
Photorealistic cotton bath towel folded once and hanging over an invisible horizontal bar, both halves hanging down evenly, about 60 cm wide and 40 cm tall from the fold, soft terry cloth texture, faded light blue with a darker stripe near the ends, slightly damp creases. Towel only, no bar, no rail. Single object. High detail, realistic fabric, PBR.
```
Texture: `faded light blue terry cloth with a darker stripe, soft loops, damp creases`
Nếu Tripo vẽ kèm thanh sắt: integrator xóa thanh trong Blender, không cần tạo lại.

**E7. Mặt ổ cắm + công tắc âm tường** → `wall_socket_r1.glb`
```text
Photorealistic old wall plate with one rocker light switch and one two-pin electrical socket side by side as used in Vietnam, square off-white plastic plate about 12 by 12 cm and 2 cm thick, yellowed plastic, finger smudges and dirt around the switch, a small crack in one corner, visible screw heads. Flat back for mounting on a wall. No text, no logo. Single object. High detail, realistic materials, PBR.
```
Texture: `yellowed off-white plastic, gray finger smudges around the switch, dirt in the socket holes`

### Nhóm F

**F1. Kệ góc nhà tắm có chai lọ** → `bath_shelf_r1.glb`
```text
Photorealistic two-tier corner shower shelf made of white plastic, triangular shelves about 25 cm per side, total height 45 cm, holding a shampoo bottle, a shower gel bottle, a bar of soap in a dish and a plastic razor. Plain colored bottles without labels. Water stains, soap scum and slight mildew on the shelf. No text, no logo. Single object. High detail, realistic materials, PBR.
```
Texture: `white plastic with soap scum, water spots, faint mildew, plain blue and white bottles`

**F2. Cốc bàn chải** → `toothbrush_cup_r1.glb`
```text
Photorealistic plastic cup on a bathroom sink holding four toothbrushes in different colors and a squeezed toothpaste tube, cup about 8 cm wide and 10 cm tall, translucent light green plastic with white water stains, worn bristles. Plain tube without text. No logo. Single object standing on a surface. High detail, realistic materials, PBR.
```
Texture: `translucent light green plastic cup with limescale, colored toothbrush handles, white and blue toothpaste tube`

**F3. Gương nhỏ treo tường** → `mirror_small_r1.glb`
```text
Photorealistic small rectangular bathroom wall mirror about 40 by 55 cm with a thin plastic frame and a narrow shelf at the bottom, cheap and old, silvering damaged with dark spots near the edges, water splashes and toothpaste spots on the glass, frame slightly yellowed. Flat back for wall mounting. No text, no logo. Single object. High detail, realistic materials, PBR.
```
Texture: `yellowed white plastic frame, dark spots of damaged silvering at the edges, dried water splashes`

**F4. Cây lau nhà** → `mop_r1.glb`
```text
Photorealistic old cotton string mop leaning upright, metal handle about 1.2 m long with a faded blue plastic grip, gray dirty cotton strings hanging down at the bottom, still damp. No text, no logo. Single object. High detail, realistic materials, PBR.
```
Texture: `gray dirty cotton mop strings, scratched steel handle, faded blue plastic grip`

**F5. Móc inox treo khăn** → `towel_rack_r1.glb`
```text
Photorealistic stainless steel wall towel rack with a horizontal bar and four hooks below, about 45 cm wide, with one faded green towel hanging over the bar and a pair of shorts on a hook. Steel slightly rusty at the screws, water spots. Flat back for wall mounting. No text, no logo. Single object. High detail, realistic materials, PBR.
```
Texture: `brushed stainless steel with water spots and small rust at the screws, faded green terry towel, gray cotton shorts`

**F6. Giá phơi đồ gấp inox** → `drying_rack_r1.glb`
```text
Photorealistic foldable stainless steel clothes drying rack standing open on a balcony floor, about 1.2 m wide, 1 m tall and 55 cm deep, A-frame legs with plastic feet, several horizontal round bars of thick tubing, a few socks and a t-shirt hanging on it. Steel dull with water spots and slight rust at the joints. No text, no logo. Single object standing on the floor. High detail, realistic materials, PBR.
```
Texture: `dull stainless steel tubes with water spots and rust at joints, plain cotton clothes`
Nếu bản đầu thanh bị chảy/đứt (lỗi giống thanh vạt giường đợt 2): thêm `few thick bars, all tubes connected, solid sturdy frame`.

**F7. Chồng chậu nhựa + gáo** → `bath_basins_r1.glb`
```text
Photorealistic two round plastic washing basins stacked inside each other on a bathroom floor, the bigger one about 45 cm wide in faded pink, the smaller one in faded blue, a plastic water scoop with a long handle resting inside the top basin, a little water at the bottom. Scratched plastic with white limescale marks. No text, no logo. Single solid object. High detail, realistic materials, PBR.
```
Texture: `faded pink and blue plastic with scratches and white limescale, light green plastic scoop, wet shine at the bottom`

**F8. Cọ bồn cầu có ống đựng** → `toilet_brush_r1.glb`
```text
Photorealistic toilet brush standing in its round plastic holder on a bathroom floor, holder about 12 cm wide and 15 cm tall, total height 40 cm, white plastic handle, worn gray bristles, holder slightly dirty with water stains inside. No text, no logo. Single object. High detail, realistic materials, PBR.
```
Texture: `off-white plastic with water stains and grime, worn gray bristles`

**F9. Giấy vệ sinh trên giá + cuộn dự phòng** → `toilet_paper_r1.glb`
```text
Photorealistic simple wall-mounted toilet paper holder of chrome-plated steel with a half-used white toilet paper roll on it, a short piece of paper hanging down, and one spare roll sitting on top of the holder. Chrome slightly rusty at the screws, paper a little damp at the edge. Flat back for wall mounting. No text, no logo. Single object. High detail, realistic materials, PBR.
```
Texture: `chrome with water spots and small rust at the screws, soft white embossed toilet paper`

**F10. Can nước giặt + túi bột giặt** → `laundry_detergent_r1.glb`
```text
Photorealistic laundry supplies on a bathroom floor: a 3 liter plastic jug of liquid laundry detergent with a handle and a screw cap used as a measuring cup, plain light blue plastic, next to an opened plastic bag of washing powder folded over at the top with some white powder spilled beside it. Plain packaging, no text, no label, no logo. Single object made of touching pieces, resting on the floor. High detail, realistic materials, PBR.
```
Texture: `plain light blue plastic jug with drips, plain white and blue plastic bag, white powder, wet stains`

**F11. Đồ cá nhân trên bồn rửa** → `sink_toiletries_r1.glb`
```text
Photorealistic small group of personal grooming items lying together on the edge of a bathroom sink: a black plastic comb with a few hairs, a used bar of soap on a small plastic soap dish, a disposable plastic razor and a small tin of hair wax with the lid off. Group about 30 by 15 cm, slightly wet. No text, no logo. Single object made of touching pieces, resting flat. High detail, realistic materials, PBR.
```
Texture: `black plastic comb, worn white soap bar with cracks on a pale green dish, blue razor, brushed metal tin`

**F12. Chai dầu gội, sữa tắm cỡ lớn** → `shower_bottles_r1.glb`
```text
Photorealistic three large plastic bathroom bottles standing together on a wet floor: a pump bottle of shampoo, a pump bottle of shower gel and a squeeze bottle of conditioner, about 25 to 30 cm tall, plain colors white, dark blue and pale green, half used, wet drips and soap residue on the pumps. Plain bottles, no labels, no text, no logo. Single object made of touching pieces. High detail, realistic materials, PBR.
```
Texture: `glossy plain plastic in white, dark blue and pale green, soap drips and water spots on the pumps`

## 5. Báo lại cho integrator
Nhắn: `Đã tạo <mã món> (lượt n)` hoặc `xong nhóm D`. Integrator làm:
1. Lưu hash nguồn (`art_source/graphics_upgrade/tripo/room407_batch3/SHA256SUMS.txt`).
2. Nướng bản nhẹ bằng `bake_prop.py`: đồ nhỏ ≤ 5.000 tam giác, đồ lớn ≤ 8.000, 1 vật liệu, texture ≤ 2048.
3. Dựng phần Blender ở mục 2 (chiếu sàn, decal bẩn/ẩm, gạch nhà tắm, lịch, rèm).
4. Đặt vào cảnh thử theo mục 1 (lối đi ≥ 1 m), chụp ảnh trước/sau cho anh/chị duyệt.
5. Ghi phiếu dưới đây.

## Phiếu đợt 3 (integrator điền)
Chưa có món nào.
