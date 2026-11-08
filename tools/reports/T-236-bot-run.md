# T-236 — Kết quả chạy bot chương 2–3

- Ngày bắt đầu: 08/11/2026; nền `894d871a596de9223e9431ed32d7e5952fce6b26`; nhánh `lane-c/T-236-run-bots-ch2-ch3`.
- Ủy quyền: D-145. Chạy từng ca, TimeScale=1, RequireComplete, Capture; mỗi ca một tiến trình pwsh riêng và một khóa Godot CreateNew, trả khóa trong finally.
- Lệnh ca đầu: `pwsh tools/playthrough.ps1 -Chapter 2 -Scenario ch2_good -RequireComplete -Capture -TimeScale 1`.
- Log tổng, metadata, bản sao report/ảnh ở `build/t236/<lượt>/`; launcher còn giữ bản gốc trong `build/playthrough/`. Không commit các artifact này.

## Bảng ca

| Chương | Ca | Kết quả | Thời gian bot thật | Bước dừng / nhận xét |
|---|---|---|---|---|
| 2 | ch2_good, lượt 01 | FAIL | 235,88 giây | Wipe đầu vòng 4 không được xác nhận; chưa tới lựa chọn tắm đầu tiên |
| 2 | ch2_good, lượt 02 | FAIL | 239,32 giây | Đã tới gần màn nhưng hiệu ứng đẩy cửa xóa góc camera của bot |
| 2 | ch2_good, lượt 03 | PASS | 590,31 giây (9:50) | Qua kết chương và các mốc good sau hai sửa bot |
| 3 | ch3_good, lượt 04 | FAIL | 71,72 giây | Dừng đường cầu thang; thông báo cuối che mất lỗi đầu |
| 3 | ch3_good, lượt 05 | FAIL | 71,55 giây | Xác nhận DEATH_CH3_GRABBED tại tầng 3 khi waypoint yêu cầu tầng 4 |
| 3 | ch3_good, lượt 06 | FAIL | 75,64 giây | Qua cửa/cầu thang; bị bắt khi rời chỗ nấp 207 sau 30 giây chờ |
| 3 | ch3_good, lượt 07 | FAIL | 97,15 giây | Đi cúi qua được cửa 207; va đồng đội trên đường tây, bị nhóm xác phía sau bắt |
| 3 | ch3_good, lượt 08 | FAIL | 438,34 giây | Qua nhà B; đứng ngoài mép vườn nên timeout chuyển khu |
| 3 | ch3_good, lượt 09 | FAIL | 154,13 giây | Đã chuyển garden; tuyến ngắn nhất dẫn vào cụm xác trước khi nhận thanh sắt |
| 3 | ch3_good, lượt 10 | FAIL | 170,91 giây | Nav vòng mép tây vẫn đi qua cụm xác z=28 |
| 3 | ch3_good, lượt 11 | FAIL | 211,20 giây | Tới Ngư, nhận thanh sắt 8 lượt; bot không đánh được khi rời vườn |
| 3 | ch3_good, lượt 12 | FAIL | 314,44 giây | Đánh được, ra vườn; chết giữa hai điểm spawn cửa tây sân vận động |
| 3 | ch3_good, lượt 13 | FAIL | 469,13 giây | Vào sân từ phía nam; bị tóm trong vòng sống sót (đi tới P22), thanh sắt còn 7 lượt, thể lực 0,35 |
| 2 | ch2_chain_timeout | Chưa chạy | — | Để việc sau (xem Kết luận) |
| 2 | ch2_chain_wrong | Chưa chạy | — | Để việc sau (xem Kết luận) |
| 2 | ch2_scald | Chưa chạy | — | Để việc sau (xem Kết luận) |
| 2 | ch2_leave_shower | Chưa chạy | — | Để việc sau (xem Kết luận) |
| 2 | ch2_wrong_prediction | Chưa chạy | — | Để việc sau (xem Kết luận) |
| 3 | ch3_grabbed | Chưa chạy | — | Để việc sau (xem Kết luận) |
| 3 | ch3_guard | Chưa chạy | — | Để việc sau (xem Kết luận) |

## Phân tích lượt 01

