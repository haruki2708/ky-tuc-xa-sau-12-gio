# Claude Code trên web — Lane D (UI và Đa ngôn ngữ), D-107

**14/10/2026, D-107:** chủ dự án cho agent lane D cũ nghỉ; **Claude Code trên web (claude.ai/code) nhận lane D**. Lane A, B, C, F giữ nguyên.

Vùng của lane D: `game/ui/`, `game/scripts/ui/`, `game/localization/`, `game/assets/fonts/` và các test UI trong `game/tests/ui/`. Lịch sử việc đã làm: T-211 (cài đặt hình ảnh, khả năng đọc), T-214 (giao diện mới, D-091/D-094). Prompt cũ của agent trước giữ ở [lane-d.md](lane-d.md) làm lịch sử.

Lịch sử phiên web trước: T-192 (thay lane B), T-201, T-204 (thay core), G0 của T-207; đều đã ghép.

**Việc hiện tại: chưa có.** Khi có việc giao diện, integrator viết card `docs/tasks/T-xxx-*.md` và điền tên task vào mục 1.

## Giới hạn của máy cloud
- Phiên web chạy Linux trên cloud, clone repo từ GitHub, làm trên nhánh riêng rồi push. Integrator (Claude ở máy chủ dự án) review, chạy test trên Windows và merge.
- Không có Godot sẵn, phải tải. **Không có card đồ họa:** không chụp được ảnh giao diện, không đo FPS, không xuất `.exe`, không chơi thử.
- Test headless chạy được. Ảnh trước/sau ở 720p và 1080p do integrator chụp trên Windows khi review; trong Handoff phải liệt kê màn nào cần chụp.

## 1. Prompt giao task (dán nguyên khối vào phiên web, chọn repo `tuaanh666/ky-tuc-xa-sau-12-gio`)
```
Bạn là agent Lane D (UI và Đa ngôn ngữ) của game kinh dị "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript), theo D-107 (Claude Code web nhận lane D).
Task: <T-xxx, tên card>. Trả lời tôi bằng tiếng Việt. Tài liệu viết tiếng Việt, code viết tiếng Anh.

Bước 1. Chuẩn bị máy (Linux, không cần sudo; mọi thứ cài vào ~/tools):
  - git lfs install; git lfs pull
  - git fetch origin; tạo nhánh lane-d/<T-xxx-ten-ngan> từ origin/main mới nhất (nếu nhánh đã có trên origin thì switch và pull).
  - Tải Godot 4.7.2 bản Linux:
      mkdir -p ~/tools && cd ~/tools
      curl -LO https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
      unzip -o Godot_v4.7.2-stable_linux.x86_64.zip && chmod +x Godot_v4.7.2-stable_linux.x86_64
      export GODOT=~/tools/Godot_v4.7.2-stable_linux.x86_64
  - Chạy test trực tiếp (không cần PowerShell):
      $GODOT --headless --path game --import
      $GODOT --headless --path game res://tests/run_tests.tscn            (cả bộ)
      $GODOT --headless --path game res://tests/run_tests.tscn -- --filter=ui
  - Chạy thử cảnh thật: tạo scene tạm .tscn trong game/_tmp (xóa trước khi commit). KHÔNG dùng `godot -s script.gd`
    (chế độ -s không nạp autoload EventBus nên báo lỗi giả).
Bước 2. Đọc kỹ, theo thứ tự: AGENTS.md, docs/STATUS.md, docs/DECISIONS.md (D-091, D-094, D-102, D-107 và các D card nhắc tới),
        docs/handoff/web.md, card của task, Handoff/Review của T-211 và T-214, game/ui/theme/, game/assets/fonts/CREDITS.md, game/tests/ui/.
Bước 3. TRƯỚC KHI SỬA GÌ: chạy cả bộ test một lần trên origin/main và lưu kết quả (dòng RESULT và tên test FAIL).
        Test nào đã FAIL sẵn ở lượt này là do môi trường Linux, KHÔNG sửa chúng, chỉ ghi vào Handoff.
Bước 4. Làm task trong card, CHỈ sửa file trong mục "Được phép sửa" của card.
        Cần sửa file ngoài phạm vi (core game/scripts/core/, cảnh chương, project.godot, âm thanh lane F) thì ghi "Yêu cầu thay đổi" vào Handoff, không tự sửa.
        Font chỉ OFL/CC0/CC-BY có đủ dấu tiếng Việt; texture UI CC0/CC-BY; ghi CREDITS.md và file giấy phép.
        Không đổi nội dung chữ, key cũ, luồng chơi, luật, lời thoại; chỉ thêm key UI_ mới (vi + en). Giữ tên node/đường dẫn mà script và test dùng.
Bước 5. Trước khi kết thúc: chạy lại cả bộ test; không được có test FAIL mới so với lượt ở Bước 3.
        Commit nhỏ, message dạng "T-xxx: ..."; git push -u origin lane-d/<T-xxx-ten-ngan>.
        Điền mục Handoff trong card (ghi "Claude Code web, lane D, D-107"; kết quả test hai lượt; danh sách màn integrator cần chụp 720p/1080p, vi/en;
        những gì chưa kiểm được trên máy không có card đồ họa), commit và push lại.
Bước 6. Trả lời tôi ngắn gọn: (1) đã làm gì, (2) kết quả test hai lượt, (3) checklist mục nào chưa đạt và vì sao,
        (4) yêu cầu thay đổi ngoài phạm vi, (5) có bị chặn ở đâu không.
Quy tắc: KHÔNG push lên main, không mở pull request vào main trừ khi tôi bảo, không thêm plugin hay addon,
không đổi phiên bản Godot, không đoán về luật chơi hay cốt truyện (ghi câu hỏi vào Handoff). Không đo FPS, không chạy bot.
Ghi trung thực: chưa test thì nói chưa test.
```

## 2. Prompt tiếp tục (phiên mới hoặc phiên cũ mất ngữ cảnh)
```
Tiếp tục <T-xxx> (lane D, D-107) theo docs/handoff/web.md mục 1. Làm lại Bước 1 (máy cloud có thể đã mất ~/tools),
git switch lane-d/<T-xxx-ten-ngan>; git pull. Đọc mục Handoff trong card để biết lần trước dừng ở đâu,
kiểm tra git status và git log -5, làm tiếp các mục checklist chưa xong, kết thúc theo Bước 5–6.
```

## 3. Prompt yêu cầu sửa (khi integrator trả task về)
```
Integrator đã review <T-xxx> và yêu cầu sửa: xem mục "Review" trong card trên origin/main
(git fetch; git show origin/main:docs/tasks/<card>.md). Làm lại Bước 1 của docs/handoff/web.md nếu cần,
rebase nhánh lên origin/main, sửa từng ý, chạy test hai lượt như trước, push, cập nhật Handoff và báo lại theo 5 mục.
```
