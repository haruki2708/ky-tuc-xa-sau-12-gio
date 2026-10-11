# T-210 — sửa R1–R4 theo D-082

Workspace `D:\GAME_WORK\lane-c`, nhánh `lane-c/T-210-graphics-asset-qa`. Workspace sạch trước fetch; rebase thành công lên `origin/main` `1b63c61` có D-082. Phần `7af1075` được giữ nguyên nội dung qua commit rebase `7255b40` (`git cherry` xác nhận patch tương đương); probe `b86a77d` đã nằm trong main, không sửa lại. Integrator hiện hành: **Claude Code (Opus 5.5)**.

## Fixture trước và sau sửa

`test_review_r1r4.py` dựng file GLB tối thiểu có JSON chunk, import config, cache cảnh dạng text và đồ thị reference importer → material → texture/shader/include, cùng wrapper scene/script. Mỗi ca mất hash chỉ xóa đúng một đường. Các ca stale sửa đúng file còn giữ hash. Ca gỡ hash rồi sửa importer là fixture riêng.

Đã chạy cùng tập fixture trên bản công cụ lấy nguyên từ **`7af1075`** và bản sửa; snapshot đầy đủ tại [r1r4_fixtures.json](r1r4_fixtures.json). “Lọt” dưới đây nghĩa là không phát hiện vi phạm mới (`errors=[]` và không có lý do dependency cụ thể), **không gọi INCOMPLETE là PASS**.

| Review | Sửa | Fixture chính | Trước sửa | Sau sửa |
|---|---|---|---|---|
| R1 | Unit scale với epsilon 0,00001 không đơn vị; tolerance balo hữu hạn trong [0; 0,001] m, tách riêng scale | `r1_double_root_and_dimensions`, `r1_tolerance_100_and_size_99`, `r1_scale_cannot_borrow_position_tolerance` | INCOMPLETE, lỗi kỹ thuật lọt | FAIL, chỉ rõ `root_scale`/`tolerance_m` |
| R2 | Profile D-079 3001 exclusive / 2 material / 1024 px; manifest không tự tăng trần. Asset khác vẫn có budget/basis riêng chờ contract review | `r2_self_declared_inflated_limits`, `r2_inflated_{triangle_limit_exclusive,material_limit,texture_edge_limit}` | INCOMPLETE, lỗi kỹ thuật lọt | FAIL, chỉ rõ budget vượt trần |
| R3 | Dựng tập đường kỳ vọng từ file nguồn/import/scene, không dựa trên hash còn có; missing/unproven có đường cụ thể, stale báo FAIL | `r3_removed_importer_then_changed`, `r3_missing_{importer,material,texture,include,wrapper}`, `r3_opaque_cache_closure` | INCOMPLETE nhưng không chỉ ra dependency thiếu | INCOMPLETE với đúng đường dependency/import cache |
| R4 | Thực thi type/const/range và mọi keyword schema đang dùng; `parameters` là object chứa JSON hữu hạn, `rights_evidence` là array string cho mọi provider | `r4_rights_evidence_42_{self_authored,tripo,meshy}`, `r4_parameters_array_{self_authored,tripo,meshy}`, `r4_schema_range`, `r4_schema_nested_parameters` | INCOMPLETE, lỗi kiểu/range lọt | FAIL có đường field, không crash |

Những ca đã bị bắt ở bản cũ vẫn FAIL sau sửa: tolerance âm/NaN/Infinity; năm dependency stale khi còn hash; const pose sai, boolean giả số trong vector và vector sai độ dài. Không ghi chúng là lỗi mới phát hiện. Bảy ca dương tính gồm đồ thị dependency tĩnh đầy đủ, epsilon scale ở biên, tolerance 1 mm, asset khác có budget riêng, và metadata của ba provider. Các ca dương tính không có lỗi kỹ thuật; vẫn INCOMPLETE do các cổng duyệt thủ công. Fixture tĩnh đầy đủ còn xác nhận không xuất hiện cờ missing/unproven dependency.

## Kết quả chạy

- Trước sửa: **42/42 test cũ OK**; snapshot mới tái hiện các lỗ hổng của review.
- Sau sửa: `python -B -m unittest discover -s tools/graphics -p 'test_*.py' -v`: **82 tests OK, exit 0** = 42 ca cũ + **33 ca âm tính, 7 ca dương tính mới**. Đây là số test method; vài ca cũ có nhiều subtest.
- Log offline: `build/graphics/r1r4-tests.log`; snapshot nguồn `r1r4-before.json`, `r1r4-after.json`; công cụ cũ chỉ sao vào thư mục build của C, không sửa repo tích hợp.
- Nhận xác nhận bàn giao lượt từ **Opus 5.5** qua chủ dự án; APPDATA riêng cho import/check, test runner vẫn dùng vùng fixture riêng.
- `pwsh tools/test.ps1`, 11/10 UTC+7 **22:28:20–22:48:31**: **RESULT: 746 passed, 0 failed**, exit 0, kết quả thực của lượt C này.
- `pwsh tools/check.ps1`, **22:48:50–22:55:41**: **RESULT: check 0 error(s)**, **345 script parse PASS**, exit 0. Không dùng kết quả lượt trước hoặc của integrator thay lượt này.
- Kiểm mẫu balo với log full test mới: **FAIL, exit 1**, lỗi duy nhất `material budget exceeded` (balo cũ 3 > 2 material). Còn 368 mục unavailable gồm các cổng thủ công và dependency scene/cache chưa được chứng minh; quét scene lấy cả nhánh ngoài balo, nên không coi GLB probe là bằng chứng wrapper/scene đầy đủ. Log `build/graphics/r1r4-backpack-report.json`.
- **C đã nhả lượt Godot lúc 22:55:41**, xác nhận không còn tiến trình Godot. Không có diff game/âm thanh trong gói sửa. Log full: `build/graphics/r1r4-full-test.log`, `r1r4-full-check.log`; `git diff --check` sạch.
- Đủ điều kiện bàn giao commit `T-210: fix R1R4 schema validation and dependency evidence` trên nhánh task. Giữ thêm quan hệ lịch sử với commit gốc `7af1075` (nội dung đã có qua rebase, không lấy lại nội dung cũ đè bản mới) để push bình thường, không force-push. Hash commit/push đối chiếu Git và thông báo cuối. G1 schema vẫn chờ review/ghép, T-210 chưa done toàn gói.

## Phạm vi và phần chưa kiểm

Không sửa probe/G0, manifest/asset B, core, STATUS/DECISIONS/Review hoặc bất kỳ ngưỡng production nào. Giữ trần D-079 và sai số D-081. Dry-run tiếp tục offline; fixture G0/Studio/API/ví/resume vẫn đạt. Không dùng Tripo, plugin/MCP, render/FPS/bot.

Offline closure không giải mã PackedScene nhị phân hoặc chứng minh dependency động; những trường hợp này phải INCOMPLETE kèm đường cụ thể. Quét scene có thể bao gồm nhánh ngoài node được chọn. Báo cáo GLB riêng không chứng minh wrapper/gameplay đã đo. Schema chỉ là đề xuất chờ Claude review; B chưa chuyển manifest. Chưa có asset Tripo thật, quyền license/ví/ngân sách/operator để nghiệm thu G2. Không có câu hỏi contract mới: áp đúng D-079/D-081; **không còn chặn kiểm/bàn giao R1–R4**. Không dùng kết quả Windows này để nhận đã sửa lỗi nav Linux hoặc nghiệm thu hình ảnh.
