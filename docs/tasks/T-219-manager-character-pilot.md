# T-219 — G4 mẫu thử nhân vật: quản lý ký túc xá, hai cách làm song song
- Lane: **C** (làm cả phần 3D/Blender và nối gameplay; chuyển từ lane B vì B hết hạn mức) | Trạng thái: **D-119: quản lý Tripo trong cảnh xem thử, chờ chủ dự án duyệt** (chủ dự án tự làm, integrator hỗ trợ, D-118) | Agent: chủ dự án + Claude
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
1. **`stand` là dáng khuỵu gối, chân choãi, tay dang**, không phải người quản lý đứng.
   - Probe của integrator ở `stand` t = 0 so với tư thế gốc: gối gập 17–24° (gốc 7°), hai bàn chân cách 0,36 m (gốc 0,20), đầu hạ 11 cm (1,54 → 1,43 m).
   - **Đính chính (16/10, sau phản hồi lane C):** integrator nhận định ban đầu là lỗi chuyển động tác. Sai: ảnh `previews/reference_v3_original_before_front.png` cho thấy mô hình Quaternius gốc cũng khuỵu như vậy (`Idle_Loop` t = 0: gối 21,45°/14,12°, hai bàn chân cách 0,532 m, đo ở cả Blender và Godot). Đây là dáng thủ thế của clip nguồn.
   - **Integrator đồng ý hướng lane C đề xuất:** tạo một `stand` đứng thẳng, phái sinh CC0, đặt ở thư viện nguồn dùng chung (A và C cùng dùng, không chỉnh riêng từng mẫu). Nếu đo thấy còn lệch do chuyển động tác thì vẫn sửa ở tư thế nghỉ hoặc BoneMap. `ask` nếu cũng khuỵu như vậy thì làm cùng cách. Ngưỡng test giữ nguyên.
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

### D-118 (16/10/2026): dừng giao lane, không ghép phần của lane C

- Chủ dự án: "cái bước nhờ lane c tạo mẫu quản lý tôi nghĩ nên bỏ được rồi, tôi sẽ đảm nhiệm việc đó + sự hỗ trợ của chính bạn".
- Hỏi xử lý phần lane C đã làm xong (mẫu C MPFB, bộ động tác dùng chung, cảnh so sánh, test), chủ dự án chọn **"Bỏ hết"**.
- **Không ghép** nhánh `lane-c/T-219-manager-pilot`. Lượt sửa HEAD `40c3b2d` đã qua review: integrator tự chạy 804/804, check 0 trên bản ghép thử, rồi hủy bản ghép theo quyết định này. Nhánh vẫn nằm trên origin để tra cứu, không xóa.
- **Từ nay chủ dự án tự làm quản lý, integrator hỗ trợ** (Claude làm thay phần B/A khi cần). Không giao lane B, C cho việc này; prompt `lane-b.md` mục 7 và `lane-c.md` mục 5, 5.1 không dùng nữa.
- Mục tiêu, ngân sách, hợp đồng `body_scene` và "bản chơi giữ thân cũ tới khi chủ dự án duyệt" vẫn giữ. Phiếu `docs/handoff/TRIPO_QUAN_LY.md` vẫn dùng được.
- **Bài học từ lượt của lane C, giữ lại cho lần làm sau:**
  - Clip `Idle_Loop` và `Idle_Talking_Loop` của Quaternius UAL là thế thủ khuỵu gối, không dùng thẳng cho dáng đứng hoặc dáng hỏi.
  - Retarget sang `SkeletonProfileHumanoid` cần chỉnh tư thế nghỉ (rest fixer) ở cả nguồn và đích.
  - `Sword_Attack` là cú quét ngang, không phải cú bổ.
  - MPFB `age` 0,62 trông như thiếu niên; tóc short01 thành khối như mũ.

### D-119 (19/10/2026): quản lý Tripo trong cảnh xem thử (chủ dự án tạo trên Tripo, Claude làm thay B/A)

**Chủ dự án tạo trên Tripo Studio (18–19/10):**
- Lượt đầu Text to 3D ra kiểu hoạt hình nên bỏ. Đổi sang tạo ảnh mẫu trong Tripo (Nano Banana, khung 3:4, chọn ảnh 2), rồi Image to 3D.
- Retopo còn 18.449 tam giác. Auto Rig loại Humanoid, xương kiểu Mixamo, có đủ ngón tay.
- Động tác preset: idle, walk, wait, run, slash, bow.
- Đồ đi kèm: dao phay, chùm chìa khóa, thẻ đeo.

**Claude làm thay B/A:**
- **`pack_tripo_manager.py`:**
  - gốc là file có động tác (file rigged không kèm động tác có xương ở vị trí gốc);
  - ghép 7 clip `stand` (idle), `walk`, `ask` (bow), `wait`, `slash` (cắt 1,15–3,10 s), `lunge` (run), `kill` (slash 1,15–2,30 s; Tripo không có động tác kết liễu);
  - bỏ trôi hông ở clip di chuyển, bỏ kênh scale hằng;
  - texture JPEG ≤ 2048; file 4,9 MiB.
- **Import:** `root_scale` 1,73 → đỉnh đầu 1,70 m.
- **`manager_body.tscn`:**
  - xoay 180° để nhìn về −Z;
  - dao (dựng thẳng bằng `align_prop.py`, nướng bằng `bake_prop.py`) gắn tay phải, lưỡi hướng ra trước nắm tay, `BladeTip` ở mũi dao;
  - chìa khóa ở hông phải, thẻ ở ngực trái;
  - `HandGripModifier` co 4 ngón tay phải quanh cán;
  - `manager_body.gd` cho các clip đứng, đi, chạy lặp.
- **Ngân sách:** 24.131 tam giác, 4 vật liệu, texture ≤ 2048².
- **Cảnh xem thử** `game/scenes/levels/graphics_pilot/manager_preview.tscn`: phòng 407 của bản chơi, ánh sáng D-113; phím 1–7, L, C, Space. 14 ảnh 1080p ở `art_source/graphics_upgrade/manager/previews/`.
- **5 test** `game/tests/player/test_manager_body.gd`:
  - đủ 6 clip và vòng lặp;
  - cao 1,70 m, nhìn −Z;
  - mũi dao lên trên đầu rồi bổ xuống phía trước;
  - ngân sách;
  - `manager.gd` đi, hỏi, chém 6 lần, giết với thân mới.
- **Bản chơi chưa đổi:** `manager.tscn` và các chương vẫn dùng thân cũ.

**Còn mở:**
- **Mắt:** trong game mắt bình thường, không trắng đục như ảnh mẫu (texture Tripo không giữ).
- **Chủ dự án chọn `ask`:** bow (cúi chào 90°) hay wait (chống nạnh).
- **Chuyển cảnh giữa các động tác:** `manager.gd` gọi `stop()` trước mỗi `play()` nên không pha trộn động tác. Sửa khi đưa vào bản chơi.
- **Xác nhận gói tài khoản Tripo:** ảnh mẫu tạo ở tài khoản hiển thị "H".
- **Tay trái:** tay mở cửa (`LeftArm`) chưa làm.
