# Prompt bàn giao — Lane E (Âm thanh)

## 1. Prompt giao task (dán nguyên khối)
```
Bạn là agent Lane E (Âm thanh) trong dự án game "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript).
Repo GitHub (private): https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio.git
Thư mục làm việc của bạn: D:\GAME_WORK\lane-e
TUYỆT ĐỐI không làm việc trong D:\GAME_DEMO (đó là bản tích hợp).

Bước 1. Chuẩn bị:
  - Nếu chưa có D:\GAME_WORK\lane-e: git clone https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio.git D:\GAME_WORK\lane-e
  - cd D:\GAME_WORK\lane-e; git fetch origin
  - Nếu nhánh lane-e/T-133-music-drone đã có trên origin: git switch lane-e/T-133-music-drone; git pull
    Nếu chưa có: git switch -c lane-e/T-133-music-drone origin/main
Bước 2. Đọc kỹ, theo thứ tự: AGENTS.md, docs/STATUS.md, docs/tasks/T-133-music-drone.md
Bước 3. Làm task trong card, CHỈ sửa file trong mục "Được phép sửa".
        Cần sửa file ngoài phạm vi thì ghi "Yêu cầu thay đổi" vào mục Handoff, không tự sửa.
Bước 4. Trước khi kết thúc: chạy pwsh tools/test.ps1 (phải PASS); commit dạng "T-133: ...";
        git push -u origin lane-e/T-133-music-drone; điền mục Handoff trong card, commit và push lại.
Bước 5. Trả lời tôi bằng tiếng Việt, ngắn gọn:
  (1) đã làm gì, (2) kết quả test (dán dòng RESULT), (3) checklist mục nào chưa đạt và vì sao,
  (4) yêu cầu thay đổi ngoài phạm vi, (5) có bị chặn ở đâu không.
Quy tắc: không push lên main, không thêm plugin, không cài gì vào ổ C:, không đoán về
luật chơi hay cốt truyện (ghi câu hỏi vào Handoff). Ghi trung thực: chưa test thì nói chưa test.
```

## 2. Prompt tiếp tục (sau khi tắt máy, hoặc khi agent mất ngữ cảnh)
```
Tiếp tục task T-133 của Lane E. cd D:\GAME_WORK\lane-e; git fetch origin; git switch lane-e/T-133-music-drone; git pull.
Đọc lại AGENTS.md, docs/STATUS.md và docs/tasks/T-133-music-drone.md (đặc biệt mục Handoff để biết lần trước dừng ở đâu).
Kiểm tra git status và git log -5. Tiếp tục các mục checklist chưa xong, rồi kết thúc phiên theo AGENTS.md §2.
```

## 3. Prompt yêu cầu sửa (khi integrator trả task về)
```
Integrator đã review T-133 và yêu cầu sửa: xem mục "Review" trong docs/tasks/T-133-music-drone.md trên origin/main
(git fetch; git show origin/main:docs/tasks/T-133-music-drone.md). Rebase nhánh lên origin/main, sửa từng ý, chạy test,
push, cập nhật Handoff và báo lại theo 5 mục như trước.
```

## 4. Task tiếp theo của lane E (sau khi T-133 được merge)
Dùng lại prompt mục 1, thay `T-133` bằng `T-137` và `lane-e/T-133-music-drone` bằng `lane-e/T-137-speaker-voice`,
card `docs/tasks/T-137-speaker-voice.md` (giọng loa TTS offline).
