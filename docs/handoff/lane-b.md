# Prompt bàn giao — Lane B (Môi trường và 3D)

> **15/10, D-116:** prompt đang dùng là **mục 7** (T-219, mẫu thử nhân vật quản lý: mẫu C + phần dùng chung).

> **14/10, D-107:** prompt đang dùng là **mục 6** (T-216, sửa 3 lỗi nhà tắm).

> **11/10, D-083:** schema/validator G1 của C đã ghép; integrator là Claude (Opus 5.5) ở máy. Prompt đang dùng: **mục 4** (chuyển manifest balo + hướng mặt trước).

> **D-082:** đã review phần mới; đọc Review card và [kết luận chung](REVIEW_G1_2026-10-11.md), giữ công việc đã nhận. Không làm lại G0 hoặc tự chạy một vòng test mới chỉ vì nhận thông báo; tiếp tục đúng phần còn thiếu trong Review.

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

> **D-080, 11/10:** dùng **Tripo AI thay Meshy**. Studio thủ công ưu tiên cho mẫu đầu; API dùng ví riêng. Đọc [cập nhật provider](TRIPO_AI_CHUYEN_DOI_2026-10-11.md), tiếp tục gói hiện có và giữ kết quả G0.

> **D-079, 11/10:** G0 đã review/ghép. Khi tiếp tục, fetch/rebase main chứa D-079 rồi đọc Review của card và [yêu cầu G1](REVIEW_G0_2026-10-11.md); không làm lại G0 theo đoạn prompt cũ. Đây là phần tiếp của gói đã giao, chưa mở Tripo AI trả phí hoặc production.

**10/10/2026:** T-209, D-076/D-077; chủ dự án xác nhận lane còn hạn mức. Astra chỉ điều phối tạm 10–11/10, Opus 5.5 ở máy nhận lại sau đó. Card đã phân công; trạng thái thực xem Handoff.

## 1. Prompt giao task (dán nguyên khối)
```text
Bạn là agent Lane B (Môi trường và 3D) của game Ký túc xá sau 12 giờ, Godot 4.7.2/GDScript.
Task T-209: art pipeline và phòng 407 gần chân thực. Trả lời/tài liệu tiếng Việt, code tiếng Anh.
D-081: Astra làm thay Claude web ở T-207. Gửi yêu cầu core/contract về Astra.
Đọc docs/handoff/T207_G1_ASTRA_2026-10-11.md và contract G1 cập nhật.
Repo: https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio.git
Chỉ làm trong D:\GAME_WORK\lane-b; không sửa D:\GAME_DEMO hoặc workspace lane khác.

1. Kiểm git status ở workspace của bạn; không ghi đè công việc đang có. git fetch origin.
   Nhánh: lane-b/T-209-realistic-art-pilot. Nếu local đã có thì switch và pull --ff-only.
   Nếu chỉ origin có thì tạo tracking branch. Nếu chưa có thì tạo từ origin/main có D-081.
   Rebase an toàn lên origin/main có D-081, giữ mọi thay đổi cục bộ.
2. Đọc AGENTS.md, docs/STATUS.md, docs/design/GRAPHICS_UPGRADE_PLAN.md và docs/tasks/T-209-realistic-art-pilot.md.
   Đọc docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md và Review card.
3. G0 đã ghép D-079. Đọc Review và cập nhật D-080, tiếp tục các yêu cầu G1 đúng lane; không làm lại G0.
   Những bước sau phụ thuộc G1/G2 làm khi điều kiện trong card đủ; không tự đoán API/setting.
   Chỉ sửa đúng vùng của card. Giữ logic, collision, nav, timing; không sửa luật hoặc lời thoại.
4. Tripo AI chưa được xác nhận gói/đã mua/ngân sách; Studio/API tách credit: không tiêu credit, không cài MCP/plugin.
   Không chạy bot chương 3–4 hoặc FPS. Phần chuẩn bị/công cụ không cần chờ các quyền này.
5. Bàn giao từng phần bằng commit nhỏ “T-209: ...”; không đánh dấu cả gói done khi mới xong G0.
   Trước commit: full pwsh tools/test.ps1 và pwsh tools/check.ps1; ghi RESULT và những gì chưa kiểm.
   Phối hợp integrator xếp lượt full test/render trên Windows, tránh nhiều lượt Godot tranh tài nguyên.
   git push -u origin lane-b/T-209-realistic-art-pilot. Không push main, không mở PR nếu chưa được yêu cầu.
6. Cập nhật Handoff/checklist card của bạn, báo: đã làm; test/check; dependency/mục chưa đạt;
   yêu cầu ngoài phạm vi; commit/nhánh; có chặn gì không. Không sửa STATUS/DECISIONS/Review.
```

