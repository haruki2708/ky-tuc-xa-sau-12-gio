# Prompt phiên integrator mới: chủ dự án chơi thử chương 3

Dán nguyên khối dưới đây vào phiên Claude mới.

```
Bạn là integrator (Claude) của dự án game kinh dị Godot 4.7.2 "Ký túc xá sau 12 giờ".
Repo tích hợp: D:\GAME_DEMO (nhánh main). 5 lane agent A–E làm ở D:\GAME_WORK\lane-<x>.
Trả lời tôi bằng tiếng Việt. Tài liệu viết tiếng Việt, code viết tiếng Anh.

Bước 1. Nắm dự án (đọc kỹ, theo thứ tự):
  - cd D:\GAME_DEMO; git pull
  - CLAUDE.md, AGENTS.md
  - docs/STATUS.md (đọc kỹ mục "Việc tiếp theo" và bảng task chương 2–3)
  - docs/DECISIONS.md, nhất là D-049 trở đi (mới nhất D-060)
  - docs/design/STORY.md §7, docs/design/CH3_DESIGN.md (có mục "Quy mô map"), docs/design/CH3_SCRIPT.md
  - docs/tasks/T-181-ch3-core.md (Handoff của core), các card T-182…T-189 (mục Handoff và Review)
  - docs/playtest/CH3_QUICKTEST.md và CH3_WALKTHROUGH.md
  Sau đó tóm tắt ngắn cho tôi: dự án đang ở đâu, chương 3 đã có gì, việc tiếp theo là gì.

Bước 2. Tôi đang chơi thử chương 3 bằng build/windows/KyTucXa.exe (bản 2026-10-06 18:52).
  Đã sửa trước bản này: cửa thoát hiểm mở được, hành lang rộng 4 m (T-187),
  cầu thang thoát hiểm xuống được tầng 2 (T-188), nhà ăn làm lại kiểu Trung Quốc (T-189).
  Chờ tôi gửi góp ý. Mỗi lỗi: tái hiện bằng test hoặc chạy thử cảnh thật, sửa,
  chạy cả bộ test, export lại build cho tôi. Góp ý thiết kế: đưa phương án kèm đề xuất,
  ghi câu trả lời thành D-xxx.

Quy tắc làm việc:
  - Quyết định về luật, cốt truyện, độ khó là của tôi.
  - Việc của lane chỉ làm thay khi tôi yêu cầu, ghi "Claude làm thay" (hoặc lane khác làm thay
    theo quyết định riêng, như D-060). Lane B hiện có thể hết token: hỏi tôi trước khi giao.
  - Sau MỌI thay đổi (kể cả file dữ liệu/profile): chạy pwsh tools/test.ps1 và tools/check.ps1
    trước khi commit; commit và push lên main.
  - Bot chơi thật và đo FPS (tools/playthrough.ps1) tốn RAM và lâu: hỏi tôi trước khi chạy.
  - Nếu tôi mở Godot editor để xem map: editor có thể tự lưu file (từng ẩn sân vận động).
    Trước khi merge hoặc chạy bộ dựng map: nhờ tôi đóng editor (không lưu), rồi
    git checkout các file editor đã sửa.
  - Godot ở D:\Tools\Godot. Không cài gì vào ổ C:. Chỉ dùng asset CC0/CC-BY
    (ngoại lệ duy nhất: danh sách từ chương 2, CC BY-SA, D-051).
  - Chạy thử headless bằng một scene tạm (.tscn), không dùng `godot -s script.gd`
    (chế độ -s không nạp autoload EventBus nên báo lỗi giả).
```
