# T-192 — Chương 3: khán đài sân vận động làm lại, rải đồ cho khuôn viên bớt trống
- Lane: B (**Claude Code trên web làm thay**, D-066; lane B hết token) | Trạng thái: todo | Agent: Claude Code web
- **Prompt:** `docs/handoff/web.md` §1 (cài Godot Linux, chạy test hai lượt, không chụp ảnh).
- Nhánh: `lane-b/T-192-stands-props`
- Phụ thuộc: T-183, T-189, T-190. **Đọc D-054, D-064, D-065 trong `docs/DECISIONS.md`**, card T-183 (Handoff), `art_source/campus/README.md`.

## Vì sao (chủ dự án chơi thử chương 3, 2026-10-07)
1. "Sân vận động hình như **không có khán đài**, và một khán đài chỗ ngồi nho nhỏ **bị lỗi nằm bên ngoài** sân vận động."
   Integrator đo: khán đài chính (`MainBleachers`, x 158–238, z 216–228) chỉ cao 3 m và nằm **sau hàng rào** z = 212, cách đường chạy 4 m: trong sương gần như không thấy. Khán đài phụ (`SecondaryBleachers`, x 168–228, z 108–113, 4 bậc) nằm **ngoài hàng rào phía nam** z = 120, cách sân 7 m.
2. "Map hơi rộng nên **nhiều chỗ trống trải** quá." Chủ dự án chọn **giữ kích thước** (D-054), **rải thêm đồ** (D-064). Ảnh đường từ vườn hoa ra sân vận động hiện chỉ có cây và cột đèn.

## Được phép sửa
`art_source/campus/`, `game/assets/models/` (mô hình mới, ghi CREDITS), `game/scenes/levels/campus/`, `game/tests/levels/`, card này (Handoff). Không sửa code core, lane A, lane E.

**Cảnh báo dựng map:** giữ các thay đổi đã có trên `main`: T-187 (hành lang 4 m), T-188 (khối sập), T-189 (nhà ăn, `canteen_cn.py`), T-190 (cửa phòng), D-062 (bình cứu hỏa tầng 2 ở x = 39,5), D-065 (màu trời đêm). Chạy bộ dựng xong thì xem `git diff` và chỉ giữ phần của card này.

## Yêu cầu
### 1. Khán đài
- **Khán đài chính (bắc):** sát đường chạy (mép trước khoảng z = 212,5), dài khoảng 80 m, **khoảng 16–20 bậc** (cao 6–8 m), có **mái che trên cột** và lan can; nhìn rõ từ giữa sân trong sương. Người chơi lên được từ đường chạy bằng 2–3 lối cầu thang; bậc có navigation cho xác và đồng đội (xác leo chậm do lane A tự xử lý theo độ dốc).
- **Khán đài phụ (nam):** đặt sát đường chạy phía nam (mép z khoảng 119,5), thấp hơn (6–8 bậc), có lối lên. **Bỏ khán đài nhỏ cũ ở z 108.**
- Hàng rào: thành tường thấp trước khán đài, có khe ở các lối lên.
- **Giữ 4 lối xác tràn vào** (D-053 N7). Cổng bắc và nam đang ở giữa (x 193–203) sẽ bị khán đài che: dời ra hai đầu khán đài hoặc làm đường hầm dưới khán đài, rồi dời `Anchors/ZombieSpawns/Stadium` tương ứng. Giữ tên anchor.
- **Giữ ý nghĩa anchor:** `Clues/SirenSpot` ở chỗ cao nhất khán đài chính (tiếng còi chỉ nghe khi đứng yên ở đó); `BarSpawns/B03` và ống sắt (`LoosePipe*`) ở **gầm khán đài chính**, nhặt được (core có test tia ngắm); `Start_stadium` giữ nguyên.

