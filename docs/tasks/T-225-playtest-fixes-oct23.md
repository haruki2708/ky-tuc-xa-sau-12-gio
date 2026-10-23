# T-225 — Sửa lỗi chơi thử 23/10: ô vuông xám, hộp xôi, thời khóa biểu, khung điện thoại, giá phơi đồ
- Lane: **integrator** (Claude làm thay A/B/D) | Trạng thái: **xong (23/10/2026), chờ chủ dự án chơi bản build mới** | Agent: Claude Code ở máy (Opus 5.5)
- Quyết định: **D-135**. Chủ dự án chơi bản 23/10 01:40: quản lý đã ổn, còn vài lỗi.
- Ảnh chủ dự án chụp: `anh_chup_sua_loi/` ở gốc repo (không đưa vào git).
- Liên quan: [T-223](T-223-playtest-fixes-oct22.md) (khung điện thoại D-133), [T-224](T-224-manager-ch1-beds-chase-physics.md) (đường đi của quản lý).

## Chủ dự án báo (23/10/2026)
> "quản lý đã ổn nhưng có 1 vài chỗ lỗi. 1 : Tôi muốn xoá các ô vuông của tu_do.png(ổ khoá bị chèn), cong_tac_den.png, tu_do_viet.png( ổ khoá bị chèn), tay_nam_cua_phong.png(ô vuông dính sát vào tay nắm cửa làm tôi khônng thể thấy tay nắm cửa, thung_rac.png(ô vuông xuyên qua thùng rác), giong.png, sổ ghi chèn với hộp xôi ( ảnh so_ghi.png), ánh sáng quá sáng không thể nhìn được chữ trong tờ dán(anh_sang_den.png), khung chat và camera vẫn bị thấp quá, không thấy được bên dưới (khung_chat.png)"

Thư mục ảnh còn có `xuyen_qua.png`: đi xuyên qua giá phơi đồ.

## 1. Ô vuông xám, trắng
**Nguyên nhân:**
- Mỗi chỗ tương tác của lane A có một khối hộp đứng tạm.
- Phòng 407 đủ đồ chỉ ẩn khối tạm của chính nó lúc dựng phòng.
- Chương 1 gắn các chỗ tương tác sau đó, nên khối tạm của chúng vẫn hiện.
- Chương 2 tự ẩn khối tạm của nó; chương 2 và 3 dùng lại phần gắn đồ của chương 1.

**Sửa** (`chapter1_director.gd`; `_hide_placeholder` chuyển từ chương 2 lên chương 1):
- ẩn hộp của khóa số tủ Đạt (vẫn thấy ổ khóa số của phòng);
- ẩn hộp lục tìm ở tủ Việt, nệm Phúc, thùng rác;
- ẩn hộp của chốt cửa phòng: thấy lại tay nắm cửa, nhắm vào tay nắm vẫn hiện "khóa cửa";
- ẩn hộp gõ tường 406, nằm sau tủ Việt;
- ẩn hộp che ổ mạng trên tường; mặt ổ mạng có hai lỗ cắm hiện ra.
- **Công tắc đèn bàn:** bỏ hộp nhỏ trên bàn; vùng bấm phủ cả cây đèn bàn Tripo (`room407.gd` `furnished_prop()`), nhắm vào đèn là bấm được.
- **Không đổi:** hai đầu dây mạng xanh và xám. Khối tạm ở đó đóng vai đầu cắm; ẩn đi thì đầu dây chỉ còn 1–2 cm, khó tìm.

## 2. Sổ hợp âm guitar chèn với hộp xôi
- Hộp xôi (`TakeawayBox`, `data/room407/placements.json`) nằm đè lên sổ hợp âm của Việt (anchor `GuitarSongbook`, giấy `ch1_tap_chart`).
- Dời hộp sang góc trái bàn, trước ấm đun nước: (5,09; 0,76; −0,85), không xoay.
- Không đè sổ hợp âm, thẻ của Việt hay giấy nào chương 1 đặt trên bàn.