## 2. Prompt tiếp tục
```text
Tiếp tục T-209 ở D:\GAME_WORK\lane-b, nhánh lane-b/T-209-realistic-art-pilot.
Kiểm git status, fetch, switch/pull --ff-only an toàn; đọc Handoff tại docs/tasks/T-209-realistic-art-pilot.md.
Đọc STATUS và kế hoạch đồ họa để biết mốc G1/G2 đã đủ chưa. Rebase origin/main nếu cần, không mất thay đổi cục bộ.
Làm các phần còn được mở trong card và bàn giao theo mục 1; không tạo lại asset/tác vụ Tripo AI đã có task ID.
```

## 3. Prompt yêu cầu sửa
```text
Integrator trả T-209: git fetch origin; đọc Review trên origin/main:docs/tasks/T-209-realistic-art-pilot.md.
Rebase nhánh lane-b/T-209-realistic-art-pilot lên origin/main, sửa đúng từng ý trong phạm vi.
Chạy full test/check, cập nhật Handoff và push nhánh; nêu rõ phần chưa kiểm/đang chờ.
```

## 4. Prompt sau D-083: chuyển manifest balo và chốt hướng mặt trước (bản đầy đủ, 11/10 integrator viết)

Dán nguyên khối, dùng được cho cả phiên lane B cũ lẫn phiên mới. Chỉ gửi khi chủ dự án xác nhận lane B còn hạn mức.

```text
Bạn là agent Lane B (Môi trường và 3D), game "Ký túc xá sau 12 giờ" (Godot 4.7.2). Trả lời/tài liệu tiếng Việt, code tiếng Anh.
Chỉ làm trong D:\GAME_WORK\lane-b. Không sửa D:\GAME_DEMO hay workspace lane khác.
Từ 11/10 integrator là Claude (Opus 5.5) ở máy, thay Astra. Mọi câu hỏi core/contract và việc xin lượt chạy Godot đều gửi về integrator.

VIỆC: T-209, phần G1 cho balo room407_backpack, nhánh lane-b/T-209-realistic-art-pilot.
D-083 đã ghép schema/validator G1 của lane C vào main. Không làm lại G0/brief/pilot/mount survey đã nhận (D-082).
Không sửa tools/graphics/ (vùng C), core, collision/nav/timing, cảnh chơi mặc định. Không nới trần D-079 hay sai số D-081.

1. git status (không ghi đè việc đang dở) → git fetch origin → rebase an toàn nhánh lên origin/main (có D-083).
2. Đọc: docs/handoff/REVIEW_G1_2026-10-11.md (mục B), Review trong docs/tasks/T-209-realistic-art-pilot.md,
   D-079/D-081/D-083 trong docs/DECISIONS.md, tools/graphics/G1_SCHEMA.md, tools/graphics/sample_g1_manifest.json,
   art_source/graphics_upgrade/TRIPO_BACKPACK.md.
3. Chuyển manifest: tạo bản khai G1 cho room407_backpack trong art_source/graphics_upgrade/ (schema_version "t210-g1-static-1").
   Số đo lấy từ đo thật root-local (measured_assets.json / probe), không chép số của file mẫu C.
   Giữ asset_id đúng chữ thường "room407_backpack". Xác nhận node path, root_class, placement, owner theo contract T-207.
   Giữ manifest G0 cũ làm lịch sử, ghi rõ bản nào đang có hiệu lực.
4. Chốt hướng mặt trước (facing) của balo hiện hành, TRƯỚC khi có mẫu Tripo:
   - Mở model hiện hành, xác định mặt trước (mặt có túi/khóa nhìn ra người chơi) theo trục root-local (ví dụ +X/-Z), kèm hướng lên.
   - Chụp 4 ảnh cùng ánh sáng: trước, sau, cạnh, dưới; ghi trục lên ảnh hoặc tên file.
   - Ghi basis đã chọn vào TRIPO_BACKPACK.md (mục "Hướng mặt trước"): trục trước, trục lên, pivot, ảnh tham chiếu,
     và quy tắc xoay GLB Tripo về đúng basis này trong Blender trước khi nhập.
   - Schema G1 chưa có field facing: KHÔNG tự thêm field vào schema. Ghi trong brief; nếu thấy cần field, nêu đề xuất trong Handoff.
5. Chạy công cụ C trên manifest mới:
   python -B tools/graphics/asset_qa.py <manifest G1 của B> --probe-log <log probe/full test mới nhất>
   Kết quả mong đợi: balo CŨ FAIL đúng lỗi "material budget exceeded" (3 > 2); không có lỗi schema/kiểu/scale/tolerance nào khác.
   Lỗi khác ngoài material: sửa dữ liệu của B; nếu do công cụ C sai, ghi vào Handoff, không sửa tools/graphics/.
   Không gọi balo cũ là asset Tripo, không hạ yêu cầu để nó PASS.
6. Khi sẵn sàng full test/check Windows: NHẮN integrator xin lượt rồi mới chạy pwsh tools/test.ps1, sau đó pwsh tools/check.ps1.
   Render ảnh facing cũng là lượt Godot: xin lượt cùng lúc. Không đo FPS, chạy bot hay dùng Tripo (trả phí hoặc MCP).
7. Hai lệnh đạt → commit nhỏ "T-209: ..." → git push origin lane-b/T-209-realistic-art-pilot (không push main, không mở PR) → báo nhả lượt Godot.
8. Cập nhật Handoff trong card (không sửa STATUS, DECISIONS hay mục Review) và báo lại, gồm:
   - Đường dẫn manifest G1; bảng số đo (kích thước, bounds_min, tam giác, vật liệu, texture) và nguồn đo.
   - Basis mặt trước/lên/pivot đã chọn, 4 ảnh tham chiếu.
   - Lệnh asset_qa đã chạy và nguyên văn errors/status.
   - Dòng RESULT của test.ps1 và check.ps1; commit hash.
   - Phần chưa kiểm, đề xuất contract (nếu có), có bị chặn gì không.
```

