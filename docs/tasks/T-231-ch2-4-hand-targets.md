# T-231 — Điểm đặt tay (`HandTarget`) cho đồ dùng được trong chương 2–4
- Lane: A (Gameplay) | Trạng thái: done (merge 08/11/2026) | Agent: tài khoản GPT lane A (D-139)
- Nhánh: `lane-a/T-231-ch2-4-hand-targets` từ `origin/main` mới nhất.
- Quyết định giao: **D-141** (chủ dự án duyệt 07/11). Tiếp nối T-228 (chương 1, D-140).
- Phụ thuộc: T-228 (cách đặt marker, test mẫu `game/tests/player/test_ch1_hand_targets.gd`), D-140 (`Interactable.hand_target()` bỏ qua marker của Interactable lồng bên trong).

## Bối cảnh
- Chương 1 đã có `HandTarget` cho 22 đồ (T-228). Bước tiếp theo của nhân vật chính có thân (T-220 bước 5, T-227) là đưa thân vào cả 4 chương. Mọi đồ dùng tay của chương 2–4 cần có điểm đặt tay trước.
- Bản chơi chưa có thân, nên thêm marker **không đổi gì** khi chơi hiện nay.
- Đồ tương tác chương 2–4 nằm ở 3 nơi, **quyền sửa khác nhau**:
  1. **Scene và script của lane A** (`game/scenes/interaction/`, `game/scripts/interaction/`): director chương tạo ra. Ví dụ đã thấy: chương 2 `carry_item.tscn` (giẻ, khăn, áo), `shower_screen.tscn` (lau màn), `stuck_door.tscn`, `shower_stall.tscn`, `shower_choice.tscn`, `gag_spot.tscn`; chương 3 `iron_bar.tscn`; chương 4 `bed_slat.tscn`, `fake_search_spot.tscn`; cùng `readable.tscn` và các scene chương 1 nếu chương 2–4 dùng lại. **Lane A gắn marker.**
  2. **`Ch3Use` của core** (`game/scripts/core/ch3_use.gd`, director tạo bằng code): chương 3 `Use_FireKey`, `Use_FireDoor`, `Use_Extinguisher2F`, báo cháy tầng 1; chương 4 `Use_BackDoor` và các `Use_*` khác. **Lane A không sửa core**: kiểm kê và đề xuất chỗ đặt tay, kiểu nắm cho từng cái trong Handoff. Integrator gắn.
  3. **Scene level của lane B** (`game/scenes/levels/`, ví dụ cửa phòng `room_door`, bệnh viện): **lane A không sửa**. Kiểm kê và đề xuất như mục 2.

## Việc cần làm
1. **Kiểm kê** đồ tương tác của chương 2, 3, 4: đọc `chapter2_director.gd`, `chapter3_director.gd`, `chapter4_director.gd`, scene `scenes/main/chapter2.tscn`…`chapter4.tscn`, `campus`, `hospital_room` (đọc, không sửa). Ghi bảng vào Handoff: chương, tên, scene/script, thuộc nhóm 1/2/3 ở trên, nơi đặt (anchor), dùng tay hay không, kiểu nắm, chỗ đặt.
2. **Gắn `HandTarget` cho nhóm 1**, theo chú thích đầu `hand_target.gd` và cách T-228 đã làm:
   - đồ cầm lên (giẻ, khăn, áo, thanh sắt): kiểu nắm hợp lý (GRIP cả bàn cho thanh sắt, PINCH hoặc GRIP cho vải), ghi lý do;
   - lau màn tắm: bàn tay áp lên mặt màn, ghi kiểu nắm và lý do;
   - giấy, thẻ: như T-228 (PINCH, `pick_up = true`, đặt theo `size`);
   - đồ một scene dùng nhiều chỗ: kiểm marker đúng ở **từng chỗ** chương đặt nó;
   - nếu cần đặt khác nhau theo chỗ, ưu tiên một thuộc tính `@export` hoặc tính từ khối va chạm, **tránh mã cứng theo tên chỗ** (góp ý ở Review T-228).