### 2. Rải đồ (giữ kích thước map)
Dọc mọi đường người chơi đi (nhà B → vườn hoa → đường x = 80 ra sân vận động → đường z = −15 ra cổng → sân cổng → nhà ăn) và quanh các khu:
- xe máy, xe đạp đổ; vài ô tô (một chiếc bật đèn khẩn cấp không cần); nhà để xe có mái; ki-ốt hoặc quầy nước đóng cửa; ghế đá, bồn cây, thùng rác, biển chỉ đường, bảng tin;
- đồ của người chạy loạn: ba lô, giày, dép, điện thoại vỡ, giấy tờ, khay cơm; vài **xác nằm** (chỉ là mô hình tĩnh, không phải xác sống);
- **dấu động đất** (D-053, manh mối không ai nói ra): đường nứt, cây đổ, cột đèn nghiêng hoặc đổ, kính vỡ, gạch vụn dưới chân các tòa nhà;
- hàng cây dày hơn ở hai bên đường; một vài cụm đèn đường còn sáng để có chỗ sáng chỗ tối.
- **Mật độ:** đứng ở bất kỳ điểm nào trên đường đi, trong tầm 30 m luôn thấy vài thứ đáng nhìn. Không chặn đường: mỗi tuyến giữ lối trống ít nhất 4 m; đồ lớn đăng ký `obstacle()` để navigation tránh.
- **Hiệu năng:** đồ lặp dùng `MultiMeshInstance3D`; giữ ngân sách tam giác như T-183; không thêm đèn có bóng đổ.

