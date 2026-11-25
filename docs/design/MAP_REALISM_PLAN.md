# Kế hoạch làm lại đồ hoạ toàn map theo 208 ảnh GPT

**Trạng thái:** bản đề xuất của integrator, 26/11/2026 (Mythos 5.2). Chủ dự án đã duyệt cả 208 ảnh làm đích (D-200); **các đợt dưới đây chưa giao**, chờ chủ dự án trả lời mục 8.

- Ảnh đích: `build/graphics/anh_gpt/<khu>/<tên>_gpt.png` (208 ảnh, 20 khu, không commit).
- Ảnh hiện trạng cùng góc máy: `build/graphics/anh_hien_trang/<khu>/<tên>.jpg`, chụp bằng `art_source/graphics_upgrade/realistic_map/atlas/capture_atlas.gd`.
- Kế hoạch trước: [`realistic_map/PLAN.md`](../../art_source/graphics_upgrade/realistic_map/PLAN.md) (T-248, mười đợt T-250…T-267, đã xong).

## 1. Khoảng cách giữa game hiện nay và ảnh GPT

Integrator so 60 cặp ảnh ở đủ 20 khu. Ảnh GPT **giữ gần như nguyên khối nhà, bố cục và đồ đạc** của mười đợt trước; chỗ khác nằm ở năm nhóm, xếp theo mức đóng góp:

| # | Khác ở đâu | Hiện nay | Ảnh GPT | Thấy ở |
|---|---|---|---|---|
| 1 | **Ánh sáng** | Sáng nền phẳng màu xanh lam (`ambient_light_energy` 0,40–0,65), không bóng tiếp xúc, đèn pin là đĩa sáng đều | Nền tối, đèn tuýp và đèn đường là nguồn chính, ấm, tắt dần theo khoảng cách; góc trần, chân tường sẫm lại | cả 208 ảnh |
| 2 | **Mặt sàn, mặt đường** | Nhám đều, không phản chiếu | Bóng ướt, có vệt sáng đèn kéo dài, vũng nước, vết mòn | sàn mọi nhà, đường, sân lát, đường chạy |
| 3 | **Tường, trần** | Vữa sạch, màu chân tường nhạt, hoa văn lặp thấy rõ | Ố thấm chảy dọc, bong sơn, rêu chân tường, sơn chân tường xanh sẫm, trần loang | hành lang, phòng, cầu thang, mặt ngoài nhà |
| 4 | **Ngoài trời** | Trời một màu, cây ít lá, cỏ phẳng | Trời đêm nhiều mây, cây tán dày, cỏ có độ dày, đèn xa, sương mỏng | khu 10–17 |
| 5 | **Đồ lẻ** | Mùng là hộp kính xanh, vải cứng | Mùng lưới mỏng rủ, vải mềm, đồ bừa thêm ở phòng 407 chương 4 | khu 01, 04, 18, 19 |

**Hệ quả cho cách làm:** đây không phải một lượt dựng lại khối trong Blender. Phần lớn lợi ích đến từ ánh sáng và vật liệu trong Godot (nhóm 1–3, tác động mọi góc máy cùng lúc). Blender dùng cho nhóm 4–5 và các tấm vết ố. D-166 từng chốt "ánh sáng giữ như nay" cho mười đợt trước; kế hoạch này đổi điểm đó.

## 2. Nguyên tắc

1. **Ảnh GPT là đích về cảm giác, không phải bản vẽ.** Giữ nguyên bố cục, collider, navmesh, điểm tương tác, chữ tiếng Việt, biển số phòng và các dấu hiệu cốt truyện (hợp đồng gameplay ở PLAN.md mục 4).
2. **Chỗ GPT tự thêm hoặc đổi** (ghế đá, xe đạp khác kiểu, đồ bừa, cửa sổ sáng đèn, chữ sai): chỉ lấy phần trang trí không chắn lối và không đổi nghĩa truyện. Phần còn lại ghi vào danh sách hỏi chủ dự án.
3. **Không dán ảnh GPT làm texture.** Ảnh là phối cảnh, không lát được. Texture lấy từ nguồn CC0 như trước, chỉnh màu theo ảnh.
4. **Thước đo:** chụp lại đúng góc máy rồi ghép ba cột *trước | sau | GPT*. Mỗi đợt nộp bảng ba cột của mọi ảnh thuộc khu đó.
5. **Hiệu năng:** đích vẫn là trung bình ≥ 60 FPS ở 1080p trên RTX 3050 Laptop. Góc nặng nhất chương 3 đang khoảng 70–75 FPS, tức còn chừng 2–3 ms. Bộ nhớ hình còn rộng (chương 3 dùng 1,25 GB trên 4 GB sau T-257).
6. **Không dùng:** SDFGI, lightmap nướng sẵn (đèn trong game bật tắt theo truyện, cúp điện), bóng động cho hàng loạt đèn.

## 3. Cách làm kỹ thuật (đề xuất, chốt bằng số đo ở đợt R0)