3. **Không gắn** (ghi trong bảng): giường, chỗ nấp, bịt miệng (`bunk_spot`, `hide_spot`, `gag_spot`: leo, nằm, nấp, bịt miệng là phần thân của T-227 bước sau), vùng đứng như `shower_stall`, `StoryTrigger`, xác sống và nhân vật. Đồ chỉ đứng vào hay nhìn vào, không chạm tay, cũng không gắn; ghi lý do.
4. **Đề xuất cho nhóm 2 và 3** (mục "Yêu cầu thay đổi" trong Handoff): mỗi đồ một dòng gồm đường dẫn node, vị trí marker (local của node đó), kiểu nắm, `pick_up`, lý do.
5. **Test mới** `game/tests/player/test_ch2_4_hand_targets.gd`, theo mẫu `test_ch1_hand_targets.gd`:
   - mỗi đồ nhóm 1 "dùng tay" có đúng một `HandTarget`, đúng `grip` và `pick_up`, kiểm **ở vị trí thật chương đặt** (instance chương, `auto_start = false`, như test T-228);
   - marker trong hoặc sát (≤ 5 cm) khối va chạm của chính đồ đó, cao 0,2–1,9 m so với sàn nơi đặt. Đồ nào cần ngoại lệ thì ghi rõ trong test và Handoff, **hỏi chủ dự án** như T-228 đã làm, không tự nới giới hạn chung;
   - đồ trong bảng "không gắn" vẫn trả `hand_target() == null`;
   - người chơi không có thân vẫn dùng mọi đồ như cũ (test chương 2–4 cũ đạt).

## Được phép sửa
- `game/scenes/interaction/*.tscn` của đồ nhóm 1: chỉ thêm node `HandTarget`.
- `game/scripts/interaction/*.gd` của đồ nhóm 1: chỉ phần tạo hoặc đặt `HandTarget`.
- `game/tests/player/test_ch2_4_hand_targets.gd` (mới).
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa `player.gd`, `player_body.gd`, `hand_target.gd`, `door_handles.gd`, core (`game/scripts/core/`, kể cả `ch3_use.gd`, director), scene level (`game/scenes/levels/`), scene chương (`game/scenes/main/`), cảnh thử `graphics_pilot/`.
- Không đổi luật, lời thoại, thời gian, cách chơi; không đổi khối va chạm, vùng bấm của đồ.
- Không chạy bot, không đo FPS, không tiêu credit Tripo.

## Checklist hoàn thành
- [x] Bảng kiểm kê đủ đồ chương 2, 3, 4 trong Handoff, chia nhóm 1/2/3
- [x] `HandTarget` cho mọi đồ nhóm 1 dùng tay, đúng kiểu nắm
- [x] Đề xuất vị trí, kiểu nắm cho nhóm 2 và 3 trong "Yêu cầu thay đổi"
- [x] `test_ch2_4_hand_targets.gd` đạt
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot, `AGENTS.md` mục 4)
- [x] Handoff trung thực, có commit hash

## Cách kiểm tra
- Khi đang làm: `pwsh tools/test.ps1 -Filter hand_targets`. Full test và check trước khi commit.
- Integrator đọc bảng, gắn marker nhóm 2 vào core theo đề xuất; chụp ảnh tay chạm khi đưa thân vào chương.

## Handoff (agent điền)

### Phiên 07–08/11/2026 — lane A

- Nhánh: `lane-a/T-231-ch2-4-hand-targets`, gốc `origin/main` tại `85598c6`. Đã đọc lại AGENTS D-141, STATUS và Review T-228 (D-140).
- Đã thêm marker vào 6 scene: carry_item, shower_screen, shower_choice, stuck_door, iron_bar, bed_slat. fake_search_spot dùng marker kế thừa từ search_spot, chỉ đặt lại vị trí, không thêm bản thứ hai. Không sửa script gameplay, collision, thời gian hay director.
- Test mới instance cả ba chương với `auto_start = false`, chờ director/deferred/physics đặt đồ xong: chương 2 có 28, chương 3 có 28, chương 4 có 33 đồ nhóm 1 dùng tay. Kiểm đúng một marker, grip/pick_up, khoảng cách tới collision trong không gian thế giới, độ cao và các loại bị loại trừ. Có kiểm 7 thanh sắt mỗi chương 3/4: 6 do director tạo và 1 ở quầy thư viện.
- `pick_up = false` cho vải và thanh sắt: thuộc tính này của HandTarget là luồng nâng giấy lên mắt rồi chờ đóng tài liệu; CarryItem tự quản lý cầm/thả/tiêu thụ, IronBar tự trao vũ khí. Chỉ giấy/thẻ kế thừa dùng `pick_up = true`.
- Phần đặt marker mới không dùng mã cứng theo spot_id hoặc so sánh kích thước shape. Tên anchor trong test chỉ xác định danh sách và ngoại lệ đã duyệt; logic T-228 dùng chung không sửa trong task này.
- Commit triển khai: **`19c0f4601ee0299e5422cd2eb5e5452479e6ed46`** — `T-231: Add chapter two to four hand targets and placement tests`. Handoff ở commit tài liệu kế tiếp. Fetch cuối phiên ngày 08/11 xác nhận `origin/main` vẫn là `85598c6`; không cần rebase.

