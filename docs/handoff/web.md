# Claude Code trên web — Lane F (Âm thanh), D-108

**14/10/2026, D-108:** chủ dự án đổi ý so với D-107: **Claude Code trên web (claude.ai/code, Sonnet 5.5) nhận lane F (âm thanh)**; lane D chuyển cho Gemini 3.8 Flash trong Antigravity (xem [lane-d.md](lane-d.md) mục 0). Lane A, B, C giữ nguyên.

Vùng của lane F: `game/audio/`, `game/scripts/audio/`, âm thanh/giọng trong `game/audio/voice/`, credits âm thanh và test trong `game/tests/audio/`. Lịch sử: lane E (đến D-078), rồi lane F GPT Plus: T-212 (âm thanh gắn vật thể cho đồ họa mới, chuông báo cháy; D-082 nhận phần đề xuất). Prompt cũ giữ ở [lane-f.md](lane-f.md).

Lịch sử phiên web trước: T-192 (thay lane B), T-201, T-204 (thay core), G0 của T-207; đều đã ghép.

**Việc hiện tại: chưa có.** T-218 đã ghép (D-111). Khi có việc âm thanh, integrator viết card `docs/tasks/T-xxx-*.md` và điền tên task vào mục 1.

**Chỉ có trên máy chủ dự án, phiên web không thấy:** thư mục `D:\GAME_WORK\lane-f` còn một stash cũ ("T-212: preserve pending D-080 handoff before D-081 rebase"). Integrator giữ nguyên; nếu task cần nội dung đó, integrator đưa lên nhánh trước.

## Giới hạn của máy cloud
- Phiên web chạy Linux trên cloud, clone repo từ GitHub, làm trên nhánh riêng rồi push. Integrator (Claude ở máy chủ dự án) review, chạy test trên Windows và merge.
- Không có Godot sẵn, phải tải. **Không có card đồ họa và không có loa:** không nghe được âm thanh, không chụp ảnh, không đo FPS, không xuất `.exe`, không chơi thử.
- Test headless chạy được. Việc nghe thử do chủ dự án làm trên Windows; trong Handoff phải liệt kê âm nào cần nghe, ở cảnh/chương nào. Âm thanh chỉ CC0/CC-BY (ghi credits); giọng TTS cần công cụ nào thì ghi rõ trong Handoff (máy cloud không có espeak-ng như máy Windows).

## 1. Prompt giao task (dán nguyên khối vào phiên web, chọn repo `tuaanh666/ky-tuc-xa-sau-12-gio`, model Sonnet 5.5)
```
Bạn là agent Lane F (Âm thanh) của game kinh dị "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript), theo D-108 (Claude Code web nhận lane F).
Task: <T-xxx, tên card>. Trả lời tôi bằng tiếng Việt. Tài liệu viết tiếng Việt, code viết tiếng Anh.

Bước 1. Chuẩn bị máy (Linux, không cần sudo; mọi thứ cài vào ~/tools):
  - git lfs install; git lfs pull
  - git fetch origin; tạo nhánh lane-f/<T-xxx-ten-ngan> từ origin/main mới nhất (nếu nhánh đã có trên origin thì switch và pull).
  - Tải Godot 4.7.2 bản Linux:
      mkdir -p ~/tools && cd ~/tools
      curl -LO https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
      unzip -o Godot_v4.7.2-stable_linux.x86_64.zip && chmod +x Godot_v4.7.2-stable_linux.x86_64
      export GODOT=~/tools/Godot_v4.7.2-stable_linux.x86_64
  - Chạy test trực tiếp (không cần PowerShell):
      $GODOT --headless --path game --import
      $GODOT --headless --path game res://tests/run_tests.tscn            (cả bộ)
      $GODOT --headless --path game res://tests/run_tests.tscn -- --filter=audio
  - Chạy thử cảnh thật: tạo scene tạm .tscn trong game/_tmp (xóa trước khi commit). KHÔNG dùng `godot -s script.gd`
    (chế độ -s không nạp autoload EventBus nên báo lỗi giả).
Bước 2. Đọc kỹ, theo thứ tự: AGENTS.md, docs/STATUS.md, docs/DECISIONS.md (D-078, D-082, D-108 và các D card nhắc tới),
        docs/handoff/web.md, card của task, Handoff/Review của T-212, game/audio/, game/scripts/audio/, game/tests/audio/, credits âm thanh.
Bước 3. TRƯỚC KHI SỬA GÌ: chạy cả bộ test một lần trên origin/main và lưu kết quả (dòng RESULT và tên test FAIL).
        Test nào đã FAIL sẵn ở lượt này là do môi trường Linux, KHÔNG sửa chúng, chỉ ghi vào Handoff.
Bước 4. Làm task trong card, CHỈ sửa file trong mục "Được phép sửa" của card.
        Cần sửa file ngoài phạm vi (core game/scripts/core/, cảnh chương, project.godot, giao diện lane D) thì ghi "Yêu cầu thay đổi" vào Handoff, không tự sửa.
        Âm thanh chỉ CC0/CC-BY, ghi nguồn + giấy phép. Giữ âm lượng nhỏ, dễ chịu (chủ dự án thích âm nhỏ). Không đổi lời thoại hay strings.csv.
        Giữ tên node/bus/đường dẫn mà script và test dùng; không sửa game/default_bus_layout.tres nếu card không cho phép.
Bước 5. Trước khi kết thúc: chạy lại cả bộ test; không được có test FAIL mới so với lượt ở Bước 3.
        Commit nhỏ, message dạng "T-xxx: ..."; git push -u origin lane-f/<T-xxx-ten-ngan>.
        Điền mục Handoff trong card (ghi "Claude Code web, lane F, D-108"; kết quả test hai lượt; danh sách âm chủ dự án cần nghe thử (cảnh/chương);
        những gì chưa kiểm được trên máy không có loa và card đồ họa), commit và push lại.
Bước 6. Trả lời tôi ngắn gọn: (1) đã làm gì, (2) kết quả test hai lượt, (3) checklist mục nào chưa đạt và vì sao,
        (4) yêu cầu thay đổi ngoài phạm vi, (5) có bị chặn ở đâu không.
Quy tắc: KHÔNG push lên main, không mở pull request vào main trừ khi tôi bảo, không thêm plugin hay addon,
không đổi phiên bản Godot, không đoán về luật chơi hay cốt truyện (ghi câu hỏi vào Handoff). Không đo FPS, không chạy bot.
Ghi trung thực: chưa test thì nói chưa test.
```

## 2. Prompt tiếp tục (phiên mới hoặc phiên cũ mất ngữ cảnh)
```
Tiếp tục <T-xxx> (lane F, D-108) theo docs/handoff/web.md mục 1. Làm lại Bước 1 (máy cloud có thể đã mất ~/tools),
git switch lane-f/<T-xxx-ten-ngan>; git pull. Đọc mục Handoff trong card để biết lần trước dừng ở đâu,
kiểm tra git status và git log -5, làm tiếp các mục checklist chưa xong, kết thúc theo Bước 5–6.
```

## 3. Prompt yêu cầu sửa (khi integrator trả task về)
```
Integrator đã review <T-xxx> và yêu cầu sửa: xem mục "Review" trong card trên origin/main
(git fetch; git show origin/main:docs/tasks/<card>.md). Làm lại Bước 1 của docs/handoff/web.md nếu cần,
rebase nhánh lên origin/main, sửa từng ý, chạy test hai lượt như trước, push, cập nhật Handoff và báo lại theo 5 mục.
```
