# Prompt mở phiên chat mới với Claude (integrator)

Claude không nhớ nội dung các phiên chat trước. Mọi thứ cần biết nằm trong repo (`docs/STATUS.md`, `docs/DECISIONS.md`, `docs/tasks/`, `docs/design/`). Mở phiên mới thì dán một trong các prompt dưới đây.

## 1. Mở phiên bình thường (dán nguyên khối)
```
Bạn là integrator (Claude) của dự án game "Ký túc xá sau 12 giờ" (Godot 4.7.2), repo ở D:\GAME_DEMO (nhánh main),
5 lane agent A–E làm ở D:\GAME_WORK\lane-<x>.
Trước khi làm gì: git pull trong D:\GAME_DEMO, rồi đọc CLAUDE.md, AGENTS.md, docs/STATUS.md, docs/DECISIONS.md
(đặc biệt các quyết định gần nhất) và docs/tasks/BACKLOG.md.
Tóm tắt cho tôi bằng tiếng Việt, ngắn gọn: dự án đang ở đâu, lane nào đang làm gì, việc gì đang chờ tôi quyết.
Sau đó chờ tôi giao việc.
```

## 2. Làm thiết kế mới: cốt truyện, nhiệm vụ, đồ họa (D-028)
Dán prompt mục 1, rồi dán thêm khối này và điền phần của bạn:
```
Hôm nay làm thiết kế mới theo D-028 (lùi ngày đăng để cải thiện game). Đọc thêm docs/design/STORY.md (thiết kế v2 hiện hành),
docs/design/LAYOUT.md; phần chơi cũ ở docs/design/archive/.
Ý tưởng của tôi (chưa đủ thì hỏi lại tôi, đừng tự đoán phần thiết kế):

1. Cốt truyện: <bối cảnh, nhân vật, bí ẩn, kết thúc>
2. Cơ chế game: <người chơi làm gì là chính>
3. Nhiệm vụ theo mốc giờ: <chuỗi việc trong đêm>
4. Thực thể siêu nhiên: <hình dạng, hành vi, luật để né>
5. Hù dọa và kịch tích: <khoảnh khắc muốn có, cao trào>
6. Nhạc và âm thanh: <cảm giác, game/bài tham khảo>
7. Đồ họa: <tên game tham khảo, ảnh đính kèm, thích điểm nào>
8. Thời lượng mong muốn: <phút>

Việc của bạn: viết lại thiết kế (RULES.md, GDD.md, LAYOUT.md nếu đổi bản đồ) và một bản định hướng
hình ảnh, giữ lại những gì đã làm được; liệt kê chỗ cần tôi quyết; ước lượng khối lượng theo lane.
Chỉ viết task cho lane sau khi tôi duyệt thiết kế.
```

## 3. Review khi các lane làm xong
```
Lane <A/B/C/D/E> đã xong T-<số>. Review lần lượt cho tôi: đọc Handoff trong task card, xem diff nhánh,
chạy test/check (và tools/playthrough.ps1 -Scenario all nếu đụng tới luồng chơi), merge nếu đạt,
cập nhật STATUS và đẩy lên main. Báo kết quả bằng tiếng Việt.
```

## 4. Chơi thử
```
Mở game cho tôi chơi thử. Chơi xong tôi sẽ góp ý.
```

## Ghi chú
- Đóng editor Godot đang mở `D:\GAME_DEMO` trước khi Claude merge.
- Muốn Claude làm thay một lane thì nói rõ; task sẽ được ghi "Claude làm thay".
- Ảnh tham khảo đồ họa: kéo thả ảnh vào khung chat cùng prompt mục 2.
