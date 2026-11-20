# T-260 — Occlusion culling: không vẽ những gì bị tường, sàn kín che

Làm ngày 14/11/2026, 13:20–15:00, lane HARU (D-173), nhánh `integrator/T-260-occlusion-culling`. Card: [T-260](../../docs/tasks/T-260-occlusion-culling.md).

## Kết luận
- **Không có lỗi hình:** ảnh tắt/bật cùng camera (28 góc chương 1 và 3) giống hệt từng điểm ảnh, trừ mép cánh quạt đang quay. 5 lượt camera di chuyển qua cửa phòng, sảnh, hai cầu thang (1.279 cặp khung): không vật nào hiện trễ hay nhấp nháy.
- **Nhanh hơn ở các góc nặng:** chương 3 góc chậm nhất từ 62 lên 70 FPS trung bình, 1% khung chậm nhất của góc tệ nhất từ 38 lên 45 FPS. Sảnh tầng 1: 69 → 98 FPS; mở cả 7 cửa tầng 4: 62 → 75; trong 406 nhìn ra hành lang: 82 → 118; dọc ban công: 72 → 100. Số vật vẽ giảm tới một nửa.
- **Chậm đi ở vài góc nhẹ:** khoảng 5% (0,4–0,5 ms mỗi khung) ở 3 góc vốn đã trên 95 FPS (trong phòng 408 và góc xiên cửa 407 ở chương 3, trong 406 nhìn ra ở chương 1, góc này dao động mạnh giữa hai vòng). Đây là chi phí CPU của occlusion culling khi có ít vật để bỏ.
- **Đề xuất: bật trong bản chơi.** Lợi rõ ở những chỗ đang chậm (chương 3, khuôn viên và nhà B), không lỗi hình, chi phí nhỏ ở chỗ đã nhanh. Chủ dự án quyết (D-xxx); nhánh chưa merge.

## Điều đã kiểm trong tài liệu Godot 4.7 (docs.godotengine.org, bản 4.7)
- Bật bằng cài đặt dự án `rendering/occlusion_culling/use_occlusion_culling` (mặc định tắt); lúc chạy bật/tắt được bằng `get_tree().root.use_occlusion_culling` (dùng cho ảnh và đo ở đây).
- Occluder được vẽ trên CPU (thư viện Embree) vào một bộ đệm độ phân giải thấp; một vật chỉ bị bỏ khi **cả hộp bao** của nó bị che. Có chi phí CPU; cảnh rộng, ít chỗ che thì có thể không đáng.
- Hình occluder: `BoxOccluder3D`, `QuadOccluder3D`, `SphereOccluder3D`, `PolygonOccluder3D`, `ArrayOccluder3D`. Nút "Bake Occluders" là nút của editor (dự án làm không cửa sổ), nên occluder ở đây là hộp đặt bằng script.
- Dời hay ẩn occluder lúc chạy phải tính lại mất vài khung: occluder ở đây đứng yên, không gắn vào cánh cửa.
- Vật trong suốt không được bake; với occluder hình khối thì không liên quan.

## Đã làm
- `game/project.godot`: `rendering/occlusion_culling/use_occlusion_culling=true`.
- Cảnh core `game/scenes/main/occlusion/`:
  - `occluders_floor4.tscn` (53 hộp, cả 4 chương): sàn hành lang, sàn các phòng, 407, nhà vệ sinh chung; tường mặt phòng hai bên mỗi lỗ cửa và phần tường trên cửa; vách giữa các phòng 401–408; tường nhà vệ sinh chung.
  - `occluders_campus.tscn` (106 hộp, chương 3–4): sàn giữa các tầng nhà B, vách phòng và mặt trước tầng 1–3 (hai bên lỗ cửa, trên cửa), hai khối tầng 5–6, vỏ kín nhà A, giảng đường, nhà thể chất.
  - Gắn vào `chapter1.tscn`…`chapter4.tscn` (không sửa cảnh của lane B).
