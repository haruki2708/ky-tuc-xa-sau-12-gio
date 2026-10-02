# T-111 — Xem giấy tờ cận cảnh và sổ tay
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh chụp đủ kiểu giấy và sổ tay
- [ ] Không chạm file ngoài phạm vi; `CREDITS.md` nếu có font mới
- [ ] Mục Handoff đã điền, kèm "Yêu cầu thay đổi" (gắn màn xem giấy và sổ tay vào `main.tscn`)

## Handoff (agent điền)