- Ca chạy 15:03:52–15:08:06 gồm import/launcher; bot báo 235,88 giây, launcher đo 244,55 giây, wrapper 253,84 giây. Exit 1; `RESULT: playthrough 0 passed, 1 failed`.
- Log: `build/t236/01-ch2-good/launcher.stdout.log`; artifacts gốc `build/playthrough/1b5e176e9fe24f1eb6dace9b4ef0869d/ch2_good/`. Bản sao trong `build/t236/01-ch2-good/1b5e176e9fe24f1eb6dace9b4ef0869d/`.
- Đã qua trap, nhặt rag/towel/shirt, gag_1/2/4, loop và choice nhắn bạn, ba lần đẩy cửa. Lỗi: `physical action not acknowledged: Floor4/Room407/Anchors/ShowerScreen/Wipe`.
- Khung hình cửa sổ game `build/t236/01-ch2-good/window-1506.png` cho thấy vòng nối từ ở phòng ngủ; đây là ảnh trước lỗi, không phải ảnh đúng thời điểm FAIL. Capture có bật nhưng bot ch2 chưa gọi mốc chụp ở action lỗi nên launcher chưa sinh ảnh lỗi.
- Nguyên nhân bot: khi GameState vừa chuyển r4, `last_wipe_slot=-1`, số nhiệt độ quan sát là 0. `_tick_actions()` mở cửa rồi lau ngay trước khi có `shower_pending`; bước định vị gần nhất vẫn là bedroom `(33.5, 0.05, -1.5)`, suy ra từ profile và thứ tự action, chưa phải vị trí đo tại lỗi. Tia ngắm Wipe đúng hướng nhưng ngoài tầm tương tác. Không có bằng chứng lỗi gameplay cần sửa.
- Sửa trong C: đi tới điểm `leave_shower` đã kiểm capsule/ray trước lần lau đầu; nếu bước định vị thất bại thì dừng, không đánh dấu chuẩn bị xong. Ghi action/segment/vị trí thực vào report và chụp mốc khi action lỗi. Test lịch thao tác dùng stub không đưa bot vào tree, không chạy chương.

## Phân tích lượt 02 và sửa ngắm

- Lượt 02 15:10:53–15:15:10; bot 239,32 giây, launcher 247,91 giây, wrapper 257,54 giây. Exit 1, vẫn FAIL Wipe; `leave_shower` đã PASS. Dừng phân tích, không chạy ca khác.
- Report đo vị trí lỗi `(36.18, 0.00039, -5.2)`, segment r4. Ảnh `build/t236/02-ch2-good/c428ac9c5b924dba8cd3e79cd6dd1cc5/captures/01_ch2_wipe_FAIL.png` cho thấy màn ở bên trái góc nhìn, bot vẫn trong phần thông báo mở vòng 4. Log và report cùng thư mục artifact này.
- Nguyên nhân bổ sung thuộc bot: `camera.look_at()` đặt trực tiếp góc camera ngay sau ba lần đẩy cửa. `_update_door_bash()` của player ghi góc camera cho hiệu ứng 0,22 giây rồi trả về zero, xóa hướng ngắm đó. T-232 chỉ kiểm ray khi player physics tắt nên không bắt được tình huống này.
- Sửa `ch2_actions.gd`: đặt yaw của thân và pitch của Head theo vị trí node thật, giữ góc camera cho hiệu ứng gameplay. Không sửa player/hiệu ứng/thời gian game.
- Mở rộng fixture hiện có: bật physics player, gọi hiệu ứng đẩy cửa thật rồi `physical("wipe")`; yêu cầu tín hiệu `wiped` thật và nhả phím sau khi input queue xử lý. `pwsh tools/test.ps1 -Filter test_bot_positions`: `RESULT: 1 passed, 0 failed` (exit 0). Kiểm đầu tiên của fixture đạt lau nhưng assertion nhả phím đọc trước input flush; đã thêm chờ hai physics frame rồi kiểm, không đổi logic game. Test lịch thao tác riêng: `RESULT: 2 passed, 0 failed` (exit 0).
- Lượt 03 chạy lại đúng ch2_good trên hai sửa bot; bản vá lưu trong `build/t236/03-ch2-good/bot.patch`.

## Lượt 03 hoàn tất

- Ch2 good PASS, exit 0, `RESULT: playthrough 1 passed, 0 failed`. Bot 590,31 giây; wrapper gồm import/cleanup 606,40 giây, chạy 15:19:39–15:29:46. Log/report tại `build/t236/03-ch2-good/a26b5c477ef4405697d716e8d0783d81/`.
- Đã qua kiểm mốc good có sẵn: gag ba xác, trap thật, chuỗi lặp, nhắn bạn, đủ phút tắm, hai dự đoán đúng, mở khóa chương 3. Report `game_minutes=0` là số ghi nhận của observer hiện tại, không dùng làm thời lượng chơi; ETA đối chiếu bằng đồng hồ thật.
- Đã nhả khóa sau ca, khởi chạy ch3_good lượt 04 bằng pwsh riêng.