- Mỗi occluder nằm trong **một** hộp va chạm tường/sàn/khối đặc (layer 1) của cảnh thật: dày 4 cm giữa bề dày tường, hai đầu lùi 0,1 m (cách lỗ cửa bên cạnh ít nhất 0,1 m); khối đặc lùi 0,3–0,5 m mọi phía.
- Chưa đặt (lý do): tường hậu các phòng (cửa ban công, có thể có cửa sổ nhà tắm); giếng hai cầu thang (cửa sổ, lỗ thông); vách phòng quản lý tầng 1 (khung cửa sổ vẽ chồng qua vách); các vách PS1 cũ đã ẩn; cửa, cửa sổ, kính, lan can, tán cây.
- Sinh lại: `art_source/graphics_upgrade/occlusion/make_occluders.py` (đọc số liệu khảo sát từ `survey.gd`, cách chạy ghi trong file). Nếu lane B dời tường, chạy lại khảo sát và script; test bên dưới báo hỏng nếu quên.

### Bảng khối kín (toạ độ thế giới, m)
| Chỗ | Khối | Ghi chú |
|---|---|---|
| Tầng 4 hành lang | sàn x 0…44, z 0…4, y −0,1 | lan can ở z 4 không đặt |
| Tầng 4 tường mặt phòng | z 0, x 6…44, cao 0…3 | lỗ cửa rộng 2 m tại x 8, 12, … 28, 32, 42; cửa 408 cũ (x 34…38) xây kín |
| Tầng 4 vách giữa phòng | x 6, 10, 14, 18, 22, 26, 30, 38, 44; z 0…−7 | 407 chiếm x 30…38 |
| Nhà vệ sinh chung tầng 4 | x 0…6, z 0…−5 | lỗ ra vào x 2,4…3,6 |
| Nhà B tầng 1–3 | sàn y −6,7, −3,4, −0,2; x 0…44, z −7,6…4 | giếng thang ở x < 0 và x > 44, ngoài vùng |
| Nhà B vách phòng tầng 1–3 | x 0, 5,5, 11, … 44; z 0…−7,6 | trừ x 5,5 tầng 1 (phòng quản lý) |
| Nhà B mặt trước tầng 1–3 | z 0 | lỗ cửa rộng 1,7 m tại x 2,75 + 5,5k |
| Nhà B tầng 5–6 | khối x 0…44, y 3,3…9,6, z −7,6…4 | cửa sổ vẽ trên mặt khối |
| Nhà A, giảng đường, nhà thể chất | vỏ kín | cửa sổ trên mặt ngoài; occluder lùi 0,5 m |

## Kiểm hình
- Ảnh tắt/bật cùng camera (`art_source/graphics_upgrade/occlusion/capture.gd`), cảnh chương thật, thời gian gần như dừng (`Engine.time_scale = 0.0001`; để 0 thì một script khuôn viên chia cho delta, sinh NaN và treo Godot), đèn pin trên camera, 1920 × 1080.
  - Chương 1: 13 góc (hai đầu hành lang, cửa 406 mở, cả bảy cửa mở hai hướng, trong 408, 402, 406, ban công 404, 407 hai hướng, nhà vệ sinh chung, góc xiên cửa 407): **0 điểm ảnh khác** (ngưỡng 24/255).
  - Chương 3: 15 góc (hành lang tầng 4, nhìn ra khuôn viên, từ tầng 4 xuống vườn, hai cầu thang, hành lang tầng 3, 2, cửa tầng 3, sảnh, phòng quản lý, từ vườn lên nhà B, từ vườn sang nhà A, góc xiên phía tây, 407): 13 góc 0 điểm ảnh khác, 1 góc 1 điểm ảnh, góc 407 0,004% (mép cánh quạt trần và quạt đứng).
  - Ảnh ghép: `art_source/graphics_upgrade/occlusion/previews/compare_ch1.jpg`, `compare_ch3.jpg` (trái tắt, phải bật); ảnh gốc `off_*.jpg`, `on_*.jpg`.
