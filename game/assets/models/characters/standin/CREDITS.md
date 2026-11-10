# Credits — thân tạm cho nhân vật chính (T-220, D-121)

| File | Nguồn | Tác giả | Quyền dùng |
|---|---|---|---|
| `quaternius_ual.glb` | **Quaternius Universal Animation Library (Standard)**, bản glTF ở [J-Ponzo/gltf-universal-animation-library](https://github.com/J-Ponzo/gltf-universal-animation-library), snapshot 10/06/2025. Bản gốc của tác giả: [quaternius.itch.io/universal-animation-library](https://quaternius.itch.io/universal-animation-library). Lấy nguyên byte từ nhánh lane C `lane-c/T-219-manager-pilot` (file `game/assets/models/characters/manager/quaternius_original.glb`, commit `0363102`). SHA-256 `b94b87af722757a3e8971d97e0968c4fca3a1963ec49f216c1935618a9723a09`. | Quaternius | **CC0 1.0** (không bắt buộc ghi công; vẫn ghi để tra cứu) |
| `quaternius_bone_map.tres` | Bảng nối xương Quaternius → `SkeletonProfileHumanoid` của Godot, do lane C (Codex) làm ở T-219, lấy nguyên từ cùng nhánh. | Dự án | Như dự án |
| `quaternius_ual2.glb` | **Quaternius Universal Animation Library 2 (Standard)**, tải từ [quaternius.itch.io/universal-animation-library-2](https://quaternius.itch.io/universal-animation-library-2) ngày 08/11/2026 (chủ dự án tải, D-143). Zip `Universal Animation Library 2[Standard].zip` SHA-256 `4008ea208a604773a2b2177d965f0f5d3195498b5bf838c3f5785d68e95f2a68`; file trong zip `Unreal-Godot/UAL2_Standard.glb` (bản không có root motion), nguyên byte, SHA-256 `8cee20ab1bc55130092447e810e26df22dd2803eccc54f52137a7d54d7ab88a8`. `License.txt` trong zip: CC0 1.0. | Quaternius | **CC0 1.0** |
| `quaternius_ual2_bone_map.tres` | Bảng nối xương UAL2 (tên kiểu Unreal: `pelvis`, `clavicle_r`, `calf_l`, `ball_l`…) → `SkeletonProfileHumanoid`, integrator làm (T-227 lượt 2). | Dự án | Như dự án |

- **Thân tạm:** người mẫu không mặt, không texture. Chỉ dùng để làm cơ chế thân và tay ở bước 1. Từ T-227 thân là Trần Trung (Tripo); file này chỉ còn cho mượn động tác.
- **Động tác dùng** (T-227: chạy trên khung xương Trần Trung, thư viện `ual/` trong `player_body.gd`):
  - `Crouch_Idle`, `Crouch_Fwd` để ngồi xổm, đi khom (đứng, đi, chạy là động tác Tripo của Trần Trung);
  - `Interact`: từ T-241 chỉ còn lấy dáng ngón tay phải lúc với (clip không còn phát khi với tay); `PickUp_Table` không còn dùng;
  - `Idle` để đo chỗ đứng của hông (mọi clip `ual/` được dời hông cho khớp Trần Trung).
- **Import:** nối xương qua `quaternius_bone_map.tres`, đổi tên xương theo `SkeletonProfileHumanoid`, khung xương tên `GeneralSkeleton`. Nhờ vậy động tác dùng chung được cho mọi thân người khác.
- **UAL2** (T-227 lượt 2, thư viện `ual2/` trong `player_body.gd`, chỉ giữ các clip dùng): `LayToIdle` (nằm ngửa rồi ngồi dậy, đứng lên), `ClimbUp_1m` (trèo lên giường tầng, bục), `Hit_Knockback` (trúng đòn), `Walk_Carry_Loop` (bê đồ khi đi), `Idle_FoldArms_Loop` (chỉ để đo chỗ đứng của hông); Godot bỏ đuôi `_Loop` khi import (`Walk_Carry`, `Idle_FoldArms`). Cùng cách import với UAL1.
