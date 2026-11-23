# T-269 — Chuyển động bước 3: Trần Trung đi, chạy, ngồi xổm bằng clip Mixamo (mặc định)

- Lane: integrator | Trạng thái: **phần đầu đã merge vào main (24/11/2026)**; phần còn lại ở mục 3 | Agent: integrator
- **Model:** Opus 5.5 xhigh (chủ dự án chọn)
- Quyết định nền: D-189, **D-190** (chủ dự án duyệt mẫu thử T-268), kế hoạch `docs/design/MOTION_UPGRADE_PLAN.md` bước 3

## 1. Đã làm (23/11)
- **Bộ đã duyệt thành mặc định:** `PlayerBody.motion` và `ManagerBody.motion` = `&"mx"`.
  - Trần Trung đứng Neutral Idle, đi tới, đi lùi, đi ngang.
  - Quản lý đi Male Brutal Walk theo nhịp chân, chém bằng clip Mixamo.
  - Đặt `&""` thì quay lại clip Tripo.
- **Chạy:** Standard Run, tốc độ phát ×0,98 ở 3,6 m/s (bản cũ ×1,14; Jogging phải ×2,2 nên loại).
- **Ngồi xổm: giữ clip Quaternius.**
  - Clip khom của Mixamo đứng cao hơn camera khom 1,0 m khoảng 22 cm: mắt khoảng 1,10–1,22 m, thân va chạm chỉ cao 1,15 m. Camera sẽ nằm trong ngực.
  - Mã đi khom bốn hướng đã có, bật bằng `PlayerBody.mx_crouch` khi tìm được clip khom thấp hơn.
- **Thao tác tay đứng trên dáng mới:** không còn cú đổi dáng ở đầu thao tác. Bốn test tay hỏng khi đổi, đã sửa đúng nguyên nhân:
  - **Với lên cao (kiễng chân)** giờ tính trên tư thế đang giữ, như với ngang tầm (T-241). Neutral Idle dồn trọng tâm làm vai lệch khung đầu tới 9 cm.
  - **Độ nghiêng khi với lên cao** dự đoán bằng chính phép tính của `BodyLeanModifier`. Cách chia đều cũ làm vai thật lệch 1–3,5 cm so với dự tính, nên ảnh đội ở mép tầm tay được gợi ý với rồi trượt 2 cm. Bản Tripo cũng trượt nếu đứng đúng chỗ đó: dựng lại được 17,9 cm, quá ngưỡng 16,4 cm.
  - **Test camera theo mắt (T-241)** giờ kiểm camera đi đúng quãng mắt đi khi nghiêng, sai số dưới 3 cm, và không xa mắt quá 6 cm. Neutral Idle đứng với mắt thấp hơn camera 1,6 m khoảng 3,7 cm; mắt của idle Tripo trùng camera.
- **Test:**
  - `test_t249`: đi lùi giờ phát clip đi lùi theo chiều xuôi.
  - `test_t268_motion_pilot`: thêm test cho mặc định và cho tốc độ chạy.
  - `tests/player/` 275/0; smoke 1/0; `graphics_pilot` 3/0.

## 2. Video (trong `build/graphics/motion/`, không commit)
- `t269_chay_khom_cu_moi.mp4`: chạy, rồi ngồi xổm. Phần ngồi xổm hai bên giống nhau vì giữ clip cũ.
- `t269_tay_cu_moi.mp4` (cũ | mới, 40 giây): dạo phòng, tủ, sổ tay Đạt, cửa 407, cửa tắm, cửa ban công; mắt người chơi rồi nhìn từ trong phòng.
  - Lần quay bản cũ đầu tiên (23/11) bị dừng vì thiếu RAM (mã 0xC0000005). Quay lại ngày 24/11 sau khi chủ dự án gỡ RAV.

## 3. Còn lại của bước 3
**D-191 (24/11):** chủ dự án duyệt cách chạy mới; ngồi xổm giữ clip cũ; phần dưới đây chờ chủ dự án chơi thử bản `6dfd01dd` xong.
- Xoay tại chỗ có bước chân: hiện dùng clip đi phát 0,7 lần, như cũ.
- Lên, xuống cầu thang (chương 3).
- Đứng dậy khỏi giường.
- Bắt đầu và dừng bước: bỏ, vì người chơi tăng tốc lên 2,2 m/s trong 0,18 giây, ngắn hơn mọi clip bắt đầu bước.

## 4. Kiểm trước khi merge (24/11/2026, sau khi chủ dự án gỡ RAV)
- Full test chạy trực tiếp 17 phần: **1105 đạt / 0 hỏng** (1096 cũ + 9 test T-268/T-269), mọi file test đều chạy.
- Check: 0 lỗi.
- Máy chạy chậm hơn hôm 22/11 khoảng 1,5 lần lúc đầu (Blender đang mở), nên phần core chương 1–2 phải chia đôi.