- Lượt camera di chuyển (0,03 m mỗi khung, cùng đường đi hai lần, tắt rồi bật; khung lưu ở `build/haru/t260_walk/`, không commit): hành lang vào 407, hành lang vào 402, vườn vào sảnh rồi dọc tầng 1, xuống cầu thang chính, hành lang ra cầu thang thoát hiểm. Không có vật hiện trễ. Chỗ khác chỉ do: cánh quạt; cánh cửa 402 đang mở dở (thời gian gần dừng nên cánh cửa ở góc khác giữa hai lượt); **hai khung đường đi xuyên qua vách nhà B tầng 1** (camera nằm trong tường, trùng mặt occluder, nên Godot coi mọi thứ bị che). Người chơi không vào được giữa tường (capsule bán kính 0,3 m, occluder nằm sâu trong tường 0,08 m); camera kịch bản (nếu có) không nên đi xuyên tường.
- Số liệu vẽ (ảnh tĩnh): chương 1 dọc hành lang 497 → 247 nghìn tam giác; cả bảy cửa mở 2,08 → 0,75 triệu; chương 3 tầng 2 1,98 → 1,15 triệu, sảnh 1,85 → 1,04 triệu.

## Đo FPS
Cách đo của [T-255](T-255-rooms-fps.md): RTX 3050 Laptop (4 GB), Forward+, cửa sổ 1920 × 1080, tắt vsync, không giới hạn FPS; cảnh chương thật, director không chạy, người chơi và giao diện ẩn. Mỗi góc: 90 khung khởi động, 240 khung đo cho mỗi chế độ. Vòng 1 tắt trước rồi bật, vòng 2 bật trước rồi tắt; bảng là trung bình hai vòng. Lúc đo không lane nào chạy Godot, không Chrome, Blender; còn 5,9 GB RAM trống. Script `art_source/graphics_upgrade/occlusion/fps.gd`, số gốc `build/haru/t260_fps_ch*_r*.json` (không commit). Hai vòng lệch nhau tới ±15% ở vài góc, nên chỉ coi khác biệt trên 10% là rõ.

