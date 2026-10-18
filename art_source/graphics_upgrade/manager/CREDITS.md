# Credits — quản lý ký túc xá, Tripo (T-219, D-118)

| File game (`game/assets/models/characters/manager/`) | Nguồn | Tác giả / công cụ | Quyền dùng |
|---|---|---|---|
| `manager_tripo.glb` + 3 texture `manager_tripo_*.jpg` | Tripo AI Studio, 18–19/10/2026. Ảnh mẫu tạo trong Tripo (mục Image, Nano Banana) → Image to 3D (H3.1) → Retopo (18.449 tam giác) → Auto Rig (Humanoid, xương kiểu Mixamo, 55 xương + đầu ngón) → Animate (preset `idle`, `walk`, `wait`, `run`, `slash`, `bow`). File gốc ở `build/graphics/staging/manager/`, chỉ lưu hash (`SHA256SUMS.txt`). | Tripo AI; người vận hành: chủ dự án; ghép clip, cắt đoạn, bỏ trôi hông, thu texture 2048: Claude (`pack_tripo_manager.py`) | Đầu ra gói trả phí **Tripo Studio Pro**, ngoại lệ **D-084**; điều khoản lúc tạo: `../tripo/room407_backpack/evidence/tripo_terms_2026-10-12.pdf`, `tripo_commercial_2026-10-12.pdf` |
| `manager_knife.glb`, `manager_keys.glb`, `manager_id_card.glb` | Tripo AI Studio, Text to 3D, H3.1, texture 4K (19/10/2026), prompt ở `docs/handoff/TRIPO_QUAN_LY.md` mục 4 | Tripo AI; người vận hành: chủ dự án; dựng thẳng dao (`align_prop.py`), giảm đa giác + nướng normal: Claude (`../tripo/bake_prop.py`, Blender 5.2.2) | Như trên (D-084) |

- **Mã tác vụ đã biết** (từ ảnh chụp màn hình chủ dự án gửi):
  - ảnh mẫu: `studio.tripo3d.ai/workspace/generate-image/a92203d3-c633-431c-9344-f9f42d5e4bab`;
  - gắn xương và động tác: `.../workspace/rigging/c207078a-72da-4712-b378-30ee6cccebc6`.
  - Các mã còn lại chủ dự án ghi trong `build/graphics/staging/manager/ghi_chu.txt`.
- **Chờ chủ dự án xác nhận:** ảnh mẫu tạo bằng tài khoản hiển thị "H" (Lv.0), các bước 3D, Retopo, Rig bằng tài khoản "School". Cần xác nhận cả hai đều là gói trả phí.
- **Đầu vào:** chỉ prompt chữ do dự án viết, cộng ảnh mẫu tạo ngay trong Tripo; không dùng ảnh ngoài.
- Bản dựng hoạt hình lượt đầu (Text to 3D, `.../generate/e22d590c-...`) không dùng.
- **Khai báo nội dung AI (Steam):** mô hình, texture và động tác của quản lý tạo bằng AI (Tripo AI).
