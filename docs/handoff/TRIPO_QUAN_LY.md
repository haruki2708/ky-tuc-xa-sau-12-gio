# Tripo: quản lý ký túc xá, mẫu A (T-219, D-115)

> Integrator (Claude, Opus 5.5), 15/10/2026.
> - Người bấm tạo: **chủ dự án**. Không giới hạn lượt (D-095). Credit chỉ ghi khi chủ dự án báo.
> - Mẫu A làm toàn bộ bằng Tripo. Mẫu C (MPFB + đồ Tripo) dùng chung **dao, chùm chìa khóa, thẻ đeo** ở mục 4.
> - Tải về `D:\GAME_DEMO\build\graphics\staging\manager\`, đặt tên theo bảng; lượt sau thêm `_r2`, `_r3`; bản sửa thêm `_tex1`, `_brush1`.

## 1. Ngoại hình (chủ dự án chốt, D-115)
- Nam, **khoảng 45 tuổi**, **trang phục quản lý trường học**, **lộ mặt, mặt kinh dị**, cầm **dao sắc**.
- **Claude đề xuất chi tiết, chủ dự án sửa được:**
  - **Dáng:** gầy, hơi gù, vai xuôi, cao khoảng 1,70 m.
  - **Đồng phục:** sơ mi xanh nhạt dài tay sơ vin, quần tây xám đậm, thắt lưng da đen, giày da đen cũ, thẻ đeo trơn (không chữ), chùm chìa khóa bên hông.
  - **Mặt kinh dị, gắn với twist động đất:**
    - da xám tái phủ bụi bê tông;
    - vệt máu khô từ chân tóc chảy xuống thái dương;
    - mắt mở to không chớp, tròng trắng đục, con ngươi nhỏ;
    - môi khô nứt, miệng hơi cười cứng;
    - tóc đen cắt ngắn, bạc hai bên thái dương.
  - **Dao:** dao phay dài khoảng 45 cm, lưỡi chữ nhật nặng, **mép lưỡi mài sáng loáng**, thân thép xám xước, cán gỗ sẫm, hai đinh tán đồng, gỉ lấm tấm gần sống dao.

## 2. Cài đặt tạo
- Tripo Studio, **Text to 3D**, model **H3.1**, Triangle; Ultra mesh bật, texture **4K**, PBR bật, Remove lighting bật, Generate in parts tắt.
- Nhân vật phải đứng **A-pose** (hai tay dang chéo xuống khoảng 45°, chân hơi tách), **không cầm gì**, để gắn xương được. Dao tạo riêng ở mục 4.
- Ô negative prompt (nếu có), dán chung:
  `text, letters, logo, watermark, holding object, weapon in hand, T-pose with fists, floating parts, base platform, ground plane, cartoon, anime, stylized, toy, chibi, baked shadows`

## 3. Thân quản lý: `manager_body.glb`

**Prompt:**
```text
Full body photorealistic 3D character of a Vietnamese man about 45 years old, a school dormitory manager, standing in a relaxed A-pose with arms angled down 45 degrees away from the body, empty open hands, feet slightly apart. Thin, slightly hunched build, sloped shoulders. Short black hair with grey at the temples. Horror face fully visible: grey pale skin covered in fine concrete dust, a streak of dried dark blood from the hairline down the temple, wide unblinking eyes with milky clouded irises and tiny pupils, cracked dry lips set in a stiff faint smile, sunken cheeks. Light blue long-sleeve button-up uniform shirt tucked in, dark grey trousers, black leather belt, worn black leather shoes. Shirt dusty with faded stains. Realistic skin pores, realistic fabric folds, PBR.
```
**Texture** (dùng cho AI Texturing khi hình đúng mà màu/da sai):
```text
Photorealistic grey pale dusty skin with dried blood streak from the hairline, milky clouded eyes, light blue cotton shirt with dust and faded stains, dark grey wool trousers, worn black leather, no text
```

**Kiểm trước khi tải:**
1. Mặt rõ, đúng mắt đục và vệt máu, không méo hay nhòe.
2. Đủ 5 ngón mỗi bàn tay, tay không dính vào hông.
3. A-pose, không cầm gì.
4. Không chữ, không logo trên áo và thẻ.
5. Quần áo không thủng, không mảnh bay.

**Sửa:**

| Lỗi | Cách sửa |
|---|---|
| Mặt nhòe hoặc không đủ kinh dị | Magic Brush vùng mặt: `sharp realistic face, milky clouded eyes, dried blood from hairline, grey dusty skin` |
| Ngón tay dính hoặc thiếu | Magic Brush bàn tay: `five separate fingers, open relaxed hand` |
| Hình sai hẳn | Tạo lại. Nếu Text to 3D làm mãi không đạt: tạo ảnh ngay trong Tripo (nếu Studio có tạo ảnh) bằng chính prompt trên, chọn ảnh **chính diện, A-pose, toàn thân**, rồi **Image to 3D**. Không dùng ảnh mạng (D-084) |

**Gắn xương (sau khi hình đạt):**
1. Nếu Studio có giảm lưới (Low Poly / Retopology / giới hạn mặt): giảm còn **khoảng 20.000 tam giác** trước khi gắn xương.
2. Dùng **Auto Rig** loại người (humanoid). Xem thử động tác mẫu: vai, khuỷu, đầu gối không được gãy hay rách áo.
3. Tải **GLB có xương** `manager_body_rigged.glb`. Nếu Studio có sẵn động tác đi, đứng thì tải thêm `manager_walk.glb`, `manager_idle.glb`.
4. **Tải cả bản chưa gắn xương** `manager_body.glb`.

## 4. Đồ đi kèm (tạo riêng, dùng cho cả mẫu A và C)

| File | Prompt | Kiểm |
|---|---|---|
| `manager_knife.glb` | `Long Vietnamese chopping knife (dao phay), 45 cm, heavy rectangular steel blade with a bright freshly honed sharp edge, scratched grey steel body, small rust spots near the spine, dark wooden handle with two brass rivets, photorealistic, PBR, no text` | Lưỡi phẳng, mép sáng, cán liền lưỡi, không chữ |
| `manager_keys.glb` | `Ring of old brass and steel keys on a large metal key ring with a short leather strap clip, about 12 keys, worn, photorealistic, PBR, no text` | Chìa tách rõ, có móc |
| `manager_id_card.glb` | `Plain staff ID card in a clear plastic holder on a dark blue fabric lanyard, card blank with a small portrait photo area, slightly dirty, photorealistic, PBR, no text, no logo` | Không chữ, không logo |

## 5. Báo lại integrator
Báo theo mẫu:
- tên file;
- lượt thứ mấy;
- đã sửa bằng gì;
- số credit trước và sau (nếu muốn ghi);
- mặt có đạt chưa, theo ý anh/chị.

Integrator chuẩn hóa, gắn dao vào tay, đặt **mẫu A cạnh mẫu C** trong phòng 407 rồi chụp ảnh so sánh (T-219).
