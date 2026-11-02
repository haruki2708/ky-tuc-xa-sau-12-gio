# T-230 — Rà tĩnh bot và smoke test chương 2–4

Ngày bắt đầu: 01/11/2026; tiếp tục qua 02/11/2026. Lane C mới (D-139). Mốc đối chiếu: `origin/main` = `2773a3f608f33a2bda719a3dcfbf74900cfe07c0`.
Nhánh: `lane-c/T-230-bot-smoke-review-ch2-4`.

## 1. Kết luận và giới hạn

**Cần sửa binding lau màn sen tắm trước khi cho chạy lại nhóm kịch bản chương 2 đi tới vòng 4.** Điểm bedroom còn chồng bàn gấp trong mô hình hình học tĩnh. Profile vẫn ngắm vào vị trí cũ; màn và vùng nhận lau đã chuyển sang tường tây (D-109). Bot chương 3 còn thiếu kiểm chứng báo cháy tầng 1 D-075 và có nguy cơ vướng đồ mới ở đoạn ra khỏi phòng 407. **Chưa có menu F9 chương 4**, dù đã có API director nhảy giai đoạn.

Lượt này không chạy bot, launcher playthrough, benchmark/FPS, export hay Tripo. Không sửa profile/bot/gameplay/scene. Kết luận dưới đây là từ đọc mã, dữ liệu scene và công cụ kiểm tĩnh; **OK không đồng nghĩa chơi hết chương thành công**.

Quy ước:
- **OK:** hợp đồng/đường dẫn tĩnh khớp, chưa thấy sai trong phần được kiểm.
- **Có thể hỏng:** cần kiểm runtime, ray/va chạm/navigation/nhịp sự kiện; chưa khẳng định thất bại.
- **Chắc chắn hỏng:** có mâu thuẫn cụ thể trong mã hoặc thiếu khả năng được yêu cầu. Không suy diễn rằng mọi kịch bản đều chết ở cùng một điểm.
- `DEFERRED` của công cụ: đường dẫn được khai báo trong bảng producer runtime đã rà tay; chỉ xác nhận các node cha/anchor tồn tại, **không** chứng minh producer đã chạy, method/signal còn đúng hay node còn sống.

Các số dòng dưới đây thuộc mốc main trên, đường dẫn tính từ gốc repo.

## 2. Công cụ và bằng chứng node path

Công cụ mới: `game/scripts/debug/profile_static_audit.gd`; test: `game/tests/tools/test_profile_static_audit.gd`.

Chạy lại: `pwsh tools/test.ps1 -Filter test_profile_static_audit` theo luật lượt Godot. Công cụ đọc `PackedScene.get_state()`, mở rộng scene lồng và base scene, chuẩn hóa `./`; **không instantiate scene chương, không đưa scene vào cây, không gọi director**. Thu thập đệ quy mọi `path`, `anchor`, `director`, đường DeathScreen, mảng guard/spawn, cả loop/wait/verify/menu/performance trong hai profile. `HeadHitbox` được kiểm theo root zombie riêng.

| Profile | Số tham chiếu (có lặp) | Có sẵn | Producer runtime cần kiểm tiếp | Thiếu chưa giải thích |
|---|---:|---:|---:|---:|
| Chương 2 | 21 | 9 | 12 | 0 |
| Chương 3 | 108 | 91 | 17 | 0 |

Lượt test lọc cuối: `RESULT: 3 passed, 0 failed`. Log tại `build/t230/filtered-test.log` (không commit build). Test có trường hợp sai tên, mất anchor cha, vòng lặp lồng, path trong wait/array, scope đầu zombie và scene lồng của hai chương thật. Lượt đầu công cụ chưa loại `./` nên báo thiếu sai; đã sửa, không dùng số lượt đầu làm kết luận về game.

Producer được đối chiếu:
- Ch2 `chapter2_director.gd:772`: Carry_rag/towel/shirt (:780), GagSpot (:797), StuckDoor (:806), ShowerStallArea (:818), Wipe (:837). Cha nằm dưới `Floor4/Room407`.
- Ch3 `chapter3_director.gd:405`: Horde; :450–464 tạo Guard01…12 theo `Campus/Anchors/GuardLine/G01…G12`; :469–510 tạo Use_FireKey, Use_FireDoor, Use_Extinguisher2F.
- Player, DeathScreen/Root, Floor4/Door407, các anchor route/spawn đều có trong PackedScene; HeadHitbox có trong zombie.
- Bảng runtime trong công cụ là tri thức rà tay, cần cập nhật cùng producer. Nó không phân tích GDScript để chứng minh việc tạo node.
- Công cụ chưa tự dò chuỗi path bên trong mã bot; phần này rà tay ở mục 5. Nó cũng không kiểm method/property/signal, transform sau `_ready`, reachability hoặc hình ảnh.