| Góc | Tắt: TB | Bật: TB | Khác | Tắt: 1% thấp | Bật: 1% thấp | Vật vẽ tắt/bật |
|---|---|---|---|---|---|---|
| ch1 01 hành lang từ tây, cửa đóng | 163,7 | 160,3 | −2% | 95,6 | 96,7 | 2.772 / 2.558 |
| ch1 02 hành lang từ đông, cửa đóng | 151,1 | 179,3 | +19% | 89,8 | 113,0 | 2.750 / 2.410 |
| ch1 03 cửa 406 mở, đèn pin | 154,6 | 158,2 | +2% | 111,1 | 102,0 | 2.885 / 2.729 |
| ch1 04 cửa 405, 406 mở | 156,8 | 165,4 | +6% | 111,4 | 104,4 | 2.450 / 2.198 |
| ch1 05 cả bảy cửa mở, từ tây | 127,8 | 152,2 | +19% | 78,0 | 108,7 | 4.276 / 3.392 |
| ch1 06 cả bảy cửa mở, từ đông | 126,8 | 139,4 | +10% | 77,6 | 83,5 | 4.374 / 3.563 |
| ch1 07 trong 408 | 178,3 | 184,1 | +3% | 144,9 | 147,3 | 874 / 870 |
| ch1 08 trong 402 | 224,1 | 225,3 | +1% | 186,9 | 193,5 | 292 / 275 |
| ch1 09 trong 406 nhìn ra | 178,3 | 165,4 | −7% | 120,2 | 101,8 | 2.090 / 1.849 |
| ch1 10 dọc ban công 404 | 151,7 | 210,2 | +39% | 98,4 | 152,3 | 2.689 / 2.161 |
| ch1 11 trong 407 nhìn ra cửa | 126,8 | 131,9 | +4% | 85,8 | 108,5 | 2.031 / 1.926 |
| ch1 12 góc xiên cửa 407 | 156,4 | 174,6 | +12% | 100,8 | 118,8 | 2.258 / 2.047 |
| ch3 01 hành lang từ tây, cửa đóng | 75,2 | 85,8 | +14% | 48,0 | 56,2 | 5.769 / 4.433 |
| ch3 02 hành lang từ đông, cửa đóng | 89,8 | 102,0 | +14% | 54,5 | 73,2 | 4.028 / 3.330 |
| ch3 03 cửa 406 mở | 112,8 | 112,2 | −1% | 69,0 | 87,8 | 3.485 / 3.273 |
| ch3 04 cửa 405, 406 mở | 111,7 | 122,4 | +10% | 65,7 | 83,0 | 2.994 / 2.664 |
| ch3 05 cả bảy cửa mở, từ tây | 62,2 | 75,3 | +21% | 37,7 | 51,7 | 7.708 / 5.784 |
| ch3 06 cả bảy cửa mở, từ đông | 77,8 | 81,7 | +5% | 54,3 | 50,6 | 6.082 / 4.882 |
| ch3 07 trong 408 | 152,4 | 144,0 | −6% | 109,3 | 88,2 | 1.955 / 1.307 |
| ch3 08 trong 402 | 183,1 | 188,9 | +3% | 124,2 | 101,2 | 365 / 325 |
| ch3 09 trong 406 nhìn ra | 82,4 | 117,8 | +43% | 49,9 | 84,6 | 4.366 / 2.814 |
| ch3 10 dọc ban công 404 | 71,7 | 100,3 | +40% | 44,9 | 73,0 | 5.336 / 3.462 |
| ch3 11 trong 407 nhìn ra cửa | 81,8 | 101,8 | +24% | 49,0 | 67,5 | 4.304 / 2.859 |
| ch3 12 góc xiên cửa 407 | 104,6 | 99,0 | −5% | 68,5 | 60,8 | 3.318 / 2.804 |
| ch3 c1 hành lang đông nhìn ra khuôn viên | 90,2 | 94,8 | +5% | 62,0 | 59,5 | 4.018 / 3.279 |
| ch3 c2 từ tầng 4 xuống vườn | 153,9 | 202,4 | +32% | 93,3 | 141,1 | 1.278 / 516 |
| ch3 c3 hành lang tầng 3 | 91,2 | 101,7 | +11% | 61,1 | 68,4 | 3.921 / 3.263 |
| ch3 c4 sảnh tầng 1 | 69,3 | 98,3 | +42% | 43,0 | 64,8 | 5.377 / 3.356 |
| ch3 c5 từ vườn nhìn lên nhà B | 86,4 | 87,8 | +2% | 57,6 | 53,1 | 4.048 / 4.016 |
| ch3 c6 từ vườn sang nhà A | 153,8 | 207,8 | +35% | 95,0 | 152,1 | 1.143 / 638 |
| ch3 c7 góc xiên phía tây khuôn viên | 66,1 | 70,5 | +7% | 39,8 | 45,0 | 5.759 / 5.608 |

- Chương 3 vẫn còn góc dưới 75 FPS trung bình (c7 70,5; 05 75,3) và 1% thấp dưới 60 ở nhiều góc: phần còn lại chủ yếu do khuôn viên (cây, đồ, khối nhìn từ xa) mà occluder hiện có không che được. Lượt sau có thể thêm occluder cho tường hậu nhà B (cần kiểm cửa sổ) và giếng thang, hoặc dùng `visibility_range` cho đồ khuôn viên.

## Kiểm (test)
- `game/tests/core/test_t260_occlusion.gd`: cài đặt bật; mỗi chương có cảnh occluder đúng (tầng 4 cả bốn chương, khuôn viên chương 3–4); mỗi occluder là hộp; ở chương 1 và 3 thật, **mỗi occluder nằm trong một hộp va chạm đặc layer 1**, không giao với hình của cửa phòng, cửa nhà tắm, ban công, buồng vệ sinh, cửa thoát hiểm, cửa chính, cửa sổ, lan can, và cách mắt (1,0 m và 1,65 m) ở các điểm xuất phát `seg*_start`, `Start_*` và chỗ đứng đầu chương ít nhất 0,3 m. Chương 2 và 4 dùng cùng hai cảnh occluder và cùng tầng 4, khuôn viên.
- Full test **988 passed, 0 failed** (14/11 15:05–15:35), check **0 lỗi** (15:53), trên nhánh (main không đổi từ khi tách nhánh).

