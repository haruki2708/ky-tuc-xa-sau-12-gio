# T-250 — Đồ hoạ thật đợt 1: bàn trực tầng 4, cầu thang thoát hiểm và cửa, cầu thang chính nhà B
- Lane: B | Trạng thái: todo | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max), chủ dự án tự dán prompt (`lane-b.md` mục 1h).
- Nhánh: `lane-b/T-250-realistic-graphics-wave1` từ `origin/main` mới nhất.
- Quyết định giao: **D-166** (12/11/2026): chủ dự án duyệt kế hoạch [T-248](T-248-realistic-graphics-survey.md) với 10 đợt theo đường người chơi đi; mọi thứ dựng **bằng Blender trước, theo đúng chất lượng đồ phòng 407**; chỗ nào chủ dự án không ưng thì đổi sang Tripo sau.

## 1. Chủ dự án đã chốt (D-166)
- **Phong cách nhà B:** cùng chất liệu với phòng 407 và hành lang tầng 4 (G5), cũ vừa phải; không thành phế tích, không sạch mới.
- **Dựng bằng Blender, không dùng Tripo** ở đợt này (kể cả điện thoại bàn, loa treo mà PLAN đề xuất Tripo): chân thực như đồ phòng 407; vật liệu CC0 như phòng 407 và hành lang. Chủ dự án xem ảnh, thứ nào không ưng thì đổi sang Tripo ở lượt sau.
- **Ánh sáng giữ như hiện nay**, chỉ chỉnh vật liệu cho dễ nhìn.
- Động tác của Trần Trung ở chỗ này (T-247 dòng 5 chìa trong ngăn kéo, 6 cửa thoát hiểm có ổ khoá, 9 chân trên cầu thang) **chưa làm** ở card này: chỉ dựng hình sao cho làm được sau (ngăn kéo tách riêng trượt được, ổ khoá và tay nắm là node riêng trên cánh, mặt bậc nhìn thấy khớp mặt bậc va chạm).

## 2. Phạm vi (PLAN mục 2–4, mã khu A01, A06, A07)
| Mã | Khu | Scene và node | Làm |
|---|---|---|---|
| A01 | Bàn trực tầng 4, chìa, đồng hồ | `game/scenes/levels/floor4/duty_desk.tscn` → `DutyDesk`; `campus/building_b.tscn` → `DeskClock`, `KeyStem`/`KeyTooth` | Bàn có thân và **ngăn kéo riêng có ray trượt**, chìa riêng, đồng hồ, bảng, ghế, đèn (dùng lại hoặc chỉnh từ bộ đồ phòng 407), điện thoại bàn, loa treo. Giữ vị trí chìa (`FireKey` ở (39,8; 0,66; 0,42)), mặt bàn, đồng hồ, nguồn tiếng. |
| A07 | Cầu thang thoát hiểm, cửa, đoạn sập | `campus/building_b.tscn` → `FireStairs`, `FireDoor`, `FireRubbleDetail`, `StairCrack` | Bậc, chiếu nghỉ, tay vịn, tường; **cánh cửa thép có bản lề, ổ khoá và tay nắm là node riêng**; mảnh sập không lấn tuyến. Giữ pivot cửa, blocker, vùng `Collapse2F` (46,5; −6,6; −1). |
| A06 | Cầu thang chính | `campus/building_b.tscn` → `MainStairs`, `Handrail_-4*`, `UpperRubbleDetail` | Bậc, chiếu nghỉ, trụ, tay vịn, phần chặn tầng trên, mảnh vỡ theo số đo. **Mặt bậc nhìn thấy khớp collider**, giữ độ cao tầng 3,3 m (tầng 1/2/3/4 ở Y = −9,9 / −6,6 / −3,3 / 0) và vùng chặn. |

Hợp đồng gameplay (PLAN mục 4): không đổi tên, transform gốc, marker, signal, đường dẫn tài nguyên mà director và test đang tìm. Thay hình dưới node sở hữu; **giữ nguyên collider, navmesh, layer, `Ch3Use`** (`Use_FireKey`, `Use_FireDoor`). Không đổi luật chơi.

## 3. Cách làm (theo vòng của PLAN mục 5)
1. **Mẫu trước:** dựng A01 (bàn trực) trước, chụp ảnh trước/sau cùng góc ở chương 3 thật (và chương 1, vì bàn trực có ở mọi chương), tự xem lại. Ghi số tam giác, vật liệu.
2. Rồi A07 và A06, cũng ảnh trước/sau: đứng dưới chân cầu thang, giữa cầu thang, chiếu nghỉ, trước cửa thoát hiểm (đóng, mở), đoạn sập.
3. Script Blender trong `art_source/graphics_upgrade/realistic_map/wave1/`, glb trong `game/assets/models/graphics_pilot/realistic_map/wave1/`, CREDITS ghi nguồn vật liệu. Mẫu: cách dựng hành lang tầng 4 (`art_source/graphics_upgrade/floor4_corridor/`) và đồ phòng 407 (`room407_furnished/`, `room407_shell/`).
4. Ảnh `art_source/graphics_upgrade/realistic_map/previews/wave1/` (1080p, ánh sáng của chương); một ảnh ghép trước/sau cho chủ dự án.
5. **Không đo FPS, không chạy bot** (chủ dự án chưa cho); ghi số tam giác, vật liệu, đèn mới (nếu có) để ước lượng.

## 4. Kiểm
- Test mới trong `game/tests/levels/`: các node mà director/test tìm vẫn còn đúng chỗ; collider cầu thang không đổi (so với main); cửa thoát hiểm vẫn quay đúng, ổ khoá và tay nắm đi theo cánh; ngăn kéo là node riêng trượt được; mặt bậc nhìn thấy cách mặt bậc va chạm ≤ 2 cm.
- Test cũ chương 1–4 đạt (`test_chapter3`, `test_ch3_*`, `test_ch2_4_hand_targets`, `test_t249_chapter3_bar`, `test_floor4*`, `test_room407*`…). Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit.

## 5. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/wave1/`, `.../previews/wave1/`, `game/assets/models/graphics_pilot/realistic_map/`, `game/assets/textures/` (vật liệu CC0 mới), `game/scenes/levels/floor4/duty_desk.tscn`, `game/scenes/levels/campus/building_b.tscn` (phần hình của A01, A06, A07), script dựng cảnh trong `game/scenes/levels/` nếu cần, test mới trong `game/tests/levels/`, card này.
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 6. Không được
- Đổi collider, navmesh, luật, thời gian, director (`game/scripts/core/`), `Ch3Use`; làm động tác cho Trần Trung (T-247 dòng 5, 6, 9).
- Dùng Tripo, tiêu credit Tripo; chạy bot, đo FPS.
- Sửa khu ngoài A01, A06, A07 (hành lang tầng 1–3, sảnh, phòng 203… là đợt 2).
- Commit log, video, `anh_chup_sua_loi/`. Sửa STATUS, DECISIONS.

## Checklist
- [ ] A01 bàn trực (ngăn kéo riêng), ảnh trước/sau
- [ ] A07 cầu thang thoát hiểm, cửa (ổ khoá, tay nắm riêng), đoạn sập, ảnh
- [ ] A06 cầu thang chính, ảnh
- [ ] Test mới, test cũ đạt, full test, check
- [ ] CREDITS, ảnh ghép trước/sau, Handoff

## Handoff
(lane B điền)
