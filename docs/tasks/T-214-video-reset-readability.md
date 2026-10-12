# T-214 — Reset hình ảnh và nâng giao diện

## Checklist

- [ ] 1. Reset riêng section video, xác nhận, vi/en và test.
- [ ] 2. Màn tiêu đề: hành lang ban đêm, logo, focus/hover và chuyển cảnh.
- [ ] 3. Pause/settings: theme chung, chất liệu, tab và chuyển động.
- [ ] 4. Điện thoại: khung smartphone, icon và toàn bộ luồng cũ.
- [ ] 5. Giấy/sổ, phụ đề, gợi ý phím, màn chết và thẻ chương.
- [ ] 6. Chữ tối thiểu 16 px tại 720p, ảnh trước/sau vi/en ở 720p/1080p.
- [ ] Full test → check PASS và push; nhả lượt Godot.

## Handoff

### 12/10/2026 — lane D, đang thực hiện

- Workspace ban đầu sạch. Đã fetch và tạo `lane-d/T-214-video-reset-readability` từ `origin/main` `25e3bfe`. T-211 giữ nguyên. Card chưa có trên origin/main lúc bắt đầu; tệp này chỉ ghi checklist/Handoff theo prompt chủ dự án, sẽ nhận nội dung card của integrator khi xuất hiện.
- Phần 1 đã viết: `Settings.reset_section(section)` reset các khóa đã biết trong đúng section, giữ khóa lạ/các section khác; load file cũ, save một lần rồi mới áp/emit. Nút `Footer/ResetVideo` và hộp xác nhận trong panel dùng chung title/pause. Reset video gồm ba khóa hiện có: head_bob, brightness, ps1_strength; không thêm setting mới. Chính sách giữ acknowledgement của reset toàn bộ vẫn nguyên.
- Key mới: `UI_RESET_VIDEO`, `UI_RESET_VIDEO_CONFIRM`, đủ vi/en. Test mới kiểm bảo toàn giá trị/kiểu và khóa lạ; file thiếu; section không hợp lệ; dữ liệu video sai; lỗi lưu giả lập tại ranh giới I/O; xác nhận/hủy và giữ tùy chọn ngoài video. Chưa chạy test mới.
- Chủ dự án đã chuyển bàn giao lượt renderer ảnh trước từ integrator Claude. Kiểm máy còn full test `D:\GAME_DEMO` PID 13128/16780, D chưa chạy Godot và không can thiệp tiến trình lane khác; chờ lượt thực trống. Sau ảnh trước sẽ nhả; ảnh sau/full test/check cần lượt mới.
- `RESULT test.ps1`: **chưa chạy**. `RESULT check.ps1`: **chưa chạy**. Chưa có ảnh trước/sau hoặc chứng nhận cỡ chữ. Chỉ kiểm tĩnh `git diff --check` tại phần 1.
- Phần 2–6 đang chuẩn bị. Font/texture mới sẽ ghi nguồn, hash và giấy phép trong CREDITS vùng D. Không sửa STATUS/DECISIONS/Review, core, project.godot, cảnh chương hoặc workspace khác.
- Yêu cầu ngoài phạm vi: lane F cân nhắc âm hover/click nhẹ; D không thêm âm. Các câu hỏi contract và lượt Godot gửi integrator Claude qua chủ dự án. Chưa có yêu cầu signal/autoload mới.