## Bổ sung 16/11/2026: khối che vỏ nhà ăn (sau T-263, D-181)
Integrator thêm **13 hộp che** cho nhà ăn vào `occluders_campus.tscn` (nay 119 hộp), sinh bằng `make_occluders.py`: mái, tường đông (`Side210`), ba đoạn tường sau, tường bếp và kho, hai đoạn tường tây hai bên lối tây. **Không đặt** ở tường trước (10 cửa sổ kính trong và cửa chính) và sàn. Hai hộp cạnh cửa sau kho thu ngắn 0,4 m mỗi đầu vì khung cửa mới phủ lên tường 0,3 m.

Kiểm bằng cảnh thử `build/integrator/canteen_occ.gd` (chương thật, director giữ, thời gian gần như dừng, 1920 × 1080, đèn pin): chụp cùng camera khi tắt rồi bật occlusion culling, so từng điểm ảnh (ngưỡng 6/255 mỗi kênh). **22 góc (18 ở chương 3, 4 ở chương 4): không điểm ảnh nào khác.**

| Góc (chương 3) | Lần vẽ tắt → bật | Tam giác tắt → bật |
|---|---|---|
| Sảnh nhìn tây (TV) | 5.595 → 3.991 | 2,17 → 1,58 triệu |
| Sảnh nhìn lối tây | 5.802 → 3.674 | 2,11 → 1,49 triệu |
| Sảnh nhìn cửa sổ trước (chéo) | 4.932 → 3.277 | 1,84 → 1,10 triệu |
| Góc sảnh đông bắc nhìn tây nam | 4.948 → 862 | 1,84 → 0,22 triệu |
| Bếp nhìn chéo | 5.738 → 4.276 | 2,10 → 1,72 triệu |
| Kho nhìn vào sảnh | 4.784 → 475 | 1,58 → 0,12 triệu |
| Ngoài phía đông nhìn vào | 5.843 → 682 | 2,12 → 0,13 triệu |
| Sảnh nhìn quầy và bếp | 891 → 202 | 111 → 99 nghìn |
| Chương 4: sảnh nhìn lối tây | 5.726 → 481 | 2,10 → 0,10 triệu |

- Số "tắt" là không có khối che nào; số "bật" gồm cả 106 hộp cũ và 13 hộp mới (không đo riêng phần của 13 hộp mới).
- Nhìn thẳng tường tây từ giữa sảnh vẫn còn khoảng 4.000 lần vẽ: qua lỗ lối tây và các cửa sổ trước vẫn thấy một phần khuôn viên, và vật lớn chỉ bị bỏ khi bị che hết.
- Test: `test_t260_occlusion` 5/0 (thêm bài riêng cho nhà ăn: đủ 13 hộp, không hộp nào chạm tường trước, lối tây, lỗ sang bếp, sang kho, cửa sau kho), `test_t263` 12/0, `test_campus` 5/0. **Chưa chạy full test và check** cho thay đổi này (chỉ đổi cảnh khối che của core và test của nó); sẽ chạy ở lần merge kế tiếp.
- Không đo FPS (D-179).

## Bổ sung 20/11/2026: khối che thư viện (sau T-265, D-185/D-186)
Integrator thêm **25 hộp che** cho thư viện vào `occluders_campus.tscn` (nay 144 hộp), sinh bằng `make_occluders.py`: 21 hộp lúc merge T-265, 4 hộp sàn tầng 1 thêm tối cùng ngày sau lần chụp bật/tắt dưới đây. Luật `LIBRARY` chạy sau `CAMPUS`, nên id các hộp cũ giữ nguyên; `occluders_floor4.tscn` không đổi (53 hộp). Chỗ đặt theo mục "Mặt đặc kín" lane B ghi ở Handoff T-265: bốn tường ngoài chỉ có hai lỗ thật là cửa trước và cửa sau (x 64…66, y −9,9…−7,5); mọi cửa sổ là kính tối `W7GlassDark` (đục) nằm trong bề dày tường; sàn chỉ hở ở ô cầu thang; mái kín.

