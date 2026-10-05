# Chương 2 "Trò chơi" (6:00–8:00): thiết kế để duyệt

> **Bản nháp chờ chủ dự án duyệt** (2026-10-05). Đã chốt 4 điểm (D-046). Bổ sung cho `STORY.md` §6. Chuẩn chương 1 bản 2 áp dụng mặc định: nhiều nhiệm vụ, **chỉ một độ khó Insane** (D-039), **cắt thời gian trống** khi xong nhiệm vụ (D-040), **không giải thích luật** (D-038), **có cảnh chết** (D-042). Các điểm đã chốt ghi ở cuối. Con số là giá trị khởi đầu, chỉnh sau chơi thử.

## Tóm tắt
- **Vòng 3 (6:00–7:00), nối từ:** ba xác bạn cùng phòng ngồi dậy, chơi nối từ tiếng Việt với Trung. Lời giải: bịt miệng cả ba xác bằng giẻ, rồi lặp vòng từ Minh Nhật đưa tới hết giờ. Hết vòng: còn **5** người.
- **Vòng 4 (7:00–8:00), tắm nước nóng** trong nhà vệ sinh riêng của 407: phải tắm đủ **25 phút**. Mỗi 2 phút chọn có xả nước hay không, nhiệt độ hiện sau khi chọn. Lời giải: tìm ra **quy luật nhiệt độ** (khác video). Hết vòng: còn **3** người (Trung, Minh Nhật, Ngư).
- **Dài khoảng 35–45 phút chơi**, không tính chết. Checkpoint chỉ ở đầu mỗi vòng (`ch2_r3`, `ch2_r4`).
- **Nhân vật trong cuộc gọi:** Minh Nhật và Khương Ngọc Ngư (tòa 8, phòng 401). Tổng tắc vẫn còn hiệu lực cả đêm: **ra khỏi phòng là chết**. Nhà vệ sinh và ban công **thuộc phòng 407**.

## Mở đầu chương (6:00)
- Loa: "Quy tắc vòng hai kết thúc. Số người sống sót hiện tại: 28 người", rồi đọc **luật vòng 3**:
  > *"Công việc kiểm tra phòng kết thúc. Đến giờ giải trí. Chúng ta chơi nối từ nhé. Bốn người trong phòng bắt buộc tham gia, nối lần lượt theo chiều kim đồng hồ, mỗi lượt dưới 15 giây. Từ nối phải là từ hai tiếng, tiếng đầu trùng với tiếng cuối của từ trước, đúng cả dấu. Trong ba lượt liền nhau không được lặp từ. Ai không nối được, chết."*
- **Ba xác ngồi dậy** trong vũng máu, mắt trống rỗng, quay về phía Trung (dùng tư thế `sit_up` của xác T-154). Jumpscare 1.

## Vòng 3: nối từ (6:00–7:00)

### Luật trong game
- **Thứ tự theo chiều kim đồng hồ:** Phúc (giường 1) → Việt (giường 2) → Đạt (giường 4) → **Trung** → Phúc …
- **Lượt của xác:** xác nói một từ (giọng eSpeak méo, môi giật), khoảng 3–5 giây.
- **Lượt của Trung:** bảng chọn hiện trên màn hình với **4 phương án** và đồng hồ **15 giây**. Một từ đúng, ba từ bẫy:
  - sai tiếng đầu: âm gần giống, ví dụ "khuyết điểm" thay cho "khuất …";
  - **đúng tiếng nhưng sai dấu**, ví dụ "đà …" khi cần "đá …";
  - từ đã xuất hiện trong 3 lượt gần nhất;
  - từ không phải từ hai tiếng (ba tiếng, hoặc ghép bừa).
- **Chọn sai hoặc hết 15 giây thì chết** (`DEATH_CHAIN_WRONG`, `DEATH_CHAIN_TIMEOUT`).
- **Phải ở trong phòng ngủ để trả lời.** Ở nhà vệ sinh hoặc ban công thì bảng chọn mờ: "Họ không nghe thấy bạn". Đi lấy đồ xa phải canh giữa hai lượt của mình, khoảng 15–25 giây.

