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
