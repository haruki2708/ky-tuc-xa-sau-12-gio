# Kịch bản chương 1 "Tổng tắc"

> **Bản nháp, chờ chủ dự án duyệt.** Sinh tự động từ `docs/design/ch1/build_ch1_script.py`; muốn sửa lời thì báo integrator (hoặc sửa file nguồn rồi chạy lại). Thiết kế: `docs/design/STORY.md` §5.

Ký hiệu: **Loa** = loa trường · **Quản lý** · *(trong phòng)* = giọng nghe trực tiếp · 📞 = trong cuộc gọi nhóm · 💭 = suy nghĩ của Trung (chỉ phụ đề) · ▶ = lựa chọn của người chơi · `[…]` = diễn biến.

## Nhân vật trong cuộc gọi
| Tên | Phòng | Tính cách | Kết cục |
|---|---|---|---|
| Lý Minh Nhật | 203 nhà B | Bình tĩnh, giỏi phân tích, lập nhóm gọi | Sống (nhờ Trung) |
| Hùng | 102 | Hay đùa, lạc quan | Trả lời "có": chết |
| Đăng | 106 | Nóng nảy, chửi thề | Chết dù làm theo lời khuyên nào |
| Bảo | 209 | Sợ hãi, hay khóc | Im lặng: vẫn chết |
| Kiệt | 306 | Lo lắng, hay hỏi | Trả lời "không có": chết |
| Vinh | 311 | Liều | Hô tên: chết |
| Sơn | 504 | Trầm, ít nói | Trùm chăn: chết |
| Tùng | 110 | Bốc đồng | Ra khỏi phòng ở vòng 1: chết |
| Khương Ngọc Ngư | 401 nhà A | Gan dạ | Vào nhóm cuối chương |

## Mở đầu — 4:00

- **04:00** `[Trung nằm trên giường số 3, tỉnh giấc vì tiếng loa. Đèn tắt, chỉ có ánh xanh từ cửa sổ.]`
- **04:00** **Loa:** Chú ý. Một phút nữa, người nào còn nằm trên giường sẽ chết.
- **04:00** **Phúc** *(trong phòng)*: Ai mở loa giờ này vậy trời…
- **04:00** **Đạt** *(trong phòng)*: Bốn giờ sáng đó. Để người ta ngủ với.
- **04:00** **Việt** *(trong phòng)*: Kệ nó. Ngủ tiếp đi.
- **04:00** 💭 Tỉnh rồi thì đi vệ sinh luôn vậy.
- **04:01** `[Hết 60 giây thật. Còn nằm trên giường thì chết (DEATH_STAYED_IN_BED). Trung đã ra nhà vệ sinh chung cuối hành lang thì nghe tiếng la hét lan khắp tòa nhà.]`
- **04:03** 💭 Sao im lặng quá vậy…
- **04:03** 💭 Máu… Phúc? Việt? Đạt?
- **04:03** `[Ba bạn nằm chết trên giường 1, 2, 4; máu nhỏ xuống sàn.]`
- **04:04** 💭 Không có sóng. Gọi cấp cứu cũng không được.
- **04:04** `[Trung chạm vào nắm cửa định chạy đi thì loa đọc Tổng tắc.]`
- **04:04** **Loa:** Toàn thể sinh viên chú ý. Sau đây là Tổng tắc của ký túc xá.
- **04:04** **Loa:** Mọi quy tắc phải được nghe rõ và làm đúng. Ai vi phạm sẽ chết ngay tại chỗ.
- **04:04** **Loa:** Khi quy tắc mới được công bố, quy tắc cũ hết hiệu lực. Không có quy tắc nào lặp lại.
- **04:04** **Loa:** Không sinh viên nào được rời khỏi phòng của mình. Ai rời phòng sẽ chết.
- **04:04** **Loa:** Không được tấn công quản lý ký túc xá, bảo vệ hay bất kỳ nhân viên nào.
- **04:04** **Loa:** Mỗi giờ sẽ có một quy tắc mới, trong năm giờ. Ai còn sống đến cuối cùng sẽ được rời đi an toàn.
- **04:05** 💭 Suýt nữa thì… Tay mình vẫn còn trên nắm cửa.
## Vòng 1 — 4:05 đến 5:00: bị giam trong phòng

