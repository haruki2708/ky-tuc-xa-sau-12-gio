# T-209 — Pipeline mỹ thuật và phòng 407 gần chân thực

> **D-080, 11/10:** chuyển sang **Tripo AI**; giữ G0 đã ghép và task/nhánh hiện có. Đọc [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md). Handoff/checklist G0 bên dưới là lịch sử; chưa có Tripo asset hoặc client live.

- Lane: B | Trạng thái: **G0 đã review/ghép (D-079); G1 tiếp tục, toàn gói chưa done** | Agent: lane B
- Nhánh: `lane-b/T-209-realistic-art-pilot`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 không cần Tripo AI. G1 theo T-207, rig theo T-208, manifest/công cụ T-210, settings T-211, marker âm T-212.
- Hạn đề xuất: phiên đầu gửi kiểm kê/ảnh tham chiếu/pilot vật liệu; mở rộng sau khi phòng mẫu được duyệt.

## Bối cảnh
Tầng 4/phòng 407 dùng chung cả bốn chương; map và đường đi đã sửa qua T-203/T-206, D-058/D-062/D-075. Godot dùng Forward+, shader PS1 chủ yếu albedo nearest. Khuôn viên đã chia cụm/giới hạn hiển thị; không chạy generator cũ làm mất sửa chữa. Nhân vật B đang tự dựng khớp, cần phối hợp adapter A.

## Việc và các phần có thể chia nhỏ
1. **G0 — kiểm kê và mẫu nhìn:** tạo `art_source/graphics_upgrade/README.md`, `asset_manifest.json` (bản nháp tới G1), `CREDITS.md` và brief/prompt tiếng Anh cho asset. Ghi mỗi món: scene đang dùng, kích thước/pivot/hướng đo được, khoảng cách nhìn, tương tác/marker phải giữ, nguồn/license, tự dựng hay Tripo AI. Ưu tiên phòng 407/hành lang và bình cứu hỏa/nút+chuông báo cháy.
2. Tạo cảnh thử riêng `game/scenes/levels/graphics_pilot/` dùng mesh hiện có/CC0 để so vật liệu và ánh sáng. Thử tường, gạch, sắt, vải; tắt PS1 trong cảnh thử nhưng giữ độ sáng hoạt động. Chụp trước/sau cùng góc bằng renderer thật; không đổi mặc định bốn chương trước G3.
3. **G2 — pipeline Tripo AI/Blender:** sau khi operator nhận ngân sách, thử một đạo cụ; kiểm mặt sau, normals, UV, texture, kích thước, pivot, vật liệu, LOD, import GLB. Mẫu thử đề xuất: balo, giày, bình cứu hỏa, quạt; không cần tạo cả bốn trong một lần hoặc vượt trần được giao. Ghi credit và công sửa từ log C, đánh giá giá trị trước khi tạo thêm.
4. **G2 — phòng mẫu và một nhân vật:** hoàn thiện module giường/cửa/tủ đúng kích thước bằng Blender, ánh sáng phòng 407 + 10–15 m hành lang. Dựng một sinh viên với rig/clip/marker theo contract A; kiểm đứng/đi/nằm/ngồi/quay đầu. Dùng shader PBR phù hợp, không đưa texture 4K/8K hàng loạt vào game.
5. **G3/G4 — sản xuất theo đợt:** phòng/tầng 4 → phần còn lại nhà B → quản lý/ba bạn/đồng đội/xác → vườn/sân/cổng/nhà ăn → thư viện/bệnh viện. Cùng bộ vật liệu và tỉ lệ; biến thể dùng lại mesh. Mỗi nhóm có ảnh và test rồi mới merge.

## Được phép sửa
Vùng B: `art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`; Handoff/checklist card. Prototype mới đặt dưới `graphics_upgrade`/`graphics_pilot` khi thích hợp. Không sửa core, AI/adapter vùng A, project.godot, SETTINGS, menu, audio. Cửa/core sinh ra bằng code phải gửi asset/đường dẫn cho web nối.

## Tiêu chuẩn và test
- Dùng kế hoạch §6; budget gần chân thực là đề xuất cho prototype, chưa tự nới các ngưỡng PS1 hiện có. Báo số tam giác/material/texture thật cho G1/G2; file <10 MB, Git LFS, commit import/uid cần thiết.
- Với đồ thay thật: bounds visual khớp collider, bản lề/giường/marker đúng; kiểm tia ngắm, đường đi và phòng 407 trong cả bốn chương. Không tái tạo z-fighting tấm 408; giữ các khoảng thông và tọa độ thế giới.
- Đèn có bật/tắt phải đổi sáng đúng; bake không để nguồn đèn đã tắt còn sáng sai cơ chế. Prototype không làm settings người dùng bị lưu đè.
- Chụp ảnh ở ánh sáng trung tính và trong cảnh game; so cùng camera. FPS chưa được phép thì ghi chưa đo. Mặt/tay/biến dạng animation cần ảnh thực, không chỉ text test.
- `pwsh tools/test.ps1`, `pwsh tools/check.ps1` đầy đủ. Ghi rõ cái gì mới ở cảnh thử, cái gì đã gắn vào chương.

