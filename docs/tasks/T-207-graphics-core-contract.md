# T-207 — Hợp đồng và tích hợp core cho đồ họa gần chân thực
- Lane: core, **Claude Code web làm phần core theo D-077** | Trạng thái: **G0 đã review/ghép (D-079); G1 tiếp tục, toàn gói chưa done** | Agent: Claude web
- Nhánh: `core/T-207-graphics-core-contract`, tạo từ `origin/main` có D-077.
- Phụ thuộc: D-076, D-077; đọc `docs/design/GRAPHICS_UPGRADE_PLAN.md`. G0 độc lập; wiring sau G1 và đầu ra T-208…T-212 tương ứng.
- Hạn đề xuất: gửi hợp đồng sơ bộ trong phiên đầu 10–11/10; phần tích hợp theo từng đợt, không hứa hoàn thành cả game trong hai ngày.

## Bối cảnh
Tầng 4/phòng 407 dùng chung bốn chương. Director chương 2–4 kế thừa nhau; core vẫn tự tạo hình nút báo cháy trong `_place_fire_alarm`, giữ `FireAlarm1F`, `FIRE_ALARM_AT`, `FIRE_BELL_AT`, `FIRE_BELL_SECONDS`, `FIRE_BELL_STREAM`. D-075 kéo bốn xác, chuông chỉ chương 3. Nhân vật gọi `set_body`, pose, marker; hình mới phải khớp luật cũ.

## Việc theo từng phần bàn giao
1. **G0 — khảo sát và hợp đồng:** tạo `docs/design/graphics/ASSET_BINDINGS.md`: scene/chương, root/NodePath thật, collider, marker, API/signal, clip/timing và bên sở hữu. Bắt đầu với cửa/giường 407, ba xác, quản lý, đồng đội, bình cứu hỏa, chuông tầng 1. Ghi transform thật từ scene/mã nguồn; không bịa số đo. Kiểm các nơi core đang dựng visual hoặc hardcode đường dẫn.
2. Tạo `docs/design/graphics/INTEGRATION_CONTRACT.md`: cách giữ root, chuẩn hóa visual, gọi adapter, nhận marker, fallback khi model thiếu, trách nhiệm A/B/C/D/F (F tiếp nhận âm thanh từ E theo D-078). Tiếp nhận đề xuất schema/asset ID/settings của các lane qua Handoff; chỉ ghi thay đổi tối thiểu cần cho pilot. Ghi riêng đề xuất key/default/ai ghi/ai đọc để integrator cập nhật `docs/SETTINGS.md` ở G1.
3. **Sau G1:** chuẩn bị điểm nối core nhỏ, có test hành vi thật, model cũ vẫn hoạt động. Không thêm hệ thống registry/autoload tổng quát nếu không có nhu cầu cụ thể. Chưa đổi main scene, mặc định hình ảnh hay luật chơi.
4. **G2/G3:** khi asset B/âm F và adapter A đã có, nối từng phần vào core. Với chuông, chỉ thay phần nhìn/nguồn âm; giữ tọa độ mồi, bán kính tiếng động, số xác, thời lượng và điều kiện chỉ chương 3. Không gọi cùng sự kiện từ cả animation mới lẫn director gây kích hoạt hai lần.
5. Ghi bảng đầu ra đã sẵn sàng/chờ dependency, cách quay lại bản trước, lệnh kiểm trên Windows cho integrator. Phần đồ họa thực phải được máy có GPU kiểm sau.

## Được phép sửa — ngoại lệ cho web D-077
Chỉ `docs/design/graphics/INTEGRATION_CONTRACT.md`, `docs/design/graphics/ASSET_BINDINGS.md`, `game/scripts/core/` và `game/scenes/main/` **ở các điểm nối visual của card**, `game/tests/core/`, Handoff/checklist card này. Đổi `game/project.godot`, `docs/SETTINGS.md`, `game/data/` hay file lane phải ghi yêu cầu cho integrator, chưa tự sửa. Không sửa STATUS/DECISIONS, lời thoại, save/checkpoint, AI hay file B/A/D/F/C.

## Test và bằng chứng
- Linux cloud: chạy toàn bộ test baseline trước sửa, sau sửa và check; ghi lỗi nền nếu có, không tự quy lỗi là do Linux khi chưa có bằng chứng. Không được thêm lỗi mới. Nếu launcher không chạy được, dùng Godot 4.7.2 headless trực tiếp và ghi lệnh/giới hạn check.
- Khi có wiring: test trên scene chương thật, cả có/thiếu visual mới; flags, tín hiệu, kết quả sống/chết và timing liên quan phải giữ đúng. Gỡ wiring cần thiết hoặc bỏ marker bắt buộc phải khiến test hợp đồng thất bại; không chấp nhận test chỉ gọi mock.
- Chuông vẫn chỉ chương 3, không tự phát thêm ở chương 4 kế thừa; một lần dùng chỉ phát một sự kiện mồi. Kiểm các hồi quy D-069…D-075 tương ứng.
- Cloud không có GPU: không báo đã chụp/đạt FPS/chơi tay. Integrator chạy lại đầy đủ trên Windows trước merge.