## 3. Chương 2: từng bước và từng kịch bản

### 3.1. Các bước vật lý trong profile

`chapter_actions.gd:81–85` thực hiện goto bằng gán `player.global_position`, xóa velocity; **không đi bộ qua đường nối hai điểm**. `ch2_actions.gd:122` chạy lần lượt steps, chờ xác nhận tối đa 3 giây (:149). Gọi `interact` trực tiếp (:192) không tự kiểm khoảng cách/ray. CarryItem cũng không kiểm khoảng cách trong `carry_item.gd:44`. Vì vậy nhặt thành công có thể che mất lỗi vị trí hoặc đường đi.

Tất cả tọa độ sau là world; room có offset (30,0,0), `floor4.tscn:49–50`.

| Action / từng bước | Đánh giá | Bằng chứng và ảnh hưởng |
|---|---|---|
| pickup_rag, bước 0: goto (35.6,.05,-4.7), xác nhận bathroom | Có thể hỏng | Profile :13–25. Điểm cũ; giẻ thật ở (37.827,1.509,-5.3), `room407_anchors.tscn:311–312`. Chênh ngang khoảng 2.31 m, vượt ray 2 m trước cả chênh cao. Không chứng minh người chơi nhặt được. |
| pickup_rag, bước 1: Carry_rag.interact → picked | OK về producer/API; có thể bỏ sót lỗi tầm với | Profile :29; director :780; CarryItem :44. Bot có thể nhặt từ xa vì gọi method trực tiếp. |
| pickup_towel, bước 0: goto (32.8,.05,-7.6), xác nhận balcony | Có thể hỏng | Profile :39–52; cửa ban công và giá phơi cần rà hình học mục 3.3. TowelSpot đã chuyển tới (32.8,2.15,-7.85), `room407.gd:27,213`. |
| pickup_towel, bước 1: Carry_towel.interact → picked | OK về producer/API | Profile :55; director :780. Không chứng minh ray tới khăn cao mới hoặc đi qua cửa được. |
| pickup_shirt, bước 0: goto (31,.05,-1.25), xác nhận bedroom | Có thể hỏng | Profile :65–78; ShirtSpot ở (30.3,.87,-1.25), anchor :323. Vị trí vẫn gần, chưa kiểm capsule với giường/đồ. |
| pickup_shirt, bước 1: Carry_shirt.interact → picked | OK về producer/API | Profile :81; director :780. Cùng giới hạn tương tác trực tiếp. |
| gag_1, bước 0 goto (31.4,.05,-2.3); bước 1 Gag1/GagSpot.interact | Có thể hỏng về chỗ đứng; OK về producer | Profile :91; director :797. Anchor Gag1 theo cơ thể (:329–331); không lấy vị trí miệng thật để đặt/ngắm. |
| gag_2, bước 0 goto (31.4,.05,-2.3); bước 1 Gag2/GagSpot.interact | Có thể hỏng về tầm với; OK về producer | Profile :118; dùng cùng chỗ đứng cho hai giường; anchor Gag2 :333–335. Gọi method không chứng minh nhắm đúng miệng. |
| gag_4, bước 0 goto (36.6,.05,-2); bước 1 Gag4/GagSpot.interact | Có thể hỏng về chỗ đứng; OK về producer | Profile :145; anchor :337–339. Giường và đồ chặn cần kiểm capsule. |
| bedroom, bước 0 goto (33.5,.05,-2) → bedroom | **Chắc chắn chồng collider trong mô hình hình học tĩnh**; có thể hỏng runtime | Profile :172; giao capsule với FoldingTable mới khoảng 0.0725 m theo phép tính mục 3.3. Kiểm zone chưa đủ phát hiện chồng đồ; chưa đo đẩy bật/trượt khi physics chạy. |
| push_door_1, bước 0 StuckDoor.interact → bashed | OK về API; có thể bỏ sót lỗi tiếp cận | Profile :188; director :806. Không bước đi đến cửa; dùng vị trí cuối trước đó. |
| push_door_2, bước 0 cùng node → bashed | OK về API; có thể bỏ sót lỗi tiếp cận | Profile :202. Không xác minh hình cánh cửa hoặc khoảng trống. |
| push_door_3, bước 0 cùng node → opened | OK về API; có thể bỏ sót lỗi tiếp cận | Profile :216; director nối opened :811–813. |
| enter_shower, bước 0 goto (36.18,.05,-6.32) → player_inside=true | OK về anchor; có thể hỏng va chạm | Profile :230; stall anchor :363–370; director sao chép box thật :819–823. Chưa kiểm capsule cạnh BathShelf. |
| leave_shower, bước 0 goto (36.18,.05,-5.2) → player_inside=false | OK về anchor; có thể hỏng va chạm | Profile :246; cần kiểm overlap area sau physics và cửa nhà tắm. |
| wipe, bước 0 giữ interact 1.1s, aim (36.18,1.45,-6.78) → wiped | **Chắc chắn hỏng binding ngắm cũ** | Profile :262–274; màn thực ở (35.387,1.45,-6), xoay Y=90°, `room407_anchors.tscn:341–344`. Xem phân tích dưới. |

