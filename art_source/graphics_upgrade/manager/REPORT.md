# T-219 — Mẫu C sửa sau review đợt 1 (16/10/2026)

Đã có mẫu C MPFB, sáu động tác CC0 dùng chung, scene thân theo `body_scene` và cảnh xem riêng trong phòng 407. Đây là mẫu để đánh giá cách làm; chưa duyệt mỹ thuật và chưa thay thân trong bản chơi. Mẫu A chưa có file ở staging nên chưa có phép so sánh A/C thực tế.

## Ảnh 1920×1080

Forward+ / Vulkan, Godot 4.7.2, RTX 3050 Laptop. Tám ảnh chính đã chụp lại sau sửa; thời điểm và thông số đèn pin thực tế ở [metadata](previews/capture_report.json).

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
| [Khuỷu lấy đà, cận](previews/elbow_windup_close.png) | Kiểm nếp gập và độ liền của tay áo, `slash` 0,10 s |
| [Sáu clip tại giữa thời lượng](previews/six_clips_midpoint.png) | Trái → phải, trên → dưới: stand, walk, ask, slash, lunge, kill; ghép trực tiếp pixel viewport, không sửa hình |

## Đối chứng nguồn và retarget

Trước khi đổi model/animation, đã chụp Quaternius nguyên bản bên trái và C đợt 1 bên phải:

- Nguồn mirror đợt 1: [cặp trước sửa](previews/reference_original_before_front.png).
- Nguồn Standard v3 chính thức: [cặp trước sửa](previews/reference_v3_original_before_front.png).

**Phát hiện:** Idle_Loop nguyên bản cũng khuỵu gối. Blender độc lập đo gối **21,4468°/14,1240°**, bàn chân cách **0,531902 m**; Godot trên cả hai nguồn cho cùng kết quả. Chênh với số 0,36 m trong review là do review đo riêng khoảng cách ngang X, còn bảng này dùng khoảng cách 3D giữa hai xương bàn chân. [Probe Blender](previews/original_blender_probe.json), [baseline C](previews/retarget_before.json).

Chủ dự án đã chuyển xác nhận integrator: **đồng ý sửa retarget + tạo stand nguồn thẳng**. Hai phần được thực hiện riêng:

1. Rest fixer bật silhouette cho cả nguồn/đích với ngưỡng **0,1°** thay mặc định 15°. Không bỏ qua độ gập nghỉ nhỏ ở gối/cột sống/vai; BoneMap vẫn đầy đủ, chuẩn SkeletonProfileHumanoid, không có hiệu chỉnh key riêng theo rig C.
2. `build_motion.py` tạo stand thẳng dùng chung trên rig nguồn CC0; có thở và tay hạ/nắm dao. Hunch chỉ ở Spine/Chest trong bộ thư viện dùng chung. Khi có Tripo sẽ dùng cùng thư viện và cấu hình chuẩn hóa, nhưng vẫn phải kiểm BoneMap/tỷ lệ A thực tế.

Sau sửa, Quaternius và C cùng chạy **chính `manager_shared.tres/stand`**: [cặp sau sửa](previews/reference_shared_after_front.png). Các ảnh [nguồn cũ sau sửa](previews/reference_original_after_front.png) và [nguồn v3 sau sửa](previews/reference_v3_original_after_front.png) giữ Idle gốc ở bên trái, stand mới ở C bên phải để phân biệt thay đổi clip nguồn với thay đổi retarget.

| Đo trên C | Trước | Sau, t=0 | Ngưỡng test |
|---|---:|---:|---:|
| Gối trái / phải | 24,074° / 16,657° | 4,193° / 4,193° | ≤10° mỗi gối |
| Khoảng cách bàn chân 3D | 0,53048 m | 0,21993 m | ≤0,28 m |
| Đầu hạ so với rest tương ứng | 0,11407 m | 0,03927 m | ≤0,05 m |

Test kiểm thêm 25%, 50%, 75%, 99,9% vòng stand. [Số đo sau sửa](previews/retarget_after.json). `slash` mới giữ thân/chân từ Sword_Attack CC0 và chỉnh hai tay trên rig nguồn: lấy đà 0,10 s, mũi dao y=1,813 m > vai y=1,228 m; chạm 0,25 s, mũi dao y=0,277 m < ngực y=0,756 m và z=−0,962 m ở phía trước ngực z=−0,027 m. Scene thân hướng −Z. Clip lặp 0,45 s, BladeTip vẫn theo RightHand, director không đổi.

## FPS

Cùng phương pháp cảnh riêng của [D-114](../../../tools/reports/D-114-room407-performance.md): tầng 4/phòng 407 đủ đồ, hai gương, đèn bàn bật, đèn trần giữ ở đỉnh nhấp nháy; một quản lý hiện và lặp `slash`. Không player/HUD/story. VSync tắt, không giới hạn FPS, 90 frame khởi động + 240 frame đo mỗi góc. Kích thước viewport được ghi lại là **1920×1080**. [Dữ liệu từng frame](previews/fps_report.json).

| Mẫu | Góc | FPS trung bình | p95 thời gian frame | Ngưỡng 60 FPS |
|---|---|---:|---:|---|
| C | `centre` | 90,1 | 11,50 ms | Đạt |
| C | `door_overview` (góc nặng nhất D-114) | 83,8 | 12,27 ms | Đạt |
| A | Cả hai góc | Chưa đo | Chưa có GLB | Chờ đợt 2 |

Các số trên không đại diện chương thật có AI, player, HUD, âm thanh và các nhân vật khác.

Đã đo lại dù số tam giác giảm và số vật liệu giữ nguyên, để kiểm bản có normal da mới. Không có model Quaternius đối chứng trong lượt đo.

## Ngân sách C

