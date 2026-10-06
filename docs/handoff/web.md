# Prompt bàn giao — Claude Code trên web (làm thay lane B, D-066)

Chủ dự án dùng tín dụng Claude Code trên web (claude.ai/code) như một **lane dự phòng**. Phiên web chạy trên máy Linux trên cloud, clone repo từ GitHub, làm trên nhánh riêng rồi push. Integrator (Claude ở máy chủ dự án) review, chụp ảnh, chạy test trên Windows và merge.

**Giới hạn của máy cloud:** không có Godot sẵn (phải tải), **không có card đồ họa** (không chụp ảnh, không đo FPS, không export `.exe`), không chơi thử được. Test chạy headless được.

## 1. Prompt giao task (dán nguyên khối vào phiên web, chọn repo `tuaanh666/ky-tuc-xa-sau-12-gio`)
```
Bạn làm thay Lane B (Môi trường và 3D) trong dự án game "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript), theo quyết định D-066.
Trả lời tôi bằng tiếng Việt. Tài liệu viết tiếng Việt, code viết tiếng Anh.

Bước 1. Chuẩn bị máy (Linux, không cần sudo; mọi thứ cài vào ~/tools):
  - git lfs install; git lfs pull
  - Tạo nhánh: git fetch origin; git switch -c lane-b/T-192-stands-props origin/main
    (nếu nhánh đã có trên origin: git switch lane-b/T-192-stands-props; git pull)
  - Tải Godot 4.7.2 bản Linux:
      mkdir -p ~/tools && cd ~/tools
      curl -LO https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
      unzip -o Godot_v4.7.2-stable_linux.x86_64.zip && chmod +x Godot_v4.7.2-stable_linux.x86_64
      export GODOT=~/tools/Godot_v4.7.2-stable_linux.x86_64
  - Cài PowerShell 7 bản tar.gz cho Linux x64 (bản 7.x mới nhất ở github.com/PowerShell/PowerShell/releases) vào ~/tools/pwsh, chạy bằng ~/tools/pwsh/pwsh.
    Nếu không cài được, chạy test trực tiếp:
      $GODOT --headless --path game --import
      $GODOT --headless --path game res://tests/run_tests.tscn            (cả bộ)
      $GODOT --headless --path game res://tests/run_tests.tscn -- --filter=levels
  - Python 3 có sẵn là đủ cho bộ dựng map (chỉ dùng thư viện chuẩn).
Bước 2. Đọc kỹ, theo thứ tự: AGENTS.md, docs/STATUS.md, docs/DECISIONS.md (D-054, D-062…D-066),
        docs/tasks/T-192-ch3-stands-props.md, art_source/campus/README.md, art_source/campus/room_doors.md.
Bước 3. TRƯỚC KHI SỬA GÌ: chạy cả bộ test một lần trên origin/main và lưu kết quả (dòng RESULT và tên test FAIL).
        Test nào đã FAIL sẵn ở lượt này là do môi trường Linux, KHÔNG sửa chúng, chỉ ghi vào Handoff.
Bước 4. Làm task trong card, CHỈ sửa file trong mục "Được phép sửa".
        Bỏ qua yêu cầu chụp ảnh (máy không có card đồ họa); integrator sẽ chụp khi review.
        Cần sửa file ngoài phạm vi thì ghi "Yêu cầu thay đổi" vào Handoff, không tự sửa.
Bước 5. Trước khi kết thúc: chạy lại cả bộ test; không được có test FAIL mới so với lượt ở Bước 3.
        Commit nhỏ, message dạng "T-192: ..."; git push -u origin lane-b/T-192-stands-props.
        Điền mục Handoff trong card (ghi rõ "Claude Code web làm thay lane B, D-066", kết quả test hai lượt,
        tọa độ khán đài, cổng, anchor đã dời, số tam giác), commit và push lại.
Bước 6. Trả lời tôi ngắn gọn: (1) đã làm gì, (2) kết quả test hai lượt, (3) checklist mục nào chưa đạt và vì sao,
        (4) yêu cầu thay đổi ngoài phạm vi, (5) có bị chặn ở đâu không.
Quy tắc: KHÔNG push lên main, không mở pull request vào main trừ khi tôi bảo, không thêm plugin hay addon,
không đổi phiên bản Godot, chỉ dùng asset CC0/CC-BY (ghi CREDITS), không đoán về luật chơi hay cốt truyện
(ghi câu hỏi vào Handoff). Ghi trung thực: chưa test thì nói chưa test.
```

## 2. Prompt tiếp tục (phiên mới hoặc phiên cũ mất ngữ cảnh)
```
Tiếp tục T-192 (làm thay lane B, D-066) theo docs/handoff/web.md mục 1. Làm lại Bước 1 (máy cloud có thể đã mất ~/tools),
git switch lane-b/T-192-stands-props; git pull. Đọc mục Handoff trong docs/tasks/T-192-ch3-stands-props.md để biết lần trước dừng ở đâu,
kiểm tra git status và git log -5, làm tiếp các mục checklist chưa xong, kết thúc theo Bước 5–6.
```

## 3. Prompt yêu cầu sửa (khi integrator trả task về)
```
Integrator đã review T-192 và yêu cầu sửa: xem mục "Review" trong docs/tasks/T-192-ch3-stands-props.md trên origin/main
(git fetch; git show origin/main:docs/tasks/T-192-ch3-stands-props.md). Làm lại Bước 1 của docs/handoff/web.md nếu cần,
rebase nhánh lên origin/main, sửa từng ý, chạy test hai lượt như trước, push, cập nhật Handoff và báo lại theo 5 mục.
```
