# Ký túc xá sau 12 giờ

Game kinh dị và giải đố 3D, góc nhìn thứ nhất, bối cảnh ký túc xá Việt Nam. Làm bằng Godot 4.7.2.

- Kế hoạch tổng: `docs/PLAN.md`
- Tiến độ hiện tại: `docs/STATUS.md`
- Luật cho agent: `AGENTS.md`
- Prompt gửi agent: `docs/handoff/lane-*.md`

## Chủ dự án: cách làm hằng ngày
1. Xem `docs/STATUS.md` để biết đang ở đâu.
2. Gửi prompt trong `docs/handoff/lane-x.md` cho agent tương ứng:
   - Mục 1 khi giao task mới.
   - Mục 2 khi tiếp tục sau lúc tắt máy.
3. Agent báo xong thì nhắn Claude: "review lane X".
4. Chơi bản build Claude đưa (file `build/windows/KyTucXa.exe`), ghi lại cảm nhận.

## Mở dự án trong Godot
Chạy `D:\Tools\Godot\Godot_v4.7.2-stable_win64.exe`, chọn Import, rồi chọn file `game/project.godot`. Bấm F5 để chơi scene chính, F6 để chơi scene đang mở.