### Bảng kiểm kê nhóm 1

Đường dẫn tính từ gốc chapter. Viết tắt `R = Floor4/Room407/Anchors`, `C = Campus/Anchors/Ch4/Room407`, `D = ChapterNDirector`. Scene nhóm 1 ở `game/scenes/interaction/`, script ở `game/scripts/interaction/`; cột tên rút gọn ghi scene/script chính. power_strip_switch nằm trong power_strip.tscn; công tắc bàn dùng desk_lamp_switch.tscn kế thừa light_switch; fake_search_spot kế thừa search_spot. Vị trí là local của Interactable, đơn vị mét. Các dòng dùng chung đều được kiểm lại trong từng chương, không suy từ test chương 1.

| Chương | Đồ / anchor hoặc node | Scene/script | Nhóm | Dùng tay, grip / pick_up, vị trí |
|---|---|---|---|---|
| 2/3/4 | Giấy Đạt: DatNote; thẻ Đạt: DatNote + (0,0,.22) | readable | 1 | Có; PINCH / true; mép phải theo size |
| 2/3/4 | Lịch Phúc: PhucBooks + (.12,-.25,0); thẻ Phúc: PhucCard | readable | 1 | Có; PINCH / true; mép phải theo size |
| 2/3/4 | Ảnh Việt: VietPhoto + (-.001,-.05,.142); thẻ Việt: VietLaptop + (.27,-.148,.03) | readable | 1 | Có; PINCH / true; mép phải theo size |
| 2/3/4 | Ảnh nhóm: TeamPhoto + (.062,.1,.05); tập nhạc: GuitarSongbook | readable | 1 | Có; PINCH / true; mép phải theo size |
| 2/3/4 | R/VietLocker/SearchVietLocker | search_spot | 1 | Có; HOOK / false; (-.06,0,.01), giữ T-228 |
| 2/3/4 | R/PhucMattress/SearchPhucMattress | search_spot | 1 | Có; HOOK / false; (-.1,-.105,0), giữ T-228 |
| 2/3/4 | R/TrashBin/SearchTrashBin | search_spot | 1 | Có; HOOK / false; (.13,.18,0), giữ T-228 |
| 2/3/4 | R/WallKnock406/WallKnock406 | wall_knock | 1 | Có; GRIP / false; (-.1,0,0) |
| 2/3/4 | R/PowerStrip/PowerStripInteract/Switch1, Switch2, Switch3 | power_strip_switch | 1 | Có; PINCH / false; (0,0,-.03) mỗi nút |
| 2/3/4 | R/LanBlueEnd/Cable_blue; R/LanGrayEnd/Cable_gray | lan_cable | 1 | Có; PINCH / false; (0,.015,0) |
| 2/3/4 | R/LanWallPort/LanSocket | lan_socket | 1 | Có; PINCH / false; (0,0,.02) |
| 2/3/4 | R/DeskLampSwitch/DeskLampSwitch | light_switch | 1 | Có; PINCH / false; theo bounds đèn thật bằng code T-228 |
| 2/3/4 | Floor4/Door407/Pivot/DoorLatch407 | door_latch | 1 | Có; GRIP / false; (-.78,1.05,-.19) |
| 2/3 | D/DatLocker, lấy vị trí R/DatLocker | puzzle_station | 1 | Có; PINCH / false; (.1,0,0). Chương 4 không tạo station này |
| 2 | R/RagSpot/Carry_rag | carry_item | 1 | Có; PINCH / false; (0,.02,0), kẹp vải |
| 2 | R/TowelSpot/Carry_towel | carry_item | 1 | Có; PINCH / false; (0,.02,0), kẹp vải |
| 2 | R/ShirtSpot/Carry_shirt | carry_item | 1 | Có; PINCH / false; (0,.02,0), kẹp vải |
| 2 | R/ShowerScreen/Wipe | shower_screen | 1 | Có; PINCH / false; (0,0,.02) trên mặt màn. PINCH là độ cuộn ngón nhỏ nhất hiện có; chưa có pose bàn tay mở chuyên lau |
| 2 | R/ShowerYes/Choice | shower_choice | 1 | Có; PINCH / false; (0,0,.02), chạm mặt nút |
| 2 | R/ShowerNo/Choice | shower_choice | 1 | Có; PINCH / false; (0,0,.02), chạm mặt nút |
| 2 | Floor4/Room407/Extension/BathroomDoor/StuckDoor | stuck_door | 1 | Có; GRIP / false; (.35,.90,.05), điểm nắm tay tì/đập lên cánh cửa, không thêm cơ chế đập |
| 3/4 | D tạo tại Campus/Anchors/BarSpawns/B01…B06 | iron_bar | 1 | Có; GRIP / false; (0,.02,-.22), nắm phần thân thanh, kiểm sau raycast đặt xuống |
| 3/4 | Campus/Library/Counter/IronBar | iron_bar | 1 | Có; GRIP / false; (0,.02,-.22), prefab lane A dù instance nằm trong level |
| 4 | C/Slat1/BedSlat1 | bed_slat | 1 | Có; HOOK / false; (0,-.0175,.70), mép dưới phía trước tấm thật |
| 4 | C/Slat2/BedSlat2 | bed_slat | 1 | Có; HOOK / false; (0,-.0175,.70) |
| 4 | C/Slat4/BedSlat4 | bed_slat | 1 | Có; HOOK / false; (0,-.0175,.70) |
| 4 | C/FakeLocker/SearchLocker | fake_search_spot / search_spot | 1 | Có; HOOK / false; (0,0,0) |
| 4 | C/FakeCeiling/SearchCeiling | fake_search_spot / search_spot | 1 | Có; HOOK / false; (0,0,0), dưới tấm trần 2,25 cm |
| 4 | C/FakeVent/SearchVent | fake_search_spot / search_spot | 1 | Có; HOOK / false; (0,0,0), sát nan thông gió |
| 2/3/4 | R/Bunks/Bunk1…Bunk4/Bunk1…Bunk4; các HideSpot | bunk_spot / hide_spot | 1 | Không: leo/nằm/nấp thuộc phần thân T-227 |
| 2 | R/Gag1/GagSpot, R/Gag2/GagSpot, R/Gag4/GagSpot | gag_spot | 1 | Không: động tác bịt miệng thuộc T-227 |
| 2 | R/ShowerStall/ShowerStallArea | shower_stall | 1 | Không: vùng đứng Area3D, không phải Interactable |
| 2/3 | D/ChargerSocket; các StoryTrigger | core/story_trigger | 2 | Không: trigger cốt truyện; chương 4 không tạo socket này |
| 2/3/4 | Nhân vật, xác sống, horde, vùng scare/thoát | entity/core/level | 1/2/3 | Không: không phải thao tác tay lên đồ; không gắn marker |

