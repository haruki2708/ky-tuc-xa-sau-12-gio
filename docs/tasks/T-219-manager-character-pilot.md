# T-219 — G4 mẫu thử nhân vật: quản lý ký túc xá, hai cách làm song song
- Lane: **C** (làm cả phần 3D/Blender và nối gameplay; chuyển từ lane B vì B hết hạn mức) | Trạng thái: **đợt 1 trả sửa (16/10)** | Agent: **lane C**, prompt [`lane-c.md` mục 5](../handoff/lane-c.md)
- Quyết định: **D-115**, giao việc **D-116** (lane B) → **D-117** (lane C). Chủ dự án: "1: làm quản lý trước, 2: thử A và C song song, 3: ngoại hình quản lý tầm 45 tuổi, trang phục quản lý trường học, lộ mặt kinh dị, dao sắc".
- Phụ thuộc: D-114 (FPS 1080p còn dư), hợp đồng nhân vật T-208 (bảng Manager), `game/scripts/entity/manager.gd` (`body_scene`).

## Mục tiêu
Làm **hai bản quản lý** đặt cạnh nhau trong phòng 407, cùng ánh sáng, cùng động tác. **Chủ dự án nhìn rồi chọn một cách làm** cho mọi nhân vật sau (xác bạn cùng phòng, xác sống, Ngư, Minh Nhật, bảo vệ).
- **Mẫu A (Tripo):** thân, mặt và khung xương đều từ Tripo (Auto Rig). Chủ dự án tạo theo [`docs/handoff/TRIPO_QUAN_LY.md`](../handoff/TRIPO_QUAN_LY.md).
- **Mẫu C (kết hợp):** thân, mặt và khung xương từ **MPFB** (MakeHuman trong Blender, tài sản CC0). Đồng phục dựng hoặc chỉnh trong Blender. Dao, chìa khóa, thẻ đeo dùng chung bản Tripo ở phiếu mục 4.
- **Động tác dùng chung cho cả hai:** thư viện động tác CC0 (ví dụ Quaternius Universal Animation Library), đổi sang khung xương người của Godot (`SkeletonProfileHumanoid`) để một bộ động tác chạy trên cả A và C. Khác nhau chỉ nằm ở mô hình.

## Việc cần làm
1. **Công cụ (C):** cài MPFB vào Blender 5.2.2 ở chế độ portable (`D:\Tools\Blender\5.2.2\portable`), **không ghi gì vào ổ C**. Tải bộ tài sản MakeHuman (CC0). Ghi nguồn và giấy phép vào `CREDITS.md`.
2. **Mẫu C:**
   - người nam khoảng 45 tuổi, nét Việt, gầy, hơi gù, theo ngoại hình ở phiếu Tripo mục 1;
   - da và mắt kinh dị bằng texture riêng: da xám bụi, vệt máu khô, mắt đục;
   - đồng phục: sơ mi xanh nhạt sơ vin, quần tây xám, thắt lưng, giày da.
3. **Mẫu A:** chuẩn hóa GLB Tripo:
   - hướng −Z, cao khoảng 1,70 m, gốc ở chân;
   - texture ≤ 2048²;
   - kiểm khung xương có map được sang `SkeletonProfileHumanoid` không.
4. **Động tác:** cần các clip tên đúng `manager.gd` đang gọi: `stand`, `walk`, `ask`, `slash`, `lunge`, `kill`.
   - `slash` là chém xuống từ trên vai, lặp được (đạo diễn chém 6 lần, cách 0,45 s).
   - `ask` là cúi đầu hỏi.
   - `kill` là kết liễu khi người chơi bị bắt.
5. **Scene thân:** `game/scenes/entity/manager_body_a.tscn` và `manager_body_c.tscn` đúng hợp đồng `body_scene` của `manager.gd`:
   - root Node3D;
   - một `AnimationPlayer` có đủ clip trên;
   - `BladeTip` gắn ở mũi dao, dao gắn vào xương bàn tay phải bằng `BoneAttachment3D`.
   - Tay mở cửa (`LeftArm` / `set_reach_weight` ở T-208) **chưa làm trong mẫu thử**; ghi vào phần chưa làm.