## Checklist hoàn thành
- [x] G0: bảng binding có căn cứ, contract và yêu cầu settings gửi review (chờ integrator xem)
- [ ] G1: contract đã được integrator ghép; dependency xác định rõ
- [ ] Wiring từng phần giữ hành vi cũ và có test phù hợp
- [ ] Test baseline/sau sửa/check được ghi trung thực
- [ ] Handoff nêu phần còn chờ, không ghi done cả gói khi mới xong G0

## Handoff (agent điền)
**Claude Code web làm phần core, D-077.** Nhánh `core/T-207-graphics-core-contract` (tạo từ `origin/main` tại `e3ed54a`, có D-077 và D-078). **Mới xong G0**; G1, wiring và các mục còn lại của card **chưa làm, card chưa done**.

**Đã làm (G0)**
- `docs/design/graphics/ASSET_BINDINGS.md`: bảng ràng buộc có căn cứ. Số đo lấy bằng cách dựng thật bốn cảnh chương 1–4 và các model bằng Godot 4.7.2 headless (tọa độ thế giới, collider/layer/mask, marker, group, clip và thời lượng, bounds và số tam giác). Gồm cửa 407 (kể cả proxy cửa chương 3–4), 4 giường, 3 xác (API, NodePath bắt buộc, gắn miệng), quản lý (`BladeTip`, clip, thời gian), đồng đội/zombie/guard, bình cứu hỏa, nút báo cháy, chuông; kiểm kê chỗ core tự dựng hình hoặc hardcode đường dẫn; các sai khác phát hiện được.
- `docs/design/graphics/INTEGRATION_CONTRACT.md`: nguyên tắc giữ root và một nguồn sự kiện, chuẩn hóa visual, điểm nối hiện có, marker/API cần có và fallback, kế hoạch wiring W1–W4 sau G1, phân vai A/B/C/D và **F (tiếp nhận âm thanh từ E, D-078)**, đề xuất settings cho integrator, đề xuất trường asset cho C/B, tình trạng đầu ra, lệnh kiểm Windows, các điểm cần integrator quyết.
- `game/tests/core/test_graphics_bindings.gd` (8 test, trên scene chương thật): khóa các ràng buộc ở bảng (cửa 407 ở cả 4 chương, giường, API và NodePath của ba xác, `GagN` bám đầu xác, `BladeTip` + 6 clip của manager, `set_body` hai lần chỉ còn một model, vùng dùng bình/nút/chuông ở chương 3, chương 4 không có nút, proxy cửa chương 3–4). Đã thử phá: đổi offset `gag_anchor.gd` và sửa điều kiện chương của `_place_fire_alarm` thì test FAIL đúng chỗ, rồi hoàn lại (không để lại thay đổi nào ngoài test).
- Không sửa mã game, `project.godot`, `docs/SETTINGS.md`, `game/data/`, STATUS/DECISIONS, file của A/B/C/D/F.

**Điều phát hiện quan trọng cho các lane (chi tiết ở ASSET_BINDINGS §8)**
1. Chương 3–4: collider lá cửa 407 bị `door407_proxy.gd` (B) đưa về layer 0 và thay bằng `Blocker`; đo: lá cửa layer 1 ở chương 1–2, layer 0 ở chương 3–4.
2. Chuông: `lock_alarm.ogg` dài 1.50 s, `loop = false`, core phát lại trong 20 s bằng `await finished`. Stream lặp (`loop = true`) làm chuông không bao giờ dừng nếu `_ring_bell` không đổi (W2). Test khóa `not stream.loop` để F không vô tình đổi trước W2.
3. Hình nút báo cháy là hộp đỏ do core tự dựng bằng mã (chỉ chương 3); chuông chỉ là nguồn âm tại `(42.0, -7.7, 0.2)`, chưa có visual hay marker treo.
4. `corpse_body.gd`, `gag_anchor.gd`, `UnseenPoser` đọc thẳng NodePath `Rig/Hips/Chest/Head...`; model xác mới không thể thay scene nếu không có adapter giữ API.
5. `head_position()` của model campus thấp hơn fallback 7 cm (1.48 m so với 1.55 m).
6. Nhóm `ch2_corpse` có 6 phần tử, 3 trong đó là xác phòng 310 CCTV.

