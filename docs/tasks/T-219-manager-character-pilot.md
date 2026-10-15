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