Wipe: `ch2_actions.gd:165–172` xoay camera tới aim; `shower_screen.gd:23–28` bắt ray phải chạm chính node Wipe và :31–46 yêu cầu giữ nhìn liên tục. Box lau chỉ (0.4,0.3,0.04), `scenes/interaction/shower_screen.tscn:5`; sau xoay 90° bề dày theo X chỉ 0.04 m. Khi đứng ở hai điểm enter/leave có X=36.18, nhìn aim X=36.18, ray không hướng sang mặt màn X=35.387 (lệch 0.793 m). Khi chưa di chuyển khỏi bedroom, đường ngắm cũ cũng không nhắm đúng màn. Đây là lỗi binding tĩnh, không phải khẳng định đã quan sát timeout runtime. Đề xuất lấy điểm ngắm từ anchor/node Wipe và chọn chỗ đứng hợp lệ, giữ nguyên yêu cầu lau 1 giây.

### 3.2. Luồng chung và sáu kịch bản

`ch2_bot.gd:7–14` liệt kê sáu case; :33–101 khởi tạo từ đầu chương, không dùng `jumps.r3/r4` để rút ngắn các case âm. `ch2_policy.gd` chọn từ độc lập và chỉ dùng nhiệt độ đã quan sát. D-072 đã được cập nhật: tell ở :145, vòng bốn từ trong `ch2_actions.gd:7–8,101–108`.

| Kịch bản | Chuỗi bước được rà | Đánh giá |
|---|---|---|
| ch2_good | preflight/isolation/time_scale → start → trả lời cuộc gọi → nối từ hợp lệ/bẫy → pickup/gag ba giường + bedroom → tell → bốn từ vòng lặp → ba cú đẩy cửa → chọn tắm/ra ngoài + wipe mỗi slot → dự đoán hai bạn → đủ phút → unlock 3 | **Chắc chắn hỏng binding wipe**, những bước vật lý khác có rủi ro nêu trên. Phần chữ/signal/điều kiện hoàn thành OK tĩnh (:84–86, :133–202). |
| ch2_chain_timeout | start → đợi chain_input_requested → không trả lời ≥15s → lý do/animation corpse_lunge → DeathScreen → checkpoint ch2_r3/fresh scene | OK tĩnh (:154–158, :210–228). Không dùng pickup/wipe; chưa xác minh UI/reload runtime. |
| ch2_chain_wrong | start → tìm từ sai dấu → kiểm độc lập với core → phát câu → death/reload ch2_r3 | Có thể hỏng thời gian chờ nếu không tìm được sai dấu: :162–176 chuyển về legal, chưa đảm bảo case âm xảy ra trong hạn. Policy :68–71 quét từ điển; không phụ thuộc model. |
| ch2_scald | luồng R3 như good → mở cửa → các slot đầu → tại slot index 3 cố chọn Có để gặp 81°C → death scald → ch2_r4 | **Có thể không tới thao tác âm vì binding wipe chắc chắn sai** (:184–202); kiểm cờ 81°C :126–130 khớp director :557–562. |
| ch2_leave_shower | luồng R3 → mở cửa → lần Có đầu → enter rồi leave → death fall_back → ch2_r4 | Cùng blocker wipe ở các slot trước; logic rời vòi :196–198 và kiểm death :210–228 OK tĩnh. |
| ch2_wrong_prediction | luồng R3 → R4/tắm/wipe → trả lời đúng Minh Nhật, sai Ngư → DEATH_CH2_LOST_NGU → ch2_r4 | Cùng blocker wipe; chính sách chỉ dùng ba nhiệt độ đã nhận, `ch2_policy.gd:96`; bot :134–141 không tự đặt kết quả. |

Quản lý Tripo hiện qua `room.flash_reflection()` ở `chapter2_director.gd:520–527`. Bot không tìm bone/model quản lý, không kiểm hình phản chiếu. Đường dẫn bot không hỏng chỉ vì đổi model, nhưng một lượt bot PASS cũng không chứng minh hiệu ứng đúng.

### 3.3. Đồ chặn T-225 và cửa ban công

`room407_obstacles.gd:39–45,91–110` thêm collider layer world cho tám đồ dưới đây. `room407.gd:257–260` tạo vật lý và bake navigation. Đây là collider theo bounds GLB, có xoay và inset 0.05 m; **khoảng cách tới gốc đồ không phải bằng chứng không chồng collider**.

