# T-271 — Động tác đứng dậy khỏi giường (Trần Trung)

- Lane: integrator | Trạng thái: **xong, đã merge (D-194, D-195)**: bật mặc định 2,0 giây; chủ dự án miễn phần full test còn lại và check | Agent: integrator
- **Model:** Mythos 5.2 xhigh (chủ dự án chọn)
- Quyết định nền: D-147 (nằm trong giường), D-189 (Mixamo), **D-192** (thêm động tác đứng dậy khỏi giường, chấp nhận rời giường chậm hơn)

## 0. Hiện trạng trước phiếu này
- Bấm E khi đang nằm: người chơi nhảy ngay ra điểm rời giường (`Exit` của giường), thân người đứng sẵn ở đó. Không có động tác.
- Giường của Trung (số 3) và giường Việt (số 2) là tầng dưới. Đo trên ảnh cắt ngang (`build/graphics/motion/frames/t271_slice_*.png`):
  - mặt nệm dưới cao 0,43 m; đáy thành giường trên cách mặt nệm 0,64 m; mép khung phía phòng cách tim giường 0,42 m;
  - điểm rời giường cách tim giường 0,85 m, ngang chỗ gối.
- Vì vậy không ngồi thẳng dậy trong giường dưới được (đầu chạm giường trên). Người thật xoay chân ra mép, cúi đầu chui ra rồi mới đứng.

## 1. Cách làm
- **Luật chơi giữ nguyên:** bấm E là người chơi ra khỏi giường **ngay** (cờ `player_bed`, vị trí người chơi ở điểm rời giường, quản lý thấy như cũ). Chỉ thêm: trong lúc đứng dậy không đi và không xoay nhìn được.
- **Thân người** làm động tác trong `PlayerBody.bed_rise_seconds` giây, **camera bám theo mắt nhân vật**, cuối động tác về đúng tầm mắt đứng ở điểm rời giường.
- **Động tác** (`player_body.gd` `_build_bed_out`, dựng riêng cho hình học của giường đang rời):
  1. 1,0 giây: từ tư thế đang nằm sang ngồi ở mép nệm, hai chân đưa ra ngoài. Đoạn này nội suy, có khom lưng cúi cổ để đầu đi thấp qua mép giường trên.
  2. 0,85 giây: clip Mixamo **Getting Up** từ lúc ngồi chúi người: chân chạm sàn, người đứng lên. Hông tựa trên nệm tới khi rời nệm.
  3. 0,3 giây cuối: về dáng đứng nghỉ. Hai tay hạ xuống sớm (clip gốc giơ hai nắm tay lên như võ sĩ).
- **Hai bên giường:** giường Trung ra bên trái, giường Việt ra bên phải. Công cụ đóng gói có thêm tuỳ chọn `mirror` (lật gương clip, sai lệch đo được 0,0 mm); thư viện có `bed_rise` và `bed_rise_left`.
- **Không đổi:** giường tầng trên, rời giường không tiếng động (`leave_hide_spot(false)`: bị kéo ra, cảnh bị huỷ), người chơi không có thân, tủ và buồng nấp. Các trường hợp này vẫn ra ngay như cũ.
- Giường có hình học lạ (lối ra không nằm bên cạnh, sàn không thấp hơn nệm cỡ một chỗ ngồi) thì cũng ra ngay.
- Chết hoặc bị đặt nằm lại giữa chừng: động tác dừng, camera trả về người chơi.

## 2. Mẫu thử (cổng duyệt)
- Cờ: `PlayerBody.bed_rise_seconds` (0 = như cũ; mẫu thử quay ở **2,0 giây**; từ D-194 mặc định 2,0).
- Cảnh thử: `protagonist_pilot.tscn -- --bed-rise-demo --bed-rise=2.0` (giường 3 rồi giường 2; mỗi giường: mắt người chơi, nhìn từ trong phòng, nhìn ngang).
- **Video cũ | mới:** `build/graphics/motion/t271_roi_giuong_cu_moi.mp4` (32 giây).
- Test `tests/player/test_t271_bed_rise.gd` (4 test):
  - cờ tắt thì như cũ;
  - hai giường dưới: người chơi ra ngay, khoá đi lại; camera bắt đầu ở gối, không nhảy (dưới 7 cm mỗi nhịp), bám mắt (lệch dưới 2 cm); lúc qua mép giường mắt cao không quá 0,58 m trên nệm; chân không xuống dưới sàn; hông không chìm dưới nệm; đúng số giây thì đứng, mở khoá, camera ở 1,6 m tại điểm rời giường; thân lệch hướng nhìn dưới 50° nên không phải xoay bước;
  - giường trên và rời không tiếng động: ra ngay;
  - nằm lại hoặc chết giữa chừng: dừng sạch.

## 3. Còn tồn tại (nói thẳng)
- Lúc về dáng đứng nghỉ, bàn chân xê dịch tới khoảng 32 cm trong nửa sau (dáng đứng nghỉ của Trung dang chân trái). Ở góc nhìn người chơi không thấy; thấy trong gương.
- Thân người đi xuyên qua màn (mùng) quanh giường, như lúc vào giường hiện nay.
- Nếu chết đúng trong 2 giây đang đứng dậy, camera nhảy về tầm đứng trước khi cảnh chết chạy.
- Tư thế nằm trong giường không đổi (vẫn clip cũ, D-147).

## 4. Chủ dự án duyệt (D-194, 24/11)
- "tôi duyệt nhé". Chủ dự án không đổi số giây và không nói gì về giường tầng trên, nên lấy theo đề xuất: **2,0 giây**; giường tầng trên **vẫn ra ngay** (chưa làm động tác leo xuống).
- Bật mặc định: `PlayerBody.bed_rise_seconds = 2.0`. Đổi số giây chỉ là sửa một con số.
- Test cũ sửa theo: `test_protagonist_bed.gd` (thân người đứng dậy trong 2 giây thay vì đứng ngay; test "không có thân" giờ gỡ thân thật).

## 5. Kiểm tra lúc merge (D-195, 24/11)
- Đã chạy: nhóm test giường, thân người, giường tầng, smoke 65 đạt / 0 hỏng; full test chạy được 486 đạt / 0 hỏng (8 phần đầu và 3/4 phần 9, gồm toàn bộ test cốt truyện bốn chương) rồi bị ngắt vì thiếu RAM; phần còn lại (`levels/test_t265`, `levels/test_t264`, test nhân vật, âm thanh, giao diện, công cụ) và check **chưa chạy**.
- Merge `701aeecb`, bản chơi `build/dist/KyTucXa-0.0.1-701aeecb-win64.zip`.
- Chủ dự án: "không cần chạy test nữa đâu, tôi thấy ok rồi nhé". Merge theo lời đó; lần full test + check kế tiếp (ở việc sau) sẽ phủ phần chưa chạy.