| Nhóm | Cách làm | Chi phí dự kiến |
|---|---|---|
| Ánh sáng | Hạ sáng nền, đổi màu nền theo từng không gian (trong nhà, ngoài trời); đèn tuýp, đèn đường ấm hơn, tầm và độ tắt dần chỉnh lại; đèn pin có viền mềm và lõi sáng; bật SSAO cho mọi cảnh (nay chỉ phòng 407); glow nhẹ quanh đèn; chỉnh phơi sáng và tông màu | SSAO và glow khoảng 0,5–1 ms, **chưa đo** |
| Sàn bóng ướt | Hạ độ nhám sàn theo bản đồ mòn (chỗ đi nhiều bóng hơn), thêm vũng nước bằng tấm vết; phản chiếu bằng `ReflectionProbe` từng đoạn hành lang, từng phòng. SSR chỉ thử ở R0, dùng nếu đo thấy đủ khung hình | Probe gần như không tốn khi đứng yên; SSR khoảng 1–2 ms, **chưa đo** |
| Tường ố | Một shader tường dùng chung: lớp vữa, lớp sơn chân tường, lớp bẩn trộn theo màu đỉnh và độ cao; cộng bộ khoảng 20 tấm vết (`Decal`): thấm chảy, bong sơn, rêu, nứt, vũng nước | Thêm vài chục MB bộ nhớ hình; decal tốn theo số tấm cùng thấy |
| Ngoài trời | Bầu trời đêm có mây (ảnh toàn cảnh), sương theo khoảng cách chỉnh lại; cây dựng lại trong Blender bằng cành lá dạng tấm, ba mức chi tiết; cỏ có lớp ngọn gần camera; đèn xa là tấm phát sáng | Lá trong suốt chồng nhau là rủi ro lớn nhất về khung hình |
| Đồ lẻ | Mùng lưới mỏng (texture lưới có lỗ thay cho kính), vải rủ, đồ bừa phòng 407 chương 4 | Nhỏ |
| CCTV | Hưởng vật liệu và ánh sáng chung. Feed chỉ 320 × 240 nên không dựng thêm chi tiết riêng (D-166 giữ góc máy và độ rõ) | Không đáng kể |

## 4. Các đợt

Ký hiệu R0…R9 (R = realism). Card nhận số T khi giao; số tiếp theo là T-273.

| Đợt | Phạm vi | Số ảnh đích | Ai làm, model | File chính |
|---|---|---:|---|---|
| **R0** | **Nền ánh sáng và bề mặt + hai khu mẫu.** Thiết lập ánh sáng, hậu kỳ, shader tường, shader sàn, bộ tấm vết, công cụ ghép ba cột. Áp vào khu mẫu trong nhà (hành lang tầng 4 đoạn bàn trực và nhà vệ sinh chung) và khu mẫu ngoài trời (nhà B mặt ngoài). Đo FPS ở các góc đã có số cũ. Viết bảng thông số chung cho các đợt sau. | 9 mẫu | Integrator, **Mythos 5.2 high** (việc xuyên mọi cảnh, đụng thiết lập chung) | môi trường của từng cảnh chương, `floor4/`, `campus/building_b.tscn`, `campus/shells.tscn`, thư mục vật liệu chung mới |
| R1 | Phòng 407 chương 1 và chương 4: mùng, vải, đồ bừa chương 4, nhà tắm, ban công | 24 | Lane B, **Opus 5.5 xhigh** | `room407/`, `ch4/` |
| R2 | Tầng 4: hành lang, nhà vệ sinh chung, phòng 401–406 và 408 | 35 | Lane B, Opus 5.5 xhigh | `floor4/` |
| R3 | Hai cầu thang, tầng 3, tầng 2, sảnh tầng 1 | 45 | Lane B, Opus 5.5 xhigh | `campus/building_b.tscn` |
| R4 | Nền ngoài trời: bầu trời, mặt đất, đường, cây, hàng rào; mặt ngoài nhà B, nhà A, giảng đường, nhà thể chất | 22 | Integrator, Mythos 5.2 high (cây và trời dùng chung cho R5–R7 nên cần xong trước) | `campus/shells.tscn`, `rest_real.gd`, `foliage.gd`, `props.tscn` |
| R5 | Vườn hoa, sân vận động, cổng trường | 30 | Integrator, Mythos 5.2 high | `garden.tscn`, `stadium.tscn`, `gate.tscn` |
| R6 | Nhà ăn, bếp, kho | 15 | Lane B, Opus 5.5 xhigh | `campus/canteen.tscn` |
| R7 | Thư viện ba tầng | 20 | Lane B, Opus 5.5 xhigh | `library/` |
| R8 | Phòng bệnh đoạn kết, năm phòng trường quay CCTV | 17 | Lane B, Opus 5.5 xhigh | `hospital/`, `cctv/` |
| R9 | Khép: chụp lại 217 góc, bảng ba cột toàn map, đo FPS bốn chương, full test + check, bản chơi, danh sách điểm cần xem cho lượt chơi thử cuối (D-176) | 208 | Integrator, Mythos 5.2 high | — |

