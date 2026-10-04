# T-150 — Chương 1 "Tổng tắc": hợp đồng chung, luồng chương, kịch bản, ghép
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude
- Phụ thuộc: thiết kế `docs/design/STORY.md` v2 (D-034, D-035)
- **Hạn chơi thử chương 1: 2026-10-07.**

## Mục tiêu
Chương 1 (4:00–6:00, khoảng 50 phút): mở đầu, vòng 1 (bị giam trong phòng, nhóm chat), vòng 2 (quản lý kiểm tra phòng). Người chơi ở gần như suốt chương trong **phòng 407**. Core lo: hợp đồng giữa các lane, luồng chương, kịch bản (loa, nhóm chat, đường đi của quản lý), dữ liệu, ghép và cảnh chết.

## Phần 1 — Hợp đồng chung (xong)
- `5f31722`:
  - phím `crouch` (C, Ctrl), `phone` (Q), `flashlight` (F), `hold_breath` (Space);
  - signal sinh tồn, điện thoại, câu đố, thực thể;
  - `Progress`, `GameState.chapter`, `App.start_chapter(n)`;
  - `MessageData`, `PuzzleData`; chứng cứ trong `RuleSystem`.
- Bổ sung cho v2:
  - signal `phone_call_incoming`, `phone_call_answered`, `chat_member_changed`, `chat_choice_requested`, `chat_choice_made`, `survivor_count_changed`;
  - `MessageData.spoken` (câu nói trong cuộc gọi nhóm, có giọng).

## Số giường phòng 407 (dùng chung mọi lane)
| Giường | Vị trí | Chủ |
|---|---|---|
| 1 | Tầng trên, giường tầng A | Phúc |
| 2 | Tầng dưới, giường tầng A | Việt |
| 3 | Tầng dưới, giường tầng B | **Trung** |
| 4 | Tầng trên, giường tầng B | Đạt |

## Phần 2 — Kịch bản và dữ liệu
- Loa: lời cảnh báo mở đầu, Tổng tắc 5 điều, quy tắc vòng 1, vòng 2, số người sống sót. Câu chữ **viết lại**, không chép video.
- Nhóm chat: Minh Nhật và khoảng 6 thành viên có tên và giọng riêng; các câu thoại theo thời gian; các lựa chọn trả lời của người chơi. Khi quản lý tới phòng của một thành viên, nhóm nghe được cách trả lời và cái chết của người đó.
- Câu đố vòng 1: điện thoại sắp hết pin; sạc nằm trong tủ khóa số của Đạt; mã lấy từ thẻ sinh viên hoặc sổ tay của Đạt.
- Cám dỗ rời phòng ở vòng 1: tiếng gõ cửa xin vào, tiếng bạn quen gọi ngoài hành lang.

## Phần 3 — Luồng và ghép
- Luồng chương mới thay luồng demo:
  - **Mở đầu:** 60 giây để rời giường; nhà vệ sinh chung; quay về thấy ba bạn đã chết.
  - **Tổng tắc:** từ đây ra khỏi cửa là chết (vùng ngưỡng cửa).
  - **Vòng 1**, rồi **vòng 2:** quản lý đi các phòng (nghe qua nhóm chat và qua tầng) rồi tới 407.
  - Chết thì: màn chết, rồi tải checkpoint.
- Ghép việc của T-151…T-159; checkpoint ở đầu mỗi vòng và trước khi quản lý tới 407.
- `Progress.unlock(2)` khi xong chương.

## Checklist
- [x] Phần 1: hợp đồng chung, test PASS
- [ ] Phần 2: kịch bản, dữ liệu, câu chữ (vi/en)
- [ ] Phần 3: ghép, chơi trọn chương 1
- [ ] Bot T-157 PASS
- [ ] Bản build cho chủ dự án chơi thử

## Handoff