## Ch3 good lượt 04–05: chẩn đoán đường đi

- Lượt 04 chạy 15:30:19–15:31:48, wrapper 88,74 giây; bot 71,72 giây. Mở 407, lấy chìa và mở cửa thoát hiểm PASS; thao tác tới `(45.5, 0, 2)` bị hủy. Thông báo cuối bị kiểm unlock ghi đè nên chưa phân loại được nguyên nhân từ bản report cũ.
- Đã bổ sung chẩn đoán trong C: giữ lỗi đầu, ghi waypoint, vị trí thực, segment, failed_rules, điểm path đang theo và collider; chụp ảnh khi waypoint lỗi. Không đổi tuyến/luật. Test lọc `test_ch3_tools`: `RESULT: 6 passed, 0 failed`, exit 0, log `build/t236/ch3-tools-test.log`.
- Chạy lại cùng ca lượt 05, 15:33:07–15:34:34; bot 71,55 giây, launcher 80,14 giây, wrapper 87,54 giây; exit 1, `RESULT: playthrough 0 passed, 1 failed`. Log/report/ảnh: `build/t236/05-ch3-good/5fe545fbee8a4bbea6ebf3a8a88e5f60/`, ảnh `captures/01_ch3_waypoint_FAIL.png` hiện màn chết do xác sống.
- Report ghi `DEATH_CH3_GRABBED`, segment b, vị trí `(46.3735, -3.2992, 1.0494)`, collider `Campus/BuildingB/FireStairs/Landing3`, điểm nav tiếp theo `(47.8, -3.3, 0.5)` dù đích là chiếu nghỉ tầng 4. Đã dừng chạy ca khác để phân tích.
- Kiểm tra nav sau khi đồng bộ cho đường thẳng tầng 4 qua FireDoorLink từ `(42.22, 0, 1.94)` sang `(45.5, 0, 2)`; log `build/t236/ch3-navigation-diagnosis.log`, test profile 1/0. Hồi quy truy vấn ngay sau `perform("open_fire_door")` tái hiện đường cũ vòng xuống tầng 3 (`ch3-door-before.log` FAIL). Chờ cố định hai physics frame vẫn FAIL (`ch3-door-after.log`). Chờ revision tăng cũng chưa đủ vì một rebuild khác có thể hoàn tất trước (`ch3-door-revision.log` FAIL). Bản sửa dùng binding `sync_navigation_link` để quan sát đường ngắn thực sự qua FireDoorLink, giới hạn 10 giây. Không đổi cửa hay navmesh game. Test hồi quy sau sửa `ch3-door-link.log`: `RESULT: 1 passed, 0 failed`, exit 0; đường truy vấn ngay sau action đã qua cửa thẳng trên tầng 4. Lượt 06 chạy lại ch3_good lúc 15:43:22, log `build/t236/06-ch3-good/`.

## Ch3 good lượt 06: tiếng bước chân ở đoạn nấp

- 15:43:22–15:44:54; bot 75,64 giây, wrapper 91,77 giây, exit 1. Artifacts: `build/t236/06-ch3-good/722e8b45adef425d9a157b1098399a48/`; ảnh `captures/01_ch3_waypoint_FAIL.png` xác nhận chết do xác sống.
- Sửa đồng bộ nav đã giúp vượt waypoint `(45.5, 0, 2)`, tầng 3, kích hoạt bình chữa cháy tầng 2 và vào chỗ nấp 207. Sau 30 giây chờ, bước ra hành lang bị hủy với `DEATH_CH3_GRABBED`, vị trí `(35.7518, -6.6001, -0.3306)`, collider sàn tầng 2.
- Phân tích bot: `walk()` mặc định bật sprint nếu đủ thể lực. Player thật phát bước chân bán kính 12 m khi chạy, 5 m khi đi và 1,5 m khi cúi; zombie nhận noise đổi đích di chuyển. Các test core D-074/D-075 dùng `_put` với physics player tắt nên chưa kiểm tiếng bước chân thật. Giả thuyết: sprint lúc vào/ra nấp kéo xác tới cửa phòng; chưa có snapshot xác ở lượt 06 để xác định con bắt Trung.
- Đang kiểm profile dùng crouch từ bình chữa cháy tới chỗ nấp, khi ra cửa và đi về phía tây tới x=31,5 rồi mới chạy lại; giữ nguyên 30 giây chờ và mọi luật game. Bổ sung snapshot xác trong phạm vi 20 m ở mỗi waypoint (vị trí, đích, state, caught) để phân loại nếu tiếp tục lỗi.

