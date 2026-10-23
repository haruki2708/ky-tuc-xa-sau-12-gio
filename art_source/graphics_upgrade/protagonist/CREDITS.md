# Credits — nhân vật chính (T-220, D-121…D-124; T-227, D-137, D-138)

| File game | Nguồn | Tác giả / công cụ | Quyền dùng |
|---|---|---|---|
| `game/assets/models/characters/protagonist/trung_tripo.glb` + 3 texture `trung_tripo_*.jpg` | Tripo AI Studio, 23/10/2026. Ảnh mẫu trước, trái, sau tạo trên **Gemini Argon 4** (Google AI Pro, chủ dự án, 23/10/2026 khoảng 23:10; prompt trong `trung_ref_gemini.txt` cùng thư mục staging) → dựng 3D từ 3 ảnh (Multiview to 3D theo phiếu) → Auto Rig (Mixamo, 65 xương có ngón) → Animate (preset idle, walk, run, look_around, scared_01, hit_to_body_02, jump, climb, sit). File gốc ở `build/graphics/staging/protagonist/`, chỉ lưu hash (`SHA256SUMS.txt`). | Tripo AI; Gemini cho ảnh mẫu; người vận hành: chủ dự án; ghép clip, cắt đoạn, bỏ trôi hông, thu texture: Claude (`pack_tripo_protagonist.py`) | Đầu ra gói trả phí **Tripo Studio Pro**, ngoại lệ **D-084**; điều khoản lúc tạo: `../tripo/room407_backpack/evidence/tripo_terms_2026-10-12.pdf`, `tripo_commercial_2026-10-12.pdf`. Ảnh Gemini do dự án tự tạo (D-138) |
| `game/assets/models/props/phone/phone_tripo.glb` + 3 texture | Tripo AI Studio, Text to 3D (23/10/2026), prompt ở `docs/handoff/TRIPO_NHAN_VAT_CHINH.md` mục 5 | Tripo AI; người vận hành: chủ dự án; ép mỏng, giảm đa giác, nướng normal: Claude (`../tripo/bake_prop.py`, Blender 5.2.2) | Như trên (D-084) |
| `game/assets/models/characters/protagonist/trung_bone_map.tres` | Bảng nối xương Mixamo → `SkeletonProfileHumanoid` | Dự án (Claude) | Như dự án |
| Động tác bù trong `player_body.gd` (thư viện `ual/`) | Lấy từ `quaternius_ual.glb` dưới đây, chạy trên khung xương Trần Trung | Quaternius | CC0 1.0 |
| `game/assets/models/characters/standin/quaternius_ual.glb` | Quaternius Universal Animation Library (Standard), xem `game/assets/models/characters/standin/CREDITS.md` | Quaternius | CC0 1.0 |
| `game/assets/models/props/door_lever.glb` | Dựng bằng script `build_door_lever.py` (Blender 5.2.2): đế tròn, cổ, cần gạt, inox xước, khoảng 2.000 tam giác, không texture | Dự án; script do Claude viết (D-124) | Như dự án |

- **Mã tác vụ Tripo** của thân, gắn xương và điện thoại, và tài khoản Tripo đã dùng: chờ chủ dự án gửi link (ghi vào `build/graphics/staging/protagonist/ghi_chu.txt` và chép vào đây).
- **Khai báo nội dung AI (Steam):** mô hình, texture và động tác Tripo của Trần Trung và điện thoại tạo bằng AI (Tripo AI; ảnh mẫu Gemini).
- `previews/` chụp trong phòng 407 của bản chơi. Đồ Tripo trong phòng giữ nguồn ở các hồ sơ graphics upgrade trước (D-084).
- Tay nắm có thể thay bằng bản Tripo (chủ dự án tạo, gói trả phí D-084) mà không đổi code: `DoorHandles.LEVER` trỏ tới GLB mới. Yêu cầu: đế nằm ở gốc, cần gạt chạy theo +X, nhô ra theo +Z.
