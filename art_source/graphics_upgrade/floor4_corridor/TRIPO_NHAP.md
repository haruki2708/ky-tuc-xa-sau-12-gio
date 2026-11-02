# T-229 — Phiếu Tripo NHÁP: hành lang tầng 4

**Chưa được duyệt, không bấm Generate.** Lane B soạn 01/11/2026. Integrator chuyển thành phiếu chính thức sau khi chủ dự án duyệt [PLAN.md](PLAN.md). T-229 đã dùng **0 credit, 0 tác vụ Tripo**, không tạo ảnh AI hay tải model mới.

## Phạm vi và ngân sách để xem xét

Ưu tiên tái dùng cửa 407, ghế, xô, dép, đèn bàn, bồn rửa của thư viện hiện có. Không tạo lại 8 cửa hay từng đôi dép. Hai mẫu mới đề xuất: điện thoại bàn và loa phóng thanh. Mỗi mẫu dự kiến 1–3 lượt, tổng 2–6 lượt; **đây là ước tính khối lượng, không phải số credit hoặc quyền chi**. Nếu chủ dự án chọn dựng Blender cả hai thì 0 lượt Tripo. Nếu chọn kiểu cửa khác mẫu 407, thêm 1–3 lượt riêng (tổng tối đa dự kiến 9 lượt cho cả ba mẫu); chưa thuộc gói đề xuất cơ sở.

Trước phiếu chính thức phải điền: người bấm duy nhất, tài khoản/gói Paid, Studio hay API, trần credit tổng và từng món, ngày, task ID, credit trước/sau, bản điều khoản ngày tạo, prompt và nguồn đầu vào, hash GLB gốc. Để trống các trường chưa có, không đoán giá hoặc cấu hình dịch vụ hiện hành. Studio và API dùng ví riêng; không dùng model Free; D-084 là ngoại lệ có hồ sơ, không phải giấy phép CC0. Không đưa khóa vào Git/chat. Phiếu phòng 407 chỉ là mẫu về cách diễn đạt, không kế thừa quyền chi hay số lượt.

## Quy cách chung đề xuất

- Đồ đã dùng nhiều năm nhưng còn hoạt động: trầy nhẹ, bụi ở khe và quanh nút, ố vừa; không mục nát, không máu, không ký hiệu mang ý nghĩa truyện.
- PBR, bỏ ánh sáng nướng nếu công cụ hỗ trợ; tạo một món tách biệt, đủ mặt sau/đáy. Cấu hình model/mesh/texture cụ thể do operator xác nhận ở thời điểm được duyệt, không gọi API trong T-229.
- Kích thước dưới là **mục tiêu chuẩn hóa nháp**, không phải đo model Tripo chưa tồn tại. B xử lý GLB/Blender: giảm lưới, bake normal, scale và pivot; giữ collision/anchor cũ. Mỗi binary ≤10 MB, Git LFS; budget texture/triangle của asset mới phải theo hợp đồng được integrator duyệt, không nới test production.
- Prompt dưới viết tiếng Anh để có thể chép vào công cụ, phần hướng dẫn bằng tiếng Việt. Negative prompt dùng trường riêng nếu có, nếu không thì nối rõ các điều loại trừ vào prompt chính.

## 1. Điện thoại bàn — ưu tiên 1, chờ duyệt kiểu dáng

- File nháp: `duty_telephone_r1.glb` (lượt sau `_r2`, `_r3`). Vị trí model hiện có: `Floor4/DutyDesk/DeskTelephone`=(40,4;0,8;0,42), góc Y=172°.
- Kích thước mục tiêu rộng × cao × sâu: **0,24 × 0,10 × 0,22 m**, gốc ở đáy; không chiếm chỗ chìa `Campus/Anchors/FireKey`=(39,8;0,66;0,42) hay giấy `DutyLog`.
- Hai phương án: A điện thoại nút bấm nhựa kem ố; B điện thoại nút bấm nhựa xám tối. **Đề xuất A** để đọc được hình trên bàn tối, chưa chọn thay chủ dự án. Mẫu prompt A:

```text
One standalone corded push-button desk telephone for an old Vietnamese university dormitory duty desk, approximately 24 cm wide, 10 cm high and 22 cm deep, yellowed ivory ABS plastic, compact rectangular base with a handset resting in its cradle, unmarked keypad buttons, subtle edge scratches and hand grime, dust in narrow seams, aged but intact and functional, realistic proportions, photorealistic PBR materials, neutral even lighting, complete back and underside, isolated object. The short handset cord should remain close to the body, no long trailing cable.
```

Negative:

```text
text, digits, letters, brand, logo, watermark, readable labels, smartphone, rotary dial, cartoon, toy, oversized handset, broken plastic, blood, rusted plastic, desk, room, hands, people, baked shadows, glowing screen, extra telephones, floating parts, long tangled wires
```

Tiêu chí chọn: đọc rõ thân/tay nghe, không dính mặt bàn, không phát sáng, có đáy, nút không có chữ giả. Dây xoắn lỗi hoặc vượt envelope thì dựng dây Blender; không trả thêm lượt chỉ để có dây. Prompt B chỉ thay `yellowed ivory ABS plastic` bằng `aged dark grey ABS plastic with slightly faded edges` sau duyệt.

