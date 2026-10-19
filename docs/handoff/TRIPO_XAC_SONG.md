# Tripo: xác sống, các mẫu gốc (T-221, D-122)

> Integrator (Claude, Opus 5.5), 19/10/2026.
> - **Người bấm tạo:** chủ dự án. Không giới hạn lượt (D-095); credit chỉ ghi khi chủ dự án báo.
> - **Cách làm (D-122):** chủ dự án tạo vài mẫu gốc trên Tripo. Claude theo đúng kiểu đó làm ra đủ 10 dạng xác sống cho chương 3–4 (mục 6).
> - **Thư mục tải về:** `D:\GAME_DEMO\build\graphics\staging\zombie\`, đặt tên theo bảng. Lượt sau thêm `_r2`, `_r3`; bản sửa thêm `_tex1`, `_brush1`.
> - **Làm m1 trước rồi báo integrator.** Claude chạy thử cả quy trình trên m1 (đóng gói, mắt đỏ, 2–3 biến thể, ảnh trong game). Anh/chị duyệt xong mới làm m2–m4.

## 1. Kiểu xác sống (chủ dự án chốt kiểu A, D-122)
**Xác vừa chết:** cả trường chết trong đêm, mới vài giờ (thiết kế chương 3: xác đứng dậy, mắt đỏ, đi chậm).
- **Da:** xám tái; mảng tím bầm dưới da; môi thâm tím; quầng mắt thâm.
- **Mắt:** đỏ ngầu. Claude sẽ tô lại mắt đỏ phát sáng nhẹ như mắt quản lý, nên mắt chưa đẹp thì không cần tạo lại.
- **Máu:** khô, sẫm, ở miệng, mũi, vết thương.
- **Không** thối rữa, không lộ thịt hay xương, không mất tay chân.
- **Quần áo:** đồ mặc ngủ ở ký túc xá ban đêm, nhàu, dính máu và bụi; chân trần hoặc đi dép.
- **Người:** sinh viên Việt Nam 18–22 tuổi.

## 2. Các bước trên Tripo (giống lần làm quản lý)
1. **Tạo ảnh mẫu** (mục Image):
   - model **Nano Banana**, khung **3:4**, dán prompt ở mục 3;
   - chọn ảnh chính diện, thấy **toàn thân từ đầu tới chân**, A-pose, tay không cầm gì, đủ 5 ngón, mặt rõ;
   - lưu thành `zombie_<mẫu>_ref.png`.
2. **Image to 3D** từ ảnh đó: model **H3.1**, **HD** như quản lý. Tải `zombie_<mẫu>_body.glb`.
3. **Retopo** khoảng **6.000–8.000 tam giác**.
   - Lý do: chương 3 có tới khoảng 40 xác sống cùng lúc, nên phải thấp hơn quản lý (18.000).
   - Không chỉnh được đúng số: chọn mức thấp nhất mà mặt vẫn rõ, rồi báo số tam giác.
4. **Auto Rig:** Humanoid, khung xương kiểu **Mixamo**, **có xương ngón tay** (như quản lý).
5. **Animate:** mỗi động tác xuất **một file GLB**, bật **Export Skeleton**, **Number of Animations ≥ 1**.
   - **Mọi mẫu:** `idle` (**bắt buộc**, Claude dùng file này làm gốc) và `walk`.
   - **Riêng m1:** thêm **mọi preset trông giống xác sống** mà Tripo có, đặt tên theo tên preset:
     - đi chậm hoặc đi lê, loạng choạng;
     - ngã hoặc gục xuống, đứng dậy;
     - vồ hoặc tấn công bằng tay;
     - ngồi, nằm, bò.
   - Động tác Tripo không có thì Claude lấy từ bộ CC0 rồi chỉnh tay (D-121 cách c). Mọi mẫu dùng chung một bộ động tác.
6. Không cần tạo đồ đi kèm.

## 3. Các mẫu gốc (Claude đề xuất, chủ dự án sửa được)
- **m1–m3 là 3 bạn cùng phòng** (Phúc, Việt, Đạt), nhóm xác sống đầu tiên trong chương 3 (`zombie_01`–`03`). Sau này xác của họ ở chương 1–2 cũng dùng chung mô hình này.
- **m4 là một nữ sinh phòng khác**, để Claude làm thêm các dạng nữ.
- **Vết thương của 3 bạn cùng phòng:** vết chém dao phay của quản lý.
- **Phúc và Đạt** là "anh em cây khế", cùng đá đội bóng khoa (ảnh đội bóng trong phòng 407). Áo đội để **trơn, không số, không chữ**.

Dán phần **chung** trước, rồi dán prompt của từng mẫu ngay sau.

**Chung (dán đầu mỗi prompt):**
```text
Full body photorealistic 3D character, front view, standing in a relaxed A-pose with arms angled down 45 degrees away from the body, empty open hands with five separate fingers, feet slightly apart, whole body visible from head to toe, plain neutral grey background, even soft lighting. A Vietnamese university student who died a few hours ago and has risen as a fresh corpse: pale greyish skin with faint purple livor mortis blotches, dark bluish lips, dark circles under bloodshot red eyes, dried dark blood, no rot, no exposed bone, realistic skin pores, realistic fabric folds, PBR.
```

| Mẫu | File (tiền tố) | Prompt riêng (dán sau phần chung) |
|---|---|---|
| m1 Phúc | `zombie_m1_` | `Male, about 20 years old, athletic football player build, short black hair messy with dried blood. Plain red short-sleeve football jersey with white trim and no numbers or text, black football shorts, barefoot. Deep diagonal cleaver cut across the left shoulder and collarbone, dried blood soaked down the jersey.` |
| m2 Việt | `zombie_m2_` | `Male, about 20 years old, thin and slightly short, untidy black hair with a long fringe. Faded grey crew-neck T-shirt and blue-and-white checkered pajama trousers, bare feet. Cleaver cut on the side of the neck, dried blood running down the chest and one arm.` |
| m3 Đạt | `zombie_m3_` | `Male, about 21 years old, tall and broad, buzz-cut black hair. White sleeveless tank top and black sports shorts, cheap rubber flip-flops. Cleaver wound on the forehead with dried blood down the face, blood splattered across the tank top.` |
| m4 nữ | `zombie_m4_` | `Female, about 19 years old, long black hair in a loose low ponytail with strands across the face. Modest light pink cotton pajama set with a small flower print, short-sleeve top and long trousers, barefoot. Dried blood from the nose and mouth down the chin and collar, scratches on the forearms.` |

**Negative prompt** (nếu có ô này, dán chung cho mọi mẫu):
```text
text, letters, numbers, logo, watermark, holding object, T-pose, floating parts, base platform, ground plane, cartoon, anime, stylized, toy, chibi, baked shadows, rotting flesh, exposed bone, missing limbs, gore splatter on background
```

**Texture** (dùng cho AI Texturing khi hình đúng mà da hoặc màu sai):
```text
Photorealistic pale greyish dead skin with faint purple blotches, dark bluish lips, dried dark blood, wrinkled cotton sleepwear with blood and dust stains, no text
```

## 4. Kiểm trước khi tải
1. Mặt rõ, da xám tái, có máu khô, **không thối rữa** (kiểu A).
2. Đủ 5 ngón mỗi bàn tay, tay không dính vào hông.
3. A-pose, không cầm gì.
4. Không chữ, số hay logo trên áo.
5. Quần áo không thủng, không mảnh bay; tóc không dính thành khối lạ.

**Sửa:**

| Lỗi | Cách sửa |
|---|---|
| Mặt nhòe | Magic Brush vùng mặt: `sharp realistic face, pale greyish dead skin, dark bluish lips, dried blood` |
| Ngón tay dính hoặc thiếu | Magic Brush bàn tay: `five separate fingers, open relaxed hand` |
| Thành thối rữa, quá ghê | Tạo ảnh lại, thêm vào cuối prompt: `fresh corpse, intact skin` |
| Áo có chữ hoặc số | AI Texturing với prompt texture ở trên |

## 5. Báo lại integrator
- Tên file, lượt thứ mấy, đã sửa bằng gì.
- Số tam giác sau Retopo.
- Có những preset động tác nào (riêng m1).
- Link từng bước (tạo ảnh, 3D, gắn xương): ghi vào `build/graphics/staging/zombie/ghi_chu.txt`.
- Mặt đạt chưa, theo ý anh/chị.

## 6. Claude làm từ các mẫu (T-221)
- **Đóng gói** giống quản lý:
  - texture 1024;
  - bỏ trôi hông;
  - **mắt đỏ phát sáng nhẹ** (tô lại texture và thêm lớp phát sáng).
- **Động tác dùng chung** cho mọi mẫu, đủ bộ chương 3 cần: đứng, đi, gục khi bị đập, vồ, ngồi, nằm, đứng dậy.
- **10 dạng** `zombie_01`–`10`:
  - 01–03 là Phúc, Việt, Đạt;
  - 04–10 làm từ các mẫu: đổi màu áo, quần, tóc theo từng vùng cơ thể, đổi chỗ máu và vết thương, sắc da, chiều cao ±5 %, nhịp đi.
- **Ảnh:** chụp cả 10 dạng dưới đèn pin để anh/chị duyệt **trước khi vào bản chơi**.
