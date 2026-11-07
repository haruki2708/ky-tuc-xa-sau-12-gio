# AGENTS.md — Luật chung cho mọi agent

Dự án: **"Ký túc xá sau 12 giờ"**. Game kinh dị và giải đố 3D, góc nhìn thứ nhất, làm bằng **Godot 4.7.2 (GDScript)**. Bản hiện hành dùng đồ họa PS1; chủ dự án đã chọn nâng sang **gần chân thực** (D-076), triển khai từng mốc theo `docs/design/GRAPHICS_UPGRADE_PLAN.md`.
Mục tiêu là game đầy đủ khoảng 3–4 tiếng, phát hành theo 4 chương (D-029); cả bốn chương đã có phần triển khai, tình trạng chơi thử xem `docs/STATUS.md`. Đợt tiếp theo T-207…T-212 chuẩn bị/nâng đồ họa, giữ cơ chế và logic đã chốt. **Thiết kế cốt truyện duy nhất còn hiệu lực là `docs/design/STORY.md` (v2, D-034, D-035).** Các tài liệu trong `docs/design/archive/` là phần chơi cũ của bản demo, chỉ để tham khảo hệ thống có sẵn; đừng làm theo cốt truyện hay luật trong đó.

Các vai trò và phiên làm việc trong dự án:
- **Integrator (Claude Code ở máy, Opus 5.5):** giữ kiến trúc, viết task card, review và merge mọi nhánh vào `main`, cập nhật `docs/STATUS.md`.
- **Agent lane A, B, C, D, E:** mỗi agent một lane, mỗi lane sở hữu một vùng file riêng (mục 3).
  - **D-139 (31/10/2026):** lane A, C là 2 tài khoản GPT chạy **Codex CLI trên máy này**, workspace `D:\GAME_WORK\lane-a2`, `lane-c2`. Bàn giao: `docs/handoff/BAN_GIAO_LANE_ABC_2026-10-31.md`.
  - **D-141 (07/11/2026):** lane B (Môi trường và 3D) chuyển sang **một tài khoản Claude chạy Claude Code trên máy này**, workspace `D:\GAME_WORK\lane-b2`. Tài khoản GPT từng làm lane B chuyển sang **lane E (Âm thanh)**, Codex CLI, workspace `D:\GAME_WORK\lane-e2`. Lane F (Claude Code web) dừng. Bàn giao: `docs/handoff/BAN_GIAO_LANE_B_E_2026-11-07.md`.
  - Lane D: Gemini (Antigravity) trên máy này, workspace `D:\GAME_WORK\lane-d` (D-108).
  - Lịch sử: D-078 lane E nghỉ và F nhận âm thanh; D-141 âm thanh trở lại tên E. Các workspace cũ `lane-a`, `lane-b`, `lane-c`, `lane-e`, `lane-f` đã xóa ngày 07/11; tác giả, nguồn asset trong credits giữ nguyên.
  - Lịch sử điều phối cũ (Astra, Claude web 10–11/10) xem `docs/handoff/OPUS_5_5_NHAN_LAI_DIEU_PHOI.md`; không còn hiệu lực.
- **Chủ dự án (người dùng):** ra quyết định thiết kế, chơi thử, gửi prompt cho agent, chuyển kết quả cho integrator.

## 1. Bắt đầu mỗi phiên (bắt buộc)
1. Làm việc **trong thư mục riêng của lane**: `D:\GAME_WORK\lane-a2`, `lane-b2`, `lane-c2`, `lane-e2` cho A, B, C, E; `D:\GAME_WORK\lane-d` cho D.
   - **Không bao giờ** làm trong `D:\GAME_DEMO` (bản tích hợp của integrator) hay workspace của lane khác.
   - Chưa có thư mục thì clone: `git clone https://github.com/haruki2708/ky-tuc-xa-sau-12-gio.git D:\GAME_WORK\lane-<x>2`, rồi `git lfs pull`.
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
| A | Gameplay | `game/scenes/player/`, `game/scenes/interaction/`, `game/scenes/entity/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/scripts/entity/`, `game/tests/player/` |
| B | Môi trường và 3D | `art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/` |
| C | QA và Tools | `tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/` |
| D | UI và Đa ngôn ngữ | `game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/` |
| E | Âm thanh (D-141; từ D-078 đến D-141 gọi là F) | `audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/` |

