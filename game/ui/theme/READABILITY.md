# T-214 — Bằng chứng hình ảnh và khả năng đọc

Ngày 12/10/2026, lane D. [Trang đối chiếu trước/sau](previews/index.html) mở trực tiếp bằng trình duyệt, có bộ chọn màn, vi/en, 720p/1080p và chế độ xem đúng kích thước. Có **192 PNG gốc**: 24 màn/trạng thái × 2 ngôn ngữ × 2 độ phân giải × trước/sau. [Manifest SHA-256](previews/manifest.json) và [bảng số đo từng ảnh](previews/typography.csv) đi cùng ảnh; không crop, sửa màu, ghép hoặc nén lại ảnh gốc.

## Phạm vi và cách đọc số đo

- Trước: code `origin/main` **25e3bfe** được chép vào `build/T214/baseline/game` trong workspace D trước thay đổi giao diện. Cùng fixture và dữ liệu mẫu UI, không chạy director chương. `settings_reset` trước chỉ hiện settings vì bản này chưa có nút/hộp reset riêng.
- Sau: mã T-214 trên nhánh `lane-d/T-214-video-reset-readability`. Godot **4.7.2**, Forward+, RTX 3050 Laptop; output thật **1280×720** và **1920×1080**. APPDATA riêng cho trước/sau; không dùng save của người chơi.
- Nội dung mẫu điện thoại dùng `phone_preview.gd` và key thử có sẵn; giấy dùng dữ liệu dự án. Nền của fixture overlay giữ cùng ảnh hành lang cũ ở hai phía để dễ so sánh; title dùng nền mới. Đây là ảnh UI có kiểm soát, không phải ảnh chơi hết chương 1–4.
- Canvas thiết kế 1920×1080. Cỡ chữ trong ảnh = cỡ theme × tỉ lệ Control × chiều cao output / 1080. Cỡ font là kích thước em, không là số pixel đen của từng nét chữ. JSON ghi cả độ phân giải logic và output; fixture áp hệ số **2/3** khi chụp 720p, vì `get_screen_transform()` đơn lẻ không phản ánh bước co canvas trong lượt chụp này.
- **1.244 mục chữ** được ghi nhận trong 96 ảnh sau; tối thiểu **16 px**. Có **194 mục chữ dưới 16 px** trong bộ trước. Chữ trong vùng cuộn được tính cỡ dù ở ngoài vùng nhìn; điều này không chứng minh tất cả đoạn văn đã được đọc/kiểm từng dòng.

## Bảng cỡ chữ chính

| Thành phần | Cỡ tại canvas/1080p | Cỡ tại 720p |
|---|---:|---:|
| Logo tên game | 76 | 50,67 |
| Tiêu đề menu/settings | 40 | 26,67 |
| Nút/menu và nhãn mặc định | 28 | 18,67 |
| Heading nhóm settings | 30 | 20 |
| Mô tả trợ năng, tooltip | 24 | 16 |
| Tiêu đề/body/nút hộp reset | 28 | 18,67 |
| Điện thoại: trạng thái, transcript, tab, sơ đồ, trợ giúp | 24 | 16 |
| Ô nhập tin nhắn | 26 | 17,33 |
| Giấy: tiêu đề / thân / dấu | 36 / 29 / 24 | 24 / 19,33 / 16 |
| Sổ: tiêu đề / heading / thân / bằng chứng | 40 / 32 / 26 / 24 | 26,67 / 21,33 / 17,33 / 16 |
| Sổ đối chiếu: nội dung quy tắc | 25 | 16,67 |
| Phụ đề / gợi ý phím E | 30 / 28 | 20 / 18,67 |
| Bảng nối từ: nhãn / người nói / từ đang nối | 24 / 26 / 46 | 16 / 17,33 / 30,67 |
| Thẻ chương 3: tên / nhãn | 56 / 26 | 37,33 / 17,33 |
| Thẻ chương 4: kết thúc / cảm ơn / credits | 46 / 36 / 28–24 | 30,67 / 24 / 18,67–16 |

Shower UI cũng nâng các nhãn 20–23 lên 24 logical px; màn đó đặt trong thế giới 3D nên kích thước nhìn được còn phụ thuộc khoảng cách/camera. Không dùng bảng UI 2D này để chứng nhận mọi biển/màn hình 3D.

## Những gì đã kiểm

- Nhìn ảnh 720p vi/en của title, settings, cuối vùng cuộn, hộp reset, điện thoại/gọi/sơ đồ/dự đoán/tin cuối, giấy/sổ/đối chiếu, HUD, bảng nối từ, chết và thẻ chương; đối chiếu thêm ảnh 1080p. Các màn có vùng cuộn vẫn cuộn theo cơ chế cũ; không thu nhỏ font để giấu nội dung.
- Theme giấy dùng mực tối trên ảnh sợi giấy CC0; overlay dùng chữ kem trên kim loại/kính tối. Tỉ lệ tương phản tính từ cặp màu nền đặc của palette khoảng 11,2–16,6:1; đây là tham khảo palette, **không là phép chứng nhận tương phản từng pixel trên mọi cảnh game**. Trạng thái điện thoại mất kết nối vẫn giữ độ mờ 0,35 mà test cũ quy định; chưa đổi hợp đồng hiển thị trạng thái này.
- Viền focus rõ, các nút dùng focus chuẩn Godot. Test UI kiểm phím điều hướng, đổi ngôn ngữ trực tiếp, menu/confirm, save/reset, tab/điện thoại và luồng UI chương 4. Chưa chơi tay bằng tay cầm vật lý.
- Renderer fixture gọi đóng pause/settings sau chụp, kiểm Root ẩn và gameplay hết pause ngay, overlay mờ dần được giải phóng sau 250 ms. Không nhân bản Window để làm hiệu ứng. Bản headless bỏ phần chụp pixel, giữ cùng hành vi đóng menu đồng bộ.
- Glyph tiếng Việt hoa/thường, `ă â đ ê ô ơ ư` và năm dấu trong ba font qua kiểm cmap và test Godot. Không dùng chữ raster/AI để thay nội dung dịch.

## Tái tạo

Chỉ chạy Godot khi integrator đã bàn giao lượt Windows; không chạy song song với lane khác. Tại gốc repo, dùng APPDATA dưới `build/T214/capture-userdata/after`, import asset rồi chạy console Godot với:

```text
--path game res://ui/theme/t214_capture.tscn --windowed --resolution 1280x720 -- --t214-output=D:/GAME_WORK/lane-d/build/T214/after
```

Fixture tự chụp cả hai kích thước và vi/en, kiểm đóng menu, sau đó thoát bằng `App.quit()`. Để chụp trước, dùng bản sao base `25e3bfe` trong workspace D, cùng fixture; không checkout đè lên thay đổi hiện tại. Đóng gói ảnh và cỡ chữ bằng `python game/ui/theme/build_review.py`; script chỉ chép PNG nguyên vẹn và đọc JSON, không mở renderer.

Full test/check và hash bàn giao cuối ghi trong [card T-214](../../../docs/tasks/T-214-video-reset-readability.md). Không chạy FPS, bot, export hoặc sửa dữ liệu/chương trong các fixture này.