## Ch3 good lượt 07: đường qua đồng đội

- 15:48:51–15:50:42; bot 97,15 giây, launcher 104,77 giây, wrapper 111,16 giây, exit 1. Log/report: `build/t236/07-ch3-good/3a5401d580de40a9ba1ff67d0ca527ed/`.
- Đi cúi giúp bot ra được cửa 207. Bốn xác bị dụ đứng tại x≈46,7–48,2, z≈2,3; không còn đuổi tới phòng nấp trong snapshot. Khi đi tới `(31.5, -6.6, 2)`, bot chết tại `(33.5204, -6.5997, 1.7505)`, collider cuối là `Chapter3Director/Companion`. Xác `@CharacterBody3D@828` tại `(34.1601, -6.5997, 1.7660)` có `caught=true`; hai xác phía sau cùng đích người chơi.
- Đây là bằng chứng tuyến bot thẳng giữa hành lang chạm đồng đội; chưa đủ kết luận người chơi không thể lách qua. Không đổi collision layer/NPC. Sửa profile thử đi phía trống z=3 qua x=35,75→31,5 trước khi quay về tuyến chính; giữ cúi và thời gian chờ. Test profile trước lượt 07 đạt 1/0 (`ch3-stealth-profile.log`).

## Ch3 good lượt 08: điểm vào vườn

- 15:53:21–16:00:55; bot 438,34 giây, launcher 446,64 giây, wrapper 453,73 giây, exit 1. Log/report `build/t236/08-ch3-good/405a561240734d56bfe0c4a8c7534f1e/`. Bot timeout chờ garden 300 giây, không chết; bản này chưa chụp ảnh timeout nên không có ảnh lỗi tương ứng.
- Tuyến z=3 đi qua đồng đội thành công, qua tầng 1/báo cháy/cửa sổ quản lý. Điểm cuối P13 `(22, -9.9, 8)` nằm ngay mép vườn (tâm z=28, nửa rộng 20). Vị trí report `(21.4064, -9.8999, 7.9878)`, segment b: bot nhận đạt trong 0,6 m nhưng vẫn ngoài vùng game.
- Test bắt P14_Wait_garden `(22, -9.9, 26)` lệch navmesh 2 m (`ch3-stage-entry.log` FAIL), nên profile dùng điểm `(20, -9.9, 26)` vốn có ở đầu tuyến garden trước khi chờ segment garden. Thêm test điểm chuyển khu nằm sâu hơn sai số 0,6 m trong Garden/Stadium/Gate và chụp/ghi vị trí khi chờ lỗi.
- Khi tiếp tục phiên, đã fetch, stash toàn bộ sửa đổi và file mới, rebase lên `9578ec2`, khôi phục stash và LFS; main mới chỉ đổi STATUS/DECISIONS D-147, không đổi game. Các lượt 01–08 vẫn ghi nền cũ đúng thực tế.

## Ch3 good lượt 09: tiếp cận Ngư

- Nền `9578ec2`, 16:04:20–16:07:13; bot 154,13 giây, wrapper 172,92 giây, exit 1. Log/report/ảnh: `build/t236/09-ch3-good/b31c8bd7e4264beeb35c46b14bedaee1/`, ảnh `captures/01_ch3_waypoint_FAIL.png`.
- Segment đã là garden, xác nhận sửa mép vùng. Bot bị tóm ở `(18.0358, -9.8998, 22.1755)`, collider Paving, khi nav dẫn từ P13 qua lối x=18 tới ghế Ngư. Hai xác Horde có `caught=true` tại `(17.9673, -9.8997, 21.2276)` và `(17.2943, -9.9010, 22.7759)`. Không kẹt collider, chưa tới chỗ nhận thanh sắt.
- Tuyến bot đi vào giữa các cụm idle x=12/x=28 ở z=18/28. Thử đổi tiếp cận vòng mép tây lên z=36 rồi tới Ngư từ phía bắc để tránh xuyên giữa cụm xác chưa có vũ khí. Không đổi số lượng/vị trí xác, độ khó, luật hoặc navmesh game. Thêm stamina/bar_hits vào report; tránh chụp lặp lỗi cũ khi các bước chờ sau đã thất bại.

