# T-211 — Cài đặt hình ảnh và khả năng đọc trong đồ họa mới
- Lane: D | Trạng thái: **ready — G0** | Agent: lane D
- Nhánh: `lane-d/T-211-graphics-settings-readability`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 độc lập. Key/settings mới sau G1 T-207; hình nền/cảnh mẫu T-209.
- Hạn đề xuất: phiên đầu gửi khảo sát/mockup và hợp đồng đề xuất, triển khai sau G1.

## Bối cảnh
`docs/SETTINGS.md` hiện có `video.ps1_strength` và `brightness`, B áp dụng; D ghi ConfigFile rồi phát `settings_changed`. Hướng gần chân thực cần lựa chọn hình ảnh dễ hiểu và chữ vẫn đọc được trong bóng tối. Không thêm gợi ý luật theo D-038/D-055 hoặc thay lời đã duyệt.

## Việc
1. **G0:** kiểm menu video, brightness, PS1, độ phân giải, phụ đề/điện thoại/giấy/biển và credits. Ghi các điểm dựa vào pipeline PS1; làm mockup ở vùng D và đề xuất key/type/default/range/consumer cho web/integrator.
2. **Sau G1:** triển khai những setting có backend thật đã thống nhất, ưu tiên mức Low/Medium và độ sáng; giá trị chi tiết dựa trên pilot, chưa tuyên bố preset đạt FPS. D sở hữu phần lưu/menu, B/core sở hữu phần áp dụng theo contract. Không thêm key vào file người dùng trước khi integrator cập nhật SETTINGS.
3. Xử lý file settings cũ/thiếu/sai kiểu theo hợp đồng, reset và load scene; giữ ngôn ngữ/âm lượng/input của người dùng. Chuyển mặc định khỏi PS1 chỉ khi G3 được duyệt, tránh âm thầm bật/tắt trong giai đoạn thử.
4. Kiểm chữ trên nền sáng/tối, giấy tờ, phone và subtitle ở 1080p cùng mức render thấp hơn. Thêm key UI vi/en cần thiết, không sửa block lời sinh tự động. Biển trong thế giới B sở hữu; D cung cấp yêu cầu chữ/localization, B gắn vào model.
5. Cập nhật hiển thị credits cho nguồn được nhập thật, có tên công cụ AI/license đúng; không tuyên bố Private là CC0. Nếu cần đổi cấu trúc credits ngoài vùng D thì gửi yêu cầu.

## Được phép sửa
Vùng D: `game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, thêm key trong `game/localization/strings.csv`, `game/tests/ui/`; Handoff/checklist card. Không sửa `docs/SETTINGS.md`, rendering, project.godot, main scene hoặc asset B. Không tạo control có vẻ dùng được nhưng không áp dụng gì.

## Test và bằng chứng
- Giá trị mặc định/thiếu/sai kiểu, lưu trước signal, khôi phục/reset, file cấu hình cũ không mất tùy chọn khác. Test phần consumer thật sau khi B/core ghép, không chỉ test widget đổi nhãn.
- UI đọc được, focus/chuột/menu pause vẫn đúng, không che tâm ngắm/tương tác; có ảnh so sánh vi/en. Chưa có cảnh mới ghi rõ chỉ test nền mẫu.
- `pwsh tools/test.ps1`, `pwsh tools/check.ps1` đầy đủ. Không chạy FPS để tự chọn preset khi chưa được phép.

## Checklist hoàn thành
- [ ] G0: khảo sát/mockup và đề xuất contract
- [ ] G1: settings thống nhất trước khi dùng chung
- [ ] Preset có tác dụng thật và migration an toàn
- [ ] Kiểm khả năng đọc/vi/en và credits nhập thật
- [ ] Full test/check PASS, Handoff ghi giới hạn hình ảnh/performance

## Handoff (agent điền)
Chưa bắt đầu; chưa có settings mới được chốt.

## Review (integrator)
Chưa review triển khai.