### N1. Sống sót những lượt đầu
- Lượt đầu, xác cố tình ra từ khó, như video: Đạt nói **"oan khuất"**, Trung phải nối **"khuất …"** (khuất phục, khuất bóng, khuất mắt).
- **Không có Minh Nhật nhắc** (Insane). Video có Nhất San cứu lượt đầu; ở game, người chơi tự chọn trong 4 phương án.

### N2. Gài bẫy xác (không bắt buộc, mua thời gian)
- Trong 4 phương án đôi khi có **từ láy cụt**: tiếng cuối không nối được, như "lởm chởm", "khập khiễng", "nhõng nhẽo".
- Chọn từ đó: xác kế tiếp ú ớ hết 15 giây, gục xuống rồi **sống lại** sau khoảng 10 giây, và bắt đầu chuỗi mới. Người chết không sợ thua; chỉ Trung là không được thua.
- Mỗi lần gài được thêm khoảng **25 giây rảnh** để đi lấy đồ.

### N3. Tìm 3 miếng giẻ
- Ngư kể: *"Mình vừa nối vừa kéo tay đứa cùng phòng. Nó chẳng phản ứng gì, chỉ lo nối từ."* **Không nói tiếp ý "bịt miệng"** (D-046): người chơi tự nghĩ ra.
- Ba thứ bịt được miệng, ở ba chỗ xa nhau:
  - **giẻ lau** trên bồn rửa trong nhà vệ sinh (`rag.tscn` của T-154);
  - **khăn tắm** trên dây phơi ngoài ban công;
  - **áo của Việt** trong tủ Việt.
- Cầm được một món một lúc.

### N4. Bịt miệng 3 xác
- Cầm giẻ, tới sát xác, bấm E: xác bị bịt, vẫn quay mặt nói nhưng chỉ ú ớ.
- Tới lượt xác đã bị bịt: ú ớ hết giờ, gục, sống lại, **lượt chuyển cho người kế tiếp**, như video.
- **Bẫy Insane:** bịt miệng đúng lúc xác **đang nói** thì nó quay sang, nhìn chằm chằm, rồi tiếp tục (jumpscare 2, không chết). Bịt lúc nó im thì không sao.
- Bịt đủ 3 xác thì trò chơi chỉ còn một mình Trung, mỗi lượt vẫn phải chọn trong 15 giây.

### N5. Vòng lặp từ của Minh Nhật
- Minh Nhật gửi vào nhóm chat một **vòng 8 từ** và bảo "lái về chữ **học**":
  > học sinh → sinh viên → viên phấn → phấn đấu → đấu tranh → tranh luận → luận văn → văn học → học sinh …
- Người chơi phải **tự lái chuỗi** từ tiếng đang có về "học", qua 1–3 từ trung gian có trong phương án, rồi chọn đúng từ trong vòng mỗi lượt.
- Đi trọn **một vòng** (8 lượt) thì cắt thời gian trống, nhảy tới 7:00 (D-040).
- Lặp sai vòng vẫn chết như thường.

### Ngoài phòng 407 (nghe qua điện thoại)
- Người trong nhóm chết dần. Minh Nhật đọc số người còn lại; tiếng hét vọng từ các tầng.
- **Camera an ninh (D-046)** cho thấy **một phòng khác thua** (phòng 102 đã có sẵn ở T-165, ba xác lao vào người còn sống), để người chơi biết thua là thế nào trước khi tự trải qua.
- **7:00:** loa: "Quy tắc vòng ba kết thúc. Số người sống sót hiện tại: 5 người." Ba xác gục xuống.

## Vòng 4: tắm nước nóng (7:00–8:00)

### Luật (loa)
> *"Trò chơi gắn kết tình bạn kết thúc. Đến giờ tắm nước nóng cho thoải mái. Mời mọi người vào nhà vệ sinh. Vòng này không có yêu cầu nào khác: chỉ cần thời gian xả nước vượt quá 25 phút. Chúc các bạn tắm vui vẻ."*

