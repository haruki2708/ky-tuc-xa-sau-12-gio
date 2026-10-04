# T-154 — Mô hình chương 1: quản lý, xác ba bạn cùng phòng, đạo cụ
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent:
- Nhánh: `lane-b/T-154-ch1-models`
- Phụ thuộc: T-153 (làm ngay sau). Đọc `docs/design/STORY.md` v2 §0, §2, §9.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Mô hình thực thể và đạo cụ cho chương 1, theo phong cách PS1: vật lớn dưới 1500 tam giác, vật nhỏ dưới 500, texture 64–256 px, lọc nearest. Chỉ dùng CC0, CC-BY hoặc tự làm; ghi `CREDITS.md`; asset tạo bằng AI phải ghi công cụ.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
1. **Quản lý** (`manager_body.tscn`, dùng làm `body_scene` cho T-152):
   - Người đàn ông cao khoảng 1,95 m, đồng phục quản lý ký túc xá cũ, sờn; mặt chìm trong bóng, chỉ thấy miệng.
   - Tay cầm **dao phay dài**, mũi dao chạm đất.
   - Animation:
     - `walk`: nặng nề, dao kéo lê;
     - `stand`, `ask`: nghiêng đầu về phía giường;
     - `slash`: chém xuống, dùng lặp được nhiều nhát;
     - `lunge`: lao tới;
     - `kill`: kết liễu sát camera.
   - Có một node `BladeTip` (Marker3D ở mũi dao) để lane E đặt nguồn âm kéo dao.
2. **Xác ba bạn cùng phòng** (`corpse_phuc.tscn`, `corpse_viet.tscn`, `corpse_dat.tscn`):
   - Mỗi người dáng và áo khác nhau, nhận ra được: Phúc áo đỏ, Việt áo kẻ, Đạt áo thể thao đen.
   - Tư thế (animation một khung hoặc node con) cho `unseen_poser` của T-152:
     - `dead_a`: nằm như đang ngủ;
     - `dead_b`: tay buông khỏi giường;
     - `head_turn`: đầu quay về phía giữa phòng;
     - `eyes_open`: mắt mở.
   - Tư thế cho chương 2 (làm sẵn nếu kịp): `sit_up` (ngồi dậy, mắt trống rỗng).
   - Máu: texture thấp, đỏ sẫm, không làm chi tiết giải phẫu.
3. **Đạo cụ:**
   - **Cục sạc** điện thoại (đặt trong tủ của Đạt).
   - **Cục phát wifi nhỏ**, đèn nhấp nháy, có `set_led(on)`.
   - **Thẻ sinh viên hoặc sổ tay của Đạt**: mặt chữ đọc được dưới filter PS1, có chỗ ghi ngày sinh để làm mã khóa (integrator chọn mã).
   - **Mảnh vụn giường bị chém**: nệm rách, mút bông, gỗ vụn.
   - **Giẻ lau** (cho chương 2, làm sẵn nếu kịp).
   - **Điện thoại cầm tay** (viewmodel cho T-151 và T-155): màn hình là một mặt phẳng riêng tên `Screen` để lane D đặt texture giao diện.
4. **Đặt vào phòng 407:** xác ở anchor `Corpse1`, `Corpse2`, `Corpse4` (T-153); sạc trong tủ Đạt; đồ trang trí cố định thì đặt luôn. Đồ có hành vi (tủ, cục phát) chỉ đặt scene, integrator nối logic.
5. **Preview và test:**
   - ảnh preview từng mô hình và cảnh phòng có đủ xác;
   - test: load scene, số tam giác, đủ tên animation và tư thế, có `BladeTip`, có `Screen`.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] `CREDITS.md` đủ nguồn
- [x] Handoff: danh sách scene, animation, API

## Handoff (agent điền)

### Đã làm — Lane B, 2026-10-04

Commit triển khai `dfde1d9`, đã push `lane-b/T-154-ch1-models` cùng 38 object LFS. Nhánh tạo từ `origin/main` tại `d000c8f`, đã có T-153 và luồng chương 1. Chỉ sửa vùng cho phép của T-154 và checklist/Handoff card này; không sửa STATUS, Player, AI, UI, dữ liệu hoặc cấu hình export.

10 model native Godot với mesh low-poly, khớp Node3D và AnimationPlayer, không cần plugin/importer model. 13 texture thủ tục 128 px, lossless/nearest, không mipmap. Nguồn, công cụ AI và giấy phép CC0 được ghi ở [CREDITS](../../art_source/CREDITS.md); font Be Vietnam Pro dùng lại theo SIL OFL hiện có. Các `.import` và `.uid` đã kèm theo.

Tất cả scene ở **`res://scenes/levels/ch1_models/`**:

| Scene | Tam giác | Animation / API |
|---|---:|---|
| `manager_body.tscn` | 776 | `walk`, `stand`, `ask`, `slash`, `lunge`, `kill`, `RESET`; Marker3D `BladeTip` ngay dưới root |
| `corpse_phuc.tscn` | 592 | Áo đỏ; `dead_a`, `dead_b`, `head_turn`, `eyes_open`, `sit_up`, `RESET` |
| `corpse_viet.tscn` | 592 | Áo kẻ, dáng hẹp; cùng bộ pose |
| `corpse_dat.tscn` | 616 | Áo thể thao đen, dáng rộng; cùng bộ pose, quay đầu/tay đối xứng vào giữa phòng |
| `charger.tscn` | 60 | Model cục sạc, không logic nhặt |
| `router.tscn` | 180 | `set_led(bool)`; bật nháy chu kỳ 1,2 s, false tắt hẳn |
| `dat_notebook.tscn` | 108 | `set_content(title, student_name, birth_date)`; ba Label3D `Title`, `Name`, `BirthDate` |
| `phone_viewmodel.tscn` | 50 | MeshInstance3D `Screen` riêng; `set_screen_texture(Texture2D)` nhận cả ViewportTexture, null trả màn tối |
| `bed_debris.tscn` | 72 | Vải nệm rách, mút, gỗ vụn |
| `rag.tscn` | 40 | Giẻ có nếp gấp, làm sẵn cho chương 2 |

Số tam giác tính cả mesh ẩn; chữ Label3D sinh theo nội dung không tính vào hình học sổ. Không có collider mới trên model.

### Điểm ghép / quy ước

- Quản lý gốc ở chân, cao khoảng 1,94 m, trước là **-Z**. `AnimationPlayer` trực tiếp dưới root; stand/walk loop, các clip khác không loop. `slash` dài 1,2 s, nhát xuống ở 0,77 s, cuối clip trở về nghỉ để gọi lại; `kill` dài 0,9 s, nhát xuống 0,46 s. Clip lunge dịch Rig tối đa 0,36 m; root do AI điều khiển. Không có method track gây chết/âm thanh. `BladeTip` theo khớp dao sau animation mỗi frame, y=0,015 m ở stand/walk.
- Ba body đã đặt tại **`Room407/Anchors/Corpse1/Body`, `Corpse2/Body`, `Corpse4/Body`**. Đầu hướng +Z, gốc tại tâm mặt nệm; capsule `Sleeper_*` cũ ẩn, giữ node path. Không có xác trên giường 3.
- Xác có `set_pose(StringName) -> bool` áp ngay một pose và pause; tên sai trả false. Có thể điều khiển trực tiếp AnimationPlayer bằng T-152. Pose khôi phục đầy đủ bằng dead_a, máu không phụ thuộc pose.
- `set_blood_visible(bool)` trên body đã nối vào `Room407.set_blood_stage()`: stage 0 ẩn vết áo, stage 1/2 hiện; mặc định dead_a sạch để dùng trong mở đầu. Máu là mảng đỏ sẫm, không chi tiết giải phẫu.
- Sạc nằm trong **`Room407/Anchors/DatLocker/Charger`**, phía trong cánh tủ; router ở **`Anchors/Router/Model`**, sổ ở **`Anchors/DatNote/Model`**. Model router/sổ cũ trong Details đã ẩn. Sổ mới hạ 0,027 m để không che mặt Readable hiện có.
- Chữ model sổ mặc định trống để caller cấp nội dung dịch; ảnh kiểm tra dùng key **DOC_CH1_DAT_CARD_* đã có trên main**, không tự đặt ngày sinh/mã khóa. Khi ghép chỉ chọn một lớp chữ giữa Readable hiện có và Label3D.
- Màn hình điện thoại 0,064 × 0,127 m, UV 0..1, trước **-Z**, +Y là đầu máy; material độc lập từng instance. Gắn dưới Camera cần xoay Y=180° để màn hướng về người chơi. Chưa tự sửa Player/UI.
- Vụn mới ở **`Details/Debris/RichDebris`** đi cùng hiển thị set_slashed() của T-153; giẻ ở **`Details/CleaningRag`**. `sit_up` và giẻ đã làm sẵn; chưa dàn cảnh chương 2 với mùng/giường tầng.

Chi tiết đường dẫn, thời lượng, dựng lại và ví dụ ghép: [README](../../art_source/ch1_models/README.md).

### Kiểm tra và preview

Đã chạy trên Godot 4.7.2, exit code 0:

```text
pwsh tools/test.ps1 -Filter ch1_models
RESULT: 5 passed, 0 failed
pwsh tools/test.ps1
RESULT: 329 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
CH1_MODELS_CAPTURE_RESULT: PASS 25 views
```

Test mới kiểm tra load scene/số tam giác/material/import texture; đủ clip và đường dẫn track; mũi dao sát sàn trong walk, nâng/hạ/reset khi slash; pose xác khác nhau và khôi phục, máu độc lập; LED nháy/tắt; nội dung sổ và texture điện thoại không rò giữa instance; placement trong phòng, ẩn capsule, máu sạch/reset và vụn. `git diff --check` sạch, mọi file dưới 10 MB.