## Checklist hoàn thành
- [x] G0: kiểm kê/brief/nguồn và cảnh vật liệu riêng (bàn giao để review, chưa duyệt hình G2)
  - [x] Manifest nháp 15 mục, brief tiếng Anh, nguồn CC0 và fixture riêng đã viết.
  - [x] Đo 13 mục bằng Godot, chụp 12 ảnh renderer cùng góc và kiểm tra metadata/ảnh.
  - [x] Full test/check đạt; bàn giao phần G0 trên nhánh task bằng commit chứa Handoff này.
- [ ] G1: manifest/marker/budget thử thống nhất
- [ ] G2: một asset đi hết pipeline và phòng mẫu có ảnh
- [ ] Nhân vật mẫu hoạt động với adapter A
- [ ] Các đợt G3/G4 có review riêng, test/check và người dùng duyệt hình

## Handoff (agent điền)
### T-209 G0 — Lane B, 10–11/10/2026

- Nhánh `lane-b/T-209-realistic-art-pilot`, tạo từ `origin/main` `e3ed54a` có D-077/D-078; workspace sạch trước khi làm. Chỉ `D:\GAME_WORK\lane-b`. Commit bàn giao: `T-209: add G0 asset inventory and isolated material pilot` (commit chứa Handoff này); đích push `origin/lane-b/T-209-realistic-art-pilot`. Không sửa STATUS/DECISIONS/Review, không mở PR.
- Đầu ra: `art_source/graphics_upgrade/{README.md,asset_manifest.json,BRIEFS.md,CREDITS.md,generate_materials.py}`; cảnh `game/scenes/levels/graphics_pilot/material_pilot.tscn`, probe `measure_assets.gd`, test `game/tests/levels/test_graphics_pilot.gd`; 12 texture thủ tục 256² dưới `game/assets/textures/graphics_pilot/`.
- Đã làm: manifest nháp 15 mục có nguồn, path, pivot/hướng, khoảng nhìn đề xuất, marker phải giữ và cách dựng. Pilot lấy snapshot hình/đèn tầng 4, thử tường/gạch/sắt/vải, bỏ PS1 trong after nhưng giữ brightness hiện hành, không ghi settings. Không gắn vào chương, không đổi logic/collision/nav/timing hoặc lời thoại.
- Gửi web/C/F ngay: bình cứu hỏa có marker `(48.83,-5.5,2.4)` lệch tâm mesh; `FireAlarm1F` do core sinh tại `(.9,-8.5,.12)`, visual `.22×.28×.06`; chuông chưa có mesh, âm ở `(42,-7.7,.2)` nhưng noise/crowd dùng `(42,-9.9,2)`. Hai điểm không được hợp nhất. B cần web/F chốt mount/basis/kích thước chuông ở G1; không đoán node/API mới. README T-153 có tọa độ giường B cũ; dùng scene hiện hành x local=7.35.
- Test/check cuối trên Windows, Godot 4.7.2, ngày 11/10: `pwsh tools/check.ps1` **`RESULT: check 0 error(s)`**, 337 script (01:47–01:55); `pwsh tools/test.ps1` **`RESULT: 724 passed, 0 failed`** (01:55:07–02:16:03). Log cục bộ: `build/t209-full-check.log`, `build/t209-full-test.log` (ignored). Full test lượt đầu bị probe tự gọi thoát khi smoke nạp mọi scene; đã sửa chỉ chạy khi có `--pilot-measure`, thêm regression, kiểm fixture 2/0 và smoke 1/0 trước khi chạy lại full suite đạt kết quả trên.
- Kiểm asset: rà JSON, scene path, ID, PNG 256²/hash sinh lại và `git diff --check` đạt; generator tạo 12 PNG, tổng 540.202 byte. `RESULT: graphics inventory 13 assets measured PASS`; `RESULT: graphics pilot capture 12 images PASS` (Forward+ Vulkan, RTX 3050 Laptop, 1280×720, brightness 1.0). Metadata đủ 6 cặp cùng camera/FOV/kích thước, ảnh trước/sau khác hash; import mới bật mipmap, PNG qua LFS và dưới 10 MB/file.
- Kết quả đo: `art_source/graphics_upgrade/{measured_assets.json,MEASUREMENTS.md}`; balo 96 tam giác, cửa 120, thân bình 48; cụm giường 7.740/4.536 gồm mùng/biến thể ẩn, không dùng để thay trần một model. Ảnh cuối tại `previews/*.png`, metadata tại `previews/capture_report.json`; đã thay toàn bộ bộ ảnh cũ sau sửa binding. Bốn vật liệu áp vào 26 mesh: tường 3, gạch 1, sắt 5 (đúng từng surface), vải 17.
- Cách kiểm: README có lệnh full test, probe, capture và check. Ảnh fixture tĩnh đã xem sơ bộ: gạch/vải rõ hơn, các vùng PS1 chưa nâng vẫn lộ texture cũ; chưa đủ kết luận gần chân thực G2, cần người dùng duyệt.
- Dependency/mục chưa đạt: G1 contract/schema/marker/budget chưa ghép main; G2 chờ kết nối/ngân sách/license Meshy và contract A; không tự làm rig/setting mới. Chưa có phòng G2/nhân vật, review người dùng hoặc chơi tay bốn chương; ray/nav/đèn của bản thay asset thật chưa thể nghiệm thu vì chưa gắn vào chương. Suite hồi quy hiện hành đã PASS, nhưng không thay các kiểm chứng đó. Chưa đo FPS hoặc chạy bot 3–4. Meshy credit thực chi **0**, không cài MCP/plugin.
- Đã đối chiếu draft T-207 trên `origin/core/T-207-graphics-core-contract` (`4fc4999`, đọc ngày 11/10): tọa độ chuông/nút/bình khớp. Tên `FireBellMount`, schema `asset_id/scene_path/binding/...` và key video mới vẫn là đề xuất G1; B chưa tạo marker hoặc dùng key đó. Cần web/C ánh xạ manifest nháp B sang schema được chốt. Ghi nhận cửa 407 chương 3–4 dùng proxy/Blocker; G0 không đụng cánh hoặc collider. Khi G3 thay cửa phải kiểm cả hai cơ chế chương 1–2 và 3–4.
- Yêu cầu ngoài phạm vi: web/C chốt schema và ID; web/A chốt wrapper/rig; web/F chốt visual chuông ở vị trí âm; D/web giữ contract brightness. Integrator xếp lượt test/render Windows, review G0 rồi mới mở dependency G1/G2. B không sửa file của các lane để tự giải quyết.
- Điều phối: người dùng đã dành **lượt kế tiếp cho Lane B, chạy khi không có Godot khác**. B đã chờ các lượt Lane A ngày 10/10; tiếp tục 11/10 khi máy trống, chạy fixture/render/full test/check tuần tự. Lượt Windows của B hoàn tất lúc 02:16:03 ngày 11/10; integrator có thể xếp lượt kế tiếp. G0 đã bàn giao đầu ra, **T-209 chưa done**.
- Chặn: G0 không còn chặn kỹ thuật. **Blocked: các bước G1/G2 chờ contract được ghép main và các quyền/đầu vào nêu trên.** Integrator/web có thể review số đo, ảnh và brief ngay trên nhánh này để chốt G1.

