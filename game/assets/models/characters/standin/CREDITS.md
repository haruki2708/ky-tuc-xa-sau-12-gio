# Credits — thân tạm cho nhân vật chính (T-220, D-121)

| File | Nguồn | Tác giả | Quyền dùng |
|---|---|---|---|
| `quaternius_ual.glb` | **Quaternius Universal Animation Library (Standard)**, bản glTF ở [J-Ponzo/gltf-universal-animation-library](https://github.com/J-Ponzo/gltf-universal-animation-library), snapshot 10/06/2025. Bản gốc của tác giả: [quaternius.itch.io/universal-animation-library](https://quaternius.itch.io/universal-animation-library). Lấy nguyên byte từ nhánh lane C `lane-c/T-219-manager-pilot` (file `game/assets/models/characters/manager/quaternius_original.glb`, commit `0363102`). SHA-256 `b94b87af722757a3e8971d97e0968c4fca3a1963ec49f216c1935618a9723a09`. | Quaternius | **CC0 1.0** (không bắt buộc ghi công; vẫn ghi để tra cứu) |
| `quaternius_bone_map.tres` | Bảng nối xương Quaternius → `SkeletonProfileHumanoid` của Godot, do lane C (Codex) làm ở T-219, lấy nguyên từ cùng nhánh. | Dự án | Như dự án |

- **Thân tạm:** người mẫu không mặt, không texture. Chỉ dùng để làm cơ chế thân và tay ở bước 1. Từ T-227 thân là Trần Trung (Tripo); file này chỉ còn cho mượn động tác.
- **Động tác dùng** (T-227: chạy trên khung xương Trần Trung, thư viện `ual/` trong `player_body.gd`):
  - `Crouch_Idle`, `Crouch_Fwd` để ngồi xổm, đi khom (đứng, đi, chạy là động tác Tripo của Trần Trung);
  - `Interact`, `PickUp_Table` để với tay;
  - `Idle` để đo chỗ đứng của hông (mọi clip `ual/` được dời hông cho khớp Trần Trung).
- **Import:** nối xương qua `quaternius_bone_map.tres`, đổi tên xương theo `SkeletonProfileHumanoid`, khung xương tên `GeneralSkeleton`. Nhờ vậy động tác dùng chung được cho mọi thân người khác.
