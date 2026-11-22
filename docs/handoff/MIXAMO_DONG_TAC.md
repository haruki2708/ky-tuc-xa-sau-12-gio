# Phiếu tải chuyển động Mixamo (D-189)

- Kế hoạch: [`docs/design/MOTION_UPGRADE_PLAN.md`](../design/MOTION_UPGRADE_PLAN.md). Người tải: integrator qua Chrome của chủ dự án (tài khoản Adobe của chủ dự án), hoặc chủ dự án tự tải.
- Nơi lưu: `D:\GAME_DEMO\build\graphics\staging\mixamo\` (**không commit**, D-189). Thư mục con `trung\` và `manager\`.
- Tên clip trên Mixamo chưa được kiểm (integrator chưa mở được thư viện lúc viết phiếu). Cột "Từ khoá" là để tìm; chọn bằng mắt theo cột "Tiêu chí". Tải xong ghi tên clip thật vào cột cuối.

## Thiết lập khi tải (mọi clip)
- Nhân vật: hình nhân mặc định của Mixamo (không tải nhân vật của dự án lên).
- Format **FBX Binary (.fbx)**; Skin **Without Skin**; **30** khung/giây; Keyframe Reduction **none**.
- Clip di chuyển (đi, chạy, ngồi xổm đi, đi ngang, đi lùi): tích **In Place**.
- Các thanh trượt (Overdrive, Character Arm-Space…) để mặc định, trừ khi tay xuyên thân thì nới Arm-Space.
- Đặt tên file theo cột "File".

## Trần Trung (`trung\`)

| File | Từ khoá | Tiêu chí | Tên clip đã tải |
|---|---|---|---|
| `idle.fbx` | idle, breathing idle | đứng thẳng, hai tay buông, đầu gần như không lắc, lặp được | |
| `idle_scared.fbx` | nervous, scared idle, looking around | thở gấp nhẹ, không vung tay | |
| `walk_fwd.fbx` | walking | đi thường, chậm vừa, đầu êm | |
| `walk_back.fbx` | walking backwards | cùng nhịp với đi tới | |
| `walk_left.fbx`, `walk_right.fbx` | left strafe walk, right strafe walk | bước ngang, thân hướng trước | |
| `run_fwd.fbx` | jog, running | chạy vừa, không phải chạy nước rút | |
| `walk_start.fbx`, `walk_stop.fbx` | start walking, stop walking | ngắn dưới 1 giây | |
| `turn_left.fbx`, `turn_right.fbx` | left turn, right turn 90 | xoay tại chỗ có bước chân | |
| `crouch_idle.fbx` | crouch idle, crouching idle | ngồi xổm thấp, tay tự do | |
| `crouch_fwd.fbx`, `crouch_back.fbx`, `crouch_left.fbx`, `crouch_right.fbx` | crouched walking, crouch walk back/left/right, sneaking | khom thấp, êm | |
| `stand_to_crouch.fbx`, `crouch_to_stand.fbx` | stand to crouch, crouch to stand | dưới 1 giây | |
| `pick_up.fbx` | picking up, pick up object | cúi nhặt đồ dưới sàn bằng tay phải rồi đứng lên | |
| `reach_table.fbx` | taking item, grabbing from table/shelf | đứng, tay phải với lấy đồ ngang hông | |
| `open_door.fbx` | opening door, open door inwards/outwards | tay phải, thân đi theo | |
| `push.fbx` | pushing, shoulder barge, bash door | hích vai vào cửa | |
| `carry_idle.fbx`, `carry_walk.fbx` | carrying, holding box walk | bê đồ trước bụng | |
| `stairs_up.fbx`, `stairs_down.fbx` | walking up stairs, descending stairs | nhịp đều | |
| `get_up.fbx` | getting up, stand up from lying | từ nằm ngửa | |
| `sit_idle.fbx` | sitting idle | ngồi mép giường | |
| `swing.fbx` | melee swing, bat swing, great sword slash | vung ngang một tay hoặc hai tay (thanh sắt, chương 3) | |
| `hit_back.fbx` | hit reaction, stumble backwards | bị đẩy lùi một hai bước | |

## Quản lý (`manager\`)

| File | Từ khoá | Tiêu chí | Tên clip đã tải |
|---|---|---|---|
| `stand.fbx` | standing idle, menacing idle | đứng im, nặng nề, tay phải buông cầm dao | |
| `walk.fbx` | slow walk, creeping walk, zombie-free "walking" | chậm, đều, thân thẳng; không lết kiểu xác sống | |
| `ask.fbx` | hands on hips, standing arguing, talking | chống nạnh hoặc cúi nhìn giường (D-120 đang chống nạnh) | |
| `look_around.fbx` | looking around, searching | đứng soát phòng, quay đầu chậm | |
| `turn_left.fbx`, `turn_right.fbx` | left turn, right turn | xoay tại chỗ có bước chân | |
| `open_door.fbx` | opening door | tay trái (hoặc lật gương sau), thân đi theo | |
| `slash.fbx` | downward slash, stabbing, knife attack, standing melee attack downward | bổ dao từ trên xuống, tay phải, về lại dáng đứng | |
| `kill.fbx` | stab, finishing attack | một cú dứt khoát, dừng thấp | |
| `lunge.fbx` | charge, run with sword/knife, sprint | lao tới, dao trong tay phải | |

## Clip đã chọn trên Mixamo (integrator rà thư viện 22/11 qua Chrome của chủ dự án)
Ghi theo dạng `tên clip >> mô tả trên Mixamo` (từ khoá tìm). Nhiều clip trùng tên, nên phải khớp cả mô tả. Clip di chuyển tích In Place.

**Trần Trung**
- `idle`: Breathing Idle >> Breathing Idle (breathing idle) — **đã tải 22/11**; dự phòng: Neutral Idle >> Neutral Idle (idle)
- `idle_scared`: Nervously Look Around >> Nervously Looking Around Left To Right - Loop (nervous); Look Over Shoulder >> Quick Nervous Look Over Right Shoulder (nervous)
- `walk_fwd`: Standard Walk >> Standard Walk (standard walk); dự phòng: Walking >> Careful Walk (walk)
- `walk_back`: Walking Backwards >> Walking Backwards (walking backward)
- `walk_left`, `walk_right`: Left Strafe Walking >> Strafe Walking To The Left; Right Strafe Walking >> Strafe Walking To The Right (strafe)
- `run_fwd`: Jogging >> Jogging (jog); dự phòng: Standard Run >> Standard Running (jog)
- `walk_start`, `walk_stop`: Start Walking >> Walking From Standing; Stop Walking >> Walking To Standing Idle (walking)
- `turn_left`, `turn_right`: Left Turn 90 >> Standing Left Turn; Right Turn 90 >> Standing Right Turn (turn)
- `crouch_idle`: Crouch Idle >> Crouch Idle (crouch)
- `crouch_fwd/back/left/right`: Crouch Walk Forward >> Walking Forward While Crouched; Crouch Walk Back >> Walking Backwards While Crouched; Crouch Walk Left >> Walking Left While Crouched; Crouch Walk Right >> Walking Right While Crouched (crouch)
- `stand_to_crouch`, `crouch_to_stand`: Crouching >> Crouching From Standing Position; Crouched To Standing >> Crouch To Stand Transition (crouch)
- `pick_up`: Picking Up Object >> Picking Up An Object With One Hand; Picking Up >> Picking Up An Object (picking up)
- `open_door`: Opening Door Inwards >> Male Walking And Opening A Door Inwards; Open Door Outwards >> Open Door Outwards While Walking; Opening >> Attempting To Open A Door (cửa kẹt, chương 2) (door)
- tủ: Opening >> Opening Cabinet Door; Closing >> Closing Cabinet Door (door)
- nút tắm: Button Pushing >> Pushing A Button With The Right Hand (push)
- `push`: Pushing >> Pushing An Object Forward (push). Không có clip hích vai; phần này giữ code tự tính.
- `carry_idle`, `carry_walk`: Box Idle >> Carrying A Box; Holding Walk >> Holding An Object While Walking (carry)
- `stairs_up`, `stairs_down`: Ascending Stairs >> Walking Up A Set Of Stairs; Descending Stairs >> Walking Down A Set Of Stairs (stairs)
- `get_up`: Getting Up >> Getting Up From Back (getting up)
- `sit_idle`: Sitting Idle >> Sitting With Breathing Idle (sitting); đứng dậy: Stand Up >> Standing Up From Seated Position (standing up)
- `swing`: Standing Melee Attack Horizontal >> Right To Left Attack With Axe (melee attack); Heavy Weapon Swing >> Two Handed Heavy Weapon Swing (swing)
- `hit_back`: Hit Reaction >> Hit Reaction (hit reaction)
- cầm điện thoại (tham khảo dáng tay): Walking While Texting >> Male Walking While Texting On A Smartphone (walking)

**Quản lý**
- `stand`: Idle >> Standing Idle (idle); Knife Idle >> Knife On The Rear Hand, Reverse Grip (knife)
- `walk`: Walking >> Male Brutal Walk (walk); dự phòng: Standard Walk
- `look_around`: Looking Around >> Idle Stand Looking Around (looking around); Idle >> Looking Over Both Shoulders (shoulder)
- `ask`: chưa tìm được clip chống nạnh cho nam (chỉ có dáng nữ); còn phải tìm thêm ("talking", "arguing", "arms crossed"). Nếu không có thì giữ clip Tripo hiện tại.
- `turn_left`, `turn_right`, `open_door`: dùng chung clip của Trung.
- `slash`: Standing Melee Attack Downward >> Downward Attack With Axe (melee attack); Stabbing >> Male Knife Stab With The Rear Hand And Reverse Grip (knife)
- `kill`: Stabbing >> Male Knife Stab With The Rear Hand And Fore Grip (knife)
- `lunge`: Fast Run >> Running Fast (jog); còn phải tìm thêm ("sprint")

**Vướng khi tải (22/11):** clip đầu tải được; từ clip thứ hai, Mixamo xuất file xong nhưng file không về máy (yêu cầu tải bị trả 503). Nghi Chrome chặn "tải nhiều file tự động" của mixamo.com; chờ chủ dự án bấm cho phép.

## Sau khi tải
- Ghi tên clip thật, ngày tải vào bảng; chép sang `CREDITS.md` khi đóng gói (bước 2 của kế hoạch).
- Không commit file `.fbx`.