Đã render và xem preview 1280×720, Forward+ Vulkan, filter PS1 strength=1:

- [Quản lý](../../art_source/ch1_models/previews/manager_body.png), [chém](../../art_source/ch1_models/previews/manager_slash.png); các clip còn lại trong thư mục previews.
- [Phúc](../../art_source/ch1_models/previews/corpse_phuc.png), [Việt](../../art_source/ch1_models/previews/corpse_viet.png), [Đạt](../../art_source/ch1_models/previews/corpse_dat.png), [Đạt ngồi dậy](../../art_source/ch1_models/previews/corpse_dat_sit_up.png).
- [Sạc](../../art_source/ch1_models/previews/charger.png), [router](../../art_source/ch1_models/previews/router.png), [sổ và ngày sinh đọc được](../../art_source/ch1_models/previews/dat_notebook.png), [điện thoại](../../art_source/ch1_models/previews/phone_viewmodel.png), [vụn](../../art_source/ch1_models/previews/bed_debris.png), [giẻ](../../art_source/ch1_models/previews/rag.png).
- [Phòng đủ ba xác](../../art_source/ch1_models/previews/room_all_corpses.png); ảnh camera nằm giường 1/2/4 và pose bổ sung ở [previews](../../art_source/ch1_models/previews/). [Manifest](../../art_source/ch1_models/previews/manifest.json) ghi số tam giác thực.

F6 `res://scenes/levels/ch1_models/models_test.tscn`: trái/phải đổi model; phím 1..6 chọn clip quản lý hoặc 1..5 chọn pose xác. Chưa chơi thử thủ công toàn chương, chưa ghép AI T-152/âm kéo dao/viewmodel UI vào chuỗi gameplay; không báo các phần này đã test. Không đo lại FPS trong T-154.

### Yêu cầu thay đổi (ngoài phạm vi, chưa tự sửa)

1. **Lane A/integrator:** gán manager_body vào `body_scene` của T-152, dùng root AnimationPlayer; điều khiển vị trí/hướng và đồng bộ slashed với nhát xuống. Gắn unseen_poser vào ba Body có sẵn, không sinh thêm xác; reset dead_a và máu khi checkpoint/mở đầu. Ghép sit_up trong dàn cảnh chương 2 cần mở/đổi mùng và vị trí ngồi phù hợp. Xử lý giảm hù dọa ở gameplay, không chạy kill cận mặt khi đã bật tùy chọn này.
2. **Lane A/E:** nối nguồn âm kéo dao vào root BladeTip; gọi âm thanh bước/chém từ manager theo nhịp clip. Bộ model không tự thêm manager_audio để tránh phát trùng.
3. **Lane A/D/integrator:** thay model điện thoại tạm bằng phone_viewmodel, đưa texture UI vào Screen; nối set_led theo mạng/puzzle, nhặt sạc từ tủ và trạng thái hiển thị sau khi nhặt. Nội dung sổ dùng dữ liệu/localization đã duyệt, cập nhật khi đổi ngôn ngữ, tránh hai lớp chữ trùng với Readable.
4. **Core/Lane C:** loại `scenes/levels/ch1_models/models_test*` khỏi bản export theo mẫu cảnh QA; không loại các scene model/runtime còn lại. Không chỉnh `export_presets.cfg` trong nhánh Lane B.

### Còn lại / bị chặn

Không checklist T-154 còn thiếu, không bị chặn. Hai mục tùy thời gian (`sit_up`, giẻ lau) cũng đã có. Còn review mỹ thuật của chủ dự án và kiểm tra gameplay sau tích hợp như trên. Không có câu hỏi thiết kế mới; dùng thiết kế v2 và dữ liệu hiện có, không tự thêm luật/cốt truyện.

### Review (integrator, 2026-10-04)
- **Đạt, đã merge.** Đúng phạm vi; 10 mô hình, 5 test mới, 25 ảnh preview; ba xác đặt sẵn trên giường, capsule cũ đã ẩn.
- **Đã ghép:**
  - `manager_body.tscn` làm `body_scene` của quản lý (T-152);
  - ba xác có `UnseenPoser` và `CorpseAudio`;
  - router nhấp nháy đèn (`set_led(true)`);
  - cục sạc trong tủ Đạt ẩn đi khi đã cắm sạc.
- **Chưa ghép:**
  - `phone_viewmodel` (cần lane A/D thay điện thoại tạm và đưa giao diện lên `Screen`);
  - nội dung `dat_notebook` (đang dùng giấy đọc được ở cùng vị trí, tránh hai lớp chữ);
  - `sit_up` và giẻ để cho chương 2.
- Loại `models_test*` khỏi bản export: integrator làm khi xuất bản build.
