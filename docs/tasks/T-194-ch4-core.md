# T-194 — Chương 4: hợp đồng chung, kịch bản, luồng 5 khu, ghép (core)
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude
- Phụ thuộc: `docs/design/CH4_DESIGN.md` (D-067). Các lane xem **mục "Hợp đồng chung" dưới đây** trước khi làm card của mình (T-195 A, T-196 B, T-197 D, T-198 E).
- **Hạn đề xuất:** hợp đồng 2026-10-07 (xong); các lane xong 2026-10-10; ghép 2026-10-11; chơi thử khoảng 2026-10-12.

## Việc của core
- **Hợp đồng chung (xong 2026-10-07):** EventBus mục "Chapter 4" (`ch4_compare_opened`, `ch4_sentence_marked`, `ch4_compare_result`, `phone_decoy_thrown`, `door_damage_changed`, `bed_slat_flipped`, `survivor_form_assembled`, `blood_name_*`, `fade_message_*`, `ch4_ending`); tên scene, node, anchor ở bảng dưới.
- **Kịch bản** `docs/design/ch4/build_ch4_script.py`: loa, cuộc gọi (Ngư, Minh Nhật), lời y tá, lý do chết `DEATH_CH4_*`, giấy tờ (bản đồ trường, nhật ký thủ thư, mảnh phiếu), luật vòng 5 để đối chiếu, giọng eSpeak (nhanh ×1,25).
- **Luồng** `scripts/core/chapter4_director.gd` (kế thừa `Chapter1Director` như chương 2 và 3) và `scenes/main/chapter4.tscn` (Floor4 + Campus + UI): 5 khu, checkpoint `ch4_split`, `ch4_library`, `ch4_return`, `ch4_407`, đợt xác theo khu, cầu thang đông xác, cuộc gọi theo mốc, hai kết, `App.CHAPTER_SCENES[4]`, `Progress.unlock(5)` không cần (chương cuối).
- **Phán quyết:** dòng luật bị gạch (`ch3_r5_2` đúng, `ch3_r5_1`/`3` sai, không phạt); tên gõ (so "Trần Trung" bỏ dấu, hoa thường, thừa khoảng trắng); tin nhắn 12 giây (đúng nếu chứa "vat giuong" sau khi bỏ dấu, hoa thường); cửa 407 chịu 90 giây, cửa phụ thư viện 75 giây; hạn riêng mỗi khu.
- **Ghép** T-195…T-198, test, export; sau đó lane C điền profile bot (T-199).

## Hợp đồng chung

### Scene và anchor (lane B dựng, core đọc theo tên). Gốc `Campus/Anchors/Ch4/` trừ khi ghi khác
| Tên | Loại | Ý nghĩa |
|---|---|---|
| `Start_split` | Marker3D | cửa phía tây nhà ăn, ngoài trời (khu 1, `ch4_split`) |
| `Start_library` | Marker3D | trong thư viện gần cửa phụ (`ch4_library`) |
| `Start_return` | Marker3D | sảnh tầng 1 nhà B, trước phòng quản lý (`ch4_return`) |
| `Start_407` | Marker3D | trong phòng 407 cạnh cửa (`ch4_407`) |
| `LibraryZombieSpawn/S01…S06` | Marker3D | ngoài cửa phụ thư viện, nơi xác tụ lại đập cửa |
| `ReadingDesk` | Marker3D | bàn đọc tầng 2, nơi mở sổ quy tắc (tab Đối chiếu) |
| `MapBoard` | Marker3D | bản đồ trường treo tường tầng 1 (có khoanh mờ nhà A, nhà B) |
| `Counter`, `LibrarianSeat`, `ScareShelf3F`, `ThrownBook3F` | Marker3D | quầy mượn (thanh sắt), chỗ thủ thư xác, kệ bật sách, kệ rơi xác |
| `StairCrowd/L1_01…L1_03`, `L2_01…L2_03`, `L3_01…L3_03`, `L4_01` | Marker3D | điểm xác kẹt trên cầu thang chính, 10 điểm |
| `Room407/Slat1`, `Slat2`, `Slat4` | Marker3D | vạt giường 1, 2, 4 (đứng gần là lật được) |
| `Room407/FakeLocker`, `FakeCeiling`, `FakeVent` | Marker3D | 3 chỗ tìm giả |
| `Room407/Door` | Node3D | cửa 407 theo hợp đồng cửa phá (xem dưới) |

