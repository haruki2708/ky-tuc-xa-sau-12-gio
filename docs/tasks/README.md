# Task cards

- Mỗi task là một file `T-xxx-ten.md`.
- Trạng thái: `todo` → `doing` → `review` (đã push, chờ integrator) → `done` hoặc `changes` (cần sửa lại).
- Agent chỉ được sửa mục **Checklist** và **Handoff** trong card của mình. Phần còn lại do integrator viết.

## Mẫu
```
# T-xxx — Tiêu đề
- Lane: X | Trạng thái: todo | Agent: (chủ dự án điền)
- Nhánh: lane-x/T-xxx-ten
- Phụ thuộc: ...
## Mục tiêu
## Được phép sửa
## Yêu cầu
## Checklist hoàn thành
## Cách kiểm tra
## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
```

## Chấm task thử tuần đầu (T-101…T-105)
Integrator chấm mỗi tiêu chí từ 1 đến 5. Chủ dự án ghi thêm tiêu chí 7.

| # | Tiêu chí | Cách đo |
|---|---|---|
| 1 | Đúng phạm vi file | Diff có chạm file ngoài lane không |
| 2 | Đạt checklist | Số mục đạt trên tổng số mục |
| 3 | Test | Test có pass không; test tự viết có kiểm tra điều quan trọng không |
| 4 | Chất lượng code | Dễ đọc, đúng quy ước, không thừa |
| 5 | Bàn giao trung thực | Mục Handoff khớp với thực tế |
| 6 | Số vòng sửa | Phải yêu cầu sửa lại bao nhiêu lần |
| 7 | Hao hạn mức và thời gian | Chủ dự án ghi: mất bao lâu, có bị chạm giới hạn không |

**Sau khi chấm:**
- Agent điểm cao giữ lane khó (A, B).
- Agent điểm thấp chuyển sang việc hẹp hơn, hoặc cân nhắc hủy tài khoản.

| Agent (tên trong SpaceVibe Deck) | Lane thử | Điểm 1–6 | Ghi chú 7 |
|---|---|---|---|
| | A | | |
| | B | | |
| | C | | |
| | D | | |
| | E | | |