## 2. Loa phóng thanh treo tường — ưu tiên 2

- File nháp: `duty_pa_horn_r1.glb`.
- Kích thước mục tiêu rộng × cao × sâu: **0,30 × 0,22 × 0,28 m**, chưa gồm gá. Mặt miệng loa hướng −Z ở asset chuẩn; gắn vào transform cũ, không đổi anchor Speaker hoặc nguồn âm.
- Vị trí model hiện tại (40;2,55;0,11), góc (−12;180;0); anchor âm thanh (40;2,45;0,37). Phải giữ khoảng trống quanh loa và không xuyên tường. Gá chữ U dựng Blender theo khoảng hở thực tế.
- Phương án A loa miệng chữ nhật bo góc; B loa miệng tròn. **Đề xuất B** để gần miệng loa tròn nhiều cạnh đang thấy ở ảnh 05/06; chủ dự án duyệt trước tạo. Prompt A dưới đây chỉ là lựa chọn thay kiểu dáng:

```text
One small wall-mounted public-address horn loudspeaker only, rectangular flared horn mouth with softly rounded corners, approximately 30 cm wide, 22 cm high and 28 cm deep, dull off-white painted metal, faded paint and small chips on the rim, restrained oxidation at screw recesses, dust inside the horn, aged but intact, simple enclosed rear driver housing, realistic old Vietnamese dormitory equipment, photorealistic PBR materials, neutral even lighting, complete geometry on all sides, isolated object, no mounting bracket or wall.
```

Negative:

```text
text, logo, brand, watermark, readable labels, handheld megaphone, handle, microphone, concert speaker, giant speaker, extra horns, cartoon, toy, severe corrosion, broken rim, blood, wall, cables, people, baked shadows, missing back, floating pieces
```

Tiêu chí chọn: miệng loa thật có chiều sâu, hậu loa kín, không biến thành loa cầm tay. Gá, vít và dây đi tường do Blender làm, không nhúng âm thanh vào model. Prompt B đề xuất: dùng cùng mô tả vật liệu/độ cũ ở trên, thay `rectangular flared horn mouth with softly rounded corners, approximately 30 cm wide, 22 cm high and 28 cm deep` bằng `circular flared horn mouth, approximately 26 cm in diameter and 28 cm deep`. Kích thước mục tiêu B là 0,26 × 0,26 × 0,28 m; cần duyệt lại envelope trước dựng.

## 3. Cánh cửa biến thể — tùy chọn, không nằm trong 2 mẫu cơ sở

**Mặc định đề xuất tái dùng** `game/assets/models/graphics_pilot/room407_shell/doors/door_room.glb` và tay gạt. Chỉ dùng mục này nếu chủ dự án chọn phương án cửa B trong PLAN. Không tạo cửa 408 đặc biệt hay giấy niêm phong bằng AI.

- File nháp: `corridor_door_variant_r1.glb`, **0,89 × 2,10 × 0,04 m** làm tỷ lệ tham khảo như cánh 407; khi triển khai phải khớp aperture/hinge từng cửa hiện có, không đổi collision.
- Mẫu phương án B: cánh gỗ phẳng, màu vẫn phải duyệt. Không tạo khung, tay nắm, bản lề, số phòng, khóa hay giấy.

```text
One single flat wooden interior door leaf only, one tall narrow solid rectangular leaf approximately 89 cm wide, 210 cm high and 4 cm thick, aged muted green painted wood for a Vietnamese university dormitory, subtle chipped paint near the edges and handle area, faint hand marks and scratches, flat straight edges, intact solid panel with matching front and back surface treatment, photorealistic PBR materials, neutral even lighting, isolated object, no frame or hardware.
```

Negative:

```text
double door, two leaves, door frame, casing, wall, hinges, handle, lock, keyhole, glass, window, number, text, logo, poster, seal, blood, broken wood, hole, bent edges, cartoon, toy, baked shadows, missing rear face
```

Không dùng tùy chọn này để thay cửa thoát hiểm, cửa buồng nhà vệ sinh hoặc cửa 407 đang hoạt động. Đó là hạng mục riêng.

## Handoff cho integrator khi chuyển phiếu chính thức

| Trường | Trạng thái T-229 |
|---|---|
| Chủ dự án duyệt kiểu/màu/mức cũ | Chưa |
| Operator, gói Paid, ví đúng dịch vụ | Chưa xác nhận |
| Trần credit tổng/từng món | Chưa được cấp |
| Ngày tạo, task ID, credit trước/sau | Không có, chưa tạo |
| Điều khoản và nguồn ảnh đầu vào | Chưa có phiên tạo; chỉ soạn text, không dùng ảnh từ game khác |
| GLB, hash, lần tạo, kết quả chọn | Không có |

Sau khi được giao tạo: báo riêng từng món, kiểm 6 hướng + đáy, kiểm texture không chữ/logo, lưu hồ sơ D-084, bàn giao B xử lý rồi chụp trong cảnh thử. Đường staging của lane B tương lai: `D:/GAME_WORK/lane-b2/build/graphics/staging/floor4_corridor/`; T-229 chưa ghi asset vào đó. Không dùng lại đường GAME_DEMO trong các phiếu mẫu cũ.
