# T-156 — Panel câu đố và gắn chứng cứ trong sổ tay
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-156-puzzle-panels-evidence`
- Phụ thuộc: T-155 (làm ngay sau). Đọc `docs/design/STORY.md` §4 (sổ tay gắn chứng cứ) và §10.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Hai panel câu đố của chương 1 (tủ sắt khóa số, hộp cầu dao), và sổ tay cho phép gắn giấy tờ đã đọc làm chứng cứ cho dòng nội quy đang nghi ngờ.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/tests/ui/`, thêm key vào `game/localization/strings.csv`.

## Hợp đồng có sẵn (T-150, không sửa)
- `EventBus.puzzle_opened(id)`, `puzzle_closed(id)`, `puzzle_solved(id)`.
- `PuzzleData.load_by_id(id)`: `kind` (`combination` hoặc `fuse_box`), `title_key`, `solution`, `label_keys`, `hint_document`, `check(answer)`. Dữ liệu: `locker_combo_601`, `fuse_box_6`.
- `RuleSystem.set_evidence(rule_id, document_id, pinned)`, `evidence_for(rule_id)`, `EventBus.rule_evidence_changed(rule_id)`.
- `DocumentData.load_by_id(id)`; giấy đã đọc báo qua `EventBus.document_opened(id)`.

## Yêu cầu
1. **Panel câu đố** (`ui/puzzle/puzzle_panel.tscn`):
   - Mở khi có `puzzle_opened(id)`: tạm dừng điều khiển người chơi như màn xem giấy, nhả chuột.
   - Esc hoặc nút Đóng thì phát `puzzle_closed(id)`.
   - **`combination`:**
     - 3 vòng số 0–9, bấm lên/xuống hoặc lăn chuột trên từng vòng;
     - nhập đủ là tự kiểm tra `check()`, không cần nút "Thử";
     - sai thì có tiếng lạch cạch (signal cho lane E hoặc dùng âm có sẵn) và rung nhẹ.
   - **`fuse_box`:**
     - một cần gạt cho mỗi phần tử `label_keys`, nhãn đọc được;
     - bấm để gạt; có cần "Thử điện" hoặc kiểm tra mỗi lần gạt (chọn cách rõ hơn, ghi lý do vào Handoff);
     - sai kiểu quá tải thì hiện chữ nhảy aptomat, tất cả gạt về tắt.
   - Đúng thì phát `puzzle_solved(id)` rồi tự đóng sau khoảng 0,8 giây.
   - Có `hint_document` thì hiện nút xem gợi ý, mở giấy đó bằng màn xem giấy hiện có. Giấy chưa tồn tại thì ẩn nút, không lỗi.
   - Có thể dùng chỉ bằng chuột; chữ không bị filter PS1.
2. **Sổ tay gắn chứng cứ** (`notebook.gd` hiện có):
   - Dòng đang đánh dấu nghi ngờ có nút "Gắn chứng cứ". Bấm thì hiện danh sách giấy tờ **đã đọc trong đêm này**, chọn để gắn hoặc gỡ.
   - Dưới mỗi dòng hiện tên các giấy đã gắn. Bấm vào tên thì mở lại giấy đó.
   - Danh sách giấy đã đọc: lấy từ `document_opened` trong đêm. Đề xuất API `snapshot()`/`restore()` cho checkpoint như điện thoại, hoặc yêu cầu integrator thêm vào `RuleSystem` (ghi vào Handoff).
3. **Song ngữ:** đủ key `vi` và `en`.
4. **Test:**
   - panel số giải đúng/sai; panel cầu dao giải đúng/sai;
   - phát đúng signal; Esc đóng;
   - gắn và gỡ chứng cứ cập nhật `RuleSystem` và vẽ lại sổ tay;
   - không lỗi khi thiếu `hint_document`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh chụp hai panel và sổ tay có chứng cứ (vi và en)
- [ ] Handoff: API, phần chưa thử, yêu cầu cho integrator

## Handoff (agent điền)
