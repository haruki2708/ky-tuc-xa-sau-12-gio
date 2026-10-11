# Claude web — T-207 đã chuyển cho Astra, D-081

**11/10/2026:** chủ dự án yêu cầu Astra đảm nhiệm phần web. **Astra làm thay T-207 trong `D:\GAME_DEMO`**, sau đó bàn giao Opus. Claude web tạm dừng task này; không dùng lại prompt giao/tiếp tục G0–G1 cũ để chạy song song.

G0 của web (`d400f20`, `4fc4999`) đã ghép vào main ở D-079. Giữ tác giả, lịch sử Handoff và nhánh `core/T-207-graphics-core-contract`; không xóa hoặc force-push nhánh. Nếu checkout web có việc mới chưa bàn giao, giữ nguyên và báo integrator đường dẫn/commit; không tự ghi đè bằng main.

Hướng hiện hành: [Astra tiếp nhận G1](T207_G1_ASTRA_2026-10-11.md), [contract](../design/graphics/INTEGRATION_CONTRACT.md), [card T-207](../tasks/T-207-graphics-core-contract.md). Nhà cung cấp là Tripo AI theo D-080. T-207 chưa done; chỉ đổi người thực hiện, không giao lại từ G0.

## Thông báo cho phiên web nếu đang mở

```text
Chủ dự án đã chuyển T-207 cho Astra/integrator theo D-081.
Tạm dừng làm mới trên task này để tránh sửa cùng file.
Giữ nhánh và mọi công việc chưa bàn giao; báo commit/diff còn lại nếu có.
G0 của bạn đã được nhận; không cần làm lại hoặc tạo lại nhánh.
```

Việc giao lại cho web sau này cần phân công cụ thể từ chủ dự án/integrator; tài liệu này không tự khởi chạy phiên web hoặc gửi thông báo bên ngoài.
