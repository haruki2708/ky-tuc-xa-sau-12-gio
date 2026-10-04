# Thiết kế v2: chuyển thể "Quy tắc ký túc xá lúc nửa đêm"

> **Trạng thái: ĐÃ DUYỆT** (chủ dự án, 2026-10-04, D-034, D-035). Thay thiết kế v1 (`STORY_v1.md`). Chương 1 đang sản xuất (T-150…T-159), hạn chơi thử **2026-10-07**.
>
> **Nguồn:** video *(Full) Quy tắc kí túc xá lúc nửa đêm*, kênh YouTube *Thế Giới Kì Quái*. Bản chép lời và bản chuyển thể nằm ở `D:\GAME_WORK\kich_ban\`. Chủ dự án chọn **chuyển thể sát video** và **máu me như video**.
>
> Chỗ ghi **[Claude đề xuất]** là phần video không có, hoặc phần cần đổi cho hợp game và bối cảnh Việt Nam. Chủ dự án sửa thoải mái.

## 0. Rủi ro đã báo, chủ dự án chấp nhận (D-034)
- **Bản quyền:**
  - Truyện gần như chắc chắn chuyển thể từ một truyện mạng Trung Quốc thể loại "quy tắc quái đàm"; tác giả gốc chưa rõ.
  - **Trước khi bán**, nên tìm tác giả gốc để xin phép, hoặc ít nhất đổi đủ nhiều chi tiết.
  - **Không chép nguyên văn** lời loa và lời thoại của video. Mọi câu chữ trong game được viết lại bằng lời của mình.
- **Nội dung nhạy cảm:** có máu, chém giết, xác sống, và nhà ký túc xá sập vì động đất. Cần:
  - màn cảnh báo nội dung rõ ràng lúc mở game (cập nhật màn của T-139);
  - nhãn nội dung khi đăng itch.io/Steam;
  - tùy chọn "Giảm hù dọa" cũng **giảm máu me**: cảnh chém giết chuyển thành màn hình tối kèm âm thanh.

## 1. Một câu
4 giờ sáng, loa trường ra lệnh giết. Trung sống sót vì vừa rời giường. Qua 5 vòng quy tắc, mỗi vòng một tiếng, cậu phải tìm ra kẽ hở trong từng câu chữ, cùng hai người lạ nối với nhau qua một nhóm chat nội bộ, trước khi cả trường chết hết.

## 2. Bối cảnh và nhân vật
- **Nơi chốn:** một trường đại học Việt Nam không tên.
  - **Nhà B:** ký túc xá nam, 6 tầng (tầng 4 đến 6 đã có và đang làm).
  - **Nhà A:** ký túc xá nữ, đối diện bên kia sân. Giữa hai nhà có **vườn hoa**.
  - Ngoài khu ký túc xá: sân vận động, cổng trường, nhà ăn, giảng đường, nhà thi đấu, thư viện.
- **Thời gian:** một đêm, từ 4:00 đến 9:00 sáng. Mỗi giờ là một vòng quy tắc.
- **Nhân vật** (đổi tên theo bối cảnh Việt) **[Claude đề xuất]**:

| Video | Game | Vai trò |
|---|---|---|
| Pon | **Trần Trung** (giữ theo D-030), phòng 407 nhà B | Nhân vật chính, người kể chuyện |
| Nhất San | **Lý Minh Nhật**, phòng 203 nhà B | Thư sinh, áo sơ mi trắng. Lập nhóm chat bằng mạng nội bộ. Giỏi phân tích và giỏi chữ |
| Khương Tử Ngư | **Khương Ngọc Ngư**, phòng 401 nhà A | Gan dạ, buộc tóc đuôi ngựa, người duy nhất còn sống ở nhà A |
| Diêu Xung và các học sinh khác | Các thành viên nhóm chat (tên Việt) | Chết lần lượt; người chơi học luật qua cái chết của họ |
| Quản lý ký túc xá | **Quản lý** | Boss vòng 2. Giọng trầm, kéo lê dao kim loại, hỏi số giường rồi chém |
| Bạn cùng phòng (3 người) | **Phúc, Việt, Đạt** (giữ tên cũ) | Chết từ phút đầu; ngồi dậy chơi ở vòng 3; thành xác sống ở vòng 5 |
| Bảo vệ | **Bảo vệ** | Đứng thành hàng ở cổng trường, cầm dùi cui điện, bất động, không được tấn công |
| Loa phát thanh | **Loa** | Giọng lạnh như trong tù. Đúng giờ đọc quy tắc và số người sống sót |

- **Twist (giữ như video):** trận **động đất lúc 4 giờ sáng** làm sập các tòa ký túc xá. "Ký túc xá máu" là thế giới lưng chừng sống và chết của những người bị vùi. Vượt hết quy tắc thì được cứu ngoài đời.

## 3. Luật chung (Tổng tắc)
Video có 5 điều. Trong game giữ **ý** của từng điều, câu chữ viết lại:
1. Phải nghe và làm đúng quy tắc; vi phạm thì chết ngay.
2. Quy tắc mới ra thì quy tắc cũ hết hiệu lực; các quy tắc không lặp lại nhau.
3. Cấm rời phòng của mình.
4. Cấm tấn công quản lý, bảo vệ và nhân viên.
5. Mỗi giờ có một quy tắc mới, trong 5 giờ; ai còn sống thì được rời đi.

**Nguyên tắc thiết kế rút từ video** (dùng cho mọi vòng, kể cả các vòng mình thêm):
1. Quy tắc luôn nói thật nhưng **không nói hết**.
2. Câu nghe càng nhẹ nhàng, tử tế thì bẫy càng lớn.
3. Điều gì quy tắc **không cấm** thì được làm.
4. Luôn có một lối sống rõ ràng.

**Bộ đếm người sống sót:** loa đọc sau mỗi vòng. Mấy nghìn → 352 → 28 → 5 → 3 → 3 người được cứu.

**Sổ quy tắc** (thay sổ tay nội quy cũ): ghi nguyên văn quy tắc từng vòng, kèm ghi chú và chứng cứ người chơi gắn vào (dùng lại phần chứng cứ của T-156).

## 4. Chia 4 chương
Video chỉ dài khoảng 30 phút. Để mỗi chương đủ 45–60 phút, mỗi vòng được kéo dài bằng phần chơi mình thêm: khám phá, câu đố, các tình huống phụ trong nhóm chat. Các phần này ghi **[Claude đề xuất]**.

| Chương | Giờ | Nội dung |
|---|---|---|
| 1 "Tổng tắc" | 4:00–6:00 | Mở đầu, vòng 1 (cấm rời phòng, nhóm chat), vòng 2 (quản lý kiểm tra phòng). Hết chương: còn 28 người; Ngư vào nhóm |
| 2 "Trò chơi" | 6:00–8:00 | Vòng 3 (nối từ với xác bạn cùng phòng), vòng 4 (tắm nước nóng). Hết chương: còn 3 người |
| 3 "Truy sát" | 8:00–8:30 | Vòng 5, phần 1: thoát khỏi nhà B, gặp nhau ở vườn hoa, chạy ở sân vận động, xem cổng trường và nhà ăn |
| 4 "Người sống sót" | 8:30–9:00 và kết | Vòng 5, phần 2: chia nhau tìm, nhận ra bẫy trong câu chữ, quay về phòng, ký tên vào phiếu. Kết ở bệnh viện |

**Chương 1 dùng lại gì từ demo:** tầng 4 và phòng 407, tầng 5 và 6, cầu thang, nhà đối diện (thành nhà A); điện thoại (chuyển thành nhóm chat); chỗ nấp, nín thở, tiếng động; AI đi tuần (thành quản lý); loa và giọng TTS.

## 5. Chương 1 "Tổng tắc" (4:00–6:00, khoảng 50 phút)
### Mở đầu, 4:00 (khoảng 5 phút)
- Loa báo 1 phút nữa ai còn nằm trên giường sẽ chết. Ba bạn cùng phòng chửi rồi ngủ tiếp.
- **Hướng dẫn:** người chơi có 60 giây thật để rời giường. Gợi ý đi vệ sinh ở nhà vệ sinh chung cuối hành lang (lúc này chưa có luật cấm rời phòng). Còn nằm thì chết, loa nói thật.
- Quay lại phòng: ba bạn đã chết, máu nhỏ từ giường. Tiếng la hét lan khắp tòa nhà. Điện thoại mất sóng.
- Người chơi định mở cửa thì loa đọc Tổng tắc. Chạm vào tay nắm là dừng lại kịp, kèm gợi ý rõ ràng.

### Vòng 1, 4:00–5:00: bị giam trong phòng (khoảng 15 phút)
- **Quy tắc:** cấm rời phòng.
- Gọi sang phòng bên thì không ai trả lời: hai phòng bên cạnh đã chết hết.
- Điện thoại báo **cuộc gọi từ người lạ**: Minh Nhật lập nhóm chat gọi qua mạng nội bộ. Hơn 20 người vào nhóm.
- **[Claude đề xuất] thêm cho đủ thời lượng:**
  - Khám phá phòng: đồ của từng bạn cùng phòng, nhật ký, ảnh. Dùng để gắn bó với các nhân vật trước khi vòng 3 bắt người chơi chơi với xác của họ.
  - Cám dỗ rời phòng: có người gõ cửa xin vào, tiếng bạn quen gọi ngoài hành lang. Ra là chết.
  - Câu đố nhỏ: tìm sạc và **cục phát mạng nội bộ** trong phòng để giữ kết nối nhóm chat; điện thoại hết pin là mất kết nối.
  - Nhóm chat bàn tán, có người thử nghiệm, có người hoảng loạn. Người chơi đọc và trả lời bằng các lựa chọn có sẵn.
- 5:00: loa báo còn **352** người.

### Vòng 2, 5:00–6:00: quản lý kiểm tra phòng (khoảng 25 phút, cảnh chính của chương)
- **Quy tắc:** nhà trường kiểm tra phòng; mỗi tòa một quản lý; học sinh ở yên trên giường và phối hợp với quản lý.
- **Học qua cái chết của người khác** (nghe qua nhóm chat):
  - một phòng trả lời "có mặt" thì bị giết;
  - một phòng trả lời "không có" thì bị giết;
  - một phòng im lặng vẫn bị giết;
  - có người trùm chăn, có người hô tên, có người chạm vào quản lý; tất cả đều chết.
  - Quản lý đi phòng **không theo thứ tự**; tiếng kéo dao kim loại vọng qua các tầng.
- **Quản lý tới phòng 407** vào lúc người chơi đã nghe đủ các cách thất bại. **Lời giải:** quy tắc chỉ bắt "ở trên giường", không bắt "ở trên giường của mình". Người chơi nằm lên giường của một bạn đã chết, im lặng, nín thở. Quản lý hỏi giường của Trung, rồi chém nát chiếc giường trống.
- **Gameplay:**
  - Đường đi của quản lý nghe được qua tai nghe, thể hiện qua các tầng và qua nhóm chat.
  - Khi quản lý đứng trong phòng: nín thở (T-151), không nhúc nhích. Thua thì có màn hù và tải lại checkpoint.
  - Ở lại giường mình, trả lời, hay chạy ra ngoài đều chết, đúng như những gì nhóm chat đã cho thấy.
- **Sau đó:** báo lời giải cho Minh Nhật qua chat để cậu sống. Minh Nhật mở rộng mạng sang nhà A, **Ngư vào nhóm**.
- 6:00: loa báo còn **28** người. **Hết chương 1.**

## 6. Chương 2 "Trò chơi" (6:00–8:00)
### Vòng 3: nối từ với xác bạn cùng phòng
- Ba xác ngồi dậy, mắt trống rỗng, chơi cùng người chơi theo chiều kim đồng hồ, mỗi lượt dưới 15 giây.
- **Việt hóa:** video là nối thành ngữ Hán. Trong game đổi thành **nối từ tiếng Việt**: từ ghép hai tiếng, tiếng cuối của từ trước là tiếng đầu của từ sau. Người chơi chọn từ trong 3–4 phương án, có đồng hồ đếm ngược. Minh Nhật nhắc qua điện thoại khi người chơi bí.
- Người chơi có thể gài bẫy bằng một từ khó nối; xác thua thì ngã xuống rồi **sống lại** chơi tiếp, vì người chết không sợ thua.
- **Lời giải (Ngư tìm ra):** quy tắc không cấm động vào bạn cùng phòng. Tìm giẻ trong phòng, bịt miệng cả ba xác. Minh Nhật đưa ra một **vòng lặp từ** để người chơi lặp tới hết giờ.
- 7:00: còn **5** người.

### Vòng 4: tắm nước nóng
- **Quy tắc:** vào nhà vệ sinh tắm đủ 25 phút.
- Vòi sen mất công tắc, thay bằng màn hình: chọn có xả nước trong 2 phút tới hay không; đã chọn thì phải làm, không thì chết; nhiệt độ chỉ hiện sau khi chọn.
- **Lời giải:** nhiệt độ đổi theo một quy luật số; đoán đúng quy luật thì chỉ chọn "có" ở những lượt an toàn.
- **[Claude đề xuất]:** giữ cơ chế nhưng **đổi quy luật số** so với video (video dùng "chữ số hàng chục lần sau bằng chữ số hàng đơn vị lần trước"), để người đã xem video không giải ngay và để giảm rủi ro chép.
- **Gameplay:** màn hình ghi lịch sử nhiệt độ; thanh "đã tắm X/25 phút" và thời gian còn lại; hơi nước mù mịt; nước 70–98 độ thì có cảnh bỏng nếu chọn sai.
- 8:00: còn **3** người.

## 7. Chương 3 và 4 "Truy sát" và "Người sống sót" (8:00–9:00)
- **Quy tắc vòng 5:** được rời phòng; "mau chạy khỏi góc khuất nguy hiểm này"; né mọi truy sát trong một giờ.
- **Xác sống:** xác cả trường đứng dậy, mắt đỏ, chậm. Ba bạn cùng phòng là nhóm đầu tiên.
- **Chương 3:**
  - thoát khỏi nhà B qua hành lang và cầu thang đầy xác;
  - gặp nhau ở vườn hoa; Ngư phát **thanh sắt tháo từ thang giường**: không giết được xác sống, đập vào đầu thì chúng tê liệt một lúc;
  - chạy vòng ở sân vận động; xem cổng trường (bảo vệ chặn); lục nhà ăn;
  - kiệt sức: có thanh thể lực.
- **Chương 4:**
  - chia nhau tìm: Ngư tới giảng đường, Minh Nhật tới nhà thi đấu, Trung tới thư viện;
  - đọc lại quy tắc vòng 5 và nhận ra câu "mau chạy khỏi" là bẫy, nghĩa là lối sống nằm trong ký túc xá;
  - liều quay về phòng 407 khi cầu thang đã bị xác chặn;
  - lục phòng, rồi lật vạt giường của ba bạn, ghép lại thành **phiếu điều tra người sống sót sau động đất**;
  - viết tên mình bằng máu. Xác sống mất mục tiêu. Kịp nói vài chữ cho đồng đội.
- **[Claude đề xuất] thêm cho đủ thời lượng:**
  - mỗi khu trường có một câu đố nhỏ và một manh mối cài sẵn về động đất (vết nứt tường, đồng hồ dừng lúc 4:00, tiếng còi cứu hộ rất nhỏ trong nhạc);
  - đèn pin và pin điện thoại, chỗ nấp trong các tòa nhà.

## 8. Kết
| Kết | Điều kiện | Diễn biến |
|---|---|---|
| **Cả ba được cứu** (kết thật) | Ký tên và kịp báo cho đồng đội | Tỉnh dậy trong bệnh viện; y tá kể chuyện động đất; hai giường bên cạnh là Minh Nhật và Ngư |
| **Một mình sống sót** | Ký tên nhưng không kịp báo | Tỉnh dậy; hai giường bên cạnh trống |
| **Chết ở một vòng** | Phạm quy tắc | Loa đọc số người sống sót giảm đi một; tải lại checkpoint |

## 9. Thực thể và hù dọa
| Thực thể | Chương | Hành xử | Dùng lại |
|---|---|---|---|
| **Quản lý** | 1 | Đi tuần các phòng theo thứ tự ngẫu nhiên; kéo dao kim loại; nghe tiếng thở và cử động; hỏi số giường rồi chém | AI đi tuần, nghe tiếng động, nấp của T-151/T-152 |
| **Xác bạn cùng phòng** | 1–4 | Nằm chết (1); ngồi dậy chơi nối từ (2); đứng dậy đuổi (3–4). **[Claude đề xuất]:** khi chưa tới vòng 5, chúng chỉ đổi tư thế lúc người chơi không nhìn | Luật "chỉ đi khi không bị nhìn" của Người thứ năm (T-152) |
| **Xác sống cả trường** | 3–4 | Chậm, đông, vây ở chỗ hẹp; bị thanh sắt đập thì tê liệt một lúc | AI đuổi, cần tối ưu khi đông |
| **Bảo vệ** | 3 | Bất động ở cổng; lại gần là chết | Mô hình đơn giản |
| **Loa** | 1–4 | Đọc quy tắc và số người sống sót đúng giờ | Speaker và giọng TTS (T-137) |

- **Jumpscare:** 8–10 mỗi chương (D-031). Máu me như video (D-034).
- **Âm thanh:** tiếng la hét lan khắp tòa nhà; tiếng kéo dao kim loại; nhóm chat có tiếng người (TTS cho các thành viên); nhạc rất khẽ.

## 10. Quyết định (D-035)
1. Tên nhân vật đổi sang tiếng Việt như bảng mục 2.
2. Phòng của Trung giữ là **407**.
3. Chia 4 chương như mục 4.
4. Vòng 3 là **nối từ tiếng Việt**; vòng 4 **đổi quy luật số** so với video (Claude chọn quy luật mới khi viết chương 2).
5. Duyệt các phần **[Claude đề xuất]**.
6. **Không lùi hạn chương 1:** chơi thử ngày 2026-10-07.
