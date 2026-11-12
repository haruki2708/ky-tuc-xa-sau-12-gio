# T-248 — Khảo sát và kế hoạch thay toàn bộ đồ hoạ PS1 bằng đồ hoạ thật (chỉ khảo sát, chưa dựng)
- Lane: A | Trạng thái: todo | Agent: tài khoản GPT lane A (`.codex-accountA`), Codex CLI, `D:\GAME_WORK\lane-a2`; integrator giao chạy ngầm (D-164)
- Nhánh: `lane-a/T-248-realistic-graphics-survey` từ `origin/main` mới nhất.
- Quyết định giao: **D-165** (12/11/2026). Chủ dự án: thay đồ hoạ ký túc xá (các phòng khác, hành lang), các khu ký túc khác, sân, sân bóng đá, nhà ăn, mọi thứ trên map bằng đồ hoạ chân thực như phòng 407 (Blender, Tripo), làm trước phần thân Trần Trung bám cảnh ở chương 3. Làm theo đợt, theo đường người chơi đi; khảo sát và kế hoạch trước, chủ dự án duyệt rồi mới dựng.

## Bối cảnh (đọc trước)
- Đã làm thật: phòng 407 (D-096…D-104, T-213, T-215, T-222; Tripo đợt 1–3 và Blender) và hành lang tầng 4 (T-229 khảo sát → T-233 mẫu → T-235 cả hành lang → T-237 vào cả 4 chương, D-144/D-148). **T-229 là mẫu cho card này**: `docs/tasks/T-229-floor4-corridor-survey.md`, `art_source/graphics_upgrade/floor4_corridor/PLAN.md`.
- Quy trình đồ Tripo (D-088): Tripo chi tiết → bản nhẹ + normal nướng, `art_source/graphics_upgrade/tripo/bake_prop.py`; phiếu Tripo mẫu `docs/handoff/TRIPO_DOT2_PHONG407.md`. Chủ dự án tự tạo đồ trên Tripo, không giới hạn lượt (D-095).
- FPS: `tools/reports/D-114-room407-performance.md`, `D-148-corridor-fps.md`, `T-237-chapter-fps.md` (chương 3 nhìn dọc hành lang ra khuôn viên: 1% thấp nhất 42–57 FPS, chủ yếu do Campus), `T-243-ch2-body-fps.md`.
- Khảo sát thân chương 3: `tools/reports/T-247-ch3-body-survey.md` (dòng 5–10 của bảng cần mô hình mới: ngăn kéo bàn trực, cửa thoát hiểm có ổ khoá và tay nắm, bình cứu hoả, hộp báo cháy, cầu thang, bậu cửa sổ phòng quản lý).
- Thiết kế chương: `docs/design/CH3_DESIGN.md` (map chương 3, quy mô D-054), các file `docs/design/` của chương 2 và 4.

## Phạm vi khảo sát
Mọi khu còn PS1 mà người chơi thấy, ở cả 4 chương. Tìm bằng code và scene, không đoán:
- `game/scenes/levels/floor4/` (các phòng khác của tầng 4, cầu thang, những gì còn PS1 sau T-237);
- `game/scenes/levels/campus/` (`building_b.tscn` nhà B tầng 1–3, cầu thang thoát hiểm và cầu thang chính, sảnh; `garden.tscn`, `stadium.tscn`, `gate.tscn`, `canteen.tscn`, `shells.tscn` các nhà khác, `props.tscn`, `campus.tscn`);
- `game/scenes/levels/library/`, `hospital/`, `cctv/`, `ch2/`, `ch4/` và scene khác mà chương 1–4 dùng (xem `game/scenes/main/chapter*.tscn`);
- nhân vật PS1 còn lại (xác sống, Ngư, Minh Nhật, bảo vệ, sinh viên CCTV…): chỉ ghi danh sách và chỗ xuất hiện, **không lên kế hoạch dựng** (xác sống đã có T-221).

## Sản phẩm
1. **Kế hoạch** `art_source/graphics_upgrade/realistic_map/PLAN.md` (tiếng Việt), giống `floor4_corridor/PLAN.md`:
   - bảng mọi khu: tên, chương dùng, scene và node, kích thước (m), số tam giác và số vật liệu PS1 hiện có, người chơi ở đó bao lâu và nhìn gần hay xa;
   - với mỗi khu: dựng gì bằng Blender (kiến trúc, vật liệu CC0 như phòng 407 và hành lang), đồ nào cần Tripo (danh sách, ước lượng số món), phần động hoặc gameplay phải giữ (cửa, va chạm, lưới dẫn đường, `Ch3Use`, chỗ đặt bot), mức chi tiết (gần, xa, chỉ làm cảnh nền cho các nhà ký túc khác);
   - **chia đợt theo đường người chơi đi** (gợi ý của integrator: nhà B cầu thang, hành lang tầng 1–3, sảnh, các phòng có cảnh truyện → vườn hoa → sân vận động → cổng và nhà ăn → các nhà khác ở mức nhìn xa → khu chương 4), mỗi đợt ước lượng công và rủi ro; đánh dấu các đợt chứa dòng 5–10 của T-247;
   - **ngân sách FPS** từng khu (1080p, mục tiêu ≥ 60 trung bình như D-114/D-148): ước lượng từ số đo đã có, chỗ cần bản nhẹ cho xa gần, chỗ cần che khuất; ghi rõ "chưa đo";
   - **câu hỏi cho chủ dự án** ở cuối, mỗi câu có phương án và một đề xuất (ví dụ phong cách từng khu, mức bẩn cũ, ban đêm hay sương).
2. **Ảnh hiện trạng** `art_source/graphics_upgrade/realistic_map/previews/survey/` (1080p, JPG, ánh sáng của chương), mỗi khu 2–4 tấm ở chỗ người chơi đứng nhiều nhất; tự xem lại từng tấm. Thêm một ảnh tổng hợp nhiều khu.

## Được phép sửa
- `art_source/graphics_upgrade/realistic_map/` (mới), Checklist và Handoff của card này.
- Cảnh tạm chụp ảnh trong `game/_probe_tmp/`: **không commit**, xoá khi xong.

## Không được
- Sửa code, scene, test, level; sửa STATUS, DECISIONS.
- Dựng mô hình, tạo đồ Tripo, tiêu credit Tripo.
- Chạy bot, đo FPS (chỉ ước lượng từ báo cáo có sẵn).
- Commit log, video, `anh_chup_sua_loi/`.
- Commit chỉ có kế hoạch và ảnh nên không cần full test/check; vẫn theo luật Lượt Godot mỗi khi mở Godot.

## Checklist
- [ ] Danh sách mọi khu PS1 lấy từ scene thật, kèm số tam giác, vật liệu, kích thước
- [ ] Ảnh hiện trạng từng khu, đã tự xem lại
- [ ] PLAN.md: cách dựng từng khu, danh sách Tripo, phần gameplay phải giữ, chia đợt, ngân sách FPS
- [ ] Câu hỏi cho chủ dự án có phương án và đề xuất
- [ ] Xoá `game/_probe_tmp/`; push nhánh; Handoff

## Handoff
(lane A điền)