## Ch3 good lượt 10: kiểm cả đường nav tới Ngư

- 16:11:27–16:14:36; bot 170,91 giây, wrapper 188,60 giây, exit 1. Log/report/ảnh `build/t236/10-ch3-good/b0a5e2e6bc964aaba1da9a1271e718c6/`, ảnh `captures/01_ch3_waypoint_FAIL.png`.
- Đích `(20, -9.9, 36)` nhưng nav vòng xuống z=28 qua cụm xác. Lỗi tại `(5.5584, -9.8992, 28.0145)`, segment garden, bar_hits=0, stamina≈0,349, collider Paving; xác tại `(6.5408, -9.8997, 27.9469)` bắt Trung.
- Đã phân tích đường nav (`ch3-garden-path.log`, `ch3-garden-detours.log`): các lối tây z=38/40/46 đều vòng qua z=28. Đổi tuyến bot đi bên ngoài phía đông x=48, vào vườn `(42, -9.9, 36)`, đi cúi tới `(20, -9.9, 36)` rồi `(20, -9.9, 28)` để tới Ngư từ phía sau đàn idle. Test thêm kiểm góc đường vào/ngang vườn đều ở z>34; `ch3-garden-east.log`: `RESULT: 1 passed, 0 failed`, exit 0.
- Lượt 11 bắt đầu 16:19:16; bản vá/log tại `build/t236/11-ch3-good/`. Chưa kết luận hoàn tất hoặc lỗi game.

## Ch3 good lượt 11: input đánh thanh sắt

- 16:19:16–16:23:02; bot 211,20 giây, wrapper 225,85 giây, exit 1. Log/report/ảnh `build/t236/11-ch3-good/3ea3e310d7f945888528c263b006a24b/`, ảnh `captures/01_ch3_waypoint_FAIL.png`.
- Tuyến đông/cúi tới Ngư thành công: `bar_hits=8`, stamina=1 tại `(19.4621, -9.8991, 28.1412)`. Chết khi đi P15 tại `(24.7738, -9.8991, 36.0019)`, xác trước mặt `(25.7495, -9.8997, 35.8436)` có caught=true, thanh vẫn 8 lượt, stamina≈0,518.
- Fixture mới `test_ch3_bot_strike.gd` dùng player/weapon/input thật và lần lượt 10 mẫu xác đã mặc model, không chạy chương: trước sửa FAIL cả 10, log `ch3-strike-before.log`; Godot cảnh báo parse lại cùng đối tượng event trong một frame. Bot đổi `event.pressed=false` sau `process_frame` có thể sửa chính sự kiện nhấn chưa được input queue xử lý.
- Sửa bot tạo đối tượng nhả chuột riêng, không thay đổi event nhấn đã gửi. Sau sửa fixture đạt đủ 10 mẫu bị stun và thanh mất đúng một lượt: `RESULT: 1 passed, 0 failed`, exit 0, `build/t236/ch3-strike-event.log`. Không sửa player/vũ khí/xác.

## Ch3 good lượt 12: cửa tây sân vận động

- 16:26:32–16:32:00; bot 314,44 giây, wrapper 328,56 giây, exit 1. Log/report/ảnh `build/t236/12-ch3-good/43c8761cc8254664bd106cbf680ab74f/`, ảnh `captures/01_ch3_waypoint_FAIL.png`.
- Đã nhận thanh sắt, đập thật (8→7 lượt khi rời vườn), tới P16/P17. Lỗi khi vào P18_Wait_stadium: segment stadium, vị trí `(111.2275, -9.8998, 165.9391)`, bar_hits=6, stamina≈0,510, collider là xác. Hai xác có caught=true phía trước và bên hông.
- Tuyến đi thẳng cửa tây x≈112,z166 trùng hai spawn đầu `(112,-9.9,166)` và `(112,-9.9,170)`, bot chỉ kịp choáng một con. Không đổi spawn/đợt xác. Đang kiểm tuyến vào/ra qua phía nam `(149,-9.9,220)`, vòng sống sót chỉ dùng bốn điểm giữa sân P19/P20/P21/P22, bỏ P23 sát cửa tây để tránh quay qua điểm spawn mỗi vòng.

## Ch3 good lượt 13: vòng sống sót sân vận động (Claude làm thay)