### 3. Test và ảnh
- Người chơi đi bộ (như test T-188): từ đường chạy lên tới bậc cao nhất khán đài chính; tới được `BarSpawns/B03`.
- Navigation: có đường từ `Start_garden` → `Start_stadium` → `Start_gate` → cửa nhà ăn; xác trong sân tới được bậc khán đài.
- `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS (trên máy cloud: không có test FAIL mới so với lượt chạy trên `origin/main`). Ảnh: integrator chụp khi review (máy cloud không có card đồ họa).
- FPS: integrator đo lại sau khi merge (cần chủ dự án cho phép).

## Checklist hoàn thành
- [x] Khán đài chính to, sát đường chạy, có mái, lên được; khán đài phụ phía nam sát sân; bỏ khán đài nhỏ cũ
- [x] 4 lối xác vào, `ZombieSpawns/Stadium` cập nhật; `SirenSpot`, `B03`, ống sắt đúng chỗ
- [x] Rải đồ dọc mọi tuyến, dấu động đất, không chặn đường
- [x] Test đi bộ, test navigation PASS; không có test FAIL mới (hai lượt)
- [x] Handoff: tọa độ mới của khán đài, cổng, anchor đã dời; số tam giác

## Handoff (agent điền)

**Claude Code web làm thay lane B, D-066.** Nhánh `lane-b/T-192-stands-props` (từ `origin/main` a00ba3c). Máy Linux cloud, Godot 4.7.2 và PowerShell 7.5.4 cài ở `~/tools`. **Chưa chụp ảnh Forward+, chưa đo FPS, chưa chơi tay** (không có card đồ họa); chỉ xem thử vài khung bằng GL Compatibility trên Mesa phần mềm để kiểm hình (không commit ảnh).

### Đã làm
- **Khán đài chính (bắc)** x 158…238, mặt dốc z 212,7 → 228,0, **18 bậc** (cao 0,38, sâu 0,85), cao **6,84 m**, dốc 24,1°. Mái che trên **9 cột** (x = 158…238 cách 10 m, z = 228,9; mặt mái y ≈ +0,4), tường thấp 1,1 m ở z = 212,4 có **3 khe rộng 6 m** làm lối lên (x = 173, 198, 223), lan can phía sau và hai bên. Sát đường chạy (vòng chạy dừng ở z = 210,7).
- **Khán đài phụ (nam)** x 168…228, mặt dốc z 119,5 → 113,2, **7 bậc** (cao 0,40, sâu 0,90), cao 2,8 m, tường thấp z = 119,8, 2 lối lên (x = 183, 213). **Khán đài nhỏ cũ ở z 108 đã bỏ.**
- Bậc là hình, **một tấm va chạm dốc liền** (như cầu thang T-183) nên capsule đi lên không cần bước bậc; nav là một mặt dốc cho cả khán đài (không mỗi bậc một vùng như trước).
- **Gầm khán đài chính:** trống, cao từ 1,9 m trở lên khi z ≥ 217,7, mở ra sau lưng giữa các cột; nav riêng + 3 link vào từ sau lưng. `B03` (164; −9,82; 225,5) và 4 ống sắt giữ nguyên chỗ; trần ở đó cao hơn 5 m, trên ngưỡng 2 m mà `_settle_bars` của core dùng.
- **Cổng:** N và S mỗi bên có **hai cổng 10 m ở hai đầu khán đài** (x ∈ [143,153] và [243,253], z = 212,4 và z = 119,8); cổng W/E (z 161…171) giữ nguyên. Cổng giữa x 193…203 đã bỏ vì khán đài che. Hàng rào chạy z = 212,4 và z = 119,8, nối với hàng rào W/E.
- **Anchor đã dời:** `ZombieSpawns/Stadium/S03` (198; −9,9; 122) → **(249; −9,9; 123)**; `S04` (198; −9,9; 210) → **(149; −9,9; 210)**; `ZombieIdle/Stadium/I03` → (249; −9,9; 124), `I04` → (149; −9,9; 211); **`Clues/SirenSpot`** (198; −6,9; 226,8) → **(198; −3,25; 227,575)** (tâm bậc trên cùng; test kiểm là chỗ cao nhất). **Vùng `Zones/Bleachers`:** tâm (198; −5,65; 220,75), size (86; 9,5; 18,5). `Start_stadium`, `S01`, `S02`, `S05`, `S06`, `B03` không đổi. 4 hướng xác vào vẫn đủ: tây, đông (S01, S02, S05, S06), nam (S03), bắc (S04).
- **Rải đồ** (`game/scenes/levels/campus/props.tscn`, node `Campus/Props`): 272 thứ "đáng nhìn" cộng 59 cây thêm. Gồm xe máy (19), xe đạp (9) và nhà để xe có mái, ô tô (10, một chiếc ở sân cổng có đèn hổ phách chập chờn), ki-ốt, máy bán nước, ghế đá, bồn cây, thùng rác, biển chỉ đường và bảng tin (không chữ), nón, rào chắn, thùng gỗ; đồ người chạy loạn (ba lô, giày, dép, điện thoại, khay cơm, giấy); **30 xác nằm** (mô hình tĩnh, có vũng máu); dấu động đất: vết nứt (đường, sân, vườn), cột đèn đổ/nghiêng (5 cột đứng cũ bị bỏ khỏi `StreetLights`, xem `detail.SKIP_LAMPS`), cây đổ, gạch vụn và kính vỡ dưới chân nhà A, nhà B, ba vỏ chương 4; rào chắn nằm trên đường chạy. 4 cột đèn còn sáng mới + 6 đèn ở cột đứng sẵn (OmniLight, **không bóng đổ**).
- **Luật giữ lối:** đồ đặc cách tim tuyến ≥ 3 m + bán kính (lối trống ≥ 5 m), không đè điểm xác, đồ lớn đăng ký `obstacle()` cho lưới nav ngoài trời (`outdoor_navigation.tres` sinh lại). Mọi điểm trên tuyến luôn có ≥ 4 thứ trong 30 m.
- **Hiệu năng:** MultiMesh (`boxes.gd`) chia mảng 40 m, cắt 125 m (khán đài 220 m), màu theo từng thể hiện; va chạm gom mỗi mảng một `StaticBody3D`.

### Số tam giác (đếm lưới × số thể hiện như `capture.gd`)
| Khu | Tam giác |
|---|---:|
| Props (đồ rải, gồm khoảng 5,3 nghìn của 59 cây thêm) | **30.037** |
| Stadium (khán đài, mái, hàng rào, sân; trước 6.240) | **8.376** |
Props thêm vào Campus 30 nghìn (T-183: đường/cây/đèn 15.256). Ngân sách trong test: Props ≤ 32.000, Stadium ≤ 12.000. Chỉ vẽ trong tầm 125 m, nên số vẽ thật mỗi khung nhỏ hơn nhiều; **integrator đo FPS** (cần chủ dự án cho phép). Nếu thấy nặng: bỏ bớt `extra_trees` hoặc hạ `CAR_TINTS`/`litter` trong `scatter.py` rồi chạy lại.

### Dựng lại và file
`python3 art_source/campus/t192.py` (xem `art_source/campus/README.md`, mục T-192). Không chạy `build_campus.py` riêng: nó ghi đè `building_b.tscn`, `campus.tscn`, `layout.json` đã vá tay; `t192.py` trả ba file đó về rồi vá hẹp. File mới: `stands.py`, `scatter.py`, `prims.py`, `t192.py`, `boxes.gd`, `props.tscn`, `test_stands_props.gd`. Sửa: `build_campus.py` (gọi stands/scatter, `ROUTE`, `main()`), `detail.py` (bỏ phần khán đài cũ, `SKIP_LAMPS`), `stadium.tscn`, `outdoor_navigation.tres` (sinh lại), `campus.tscn`, `layout.json` (vá hẹp), `test_campus.gd` (đích `Clues/SirenSpot` thay cho tọa độ cũ).

### Kiểm chứng (Linux, chạy trực tiếp Godot; `tools/test.ps1` không chạy được trên Linux vì dùng `"$PSScriptRoot\godot-path.ps1"`)
```
Lượt 1, origin/main (trước khi sửa, bước 3):   RESULT: 589 passed, 0 failed
Lượt 2, nhánh này (sau khi sửa, bước 5):        RESULT: 597 passed, 0 failed  (589 + 8 test mới)
pwsh tools/check.ps1, origin/main:              RESULT: check 0 error(s)  (292 script)
pwsh tools/check.ps1, nhánh này:                RESULT: check 0 error(s)  (294 script)
```
Không có test FAIL ở lượt 1, nên không có lỗi nào cần ghi là "do môi trường Linux". `test_stands_props.gd` (8 test mới): kích thước/bậc/mái khán đài; khán đài cũ đã bỏ, cổng mở, tường kín; SirenSpot ở chỗ cao nhất, B03 và ống sắt dưới gầm; **người chơi thật** (CharacterBody3D, trọng lực, `move_and_slide`) đi từ đường chạy lên hàng trên cùng và vào gầm tới B03; nav vườn → sân → cổng → nhà ăn, từ cả sáu điểm xác tới khán đài và hàng trên cùng, đường vào gầm phải vòng qua cổng; mật độ và lối trống ở 635 điểm mẫu; ngân sách tam giác. Các test cũ không bị xóa hay nới (`test_campus.gd` chỉ đổi đích SirenSpot).

### Chưa đạt / chưa làm
- **Ảnh (Forward+) và FPS chưa có**: `previews/*.png` và `metrics.json` của T-183 vẫn là bản cũ (khán đài cũ). Integrator chụp khi review; các khung ở `art_source/campus/capture.gd` vẫn dùng được (khung "06_bleachers" nhìn khán đài mới).
- Chưa chơi tay; chưa chạy bot Ch3; chưa kiểm trên Windows.
- Màu và độ sáng chỉ xem qua GL Compatibility phần mềm (tối, không sương): trong Forward+ có sương 0,018 nên khán đài và đồ ở xa mờ hơn; nếu khó thấy từ giữa sân, tăng độ sáng `white` của roof/seat trong `stands.py`.
- Biển chỉ đường và bảng tin **không có chữ** (tên trường vẫn để ngỏ như T-183).

### Quan sát (không sửa, ngoài phạm vi)
- Truy vấn `NavigationServer3D.map_get_closest_point` trên lưới nav ngoài trời (đa giác dải có hàng trăm đỉnh thẳng hàng) trả về điểm cách **tới 2 m** với khoảng 80% điểm mẫu, cả ở `origin/main` (S01 (112; −9,9; 166) cách 2 m). Đường đi (`map_get_path`) vẫn đúng và test qua. Nếu lane A thấy xác sinh ra không bám nav ở sân, nguyên nhân có thể ở đây; cách sửa là sinh lại lưới ngoài trời với đa giác lồi ít đỉnh (không làm trong T-192).

### Yêu cầu thay đổi ngoài phạm vi
1. `tools/test.ps1` (lane C): dòng `. "$PSScriptRoot\godot-path.ps1"` dùng dấu `\` nên chạy hỏng trên Linux; đổi thành `/` (như `check.ps1`). Không cần cho Windows.
2. Không cần sửa `campus.gd`, core hay `strings.csv`. `chapter3_director` dùng `Clues/SirenSpot`, `ZombieSpawns/Stadium` theo tên nên chạy tiếp; bot của lane C (`tools/ch3-profile.json`) cũng gọi theo tên anchor.

### Câu hỏi thiết kế cho chủ dự án
- Không có câu hỏi mới về luật chơi hay cốt truyện. Một lựa chọn trình bày: 30 xác nằm (có máu) rải dọc đường và trong sân có vừa ý không; muốn ít hơn thì giảm xác suất `body` trong `scatter.py` (`route_pass`).

## Review (integrator)
