# Bàn giao lane A, B, C cho tài khoản mới (D-139, 31/10/2026)

Đọc trang này sau `AGENTS.md` (Codex tự đọc file đó ở gốc repo). Prompt dán cho từng agent nằm ở `docs/handoff/lane-a.md`, `lane-b.md`, `lane-c.md` mục 1.

## 1. Vì sao đổi
- Gói Plus của 3 tài khoản cũ sắp hết hạn. Chủ dự án mua 3 tài khoản GPT mới, chạy **Codex CLI trên máy này**.
- Giữ tên lane A, B, C và phạm vi file như `AGENTS.md` mục 3.
- Lúc bàn giao, 3 lane cũ **không còn việc dở**:
  - workspace `D:\GAME_WORK\lane-a`, `lane-b`, `lane-c` sạch;
  - nhánh duy nhất chưa ghép `lane-c/T-219-manager-pilot` bị bỏ có chủ đích (D-118), chỉ để lưu.
- Agent mới **bắt đầu từ `origin/main`**, không tiếp nhận nhánh cũ nào.

## 2. Dự án đang ở đâu
- **Game:** "Ký túc xá sau 12 giờ", kinh dị góc nhìn thứ nhất, 4 chương, Godot 4.7.2 GDScript.
  - Cốt truyện duy nhất còn hiệu lực: `docs/design/STORY.md`.
  - Tình trạng chi tiết: `docs/STATUS.md`, lộ trình: `docs/ROADMAP.md`, quyết định: `docs/DECISIONS.md`.
- **Đang ở giai đoạn 3, đồ họa gần chân thực:**
  - phòng 407 xong: đồ Tripo, vỏ Blender, ánh sáng, gương thật;
  - quản lý Tripo vào bản chơi;
  - nhân vật chính Trần Trung (Tripo) có thân trong cảnh thử. Integrator làm T-227, chưa vào bản chơi;
  - hành lang tầng 4 và các khu khác còn hình PS1.
- Chương 1 tạm chốt, chương 2 tạm chốt, chương 3 chơi thử tới tầng 1 nhà B, chương 4 chưa chơi tay.

## 3. Việc đầu tiên của từng lane (việc thử, D-139)
| Lane | Card | Tóm tắt |
|---|---|---|
| A Gameplay | [T-228](../tasks/T-228-ch1-hand-targets.md) | Gắn điểm đặt tay `HandTarget` cho đồ dùng tay trong chương 1, có test |
| B Môi trường 3D | [T-229](../tasks/T-229-floor4-corridor-survey.md) | Khảo sát hành lang tầng 4, ảnh hiện trạng 1080p, kế hoạch nâng đồ họa, phiếu Tripo nháp. Không sửa scene chơi |
| C QA và Tools | [T-230](../tasks/T-230-bot-smoke-review-ch2-4.md) | Rà tĩnh bot và smoke test chương 2–4, báo cáo, công cụ kiểm node path. Không chạy bot |

- Integrator review từng việc và chấm theo bảng trong `docs/tasks/README.md`.
- Đạt thì giao việc lớn hơn trong cùng mảng: A làm thao tác tay chương 2–4, B dựng hành lang theo kế hoạch đã duyệt, C sửa và chạy bot khi được phép.

## 4. Luật quan trọng (đọc kỹ, đã có sự cố thật)
1. **Một laptop, nhiều agent.** Godot nặng; trước đây đã có tiến trình bị tắt vì thiếu RAM. Theo luật "Lượt Godot" trong `AGENTS.md` mục 4: file khóa `D:\GAME_WORK\GODOT_DANG_CHAY.txt`, mỗi lúc một lượt full test, check, chụp ảnh hay export.
2. **Thời gian chạy:**
   - full test khoảng 28 phút, check khoảng 12 phút;
   - lần đầu mở repo mới, Godot import toàn bộ asset, lâu hơn nhiều;
   - khi đang làm, dùng `-Filter <tên file test>`.