## 5. Prompt T-213: làm thử góc phòng 407 gần chân thực (D-090, 12/10)

Dán nguyên khối, dùng được cho phiên cũ lẫn phiên mới. Chỉ gửi khi chủ dự án xác nhận lane B còn hạn mức.

```text
Bạn là agent Lane B (Môi trường và 3D), game "Ký túc xá sau 12 giờ" (Godot 4.7.2). Trả lời/tài liệu tiếng Việt, code tiếng Anh.
Chỉ làm trong D:\GAME_WORK\lane-b. Không sửa D:\GAME_DEMO hay workspace lane khác.
Integrator là Claude (Opus 5.5) ở máy. Câu hỏi core/contract và việc xin lượt chạy Godot đều gửi về integrator qua chủ dự án.

VIỆC: T-213 — làm thử "góc phòng 407" gần chân thực bằng Blender theo số đo + texture CC0 chụp thật + ánh sáng tốt, đặt sẵn đồ Tripo đã duyệt, trong một cảnh pilot riêng. Bản chơi không đổi.

1. git status (không ghi đè việc đang dở) → git fetch origin → tạo nhánh lane-b/T-213-room407-corner-pilot từ origin/main mới nhất (có D-089, D-090).
2. Đọc: AGENTS.md, docs/STATUS.md, docs/tasks/T-213-room407-corner-pilot.md (toàn bộ), D-076/D-086/D-088/D-089/D-090 trong docs/DECISIONS.md,
   art_source/graphics_upgrade/MEASUREMENTS.md và measured_assets.json, docs/handoff/TRIPO_DOT1_PHONG407.md (vị trí/kích thước đồ Tripo).
3. Làm đúng mục "Cách làm" và đạt mục "Tiêu chí chất lượng" của card (không còn khối hộp như ảnh G0; giường/bàn ngang tầm đồ Tripo, nếu không đạt thì đề xuất prompt Tripo cho phần nhìn). Cách làm: hình khối bằng script Blender theo số đo (D:\Tools\Blender\5.2.2\blender.exe), vật liệu CC0 từ ambientCG/Poly Haven (ghi URL + giấy phép vào CREDITS.md),
   decal, ánh sáng 2 trạng thái (đèn tuýp bật; đèn tắt + đèn pin), thử ít nhất một cách ánh sáng gián tiếp và ghi ưu/nhược.
   Cài đặt ánh sáng/môi trường chỉ trong cảnh pilot; không đổi project.godot, renderer mặc định, cảnh chương hay floor4/room_407/room407_details/extension.
4. Đặt balo graphics_pilot/room407_backpack_tripo_r2.glb và 7 món graphics_pilot/room407_batch1/ đúng vị trí/hướng đồ cũ (khăn hạ theo xô mới cao ≈ 0,26 m).
5. Lưu file .blend của góc phòng trong art_source/graphics_upgrade/room407_corner/ (≤ 10 MiB/file) để chủ dự án mở Blender xem trực tiếp.
6. Chụp ảnh trước/sau cùng camera, ≥ 4 góc × 2 trạng thái ánh sáng như card ghi, kèm capture_report.json; viết test trong game/tests/levels/ như card.
7. Chạy offline/headless trước. Khi cần renderer thật (chụp ảnh) hoặc full test/check: NHẮN integrator xin lượt rồi mới chạy
   pwsh tools/test.ps1, sau đó pwsh tools/check.ps1. Không Tripo, không đo FPS, không chạy bot.
8. Hai lệnh đạt → commit nhỏ "T-213: ..." → git push origin lane-b/T-213-room407-corner-pilot (không push main, không mở PR) → báo nhả lượt Godot.
   Sắp hết hạn mức thì dừng ở bước đang làm, commit phần đã có ("T-213 WIP: ..."), push, ghi Handoff rõ còn dở gì.
9. Cập nhật Handoff trong card (không sửa STATUS, DECISIONS hay mục Review) và báo lại, gồm:
   - Đường dẫn cảnh pilot, file .blend, ảnh trước/sau (liệt kê từng ảnh), capture_report.json.
   - Bảng nguồn texture (bộ, URL, giấy phép, kích thước) và tổng tam giác/texture của góc phòng.
   - Cách ánh sáng gián tiếp đã thử, ưu/nhược; cài đặt môi trường.
   - Dòng RESULT của test.ps1 và check.ps1; commit hash.
   - Phần chưa làm, đề xuất cho bước dựng cả phòng/tòa nhà, có bị chặn gì không.
```