### N6. Vào nhà vệ sinh
- Cửa nhà vệ sinh của 407 **kẹt** vì nước nóng đã xả trước đó làm cánh cửa gỗ phồng. Phải **đẩy vai 3 lần** (E), mỗi lần là một tiếng động lớn.
- Bên trong: vòi sen **mất công tắc**, thay bằng **màn hình** gắn tường:
  > *"Chọn có xả nước trong 2 phút tới hay không. Đã chọn thì bắt buộc làm theo. Nếu không, chết."*

### N7. Mỗi lượt 2 phút: Có hay Không
- **30 lượt** (7:00–8:00), mỗi lượt khoảng **20 giây chơi** (2 phút trong game), gồm khoảng 8 giây đếm ngược để chọn.
- **Chọn "Có":** phải **đứng trong buồng tắm** suốt lượt. Bước ra là chết (`DEATH_SHOWER_BROKEN`).
- **Chọn "Không":** không xả nước, đứng đâu cũng được.
- **Không chọn kịp** cũng chết (`DEATH_NO_CHOICE`).
- **Nhiệt độ chỉ hiện sau khi chọn.**
  - Dưới 50 độ: tính vào 25 phút. Dưới 10 độ là lạnh buốt, rung hình, vẫn tính.
  - **Từ 50 độ trở lên mà đang đứng dưới vòi thì chết bỏng** (`DEATH_SCALDED`).
- **Tới 8:00 chưa đủ 25 phút thì chết.** Đủ 25 phút thì cắt thời gian trống, nhảy tới 8:00 (D-040).
- Màn hình hiện **toàn bộ lịch sử nhiệt độ** từ lượt đầu (dữ liệu để tự tìm quy luật, D-046) và thanh "Đã tắm X/25 phút".

### N8. Hơi nước che màn hình
- Mỗi lượt xả nước nóng (từ 40 độ) làm **hơi nước phủ mờ màn hình**: không đọc được nhiệt độ cũ. Phải **lau màn hình** (giữ E 1 giây).
- Lau trong lúc đứng dưới vòi thì được; bước ra khỏi buồng khi đã chọn "Có" thì chết.

### N9. Tìm quy luật nhiệt độ (khác video)
- **Quy luật:** chữ số hàng chục của lần sau = **chữ số hàng đơn vị của tổng hai chữ số lần trước**.
  - Ví dụ: 83 → 8 + 3 = 11 → lần sau là **1x** độ (an toàn); 67 → 13 → **3x**; 96 → 15 → **5x** (chết).
  - Chữ số hàng đơn vị là ngẫu nhiên (thiết kế sẵn).
  - Khác video: video dùng "hàng chục lần sau = hàng đơn vị lần trước".
- **Dãy 30 lượt đã dựng sẵn** (lặp lại khi chơi lại, bot kiểm thử được):
  > 67, 37, 8, 81, 96, 58, 37, 1, 19, 4, 43, 74, 19, 9, 94, 35, 86, 41, 52, 79, 63, 94, 31, 45, 91, 7, 71, 83, 13, 42
  - 16 lượt an toàn trên 30.
  - Từ lượt thứ 7, khi đã đủ dữ liệu đoán quy luật, còn **14 lượt an toàn, cần 13**: chỉ được bỏ lỡ một lượt.
  - Không có nhiệt độ 46–49.
- **Không có gợi ý** (D-046): Minh Nhật và Ngư cũng đang đoán, không ai nói quy luật. Người chơi tự tìm từ lịch sử nhiệt độ trên màn hình.
- **Rủi ro:** đây là phần khó nhất chương. Nếu chơi thử thấy quá khó thì nới bằng cách thêm lượt an toàn, không thêm gợi ý.

### N10. Cứu Ngư (7:40)
- Điện thoại của Ngư bị nước làm hỏng loa ngoài. Ngư đọc to 3 nhiệt độ gần nhất **của bên cô ấy** (dãy khác, cùng quy luật), hỏi lượt tới chọn gì.
- Trung có **10 giây** để chọn "Có" hoặc "Không" trong cuộc gọi. Sai thì Ngư chết và **Trung thua** (`DEATH_LOST_NGU`): mất Ngư là mất người giải chương 4.

