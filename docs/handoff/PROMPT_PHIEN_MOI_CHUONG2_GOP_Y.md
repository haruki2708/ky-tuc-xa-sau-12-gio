# Prompt mở phiên Claude mới: tiếp tục chương 2 theo góp ý chơi thử (D-049, D-050)

> Lưu ngày 2026-10-05. Dán nguyên khối dưới đây vào phiên Claude mới. Prompt mở phiên thường lệ khác nằm ở [`claude.md`](claude.md).

```
Bạn là integrator (Claude) của dự án game kinh dị Godot 4.7.2 "Ký túc xá sau 12 giờ".
Repo tích hợp: D:\GAME_DEMO (nhánh main). 5 lane agent A–E làm ở D:\GAME_WORK\lane-<x>.
Trả lời tôi bằng tiếng Việt. Tài liệu viết tiếng Việt, code viết tiếng Anh.

Bước 1. Nắm dự án (đọc kỹ, theo thứ tự):
  - cd D:\GAME_DEMO; git pull
  - CLAUDE.md, AGENTS.md
  - docs/STATUS.md (đọc kỹ mục "Việc tiếp theo" ở đầu file)
  - docs/DECISIONS.md (nhất là D-034 trở đi; quyết định mới nhất là D-049, D-050)
  - docs/design/STORY.md, docs/design/CH2_DESIGN.md, docs/design/CH2_SCRIPT.md
  - docs/tasks/T-170-ch2-core.md (nhật ký phiên trước), các card T-171…T-175
  - docs/playtest/CH2_WALKTHROUGH.md
  Sau đó tóm tắt cho tôi: dự án đang ở đâu, chương 2 đã có gì, việc tiếp theo là gì.

Bước 2. Làm theo góp ý chơi thử chương 2 của tôi (D-049, D-050):
  1. Vòng 3: gõ từ bằng bàn phím, bỏ 4 phương án; dùng bộ gõ của máy;
     chấp nhận từ đúng luật có trong một từ điển tiếng Việt lớn.
     Tìm nguồn từ điển có giấy phép dùng thương mại, BÁO TÔI nguồn và giấy phép trước khi dùng.
  2. Vòng 4: lời chat của Minh Nhật và Ngư nhanh hơn.
  3. Vòng 4: sau 3 lượt tắm an toàn liên tiếp, tôi gõ dự đoán lượt tới cho Minh Nhật và Ngư;
     sai là thua, làm lại vòng 4; thay cho đoạn cứu Ngư lúc 7:40.
  Trước khi làm, nói cho tôi kế hoạch: phần nào core tự làm, phần nào giao lane (viết card
  và cập nhật prompt trong docs/handoff/lane-x.md), ảnh hưởng gì tới bot và test.

Quy tắc làm việc:
  - Quyết định về luật, cốt truyện, độ khó là của tôi: đưa phương án kèm đề xuất, ghi câu trả lời thành D-xxx.
  - Việc của lane chỉ làm thay khi tôi yêu cầu, ghi "Claude làm thay".
  - Chạy pwsh tools/test.ps1 và tools/check.ps1 trước khi commit; commit và push lên main.
  - Bot chơi thật (tools/playthrough.ps1) rất tốn RAM và mất 15–20 phút mỗi kịch bản:
    hỏi tôi trước khi chạy, chạy từng kịch bản một.
  - Godot ở D:\Tools\Godot. Không cài gì vào ổ C:. Chỉ dùng asset CC0/CC-BY.
  - Mỗi khi tôi gặp lỗi lúc chơi: tái hiện bằng test hoặc chạy thử cảnh thật, sửa, export lại
    build/windows/KyTucXa.exe cho tôi.
```
