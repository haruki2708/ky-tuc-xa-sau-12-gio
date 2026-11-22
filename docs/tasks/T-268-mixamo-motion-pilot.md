# T-268 — Mẫu thử chuyển động Mixamo: Trần Trung và quản lý (bước 2 của kế hoạch chuyển động)

- Lane: integrator | Trạng thái: **chờ chủ dự án duyệt video** | Agent: integrator
- **Model:** Opus 5.5 xhigh (chủ dự án chọn khi bắt đầu, 22/11/2026)
- Nhánh: `t268-mixamo-pilot` (chưa merge; chỉ merge khi chủ dự án duyệt)
- Quyết định nền: D-189 (ngoại lệ giấy phép Mixamo, chỉ lấy động tác), kế hoạch `docs/design/MOTION_UPGRADE_PLAN.md` bước 2, phiếu tải `docs/handoff/MIXAMO_DONG_TAC.md`

## 0. Hiện trạng (khảo sát 22/11, năm tác tử đọc song song, không chạy Godot)

Sửa lại các nhận định trong kế hoạch:
- **Độ dài file:** `player_body.gd` dài 3.111 dòng, không phải khoảng 2.755.
- **Clip Tripo đang phát:** game chỉ phát idle, walk, run. Các clip Quaternius climb, knockback, carry_walk có trong bảng nhưng không phát ở đâu.
- **Đi ngang:** không phải "clip đi tới phát chậm". Thân xoay 60° theo hướng đi, ngực xoay ngược khoảng 36°, và khoảng 30° chuyển động không nằm trong bước chân, nên chân trượt ngang khoảng 0,5 × tốc độ.
- **Camera không gắn vào đầu khi đi:** thân được dời sao cho điểm mắt trung bình của clip nằm dưới camera (chỉ theo X/Z). Đầu nhún trong clip không làm camera rung, nhưng làm vai và tay nhún dưới camera.
- **Tên xương:** Mixamo dùng tên `mixamorig:*`, còn bảng xương của Trần Trung dùng tên không tiền tố. Phải có bảng riêng (`mixamo_bone_map.tres`).
- **`fix_silhouette`:** kế hoạch nói Quaternius dùng nó, nhưng thực ra nó tắt ở Quaternius, chỉ bật ở Trần Trung.
- **Khung xương quản lý không được chuyển:** tên `mixamorig_*`, dáng tay buông 70°, trục xương lệch X Bot 36–180°. Clip Mixamo không chép thẳng được.

## 1. Đã làm

### 1a. Công cụ đóng gói `art_source/graphics_upgrade/mixamo/`
Gồm `pack_mixamo.ps1`, `pack_mixamo.gd`, `clips.json`, `mixamo_bone_map.tres`, README, CREDITS, SHA256SUMS. Chi tiết trong README.
- Một dự án Godot tạm trong `build/mixamo_pack/` nhập FBX bằng bộ chuyển khung xương của Godot, rồi ghi `trung_mixamo.res` (track `%GeneralSkeleton:*`, như thư viện Quaternius).
- Quản lý: clip được **nướng** lên khung xương Tripo của chính ông ta, qua hai bản nhập của `manager_tripo.glb` (khớp theo đỉnh lưới), ra `manager_mixamo.res` (track `Armature/Skeleton3D:mixamorig_*`).
  - Không đổi tên xương nào. Dao, chìa khoá, thẻ, `BoneLockModifier`, `ArmReachModifier` và test tên xương giữ nguyên.
- `build/integrator/godot_steps_locked.ps1` có thêm `-ProjectDir` để chạy dự án tạm dưới cùng khoá.
- `.gitignore` chặn `*.fbx`. `.gitattributes` đưa `*.res` qua LFS (trước đây chưa có file `.res` nào trong repo).

### 1b. Game (mặc định tắt; mọi test cũ chạy như trước)
- **`player_body.gd`:**
  - Cờ tĩnh `PlayerBody.motion = &"mx"` bật mẫu thử, `PlayerBody.mx_idle` chọn kiểu đứng.
  - `clips` là bảng theo từng thân: `CLIPS` cộng các clip Mixamo. `CLIPS` vẫn là hằng, nên test đọc `CLIPS` không đổi.
  - Mẫu thử thay đứng (Neutral Idle) và đi tới (Standard Walk), thêm đi lùi (Walking Backwards) và đi ngang trái, phải (Left/Right Strafe Walking).
  - Khi đi ngang, thân quay mặt về trước. Vùng đi ngang là 67,5–100° lệch hướng nhìn, có trễ 5°. Đường chéo bàn phím 45° vẫn là đi tới.
  - Đi lùi phát clip đi lùi theo chiều xuôi.
  - Chạy, ngồi xổm và thao tác tay giữ nguyên clip cũ. Thao tác tay vẫn giữ idle Tripo đứng yên dưới IK, nên lúc bắt đầu và kết thúc thao tác có một cú chuyển dáng; bước 4 sẽ xử lý.
- **`manager_body.gd`** (thêm `class_name ManagerBody`): cờ `ManagerBody.motion = &"mx"` thay `walk` và `slash` trên bản sao thư viện.
- **`manager.gd`:** clip `walk` nào có meta `stride_speed` thì phát ở `speed / stride_speed`, nên chân không trượt. Clip Tripo không có meta nên không đổi.
- **Cảnh xem trước:** `protagonist_pilot.gd` và `manager_preview.gd` có chế độ `--motion-compare` (`--motion=mx`, `--mx-idle=idle_breathing`) để quay video.

### 1c. Số đo (Godot, 22/11)