- Lane C hết hạn mức sau khi chuẩn bị tuyến phía nam (test `ch3-stadium-south-nav.log`: `RESULT: 1 passed, 0 failed`). Integrator chạy lượt 13 bằng đúng `build/t236/run_case.ps1` của lane C, khóa CreateNew, 16:47:03–16:55:07; bot 469,13 giây, wrapper 483,35 giây, exit 1, `RESULT: playthrough 0 passed, 1 failed`. Log/report/ảnh `build/t236/13-ch3-good/85676926aae84b9391cb69e5ad414941/`, ảnh `captures/01_ch3_waypoint_FAIL.png`; bản vá `bot.patch`.
- Tuyến phía nam vào sân được: PASS `(80, -9.9, 226)`, `(149, -9.9, 220)`, segment đổi sang stadium. Các mốc ch3 đều qua trong lượt này: `open_407`, `take_key`, `open_fire_door`, `sound_extinguisher`, `sound_fire_alarm`, nhận thanh sắt.
- Lỗi: trong vòng giữa sân, đi tới P22 thì `DEATH_CH3_GRABBED` tại `(220.9, -9.9, 164.6)`; xác `(220.4, -9.9, 165.5)` caught=true, hai xác khác đang săn trong 20 m. Thanh sắt còn 7 lượt (bot không đánh trong sân), thể lực 0,35.
- Phân tích: bot chỉ đánh khi bị chặn (`strike_blocker`), còn vòng sống sót chỉ đi giữa bốn điểm; xác mới xuất hiện dồn theo. Đây là chiến thuật của bot (khi nào đánh, khi nào chạy, giữ thể lực), chưa có bằng chứng lỗi game. Không chạy thêm lượt.

## Kết luận lượt T-236 (08/11/2026)

- **Mục tiêu kiểm các sửa T-232 đã đạt:** ch2 good PASS (lau màn tắm theo node thật, chỗ đứng, cả chương); ch3 good qua báo cháy tầng 1 và mọi mốc trước sân vận động.
- **Sửa bot trong lượt này** (không sửa game): ch2 đi tới chỗ đứng `leave_shower` trước lần lau đầu, ngắm bằng yaw thân và pitch Head (hiệu ứng đẩy cửa xóa góc camera); ch3 chờ đường qua FireDoorLink sau khi mở cửa, đi cúi ở đoạn nấp 207, tránh đồng đội ở hành lang (z=3), điểm vào vườn trong vùng, vòng phía đông tới Ngư, nhả chuột bằng sự kiện riêng khi đánh, vào sân từ phía nam; thêm chẩn đoán (vị trí, segment, xác trong 20 m, thể lực, lượt gậy, ảnh khi lỗi).
- **Còn lại, đề xuất việc sau cho lane C:** (1) chiến thuật vòng sống sót sân vận động cho bot (đánh xác ở gần khi còn gậy, giữ thể lực, chọn điểm xa chỗ spawn) cho tới khi ch3 good đạt; (2) các ca âm ch2 (5 ca) và ch3 (2 ca).
- **Gợi ý cho chủ dự án (chưa phải lỗi game):** bot cần đi cúi, vòng tránh đàn xác và đồng đội mới qua được chương 3; nếu người chơi thật cũng hay chết ở 207, vườn hay sân vận động thì đó là độ khó cần xem khi chơi thử chương 3.

## So với dự trù T-230

T-230 dự trù ch2 good 12–25 phút, ch3 good 12–30 phút; các ca âm ch2 chain 1–5 phút, scald/leave 4–10 phút, wrong_prediction 8–18 phút; ch3 grabbed/guard 1–6 phút. Lượt 01 dừng sớm khoảng 3 phút 56 giây ở đầu vòng 4, nên không dùng thời gian này để kết luận ETA hoàn thành ch2 nhanh hơn dự trù. Ch2 good lượt 03 hoàn tất 9:50, thấp hơn dự trù 12–25 phút; đây là một lượt bot dùng action/profile hiện có, không đại diện thời gian người chơi. Các ca chưa chạy chưa có số đo.

## Kiểm tra và giới hạn

Test lọc lịch thao tác đạt 2/0, fixture vị trí/ray/lau có physics đạt 1/0, fixture đánh 1/0, profile ch3 1/0. Ch2 good đạt; ch3 good chưa đạt (vòng sống sót sân vận động). Các ca âm chưa chạy. Full test/check: integrator chạy trên `main` sau khi merge nhánh này (xem Handoff card). Chưa đo FPS, không chạy chương 1, không sửa game hoặc docs ngoài card T-236. Full test/check sẽ chạy trước commit vì có sửa code.