Tổng R1–R8: 208 ảnh.

**Hai luồng song song sau R0:** lane B đi trong nhà (R1 → R2 → R3 → R6 → R7 → R8), integrator đi ngoài trời (R4 → R5). Mỗi khu nằm ở file cảnh riêng nên ít đụng nhau; `campus.tscn` (10.846 dòng) chỉ một nhánh sửa tại một thời điểm. Lane C, E không tham gia (mẫu thử Codex cho đồ hoạ không đạt ở D-168).

**Mỗi đợt R1–R8 gồm:**
1. Áp shader tường, sàn và thông số ánh sáng của R0 vào khu.
2. Đặt tấm vết theo ảnh GPT của từng góc máy.
3. Làm đồ lẻ còn thiếu của khu (cột "Thấy ở" mục 1).
4. Chụp lại mọi góc máy của khu, ghép ba cột, tự chấm từng ảnh: đạt, gần đạt, lệch và lý do.
5. Kiểm hợp đồng gameplay của khu và chạy nhóm test của khu.
6. Integrator review bảng ba cột, chạy full test (từng phần, chạy ở nền trước) và check trước khi merge.

## 5. Điều kiện qua R0

R0 quyết định cả kế hoạch, nên có điều kiện riêng:

- 9 ảnh mẫu đạt trên bảng ba cột, chủ dự án xem **trong game** (độ tối ảnh hưởng tới việc chơi).
- FPS trung bình ≥ 60 ở các góc nặng đã biết của chương 1 và chương 3; phần tăng của cả gói ánh sáng và bề mặt ≤ 1,5 ms mỗi khung.
- Đèn bật tắt theo truyện (cúp điện, đèn sân, đèn pin) vẫn đúng ở cả bốn chương.
- Có bảng thông số để lane B làm theo mà không phải đoán: màu và độ mạnh từng loại đèn, sáng nền từng không gian, khoảng độ nhám sàn, danh mục tấm vết.

Nếu SSR hoặc lá cây làm tụt dưới 60 FPS: bỏ SSR (giữ probe), giảm mật độ lá theo khoảng cách, không hạ đích 60 FPS.

## 6. Rủi ro

| Rủi ro | Xử lý |
|---|---|
| **Tối quá, khó chơi.** Ảnh GPT ngoài trời gần như đen ngoài vùng đèn; trận sân vận động và đoạn né bảo vệ cần nhìn thấy bóng người từ xa | Giữ một mức sáng nền tối thiểu ngoài trời; R0 kiểm bằng cách chơi thật đoạn sân vận động và cổng trường |
| Đổi ánh sáng làm hỏng test dựa vào độ sáng, bóng hoặc SSAO (ví dụ `test_room407_playable_furnished`) | R0 liệt kê và sửa test theo thiết lập mới, không nới ngưỡng gameplay |
| Lá cây trong suốt kéo tụt FPS ở khuôn viên, nơi vốn đã nặng nhất | Ba mức chi tiết, lá xa là tấm đặc; đo ở R4 |
| Tấm vết lặp lại, nhìn giả | Bộ khoảng 20 tấm, xoay và lật ngẫu nhiên, mỗi góc máy đối chiếu với ảnh GPT |
| Hai luồng cùng sửa file chung | Ranh giới file ở mục 4; file dùng chung (shader, thông số) chỉ integrator sửa sau R0 |

## 7. Chưa biết

- Chi phí khung hình của SSAO, glow, SSR, probe và decal trên máy đích: **chưa đo**, R0 trả lời.
- Số ngày: chưa ước lượng được trước R0. Mười đợt dựng hình trước mất 12 ngày (11–22/11); lượt này ít dựng khối hơn nhưng R0 là việc mới.
- Shader "phòng giả sau cửa sổ" của nhà A, B (D-182) có hợp với ánh sáng mới không: xem ở R4.

## 8. Câu hỏi cho chủ dự án

1. **Bắt đầu bằng R0 do integrator làm** (Mythos 5.2), duyệt xong mới làm cả map? Đề xuất: có.
2. **Cho đo FPS ở R0 và R9** (D-179 đang hoãn đo tới cuối)? Đề xuất: có, vì thiết lập ánh sáng tác động mọi cảnh; mỗi lần đo vài phút, chạy ở nền trước.
3. **Độ tối:** theo sát ảnh GPT, hay giữ mức sáng tối thiểu để còn nhìn thấy bóng người ngoài trời? Đề xuất: giữ mức tối thiểu, chốt bằng lượt xem trong game ở R0.
4. **Cách duyệt các đợt R1–R8:** chủ dự án duyệt một lần ở R0, các đợt sau integrator duyệt theo ảnh GPT (như D-185), chủ dự án xem bảng ba cột lúc nào tiện và chơi thử một lượt cuối? Đề xuất: có.
5. **Hai luồng song song** (lane B trong nhà, integrator ngoài trời)? Đề xuất: có. Nếu không, mọi đợt giao lane B và làm tuần tự.