| Đồ / nguồn placements.json | Vị trí world của gốc | Bước liên quan / việc cần kiểm |
|---|---|---|
| DryingRack :107 | (31.75,0,-6.4) | đường phòng→khăn ban công; ch2 teleport bỏ qua đoạn này |
| StandingFan :37 | (34.5,0,-4.35), yaw120 | đường phòng→nhà tắm; không có waypoint walking ch2 |
| ShoeRack :52 | (35.9,0,-.2) | đường phòng→hành lang ch3 có thể chịu thay đổi navmesh |
| FullMirror :53 | (36.6,0,-3.78), yaw180 | từ gag_4 sang nhà tắm; hình phản chiếu không được bot kiểm |
| FoldingTable :77 | (33.2,.008,-2.5), yaw90 | bedroom (33.5,.05,-2), điểm đáng kiểm overlap trước |
| WaterDispenser :80 | (35.05,0,-3.85), yaw90 | đi tới rag/nhà tắm; có thể bó hẹp đường |
| BathShelf :101 | (35.56,0,-6.78) | enter_shower và đường tới màn mới |
| Mop :105 | (37.72,0,-4.3) | nhặt giẻ đã dời tới x37.827 |

Rà bổ sung bằng Python đọc JSON chunk của GLB, min/max POSITION accessor và transform cây node (không chạy Godot/bot): mô phỏng công thức `Room407Furnish.local_bounds` (:182) và `make_solid` (:95), inset X/Z 0.05 m, rồi đo khoảng cách từ đoạn trục capsule đứng tới box đồ vật trong hệ tọa độ đồ. Capsule player bán kính0.3m, cao1.75m, tâm cao0.875m (`player.tscn:6–17`): đoạn trục từ y+0.3 tới y+1.45. Kết quả dùng placement tĩnh ban đầu; không mô phỏng physics, không xét collider ngoài tám đồ này.

| Điểm profile | Đồ gần nhất trong tám đồ | Khoảng hở có dấu capsule–box (m) |
|---|---|---:|
| pickup_rag | WaterDispenser | +0.5333 |
| pickup_towel | DryingRack | +0.6601 |
| pickup_shirt | FoldingTable | +1.9144 |
| gag_1 | FoldingTable | +1.3004 |
| gag_2 | FoldingTable | +1.3004 |
| gag_4 | FullMirror | +1.3847 |
| bedroom | FoldingTable | **-0.0725** |
| enter_shower | BathShelf | +0.3317 |
| leave_shower | FullMirror | +1.0476 |
| ch3 b[0] | FoldingTable | +1.0452 |
| ch3 b[1] | ShoeRack | +1.8199 |

Dấu âm là chồng hình trong mô hình tĩnh. Bằng chứng tái tính riêng điểm bedroom: collider FoldingTable local x≈[-0.3001,0.3000], y≈[0.0001,0.3000], z≈[-0.2001,0.1999]; placement (33.2,0.008,-2.5), yaw90°. Điểm player đổi về local x=-0.5, z=0.3; đáy đoạn trục y=0.342. Khoảng cách tới box ≈sqrt(0.1999²+0.1001²+0.0420²)=0.2275 < radius0.3. Cần chọn điểm đứng mới theo khoảng trống thật ở lượt sửa profile, không dời bàn/collider để phục vụ bot. Các khoảng hở dương chỉ loại trừ chồng với tám box tại đúng điểm đứng, không chứng minh đường nối hay những đồ khác an toàn.

Cửa ban công: `balcony_door.gd:7` mặc định -172°; `room407.gd:276–290` lấy bản lề/góc từ shell thật và bounds cánh để tạo collider. Profile không có action mở/đóng hay waypoint qua bản lề. Đọc `room407_shell/fixtures.glb`: pivot local (3.262,0,-7.075), góc -172°; box leaf trong pivot x≈[-0.922,-0.002], y≈[0.02,2.26], z≈[-0.000157,0.049999]. Điểm khăn (32.8,.05,-7.6) có khoảng hở capsule tới box cánh mở khoảng +0.3593 m theo phép tính tĩnh; không chồng box cánh ở đúng điểm này. Đường đi qua khung/bản lề vẫn chưa kiểm; teleport không kiểm đường đó. Không tự đóng cửa hay đổi scene để thuận bot. Cửa nhà tắm cũng đã chuyển pivot theo vỏ (:250–253), nên test node path không đủ kiểm lối đi.

## 4. Chương 3: từng tuyến và kịch bản

`ch3_actions.gd:44–110` lấy navmesh, chờ đồng bộ tối đa 10s, kiểm endpoint trong 0.8m, đi bằng input tới từng điểm trong 0.6m, mặc định tối đa 180s/điểm; kiểm guard radius. Có navigation không chứng minh player capsule đi qua được collider mới. Không sửa tuyến để né khó của thiết kế.

