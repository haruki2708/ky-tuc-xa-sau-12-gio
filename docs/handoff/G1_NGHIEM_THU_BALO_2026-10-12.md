# Nghiệm thu G1 đạo cụ tĩnh — balo `room407_backpack` (D-085)

> Integrator: Claude (Opus 5.5), 12/10/2026. Phần B do Lane B (Codex) làm trên workspace riêng; B hết hạn mức trước khi commit nên **Claude làm thay phần commit/push/ghép**, không sửa nội dung. Kết quả full test/check của bản ghép ghi trong commit D-085.

## 1. Điều kiện G1 (REVIEW_G1_2026-10-11 / D-081 / D-083) và kết quả

| Điều kiện | Bằng chứng | Kết quả |
|---|---|---|
| Schema/validator C bắt đủ R1–R4 | D-083; integrator chạy lại độc lập các ca review và biến thể | Đạt |
| B chuyển dữ liệu balo sang schema G1, số đo từ đo thật | `art_source/graphics_upgrade/backpack_g1_manifest.json` (`t210-g1-static-1`, `room407_backpack`); số đo probe C trên GLB: size (0.29, 0.4564, 0.3027) m, min (−0.145, 0.01, −0.1325) m, scale (1,1,1), 96 tam giác, 3 vật liệu, 3 texture 128² | Đạt; lệch target < 0.00004 m, dưới tolerance khai 0.0001 m |
| Binding/placement đối chiếu scene thật | `backpack_g1/facing_report.json`: Node3D `Room407/Details/Trung/Backpack` trong floor4, (33.78, 0.02, −4.52), yaw +90°, scale 1 | Đạt |
| Hướng mặt trước chốt trước khi có mẫu Tripo | `TRIPO_BACKPACK.md` mục "Hướng mặt trước": trước **−Z**, lên **+Y**, pivot (0,0,0); 4 ảnh Forward+ 1280×720. Integrator đã xem ảnh trước (túi phụ xám xanh), sau (hai quai đen), cạnh (túi về −Z, quai về +Z) | Đạt |
| Cùng một artifact qua công cụ C; ca sai bị bắt | `asset_qa.py backpack_g1_manifest.json --probe-log ...`: `errors: ["material budget exceeded"]`, `status: FAIL`, exit 1 (balo cũ 3 > 2 vật liệu). Không lỗi schema/kiểu/scale/tolerance/geometry khác. Integrator chạy lại probe C trên `D:\GAME_DEMO` (`build/graphics/d085-probe.log`): cùng kết quả. Dùng log probe của workspace khác thì validator báo thêm `stale dependency` cho cache `.scn`: đúng, vì cache import mỗi máy/thư mục khác nhau, **probe phải chạy trên chính checkout được kiểm** | Đạt (đây là ca âm tính đúng, **không** phải QA PASS của balo cũ) |
| Không nới trần/sai số, không đổi cảnh chơi | Trần D-079, tolerance ≤ 0.001 m giữ nguyên; balo trong bản chơi không đổi; probe chụp ảnh nằm ở `game/scenes/levels/graphics_pilot/` | Đạt |

**Kết luận: đóng G1 cho đạo cụ tĩnh `room407_backpack`.** Rig, settings, chuông (W1–W4) vẫn mở, không thuộc G1 này. Lane C còn một việc không chặn: `asset_id` khác hoa/thường (`Room407_Backpack`) không bị áp profile balo (D-083).

## 2. Giới hạn bằng chứng đã biết
Công cụ C còn 368 mục `unavailable` cho balo cũ: 315 `missing_dependency_hash` + 43 `dependency_closure_unproven` (validator quét cả closure scene floor4 trong `binding.scene_path`, còn probe chỉ hash dependency của GLB; cache `.scn` nhị phân không giải mã được) và 10 cổng duyệt tay. Đây là giới hạn đã khai trong `tools/graphics/G1_SCHEMA.md`, không phải lỗi dữ liệu B. Không thêm hash giả hay đổi binding để thành PASS.

## 3. Tiêu chí đạt cho mẫu balo Tripo (G2)
Mẫu Tripo được coi là **đạt kỹ thuật G2** khi đủ cả 6 điều:
1. **Hồ sơ D-084 đủ:** gói trả phí, ngày tạo, task/model ID (hoặc "Studio không hiện"), bản lưu điều khoản lúc tạo, prompt/ảnh đầu vào hợp lệ, credit từng lượt; không quá 5 lượt tạo. Theo `TRIPO_STUDIO_HUONG_DAN_BALO.md` mục 5.
2. **Công cụ C: `errors: []`** (công cụ nhận nhãn ngoại lệ `LicenseRef-Tripo-Paid-D-084` từ 12/10) trên manifest G1 của mẫu mới (provider `tripo`, channel `studio`) với probe GLB mới: dưới 3001 tam giác, ≤ 2 vật liệu, map ≤ 1024², file ≤ 10 MiB, root scale (1,1,1), bounds trong tolerance ≤ 0.001 m quanh target ở mục 1.
3. **`unavailable` chỉ còn** các cổng duyệt tay và mục closure của scene production chưa thay; **không** còn mục thiếu/chưa chứng minh nào thuộc chính GLB mới, file `.import`, texture, vật liệu của nó. Mẫu G2 nằm ở thư mục prototype riêng, binding vào cảnh pilot, nên closure floor4 chưa bắt buộc ở G2 (bắt buộc ở G3 khi thay vào bản chơi). **Làm rõ 12/10:** cache import `.scn` nhị phân của GLB mới luôn ra `dependency_closure_unproven` (công cụ chưa giải mã được, giống balo cũ); mục này chấp nhận ở G2 nếu GLB, `.import` và texture của mẫu đều có hash. Binding của mẫu G2 vẫn trỏ ô balo trong floor4 (chỗ sẽ thay ở G3).
4. **Hướng:** 4 ảnh cùng camera/ánh sáng như `backpack_g1/` cho thấy túi ở −Z, đỉnh +Y; không dùng scale âm hay xoay root gameplay.
5. **Ảnh trong game:** cặp ảnh trước/sau cùng góc trong phòng 407 (cảnh pilot, Forward+), chủ dự án xem.
6. Full `tools/test.ps1` và `tools/check.ps1` đạt; không đổi gameplay/collision/nav.

Đạt 6 điều thì chủ dự án quyết định có thay balo trong bản chơi (G3) và có tiếp hướng Tripo cho đồ khác không. FPS chỉ đo khi chủ dự án cho phép.
