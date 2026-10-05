# Kịch bản chương 2 "Trò chơi"

> **Tạm duyệt (D-048), sửa theo góp ý chơi thử D-049…D-051** (gõ từ, từ điển lớn, nhắn dự đoán).** Sinh tự động từ `docs/design/ch2/build_ch2_script.py` (từ nối ở `word_bank.py`). Thiết kế: `docs/design/CH2_DESIGN.md` (D-046, D-047).

Ký hiệu: **Loa** · *(trong phòng)* = giọng nghe trực tiếp · 📞 = trong cuộc gọi · 💭 = suy nghĩ của Trung (chỉ phụ đề) · ▶ = lựa chọn · `[…]` = diễn biến.

## Nhân vật trong cuộc gọi
| Tên | Ở đâu | Kết cục chương 2 |
|---|---|---|
| Lý Minh Nhật | 203 nhà B | Sống nếu Trung nhắn đúng dự đoán |
| Khương Ngọc Ngư | 401 nhà A | Sống nếu Trung nhắn đúng dự đoán |


## Mở đầu chương 2 — 6:00

- **06:00** `[Tiếp ngay sau chương 1: Trung nằm trên giường của bạn đã chết, cuộc gọi với Minh Nhật và Ngư vẫn mở. Checkpoint `ch2_r3`.]`
- **06:00** **Loa:** Quy tắc vòng hai kết thúc. Số người sống sót hiện tại: hai mươi tám người.
- **06:00** 📞 **Minh Nhật · 203:** Hai mươi tám… Cả trường mấy nghìn người mà còn hai mươi tám.
- **06:00** **Loa:** Công việc kiểm tra phòng kết thúc. Đến giờ giải trí rồi. Chúng ta chơi nối từ nhé.
- **06:01** **Loa:** Bốn người trong mỗi phòng bắt buộc tham gia. Nối lần lượt theo chiều kim đồng hồ, mỗi lượt dưới mười lăm giây.
- **06:01** **Loa:** Từ nối là từ hai tiếng. Tiếng đầu phải trùng tiếng cuối của từ trước, đúng cả dấu.
- **06:01** **Loa:** Trong ba lượt liền nhau không được lặp từ. Ai không nối được, chết.
- **06:01** 📞 **Ngọc Ngư · 401 nhà A:** Bốn người? Phòng mình chỉ còn mỗi mình sống mà…
- **06:02** `[Ba xác Phúc, Việt, Đạt cùng ngồi dậy trong vũng máu, mắt trống rỗng, quay về phía Trung (jumpscare 1). Lời của xác là giọng méo, không có trong cuộc gọi.]`
- **06:02** 📞 **Minh Nhật · 203:** Bạn cùng phòng tôi… ngồi dậy rồi. Nó đang nhìn tôi.
- **06:02** 📞 **Ngọc Ngư · 401 nhà A:** Bên mình cũng vậy. Ba đứa. Mắt trắng dã.
- **06:02** `[Lượt mở đầu cố định (N1). Phúc: "điểm danh". Việt: "danh sách". Đạt: "sách vở", rồi quay sang nhìn Trung. Trung có 15 giây để gõ một từ bắt đầu bằng "vở" (ví dụ "vở kịch").]`
- **06:02** 💭 Vở… vở gì… nghĩ đi…
- **06:03** `[Từ đây trò chơi chạy liên tục tới 7:00. Mỗi lượt của Trung: gõ một từ bằng bàn phím (bộ gõ của máy), 15 giây; từ phải có trong từ điển (D-049, D-051). Gõ sai hoặc hết giờ thì chết (DEATH_CH2_CHAIN_WRONG / DEATH_CH2_CHAIN_TIMEOUT). Ở nhà vệ sinh hoặc ban công thì không trả lời được.]`
- **06:04** 📞 **Minh Nhật · 203:** Đừng nghĩ lâu. Mười lăm giây trôi nhanh lắm.

## Vòng 3 — 6:05 đến 7:00: nối từ

