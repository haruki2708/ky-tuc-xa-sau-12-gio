# Bàn giao lane B (Claude) và lane E (âm thanh) — D-141, 07/11/2026

Đọc trang này sau `AGENTS.md`. Prompt dán cho từng agent: `docs/handoff/lane-b.md` và `lane-e.md`, mục 0 (cài đặt cho chủ dự án) và mục 1 (nhận bàn giao).

## 1. Thay đổi
| Lane | Trước (D-139) | Từ 07/11 (D-141) | Workspace |
|---|---|---|---|
| A Gameplay | GPT, Codex CLI | giữ nguyên; việc T-231 | `D:\GAME_WORK\lane-a2` |
| **B Môi trường và 3D** | GPT, Codex CLI | **tài khoản Claude, Claude Code trên máy này** | `D:\GAME_WORK\lane-b2` (dùng lại) |
| C QA và Tools | GPT, Codex CLI | giữ nguyên; việc T-232 | `D:\GAME_WORK\lane-c2` |
| D UI và Đa ngôn ngữ | Gemini (Antigravity) | giữ nguyên, đang rảnh | `D:\GAME_WORK\lane-d` |
| **E Âm thanh** | nghỉ từ D-078 (F làm thay) | **tài khoản GPT từng làm lane B**, Codex CLI | `D:\GAME_WORK\lane-e2` (clone mới) |
| F Âm thanh | Claude Code web | **dừng** | đã xóa |

- Phạm vi file mỗi lane không đổi (`AGENTS.md` mục 3). Phạm vi âm thanh trước ghi cho F nay ghi cho E.
- Ngày 07/11 chủ dự án xóa các workspace cũ `lane-a`, `lane-b`, `lane-c`, `lane-e`, `lane-f`, `ky-tuc-xa-sau-12-gio` để lấy chỗ trên ổ D. Integrator đã kiểm trước: không còn thay đổi chưa lưu, mọi commit đã có trên repo `haruki2708`, stash chỉ là bản cứu file cũ.
- **Lane B và E chưa có việc.** Phiên đầu chỉ nhận bàn giao: đọc tài liệu, làm nóng Godot, báo lại hiểu biết. Chủ dự án chưa chọn phương án hành lang tầng 4 (T-229 `PLAN.md` mục 4), nên lượt dựng hành lang chưa mở.

## 2. Hai phiên Claude trên một máy
- **Integrator:** Claude Code mở ở `D:\GAME_DEMO`, đăng nhập tài khoản chính, cấu hình ở `C:\Users\ADMIN\.claude`.
- **Lane B:** Claude Code mở ở `D:\GAME_WORK\lane-b2` bằng `D:\GAME_WORK\mo_claude_lane_b.cmd`. File này đặt `CLAUDE_CONFIG_DIR=C:\Users\ADMIN\.claude-lane-b`: đăng nhập, cài đặt, bộ nhớ của lane B nằm riêng, không đè lên integrator.
- `CLAUDE.md` ở gốc repo phân vai theo thư mục đang mở. Claude lane B đọc thấy mình là lane B, không phải integrator.
- Hai phiên không nói chuyện trực tiếp với nhau. Đường đi vẫn như mọi lane: lane B push nhánh và viết Handoff, chủ dự án báo integrator "lane B xong T-xxx", integrator review và merge.

