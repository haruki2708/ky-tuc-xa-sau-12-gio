# Prompt bàn giao — Lane E (Âm thanh)

> **07/11/2026, D-141:** lane E (âm thanh) hoạt động trở lại. Agent là **tài khoản GPT từng làm lane B** (T-229), chạy **Codex CLI trên máy này**, workspace mới `D:\GAME_WORK\lane-e2`. Đọc [bàn giao](BAN_GIAO_LANE_B_E_2026-11-07.md).
>
> Lịch sử: E cũ (GPT Plus) làm âm thanh đến 10/10; D-078 cho E nghỉ, lane F nhận âm thanh (GPT Plus, rồi Claude Code web từ D-108); D-141 lane F dừng, âm thanh trở lại tên E. Tài liệu cũ ghi "lane F" sở hữu âm thanh thì hiểu là lane E. Tác giả, nguồn asset trong credits giữ nguyên. Prompt cũ của E xem lịch sử git của file này.

## 0. Cài đặt cho chủ dự án (làm một lần)
1. Trong cửa sổ Codex đang dùng cho lane B, kết thúc phiên (agent đã bàn giao T-229 xong). **Không dùng tiếp thư mục `D:\GAME_WORK\lane-b2`**: thư mục này từ nay của Claude lane B.
2. Mở terminal mới, `cd D:\GAME_WORK`, chạy `codex` bằng **đúng tài khoản GPT đã làm lane B**. Workspace `lane-e2` chưa có; agent tự clone ở bước 1 của prompt.
3. Sau khi clone xong, các phiên sau mở Codex thẳng trong `D:\GAME_WORK\lane-e2`.
4. Quyền cần cho: `git`, `git lfs`, `pwsh`, Godot (`D:\Tools\Godot\`), ffmpeg (`D:\Tools\FFmpeg\`), espeak-ng (`D:\Tools\espeak-ng\`), Python.

## 1. Prompt nhận bàn giao (dán nguyên khối, phiên đầu)
```text
Bạn là agent Lane E (Âm thanh) của game "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript).
Bạn chính là tài khoản đã làm lane B (T-229, khảo sát hành lang tầng 4, integrator chấm đạt). Từ hôm nay (D-141) bạn chuyển sang lane âm thanh.
Lane B từ nay do một tài khoản Claude làm trong D:\GAME_WORK\lane-b2: KHÔNG làm việc trong lane-b2 nữa.
Integrator là Claude Code ở máy (Opus 5.5) làm ở D:\GAME_DEMO: review và merge vào main. Chủ dự án quyết mọi việc thiết kế, kể cả âm thanh nghe ra sao.
Trả lời và viết tài liệu bằng tiếng Việt; code, comment, commit message bằng tiếng Anh.

Workspace mới: D:\GAME_WORK\lane-e2. Chỉ làm trong thư mục này. Không sửa D:\GAME_DEMO hay workspace lane khác.

Phiên này CHỈ nhận bàn giao, chưa có việc. Không sửa file, không commit.
1. git clone https://github.com/haruki2708/ky-tuc-xa-sau-12-gio.git D:\GAME_WORK\lane-e2
   rồi trong thư mục đó: git lfs install --local, git lfs pull, git switch main.
   (Nếu thư mục đã có: kiểm git status, không ghi đè thay đổi đang có, git fetch origin, git pull --ff-only.)
2. Đọc lần lượt: AGENTS.md (mục 3 lane E sở hữu audio_source/, game/audio/, game/scripts/audio/, game/default_bus_layout.tres, game/tests/audio/),
   docs/handoff/BAN_GIAO_LANE_B_E_2026-11-07.md, docs/handoff/lane-e.md, docs/STATUS.md (phần đầu và bảng task),
   audio_source/README.md, game/audio/CREDITS.md, docs/SETTINGS.md (phần [audio]),
   các card âm thanh gần nhất: docs/tasks/T-218-room407-object-audio.md, docs/tasks/T-212-graphics-audio-anchors.md, docs/tasks/T-200-ch4-voices-call-audio.md.
3. Lần đầu mở repo mới, Godot phải import toàn bộ asset (lâu). Làm theo luật "Lượt Godot" (AGENTS.md mục 4, file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt):
   khi tới lượt, chạy pwsh tools/test.ps1 -Filter audio. Ghi dòng RESULT. Xóa file khóa khi xong, kể cả khi lỗi.
4. Báo lại cho chủ dự án bằng tiếng Việt, ngắn gọn:
   - bạn hiểu lane E làm gì, được sửa thư mục nào, luật nào quan trọng nhất;
   - âm thanh dự án đang có gì (bus, pipeline, giọng các chương, cảnh nghe thử) và còn gì chờ chủ dự án nghe;
   - kết quả bước 1 và 3;
   - câu hỏi nếu có.
Sau đó chờ integrator giao card.
```

## 2. Prompt giao việc (integrator điền T-xxx)
```text
Việc mới cho lane E: <T-xxx> — đọc docs/tasks/<file card>.md.
Ở D:\GAME_WORK\lane-e2: git status (giữ thay đổi đang có), git fetch origin, tạo nhánh lane-e/<T-xxx-...> từ origin/main.
Đọc lại AGENTS.md mục 3–5 và card. Chỉ sửa file trong mục "Được phép sửa"; ngoài phạm vi thì ghi "Yêu cầu thay đổi".
Luật âm thanh: chủ dự án thích âm NHỎ, nhẹ. Bạn không nghe được: đo bằng số (LUFS, true peak) và làm cảnh nghe thử có phím bấm; ghi rõ "chưa nghe bằng tai, chờ chủ dự án nghe".
Không thu lại lời đã duyệt, không tạo lại âm đã duyệt nếu card không yêu cầu. Nguồn âm mới chỉ CC0/CC-BY hoặc tự tổng hợp, ghi vào game/audio/CREDITS.md.
Không chạy bot, không đo FPS. Godot theo luật Lượt Godot. Khi làm: pwsh tools/test.ps1 -Filter <tên test>. Trước commit: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1.
default_bus_layout.tres là file của lane E: chỉ commit khi bạn cố ý sửa; Godot tự ghi đè sau test thì git checkout -- game/default_bus_layout.tres.
Log để trong build/, không commit log. Commit nhỏ "<T-xxx>: ...", git push -u origin <nhánh>. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card (đã làm, còn dở, cách kiểm tra và cách nghe thử, dòng RESULT test và check, commit hash, yêu cầu thay đổi, phần chưa kiểm). Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, có bị chặn không.
```

## 3. Prompt tiếp tục (phiên sau)
```text
Tiếp tục <T-xxx> ở D:\GAME_WORK\lane-e2, nhánh lane-e/<T-xxx-...>.
Kiểm git status, git fetch origin, rebase an toàn lên origin/main nếu main có thay đổi mới (không mất thay đổi cục bộ).
Đọc lại AGENTS.md và mục Handoff trong card để biết lần trước dừng ở đâu. Làm tiếp, bàn giao như prompt mục 2.
```

## 4. Prompt yêu cầu sửa (khi integrator trả lại)
```text
Integrator trả <T-xxx>. Ở D:\GAME_WORK\lane-e2: git fetch origin, đọc mục Review trong origin/main:docs/tasks/<file card>.md
(hoặc nội dung chủ dự án dán kèm). Rebase nhánh lên origin/main, sửa đúng từng ý trong phạm vi được phép.
Chạy full test và check theo luật Lượt Godot, cập nhật Handoff, push nhánh, báo lại phần đã sửa và phần chưa kiểm.
```