| Động tác | Tốc độ phát để chân không trượt | Ghi chú |
|---|---|---|
| Trung đi tới 2,2 m/s | cũ ×2,36, mới **×1,71** (bước chân 1,28 m/s) | nhịp bước đỡ vội |
| Trung đi lùi | cũ ×2,36 (clip đi tới phát ngược), mới ×2,27 (clip đi lùi) | |
| Trung đi ngang | cũ ×2,04 (thân xoay 60°, chân trượt ngang), mới **×1,50** (thân quay về trước) | |
| Quản lý đi 1,3 m/s | cũ ×1 (chân trượt khoảng 25%), mới ×1,49 (bước chân 0,87 m/s) | |
| Quản lý chém 0,45 s/nhát | cũ ×4,33 (clip 1,95 s), mới ×2,67 (clip 1,2 s) | |

- **Điểm mắt (chưa chỉnh độ cao camera):** idle Mixamo 1,520, đi ngang 1,47 (đơn vị mô hình). Idle Tripo là 1,556. Camera vẫn ở 1,6 m.
- **Hông đung đưa:** Neutral Idle khoảng 2 cm, Breathing Idle khoảng 18,8 cm.

### 1d. Video (trong `build/graphics/motion/`, không commit)
- `t268_trung_cu_moi.mp4` (22 s, cũ | mới): đứng, đi tới, đi lùi, đi ngang hai bên ở hành lang tầng 4, nhìn từ bên cạnh; rồi bốn hướng ở góc nhìn người chơi (cúi 58°).
- `t268_trung_2_kieu_dung.mp4` (5 s): Neutral Idle | Breathing Idle.
- `t268_quanly_cu_moi.mp4` (14 s, cũ | mới): đi 1,3 m/s, đứng, chém 6 nhát nhìn ngang, rồi chém 6 nhát nhìn trước mặt.

## 2. Hỏi chủ dự án (cổng duyệt)
1. **Trần Trung:** dùng bộ đứng và đi Mixamo cho bước 3 không?
2. **Kiểu đứng:** Neutral Idle (đứng nghiêng một chân, ít đung đưa) hay Breathing Idle (thở rõ hơn, đung đưa nhiều)?
3. **Quản lý đi:** dùng Male Brutal Walk không?
4. **Quản lý chém:** clip Mixamo bổ từ trên đầu xuống, tay kia dang ra lấy thăng bằng, trông "diễn" hơn cú cúi chém của Tripo. Nó bước chân theo nhát chém; chân trụ trượt khoảng 6–11 cm mỗi nhát, đúng bằng clip gốc. (Ghim hông tại chỗ thì trượt 15–26 cm, nên đã bỏ cách đó.) Có ba hướng:
   - dùng bản mới;
   - giữ bản cũ;
   - tìm clip khác. Clip đâm dao cầm ngược đã thử: đó là cú đâm ngang ngực, không hợp chém xuống giường, nên đã loại.

### 1e. Rà soát độc lập (23/11)
4 tác tử rà, mỗi lỗi một tác tử kiểm chứng: 11 điểm, 8 điểm được xác nhận (đều nhẹ), đã sửa hết:
- Khi cờ tắt, thứ tự đo trong `_ready` trả về đúng như main.
- Mẫu thử tự quay về clip Tripo nếu thư viện thiếu clip hoặc gõ sai tên idle.
- `pack_mixamo.ps1`: chỉ chép vào game khi lần đóng gói in `PACK RESULT: PASS`; luôn dùng bản `pack_mixamo.gd` và `clips.json` mới; so FBX theo hash; in cả log lỗi.
- Kiểm tra lưới đọc lại chính clip đã ghi (lệch 0,07 mm).
- Có chốt độ trượt chân (`max_slide`) cho clip đánh tại chỗ của quản lý.
- Hai test không thể hỏng và một test so sai ngưỡng đã được sửa. Thêm test quay về clip cũ.
- Lần chạy lại sau khi sửa: `tests/player/` 274/0.

## 3. Phải giữ (bước 3–6)
- Không đổi luật chơi: 1 giây và 1,4 giây cho thao tác, tốc độ đi, chạy, khom, thời điểm chém.
- Khi bật hẳn, các test đang ghim clip cũ phải sửa có lý do, không nới:
  - `test_protagonist_body.gd:560, 562-564` (idle PINGPONG, hông UAL khớp idle Tripo);
  - `test_t249_chapter3_bar.gd:335-336` (đi lùi = clip đi tới phát ngược);
  - `test_manager_body.gd:68-72` (thời điểm vung, chém của clip Tripo);
  - các số đo tay (T-239/T-241/T-243) nếu idle dưới IK đổi sang Mixamo ở bước 4.

## 4. Kiểm (22/11, cờ tắt trừ test mới)
- `player/test_t268_motion_pilot.gd`: 7 test mới đạt (bật cờ trong test). Gồm:
  - thư viện đúng khung xương;
  - đi lùi, đi ngang đúng clip và thân quay về trước;
  - chân trụ không trượt quá 4 cm ở cả bốn hướng;
  - quản lý đi đúng nhịp chân.
- `tests/player/` 273 đạt / 0 hỏng (sau rà soát: 274/0); smoke 1/0; `graphics_pilot` 3/0; `tests/tools/` 53/0.
- Full test và check: làm khi merge (sau khi chủ dự án duyệt và làm bước 3).

## Checklist
- [x] Công cụ đóng gói + hai thư viện `.res`
- [x] Cờ mẫu thử (mặc định tắt) cho Trung và quản lý
- [x] Video cũ | mới, số đo
- [x] Test mới; test cũ liên quan đạt
- [ ] Chủ dự án duyệt (D-190) → bước 3