Tám giấy/thẻ dùng vị trí marker local `(max(0, size.x/2-.015), 0, .0015)` và trục giấy không xoay. Không có giấy Khoa được tạo ở trạng thái khởi tạo chương 2–4. Các sách/giấy trang trí còn lại trong level không có Interactable, không tự biến thành đồ nhặt.

### Ngoại lệ được chủ dự án duyệt

Ngày 07/11, chủ dự án trả lời: **“Giữ đồ, cho ngoại lệ riêng theo độ cao thật (đề xuất)”**. Không di chuyển đồ, không nới ngưỡng chung, không thêm ngoại lệ khoảng cách collision.

| Đồ | Độ cao marker thực / khoảng kiểm (m) | Mốc sàn |
|---|---|---|
| Carry_towel | 2,17 / [2,14; 2,19] | y = 0 |
| SearchCeiling | 2,92 / [2,90; 2,95] | y = 0 |
| SearchVent | 2,35 / [2,33; 2,38] | y = 0 |
| Thanh B03, chương 3 và 4 | 0,10 / [0,08; 0,12] | sân y = -9,9 |
| Thanh B02, B04, B05, B06, từng chương 3 và 4 | 0,02 / [0,01; 0,04], từng anchor được chỉ rõ trong test | sân y = -9,9 |