## 3. Luật quan trọng (nhắc lại từ bàn giao 31/10, đã có sự cố thật)
1. **Một laptop, nhiều agent.** Mỗi lúc một lượt full test, check, chụp ảnh hay export, theo file khóa `D:\GAME_WORK\GODOT_DANG_CHAY.txt` (`AGENTS.md` mục 4). Bây giờ có 5 agent (A, B, C, E, có khi D) chung máy, càng phải xếp lượt.
2. Full test khoảng 28 phút, check khoảng 12 phút; lần đầu mở repo mới Godot import lâu hơn nhiều. Khi đang làm, dùng `-Filter`.
3. **Log để trong `build/`, không commit log** (lỗi của T-229).
4. Không push `main`, không sửa `docs/STATUS.md`, `docs/DECISIONS.md`, không sửa file lane khác. Cần sửa ngoài phạm vi thì ghi "Yêu cầu thay đổi".
5. Không chạy bot, đo FPS hay tiêu credit Tripo khi chưa có lời chủ dự án.
6. Thiết kế (luật chơi, truyện, giao diện, hình dáng, **âm thanh nghe ra sao**) là của chủ dự án: đưa phương án kèm đề xuất.
7. Tiếng Việt cho trả lời, tài liệu, Handoff; tiếng Anh cho code, comment, commit (`T-xxx: ...`).
8. Handoff trung thực: chưa chạy thì ghi chưa chạy; ghi dòng `RESULT` và commit hash.

## 4. Riêng lane B (Claude)
- Việc 3D trước đây do Claude làm thay đã có tài liệu, nên đọc trước khi dựng:
  - vỏ phòng Blender và texture CC0: `art_source/graphics_upgrade/room407_shell/README.md`;
  - ổ điện, dây mạng, quạt: `art_source/graphics_upgrade/room407_electrics/README.md`;
  - Tripo → Godot: `art_source/graphics_upgrade/tripo/bake_prop.py`, card T-219, T-227;
  - chụp ảnh so sánh: `game/scenes/levels/room407/room407_g3_capture.gd`, `game/scenes/levels/floor4/corridor_capture.gd`.
- Hành lang tầng 4: khảo sát, ảnh hiện trạng, kế hoạch 4 lượt và phiếu Tripo nháp đã có (T-229, `art_source/graphics_upgrade/floor4_corridor/`). Bảng "không được đổi tên hoặc dời" trong `PLAN.md` mục 2 là hợp đồng với gameplay.
- Cảnh chụp ảnh phải chạy có cửa sổ, Forward+, không `--headless`; viết thành scene (`extends Node` + `.tscn`), không dùng `--script` với `extends SceneTree`.
- Blender: `D:\Tools\Blender\5.2.2\blender.exe`. Mỗi file nhị phân ≤ 10 MB, qua Git LFS; commit cả `.import` và `.uid`.

## 5. Riêng lane E (âm thanh)
- Agent **không nghe được**. Đo bằng số (LUFS, true peak bằng ffmpeg `loudnorm`), làm cảnh nghe thử có phím bấm, ghi rõ "chưa nghe bằng tai". Chỉ chủ dự án duyệt chất âm.
- **Chủ dự án thích âm nhỏ, nhẹ.** Mức mục tiêu hiện có trong `audio_source/README.md` (Ambience −24 LUFS, SFX −18 LUFS và các ngoại lệ nhỏ hơn).
- Không thu lại lời đã duyệt, không tạo lại âm đã duyệt nếu card không yêu cầu. Nguồn mới chỉ CC0/CC-BY hoặc tự tổng hợp; ghi `game/audio/CREDITS.md`, giữ tên tác giả cũ (E cũ, F).
- `game/default_bus_layout.tres` là file của lane E: chỉ commit khi cố ý sửa.
- Công cụ: ffmpeg `D:\Tools\FFmpeg\`, espeak-ng `D:\Tools\espeak-ng\`, Python. Pipeline và cảnh nghe thử: `audio_source/README.md`, `res://audio/test/`.

## 6. Quy trình một việc (không đổi)
1. Integrator viết card, chủ dự án dán prompt mục 2 của `lane-<x>.md` (B, E) hoặc mục 1 (A, C).
2. Agent làm trên nhánh `lane-<x>/T-xxx-...`, full test và check trước commit, push nhánh, viết Handoff.
3. Chủ dự án báo integrator "lane X xong T-xxx". Integrator review: đạt thì merge, chưa đạt thì ghi Review, chủ dự án dán prompt yêu cầu sửa.