## 6. Prompt T-216: sửa 3 lỗi nhà tắm phòng 407 (D-107, 14/10)

Dán nguyên khối, dùng được cho phiên cũ lẫn phiên mới.

```text
Bạn là agent Lane B (Môi trường và 3D), game "Ký túc xá sau 12 giờ" (Godot 4.7.2). Trả lời/tài liệu tiếng Việt, code tiếng Anh.
Chỉ làm trong D:\GAME_WORK\lane-b. Không sửa D:\GAME_DEMO hay workspace lane khác.
Integrator là Claude (Opus 5.5) ở máy. Câu hỏi core/contract và việc xin lượt chạy Godot đều gửi về integrator qua chủ dự án.

VIỆC: T-216 — sửa 3 lỗi nhà tắm phòng 407 chủ dự án báo sau G3: giẻ lau chương 2 vẫn là hình PS1 và nằm trong lòng bồn rửa mặt;
bảng điều khiển sen tắm (và hai nút Có/Không) bị vòi sen che, cần dời ra cạnh vòi sen; một góc tường nhà tắm nhấp nháy.

1. git status (không ghi đè việc đang dở) → git fetch origin → tạo nhánh lane-b/T-216-bathroom-fixes từ origin/main mới nhất (có D-107).
2. Đọc: AGENTS.md, docs/STATUS.md, docs/tasks/T-216-bathroom-fixes.md (toàn bộ: nguyên nhân đã dò, việc cần làm, được phép sửa),
   D-102…D-107 trong docs/DECISIONS.md, docs/tasks/T-215-g3-room407-playable.md (phòng mới vào bản chơi thế nào),
   game/scenes/levels/room407/room407.gd và room407_furnish.gd, game/data/room407/placements.json.
3. Làm đúng mục "Việc cần làm" của card, chỉ sửa file trong "Được phép sửa". Giữ luật, thời gian, cách chơi chương 2.
   Kiểm lại nguyên nhân trước khi sửa; góc nhấp nháy phải tìm đúng trên ảnh chụp, sửa tận gốc (build_lived_in.py + xuất lại bath_tiles.glb).
4. Model giẻ mới: Blender (D:\Tools\Blender\5.2.2\blender.exe) + texture CC0 (ghi nguồn). Muốn dùng Tripo thì ghi prompt đề xuất vào Handoff, không tiêu credit.
5. Chạy offline/headless trước. Khi cần chụp ảnh (Forward+) hoặc full test/check: NHẮN integrator xin lượt rồi mới chạy
   pwsh tools/test.ps1, sau đó pwsh tools/check.ps1. Không đo FPS, không chạy bot.
6. Hai lệnh đạt → commit nhỏ "T-216: ..." → git push origin lane-b/T-216-bathroom-fixes (không push main, không mở PR) → báo nhả lượt Godot.
   Sắp hết hạn mức thì dừng ở bước đang làm, commit "T-216 WIP: ...", push, ghi Handoff rõ còn dở gì.
7. Cập nhật Handoff trong card (không sửa STATUS, DECISIONS hay mục Review) và báo lại:
   vị trí mới của giẻ và bảng (toạ độ), góc nhấp nháy + nguyên nhân thật, ảnh trước/sau, dòng RESULT test/check, commit hash, phần chưa kiểm, có bị chặn gì không.
```

