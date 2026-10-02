# AGENTS.md — Luật chung cho mọi agent

Dự án: **"Ký túc xá sau 12 giờ"**. Game kinh dị và giải đố 3D, góc nhìn thứ nhất, phong cách low-poly kiểu PS1, làm bằng **Godot 4.7.2 (GDScript)**.
Mục tiêu hiện tại là bản demo 15–20 phút đăng lên itch.io. Kế hoạch tổng nằm ở `docs/PLAN.md`, thiết kế game ở `docs/design/GDD.md`.

Có 6 người làm việc trên dự án:
- **Integrator (Claude):** giữ kiến trúc, review và merge mọi nhánh vào `main`.
- **Năm agent lane A–E:** mỗi agent một lane, mỗi lane sở hữu một vùng file riêng.
- **Chủ dự án (người dùng):** ra quyết định thiết kế, chơi thử, gửi prompt cho agent.

## 1. Bắt đầu mỗi phiên (bắt buộc)
1. Làm việc **trong thư mục riêng của lane**: `D:\GAME_WORK\lane-<x>`.
   - **Không bao giờ** làm trong `D:\GAME_DEMO`, đó là bản tích hợp của integrator.
   - Chưa có thư mục thì clone: `git clone https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio.git D:\GAME_WORK\lane-<x>`.
2. Chạy `git fetch origin`, rồi chuyển sang nhánh task của bạn. Nhánh tạo từ `origin/main`, đặt tên `lane-<x>/T-xxx-mo-ta-ngan`.
3. Đọc lần lượt:
   - file này,
   - `docs/STATUS.md`,
   - task card của bạn trong `docs/tasks/`, đặc biệt mục **Handoff** để biết lần trước dừng ở đâu.
4. Nếu `main` có thay đổi mới, rebase nhánh của bạn lên `origin/main` trước khi làm tiếp.

## 2. Kết thúc mỗi phiên (bắt buộc)
1. `pwsh tools/test.ps1` phải **PASS**. Nếu test fail mà không sửa được, ghi rõ lý do vào Handoff.
2. Commit nhỏ, message tiếng Anh có dạng `T-xxx: <việc đã làm>`. Push nhánh lên origin. **Không push lên `main`.**
3. Cập nhật mục **Handoff** trong task card:
   - đã làm gì,
   - còn gì dở,
   - cách kiểm tra,
   - yêu cầu thay đổi ngoài phạm vi (nếu có).
   Ghi trung thực: chưa test thì ghi là chưa test.
4. Không sửa `docs/STATUS.md`. Integrator cập nhật file này.

## 3. Phạm vi file theo lane (chống sửa đè)
| Lane | Vai trò | Được sửa |
|---|---|---|
| core | Integrator (Claude) | `game/project.godot`, `game/export_presets.cfg`, `game/scripts/core/`, `game/data/`, `game/scenes/main/`, `game/localization/` (cấu trúc), `game/tests/run_tests.*`, `game/tests/test_case.gd`, `game/tests/core/`, `tools/godot-path.ps1`, `AGENTS.md`, `CLAUDE.md`, `docs/` |
| A | Gameplay | `game/scenes/player/`, `game/scenes/interaction/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/` |
| B | Môi trường và 3D | `art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/` |
| C | QA và Tools | `tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/` |
| D | UI và Đa ngôn ngữ | `game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/` |
| E | Âm thanh | `audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/` |

Mọi lane đều được sửa: task card của mình (`docs/tasks/T-xxx*.md`, chỉ mục Handoff và checklist). Lane nào cũng được **thêm key mới** vào `strings.csv`, nhưng không được sửa key của lane khác.

**Cần sửa file ngoài phạm vi?** Không tự sửa. Ghi vào mục "Yêu cầu thay đổi" trong task card, integrator sẽ xử lý. Các trường hợp thường gặp:
- thêm autoload hoặc input action,
- thêm signal vào `EventBus`,
- thêm mục mới vào file cài đặt (xem `docs/SETTINGS.md`),
- đổi cài đặt trong `project.godot`.

## 4. Lệnh thường dùng (PowerShell, chạy từ gốc repo)
- Chạy test: `pwsh tools/test.ps1`. Lọc theo tên: `pwsh tools/test.ps1 -Filter player`.
- Xuất bản build Windows: `pwsh tools/export.ps1`. File ra ở `build/windows/KyTucXa.exe`.
- Godot editor (cho người): `D:\Tools\Godot\Godot_v4.7.2-stable_win64.exe`, mở `game/project.godot`.
- Godot console (cho agent): `D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`.
- Chụp khung hình để kiểm tra hình ảnh:
  ```
  <godot_console> --path game <res://scene.tscn> --write-movie <out>/frame.png --fixed-fps 30 --quit-after 60 --resolution 1280x720
  ```

## 5. Quy ước code và asset
- **Code:**
  - GDScript có kiểu (typed). Thụt lề bằng tab.
  - Tên biến, hàm và comment viết bằng tiếng Anh. Tài liệu trong `docs/` viết bằng tiếng Việt.
  - Tên file dùng snake_case. Mỗi script hoặc scene nên có một trách nhiệm rõ ràng.
- **Giao tiếp giữa các hệ thống:**
  - Dùng signal của `EventBus` (autoload).
  - Đồ vật tương tác được thì kế thừa `Interactable` (`game/scripts/core/interactable.gd`).
- **Chữ hiển thị cho người chơi:**
  - **Không viết cứng.** Luôn dùng key dịch trong `game/localization/strings.csv`, đủ hai cột `vi` và `en`.
  - Key viết HOA_GẠCH_DƯỚI, có tiền tố theo nhóm: `PROMPT_`, `UI_`, `SUB_`, `DOC_`, `RULE_`.
- **Scene:**
  - Ưu tiên chia nhỏ scene rồi instance vào nhau.
  - Sửa file `.tscn` bằng tay thì giữ đúng định dạng. Chạy test để chắc chắn scene vẫn load được.
  - Một scene chỉ do một lane sửa.
- **Collision layer:** 1 = world, 2 = player, 3 = interactable.
- **Asset:**
  - Chỉ dùng giấy phép **CC0** hoặc **CC-BY**. **Cấm** NC (phi thương mại), cấm asset không rõ nguồn, cấm asset lấy từ game khác.
  - Ghi nguồn của mọi asset vào `CREDITS.md` trong thư mục asset của lane: URL, tác giả, giấy phép, file nào.
  - Asset tạo bằng AI phải ghi rõ công cụ. Steam yêu cầu khai báo nội dung AI.
- **Phong cách PS1:**
  - Texture 64–256 px, lọc nearest.
  - Mô hình ít đa giác: đồ lớn dưới 1500 tam giác, đồ nhỏ dưới 500.
- **File nhị phân:** đi qua Git LFS (xem `.gitattributes`), mỗi file tối đa 10 MB. Commit cả các file `.import` và `.uid` do Godot sinh ra.
- **Không được:**
  - thêm plugin hoặc addon,
  - đổi phiên bản Godot,
  - dùng C#,
  - cài phần mềm vào ổ C:. Công cụ cài vào `D:\Tools\`.

## 6. Khi bị chặn hoặc không chắc
Ghi `Blocked: <lý do>` vào mục Handoff rồi dừng. **Đừng đoán** những việc thuộc thiết kế game, như luật chơi, cốt truyện hay giao diện; những việc này do chủ dự án quyết định. Chi tiết kỹ thuật nhỏ trong phạm vi lane thì cứ tự quyết, và ghi lý do vào Handoff.
