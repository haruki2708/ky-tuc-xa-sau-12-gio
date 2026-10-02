# T-111 — Xem giấy tờ cận cảnh và sổ tay
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: done | Agent:
- Nhánh: `lane-d/T-111-document-view-notebook`
- Phụ thuộc: **T-128 (lane D) xong trước**, T-110 (done). Đọc `docs/design/RULES.md` mục 3 ("Cách nhận ra dòng giả") và `docs/design/RULE_SYSTEM.md` mục "Dùng từ các lane" và "Giấy tờ".
- Làm song song với T-129 (lane A) và T-130 (lane E). Integrator ghép ở T-117.

## Mục tiêu
1. Người chơi đọc giấy tờ **rõ, sắc nét** ở độ phân giải đầy đủ (D-005), nhìn ra được kiểu giấy: đánh máy có dấu đỏ, bản photo, viết tay, giấy dán tường.
2. Sổ tay (phím Tab) ghi các dòng nội quy đã đọc **theo từng nguồn**, đánh dấu được dòng nghi ngờ. Đây là công cụ chính để đối chiếu, tìm dòng giả.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/`

## Yêu cầu
1. **Màn xem giấy `game/ui/document/document_view.tscn`** (CanvasLayer khoảng 15: trên filter PS1 và HUD, dưới menu tạm dừng 20):
   - Nghe `EventBus.document_opened(id)`, đọc `DocumentData.load_by_id(id)`.
   - Hiện: tiêu đề `tr(title_key)` (nếu có), các dòng luật đánh số 1..n với chữ `tr(RuleSystem.get_rule(rule_id).text_key)`, rồi các đoạn `tr(text_keys)`.
   - **Kiểu giấy theo `style`:**
     - `stamped`: giấy trắng, chữ đánh máy, **dấu tròn đỏ** "Ký túc xá – Tầng 4";
     - `photocopy`: giấy xám hơi bẩn, chữ hơi nhòe hoặc lệch;
     - `handwritten`: giấy kẻ ô, chữ viết tay (font OFL hỗ trợ tiếng Việt nếu có, nếu không thì nghiêng);
     - `notice`: giấy A4 dán băng keo;
     - `log`: trang sổ có dòng kẻ.
     
     Làm bằng UI (StyleBox, Label, TextureRect vẽ tạm), không cần ảnh ngoài. Ghi nguồn font mới vào `CREDITS.md`.
   - Khi mở: `get_tree().paused = true`, hiện chuột, emit `EventBus.game_paused(true)`. Đóng bằng `interact` (E, chuột trái), `pause` (Esc) hoặc `notebook` (Tab). Khi đóng: bỏ dừng, emit `game_paused(false)` và `EventBus.document_closed(id)`.
   - **Esc khi đang xem giấy chỉ đóng giấy, không mở menu tạm dừng.** Lane D sở hữu cả hai nên tự phối hợp.
   - Chữ đổi ngay khi đổi ngôn ngữ.
2. **Sổ tay `game/ui/notebook/notebook.tscn`** (cùng tầng với màn xem giấy):
   - Phím `notebook` (Tab) mở hoặc đóng; dừng game giống màn xem giấy. Không mở khi menu tạm dừng hoặc màn xem giấy đang mở.
   - Liệt kê `RuleSystem.read_entries()`, **gom theo nguồn** theo thứ tự lần đầu thấy nguồn đó. Tên nguồn (thêm key): `SOURCE_SPEAKER` "Loa phát thanh", `SOURCE_HALL_BOARD` "Bảng nội quy hành lang", `SOURCE_ROOM_PAPER` "Giấy dán sau cửa phòng 407", `SOURCE_HANDWRITTEN_NOTE` "Giấy viết tay kẹp ở bảng", `SOURCE_WASHROOM_NOTICE` "Giấy dán trong nhà vệ sinh". Nguồn lạ thì hiện tên kỹ thuật.
   - Mỗi mục hiện `tr(text_key)` của mục đó (không phải chữ gốc của luật, vì loa có thể đọc bị rè) và một nút **"Nghi ngờ"** gọi `RuleSystem.set_suspected(rule_id, …)`. Dòng bị nghi ngờ có dấu hiệu rõ (gạch, đánh dấu đỏ).
   - Cập nhật khi có `EventBus.rule_entry_added`, `rule_suspicion_changed` và khi đổi ngôn ngữ.
   - Sổ tay trống thì hiện câu hướng dẫn: "Chưa ghi gì. Đọc nội quy để ghi vào sổ."
   - **Không bao giờ hiển thị `is_fake`.**
   - Gợi ý lần đầu: khi `rule_read` lần đầu tiên, gửi phụ đề `SUB_NOTEBOOK_HINT` "Đã ghi vào sổ tay (Tab)".
3. **Test `game/tests/ui/`:**
   - `document_opened` hiện đúng tiêu đề, số dòng, đúng chữ, đúng kiểu; đóng thì emit `document_closed` và bỏ dừng game.
   - Esc khi xem giấy chỉ đóng giấy, menu tạm dừng không mở.
   - Sổ tay gom đúng nguồn; mục điều 3 nghe từ loa (`RULE_3_GARBLED`) hiện chữ rè; nút Nghi ngờ đổi `RuleSystem.is_suspected`.
   - Không mở sổ tay khi menu tạm dừng đang mở.
   - Dùng `game/data/rules/demo.tres` và các file trong `game/data/documents/`; tự `RuleSystem.reset()` khi dọn.
4. **Scene thử** `game/ui/notebook/notebook_test.tscn` (F6): nút mở từng tờ giấy, nút giả lập "loa đọc 5 điều" (gọi `mark_read` với nguồn `speaker`, điều 3 dùng `RULE_3_GARBLED`), mở sổ tay.
5. Ảnh chụp: từng kiểu giấy và sổ tay có ít nhất 2 nguồn, tiếng Việt.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh chụp đủ kiểu giấy và sổ tay
- [x] Không chạm file ngoài phạm vi; `CREDITS.md` nếu có font mới
- [x] Mục Handoff đã điền, kèm "Yêu cầu thay đổi" (gắn màn xem giấy và sổ tay vào `main.tscn`)

## Handoff (agent điền)

### Đã làm
- Lane D, ngày 2026-10-02; nhánh `lane-d/T-111-document-view-notebook`, tạo từ `origin/main` tại `6cf176c`. Commit triển khai `1dc37f3` đã push.
- Thêm `document_view.tscn`: nhận `document_opened`, tải `DocumentData`, dịch tiêu đề/dòng luật/đoạn văn; hỗ trợ đủ năm kiểu giấy, đóng bằng E/chuột trái/Esc/Tab và phát đúng signal đóng/dừng game.
- Thêm `notebook.tscn`: Tab mở/đóng, gom nguồn theo lần xuất hiện đầu, giữ `text_key` của từng mục (bao gồm chữ loa rè), nút Nghi ngờ và dấu đỏ đồng bộ giữa các nguồn; xử lý sổ trống, đổi ngôn ngữ và gợi ý lần đọc đầu. Không hiển thị `is_fake`.
- Hai màn dùng CanvasLayer 15, phối hợp với pause menu để Esc chỉ đóng màn đang đọc. Tái sử dụng font Be Vietnam Pro sẵn có; kiểu viết tay dùng chữ nghiêng. Không thêm font/asset bên ngoài, plugin, autoload hay input action.
- Thêm scene F6 `game/ui/notebook/notebook_test.tscn`, 17 key VI/EN và 10 test UI. Các ảnh kiểm chứng cùng `.import` đã commit qua LFS.

### Kiểm tra
- `pwsh tools/test.ps1`: **RESULT: 144 passed, 0 failed**.
- `pwsh tools/check.ps1`: **RESULT: check 0 error(s)**.
- Test bao phủ dữ liệu giấy thật, tín hiệu đóng/dừng, xung đột Esc với cả hai thứ tự node, E/Tab/chuột trái, chặn mở khi đang có màn khác, nhóm nguồn/chữ rè, đổi ngôn ngữ, click thực tế vào nút Nghi ngờ, gợi ý một lần và scene F6; dọn bằng `RuleSystem.reset()`.
- Đã render và xem trực tiếp cả sáu ảnh tiếng Việt: [dấu đỏ](../../game/ui/document/previews/stamped_vi.png), [bản photo](../../game/ui/document/previews/photocopy_vi.png), [viết tay](../../game/ui/document/previews/handwritten_vi.png), [giấy dán](../../game/ui/document/previews/notice_vi.png), [trang sổ](../../game/ui/document/previews/log_vi.png), [sổ tay hai nguồn](../../game/ui/notebook/previews/notebook_vi.png).
- Cách thử: mở `notebook_test.tscn`, F6; chọn từng giấy, đóng bằng các phím trên; chọn giả lập loa rồi mở sổ tay, đánh dấu Nghi ngờ. Bản photo + loa cho ít nhất hai nguồn và mục điều 3 bị rè.
- Tái tạo ảnh: chạy Godot với scene trên, `--write-movie <thư mục>/frame.png --fixed-fps 30 -- --reading-capture=<style> --quit-after-frames=5`; `<style>` là `stamped`, `photocopy`, `handwritten`, `notice`, `log` hoặc `notebook`. Chế độ này dùng tiếng Việt, không lưu thay đổi ngôn ngữ vào cài đặt.
- Lượt test đầy đủ đầu tiên có một lỗi metadata texture kit do Godot tự đổi `green_paint.png.import`; đã khôi phục nguyên bản Git và chạy lại đạt kết quả trên. Không commit thay đổi ngoài phạm vi. Check còn cảnh báo cache UID texture trong model và dùng đường dẫn thay thế; không có lỗi parse.
- Đây là test tự động và kiểm tra ảnh render; chưa chơi thử thủ công trong scene main đã tích hợp.

### Còn lại / giới hạn
- Không còn checklist chưa đạt, không bị chặn ở phạm vi Lane D.
- Repo hiện có bốn giấy gameplay; chưa có `duty_log.tres`. Nút/ảnh `log` dùng `DocumentData` tạm với câu mô tả thử giao diện trung tính, không bổ sung luật hay cốt truyện. Nội dung sổ trực thật chờ lane sở hữu dữ liệu.

### Yêu cầu thay đổi
- **Integrator (T-117):** instance đúng một `res://ui/document/document_view.tscn` và một `res://ui/notebook/notebook.tscn` ở gốc `main.tscn`; giữ layer 15, trên filter PS1 (5)/HUD (10), dưới pause menu (20). Lane D không tự sửa scene main.
- **Phối hợp Lane A/core:** nạp bộ luật demo trước tương tác; đồ vật đọc gọi `DocumentData.mark_rules_read()` rồi phát `EventBus.document_opened(id)` theo hợp đồng hiện có. Màn xem giấy chỉ hiển thị, không tự ghi luật lần nữa; scene F6 mô phỏng đúng luồng này.
- Không cần thay đổi signal, autoload, input action hay cài đặt dự án. Không có câu hỏi mới về luật chơi/cốt truyện.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`, kèm một sửa lỗi tích hợp do Claude làm thay (chủ dự án đồng ý).** Sau merge và ghép: `test.ps1` → `RESULT: 166 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi. Màn xem giấy đủ 5 kiểu, chữ sắc nét; sổ tay gom theo nguồn, giữ chữ rè của loa, nút Nghi ngờ đánh dấu đỏ, không lộ `is_fake`. Lớp chung `reading_overlay.gd` lo việc dừng game và chuột; menu tạm dừng nhường Esc. 10 test, 6 ảnh.
- `strings.csv`: xung đột cuối file với key T-117/T-129, đã gộp (92 key, không trùng).
- **Lỗi tích hợp tìm ra khi ghép với Player thật (T-129):** đóng giấy bằng E lúc *nhấn* thì game chạy lại ngay trong khung hình đó; Player vẫn thấy `interact` "vừa nhấn" và đang nhìn tờ giấy, nên **mở lại ngay**, người chơi bị kẹt. Test riêng của lane D không thể bắt được vì không có Player. **Claude sửa** (commit `d57d0ce`): `document_view.gd` đóng khi *nhả* `interact`; Esc và Tab vẫn đóng khi nhấn. Test UI của lane D vẫn PASS.
- **Integrator đã ghép (T-117):** `DocumentView`, `Notebook` vào `main.tscn`. Test core `test_reading_the_door_paper_opens_and_closes_cleanly`: Player trong phòng nhìn tờ giấy, E mở, E đóng và không mở lại, Tab mở sổ tay, Esc đóng sổ tay mà không mở menu tạm dừng.

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 4 (thiếu kịch bản cùng Player, nhưng khi đó Player chưa có giấy để đọc) · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0 (sửa do integrator làm khi ghép).