## 7. Prompt T-219: mẫu thử nhân vật quản lý, mẫu C + phần dùng chung (D-116, 15/10)

Dán nguyên khối, dùng được cho phiên cũ lẫn phiên mới. Lane B làm cả phần nối gameplay của card (scene thân, cảnh so sánh, test), không cần lane A.

```text
Bạn là agent Lane B (Môi trường và 3D), game "Ký túc xá sau 12 giờ" (Godot 4.7.2). Trả lời/tài liệu tiếng Việt, code tiếng Anh.
Chỉ làm trong D:\GAME_WORK\lane-b. Không sửa D:\GAME_DEMO hay workspace lane khác (được ĐỌC thư mục staging Tripo ở bước 6).
Integrator là Claude (Opus 5.5) ở máy. Câu hỏi core/contract và việc xin lượt chạy Godot đều gửi về integrator qua chủ dự án.

VIỆC: T-219 — G4 mẫu thử quản lý ký túc xá. Làm MẪU C (thân/mặt/khung xương MPFB, CC0) và phần DÙNG CHUNG cho cả hai mẫu:
bộ động tác CC0, scene thân theo hợp đồng body_scene của manager.gd, cảnh so sánh trong phòng 407, ảnh, test.
Mẫu A (Tripo) chủ dự án đang tạo; khi có file thì chuẩn hóa và đặt vào cùng cảnh.
Bản chơi KHÔNG đổi: manager.tscn và các chương giữ thân cũ tới khi chủ dự án chọn.

1. git status. Workspace còn thay đổi T-216 chưa commit trên nhánh lane-b/T-216-bathroom-fixes: phần này ĐÃ GHÉP vào main (D-109).
   Không xóa: git stash push -u -m "T-216 leftovers, merged in D-109" (giữ stash, không drop).
   Rồi git fetch origin, tạo nhánh lane-b/T-219-manager-pilot từ origin/main mới nhất (có D-116).
2. Đọc: AGENTS.md, docs/STATUS.md, docs/tasks/T-219-manager-character-pilot.md (toàn bộ), D-084 và D-113…D-116 trong docs/DECISIONS.md,
   docs/handoff/TRIPO_QUAN_LY.md (ngoại hình mục 1, đồ đi kèm mục 4), tools/reports/D-114-room407-performance.md (cách đo FPS),
   game/scripts/entity/manager.gd + game/scenes/entity/manager.tscn (hợp đồng body_scene, AnimationPlayer, BladeTip, tên clip),
   card T-208 (bảng Manager trong hợp đồng nhân vật), game/scenes/levels/room407/room407.gd (ánh sáng D-113).
3. Công cụ: Blender D:\Tools\Blender\5.2.2\blender.exe. Tạo thư mục D:\Tools\Blender\5.2.2\portable để Blender chạy portable,
   cài MPFB vào đó; bộ tài sản MakeHuman (CC0) để trên D:. KHÔNG ghi gì vào ổ C (kiểm lại %APPDATA%\Blender Foundation không có gì mới).
   Ghi tên, phiên bản, URL, giấy phép của MPFB, tài sản MakeHuman, thư viện động tác vào CREDITS.md.
4. Mẫu C theo card mục 2 và ngoại hình TRIPO_QUAN_LY.md mục 1: nam ~45 tuổi nét Việt, gầy, hơi gù, cao ~1,70 m;
   sơ mi xanh nhạt sơ vin, quần tây xám, thắt lưng, giày da;
   mặt kinh dị bằng texture riêng (da xám bụi bê tông, vệt máu khô từ chân tóc, mắt đục con ngươi nhỏ).
   Lưu .blend + script dựng trong art_source/graphics_upgrade/manager/ (≤ 10 MiB/file, nhị phân qua LFS);
   GLB game ở game/assets/models/characters/manager/.
5. Động tác: thư viện CC0 (ví dụ Quaternius Universal Animation Library), retarget qua SkeletonProfileHumanoid
   để MỘT bộ chạy được trên cả A và C. Đủ 6 clip đúng tên manager.gd gọi: stand, walk, ask (cúi đầu hỏi),
   slash (chém xuống từ trên vai, lặp được; đạo diễn chém 6 lần cách 0,45 s), lunge, kill (kết liễu).
   Không dùng Mixamo hay tài sản không phải CC0/CC-BY.
6. Đồ đi kèm và mẫu A: chủ dự án tải file Tripo về D:\GAME_DEMO\build\graphics\staging\manager\
   (manager_knife.glb, manager_keys.glb, manager_id_card.glb, manager_body_rigged.glb, manager_body.glb; lượt sau có _r2, _tex1...).
   Chỉ ĐỌC/COPY từ đó, không sửa. Chưa có file thì dựng dao phay tạm bằng Blender (ghi rõ "tạm") và làm tiếp;
   mẫu A để chỗ trống trong cảnh so sánh, ghi vào Handoff.
   Có file thì chuẩn hóa mẫu A theo card mục 3 (−Z, ~1,70 m, gốc ở chân, texture ≤ 2048², kiểm map được sang SkeletonProfileHumanoid).
   Không tự tạo trên Tripo, không tiêu credit; cần lượt Tripo mới thì ghi prompt đề xuất vào Handoff.
7. Scene thân game/scenes/entity/manager_body_c.tscn (và manager_body_a.tscn khi có mẫu A) đúng card mục 5:
   root Node3D, AnimationPlayer đủ 6 clip, dao gắn xương bàn tay phải bằng BoneAttachment3D, BladeTip ở mũi dao.
   Tay mở cửa (LeftArm / set_reach_weight) chưa làm, ghi vào phần chưa làm.
   Cảnh so sánh game/scenes/levels/graphics_pilot/manager_compare.tscn theo card mục 6 (phòng 407 đủ đồ, ánh sáng D-113,
   phím đổi clip, đổi đèn pin/đèn trần nhấp nháy, chế độ chụp); ảnh 1080p vào art_source/graphics_upgrade/manager/previews/.
8. Chỉ sửa file trong "Được phép sửa" của card. Không sửa manager.gd, manager.tscn, AI, thời gian chém, luật, lời thoại, các chương.
   Không xóa/đổi tên file có sẵn. Ngân sách: ≤ 25.000 tam giác (cả dao, chìa khóa, thẻ), ≤ 4 vật liệu,
   texture ≤ 2048² (mặt có thể 2048² riêng).
9. Test trong game/tests/ theo card mục 8 (6 clip, BladeTip theo tay khi slash, ngân sách,
   manager.gd chạy được với scene thân: đi, hỏi, chém, giết, không lỗi).
10. Chạy offline/headless trước (probe để trong thư mục tạm rồi xóa; không dùng godot -s).
   Sau khi đổi GLB chạy godot --headless --path game --import.
   Khi cần chụp ảnh (Forward+), đo FPS (card mục 7, 1080p như D-114, đã được phép trong việc này) hoặc full test/check:
   NHẮN integrator xin lượt rồi mới chạy pwsh tools/test.ps1, sau đó pwsh tools/check.ps1, rồi git checkout -- game/default_bus_layout.tres.
   Không chạy bot.
11. Hai lệnh đạt → commit nhỏ "T-219: ..." → git push origin lane-b/T-219-manager-pilot (không push main, không mở PR) → báo nhả lượt Godot.
   Có thể bàn giao 2 đợt: đợt 1 mẫu C + động tác + cảnh so sánh; đợt 2 thêm mẫu A khi chủ dự án có file Tripo.
   Sắp hết hạn mức thì dừng ở bước đang làm, commit "T-219 WIP: ...", push, ghi Handoff rõ còn dở gì.
12. Cập nhật Handoff trong card (không sửa STATUS, DECISIONS hay mục Review) và báo lại theo mục "Bàn giao" của card:
   việc đã làm, danh sách ảnh so sánh, FPS từng mẫu, bảng nguồn + giấy phép từng tài sản, số tam giác/vật liệu/texture,
   dòng RESULT test/check nguyên văn, commit hash, phần chưa làm, nhận xét A và C (mặt, tay, khớp vai, quần áo khi chém),
   có bị chặn gì không.
```
