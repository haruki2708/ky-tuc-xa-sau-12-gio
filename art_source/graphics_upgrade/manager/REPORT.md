# T-219 — Kết quả mẫu C, đợt 1 (16/10/2026)

Đã có mẫu C MPFB, sáu động tác CC0 dùng chung, scene thân theo `body_scene` và cảnh xem riêng trong phòng 407. Đây là mẫu để đánh giá cách làm; chưa duyệt mỹ thuật và chưa thay thân trong bản chơi. Mẫu A chưa có file ở staging nên chưa có phép so sánh A/C thực tế.

## Ảnh 1920×1080

Forward+ / Vulkan, Godot 4.7.2, RTX 3050 Laptop. Bộ ảnh ghi lúc `2026-10-15T18:06:06Z` (01:06 ngày 16/10 ở Việt Nam). [Metadata](previews/capture_report.json).

| Ảnh | Nội dung |
|---|---|
| [Toàn thân, đèn trần](previews/full_body_tube.png) | C bên phải; bên trái dành cho A |
| [Mặt 1 m, đèn trần](previews/face_1m_tube.png) | Da, vệt máu, mắt |
| [Toàn thân, đèn pin](previews/full_body_flashlight.png) | Chiếu sáng D-113 |
| [Mặt 1 m, đèn pin](previews/face_1m_flashlight.png) | Tư thế hỏi cúi đầu; kiểm chi tiết khi bị rọi gần |
| [Chém: lấy đà](previews/slash_windup.png) | `slash` ở 0,10 s |
| [Chém: hạ dao](previews/slash_contact.png) | `slash` ở 0,25 s |
| [Chém: thu tay](previews/slash_recovery.png) | `slash` ở 0,38 s |
| [Đèn trần nhấp nháy](previews/tube_flicker.png) | Một frame của chế độ nhấp nháy |

## FPS

Cùng phương pháp cảnh riêng của [D-114](../../../tools/reports/D-114-room407-performance.md): tầng 4/phòng 407 đủ đồ, hai gương, đèn bàn bật, đèn trần giữ ở đỉnh nhấp nháy; một quản lý hiện và lặp `slash`. Không player/HUD/story. VSync tắt, không giới hạn FPS, 90 frame khởi động + 240 frame đo mỗi góc. Kích thước viewport được ghi lại là **1920×1080**. [Dữ liệu từng frame](previews/fps_report.json).

| Mẫu | Góc | FPS trung bình | p95 thời gian frame | Ngưỡng 60 FPS |
|---|---|---:|---:|---|
| C | `centre` | 90,9 | 11,52 ms | Đạt |
| C | `door_overview` (góc nặng nhất D-114) | 84,0 | 12,30 ms | Đạt |
| A | Cả hai góc | Chưa đo | Chưa có GLB | Chờ đợt 2 |

Các số trên không đại diện chương thật có AI, player, HUD, âm thanh và các nhân vật khác.

## Ngân sách C

| Thành phần | Tam giác |
|---|---:|
| Da/thân/mặt | 8.499 |
| Đồng phục và giày | 10.999 |
| Tóc và lông mày | 2.450 |
| Mắt, đồng tử, thẻ/dây, chìa, mặt khóa thắt lưng | 1.384 |
| Dao phay tạm | 540 |
| **Tổng** | **23.872 / 25.000** |

**4 / 4 vật liệu** trong scene thân; texture da 2048², đồng phục/giày 2048², tóc/lông mày 1024²; chi tiết/dao dùng màu vertex. [Bảng máy đọc](../../../game/assets/models/characters/manager/manager_c_budget.json). Cao 1,70 m ở rest pose, gốc ở chân, scene thân hướng −Z. GLB thân 7.633.680 byte; `.blend` 7.360.580 byte; mọi file dưới 10 MiB, nhị phân qua LFS.

## Nguồn và khả năng dựng lại

Nguồn, phiên bản, tác giả, URL và giấy phép từng thành phần: [CREDITS.md](CREDITS.md). Hash các file nguồn giữ lại: [source_manifest.json](sources/source_manifest.json); phiên bản công cụ và mirror động tác: [tool_motion_manifest.json](sources/tool_motion_manifest.json). Hướng dẫn dựng lại và phím điều khiển: [README.md](README.md).

MPFB **2.0.18** cài trong Blender **5.2.2 portable** trên D:. Công cụ MPFB dùng GPL-3.0-or-later; thân/mặt/rig MakeHuman và quần áo/tóc/giày dùng CC0-1.0. Động tác Quaternius Universal Animation Library Standard dùng CC0-1.0. Dao/chìa/thẻ/dây tạm được dựng bằng script Blender, ghi công Codex và công bố CC0-1.0. Không dùng Mixamo, không tạo tác vụ Tripo mới. `%APPDATA%/Blender Foundation` không tồn tại cả trước và sau công việc; dữ liệu tạm Godot/Blender đặt trên D:.

## Nhận xét hình và phần còn lại

| Hạng mục | Mẫu C | Mẫu A |
|---|---|---|
| Mặt | Có da xám, vệt máu từ chân tóc, mắt đục và đồng tử nhỏ. Tuy dùng macro nam trung niên/châu Á, hình hiện tại vẫn trẻ hơn mục tiêu khoảng 45 tuổi; chưa đủ căn cứ duyệt nét Việt. Thiếu chi tiết nếp nhăn/normal; tóc còn thành khối. Đèn pin ở 1 m làm da sáng gắt và giảm chi tiết. | Chưa nhận file, chưa đánh giá |
| Tay / dao | Dao bám `RightHand`; `BladeTip` theo xương qua cả vòng chém. Ngón tay đã chạy theo động tác gốc, nhưng cách nắm cán còn thô; cần tinh chỉnh sau khi có dao thật. | Chưa kiểm map humanoid hay tay cầm |
| Vai / khuỷu | Vai xoay được qua ba pha chém; nếp gập tay áo phải ở ảnh lấy đà còn gãy và lộ đường nối. Chưa đạt mức hoàn thiện để quay cận động tác. | Chưa đánh giá biến dạng |
| Quần áo | Sơ mi xanh nhạt sơ vin, quần xám, thắt lưng, giày. Vải đi theo skinning, chưa có cloth/corrective shape; cổ/nách/cạp còn thô và có mảng tối rõ khi rọi đèn pin. Thẻ/dây/chìa gắn cứng theo xương, chưa đung đưa. | Chưa đánh giá |

Chưa làm `LeftArm` / `set_reach_weight`, IK mở cửa, mô phỏng vải/đồ đeo, mặt biểu cảm hoặc lip-sync. `kill` hiện là biến thể kết liễu của cùng động tác chém, không phải một màn kết liễu riêng. Mặt kinh dị được bake riêng vào atlas da; mắt dùng mesh/màu vertex để giữ ngân sách 4 material.

**Chờ đợt 2:** `manager_body_rigged.glb`/`manager_body.glb` và dao/chìa/thẻ từ staging, cùng hồ sơ Tripo trả phí D-084. Cảnh/test đã tự nhận `manager_body_a.tscn` nếu có, nhưng chưa chứng minh bộ động tác chạy được trên khung xương A thực tế. Phải map/chuẩn hóa, chụp lại hai mẫu và đo riêng A. Chưa có căn cứ đề nghị tiêu thêm lượt Tripo.

Không có yêu cầu thay đổi core/contract. Kết quả full test/check và commit bàn giao được ghi trong [Handoff T-219](../../../docs/tasks/T-219-manager-character-pilot.md#handoff-agent-điền).