6. **Cảnh so sánh:** `game/scenes/levels/graphics_pilot/manager_compare.tscn`.
   - Hai bản đứng cạnh nhau ở giữa phòng 407 (phòng đủ đồ, ánh sáng D-113), chạy cùng clip.
   - Phím đổi clip, đổi đèn pin/đèn trần nhấp nháy, và **chế độ chụp ảnh**.
   - Ảnh 1080p ở `art_source/graphics_upgrade/manager/previews/`: toàn thân, mặt cận 1 m, chém, dưới đèn pin, dưới đèn trần nhấp nháy.
7. **FPS:** đo như D-114 (1080p, góc giữa phòng, đèn trần nhấp nháy) **có một quản lý** trong khung hình, cho từng mẫu. Ghi vào báo cáo.
8. **Test** trong `game/tests/`:
   - mỗi scene thân có đủ 6 clip;
   - có `BladeTip` đi theo tay khi chạy `slash`;
   - tam giác ≤ 25.000, vật liệu ≤ 4, texture ≤ 2048²;
   - `manager.gd` chạy được với cả hai scene: đi, hỏi, chém, giết, không lỗi.

## Ngân sách
- ≤ 25.000 tam giác (cả dao, chìa khóa, thẻ), ≤ 4 vật liệu, texture ≤ 2048² (mặt có thể 2048² riêng).
- File ≤ 10 MiB, nhị phân qua LFS.
- 1080p: phòng 407 có quản lý vẫn **≥ 60 FPS** ở góc nặng nhất của D-114.

## Được phép sửa
- `art_source/graphics_upgrade/manager/` (mới), `game/assets/models/characters/manager/` (mới).
- `game/scenes/entity/manager_body_a.tscn`, `manager_body_c.tscn` (mới).
- `game/scenes/levels/graphics_pilot/manager_compare.*` (mới).
- `game/tests/` (file mới), `CREDITS.md`.

## Không được
- Không đổi bản chơi: **`manager.tscn` và các chương vẫn dùng thân cũ** cho tới khi chủ dự án chọn.
- Không sửa `manager.gd`, AI, thời gian chém, luật, lời thoại.
- Không cài gì vào ổ C. Không dùng Mixamo hay tài sản không phải CC0/CC-BY (trừ Tripo trả phí theo D-084).
- Không xóa hay đổi tên file có sẵn.

## Bàn giao
- `pwsh tools/test.ps1` rồi `pwsh tools/check.ps1`, hai dòng RESULT nguyên văn, commit hash.
- **Handoff:**
  - việc đã làm;
  - ảnh so sánh;
  - FPS từng mẫu;
  - nguồn và giấy phép từng tài sản;
  - phần chưa làm (tay mở cửa, áo bay theo động tác...);
  - nhận xét A và C: mặt, tay, khớp vai, quần áo khi chém.

## Handoff (agent điền)

### Lane C — đợt 1, 16/10/2026

**Phạm vi bàn giao:** mẫu C và phần dùng chung đã có để review; chưa hoàn tất so sánh A/C hoặc duyệt mỹ thuật. Chủ dự án đã chuyển xác nhận **“Integrator đã cấp lượt”** trước khi chạy Forward+ / FPS / full test / check. Bản chơi giữ thân cũ; không sửa `manager.gd`, `manager.tscn`, AI, timing, chương, luật hay lời thoại.

**Đã làm:**

