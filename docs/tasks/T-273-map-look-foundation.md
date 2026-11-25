# T-273 — R0: nền ánh sáng và bề mặt theo ảnh GPT, hai khu mẫu
- Lane: integrator | Trạng thái: **đang làm, lượt 1 xong 26/11/2026, chờ chủ dự án xem** | Model: Mythos 5.2 high.
- Nhánh: `integrator/T-273-map-look` (chưa merge). `D:\GAME_DEMO` đang đứng ở nhánh này.
- Quyết định nền: D-200 (208 ảnh GPT là đích), D-201 (làm R0). Kế hoạch: [`MAP_REALISM_PLAN.md`](../design/MAP_REALISM_PLAN.md) đợt R0.
- Ảnh: `build/graphics/anh_r0/` (không commit). Bảng ba cột *trước | sau | GPT*: `R0_trong_nha.jpg` (20 góc hành lang và nhà vệ sinh tầng 4, chương 1), `R0_ngoai_troi.jpg` (5 góc nhà B mặt ngoài, chương 3).

## Đã làm ở lượt 1

**Công tắc.** Mọi thay đổi nằm sau `-- --look=1`. Không có tham số này thì hình như cũ: đã so ảnh chụp lại với ảnh hiện trạng ở 2 góc, lệch trung bình dưới 0,05/255. Bản chơi hiện tại không đổi.

**`game/rendering/map_look.gd`** (node `MapLook`, `chapter1_main.gd` thêm vào cả bốn chương):
- Môi trường, hai bộ số:
  - chương 1–2 (chỉ có tầng 4): sáng nền 0,40 → 0,10, bão hoà màu 0,86;
  - chương 3–4 (có khuôn viên): sáng nền 0,65 → 0,62, bão hoà 0,93. Ảnh GPT giữ sân và mặt nhà sáng gần như cũ, nên ngoài trời không hạ.
- Chung cho cả hai: bật SSAO (bán kính 1,2, cường độ 2,2), glow nhẹ 0,12, phơi sáng 1,05, điểm trắng 4,0, tương phản 1,1.
- Bầu trời đêm có mây (`night_sky.gdshader`, dùng lại texture nhiễu có sẵn, không thêm file ảnh); sương không còn che hết trời.
- Đèn: mọi `OmniLight3D` không màu (bão hoà ≤ 0,34) đổi từ trắng xanh lá sang trắng, mạnh × 1,3, tầm × 1,6, độ tắt dần 1,2, phản chiếu trên mặt bóng 0,3. Đèn có màu (trăng qua cửa sổ, đèn LED) giữ nguyên.
- Đèn pin: màu ấm hơn, góc 34°, lõi sáng và viền mềm (`spot_angle_attenuation` 2,4), năng lượng 1,9.
- "Dawn" của khuôn viên: giữ độ mạnh, đổi từ xanh lam sang trắng.
- Chương 1–2: thêm một đèn trăng chỉ chiếu phông vườn và nhà A nhìn từ tầng 4 (lớp hiển thị 11). Không có nó thì phông đen hẳn khi hạ sáng nền.
- Phòng 407 chưa đụng tới (giữ D-113, D-133), để đợt R1.

**`game/rendering/room407_shell.gdshader`** (shader chung của gần như mọi tường, trần, sàn, mặt đường của mười đợt trước, 85 vật liệu `.tres`): hai biến toàn cục mới, bằng 0 khi tắt công tắc.
- `look_age`: tường và trần sơn thêm vết bẩn loang và vệt chảy dọc, đọc nhiễu theo toạ độ thế giới nên không cần vẽ mặt nạ; trần sẫm hơn, có mốc.
- `look_wet`: mọi mặt hướng lên bóng hơn (độ nhám × 0,5, tối thiểu 0,22), có mảng đọng nước sẫm và phẳng, màu bớt bão hoà.

**Công cụ:**
- `capture_atlas.gd` nhận `--out=<thư mục dưới build/graphics>`.
- `art_source/graphics_upgrade/map_look/compare.py` ghép bảng ba cột.

## Kết quả so với ảnh GPT (integrator tự chấm)

| Khu mẫu | Đã gần | Còn lệch |
|---|---|---|
| Hành lang tầng 4 | Đêm tối ngoài lan can, tường kem dưới đèn trắng, sàn bóng có vệt đèn kéo dài, trần sẫm loang | Tường ít mảng bong sơn và vệt chảy hơn ảnh GPT; trần chưa có mảng tróc |
| Nhà vệ sinh tầng 4 | Sàn ướt sẫm, tường gạch sáng dưới đèn | Sàn chưa ướt bằng; gạch chưa xanh ngọc bằng; quanh đèn tuýp bị loá |
| Nhà B mặt ngoài | Trời mây, mặt nhà giữ độ sáng, có vết bẩn | Mặt đường chưa phản chiếu mặt nhà; cây chưa đổi (việc của R4) |

Xem thử ở khu chưa làm (cầu thang, sảnh tầng 1, đường, sân vận động, nhà ăn; ảnh trong `anh_r0/`): không khu nào vỡ hình. Hai điểm cho các đợt sau:
- Đường và sân vận động tối hơn ảnh GPT vì đèn đường chưa toả vùng sáng (R4, R5).
- Tường trong nhà ở chương 3 vàng đậm hơn ảnh GPT, vì "Dawn" không có bóng nên chiếu xuyên vào phòng (R3: tách lớp hiển thị cho phần trong nhà).

Phản chiếu thật trên màn hình (SSR, `--look-ssr=1`): thử ở 3 góc, gần như không khác vì vệt sáng trên sàn đến từ đèn chứ không từ phản chiếu. Đề xuất không bật.

## Chưa làm

- **Chưa đo FPS.** Chờ chủ dự án cho phép (D-179) và máy rảnh.
- **Chưa chạy test nào** (full test, check). Phải chạy trước khi merge.
- Chưa kiểm các trạng thái theo truyện khi bật công tắc: cúp điện, đèn nhấp nháy, đèn sân vận động, phòng bệnh, trường quay CCTV. Chỗ cần xem: `campus/flicker.gd` đặt năng lượng tuyệt đối (0,35 / 0,015) nên đèn nhấp nháy không được nhân 1,3.
- Chưa có bộ tấm vết (`Decal`) và mảng bong sơn: lượt 1 chỉ dùng shader. Làm ở lượt 2 nếu chủ dự án muốn tường cũ hơn nữa.
- Chưa viết bảng thông số cho lane B.

## Cách xem trong game

`D:\GAME_WORK\xem_do_hoa_moi.bat` chạy game từ mã nguồn với công tắc bật. Cần `D:\GAME_DEMO` đứng ở nhánh `integrator/T-273-map-look`.

## Việc tiếp theo

1. Chủ dự án xem hai bảng ba cột và xem trong game, nói chỗ nào cần đậm hơn, nhạt hơn, tối hơn, sáng hơn.
2. Lượt 2: sửa theo ý chủ dự án; thêm tấm vết và bong sơn nếu cần; kiểm trạng thái theo truyện; đo FPS; chạy full test và check.
3. Viết bảng thông số, rồi merge và giao R1.
