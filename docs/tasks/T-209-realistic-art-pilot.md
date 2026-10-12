# T-209 — Pipeline mỹ thuật và phòng 407 gần chân thực

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](../handoff/T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

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
  - [x] Sau D-080: brief balo Tripo Studio có bounds/pivot/trục, trần prototype và hồ sơ ví/nguồn/license.
  - [x] Gửi đề xuất mapping schema và ảnh khảo sát giá đỡ chuông cho Astra/C/F; chưa chuyển manifest hoặc tạo mount production.
  - [x] Pilot dùng override theo vòng đời; kiểm pixel Forward+ sau thoát đạt, không ghi settings.
  - [x] Full test/check bản tiếp Review đạt; bàn giao bằng commit chứa Handoff này. Schema/mount vẫn chờ Astra duyệt.
- [ ] G2: một asset đi hết pipeline và phòng mẫu có ảnh
- [ ] Nhân vật mẫu hoạt động với adapter A
- [ ] Các đợt G3/G4 có review riêng, test/check và người dùng duyệt hình

## Handoff (agent điền)
### G1 balo sau D-083 — Lane B, 11/10/2026

- Đầu mối hiện hành: **Claude Code (Opus 5.5), integrator**, thay Astra; core/contract và lượt Godot gửi integrator. Giữ nhánh `lane-b/T-209-realistic-art-pilot`; đầu phiên sạch, fetch/rebase lên `origin/main` `6e3b06f` có D-083, không ghi đè việc dở hoặc làm lại phần D-082 đã nhận.
- Đã lập `art_source/graphics_upgrade/backpack_g1_manifest.json`, version `t210-g1-static-1`, ID đúng `room407_backpack`; dữ liệu geometry/placement lấy từ `measured_assets.json` của B, không từ mẫu C. `asset_manifest.json` G0 giữ nguyên lịch sử; README chỉ rõ bản G1 riêng hiện dùng để kiểm balo. Bảng số đo và command tại `BACKPACK_G1.md`.
- Theo contract T-207: owner B; binding `res://scenes/levels/floor4/floor4.tscn` / `Room407/Details/Trung/Backpack`, class Node3D; position `(33.78,0.02,-4.52)`, rotation `(0,90,0)`, scale `(1,1,1)`. Đã đối chiếu class/path/placement và phép đo node thực với imported GLB tại `backpack_g1/facing_report.json`; scene nguồn chỉ instantiate off-tree, không chạy gameplay.
- Basis đã xem bằng renderer: mặt túi trước **−Z**, lên **+Y**, pivot `(0,0,0)`; child mesh quay 180° Y nên không dùng dấu accessor chưa nhân transform. Quy tắc chuẩn hóa Tripo và 4 link ảnh trong mục "Hướng mặt trước" của `TRIPO_BACKPACK.md`. Ảnh `backpack_g1/{front_neg_z_up_pos_y,back_pos_z_up_pos_y,side_pos_x_up_pos_y,underside_neg_y_screen_up_neg_z}.png`: cùng ánh sáng, root identity, chỉ đổi camera; Godot 4.7.2 Forward+/RTX 3050 Laptop, 1280×720. `RESULT: backpack facing 4 images PASS`; đã xem cả 4, túi ở −Z, quai ở +Z, đáy kín. Tên file ghi trục; báo cáo ghi camera/ánh sáng/hash nguồn.
- Bảng số đo mới của C probe và so target tại `BACKPACK_G1.md`: size `(0.29000002,0.45639998,0.30270001)` m, min `(-0.14500001,0.01000001,-0.13250001)` m, **96 tris, 3 material, 3 texture 128×128** (cloth/ink/moss), scale `(1,1,1)`. Manifest giữ target từ đo G0: size `(0.29,0.45636,0.30274)`, min `(-0.145,0.01,-0.1325)`; sai lệch <0.00004 m < tolerance khai 0.0001 m. Trần vẫn 3000/2/1024 theo D-079; không gọi balo cũ là asset Tripo.
- Đã chạy `python -B tools/graphics/asset_qa.py art_source/graphics_upgrade/backpack_g1_manifest.json --probe-log build/t209-g1-probe.log`: nguyên văn **`"errors": ["material budget exceeded"]`, `"status": "FAIL"`, exit 1** — đúng 3 > 2; không có lỗi schema/kiểu/scale/tolerance/geometry khác. Output đầy đủ tại `backpack_g1/asset_qa_result.json`. Có 368 unavailable (315 missing_dependency_hash, 43 dependency_closure_unproven, 10 mục duyệt/phép đo); probe GLB không chứng minh closure của toàn floor4/wrapper mà validator R3 quét. Không bịa hash/sửa binding hoặc tools để xóa trạng thái thiếu; không coi QA FAIL thành PASS. Sau full test sẽ đối chiếu lại log mới nhất.
- Người dùng đã xác nhận "đã xin, bạn có thể tiếp tục"; B đã chờ cả chuỗi integrator và Godot trống lúc 23:45 ngày 11/10 mới import/render/probe. **Full `pwsh tools/test.ps1` đang chạy từ 23:46:29, sau đó `pwsh tools/check.ps1`; chưa có RESULT cuối hoặc commit/push.** `git diff --check` đạt.
- Chưa kiểm: full test/check đang chạy, nghiệm thu mẫu mới/closure wrapper/nguồn/hình cuối, gameplay bốn chương của asset thay thật, animated bounds/VRAM/FPS. Đề xuất gửi integrator/C: xác định mức evidence wrapper/closure cần bổ sung trước nghiệm thu asset mới; không tự sửa công cụ C. Facing/owner ghi brief/contract, không thêm field schema. Không Tripo (mọi hình thức), MCP/plugin hoặc bot; không sửa scene mặc định, core, collider/nav/timing, STATUS/DECISIONS/Review. T-209 chưa done.

### Tiếp Review G0 / D-080 — Lane B, 11/10/2026

- Giữ nhánh `lane-b/T-209-realistic-art-pilot`; workspace sạch đầu phiên, fetch/rebase an toàn lên `origin/main` `acbf771` có D-080, không làm lại G0 hoặc đổi task ID. **Astra đã nhận T-207 thay Claude web**, đầu mối core/contract của bàn giao mới; các mục G0 bên dưới là lịch sử.
- Đầu ra mới: `art_source/graphics_upgrade/TRIPO_BACKPACK.md` (Studio thủ công → GLB → Blender → Godot; số đo/pivot/placement/trần thử và hồ sơ operator); `REVIEW_D080.md` (mapping đề xuất cho C/Astra, khảo sát mount, brightness/lifetime, rà UID); cập nhật brief tiếng Anh và credits cho nội dung mới, giữ tác giả/license asset cũ.
- Cleanup: pilot chuyển sang `ShaderGlobalsOverride` với `params/ps1_strength`; khi rời fixture engine bỏ override và dùng lại base hiện hành, không ghi config. Đã kiểm pixel trên Forward+ với base đổi trong lúc pilot mở. Brightness trong pilot có một consumer screen shader; không thêm preset/key hoặc consumer gameplay.
- Mount: đã chụp/xem `review_d080/bell_front.png`, `bell_side.png`, metadata `capture_report.json`. `bell_mount_probe.tscn` chỉ chạy với `--bell-mount-capture`, dùng snapshot render không script gameplay/collision/audio. Đĩa đỏ 0.28×0.28×0.12 m là envelope đề xuất, có giá đỡ bám facade; giữ âm `(42,-7.7,0.2)` và noise `(42,-9.9,2)`. Khối Door7 gốc và khung `KitDetail1/Frame7` nhìn thấy khác nhau; ảnh/số đo để Astra/F chốt chứ chưa tạo `FireBellMount` production.
- UID: nguồn green_paint hiện là `uid://ib3fwalyl3p2`; rà tĩnh chưa thấy tham chiếu UID khác trong file nguồn, GLB dùng URI texture. Không tái hiện warning green_paint/invalid UID trong log full check/test, render test và capture mới; chưa sửa UID/asset khi không có bằng chứng, không coi đã sửa cache máy khác.
- Kiểm đã chạy theo lượt mới được người dùng bàn giao khi Godot trống: focused headless `RESULT: 3 passed, 0 failed` (pixel ghi SKIP ở headless); **Forward+ thực `RESULT: 3 passed, 0 failed`**, gồm pixel restoration; mount `RESULT: bell mount survey 2 images PASS`, RTX 3050 Laptop, 1280×720. Lỗi thử property/group và suy luận kiểu đã sửa trước lượt đạt cuối. Log cục bộ `build/t209-d080-{focused,render-test,bell-capture}.log`.
- **Full Windows cuối ngày 11/10:** `pwsh tools/check.ps1` từ **11:09:44–11:17:24**, **`RESULT: check 0 error(s)`**, 345 script; `pwsh tools/test.ps1` từ **11:17:24–11:38:32**, **`RESULT: 744 passed, 0 failed`**. Pixel test ghi SKIP trong suite headless, đã được chạy thật ở lượt Forward+ riêng nêu trên. Log ignored `build/t209-d080-full-{check,test}.log`. Test nav tầng 4 từng được báo lỗi trên Linux đạt ở lượt Windows này, chưa tái hiện và không sửa/nới test. `git diff --check` đạt; kiểm Review/header card giữ nguyên, 2 PNG 1280×720 qua LFS và dưới 10 MiB đạt.
- Yêu cầu ngoài phạm vi gửi **Astra/C**: review/ghép schema G1 đạo cụ tĩnh, root-local và dependency hash trước khi B chuyển manifest. **Astra/F**: review giá đỡ/basis/kích thước chuông; **Astra/D**: nhận consumer brightness/lifetime hiện hành. A/B tiếp tục rig khi contract riêng đủ; balo không bị buộc chờ rig/settings/chuông.
- Tripo: chưa tài khoản/gói xác nhận, chưa ngân sách/key/license exception; không tạo tác vụ hoặc cài plugin/MCP. Studio/API tách ví, API không là dependency nhập thủ công. Credit thực chi B **0**; không có model/task ID/asset Tripo mới. Chưa bot 3–4/FPS, export hoặc thay đồ họa production; chưa duyệt hình cuối.
- Bàn giao: commit `T-209: prepare Tripo Studio handoff and address G0 review` (commit chứa mục này), push nhánh hiện có `origin/lane-b/T-209-realistic-art-pilot`; không PR/main push. Lượt Windows của B **đã nhả lúc 11:38:32 ngày 11/10**. Phần chuẩn bị/sửa Review không còn chặn kỹ thuật. **Blocked cho bước tạo/nhập Tripo:** schema G1 đã duyệt và hồ sơ quyền/ngân sách/nguồn chưa đủ. Mount chờ Astra/F review phương án; không đánh dấu toàn T-209 done.

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

### 11/10/2026 — D-081, đổi đầu mối core

Astra làm thay Claude web ở T-207; gửi yêu cầu core/contract về Astra. Đọc contract G1 cập nhật và [bảng việc từng lane](../handoff/T207_G1_ASTRA_2026-10-11.md), tiếp tục task/nhánh hiện có. Giữ lịch sử G0; không sửa file lane khác hoặc coi quy ước mới là bằng chứng validator/asset đã đạt.

### 11/10/2026 — Astra, D-082, review tiếp G1

Nhận `21f2f9b` — brief Tripo, cleanup override pilot và khảo sát mount. Integrator chạy Forward+ RTX 3050: 3/3, gồm pixel restoration; đã xem hai ảnh mount B. Phương án giá đỡ đủ làm căn cứ kỹ thuật, chưa marker production/duyệt chất lượng cuối. B bổ sung facing/basis từ model balo cũ; chờ schema C sửa được ghép rồi mới chuyển manifest. Không cần làm lại brief/G0 hoặc chờ rig/settings.

Full test/check sau cập nhật là điều kiện commit/push; kết quả, giờ và log ở message D-082. Các phần runtime prototype/QA được nhận không đổi cảnh chơi mặc định.

### 12/10/2026 — Claude (integrator, Opus 5.5), D-085: **nhận G1 balo, đã ghép**
- Lane B hết hạn mức sau khi `git add` đủ 15 file nhưng trước khi commit. **Claude làm thay** phần commit/push: chép nguyên 15 file đã stage từ workspace B (không sửa nội dung, không sửa workspace B) thành commit `a178500` trên `lane-b/T-209-realistic-art-pilot`. Full test/check của B chạy trên workspace B lúc 23:46: 746 passed, 0 failed; check 0 error(s).
- Review: manifest G1 đúng schema `t210-g1-static-1`, số đo từ probe thật; binding/placement khớp floor4; 4 ảnh hướng đã xem (trước: túi phụ; sau: hai quai; cạnh: túi −Z, quai +Z). `asset_qa` trên balo cũ: chỉ `material budget exceeded` (đúng). Phạm vi: `art_source/`, `game/scenes/levels/graphics_pilot/` (probe chụp ảnh, không vào cảnh chơi), card.
- Kết luận và tiêu chí G2 cho mẫu Tripo: `docs/handoff/G1_NGHIEM_THU_BALO_2026-10-12.md`. Việc tiếp theo của B (khi có mẫu Tripo): chuẩn hóa hướng/kích thước trong Blender, nhập thư mục prototype, chạy công cụ C, ảnh trước/sau.

### 12/10/2026 — Claude (integrator), **Claude làm thay** lane B: G2 balo Tripo
- Lưu nguồn Tripo nguyên vẹn + 2 PDF điều khoản (`art_source/graphics_upgrade/tripo/room407_backpack/source|evidence/`, LFS), CREDITS, manifest G2.
- `normalize_backpack.py` (Blender 5.2.2): xoay 180° (túi về −Z), khớp khung balo cũ, texture 2048 → 1024, đổi tên texture; kết quả `game/assets/models/graphics_pilot/room407_backpack_tripo.glb` (import mặc định Godot, không dùng importer PS1).
- `game/scenes/levels/graphics_pilot/backpack_g2_capture.tscn` (`-- --backpack-g2-capture`, cần renderer thật): 4 góc giống bộ ảnh G1 + trước/sau phòng 407 cùng camera; bản chơi không đổi.
- QA C: `errors: []`; chờ credit/mã model từ chủ dự án và duyệt hình. Chi tiết `docs/handoff/TRIPO_PHIEU_BALO.md`.