- **06:06** `[Lần đầu một xác bí lời (do Trung gõ một từ mà xác không biết từ nào nối tiếp, hoặc do bị bịt miệng): xác ú ớ hết 15 giây, gục xuống, 10 giây sau bật dậy và bắt đầu chuỗi mới (jumpscare 3).]`
- **06:08** 📞 **Ngọc Ngư · 401 nhà A:** Nó gục rồi lại ngồi dậy… Chúng nó chết rồi thì sợ gì thua. Chỉ có tụi mình là không được sai.
- **06:09** 📞 **Minh Nhật · 203:** Một tiếng. Tụi mình phải đúng suốt một tiếng.
- **06:12** `[Camera an ninh (D-046): điện thoại rung, CAM 310. Sinh viên phòng 310 im lặng quá 15 giây; ba xác cùng lao vào (jumpscare 4).]`
- **06:12** 📞 **Minh Nhật · 203:** Phòng 310… Cậu ấy không nói kịp. Đừng nhìn nữa.
- **06:20** `[N3: Ngư kể nửa đầu manh mối (D-046). Không ai nói tiếp ý "bịt miệng".]`
- **06:20** 📞 **Ngọc Ngư · 401 nhà A:** Mình vừa nối vừa kéo tay đứa cùng phòng. Nó chẳng phản ứng gì, chỉ lo nối từ.
- **06:20** 📞 **Minh Nhật · 203:** Cậu… gan thật đấy.
- **06:20** `[Giẻ lau (nhà vệ sinh), khăn tắm (ban công), áo của Việt (tủ Việt). Cầm một món, tới sát xác, bấm E: bịt miệng (N4). Bịt lúc xác đang nói thì nó quay sang nhìn chằm chằm (jumpscare 2).]`
- **06:35** `[N5: Minh Nhật gửi vòng lặp vào nhóm (giữ trong lịch sử chat). Chỉ có ích khi cả ba xác đã bị bịt: khi đó chuỗi chỉ còn từ của Trung.]`
- **06:35** 📞 **Minh Nhật · 203:** Tôi nghĩ ra một vòng không bao giờ hết: học sinh, sinh viên, viên phấn, phấn đấu, đấu tranh, tranh luận, luận văn, văn học… rồi lại học sinh. Lái về chữ "học" rồi cứ thế lặp.
- **06:36** 📞 **Ngọc Ngư · 401 nhà A:** Không cần nghĩ nữa. Cứ lặp thôi.
- **06:40** `[Đi trọn một vòng 8 từ (cả ba xác đã bị bịt) thì cắt thời gian trống, nhảy tới 7:00 (D-040).]`
- **06:50** 📞 **Minh Nhật · 203:** Nhóm im hết rồi. Chỉ còn tín hiệu của ba đứa mình.

## 7:00 — hết vòng 3

- **07:00** **Loa:** Quy tắc vòng ba kết thúc. Số người sống sót hiện tại: năm người.
- **07:00** `[Ba xác gục xuống giường. Checkpoint `ch2_r4`.]`
- **07:00** 📞 **Ngọc Ngư · 401 nhà A:** Năm người… Cả trường còn năm người.

## Vòng 4 — 7:00 đến 8:00: tắm nước nóng

- **07:00** **Loa:** Trò chơi gắn kết tình bạn kết thúc. Đến giờ tắm nước nóng cho thoải mái rồi.
- **07:01** **Loa:** Mời mọi người vào nhà vệ sinh. Vòng này không có yêu cầu nào khác: chỉ cần thời gian xả nước vượt quá hai mươi lăm phút.
- **07:01** **Loa:** Chúc các bạn tắm vui vẻ.
- **07:01** `[N6: cửa nhà vệ sinh kẹt. Đẩy vai 3 lần; lần 3 cửa bật mở, hơi nóng phụt ra (jumpscare 5).]`
- **07:01** 💭 Kẹt rồi… cửa phồng hết lên.
- **07:02** `[Vòi sen mất công tắc, thay bằng màn hình (UI_CH2_SHOWER_RULE). 30 lượt, mỗi lượt 2 phút trong game. Chọn Có thì phải đứng trong buồng tắm cả lượt; từ 50 độ là chết bỏng (DEATH_CH2_SCALDED); bước ra là chết (DEATH_CH2_SHOWER_BROKEN); không chọn là chết (DEATH_CH2_NO_CHOICE). Tới 8:00 chưa đủ 25 phút là chết (DEATH_CH2_SHORT_SHOWER).]`
- **07:02** 📞 **Ngọc Ngư · 401 nhà A:** Nghĩa là nếu chọn xả, bao nhiêu độ cũng phải đứng chịu hai phút.
- **07:02** 📞 **Minh Nhật · 203:** Khoan xả đã. Xem nó ra số gì.
- **07:04** `[Không ai nói quy luật (D-046). Màn hình giữ toàn bộ lịch sử nhiệt độ. Dãy: 67, 37, 8, 81, 96, 58, 37, 1, 19, 4, 43, 74, 19, 9, 94, 35, 86, 41, 52, 79, 63, 94, 31, 45, 91, 7, 71, 83, 13, 42.]`
- **07:04** 📞 **Minh Nhật · 203:** Sáu mươi bảy độ… Chọn bừa là chín người.
- **07:10** 📞 **Ngọc Ngư · 401 nhà A:** Không thể là ngẫu nhiên. Luật nào cũng có kẽ hở, mấy vòng trước đều vậy.
- **07:20** 📞 **Minh Nhật · 203:** Hơi nước mù hết màn hình rồi. Lau đi mà đọc.
- **07:18** `[Nhắn dự đoán (D-050, D-051), thay cho đoạn cứu Ngư cũ: lần đầu Trung tắm an toàn 3 lượt liền nhau (dãy chuẩn: sau lượt 9, 7:18; chưa đạt thì lúc 7:40). Minh Nhật rồi Ngư gửi 3 nhiệt độ gần nhất bên họ; Trung gõ "có", "không" hoặc khoảng như "3x", mỗi người 20 giây. Sai hoặc hết giờ thì người đó bỏng và Trung thua (DEATH_CH2_LOST_NHAT / DEATH_CH2_LOST_NGU).]`
- **07:18** 📞 **Minh Nhật · 203:** Trung, cậu tắm ba lượt liền mà không sao. Cậu tìm ra quy luật rồi phải không? Bên tôi ba lần gần nhất: 38, 16, 75. Lượt tới tôi chọn gì? Nhắn cho tôi.
- **07:18** 📞 **Minh Nhật · 203:** …Hai mươi ba độ. Sống rồi. Cảm ơn cậu.
- **07:18** 📞 **Minh Nhật · 203:** Nóng! Trung, cậu nhắn sai rồi…!
- **07:19** 📞 **Ngọc Ngư · 401 nhà A:** Loa điện thoại mình bị nước vào rồi… Trung! Bên mình: 74, 15, 62. Lượt tới chọn gì? Nhắn nhanh lên!
- **07:19** 📞 **Ngọc Ngư · 401 nhà A:** …Tám mươi mốt độ. May mà mình không xả. Cảm ơn cậu, Trung.
- **07:19** 📞 **Ngọc Ngư · 401 nhà A:** Nóng! Nóng quá… Trung…!