B01 được đặt trên đồ đổ, marker cao 1,02 m so với sàn sân; thanh quầy thư viện cao 0,92 m: cả hai vẫn dùng ngưỡng chung [0,2; 1,9]. Các ngoại lệ T-228/D-142 được giữ riêng: Switch1/2/3 [0,02; 0,10], hai Cable [0,005; 0,04], SearchTrashBin [0,15; 0,20], Ch1PhucCard/Ch1TeamPhoto [2,0; 2,1]; riêng SearchPhucMattress giữ ngưỡng khoảng cách 0,11 m đã duyệt (thực 0,1069 m). Mọi marker mới đều trong/sát collision ≤ 0,05 m.

### Yêu cầu thay đổi — nhóm 2 (core, chưa sửa)

Đây là đề xuất để integrator review và gắn trong task riêng. Mỗi vị trí dưới đây là local của node Use được nêu, ở trạng thái đồ/cửa ban đầu. `pick_up = false` cho các Ch3Use vì chúng hiện xử lý sự kiện/flag hoặc mở UI; không có vòng đời readable để nâng cả vùng tương tác lên mắt.

| Chương | Node (script ch3_use.gd) | Nhóm | Dùng tay / local đề xuất / grip / pick_up | Lý do và việc cần làm |
|---|---|---|---|---|
| 3, kế thừa 4 | Campus/Anchors/FireKey/Use_FireKey | 2 | Có; (-.04,.009,0); PINCH; false | Mặt trên thân chìa KeyStem, tránh răng chìa; core vẫn giữ luồng lấy chìa hiện có |
| 3, kế thừa 4 | Campus/Anchors/FireDoor/Use_FireDoor | 2 | Có; (-.06,0,.45); GRIP; false | Mặt cánh cửa đang xoay 90° so với anchor. Hiện chưa có ổ khóa/tay nắm riêng; đây là điểm tiếp xúc cánh, cần chốt hình thức tay mở khóa trước khi đưa thân vào |
| 3, kế thừa 4 | Campus/Anchors/Extinguisher2F/Use_Extinguisher2F | 2 | Có; (.03,.0275,0); GRIP; false | Mặt trên ExtinguisherHandle: tâm model lệch anchor +.03 theo x; không dùng tâm thân bình |
| 3 | Campus/Anchors/FireAlarm1F/Use_FireAlarm1F | 2 | Có; (0,0,.03); PINCH; false | Mặt trước hộp nút báo cháy do director tạo; không có node này ở chương 4 |
| 4 | Campus/Anchors/Ch4/ReadingDesk/Use_ReadingDesk | 2 | Có (đề xuất); (.20,.05,0); PINCH; false | Mép cuốn sách trên ReadingTable13/Book, mở UI đối chiếu hiện có. Cần kiểm động tác thân khi tích hợp |
| 4 | Campus/Anchors/Ch4/MapBoard/Use_MapBoard | 2 | Không; local/grip/pick_up không áp dụng | Đọc bảng bản đồ treo tường, hiện chỉ mở tài liệu; giữ như thao tác nhìn, không nhấc bảng |
| 4 | Campus/Anchors/Ch4/LibrarianSeat/Use_LibrarianSeat | 2 | Có (đề xuất); (.20,.04,0); PINCH; false | Vị trí lấy nhật ký trên mặt ghế. Scene hiện chỉ có ghế, chưa có mesh nhật ký riêng: B cần đặt model rồi core bám marker vào mép model, tọa độ này là điểm đề nghị ban đầu |
| 4 | Campus/Library/BackDoor/Use_BackDoor | 2 | Có; (.75,0,-.09); GRIP; false | Trùng tâm Handle khi đóng. Khi mở phải đi theo Hinge/Handle; cần core kết nối marker level với Use, không để marker đứng yên ở vị trí đóng |

Các Use kế thừa chương 3 vẫn được tạo trong chương 4 dù có thể bị vô hiệu hóa theo tiến trình. Test xác nhận tất cả node kể trên tồn tại ở chương tương ứng và vẫn chưa có HandTarget, đúng ranh giới phạm vi.

### Yêu cầu thay đổi — nhóm 3 (level, chưa sửa)