### Hết vòng (8:00)
- Loa: "Quy tắc vòng bốn kết thúc. Số người sống sót hiện tại: 3 người." Kết chương: màn tiêu đề, mở khóa chương 3.

## Cảnh chết mới (D-042)
| Lý do | Cảnh | Ai làm |
|---|---|---|
| `DEATH_CHAIN_WRONG`, `DEATH_CHAIN_TIMEOUT` | Ba xác cùng quay đầu, lao tới, cắn xé sát mặt (`corpse_lunge`) | A camera, B tư thế lao, D máu, E tiếng |
| `DEATH_SCALDED`, `DEATH_NO_CHOICE` | Hơi nước trắng xóa, da phồng đỏ, ngã gục trong buồng tắm (`scald`) | A, D lớp bỏng/hơi nước, E tiếng nước sôi |
| `DEATH_SHOWER_BROKEN` | Bước ra khỏi buồng: ngã ngửa, phụt máu như chương 1 (`fall_back`) | đã có |
| `DEATH_LOST_NGU` | Không có cảnh chết; màn thua kiểu `DEATH_LOST_NHAT` | đã có |
| `DEATH_LEFT_ROOM` | Như chương 1 | đã có |

## Jumpscare (D-031: 8–10 mỗi chương)
1. Ba xác ngồi dậy (6:00).
2. Xác quay sang khi bị bịt miệng lúc đang nói.
3. Xác bị gài bẫy gục xuống rồi bật dậy.
4. Camera: phòng khác thua (D-046).
5. Cửa nhà vệ sinh bật mở ở lần đẩy thứ 3, hơi nóng phụt ra.
6. Lượt 70–90 độ đầu tiên: nước sôi xối xuống, hơi nước trùm màn hình.
7. Trong hơi nước, gương nhà vệ sinh thoáng hiện bóng quản lý (chỉ một khung hình).
8. 7:40: Ngư hét khi điện thoại bị nước.
9. Cảnh chết `corpse_lunge` và `scald`.

## Dùng lại từ chương 1
- Phòng 407 mới: nhà vệ sinh có vòi sen, ban công, tủ Việt (T-162).
- Xác 3 bạn cùng phòng có tư thế `sit_up`, `head_turn`, `eyes_open` (T-154); giẻ `rag.tscn` (T-154).
- Bảng chọn trên điện thoại (T-155, T-163); camera an ninh (T-165).
- Cảnh chết, lớp máu, âm chết (T-161, T-163, T-164).
- Bot và menu thử nhanh (T-166); pipeline giọng eSpeak (T-159).

## Phân việc dự kiến (sau khi duyệt)
| Lane | Việc chính |
|---|---|
| Core (Claude) | Kịch bản và lời thoại (`build_ch2_script.py`), kho từ nối, dãy nhiệt độ, luồng 2 vòng, checkpoint, ghép |
| A | Cầm giẻ và bịt miệng xác, vùng đứng trong buồng tắm, đẩy cửa kẹt, lau màn hình, cảnh chết `corpse_lunge` và `scald` |
| B | Xác ngồi nói, bị bịt, lao tới; khăn trên dây phơi, áo trong tủ; màn hình vòi sen, hơi nước, cửa nhà vệ sinh kẹt |
| C | Bot chương 2 (nối từ, gài bẫy, bịt miệng, vòng lặp, 30 lượt tắm), menu nhảy tới vòng 3 và 4 |
| D | Bảng nối từ 15 giây, màn hình vòi sen (Có/Không, 3 nhiệt độ gần nhất, X/25 phút), lớp hơi nước và bỏng |
| E | Giọng xác đọc từ, tiếng ú ớ, tiếng nước (lạnh, ấm, sôi), đếm ngược, cảnh chết mới |

## Đã chốt (D-046)
1. Quy luật nhiệt độ: **không gợi ý**.
2. Manh mối bịt miệng: Ngư **chỉ kể nửa đầu**.
3. Nối từ: **4 phương án, 15 giây**.
4. Camera cho thấy **một phòng khác thua** ở vòng 3: **có**.
