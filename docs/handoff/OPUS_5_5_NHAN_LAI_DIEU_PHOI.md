# Opus 5.5 nhận lại điều phối sau Astra

Viết ngày 10/10/2026. Đây là điểm vào cho **phiên Claude Code ở máy dùng Opus 5.5**; chủ dự án là người dùng. Astra chỉ thay điều phối trong 10–11/10/2026.

## Đọc theo thứ tự

1. `AGENTS.md`, `CLAUDE.md`, `docs/STATUS.md`.
2. `docs/handoff/NHAT_KY_ASTRA_2026-10-10_11.md` — kết quả thực hiện, commit/build, giới hạn kiểm tra.
3. `docs/DECISIONS.md` D-076, D-077 và `docs/design/GRAPHICS_UPGRADE_PLAN.md`.
4. T-207…T-212 cùng Handoff/Review; dùng `git fetch` rồi kiểm nhánh thực, không suy ra agent đã chạy chỉ vì có card.
5. `docs/handoff/ASTRA_DIEU_PHOI_2_NGAY.md` là ảnh chụp trạng thái trước giai đoạn mới; các điểm thay đổi ưu tiên xem D-076/D-077 và nhật ký.

## Thay đổi ưu tiên do người dùng

Logic về cơ bản đã ổn; ưu tiên đồ họa **gần chân thực**, máy tham chiếu RTX 3050 Laptop. Người dùng dự định mua Meshy Pro tối 10/10, đã yêu cầu giao sáu lane và xác nhận còn hạn mức. Chưa xác nhận đã mua, API kết nối, ngân sách chi hay license Private. Không tự coi G2 đã mở.

Sáu gói: web T-207 core/contract; A T-208 adapter gameplay–visual; B T-209 art/pilot; C T-210 asset QA và công cụ Meshy; D T-211 settings/readability; E T-212 audio/marker. Prompt §1 đã chuẩn bị. Việc gửi prompt vào các phiên bên ngoài do người dùng thực hiện; kiểm Handoff để biết phiên nào thực sự nhận/chạy.

## Cách tiếp tục

- Làm trong `D:\GAME_DEMO` trên main, kiểm sạch rồi pull; không sửa workspace lane.
- Review G0 và chốt G1 trước khi các lane phụ thuộc API/settings mới. Cảnh mẫu trước, thay toàn game sau; giữ logic, nav/collision và sự kiện.
- A không sửa visual scene vùng B; B không sửa gameplay A; D không tự đổi hợp đồng settings; web chỉ được sửa core/docs ghi trong card, không có quyền làm B thay.
- Meshy operator ở máy: chỉ chạy khi có key cục bộ, giấy phép hợp lệ và trần chi do chủ dự án giao; tránh nhiều lane tạo trùng một asset.
- Bot chương 3–4 chưa được phép; đo FPS vẫn cần chủ dự án cho theo bàn giao. Test/check bắt buộc trước commit. Máy cloud không chứng minh hình ảnh hoặc FPS.
- Chương 1–2 tạm chốt, D-072 còn đoạn chưa chơi tay. Chương 3 lần cuối người dùng dừng ở tầng 1; chương 4 chưa có xác nhận chơi tay. Ưu tiên đồ họa không xóa các khoản kiểm tra này.
- D-059 vẫn chưa bắt đầu. Không thêm story/save/cơ chế mới dưới nhãn nâng đồ họa.

## Prompt tiếp nhận

```text
Bạn là Claude Code ở máy dùng Opus 5.5, nhận lại vai trò integrator của game Ký túc xá sau 12 giờ.
Làm trong D:\GAME_DEMO, không sửa D:\GAME_WORK\lane-a đến lane-e.
Đọc docs/handoff/OPUS_5_5_NHAN_LAI_DIEU_PHOI.md theo thứ tự đã ghi.
Kiểm Git, đọc nhật ký Astra và Handoff thật của T-207 đến T-212.
Tiếp tục kế hoạch đồ họa gần chân thực theo D-076/D-077, giữ logic game.
Phân biệt đã giao card với đã chạy/đã review/đã merge; xác minh trạng thái Meshy và các mốc G0–G4.
Trả lời bằng tiếng Việt, nêu việc đã xác nhận và bước tiếp theo, rồi làm trong phạm vi đã được giao.
```