| Mặt | Hộp | Đặt ở |
|---|---|---|
| Tường tây, đông (tầng 1–3) | `Library_West0…2`, `Library_East0…2` | mặt giữa tường |
| Tường trước (bốn khúc quanh lỗ cửa chính) | `Library_FrontW`, `FrontE`, `Front1`, `Front2` | z 194,97 (nửa ngoài tường) |
| Tường sau (bốn khúc quanh lỗ cửa sau) | `Library_BackW`, `BackE`, `Back1`, `Back2` | z 225,03 (nửa ngoài tường) |
| Sàn tầng 1 (y −10,02): ba mảnh, và `StairBase` dưới ô cầu thang | `Library_Floor0_Main/South/North`, `Library_StairBase` | mặt giữa sàn |
| Sàn tầng 2 (y −6,72) và tầng 3 (y −3,42), ba mảnh mỗi tầng, chừa ô cầu thang x 79…85, z 199…209 | `Library_Floor1_Main/South/North`, `Library_Floor2_Main/South/North` | mặt giữa sàn |
| Mái | `Library_Roof` | mặt giữa |

- Tường trước và sau dùng kiểu mới `plane|at=<z>` của `make_occluders.py`: mặt che đặt ở nửa ngoài tường, không ở mặt giữa. Lý do: kính tối nằm trên mặt giữa (z 195, 225), còn lớp `Windows` của vỏ (rèm, song) đi từ mặt kính vào trong, nên hộp ở mặt giữa sẽ chạm lớp đó. Script kiểm hộp vẫn nằm trong bề dày tường.
- Sàn tầng 1: dưới nó không có gì để che. Nhưng khi thiếu hộp ở đó, tia nhìn xuống sàn tầng 1 không gặp hộp nào, nên bộ đệm che bị thủng ở vùng sàn và khuôn viên sau tường vẫn được vẽ. Lần chụp dưới đây cho thấy điều này, nên 4 hộp này được thêm sau.
- Không đặt ở lanh tô trên hai lỗ cửa (chỉ cách khung cửa 2 cm).
- Test: `test_t260_occlusion` thêm bài riêng cho thư viện. Bài này kiểm đủ 25 hộp, và không hộp nào chạm lỗ cửa trước, sau (khung x 63,92…66,08, tới y −7,42) hay ô cầu thang (x 79…84,89, z 199…209, tầng 2–3). Hộp tường trước, sau phải nằm ngoài mặt kính. Bài chương 3 thật vẫn kiểm mọi hộp: nằm trong một hộp va chạm đặc, không chạm cửa, cửa sổ, lan can, cách điểm xuất phát.
  - Với 21 hộp: lọc `t26` 72/0; full test sau merge T-265 1072/0; check 0.
  - Với 25 hộp: lọc `t260` 6/0. Chỉ đổi cảnh khối che của core và test của nó, nên chưa chạy full test; chạy ở lần merge kế tiếp.

**Chụp bật/tắt** (chủ dự án cho, 20/11 tối), bằng cảnh thử `build/integrator/library_occ.gd`:
- Chạy trong chương thật, director giữ, khung 1600 × 900 như ảnh lane B. Cho chạy 3 giây rồi mới gần như dừng thời gian, vì trong vài giây đầu chương, các góc nhìn ra khuôn viên vẽ thêm khoảng 650 lần (chưa tìm vì sao).
- Mỗi góc chụp cùng camera khi tắt rồi khi bật occlusion culling với đủ 25 hộp, so từng điểm ảnh (ngưỡng 6/255 mỗi kênh). Góc trong nhà chụp cả không và có đèn pin (12 m, 28°).
- Góc chụp: 25 góc lane B dùng ở T-265 lượt 2 và 3 (cả cửa sau mở, từ ngoài nhìn vào và từ trong nhìn ra) ở chương 4, và 5 góc ở chương 3.
- **52 lần chụp (47 ở chương 4, 5 ở chương 3): không điểm ảnh nào khác.** Lần chụp trước đó với 21 hộp cũng không có điểm ảnh nào khác.