3. **Sau khi chạy test**, Godot có thể ghi lại `game/default_bus_layout.tres`. Nếu bạn không sửa âm thanh thì trả lại: `git checkout -- game/default_bus_layout.tres` trước khi commit.
4. **Git LFS:**
   - mọi `.glb .png .jpg .ogg .wav ...` đi qua LFS, file tối đa 10 MB;
   - clone xong chạy `git lfs pull`;
   - commit cả `.import` và `.uid` Godot sinh ra.
5. **Godot cần đường dẫn kiểu Windows** (`D:/GAME_WORK/...`) khi truyền tham số tệp.
6. **Cảnh chụp ảnh** phải chạy có cửa sổ, Forward+, không `--headless`.
   - Script chạy bằng `--script` với `extends SceneTree` từng bị treo; viết thành scene (`extends Node` + `.tscn`) rồi chạy scene.
7. **Không bao giờ:**
   - push `main`;
   - sửa `docs/STATUS.md`, `docs/DECISIONS.md`;
   - sửa file lane khác;
   - chạy bot, đo FPS hay tiêu credit Tripo khi chưa có lời chủ dự án.
8. **Thiết kế** (luật chơi, truyện, giao diện, hình dáng nhân vật hay cảnh) là của chủ dự án. Đưa phương án kèm đề xuất, không tự chọn.
9. **Ngôn ngữ:** trả lời, tài liệu, Handoff viết **tiếng Việt**; code, comment, commit message viết **tiếng Anh** (`T-xxx: ...`).
10. **Handoff trung thực:** chưa chạy thì ghi là chưa chạy. Ghi dòng `RESULT` của test và check, commit hash.

## 5. Bài học kỹ thuật đã có (đọc khi cần)
- **Tripo → Godot:**
  - `art_source/graphics_upgrade/manager/pack_tripo_manager.py`, `art_source/graphics_upgrade/protagonist/pack_tripo_protagonist.py` (gom động tác, bỏ trôi hông, thu nhỏ texture);
  - `art_source/graphics_upgrade/tripo/bake_prop.py` (giảm tam giác, ép kích thước đồ vật);
  - card T-219 mục bài học.
- **Đổi xương nhân vật:** bone map sang `SkeletonProfileHumanoid` (`trung_bone_map.tres`, `quaternius_bone_map.tres`). Động tác dùng chung được giữa các thân.
- **Vỏ phòng Blender và texture CC0:** `art_source/graphics_upgrade/room407_shell/README.md`.
- **Chụp ảnh so sánh:** `game/scenes/levels/room407/room407_g3_capture.gd`.
- **Tay người chơi:** card T-220 và T-227, chú thích đầu `game/scripts/interaction/hand_target.gd` và `game/scripts/player/player_body.gd`.

## 6. Quy trình một việc
1. Chủ dự án dán prompt mục 1 của `lane-<x>.md` vào Codex CLI mở ở `D:\GAME_WORK\lane-<x>2`.
2. Agent làm trên nhánh `lane-<x>/T-xxx-...`. Trước commit: full test và check. Push nhánh, cập nhật Handoff trong card.
3. Chủ dự án báo integrator: "lane X xong T-xxx".
4. Integrator review. Đạt thì merge vào `main`. Chưa đạt thì ghi Review trong card, chủ dự án dán prompt mục 3 ("yêu cầu sửa").

## 7. Ghi chú cho chủ dự án (cài đặt Codex CLI)
- Mỗi tài khoản đăng nhập Codex CLI riêng, mở **một cửa sổ terminal riêng** trong thư mục lane của nó. Không mở 2 agent trong cùng một thư mục.
- Agent cần quyền:
  - ghi trong thư mục lane;
  - chạy `git`, `git lfs`, `pwsh`, Godot (`D:\Tools\Godot\`) và Blender (`D:\Tools\Blender\`).
- Godot ghi dữ liệu editor vào `D:\Tools\Godot\editor_data` (ngoài thư mục lane). Nếu Codex chặn lệnh Godot vì sandbox, cho phép lệnh đó khi được hỏi, hoặc chọn chế độ quyền rộng hơn cho phiên lane.
- Repo private, Codex dùng đăng nhập git sẵn có trên máy để clone và push.
- Ổ D còn khoảng 115 GB. Mỗi clone kèm LFS và cache Godot khoảng 3–5 GB.