Các chỉ số dưới đây là index JSON bắt đầu từ 0 trong `tools/ch3-profile.json`. Các tên Pxx là dưới `Campus/Anchors/Paths/Nhat`; anchor tồn tại đã qua kiểm tĩnh. Mỗi dòng OK chỉ là cấu trúc, không phải kết quả bot.

| Bước | Đánh giá | Lý do / bằng chứng |
|---|---|---|
| b[0] (32,0,-1.3), open_407 | Có thể hỏng | Ra khỏi phòng mới; Door407 world (32.44,.01,0), `floor4.tscn:58–60`, trong 2.5m tại điểm đích. Tới được điểm đó chưa kiểm va chạm. |
| b[1] (35.75,0,2) | Có thể hỏng | Rời phòng qua khe cửa/navmesh mới; không phải đường thẳng nối hai waypoint. |
| b[2] (39.8,0,1.6), take_key | OK về anchor/producer; có thể hỏng runtime | Use_FireKey do director :470 tạo; `perform` :156–172 bắt khoảng cách và acknowledgement. |
| b[3] (42.8,0,2), open_fire_door | OK tĩnh | Use_FireDoor :479; cần có chìa, kiểm cờ sau tương tác. |
| b[4] (45.5,0,2) | OK tĩnh | Điểm cầu thang; vẫn cần navmesh/capsule runtime. |
| b[5] (45.5,-3.3,2) | OK tĩnh | Xuống tầng 3; chưa đo đường đi. |
| b[6] (47.8,-6.6,2.4), sound_extinguisher | OK tĩnh | Use_Extinguisher2F :490–496; cờ ch3_alarm là bình chữa cháy tầng 2. |
| b[7] (35.75,-6.6,2) | Có thể hỏng | Đi ngang đám xác 203, không xác minh đám đông đã tản. |
| b[8] (35.75,-6.6,-2.3), wait30s | Có thể hỏng | Chờ cố định trong 207, nhưng core theo dõi crowd settle/pull, `chapter3_director.gd:680–707` (trần 45s). 30s không bảo đảm mọi nhịp. |
| b[9] (35.75,-6.6,2) | Có thể hỏng | Ra khỏi 207 có cùng rủi ro crowd timing. |
| b[10] P02 | OK tĩnh | Anchor :7956 trong campus.tscn; nối tiếp lối tầng 2. |
| b[11] P03 | OK tĩnh | Anchor :7959. |
| b[12] P04 | OK tĩnh | Anchor :7962. |
| b[13] P05 | OK tĩnh | Anchor :7965. |
| b[14] P06 | Có thể hỏng | Anchor :7968; nhóm xuống tầng 1 cần kiểm báo cháy D-075. |
| b[15] P07 | Có thể hỏng | Anchor :7971; cùng thiếu action báo cháy. |
| b[16] P08 | Có thể hỏng | Anchor :7974; cùng nguy cơ xác chặn lối. |
| b[17] P09, crouch | Có thể hỏng | Anchor :7977; crouch không thay thế việc đánh lạc hướng đám đông. |
| b[18] P10, crouch | Có thể hỏng | Anchor :7980; thoát qua đường quản lý cần capsule/navigation thật. |
| b[19] P11 | OK tĩnh | Anchor :7983; không kiểm hình ảnh/cửa sổ. |
| b[20] P12 | OK tĩnh | Anchor :7986. |
| b[21] P13 → garden | Có thể hỏng xác nhận zone | Anchor :7989 có thật, nhưng walk không đối chiếu trường zone từng bước; chờ stage mới ở bot :71. |
| garden[0] (20,-9.9,26), chờ bar hits_left=8, 60s | Có thể hỏng nhịp | Core trao thanh sau hội thoại gần Ngư, director :275–279; bot chờ vũ khí nhưng chưa kiểm khoảng cách nghe/nhịp thực tế. |
| garden[1] P15 | OK tĩnh | Anchor :7995. |
| garden[2] P16 → road | OK tĩnh | Anchor :7998; zone là metadata chưa được assert. |
| garden[3] P17 | OK tĩnh | Anchor :8001. |
| garden[4] P18_Wait_stadium | Có thể hỏng chuyển stage | Anchor :8004; bot chờ stage stadium, không tự đặt cờ. |
| stadium[0].loop[0] P19 | OK về anchor, có thể hỏng sống sót | Anchor :8007; đánh zombie/thể lực/raycast cần runtime. |
| stadium[0].loop[1] P20 | Cùng đánh giá trên | Anchor :8010. |
| stadium[0].loop[2] P21 | Cùng đánh giá trên | Anchor :8013. |
| stadium[0].loop[3] P22 | Cùng đánh giá trên | Anchor :8016. |
| stadium[0].loop[4] P23_Wait_stadium | Cùng đánh giá trên | Anchor :8019; lặp tới ch3_stadium_survived, timeout360s; core cần240s (:24,308). |
| stadium[1] P24 | OK tĩnh | Anchor :8022. |
| stadium[2] P25 | OK tĩnh | Anchor :8025. |
| stadium[3] P26 → gate | Có thể hỏng chuyển stage | Anchor :8028; cần kiểm guard clearance thực. |
| stadium[4] Start_gate | OK tĩnh | Anchor :7554. |
| gate[0] P28 | OK tĩnh | Anchor :8034; route tránh guard chỉ là kiểm navmesh. |
| gate[1] P29 → canteen | OK tĩnh | Anchor :8037. |
| gate[2] P30_Wait_canteen | Có thể hỏng hoàn thành | Anchor :8040; chờ chapter_finished=3/unlock4 và companions trong bot :75–80. |
| guard_target → GuardLine/G06 | OK về anchor; có thể hỏng tới đích/chết | walk allow_guard=true ở bot :82–90, vẫn phụ thuộc navigation/cảnh chết/reload. |