- **04:05** `[Từ đây bước qua ngưỡng cửa là chết (DEATH_LEFT_ROOM). Checkpoint `r1_start`.]`
- **04:06** 💭 Phòng bên cạnh không ai trả lời. Không một tiếng động.
- **04:10** `[Điện thoại: cuộc gọi từ Người lạ (`stranger_call`). Bắt máy thì vào cuộc gọi nhóm.]`
- **04:10** 📞 **Minh Nhật · 203:** Alo? Nghe được không? Tôi là Minh Nhật, phòng 203 nhà B.
- **04:10** 📞 **Minh Nhật · 203:** Hồi trước rảnh quá, tôi dựng một nhóm gọi qua mạng nội bộ của ký túc xá. Không cần sóng, chỉ cần còn wifi trong tòa nhà.
- **04:11** ▶ **Trung chọn:** (1) Tôi là Trung, phòng 407. Phòng tôi… chết hết rồi. / (2) Cậu gọi được thật à? Ngoài kia còn ai không?
- **04:11** 📞 **Minh Nhật · 203:** Tôi đang mời mọi máy còn kết nối. Phải bám vào nhau mà sống.
- **04:12** `[Thành viên lần lượt vào nhóm: Hùng, Đăng, Bảo, Sơn, Kiệt, Tùng, Vinh và khoảng 15 người không nói gì (tổng 23).]`
- **04:12** 📞 **Hùng · 102:** Hùng đây, 102. Chắc trường bày trò diễn tập thôi, ai lại làm thật.
- **04:13** 📞 **Đăng · 106:** Diễn tập cái đầu mày! Ba thằng phòng tao nằm chết trên giường kìa!
- **04:13** 📞 **Bảo · 209:** Bảo, phòng 209… tôi sợ lắm… máu chảy xuống tận sàn…
- **04:14** 📞 **Sơn · 504:** Sơn, 504. Hai phòng bên cạnh tôi không còn tiếng gì nữa.
- **04:15** 📞 **Kiệt · 306:** Có ai thử ra ngoài chưa? Biết đâu xuống được tới cổng?
- **04:15** 📞 **Tùng · 110:** Tùng, 110. Phòng tao ở tầng một, sát cổng. Để tao chạy ra gọi người.
- **04:15** 📞 **Minh Nhật · 203:** Đừng! Tổng tắc điều ba, rời phòng là chết!
- **04:16** 📞 **Tùng · 110:** Tao mở cửa rồi. Hành lang không có ai cả. Thấy chưa, có gì đâ…
- **04:16** `[Tùng chết: tiếng hét, điện thoại rơi vỡ, tên Tùng xám lại.]`
- **04:16** 📞 **Hùng · 102:** Tùng? Tùng ơi?
- **04:17** 💭 Loa không đùa. Không được ra khỏi phòng.
- **04:18** 📞 **Minh Nhật · 203:** Mọi người để ý pin. Cuộc gọi này ngốn pin lắm. Mất kết nối là coi như một mình.
- **04:18** 💭 Pin còn ít quá. Dây sạc của mình còn đây, nhưng cục sạc đâu…
- **04:19** 💭 Hôm qua Đạt mượn cục sạc của mình rồi khóa trong tủ…
- **04:20** `[Câu đố: tủ khóa số của Đạt (`locker_combo_dat`, mã 1407). Sổ tay Đạt: "mật khẩu là sinh nhật tao"; thẻ sinh viên: sinh ngày 14/07/2006. Mở tủ, lấy cục sạc, cắm ở ổ cạnh bàn Trung.]`
- **04:25** 💭 Đang sạc rồi. Phải ở gần ổ điện.
- **04:35** `[Cám dỗ: tiếng gõ cửa và giọng Việt ngoài hành lang. Mở cửa thì hành lang trống, có dấu chân máu đi xa; bước ra là chết.]`
- **04:35** **Việt (ngoài cửa)** *(trong phòng)*: Trung ơi, mở cửa cho tao. Tao ra ngoài đi vệ sinh, giờ không vào được…
- **04:35** 💭 Việt… đang nằm trên giường kia mà.
- **04:36** **Việt (ngoài cửa)** *(trong phòng)*: Ra đây với tao đi. Ngoài này không có ai đâu.
- **04:37** 📞 **Vinh · 311:** Vinh, 311. Có ai nghe tiếng bạn cùng phòng gọi ngoài cửa không? Tôi vừa nghe…
- **04:37** 📞 **Minh Nhật · 203:** Đừng ra. Mở cửa thì chưa sao, nhưng bước qua ngưỡng cửa là hết.
- **04:50** 📞 **Minh Nhật · 203:** Loa nói mỗi giờ một quy tắc mới. Năm giờ sẽ có quy tắc thứ hai. Phải nghe thật kỹ từng chữ.
- **04:50** ▶ **Trung chọn:** (1) Ừ. Tôi sẽ ghi lại từng chữ. / (2) Nghe kỹ thì được gì? Nó muốn giết thì giết thôi.
- **04:51** 📞 **Minh Nhật · 203:** Quy tắc chưa nói dối lần nào. Nếu có đường sống, nó nằm trong câu chữ.
- **05:00** **Loa:** Vòng một kết thúc. Số sinh viên còn sống: ba trăm năm mươi hai.
- **05:00** 📞 **Sơn · 504:** Ba trăm năm mươi hai… cả trường mấy nghìn người mà…
## Vòng 2 — 5:00 đến 6:00: quản lý kiểm tra phòng