| Thành phần | Tam giác |
|---|---:|
| Da/thân/mặt | 8.499 |
| Đồng phục và giày | 11.000 |
| Tóc và lông mày | 1.242 |
| Mắt, đồng tử, thẻ/dây, chìa, mặt khóa thắt lưng | 1.384 |
| Dao phay tạm | 540 |
| **Tổng** | **22.665 / 25.000** |

**4 / 4 vật liệu** trong scene thân; albedo và normal da 2048², đồng phục/giày 2048², tóc/lông mày 1024²; chi tiết/dao dùng màu vertex. [Bảng máy đọc](../../../game/assets/models/characters/manager/manager_c_budget.json). Cao 1,70 m trước retarget, gốc ở chân, scene thân hướng −Z. GLB thân **7.982.276 byte**; `.blend` **7.704.972 byte**; mọi file dưới 10 MiB, nhị phân qua LFS.

## Nguồn và khả năng dựng lại

Nguồn, phiên bản, tác giả, URL và giấy phép từng thành phần: [CREDITS.md](CREDITS.md). Hash các file nguồn giữ lại: [source_manifest.json](sources/source_manifest.json); phiên bản công cụ và mirror động tác: [tool_motion_manifest.json](sources/tool_motion_manifest.json). Hướng dẫn dựng lại và phím điều khiển: [README.md](README.md).

MPFB **2.0.18** cài trong Blender **5.2.2 portable** trên D:. Công cụ MPFB dùng GPL-3.0-or-later; thân/mặt/rig MakeHuman và quần áo/tóc/giày dùng CC0-1.0. Động tác Quaternius Universal Animation Library Standard dùng CC0-1.0. Dao/chìa/thẻ/dây tạm được dựng bằng script Blender, ghi công Codex và công bố CC0-1.0. Không dùng Mixamo, không tạo tác vụ Tripo mới. `%APPDATA%/Blender Foundation` không tồn tại cả trước và sau công việc; dữ liệu tạm Godot/Blender đặt trên D:.

## Nhận xét hình và phần còn lại

| Hạng mục | Mẫu C | Mẫu A |
|---|---|---|
| Mặt | Age 0,68, giảm đầy má/tăng gò má; albedo và normal có nếp trán, khóe mắt, rãnh mũi má. Máu sẫm chia nhánh, mép không đều. Mắt đục với đồng tử nhỏ thấy rõ ở 1 m dưới đèn trần. Tóc short04 thoáng trán, có mép alpha. Cảm giác tuổi/ngoại hình Việt còn cần chủ dự án duyệt bằng mắt; hình vẫn có tính thủ tục, chưa phải chân dung quét. | Chưa nhận file, chưa đánh giá |
| Tay / dao | Dao bám `RightHand`; `BladeTip` theo xương qua cả vòng chém. Ngón tay đã chạy theo động tác gốc, nhưng cách nắm cán còn thô; cần tinh chỉnh sau khi có dao thật. | Chưa kiểm map humanoid hay tay cầm |
| Vai / khuỷu | Trọng số upperarm/lowerarm của vùng khuỷu được tính theo vị trí liên tục, cùng giá trị ở hai mép seam; vùng blend 14 cm dùng smoothstep. Ảnh cận lấy đà cho khuỷu liền và tròn hơn. Vai/nách vẫn có nếp gấp và mảng tối của skinning; không tuyên bố đã có mô phỏng vải. | Chưa đánh giá biến dạng |
| Quần áo | Sơ mi xanh nhạt sơ vin, quần xám, thắt lưng, giày. Vải đi theo skinning, chưa có cloth/corrective shape; cổ/nách/cạp còn thô và có mảng tối rõ khi rọi đèn pin. Thẻ/dây/chìa gắn cứng theo xương, chưa đung đưa. | Chưa đánh giá |

Chưa làm `LeftArm` / `set_reach_weight`, IK mở cửa, mô phỏng vải/đồ đeo, mặt biểu cảm hoặc lip-sync. `kill` hiện là biến thể kết liễu của cùng động tác chém, không phải một màn kết liễu riêng. Mặt kinh dị được bake riêng vào atlas da; mắt dùng mesh/màu vertex để giữ ngân sách 4 material.

Dao vẫn **tạm**: thép xám sẫm, cạnh sáng hẹp, cán gỗ nâu sẫm và đinh tán; bề dày tăng 5 → 8 mm, không thêm tam giác. Bề mặt còn đơn giản; chưa thay bằng dao Tripo.

**Bóng đèn pin:** đã đối chiếu `phone_item.tscn` và override ROOM_TORCH trong `room407.gd`, đồng thời ghi giá trị runtime ngay sau ảnh mặt đèn pin. Cùng shadow enabled=true, bias=0,03, normal bias=1, blur=1, opacity=1; trong phòng cùng light_size=0,025, energy=5, angle=38°, attenuation=1,3, range=10. **Không đổi thông số bóng.** Hiện tượng răng cưa còn thấy theo thiết lập game D-104/D-113; không tăng chất lượng riêng cho ảnh pilot.

**Chờ đợt 2:** `manager_body_rigged.glb`/`manager_body.glb` và dao/chìa/thẻ từ staging, cùng hồ sơ Tripo trả phí D-084. Cảnh/test đã tự nhận `manager_body_a.tscn` nếu có, nhưng chưa chứng minh bộ động tác chạy được trên khung xương A thực tế. Phải map/chuẩn hóa, chụp lại hai mẫu và đo riêng A. Chưa có căn cứ đề nghị tiêu thêm lượt Tripo.

Không có yêu cầu thay đổi core/contract. Kết quả full test/check và commit bàn giao được ghi trong [Handoff T-219](../../../docs/tasks/T-219-manager-character-pilot.md#handoff-agent-điền).