**Thiếu coverage chắc chắn:** không có action cho `Campus/Anchors/FireAlarm1F/Use_FireAlarm1F` hoặc kiểm cờ `ch3_fire_alarm` trong profile. Core tạo báo cháy ở :743–766; :720–737 tạo bốn xác tầng 1, :769–776 kéo chúng đi khi báo cháy. Milestone bot chỉ `key_taken/noise_203/stadium_survived` (:77–80). Vì vậy PASS hiện tại vẫn không xác nhận cơ chế D-075; việc bot có chết vì bỏ báo cháy hay không chỉ là **có thể hỏng**, chưa chạy để khẳng định.

| Kịch bản | Toàn bộ luồng | Kết luận |
|---|---|---|
| ch3_good | preflight/isolation/TimeScale1 → run_from b → toàn bộ b/garden/stadium/gate ở bảng trên → hoàn thành/unlock4, nhận bar, hai bạn đồng hành, bốn stage | Có thể hỏng ở phòng407, crowd203/tầng1, chiến đấu hoặc timing. Không có path thiếu tĩnh. Thiếu coverage báo cháy chắc chắn. |
| ch3_grabbed | run_from garden → đứng chờ player_failed → DEATH_CH3_GRABBED/zombie_grab → checkpoint ch3_garden → DeathScreen/fresh scene | Có thể hỏng nhịp chờ: không phải full run từ 407; phụ thuộc spawn/đến gần/story khi đứng yên. :65–67,88–114 trong ch3_bot. |
| ch3_guard | run_from gate → walk GuardLine/G06 cho phép vào vùng bảo vệ → DEATH_CH3_GUARD/guard_shock → checkpoint ch3_gate → UI/fresh scene | OK hợp đồng tĩnh; navigation/death runtime chưa kiểm. :82–114. Không kiểm toàn tuyến chương. |

Menu ch3 có jumps b/garden/stadium/gate và bốn action zombies_on/off/give_bar/refill; director có API :940–962. Cả 11 anchor performance và 40 spawn path tồn tại; chỉ đọc dữ liệu, **không chạy performance**.

## 5. Bot nền, hardcode và menu

| Thành phần | Đánh giá theo phạm vi chương 2–4 |
|---|---|
| chapter_actions.gd | Player qua find_child (:59), component phone_item/phone_screen qua tên script (:46–56,108–125); Player/Head, Head/Camera3D và InteractRay có trong player.tscn. OK tĩnh; goto teleport là khoảng trống QA hình học. |
| chapter_bot.gd | Ch2/ch3 override _run; không dùng plan chương1 mặc định. Dùng chung _until (:282), _record (:320), _finish (:333), kiểm/death-report. Timeout/SKIP không được coi là hoàn thành. |
| playthrough_bot.gd | Lớp gốc dùng _ready gọi _run động; ch2/ch3 override nên các _use legacy tại :74–128,200 không phải bước của ch2/ch3. Không đối chiếu luật demo cũ làm thiết kế mới. |
| ch2_actions/policy | Node vật lý lấy hoàn toàn từ profile; player/phone qua lớp cha. Từ điển, recent3, bốn từ D-072 và dự đoán đã có unit test. Ngắm Wipe là hardcode trong JSON đã sai. |
| ch3_actions/policy | Player, HeadHitbox, guard_paths từ hợp đồng trên; guard đủ 12 mới walk (:73–74). Guard vị trí runtime và đánh zombie (:127–152) chưa được kiểm bằng inventory. Trường zone chưa được assert trong walk/step. |
| qa_director.gd | Extends Chapter1Director, chỉ thay xử lý chết/invincible; không phải director test ch4. Không dùng để bỏ qua cơ chế trong lượt này. |
| ch2_menu.gd | F9 nhận Chapter2Director (:91), jumps r3/r4 gọi run_from sau isolation (:129–167). OK API tĩnh; menu observer không chứng minh vị trí đồ dùng. |
| ch3_menu.gd | F9 nhận Chapter3Director (:122), bốn stage và bốn action qua profile. OK tĩnh. |
| qa_menu.gd / tools/qa-menu.ps1 | qa_menu F9 chỉ nhận Chapter1Director (:101); launcher ValidateSet(1,2,3) (:3). **Chắc chắn chưa hỗ trợ chương4.** |
| tools/playthrough.ps1 | Chapter ValidateSet(0,1,2,3) (:3), danh sách case ch2/ch3 (:27,33), TimeScale1 mặc định (:29,35); không có ch4. Không chạy launcher lượt này. |

