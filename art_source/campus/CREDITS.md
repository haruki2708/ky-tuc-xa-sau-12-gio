# Nguồn asset bổ sung T-190

| File / nhóm | Tác giả, công cụ | Nguồn | Giấy phép |
|---|---|---|---|
| Cánh cửa mở, giường/tủ hộp, phòng 408 và nav | Lane B, Codex (OpenAI); Python stdlib, Godot 4.7.2 | [Generator/patch](room_doors.py), [hợp đồng](room_doors.md); hình học thủ tục | CC0-1.0 |
| Cửa gỗ tầng 4, module tường | Bộ kit CC0 hiện có của dự án | [Nguồn và giấy phép gốc](../CREDITS.md), `game/assets/models/kit/{door,wall_door,wall_straight}.glb` | CC0-1.0 |
| `previews/room401_open.png`, `previews/room408_open.png` | Godot Forward+ trên RTX 3050 Laptop; Codex viết script | [Capture](capture_room_doors.gd), render scene thực tế | CC0-1.0 |

Nguồn repo: [nhánh T-190](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/tree/lane-b/T-190-room-zombie-doors/art_source/campus).
**Khai báo AI:** Codex viết mã tạo hình học, GDScript, test và tài liệu.
Không ảnh sinh AI, không asset tải ngoài, không plugin hay texture mới.
Hai ảnh preview dùng Git LFS, mỗi ảnh dưới 10 MB.

# Nguồn asset bổ sung T-192

| File / nhóm | Tác giả, công cụ | Nguồn | Giấy phép |
|---|---|---|---|
| Khán đài, tường, hàng rào, cổng, mái; xe, ki-ốt, ghế, thùng rác, biển, xác nằm, vết nứt, đồ rải | Lane B (Claude Code trên web làm thay, D-066); Python stdlib, Godot 4.7.2 | [Stands](stands.py), [Scatter](scatter.py), [Batch](prims.py), [Patch](t192.py); hình học thủ tục | CC0-1.0 |
| `game/scenes/levels/campus/boxes.gd` | Claude Code; GDScript | vẽ MultiMesh của các hình trên | CC0-1.0 |
| Texture | Dùng lại 64 px sinh bởi `detail.py` (T-183) | không texture mới | CC0-1.0 |

**Khai báo AI:** Claude Code (Anthropic) viết mã tạo hình học, GDScript, test và tài liệu.
Không ảnh sinh AI, không asset tải ngoài, không plugin, không file nhị phân mới.