- MPFB **2.0.18** cài vào Blender **5.2.2 portable** trên D:. Tài sản MakeHuman dùng thực tế đặt trên D: và lưu nguồn cần thiết trong `art_source/graphics_upgrade/manager/sources/`. `%APPDATA%/Blender Foundation` không tồn tại trước/sau cài và dựng; APPDATA/TEMP/TMP của các lượt Godot/Blender đặt riêng trên D:.
- Mẫu C có thân/mặt/rig MPFB, đồng phục xanh nhạt/quần xám/thắt lưng/giày; da xám và máu bake vào atlas riêng, mắt đục/đồng tử nhỏ. `.blend` cùng script dựng, nguồn và manifest hash được lưu trong thư mục manager.
- Một `manager_shared.tres` gồm `stand`, `walk`, `ask`, `slash`, `lunge`, `kill`, từ Quaternius CC0; BoneMap tường minh sang `SkeletonProfileHumanoid` cho MPFB và thư viện gốc. Hỏi thêm cúi đầu, chém lặp 0,45 s, kết liễu 0,65 s; không có method track hay chuyển động X/Z của root.
- `manager_body_c.tscn`: root Node3D, AnimationPlayer, dao phay **tạm** gắn `RightHand` bằng BoneAttachment3D, `BladeTip` ở mũi dao. Chìa/thẻ/dây cũng là đồ Blender **tạm**.
- `manager_compare.tscn`: phòng 407 đủ đồ/ánh sáng D-113, chỗ trống bên trái cho A; `1–6` đổi clip, `L` đổi ánh sáng, `V` đổi góc, `P` dừng, `H` ẩn chú thích, `F12` chụp. Text giao diện có vi/en trong CSV riêng của pilot. Cảnh và test tự nhận scene A khi đợt 2 bổ sung.
- Bốn test mới kiểm thư viện/track, BladeTip bám tay và vòng chém, ngân sách thực của scene, và manager production đi → hỏi → chém sáu lần → vồ → giết/phát `player_caught`. Probe tạm dưới `game/tests/` đã xóa.

**Ngân sách C:** **23.872 tam giác**, gồm thân 8.499, đồng phục/giày 10.999, tóc/mày 2.450, mắt/đồ đeo 1.384, dao 540; **4 material**. Texture da và đồng phục 2048², tóc 1024², chi tiết dùng màu vertex. Cao **1,70 m** ở rest pose; gốc ở chân; scene thân hướng −Z (GLB humanoid nội bộ +Z, node Model xoay π). GLB thân **7.633.680 byte**, `.blend` **7.360.580 byte**; tất cả file ≤10 MiB, 27 file nhị phân qua LFS.

**Ảnh 1080p:** đều nằm trong [`previews/`](../../art_source/graphics_upgrade/manager/previews/):

- [`full_body_tube.png`](../../art_source/graphics_upgrade/manager/previews/full_body_tube.png), [`face_1m_tube.png`](../../art_source/graphics_upgrade/manager/previews/face_1m_tube.png).
- [`full_body_flashlight.png`](../../art_source/graphics_upgrade/manager/previews/full_body_flashlight.png), [`face_1m_flashlight.png`](../../art_source/graphics_upgrade/manager/previews/face_1m_flashlight.png).
- [`slash_windup.png`](../../art_source/graphics_upgrade/manager/previews/slash_windup.png), [`slash_contact.png`](../../art_source/graphics_upgrade/manager/previews/slash_contact.png), [`slash_recovery.png`](../../art_source/graphics_upgrade/manager/previews/slash_recovery.png).
- [`tube_flicker.png`](../../art_source/graphics_upgrade/manager/previews/tube_flicker.png).

**FPS từng mẫu:** Godot 4.7.2, Forward+/Vulkan, RTX 3050 Laptop, viewport thực 1920×1080. Như D-114: một quản lý hiện, chạy `slash`, đèn bàn bật/đèn trần ở đỉnh nhấp nháy, 90 frame khởi động + 240 frame đo, VSync tắt/không khóa FPS; cảnh riêng không có player/HUD/story. [Raw frame time và metadata](../../art_source/graphics_upgrade/manager/previews/fps_report.json).

| Mẫu | Giữa phòng (`centre`) | Từ cửa (`door_overview`, nặng nhất D-114) |
|---|---|---|
| C | **90,9 FPS**, p95 **11,52 ms** | **84,0 FPS**, p95 **12,30 ms** |
| A | Chưa đo: chưa có file | Chưa đo: chưa có file |

**Nguồn / giấy phép:**