## 8:00 — hết chương 2

- **08:00** **Loa:** Quy tắc vòng bốn kết thúc. Số người sống sót hiện tại: ba người.
- **08:00** 📞 **Minh Nhật · 203:** Ba người. Cả trường… chỉ còn ba đứa mình.
- **08:00** 💭 Còn một giờ nữa.

## Lý do chết mới

- **CH2_CHAIN_WRONG:** Bạn đã nối sai.
- **CH2_CHAIN_TIMEOUT:** Bạn không nối kịp trong mười lăm giây.
- **CH2_SCALDED:** Nước sôi xối xuống người bạn.
- **CH2_SHOWER_BROKEN:** Bạn đã chọn xả nước nhưng bước ra khỏi buồng tắm.
- **CH2_NO_CHOICE:** Bạn không chọn khi đồng hồ đếm hết.
- **CH2_SHORT_SHOWER:** Tới tám giờ, bạn vẫn chưa tắm đủ hai mươi lăm phút.
- **CH2_LOST_NHAT:** Minh Nhật đã chết vì tin nhắn của bạn.
- **CH2_LOST_NGU:** Ngọc Ngư đã chết vì tin nhắn của bạn.

## Từ điển nối từ (D-049, D-051)

- **Người chơi gõ** bất kỳ từ hai tiếng nào có trong từ điển: Wiktionary tiếng Việt và tiếng Anh (bản trích của kaikki.org, CC BY-SA) cộng kho từ của game; khoảng 31 nghìn từ (`game/data/ch2/dictionary.txt`, sinh từ `build_dictionary.py`).
- **Xác chỉ biết** khoảng 9,5 nghìn từ phổ biến (có trong cả hai bản Wiktionary, sau mỗi từ còn ít nhất 5 cách nối). Gõ từ mà xác không nối tiếp được thì xác bí, gục, rồi bắt đầu chuỗi mới (N2).
- So tiếng bỏ qua cách đặt dấu cũ/mới ("hoà" = "hòa") và "y"/"i" ("kỹ" = "kĩ"); phải đúng thanh điệu.

## Kho từ của game (266 từ; xác ưu tiên nói các từ này)

- **Mở đầu:** điểm danh → danh sách → sách vở → *(Trung)* vở kịch
- **Vòng lặp của Minh Nhật:** học sinh → sinh viên → viên phấn → phấn đấu → đấu tranh → tranh luận → luận văn → văn học → học sinh …
- **Từ cụt (gài bẫy xác, N2):** chết chóc, kinh khủng, lạnh lẽo, mê man, người ngợm, sống sót, thần thánh
- **Kiểm tra tự động:** mọi từ (trừ từ cụt) đều nối tiếp được và lái về được vòng lặp; xa nhất 17 lượt.

<details><summary>Toàn bộ kho từ</summary>

