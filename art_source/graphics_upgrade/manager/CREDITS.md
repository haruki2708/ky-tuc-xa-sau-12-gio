# T-219 — Nguồn mẫu C và bộ động tác dùng chung

Ngày lấy nguồn: **16/10/2026**. Lane C thực hiện thay B theo chỉ định D-117 của chủ dự án.

| Thành phần | Công cụ / tác giả / phiên bản | Nguồn | Giấy phép / file áp dụng |
|---|---|---|---|
| Phần mềm tạo người | MPFB **2.0.18**, Joel Palmius / MakeHuman Community | [Mã nguồn bản 2.0.18](https://github.com/makehumancommunity/mpfb2/tree/v2.0.18), [giấy phép](https://github.com/makehumancommunity/mpfb2/blob/v2.0.18/LICENSE.md) | Phần mềm **GPL-3.0-or-later**; cài ở Blender portable trên D:, không đưa mã MPFB vào game. |
| Thân, mặt, khung xương `game_engine`, mục tiêu chỉnh mắt/dáng | MakeHuman Team; bộ kèm MPFB 2.0.18 | Cùng bản mã nguồn MPFB ở trên | **CC0-1.0** cho tài sản và đầu ra; `manager_c.glb`, `manager_c.blend`. Bản giấy phép lưu tại `sources/MAKEHUMAN_CC0.md` và `sources/MPFB_LICENSE.md`. |
| Da nam trung niên, đồng phục, giày, tóc, lông mày, mắt | MakeHuman system assets, bản ZIP ngày sửa **14/04/2024**; Data Collection AB, Joel Palmius, Jonas Hauquier | [Trang gói chính thức](https://static.makehumancommunity.org/assets/assetpacks/makehuman_system_assets.html), [ZIP CC0](https://files.makehumancommunity.org/asset_packs/makehuman_system_assets/makehuman_system_assets_cc0.zip) | **CC0-1.0**. Các thư mục `sources/makehuman/skins/middleage_asian_male`, `clothes/male_casualsuit01`, `clothes/shoes01`, `hair/short01`, `eyebrows/eyebrow001`, `eyes/low-poly`, `eyes/materials`. Header `.mhclo/.mhmat` giữ nguyên xác nhận CC0 tháng 9/2020. |
| Động tác gốc | **Quaternius Universal Animation Library Standard**, snapshot phân phối **10/06/2025**, Quaternius | [Tác giả / giấy phép chính thức](https://quaternius.itch.io/universal-animation-library), [bản mirror glTF CC0](https://github.com/J-Ponzo/gltf-universal-animation-library) | **CC0-1.0**, `sources/QUATERNIUS_CC0.md`. Bản tải trực tiếp itch.io trả HTTP 429; dùng mirror có README ghi nguồn và ngày snapshot. Sáu clip trích xuất nằm trong `game/assets/models/characters/manager/manager_motion_source.glb`. Không dùng bản Pro/Source trả phí. |
| Bụi, máu khô, màu đồng phục, màu mắt; dao/chìa/thẻ tạm | Dự án, script do **Codex (OpenAI)** viết, chạy bằng **Blender 5.2.2 LTS** | `build_manager.py`, `textures/`, `manager_c.blend` | Phần dựng mới dành cho dự án, công bố **CC0-1.0** trong mẫu thử này; phần phái sinh giữ nguồn CC0 ở trên. Có dùng AI hỗ trợ viết script/tạo hình thủ tục; ghi lại để khai báo nội dung AI khi phát hành. Dao, chùm chìa, thẻ và dây đeo đều là **tạm**, chờ Tripo. |
| Chuyển động sau chỉnh sửa | Dự án / Codex, Godot **4.7.2** | `build_motion.py`, `build_library.gd`, BoneMap / SkeletonProfileHumanoid | Phái sinh **CC0-1.0** từ Quaternius. `manager_shared.tres`: đứng, đi, hỏi có cúi đầu, chém lặp 0,45 s, vồ tại chỗ, kết liễu 0,65 s. |

Các ảnh trong `previews/` còn chứa phòng 407 đã có trong dự án; nguồn phòng và đạo cụ được giữ nguyên ở các hồ sơ graphics upgrade trước đó. Không gán giấy phép CC0 cho những đạo cụ Tripo của phòng.

## Bổ sung sau review đợt 1 — 16/10/2026

| Thành phần | Nguồn / phiên bản | Giấy phép và thay đổi |
|---|---|---|
| Tóc đang dùng | MakeHuman system assets CC0, `hair/short04`; cùng tác giả và ZIP 14/04/2024 ở bảng trên | **CC0-1.0**. Thay `short01` bằng tóc vuốt ngắn, trán thoáng, mép sợi alpha. Đã xem phương án `short03` nhưng tóc rẽ mái phủ trán không phù hợp; không đưa `short03` vào game. Giữ nguồn `short01` để đối chiếu lịch sử. |
| Đối chứng chính thức | [Quaternius Universal Animation Library Standard v3](https://quaternius.itch.io/universal-animation-library), bản cập nhật 16/06/2026, tải ngày 16/10/2026 | **CC0-1.0**, bản Standard miễn phí; `UAL1_Standard.glb` được copy nguyên byte thành `quaternius_v3_original.glb`. Giấy phép nguyên bản: `sources/QUATERNIUS_V3_LICENSE.txt`. Không dùng Pro/Source trả phí. |
| Đối chứng nguồn đợt 1 | Mirror Quaternius 10/06/2025 ở bảng trên | **CC0-1.0**. `build_reference.py` chỉ đóng JSON/bin thành `quaternius_original.glb`, không đổi bind pose hoặc clip. |
| `stand` phái sinh | Rig và thư viện Quaternius CC0 của đợt 1, sửa bằng Blender 5.2.2 | **CC0-1.0**. Theo xác nhận của chủ dự án chuyển quyết định integrator trong phiên 16/10: tạo đứng thẳng ở **nguồn dùng chung**, vì Idle gốc đo được gối 21,45°/14,12°. Giữ chuyển động thở, tay hạ và nắm dao; không sửa riêng stand trên rig C. |
| `slash` phái sinh | `Sword_Attack`, cùng nguồn CC0 | **CC0-1.0**. `build_motion.py` giữ chuyển động thân/chân gốc, chỉnh key hai chuỗi tay trên rig nguồn bằng IK giải tích: tay phải lấy đà trên vai rồi bổ chéo xuống phía trước, tay trái thu gần thân. `manager_motion.blend` lưu bản dựng; Godot retime 0,45 s và khép vòng. `kill` vẫn từ Sword_Attack gốc. |
| Mặt, normal, trọng số áo, dao tạm | Dự án / Codex; `build_manager.py`, `face_surface.py` | Phái sinh **CC0-1.0** từ MakeHuman. Age 0,68, target má/gò má, nếp nhăn và máu bake vào albedo/normal da; blend trọng số liên tục ở hai khuỷu; màu thép/mép/cán dao và bề dày mới. Nội dung tạo thủ tục có AI hỗ trợ viết code, không dùng ảnh người thật hoặc tài sản ngoài hồ sơ. |

Các model Quaternius đối chứng chỉ được nạp trong chế độ chụp đối chứng, không nằm trong scene thân hoặc phép đo FPS. Bảng hash bổ sung ở `sources/review_sources.json`. Giấy phép phần mềm MPFB vẫn là GPL; chỉ tài sản/đầu ra đủ điều kiện CC0 được đưa vào game.

**Mẫu A và đồ Tripo của quản lý:** chưa nhận được file ở staging; chưa nhập tài sản Tripo, chưa tiêu credit. Khi có file phải bổ sung hồ sơ D-084 (gói trả phí, ngày tạo, task/model ID hoặc ghi rõ Studio không hiện, bản điều khoản và đầu vào hợp lệ) trước khi nghiệm thu.