| Thành phần | Nguồn / phiên bản | Giấy phép |
|---|---|---|
| Công cụ MPFB | [MakeHuman Community, 2.0.18](https://github.com/makehumancommunity/mpfb2/tree/v2.0.18) | GPL-3.0-or-later cho phần mềm; không đưa mã công cụ vào game |
| Thân, mặt, rig, target | Bộ tài sản kèm MPFB 2.0.18, MakeHuman Team | CC0-1.0 |
| Da trung niên, đồng phục, giày, tóc, mày, mắt | [MakeHuman system assets](https://static.makehumancommunity.org/assets/assetpacks/makehuman_system_assets.html), ZIP 14/04/2024; Data Collection AB, Joel Palmius, Jonas Hauquier | CC0-1.0 |
| Động tác | [Quaternius Universal Animation Library Standard](https://quaternius.itch.io/universal-animation-library), snapshot 10/06/2025; [mirror glTF](https://github.com/J-Ponzo/gltf-universal-animation-library) commit `e24c23cf2a1323488a3faa226ea7ea21f644b73e` | CC0-1.0 |
| Dao/chìa/thẻ/dây tạm, màu da/máu/trang phục, chỉnh động tác | Script Blender/Godot của dự án, Codex hỗ trợ | Phần dựng mới/phái sinh CC0-1.0; có khai báo AI |

Đầy đủ tên file/tác giả/URL, snapshot giấy phép và hash ở [CREDITS](../../art_source/graphics_upgrade/manager/CREDITS.md). Phòng 407 và đạo cụ Tripo đã có giữ giấy phép riêng của dự án; không gán lại CC0.

**Kiểm tra:** chạy đúng thứ tự, cả hai lệnh exit 0:

```text
pwsh tools/test.ps1
RESULT: 802 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Đã chạy `git checkout -- game/default_bus_layout.tres` sau hai lệnh. Test riêng có `RESULT: 4 passed, 0 failed`; capture có `RESULT: T219 capture 8 images PASS`. Import GLB cuối không có ERROR. Không chạy bot. Log đầy đủ giữ cục bộ ở `build/t219/full_test.log`, `full_check.log`, `capture_fps.log`. Các snapshot nguồn MakeHuman/MPFB giữ nguyên cả whitespace/tiêu đề gốc; cảnh báo `git diff --check` trong thư mục nguồn là từ bản gốc này, không phải conflict của nhánh. Code và tài liệu tự viết đã qua kiểm whitespace.

**Git:** nhánh `lane-c/T-219-manager-pilot`, đã rebase lên `origin/main` **`cb302c9` (D-117)**. Hai commit triển khai:

- **`900b6136dc37baea451a4a6f6a386f648d523570`** — MPFB C, nguồn/giấy phép, script dựng và thư viện động tác.
- **`63271da412e457e32477ae6965a37e9ec095c810`** — scene thân/cảnh so sánh, bốn test, ảnh, số đo và báo cáo.

Hai lệnh đầy đủ chạy trước rebase; commit main mới chỉ thay năm tài liệu. Cây `game/` trước/sau rebase có cùng Git tree **`781a3ad19d06dff39d70a1d180cde3e0c56365eb`**, nên code/asset/test đã kiểm không thay đổi. Commit tiếp theo chỉ cập nhật các hash trong Handoff này. Bàn giao nguyên nhánh, không push main, không mở PR.

**Nhận xét để chủ dự án chọn:**

- **C — mặt:** nhận ra da xám, máu khô, mắt đục; vẫn trẻ hơn khoảng 45 tuổi, tóc còn phẳng, chưa đủ để duyệt nét Việt. Rọi đèn pin ở 1 m làm mất chi tiết da. Cần tinh chỉnh tuổi/nếp nhăn/normal và tóc nếu chọn cách C.
- **C — tay/vai/áo:** dao bám đúng tay; cách nắm cán còn thô. Vai xoay qua ba pha chém, nếp gập khuỷu phải còn gãy/lộ đường nối; cổ/nách/cạp chưa đẹp khi nhìn gần. Áo/quần dùng skinning, chưa mô phỏng vải; thẻ/chìa/dây gắn cứng theo xương.
- **A:** chưa có file nên chưa nhận xét mặt, bàn tay, khớp vai hay quần áo; chưa chứng minh retarget trên rig Tripo thực tế.

**Chưa làm / đang chờ:** `LeftArm` / `set_reach_weight` và IK mở cửa; cloth/đồ đeo đung đưa; mặt biểu cảm/lip-sync; `kill` riêng (hiện dùng biến thể từ chém). Staging `D:\GAME_DEMO\build\graphics\staging\manager` chưa tồn tại khi kiểm tra cuối; chưa tạo `manager_body_a.tscn`, chưa có dao/chìa/thẻ Tripo và hồ sơ D-084 của chúng. Đợt 2 cần chuẩn hóa A, thay đồ tạm, kiểm rig/ngân sách/6 clip, chụp A/C cạnh nhau và đo riêng A. Chưa có căn cứ đề nghị thêm lượt Tripo, không tiêu credit.

Không có chặn kỹ thuật với đợt 1 hoặc yêu cầu sửa core/contract. Đợt 2 **chờ file của chủ dự án**. [Báo cáo ảnh/nhận xét đầy đủ](../../art_source/graphics_upgrade/manager/REPORT.md), [cách dựng lại/chạy cảnh](../../art_source/graphics_upgrade/manager/README.md). Giữ nguyên ba stash cũ.

### Sửa sau review đợt 1 — Lane C, 16/10/2026

Làm trên `lane-c/T-219-manager-pilot` trong `D:\GAME_WORK\lane-c`; đã fetch và rebase lên **`origin/main f651a8f`** (có nguyên Review đợt 1). Giữ ba stash cũ. Integrator đã cấp lượt Godot qua chủ dự án trong phiên này. Không sửa manager production, chương, AI, nhịp director, STATUS, DECISIONS hoặc phần Review.

**Từng điểm 1–7 của prompt sửa:**

1. **Nhánh / review:** đã đọc review và mục 5.1 của `lane-c.md`, rebase thành công. Hash cũ đợt 1 đổi do rebase; bản chưa ghép main vẫn được giữ trong lịch sử nhánh.
2. **Retarget và stand:** đã chụp Quaternius nguyên bản cạnh C **trước** khi thay model/clip. Cả mirror cũ và Standard v3 chính thức đều có Idle gối gập **21,45°/14,12°**, chân cách **0,532 m**; Blender độc lập xác nhận cùng số đo với Godot. Đã gửi bằng chứng qua chủ dự án và nhận quyết định **“Đồng ý sửa retarget + tạo stand nguồn thẳng”**. Sửa rest fixer ở **cả nguồn và đích**, ngưỡng silhouette **0,1°** thay mặc định 15°, chuẩn hóa các góc nghỉ nhỏ trước khi đổi trục; BoneMap vẫn tường minh theo SkeletonProfileHumanoid. Tạo stand thẳng có thở/nắm dao trên rig nguồn CC0, dùng cùng thư viện cho A/C; không hiệu chỉnh stand theo tỷ lệ riêng của C. Ảnh sau có Quaternius và C cùng chạy đúng `manager_shared.tres/stand`. C đo gối **4,193°/4,193°**, chân cách **0,21993 m**, đầu hạ **0,03927 m** so rest; test cả năm điểm trong vòng stand đạt giới hạn 10° / 0,28 m / 0,05 m. Khoảng cách chân ở đây là **3D**, không chỉ độ rộng theo X như con số 0,36 m của review. [Dữ liệu trước](../../art_source/graphics_upgrade/manager/previews/retarget_before.json), [sau](../../art_source/graphics_upgrade/manager/previews/retarget_after.json), [kiểm chéo Blender](../../art_source/graphics_upgrade/manager/previews/original_blender_probe.json).
3. **Slash:** phái sinh CC0 từ Sword_Attack, chỉnh hai chuỗi tay trên rig nguồn bằng IK giải tích trong Blender; giữ chuyển động thân/chân gốc. Tay phải nâng dao trên vai rồi bổ chéo xuống trước thân; tay trái thu gần thân. Pha 0,10 s: BladeTip y=**1,813 m**, vai phải y=**1,228 m**. Pha 0,25 s: BladeTip y=**0,277 m** < ngực **0,756 m**, z=**−0,962 m** ở trước ngực z=**−0,027 m** (scene thân hướng −Z). Vẫn lặp **0,45 s**, test bám RightHand/khép vòng và sáu lần director vẫn đạt. `.blend` động tác và script dựng đã lưu; ghi rõ phái sinh trong CREDITS. `kill` giữ biến thể Sword_Attack cũ, không sửa ngoài yêu cầu.
4. **Mặt / tóc:** age **0,68**, weight **0,24**, target giảm đầy má/tăng gò má; thêm nếp trán, khóe mắt, rãnh mũi má vào albedo và tangent normal da 2048². Máu nâu sẫm chia nhánh từ chân tóc, mép không đều; mắt đục sáng hơn, con ngươi nhỏ nhìn thấy ở ảnh 1 m dưới đèn trần. Đã so lựa chọn tóc CC0 short03/short04: chọn **short04**, tóc vuốt ngắn thoáng trán và mép alpha; short03 có mái phủ trán nên không dùng. Giữ nguồn short01 cũ để đối chiếu. Không thêm material.
5. **Khuỷu áo:** thay trọng số vùng khuỷu bằng blend upperarm/lowerarm liên tục theo vị trí, cùng giá trị qua seam, vùng chuyển 14 cm dùng smoothstep. Cận pha lấy đà cho khuỷu liền/tròn hơn; vẫn còn nếp và vùng tối ở vai/nách do skinning, không có cloth/corrective động.
6. **Dao tạm:** lưỡi thép xám sẫm, cạnh sáng hẹp, cán gỗ nâu sẫm và đinh tán; dày 5 → **8 mm**, số tam giác dao vẫn **540**. Tiếp tục ghi **tạm**, chờ Tripo; chưa tiêu credit.
7. **Bóng đèn pin:** kiểm scene điện thoại và override phòng 407, ghi giá trị runtime ngay tại ảnh mặt. **Khớp game**: shadow=true, bias=0,03, normal bias=1, blur=1, opacity=1; trong phòng light_size=0,025, energy=5, angle=38°, attenuation=1,3, range=10. **Giữ nguyên thông số**, không làm mềm bóng riêng cho ảnh pilot. [Metadata đối chiếu](../../art_source/graphics_upgrade/manager/previews/capture_report.json).

**Ảnh bàn giao — 15 ảnh 1920×1080**, thư mục [`previews/`](../../art_source/graphics_upgrade/manager/previews/):

| Nhóm | File |
|---|---|
| Tám ảnh chụp lại | `full_body_tube.png`, `face_1m_tube.png`, `full_body_flashlight.png`, `face_1m_flashlight.png`, `slash_windup.png`, `slash_contact.png`, `slash_recovery.png`, `tube_flicker.png` |
| Đối chứng trước sửa | `reference_original_before_front.png`, `reference_v3_original_before_front.png` — trái: Quaternius Idle nguyên bản; phải: C đợt 1 |
| Đối chứng sau, cùng clip mới | `reference_shared_after_front.png` — cả hai cùng chạy thư viện stand mới; dùng ảnh này để so retarget |
| Đối chứng giữ nguồn cũ | `reference_original_after_front.png`, `reference_v3_original_after_front.png` — trái vẫn Idle gốc, phải stand mới; không coi là cùng clip |
| Khuỷu / sáu clip | `elbow_windup_close.png`; `six_clips_midpoint.png` — trái → phải, trên → dưới: stand, walk, ask, slash, lunge, kill tại giữa mỗi clip |

[Báo cáo có liên kết ảnh](../../art_source/graphics_upgrade/manager/REPORT.md), [metadata tấm ghép](../../art_source/graphics_upgrade/manager/previews/review_capture_report.json). Ảnh chụp từ viewport thật; tấm ghép chỉ cắt giữa/thu nhỏ/ghép pixel, không chỉnh hình nhân vật. Góc chéo thử bị đồ phòng che nên đã bỏ khỏi bộ bàn giao, không thay bằng ảnh giả.

**Ngân sách / FPS:** C **22.665 tam giác** (da 8.499; đồng phục/giày 11.000; tóc/mày 1.242; mắt/đồ đeo 1.384; dao 540), giảm **1.207** so đợt 1; **4 vật liệu**, texture tối đa **2048²** (da thêm normal 2048², tóc 1024²). GLB thân **7.982.276 byte**, `.blend` thân **7.704.972 byte**; mọi nhị phân qua LFS, ≤10 MiB/file. Quaternius đối chứng chỉ dùng chế độ chụp, không nằm trong scene thân hoặc lượt FPS.

Đã đo lại 1080p Forward+, RTX 3050 Laptop, 90 frame khởi động + 240 frame/góc, VSync tắt, một C chạy slash, đèn trần peak/đèn bàn bật như D-114: **centre 90,1 FPS / p95 11,50 ms**; **door_overview 83,8 FPS / p95 12,27 ms**. [Raw frame time](../../art_source/graphics_upgrade/manager/previews/fps_report.json). **A chưa có file, chưa có FPS**; staging vẫn chưa tồn tại ở lần kiểm trong phiên này.

**Nguồn / giấy phép bổ sung:**

| Tài sản | Nguồn / tác giả | Giấy phép |
|---|---|---|
| Thân/mặt/rig, macro/target má | MakeHuman Team, dữ liệu kèm MPFB 2.0.18 | CC0-1.0; MPFB GPL chỉ là công cụ |
| Da, quần áo, giày, tóc short04, mày/mắt | MakeHuman system assets 14/04/2024; Data Collection AB, Joel Palmius, Jonas Hauquier | CC0-1.0 |
| Thư viện dùng chung, stand/slash phái sinh | Quaternius UAL Standard snapshot 10/06/2025 + sửa nguồn Blender/Codex của dự án | CC0-1.0 |
| Model đối chứng v3 | Quaternius UAL Standard v3 chính thức 16/06/2026, tải 16/10/2026 | CC0-1.0; không dùng bản Pro/Source trả phí |
| Normal/nếp nhăn/máu, dao và đồ đi kèm tạm | Script thủ tục của dự án, Codex hỗ trợ | Phần mới/phái sinh CC0-1.0; đã khai báo AI hỗ trợ |

Tên file, URL chính thức, license snapshot và SHA256 ở [CREDITS](../../art_source/graphics_upgrade/manager/CREDITS.md), [manifest nguồn](../../art_source/graphics_upgrade/manager/sources/source_manifest.json), [manifest bổ sung](../../art_source/graphics_upgrade/manager/sources/review_sources.json). Không ghi gì mới vào `%APPDATA%/Blender Foundation` trên C:; thư mục đó vẫn không tồn tại. Godot APPDATA/TEMP/TMP riêng trên D:. Không chạy bot.

**Kiểm tra:** probe offline/headless và import sau mỗi đổi GLB không có ERROR; probe tạm đã xóa. Sáu test pilot đạt; hai lệnh đầy đủ chạy đúng thứ tự và đều exit 0:

```text
RESULT: 6 passed, 0 failed
RESULT: T219 capture 8 images PASS
RESULT: T219 elbow and six-clip contact sheet PASS
pwsh tools/test.ps1
RESULT: 804 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Đã chạy `git checkout -- game/default_bus_layout.tres` sau hai lệnh. Log giữ cục bộ: `build/t219/full_test_review.log`, `full_check_review.log`, `capture_review.log`. Phạm vi file, giới hạn 10 MiB, thuộc tính LFS cho toàn bộ nhị phân mới/đổi và việc giữ nguyên Review đã kiểm đạt.

**Git / bàn giao:** hai commit triển khai sau rebase:

- **`036310279c13fdbf1829775b13465da682b967ca`** — chuẩn hóa rest/retarget, stand nguồn mới, cú bổ, đối chứng Quaternius và test.
- **`1cd4c47b8eb348577c66440b416ff876dbf7c147`** — mặt/normal/tóc/áo/dao, nguồn CC0, bộ ảnh và FPS/báo cáo.

Commit Handoff tiếp theo chỉ cập nhật tài liệu này. Nhánh đích `origin/lane-c/T-219-manager-pilot`; do rebase, push dùng `--force-with-lease` với HEAD remote cũ đã kiểm **`d7f1f76a70f870d9f82c03601dfcef68c011bf25`**, để từ chối nếu người khác cập nhật nhánh. Không push main, không mở PR. Nhả lượt Godot qua chủ dự án sau khi push được xác nhận.

**Nhận xét / còn lại:** C đã thay dáng stand, cú bổ, mặt/normal/tóc/mắt, khuỷu và dao như trên; tuổi/nét Việt vẫn cần chủ dự án duyệt bằng mắt, mặt còn mang tính dựng thủ tục. Cách nắm cán, nếp vai/nách/cổ/cạp và vật liệu dao còn đơn giản; không có mô phỏng vải/đồ đeo. A chưa nhận nên chưa nhận xét mặt/tay/vai/quần áo hoặc chứng minh trên rig Tripo thật. `LeftArm` / `set_reach_weight`, IK mở cửa, biểu cảm/lip-sync vẫn chưa làm. Không còn chặn kỹ thuật của phần sửa C; đợt A/đồ Tripo chờ file và hồ sơ D-084. Quyết định bổ sung stand nguồn đã nhận qua chủ dự án; không có yêu cầu thay core/contract khác.

## Review (integrator)

### Review đợt 1 (integrator, 16/10/2026): **trả sửa**, chưa ghép

Nhánh `lane-c/T-219-manager-pilot` HEAD `d7f1f76`.

**Đạt:**
- Phạm vi: 82 file, toàn bộ là file mới trong vùng card cho phép (+ Handoff). Không có file bị xóa hay đổi tên.
- 27 file nhị phân qua LFS, file lớn nhất 7,6 MB.
- Ngân sách: 23.872 tam giác, 4 vật liệu, texture ≤ 2048².
- FPS 1080p: 84–91.
- Nguồn và giấy phép ghi đủ: MPFB GPL chỉ là công cụ, tài sản MakeHuman và Quaternius là CC0.
- Bản chơi không đổi.
- Integrator tự ghép thử vào `main` và tự chạy: `RESULT: 802 passed, 0 failed`, `RESULT: check 0 error(s)`.
- Handoff kỹ và tự nêu đúng điểm yếu.

**Phải sửa:**
1. **Chuyển động tác sang khung xương MPFB bị lệch tư thế** (phần dùng chung, mẫu A cũng sẽ dính).
   - Probe của integrator ở `stand` t = 0 so với tư thế gốc: gối gập 17–24° (gốc 7°), hai bàn chân cách 0,36 m (gốc 0,20), đầu hạ 11 cm (1,54 → 1,43 m), tay dang.
   - `Idle_Loop` của Quaternius là dáng đứng thẳng. Ảnh toàn thân vì thế giống thế thủ khuỵu gối, không phải người quản lý đứng.
   - Kiểm bằng cách cho mô hình Quaternius gốc chạy cùng clip ngay cạnh, rồi chụp.
   - Sửa tận gốc ở tư thế nghỉ hoặc BoneMap (A-pose với T-pose), không chỉnh tay từng clip.
2. **`slash` chưa đúng card** ("chém xuống từ trên vai").
   - `Sword_Attack` là cú quét ngang. Pha lấy đà dang hai tay như giữ thăng bằng; pha chạm là cú vung thấp ngang người.
   - Cần một cú bổ: tay phải đưa dao lên cao ngang hoặc trên vai, bổ chéo xuống phía trước; tay trái thu gần thân. Vẫn lặp được với nhịp 0,45 s.
3. **Mặt chưa ra 45 tuổi và chưa đủ kinh dị.**
   - Tuổi đặt `age = 0.62` (khoảng 41 tuổi theo thang MakeHuman), da mịn, nên trông như thiếu niên.
   - Vệt máu là một dải đỏ phẳng như sơn.
   - Ở 1 m dưới đèn trần, mắt tối như mắt thường, không thấy đục.
   - Tóc là một khối như mũ bảo hiểm.
4. **Khuỷu tay áo bị gãy và lộ đường nối** khi chém (lane C đã nêu).
5. **Dao tạm là tấm phẳng màu trắng,** trên ảnh trông như tờ giấy hoặc bìa kẹp hồ sơ.

**Ghi nhận, không bắt sửa:**
- `kill` dùng biến thể của `Sword_Attack`.
- Chưa có tay mở cửa, vải và đồ đeo đung đưa.
- Bóng đèn pin răng cưa ở ảnh mặt 1 m: chỉ cần ghi lại cảnh so sánh có dùng cùng thông số bóng với đèn pin trong game (D-104) không.

Prompt sửa: [`lane-c.md` mục 5.1](../handoff/lane-c.md).