## 6. Chương 4 và smoke test

### 6.1. Có gì / thiếu gì

Đã có:
- `scenes/main/chapter4.tscn`, Floor4 + Campus + UI chung; `scenes/levels/hospital/hospital_room.tscn`.
- `chapter4_director.gd:12,80–85`: run_from với split/library/return/room407/end4; checkpoint/death mapping :108–117.
- Core test `test_chapter4.gd`: split/library/return (:85,103,120), lật thanh giường/ký tên/kết đúng (:136), hết giờ/sai tin nhắn (:164,171), reach thanh giường (:194), cửa sau thư viện (:227), checkpoint chết (:242).
- `test_chapter4_data.gd`, các test UI/audio/gameplay liên quan và smoke quét scene.
- Không có F9 chương4 hoặc bot/profile chương4 trong main hiện tại. Không viết thêm trong T-230.

Nếu chủ dự án muốn bot ch4: cần giao card riêng cho profile route năm stage, binding tài liệu/so sánh quy tắc/thanh giường/tên máu/tin nhắn cuối, oracle hai kết, checkpoint/death, isolation/save, deadline và menu4. Phương án đề xuất: làm test hợp đồng + menu jump trước, sau đó bot good và hai case kết cô độc; chủ dự án quyết phạm vi/case cần thiết, không tự chọn thay.

### 6.2. Smoke đang load gì

`game/tests/smoke/test_smoke_scenes.gd:4–29,32–41` quét **mọi .tscn dưới res://scenes**, đệ quy và sort, load+instantiate, đưa vào tree hai frame rồi dọn. Hiện có **125 .tscn** trong phạm vi quét. Vì vậy **không thiếu scene chương2–4 nào nằm dưới thư mục này**: chapter2/3/4, floor4, campus, hospital_room, interaction và entity đều được chọn tự động. Không cần bổ sung danh sách main scene cố định.

Giới hạn: scene chạy _ready, không hoàn toàn tĩnh; chỉ hai frame không chứng minh qua câu đố/chuyển stage hay đường đi. Script tạo resource trễ có thể chưa được gọi. Node trong scene lồng thường được nạp gián tiếp, khác với kiểm scene độc lập.