**Hai lượt test** (Godot 4.7.2 Linux chạy trực tiếp, userdata cô lập qua `XDG_DATA_HOME` + `QA_EXPECTED_USER_ROOT`; `tools/test.ps1` không dùng vì không chạy được trên Linux, đã ghi ở các task trước):
- **Trước khi sửa** (`origin/main` `e3ed54a`): `RESULT: 722 passed, 0 failed`.
- **Sau khi sửa**: `RESULT: 729 passed, 1 failed`. 8 test mới đều PASS (722 + 8 = 730). FAIL còn lại: `test_wide_corridors.gd::test_floor4_standalone_navigation_reaches_both_ends_and_room407` ("manager can navigate from 407 to (1.0, 0.0, 3.0)" và "(43.0, 0.0, 3.0)"). Đây không phải lỗi do thay đổi này: diff chỉ gồm tài liệu và một file test mới; chạy riêng `--filter=test_wide_corridors` ba lần trên cùng mã cho **1 FAIL, 2 PASS**, tức là không ổn định. Nguyên nhân chưa chẩn đoán (nghi điều hướng navmesh), chưa dám quy cho Linux; cùng họ với `test_room407_fixes.gd::test_navigation_reaches_balcony_and_bathroom_without_crossing_solids`, FAIL một lần ở baseline T-204 rồi PASS ở lần sau. Mời integrator chạy lại trên Windows.
- `tools/check.ps1` (pwsh 7 Linux, `GODOT` đặt tay): `RESULT: check 0 error(s)` (có parse file test mới).

**Chưa kiểm / chưa làm**
- G1 (integrator ghép contract) và mọi wiring W1–W4: chưa làm; chờ đầu ra T-208…T-212 (hiện chưa có Handoff nào trên `origin`).
- Hình ảnh, FPS, âm thanh nghe được, đi bộ ngắm tia với model mới: chưa kiểm (cloud không GPU, không có model mới). Không chạy bot chương 3–4, không chụp ảnh, không export.
- Triangle/material/texture của phòng 407 và hành lang chưa thống kê (thuộc B/C).
- Không có khóa/ngân sách Meshy, không gọi API trả phí, không cài plugin/MCP.

**Yêu cầu thay đổi ngoài phạm vi (cho integrator)**
- Quyết định các điểm ở INTEGRATION_CONTRACT §12 và cập nhật `docs/SETTINGS.md` nếu chấp nhận `[video] visual_style` / `graphics_preset` / `render_scale` (§8) trước khi D/B dùng key mới.
- Chuyển cho B: tên marker mới `FireBellMount`, hình nút `FireAlarm1F` trong `campus.tscn`, giữ tên node ở ASSET_BINDINGS §7.3, tương thích với `door407_proxy.gd`.
- Chuyển cho A: giữ `set_body` hai lần chỉ một model, `Head`/`BladeTip`/`LeftArm`, quy tắc "animation không phát sự kiện" (contract §1.2).
- Chuyển cho F: stream chuông không lặp (hoặc chờ W2), đường dẫn và độ dài; nguồn âm bám `BladeTip`/`Head`.
- Chuyển cho C: trường kiểm được từ góc nhìn core (contract §9); không cần core đọc manifest.

**Cách quay lại:** các thay đổi chỉ là tài liệu và một file test; `git revert` các commit `T-207:` hoặc bỏ file `game/tests/core/test_graphics_bindings.gd*` là đủ.

## Review (integrator)

### 11/10/2026 — Astra, D-079

- Nhận **G0** từ lane web, commit `4fc4999`; ghép cùng năm nhánh còn lại. **Chưa đánh dấu toàn bộ T-207 done.**
- Nhận hai tài liệu G0 và 8 test bindings cảnh thật. Full Linux của lane có một lỗi nav chập chờn: không xóa lịch sử lỗi hoặc coi đã sửa. Tổng hợp Handoff A/B/C/D/F vào G1, ưu tiên đạo cụ tĩnh; bổ sung consumer còn thiếu, Gag bám Head, CCTV 310; chưa wiring W1–W4.
- Phạm vi diff đạt; không nới test, không đổi gameplay/default. Không sửa code lane trong lượt review này.
- Full Windows test/check bản ghép và kiểm `--t202-integration` là điều kiện trước commit. Kết quả thực/thời điểm/log ở message commit `D-079`; không dùng số test lane riêng thay kết quả tích hợp.
- Đọc [báo cáo chung và yêu cầu G1](../handoff/REVIEW_G0_2026-10-11.md), làm phần Review của lane trên nhánh hiện có sau fetch/rebase; không tự dùng contract G0 như API production đã chốt. Chưa chạy Meshy trả phí hoặc FPS/bot.