Số lần vẽ, không đèn pin, mỗi góc đo liền nhau trong cùng một trạng thái. Cột "không hộp thư viện" là lúc lane B đo, và khớp số ở Handoff T-265 lượt 2 (ví dụ tầng 1 toàn cảnh 631, giữa tầng 2 3.924, ba góc đợt 7: 1.374; 276; 4.660).

| Góc | Tắt | Bật, không hộp thư viện | Bật, 21 hộp | Bật, 25 hộp |
|---|---|---|---|---|
| Ch. 4: cửa sau mở, từ ngoài nhìn vào | 4.816 | 4.574 | 709 | 375 |
| Ch. 4: ngay trong cửa sau mở, nhìn vào tầng 1 | 4.817 | 4.532 | 633 | 300 |
| Ch. 4: tầng 1 toàn cảnh (chân cầu thang) | 781 | 628 | 369 | 199 |
| Ch. 4: quầy tầng 1 | 4.249 | 3.830 | 467 | 134 |
| Ch. 4: giữa tầng 2 nhìn về mặt trước | 4.270 | 3.916 | 152 | 152 |
| Ch. 4: tầng 2 nhìn xuống ô cầu thang | 4.792 | 4.554 | 189 | 189 |
| Ch. 4: giữa tầng 3 nhìn về nam | 4.254 | 3.821 | 171 | 171 |
| Ch. 4: đầu nhịp một nhìn xuống khe đông | 4.792 | 4.619 | 3.179 | 3.181 |
| Ch. 4: trong cửa chính nhìn ra sân | 4.756 | 4.556 | 4.120 | 4.118 |
| Ch. 4: ngoài sân dọc tường tây | 4.812 | 4.622 | 4.175 | 4.145 |
| Ch. 4: ngoài sân nhìn mặt trước | 148 | 148 | 135 | 134 |
| Ch. 3: khán đài tây nhìn thư viện | 83 | 83 | 74 | 74 |
| Ch. 3, đợt 7: hành lang tầng 4 nhà B | 1.371 | 1.361 | 1.361 | 1.361 |
| Ch. 3, đợt 7: giữa vườn | 298 | 276 | 276 | 276 |
| Ch. 3, đợt 7: trên khán đài | 4.657 | 4.651 | 4.651 | 4.652 |

- Các góc trong nhà nhìn ra khuôn viên giảm từ khoảng 3.800–4.600 xuống 130–380 lần vẽ.
- Hai góc nhìn ra sân (qua kính cửa chính, và ngoài sân dọc tường tây) vẫn cao, vì phần khuôn viên đó thấy thật.
- Góc đầu nhịp một nhìn xuống khe đông còn 3.181 lần vẽ (lane B đo 5.294 ở lượt 3); 4 hộp sàn tầng 1 không giảm. Có thể tia lọt qua chỗ nối các hộp tường theo tầng: mỗi hộp lùi 0,1 m ở mép, nên giữa hai tầng còn khe 0,2 m ngay cạnh khe đông. Chưa kiểm. Góc này chỉ thấy lúc đi lên nhịp một.
- Ba góc toàn cảnh đợt 7 không đổi khi thêm khối che thư viện (không tăng). Góc vườn vẫn hơn trước đợt 8 866 primitive (+0,5 %): đó là tường ngoài và cửa chính thư viện thấy từ 190 m, khối che không bỏ được thứ đang thấy. Review T-265 lượt 2 đã chấp nhận.
- Không đo FPS (D-179).
