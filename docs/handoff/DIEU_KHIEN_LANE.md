# Integrator điều khiển các lane (D-164, 12/11/2026)

Từ D-164, integrator tự giao card và chạy lane ở chế độ ngầm. Chủ dự án không phải dán prompt từ `lane-*.md` nữa (vẫn dán tay được nếu muốn, các prompt cũ giữ nguyên).

**12/11/2026, chủ dự án chỉnh:** integrator chỉ điều khiển các phiên **Codex (lane A, C, E)**. **Lane B (Claude) chủ dự án tự dán prompt** như cũ: integrator viết prompt vào `lane-b.md` rồi báo chủ dự án, không gọi `chay_lane.ps1 -Lane B`.

## 1. Đăng nhập của từng lane (chủ dự án đã đặt sẵn, không cần đăng nhập lại)
| Lane | Workspace | Đăng nhập |
|---|---|---|
| A | `D:\GAME_WORK\lane-a2` | Codex, `CODEX_HOME=%USERPROFILE%\.codex-accountA` |
| B | `D:\GAME_WORK\lane-b2` | Claude Code, `CLAUDE_CONFIG_DIR=D:\ClaudeConfig\lane-b` |
| C | `D:\GAME_WORK\lane-c2` | Codex, `CODEX_HOME=%USERPROFILE%\.codex-accountC` |
| E | `D:\GAME_WORK\lane-e2` | Codex, `CODEX_HOME=%USERPROFILE%\.codex-accountB` (tài khoản GPT từng làm lane B) |

- Codex chạy với `-c cli_auth_credentials_store=file` như chủ dự án vẫn dùng.
- `%USERPROFILE%\.codex` (mặc định) là đăng nhập cho việc khác, không dùng cho game.

## 2. Cách integrator giao việc
1. Viết prompt vào `D:\GAME_WORK\lane_logs\prompts\<lane>_<T-xxx>.txt`: lấy prompt giao việc trong `lane-*.md`, thêm đoạn "Chạy ngầm" (mẫu ở mục 3).
2. Chạy nền:
   ```
   pwsh D:\GAME_WORK\chay_lane.ps1 -Lane E -Task T-244 -PromptFile D:\GAME_WORK\lane_logs\prompts\E_T-244.txt
   ```
   Thêm `-Resume` để lane làm tiếp phiên gần nhất của nó (prompt "tiếp tục" hoặc "yêu cầu sửa").
3. Nhật ký: `D:\GAME_WORK\lane_logs\<lane>_<task>_<giờ>.log`. Báo cáo cuối của lane: `..._last.txt`.
4. Lane push nhánh của nó; integrator review, merge, báo chủ dự án như trước.

## 3. Đoạn "Chạy ngầm" thêm vào cuối prompt
```text
Chạy ngầm (D-164): integrator gọi bạn, chủ dự án không dán prompt và không ngồi xem.
- Không ai trả lời câu hỏi giữa chừng. Gặp quyết định thiết kế thì chọn phương án nhỏ, an toàn nhất, ghi rõ trong Handoff là "chờ chủ dự án chọn/nghe", rồi làm tiếp phần còn lại. Bị chặn hẳn thì dừng ở chỗ an toàn, cập nhật Handoff, push nhánh.
- Luật Lượt Godot vẫn giữ: file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt tạo bằng CreateNew; đang có khóa thì chờ, không xóa khóa của người khác, xóa khóa của mình khi xong kể cả khi lỗi.
- Tin nhắn cuối cùng là báo cáo cho integrator, tiếng Việt, ngắn: xong gì, nhánh, commit, dòng RESULT test và check, phần chờ chủ dự án, yêu cầu thay đổi, có bị chặn không.
```

## 4. Luật giữ nguyên
- Mỗi lúc chỉ một Godot nặng (file khóa). Máy yếu RAM: integrator giao lần lượt, không cho nhiều lane chạy Godot cùng lúc.
- Bot, đo FPS, tiêu credit Tripo: vẫn hỏi chủ dự án trước khi giao.
- Không mở hai agent trong cùng một workspace: khi lane đang chạy ngầm, chủ dự án đừng gõ vào cửa sổ Codex/Claude cũ của lane đó.
- **Hết hạn mức** (chủ dự án dặn 12/11): integrator theo dõi nhật ký lane, thấy lỗi hạn mức thì báo ngay chủ dự án. Chủ dự án đăng nhập một tài khoản khác vào **cùng thư mục đăng nhập của lane** (lane E vẫn là `.codex-accountB`):
  ```
  $env:CODEX_HOME = "$env:USERPROFILE\.codex-accountB"
  codex -c cli_auth_credentials_store=file login
  ```
  Xong, integrator chạy lại lane với `-Resume` để làm tiếp phiên đang dở. Integrator không tự đổi tài khoản.