bào chữa, bén lửa, bóng tối, bạc mệnh, bạo lực, bản thân, bản án, bản đồ, ca đêm, cháy nhà, chân dung, chó dữ, chơi đùa, chương trình, chế độ, chết người, chết đuối, chỉ huy, chừng mực, chữa cháy, cung cấp, cãi nhau, còn sống, công viên, công văn, cấm kỵ, cấp cứu, cứu sống, cử chỉ, danh sách, dao găm, diện mạo, du học, dung nhan, dòng máu, dạng người, dị dạng, dội nước, dữ dội, giá lạnh, giỡn mặt, găm vào, gạch đá, gật đầu, hiểm họa, hoàng hôn, hoạt động, huy chương, hành lang, hình phạt, hóa học, hóa trang, hóa đơn, hôn mê, hôn nhân, họa sĩ, học kỳ, học phí, học sinh, học trò, học tập, hồ sơ, khởi đầu, khởi động, kinh dị, kinh hoàng, kinh tế, ký tên, ký túc, ký ức, kịch bản, kỳ lạ, kỳ thi, kỵ sĩ, lang thang, luận văn, luận án, luận điểm, lưng chừng, lưới điện, lượng sức, lạ mặt, lạnh người, lệnh cấm, lửa đỏ, lực học, lực lượng, lực sĩ, máu lạnh, máu thịt, máy móc, mã số, mê cung, móc túi, mũi dao, mạch máu, mạng lưới, mạng người, mạng nhện, mạng sống, mạo hiểm, mật mã, mặt mũi, mặt nạ, mặt trận, mệnh lệnh, mộng du, mực nước, nghẽn mạch, người chết, người học, người lạ, người thân, ngủ gật, ngủ đông, nhan sắc, nhau thai, nhi đồng, nhà tắm, nhân công, nhân viên, nhân văn, nhật ký, nhật thực, nhện độc, nhị phân, nước đá, nạ dòng, phân xác, phí tổn, phòng ngủ, phòng tắm, phạt đền, phấn khởi, phấn đấu, phận bạc, phận sự, phố xá, phục vụ, rửa tay, sinh hoạt, sinh học, sinh mạng, sinh nhật, sinh tử, sinh viên, sách vở, sĩ tử, sũng nước, sơ cứu, sắc bén, số học, số phận, sống chết, sống còn, sức lực, sự sống, tay chân, thai nhi, thang máy, thao thức, thi cử, thi đấu, thoại bản, thuốc ngủ, thuốc độc, thành phố, thân nhân, thân phận, thơ ca, thương nhân, thương tích, thần chết, thần kinh, thể thao, thịt người, thức tỉnh, thực hành, thực tế, tiên tri, trang phục, tranh cãi, tranh luận, tri thức, trung thành, trình diện, trò chơi, trò đùa, trường học, trận đấu, trực đêm, tuổi thơ, táo bạo, tên tuổi, tích tắc, túc trực, túi xách, tăm tối, tập thể, tập trung, tắc nghẽn, tắm máu, tắm rửa, tế bào, tế nhị, tỉnh táo, tối mật, tối tăm, tổn thương, tội ác, tử hình, tử thần, tử tế, viên gạch, viên phấn, viên thuốc, vào học, văn bản, văn hóa, văn học, văn phòng, vở kịch, vụ án, xá tội, xác chết, xách tay, ác mộng, án mạng, án tử, óc chó, đai lưng, điền vào, điểm danh, điểm số, điện thoại, đuối sức, đá bóng, đêm trường, đông người, đùa giỡn, đơn độc, đạc điền, đất đai, đấu giá, đấu tranh, đấu trường, đầu tiên, đầu óc, đền mạng, đỏ mặt, đồ án, đồ đạc, đồng hồ, độ ẩm, độc ác, động đất, ướt sũng, ẩm ướt, ức chế

</details>

## Vòng 4: nhiệt độ

- **Quy luật (không ai nói ra, D-046):** hàng chục lần sau = hàng đơn vị của tổng hai chữ số lần trước.
- **Dãy của Trung (30 lượt):** 67, 37, 8, 81, 96, 58, 37, 1, 19, 4, 43, 74, 19, 9, 94, 35, 86, 41, 52, 79, 63, 94, 31, 45, 91, 7, 71, 83, 13, 42
- **Nhắn dự đoán:** Minh Nhật 38, 16, 75 → lượt tới 23 độ (đúng: "có" hoặc "2x"); Ngư 74, 15, 62 → lượt tới 81 độ (đúng: "không" hoặc "8x").
- Từ 50 độ là chết bỏng; cần 25 phút (13 lượt Có an toàn); sau lượt 6 còn 14 lượt an toàn.