- **05:00** **Loa:** Vòng hai. Trong một giờ tới, nhà trường kiểm tra phòng. Mỗi tòa nhà có một quản lý. Sinh viên hãy nằm yên trên giường và hợp tác với công việc của quản lý.
- **05:01** 📞 **Minh Nhật · 203:** Lên giường hết đi. Nhanh lên.
- **05:01** 💭 Phải lên giường trước khi ông ta tới.
- **05:01** `[Checkpoint `r2_start`. Tiếng dao kéo lê bắt đầu vọng từ tầng một.]`
- **05:05** 📞 **Hùng · 102:** Có người gõ cửa phòng tao… Quản lý tới rồi.
- **05:05** **Quản lý:** Đinh Xuân Hùng. Có ở đây không?
- **05:05** 📞 **Hùng · 102:** Dạ… dạ có. Em đây ạ.
- **05:05** **Quản lý:** Tốt. Vậy thì đến lượt cậu.
- **05:06** `[Hùng chết (qua cuộc gọi: tiếng chém, tiếng hét, điện thoại vỡ).]`
- **05:07** 📞 **Minh Nhật · 203:** Quy tắc bảo nằm yên trên giường và hợp tác. Hùng trả lời thật mà vẫn chết. Hay là chữ "hợp tác" có vấn đề?
- **05:07** ▶ **Trung chọn:** (1) Hay là đừng trả lời gì cả? / (2) Hay là phải nói mình không có ở đây? / (3) Tôi không biết. Chưa đủ thông tin.
- **05:08** 📞 **Minh Nhật · 203:** Chưa biết được. Ai đó… sẽ phải thử.
- **05:12** 📞 **Kiệt · 306:** Sao ông ta lên 306 rồi? Không đi theo số phòng à?
- **05:12** **Quản lý:** Giường số ba. Có ở đây không?
- **05:12** 📞 **Kiệt · 306:** Không… không có ai ở đây hết.
- **05:12** **Quản lý:** Nằm ngoan trên giường thế kia, sao lại nói không có?
- **05:13** `[Kiệt chết.]`
- **05:20** 📞 **Bảo · 209:** Ông ta tới 209 rồi… tôi phải làm sao… làm sao bây giờ…
- **05:20** 📞 **Minh Nhật · 203:** Bảo, thử im lặng. Ông ta hỏi gì cũng đừng trả lời.
- **05:21** **Quản lý:** Giường số bốn. Có ở đây không?
- **05:21** `[Im lặng rất lâu (khoảng 8 giây).]`
- **05:22** **Quản lý:** (cười khàn khàn)
- **05:22** `[Bảo chết.]`
- **05:23** 📞 **Đăng · 106:** Im lặng cũng chết! Thế này thì làm cái quái gì mới đúng!
- **05:28** 📞 **Đăng · 106:** 106… ông ta tới 106 rồi. Phòng tao. Nói gì đi, tao phải làm gì?
- **05:28** ▶ **Trung chọn:** (1) Trùm chăn kín người lại! / (2) Hô to tên mày với số giường! / (3) Chạm vào ông ta, cho ông ta biết mày còn sống!
- **05:29** **Quản lý:** Giường số hai. Có ở đây không?
- **05:29** `[Đăng chết, dù người chơi khuyên gì.]`
- **05:32** 📞 **Minh Nhật · 203:** Sơn trùm chăn, Vinh hô tên, có người còn chạm vào ông ta… Không cách nào được cả.
- **05:33** `[Sơn, Vinh và những người im lặng lần lượt xám tên.]`
- **05:38** 📞 **Minh Nhật · 203:** Trong nhóm… chỉ còn tôi với cậu.
- **05:40** 💭 Tiếng kéo dao… ở ngay tầng này.
- **05:43** `[Checkpoint `r2_manager` (người chơi phải đang nằm trên một giường). Tiếng gõ cửa 407. Quản lý mở cửa, vào phòng.]`
- **05:43** 💭 Quy tắc chỉ nói "nằm yên trên giường". Nó không nói giường của ai.
- **05:43** 💭 Ông ta sẽ hỏi giường số ba, giường của mình. Nếu mình không nằm ở đó…
- **05:43** `[HINT_1 chỉ hiện từ lần chết thứ hai ở cảnh này, HINT_2 từ lần thứ ba.]`
- **05:44** `[Quản lý hỏi giường số ba (MGR ASK_BED_3), chờ. Không nằm giường nào: chết (DEATH_NOT_IN_BED). Nằm giường số 3: chết (DEATH_OWN_BED). Có tiếng thở hoặc nhúc nhích: chết (DEATH_HEARD). Nằm giường bạn, nín thở: quản lý cười rồi chém nát giường số 3, bỏ đi.]`
- **05:46** 💭 Ông ta chém nát giường của mình… rồi bỏ đi.
- **05:46** 💭 Việc của quản lý không phải kiểm tra phòng. Mà là dọn sạch người sống. "Hợp tác"… là nằm như người chết.
- **05:47** ▶ **Trung chọn:** (1) Nhật! Nằm lên giường của bạn cùng phòng đã chết. Đừng nằm giường mình, nín thở!
- **05:52** 📞 **Minh Nhật · 203:** Ông ta vừa chém nát giường tôi… Tôi còn sống. Cảm ơn cậu, Trung.
- **05:54** 📞 **Minh Nhật · 203:** Để tôi thử mở rộng mạng… Được rồi, bắt được nhà A bên kia vườn hoa.
- **05:55** 📞 **Ngọc Ngư · 401 nhà A:** Các cậu là… ai vậy? Nhà A, phòng 401, Khương Ngọc Ngư.
- **05:56** 📞 **Ngọc Ngư · 401 nhà A:** Lúc quản lý tới, tôi đang ở cửa sổ gọi người. Không kịp về giường mình nên nằm đại lên giường bạn… Chắc nhờ vậy mà sống.
- **05:57** 📞 **Ngọc Ngư · 401 nhà A:** Hình như cả nhà A… chỉ còn mình tôi.
- **06:00** **Loa:** Vòng hai kết thúc. Số sinh viên còn sống: hai mươi tám.
- **06:00** 💭 Hai mươi tám người. Còn ba vòng nữa.
- **06:00** `[Hết chương 1. Mở khóa chương 2.]`
## Lý do chết (màn chết)