## 3. Thời khóa biểu cháy trắng dưới đèn pin
- Tờ dán trên tường phía cửa là đồ Tripo `Timetable`. Giấy gần như trắng tuyệt đối (ảnh 0,96).
- Đèn pin 1,5 chiếu gần làm giấy vượt mức sáng tối đa nên mất chữ.
- Thử 3 mức: 1,0 cháy; 0,7 còn cháy một góc; **0,55 đọc được cả khi đèn pin chiếu gần**.
- `room407_furnish.gd` `PAPER_TINT`: giấy và băng dính của thời khóa biểu vẽ ở 0,55 độ sáng gốc. Mô hình dùng chung không bị đổi.
- Đèn pin và các giấy manh mối khác giữ nguyên. Giấy manh mối không bị cháy chữ khi chụp thử ở 0,4 m.

## 4. Khung chat và camera vẫn thấp
**Nguyên nhân:**
- Kiểu B (D-133) đặt khung ở 0,22–0,88 chiều cao màn hình, nhưng trong chương 1 thật khung cao 1310 px, xuống quá mép dưới.
- Vài khung hình đầu khi mới dựng, nội dung điện thoại đòi cao 1310 px.
- Đoạn mã rung điện thoại (`phone_tools.gd` `advance`) gán `position` mỗi khung hình. Godot tính lại cả 4 mép từ kích thước lúc đó, nên giữ luôn chiều cao 1310.
- Ảnh thử T-223 không qua đường này nên vẫn đúng.

**Sửa:**
- Rung chỉ dời hai mép trái phải (`_shift_panel`) và chỉ khi có rung.
- Khung về đúng 0,22–0,88 ở cả 3 tab (chat, sơ đồ, camera).
- Ảnh trong chương 1 thật: `game/ui/phone/previews/t225_chat_camera.jpg`. Thấy dòng hướng dẫn cuối của chat và cả hình camera.

## 5. Đi xuyên giá phơi đồ
- Đồ Tripo chỉ để nhìn; chỗ nào phòng cũ có khối va chạm (giường, bàn, tủ) thì người chơi bị chặn, chỗ khác thì đi xuyên.
- `room407_obstacles.gd` `SOLID` và `make_solid`: thêm khối chặn cho 8 món giá phơi đồ, quạt đứng, kệ giày, gương đứng, cây nước, bàn gấp, kệ nhà tắm, cây lau nhà.
- Khối chặn nằm thụt 5 cm vào trong món đồ, để đường đi của quản lý (cách đồ 0,35 m) không chạm.
- Đồ mềm hoặc nhỏ trên sàn vẫn đi qua được: đống quần áo, balo, vali, quả bóng, nồi, chổi cọ toilet.
- Bồn rửa cũng vẫn đi qua được: nó chìa ra ngay lối vào cửa nhà tắm, chặn thì người chơi vướng ngay sau cửa (test lối vào nhà tắm của chương 1 báo lỗi).
- Khối chặn thêm sau khi dựng đường đi nên đường đi của quản lý không đổi.

## Kiểm tra
- **Ảnh trước/sau**, đèn pin 1,5, đúng các góc trong ảnh chủ dự án: `art_source/graphics_upgrade/room407_shell/previews/compare_t225.jpg`.
- **Test:**
  - `test_chapter1.gd`: không còn hộp nào hiện; vùng bấm công tắc nằm trong cây đèn.
  - `test_phone.gd`: sau một khung hình cao và một lần rung, khung điện thoại về đúng chỗ.
  - `test_room407_obstacles.gd`: 8 món chặn được người chơi. Test đường đi cũ nay chờ bản đồ đường đi cập nhật, vì một lần chạy bị lệch ngẫu nhiên.
  - `test_room407_playable_furnished.gd`: hộp xôi không đè giấy và sổ; thời khóa biểu tối đi, mô hình dùng chung không đổi.
  - Cả bộ: 846/848 lần chạy đầu. Hai lỗi: bồn rửa chặn lối vào nhà tắm (bỏ bồn rửa khỏi đồ chặn) và `test_room407_shell.gd` chưa cho khối chặn mới (đã sửa). Chạy lại 4 file liên quan đều đạt; `check.ps1` 0 lỗi.