## Review (integrator)

### 11/10/2026 — Astra, D-079

- Nhận **G0** từ lane B, commit `87e99a6`; ghép cùng năm nhánh còn lại. **Chưa đánh dấu toàn bộ T-209 done.**
- Nhận kiểm kê, vật liệu CC0 và 12 ảnh renderer; đã xem ba ảnh ghi trong báo cáo chung. Chưa duyệt chất lượng gần chân thực hoặc phòng G2. Balo là mẫu đầu; bổ sung số đo cụ thể vào brief và chuyển manifest sau schema G1. Rà UID green_paint cũ và khôi phục global ps1_strength khi rời pilot; giữ nguyên budget production.
- Phạm vi diff đạt; không nới test, không đổi gameplay/default. Không sửa code lane trong lượt review này.
- Full Windows test/check bản ghép và kiểm `--t202-integration` là điều kiện trước commit. Kết quả thực/thời điểm/log ở message commit `D-079`; không dùng số test lane riêng thay kết quả tích hợp.
- Đọc [báo cáo chung và yêu cầu G1](../handoff/REVIEW_G0_2026-10-11.md), làm phần Review của lane trên nhánh hiện có sau fetch/rebase; không tự dùng contract G0 như API production đã chốt. Chưa chạy Meshy trả phí hoặc FPS/bot.

### 11/10/2026 — cập nhật D-080, Astra

- Nhà cung cấp hiện hành: **Tripo AI**. Tiếp tục phần việc trong [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md); không làm lại G0 hoặc đổi source/credits lịch sử.
- Tripo Studio/API tách ví; đường thủ công không cần client API. B/C cập nhật brief/metadata/QA đúng dịch vụ; A/D/F/web giữ ràng buộc gameplay đã review. Chưa cấp ngân sách/ngoại lệ license hoặc triển khai API live.