- **STAYED_IN_BED:** Bạn vẫn nằm trên giường khi hết một phút.
- **LEFT_ROOM:** Bạn đã bước ra khỏi phòng.
- **NOT_IN_BED:** Bạn không nằm trên giường khi quản lý vào phòng.
- **OWN_BED:** Quản lý tìm thấy bạn trên giường của chính mình.
- **HEARD:** Quản lý nghe thấy bạn.

## Giấy tờ đọc được trong phòng 407

- **Sổ tay của Đạt:** Mật khẩu tủ: sinh nhật tao. Đứa nào mở trộm là chết với tao. · Thứ hai: trả cục sạc cho Trung.
- **Thẻ sinh viên:** Họ tên: Phạm Thành Đạt · Ngày sinh: 14/07/2006 · Ký túc xá: phòng 407, nhà B
- **Lịch thi của Phúc:** Giải tích 2: thứ hai, 7 giờ 30. KHÔNG ĐƯỢC NGỦ QUÊN. · Hứa với mẹ kỳ này qua hết các môn.
- **Mặt sau tấm ảnh gia đình:** Học xong thì về quê làm thầy giáo nghe con. Ba mẹ.
- **Tủ của Đạt:** mã `1407` (ngày sinh 14/07 trên thẻ sinh viên).