Vị trí là local của node ghi trong bảng; các model cùng thao tác với Use nhóm 2 **chỉ cần một bộ marker**, không gắn trùng cả proxy lẫn model. Các dòng không dùng tay ghi rõ không áp dụng tọa độ/grip/pick_up.

| Chương | Node / scene hoặc script | Nhóm | Dùng tay / local đề xuất / grip / pick_up | Lý do |
|---|---|---|---|---|
| 2/3/4 | Floor4/Door407/Pivot/HandlePivot/LeverFront; floor4.gd/door407.gd | 3 | Có; (.06,0,.056); GRIP; false | Theo TRIPO_GRIP_POINT, đặt dưới lever sau khi reparent để theo cửa và tay nắm |
| 2/3/4 | Floor4/Door407/Pivot/HandlePivot/LeverBack; floor4.gd/door407.gd | 3 | Có; (.06,0,.056); GRIP; false | Mặt còn lại; chọn marker gần người chơi. Không lấy marker của DoorLatch407 thay tay nắm (Review T-228) |
| 2 | Floor4/Room407/Extension/BathroomDoor; bathroom_door | 3 | Không thêm bộ riêng | Điểm dùng tay là StuckDoor nhóm 1 đã gắn; hình học cánh theo Pivot, trạng thái mở/đập vẫn do director điều khiển |
| 2/3/4 | Floor4/Room407/Extension/BalconyDoor; balcony_door | 3 | Không; không áp dụng | Cửa hình học không có Interactable trực tiếp; không thêm hành vi mở tay ngoài card |
| 3/4 | Campus/BuildingB/KeyStem; campus/building_b.tscn | 3 | Có; (-.04,.009,0); PINCH; false | Model của Use_FireKey; một điểm bám chung |
| 3/4 | Campus/BuildingB/ExtinguisherHandle; campus/building_b.tscn | 3 | Có; (0,.0275,0); GRIP; false | Model của Use_Extinguisher2F; mặt trên tay nắm |
| 3/4 | Campus/BuildingB/FireDoor/Leaf; campus/door.gd | 3 | Có; (1.45,-.10,-.06); GRIP; false | Cùng điểm thế giới với đề xuất Use_FireDoor khi cửa đóng; cần theo Leaf sau khi xoay |
| 4 | Campus/Library/BackDoor/Hinge/Handle; library/library.tscn, room_door.gd | 3 | Có; (0,0,0); GRIP; false | Điểm bám cho Use_BackDoor; đi cùng Hinge khi mở/đóng |
| 4 | Campus/Library/ReadingTable13/Book; library/library.tscn | 3 | Có; (.20,.05,0); PINCH; false | Cùng điểm với Use_ReadingDesk, sách ở tầng có sàn y = -6,6 |
| 4 | Campus/Library/LibrarianChair/Seat; library/library.tscn | 3 | Có (đề xuất); (.20,.04,0); PINCH; false | Chỗ đặt model nhật ký như đề nghị core; hiện là ghế trống, chưa khẳng định tay chạm nhật ký |
| 4 | Campus/Library/MapBoard; library/library.tscn | 3 | Không; không áp dụng | Bảng chỉ đọc, tương ứng Use_MapBoard |
| 3/4 | Các RoomDoor dưới BuildingB/Floor2, Floor3, cửa 203, các cửa phòng hành lang; room_door.gd | 3 | Không; không áp dụng | Core/ZombieDoor điều khiển tự mở/phá cửa, không có thao tác tay của người chơi. BackDoor thư viện đã tách thành dòng riêng |
| 3/4 | Campus/BuildingB/MainDoor và cửa trước thư viện | 3 | Không; không áp dụng | Hình học bị chặn/xích, không có Interactable mở tay |
| 4 | C/Door; ch4/door407_proxy.gd | 3 | Không; không áp dụng | Proxy hình học/trạng thái cửa, không thêm tương tác thứ hai cạnh Floor4/Door407 |
| 4 | C/Slat1, Slat2, Slat4/Hinge/Board; C/CeilingPanel; C/VentFrame | 3 | Không thêm bộ riêng | Đã có điểm dùng tay trên BedSlat/Search nhóm 1 do director đặt; tránh trùng marker |
| 4 | HospitalRoom (hospital/hospital_room.tscn, hospital_room.gd) | 3 | Không; không áp dụng | Cảnh tỉnh dậy, camera/NPC/giường/đạo cụ điện ảnh, không có Interactable. Test gọi _show_hospital và kiểm không có marker hay Interactable |