- Cửa phá được: node có **`room: StringName`**, **`is_open: bool`**, **`set_open(bool)`**, con **`Blocker`** (`StaticBody3D`, lớp 1) và biến **`blocker`**, thuộc group **`room_doors`** (giống `RoomDoor` của T-190). Core gắn `ZombieDoor` và đặt thời gian chịu. Hai cửa mới: **`library_back`** (`Campus/Library/BackDoor`) và **`407`**.
- **Bệnh viện:** `res://scenes/levels/hospital/hospital_room.tscn`: gốc `HospitalRoom` có `Bed_Trung`, `Bed_Nhat`, `Bed_Ngu` (mỗi giường có con `Card` là `Marker3D` để gắn thẻ tên), `Nurse1`, `Nurse2`, `Camera_Wake` (Camera3D nơi Trung mở mắt), `MonitorAudio` (Marker3D để đặt âm máy theo dõi).
- **Cảnh chính:** `res://scenes/main/chapter4.tscn` (core); nhân vật hai bạn đã có ở `res://assets/models/campus/nhat.tscn`, `ngu.tscn`.

### Cờ GameState và hành động
| Tên | Ai ghi | Ý nghĩa |
|---|---|---|
| `ch4_phone_charges` (int) | core | số lần đổ chuông còn lại (3 lúc đầu) |
| `ch4_compare_enabled` (bool) | core | bật tab "Đối chiếu" (đặt ở thư viện, tại `ReadingDesk`) |
| `ch4_compare_done` (bool) | core | đã gạch chân đúng dòng luật |
| `ch4_slats_found` (int, 0..3) | core | số mảnh phiếu đã tìm |
| `ch4_form_ready` (bool) | core | đã ghép phiếu |
| `ch4_signed` (bool) | core | đã viết tên đúng |
| `ch4_message_ok` (bool) | core | tin nhắn cuối đúng ("vạt giường") |
| Input action `throw_phone` (phím G) | core thêm vào `GameInput` | lane A dùng để ném điện thoại |

### Cảnh chết mới (D-042, `player_death_started`)
| Kind | Lý do (`DEATH_CH4_*`) | Camera | Máu | Âm |
|---|---|---|---|---|
| `zombie_grab` | `GRABBED`, `STAIRS`, `LIBRARY` | có sẵn | có sẵn | có sẵn |
| `door_burst` (mới) | `DOOR` (cửa 407 vỡ) | A | D | E |

### Mã jumpscare (cho lane E; core phát `scare_triggered`)
`librarian_rise`, `books_fall`, `shelf_corpse`, `back_door_hit`, `knife_pull`, `stairs_turn`, `hall_lights`, `door_hand`, `neck_hand`, `monitor_skip`.

### Chữ hiển thị
Mọi chữ qua `game/localization/strings.csv` (vi và en). **Core** thêm `SPK_CH4_*`, `CALL_`/chat, `NEAR_`, `DOC_CH4_*`, `DEATH_CH4_*`, `RULE_*`. **Lane D** thêm `UI_CH4_*`. **Lane A** thêm `PROMPT_CH4_*`. Key mới của lane khác thì ghi vào Handoff.

## Handoff
### Phiên 2026-10-07 (Claude): hợp đồng chung, thiết kế duyệt
- Thiết kế `CH4_DESIGN.md` tạm duyệt (D-067), EventBus mục "Chapter 4", card T-195…T-198 giao các lane. Chưa viết kịch bản, luồng.
- **Chưa làm:** `build_ch4_script.py`, `chapter4_director.gd`, `chapter4.tscn`, input `throw_phone`, ghép.