Tài liệu cũ ghi lane F sở hữu âm thanh thì hiểu là lane E hiện nay. Nhánh âm thanh mới đặt tên `lane-e/T-xxx-...`.

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

### Lượt Godot (D-139: nhiều agent chung một laptop, 16 GB RAM)
- Full `pwsh tools/test.ps1` mất khoảng 28 phút, `pwsh tools/check.ps1` khoảng 12 phút. **Mỗi lúc chỉ một phiên chạy full test, check, chụp ảnh hay export.**
- Trước khi chạy: xem file `D:\GAME_WORK\GODOT_DANG_CHAY.txt`.
  - Có file thì người khác đang chạy: chờ, hoặc chỉ chạy lệnh ngắn `pwsh tools/test.ps1 -Filter <tên file test của bạn>`.
  - Không có file: tạo file, ghi một dòng `lane, lệnh, giờ bắt đầu`, chạy, **xóa file khi xong** (kể cả khi lỗi). Nên tạo bằng chế độ "chỉ tạo khi chưa có" (`[IO.File]::Open(..., CreateNew)`) để hai lane không cùng lấy một lượt.
  - File cũ hơn 60 phút mà `Get-Process godot*` không thấy tiến trình nào thì coi là bỏ quên, xóa được.
- Không tắt tiến trình Godot của người khác. Integrator cũng theo luật này.

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
  - Ngoại lệ: danh sách từ chương 2 CC BY-SA (D-051); **model tạo bằng gói Tripo AI trả phí** (D-084), phải lưu gói, ngày, task ID, bản điều khoản lúc tạo và nguồn đầu vào hợp lệ. Không dùng model gói Free.
  - Ngoại lệ khác phải hỏi chủ dự án.
  - Ghi nguồn của mọi asset vào `CREDITS.md` trong thư mục asset của lane: URL, tác giả, giấy phép, file nào.
  - Asset tạo bằng AI phải ghi rõ công cụ. Steam yêu cầu khai báo nội dung AI.
- **Ngưỡng PS1 của asset hiện hành:**
  - Texture 64–256 px, lọc nearest.
  - Mô hình ít đa giác: đồ lớn dưới 1500 tam giác, đồ nhỏ dưới 500.
  - D-076 chuyển hướng mỹ thuật sang gần chân thực. Prototype riêng T-209 được khảo sát ngân sách mới theo kế hoạch, không tự thay mặc định cảnh chơi hoặc nới test production. G1/G2 chốt hợp đồng và số đo trước khi integrator áp dụng tiêu chuẩn mới. Các kiểm tra gameplay/collision vẫn giữ hiệu lực.
- **Tripo AI (D-080, thay Meshy):** G0 giữ nguyên; ưu tiên tạo mẫu trên Tripo Studio rồi B xử lý GLB/Blender/Godot. Studio và API dùng credit riêng, thuê bao Studio không cấp ngân sách API. Chỉ chạy tác vụ trả phí khi có tài khoản/ví phù hợp và trần chi cụ thể; một operator, ghi credit/task ID, không đặt khóa trong Git/chat. Quyền thương mại Paid không tự là CC0/CC-BY; ngoại lệ license và hồ sơ bắt buộc theo D-084 (mua Pro sau G1, mẫu balo tối đa 5 lần tạo). Không cài MCP/plugin theo suy diễn từ việc đổi dịch vụ. Xem `docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md`.
- **File nhị phân:** đi qua Git LFS (xem `.gitattributes`), mỗi file tối đa 10 MB. Commit cả các file `.import` và `.uid` do Godot sinh ra.
- **Không được:**
  - thêm plugin hoặc addon,
  - đổi phiên bản Godot,
  - dùng C#,
  - cài phần mềm vào ổ C:. Công cụ cài vào `D:\Tools\`.

## 6. Khi bị chặn hoặc không chắc
Ghi `Blocked: <lý do>` vào mục Handoff rồi dừng. **Đừng đoán** những việc thuộc thiết kế game, như luật chơi, cốt truyện hay giao diện; những việc này do chủ dự án quyết định. Chi tiết kỹ thuật nhỏ trong phạm vi lane thì cứ tự quyết, và ghi lý do vào Handoff.