### Còn dở / phần chưa kiểm

- Phần lane A nhóm 1 đã xong; nhóm 2/3 chỉ kiểm kê và đề xuất theo yêu cầu card, chưa triển khai ngoài phạm vi.
- Chưa chơi thử/chụp hình tay có thân trong chương 2–4, chưa kiểm IK/với cao/cúi nhặt/thả vải/hướng lòng bàn tay. Bản production hiện không gắn PlayerBody; test xác nhận điều này. Các ngoại lệ độ cao giữ đồ hiện có, không khẳng định nhân vật đứng yên với tới được.
- Khi tích hợp T-227, cần giữ đúng input giữ E của lau màn (1 giây), tìm đồ và lật thanh giường (5/8 giây theo script). PINCH hiện không phải pose bàn tay mở; cần động tác lau/đập riêng nếu muốn tay thể hiện đúng động tác. Không đổi enum hay luật thao tác trong T-231.
- Model nhật ký trên ghế và hình thức tay mở khóa cửa cứu hỏa cần integrator/chủ dự án chốt trước khi triển khai nhóm 2/3. Đây là đề xuất còn cần review, không phải thay đổi thiết kế đã tự áp dụng.
- Blocked: không có cho phần việc được phép của lane A. Full test/check đã đạt; các đề xuất nhóm 2/3 và phần kiểm hình ảnh còn lại được ghi riêng ở trên.

### Kiểm tra và log

- `pwsh tools/test.ps1 -Filter hand_targets`: `RESULT: 6 passed, 0 failed` (3 test T-228 + 3 test mới), exit 0; log `build/t231/hand_targets.log`.
- Lần chạy chọn lọc đầu phát hiện thiếu thanh sắt thư viện trong số đếm, GagSpot chưa được loại trừ và ngưỡng thanh sát sàn chưa khớp vị trí sau physics; đã sửa test theo kiểm kê và quyết định ngoại lệ, chạy lại đạt như trên. Không sửa placement/collision để né test.
- Full `pwsh tools/test.ps1`: **`RESULT: 860 passed, 0 failed`**, exit 0; hoàn tất 20:14:28 ngày 07/11, log `build/t231/full-test.log`. Bao gồm test marker mới và test tương tác/chương 2–4 cũ.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0; hoàn tất 20:27:26 ngày 07/11, log `build/t231/check.log`. Chạy sau full test trong cùng lượt; mã thoát lưu ở `build/t231/validation-exits.txt`.
- Lượt Godot lấy khóa bằng CreateNew lúc 19:53:03 +07:00 ngày 07/11; đã giải phóng trong finally sau cả hai lệnh. Đã trả lại `game/default_bus_layout.tres`. Không chạy bot/FPS/Tripo. Log chỉ lưu build/, không commit.

## Review (integrator, 08/11/2026)
- **Đạt, merge vào `main`** (merge `a9f4e8b`). Đúng phạm vi lane A: 6 scene đồ dùng thêm `HandTarget`, `fake_search_spot` chỉ chỉnh marker kế thừa, test mới `test_ch2_4_hand_targets.gd` instance thật cả ba chương. Không sửa script gameplay, core hay level.
- Kiểu nắm khớp enum (`GRIP=0, PINCH=1, HOOK=2`); marker nằm trong hoặc sát collision. `pick_up = false` cho vải và thanh sắt là đúng: hai loại này tự quản lý việc cầm.
- Ngoại lệ độ cao ghi đúng câu trả lời của chủ dự án (D-142), có khoảng kiểm riêng từng đồ.
- Bảng nhóm 2 (Ch3Use) và nhóm 3 (level) rõ, có lý do; integrator dùng khi đưa thân vào chương. Hai điểm cần chủ dự án chốt trước khi gắn: hình thức tay mở cửa cứu hỏa, và model nhật ký trên ghế thủ thư.
- Lưu ý cho T-227: `SearchCeiling` (2,92 m) và `SearchVent` (2,35 m) cao hơn tầm nhón chân của thân; cần hỏi chủ dự án cách với (trèo lên đồ, hay dời chỗ) khi đưa thân vào chương 4.
- Integrator chạy lại sau merge A + C: full `RESULT: 863 passed, 0 failed`, check `RESULT: check 0 error(s)`.