| Ngoài res://scenes, không được smoke chọn độc lập | Mức nạp gián tiếp / thiếu |
|---|---|
| ui/chain/chain_panel.tscn; ui/shower/shower_screen.tscn | Director2 tạo panel/Lcd trong _ready; có thể được nạp qua chapter2, không là một entry smoke riêng. |
| ui/ch3/ch3_status.tscn; ui/ch3/ch3_end_card.tscn | Director3 _place_ui :371–377; nạp deferred phụ thuộc vòng đời, không có case độc lập. |
| ui/ch4/bed_card.tscn; ui/ch4/ch4_end_card.tscn; ui/ch4/fade_effect.tscn | BedCard chỉ được instance tại bệnh viện (:525–529), nên smoke chapter4 đầu chương chưa tới. End card được thêm deferred ở :704–705; fade_effect được ch4_phone.gd:39 instance khi UI điện thoại khởi tạo. Không có entry smoke độc lập cho ba scene này. |
| ui/ch2_ui_preview.tscn; ui/ch3/ch3_ui_preview.tscn; ui/ch4/ch4_ui_preview.tscn | Không nằm trong vùng quét; các preview cần test riêng nếu muốn kiểm UI độc lập. |
| ui/hud, phone, death, notebook, document, puzzle, pause, survivors | Được instance trực tiếp bởi chapter scene; không được smoke chọn độc lập từ gốc UI. |
| rendering/ps1_filter.tscn | Nạp gián tiếp trong chapter scene; không được quét độc lập. |
| scripts/debug/*_bot.tscn, *_menu_smoke.tscn, *_performance.tscn, qa_preview.tscn | Đều ngoài vùng quét; **không mở rộng smoke vào cả debug** vì có thể chạy bot/benchmark ngoài ủy quyền. |
| GLB/resource do mã load trễ | Không là .tscn được quét; không suy luận mọi asset và mọi trạng thái đã được nạp chỉ từ smoke PASS. |

Đề xuất integrator cân nhắc smoke UI theo allowlist các scene cần thiết, vô hiệu auto_start khi kiểm cấu trúc; không quét mù toàn bộ dự án. `test_ch3_profile.gd:8–119` đã kiểm API thật + endpoints navmesh, nhưng đặt player ngay cạnh action để kiểm hợp đồng; không phải một lượt đi bộ qua phòng đồ mới.

## 7. Ưu tiên và thời gian dự trù (chưa đo)

| Ưu tiên | Đề xuất lượt sau | Ai/phạm vi |
|---|---|---|
| P1 | Sửa aim Wipe theo node/anchor, test ray thực ở chỗ đứng hợp lệ | Lane C với card cho phép sửa profile; không sửa luật lau |
| P1 | Kiểm capsule ở mọi điểm goto ch2, đặc biệt bedroom và cửa ban công; kiểm lối ra 407 ch3 bằng navigation + collision | C kiểm; thiếu/sai collider/navmesh thì chuyển B/integrator |
| P1 | Thêm coverage báo cháy tầng1 ch3; xác minh cách vượt đám đông theo D-075 | C đề xuất tuyến/case, chủ dự án duyệt việc chạy; không tự đổi độ khó |
| P2 | Thay wait30s bằng acknowledgement có hạn khi có hợp đồng phù hợp; assert zone ở waypoint quan trọng | C; cần API/cờ mới thì yêu cầu core |
| P2 | Kiểm ray/reach cho nhặt/gag/đẩy cửa, tránh method call che lỗi bố trí; log điểm đứng và target | C theo card sau |
| P2 | Menu jump ch4 + smoke UI allowlist nếu cần | Chưa được giao; integrator/chủ dự án quyết |
| P3 | Kiểm thủ công hình phản chiếu quản lý, giấy, ánh sáng, cánh cửa | Chủ dự án chơi thử; bot logic không thay thế |

Ước lượng phục vụ đặt lịch, **không phải số đo hoặc cam kết PASS**, chưa gồm import lần đầu:
- Ch2 good sau sửa: khoảng 12–25 phút; hai case chain khoảng 1–5 phút/case; scald/leave khoảng 4–10 phút/case; wrong_prediction khoảng 8–18 phút. Tổng sáu case dự trù 30–75 phút nếu không bị kẹt. Căn cứ: bắt đầu R3 cho mọi case, báo thoại/nối từ, tối đa 30 slot tắm; slot20s là ngân sách, code :544–575 trừ thời gian lựa chọn và có grace2s, nên không lấy 30×20 làm thời gian thực chính xác.
- Ch3 good: khoảng 12–30 phút; grabbed/guard khoảng 1–6 phút/case; tổng khoảng 15–45 phút. Căn cứ: sân240s, chờ207 30s, nhận bar tối đa60s, chiều dài tuyến và hội thoại chưa đo.
- Ch4 chưa có bot: không có thời gian chạy bot khả dụng; chỉ có chi phí test/menu sau khi được giao.
- Trần bảo vệ không phải ETA: ch2 60 phút/case trong bot :92 và launcher3615s (:94); ch3 75 phút/case (:100) và launcher4515s. Sáu case ch2 kẹt có thể gần6 giờ; ba case ch3 gần3 giờ45 phút. Đề xuất cho chạy từng case sau khi sửa/review, dừng để phân tích khi case đầu lỗi, chưa xin/chưa có ủy quyền chạy trong T-230.

## 8. Kiểm tra phiên này

- Test lọc công cụ: `RESULT: 3 passed, 0 failed`, exit0.
- Lượt full test bắt đầu 01/11 23:29 bị ngắt cùng phiên; session không còn, log wrapper rỗng, log engine riêng dừng giữa test_chapter1_d069, không có RESULT. Không tính là PASS/FAIL. Sau yêu cầu tiếp tục của chủ dự án, đã xác nhận không còn Godot, thu hồi đúng khóa lane C và chạy lại từ 23:59. Lượt chạy lại đạt: `RESULT: 854 passed, 0 failed` (exit 0, xong 02/11 00:20:52); tiếp đó `RESULT: check 0 error(s)` (exit 0, xong 00:33:55). Khóa Godot lane C đã được xóa trong finally. Log: `build/t230/full-test.log`, `check.log`, `gate-exits.txt`.
- Chưa kiểm: bot end-to-end, walking/capsule sweep/raycast runtime toàn tuyến (đã tính tĩnh điểm đứng với tám box đồ và cánh ban công), FPS, chất lượng hình ảnh, F9 chương4 (chưa có), chơi tay chương4.
- Yêu cầu ngoài phạm vi: các đề xuất sửa profile/bot/smoke hiện có cần card/ủy quyền lượt sau; không sửa STATUS/DECISIONS/core/scene trong lượt này.
