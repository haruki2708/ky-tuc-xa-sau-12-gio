# Chương 1 bản 2: 8 nhiệm vụ, độ khó Insane (D-039, D-040)

> **Đã chốt hướng** (chủ dự án, 2026-10-05). Bổ sung cho `STORY.md` §5 và `CH1_SCRIPT.md`. Lời thoại mới thêm vào `docs/design/ch1/build_ch1_script.py`. Con số là giá trị khởi đầu, chỉnh khi chơi thử.

## Nguyên tắc
- **Không giải thích luật, không có suy nghĩ gợi ý** (D-038, Insane). Manh mối chỉ nằm trong phòng, trong cuộc gọi, và trong cái chết của người khác.
- **Insane:**
  - checkpoint **chỉ ở đầu mỗi vòng** (`ch1_prologue`, `ch1_r1`, `ch1_r2`); chết ở cảnh quản lý thì làm lại cả vòng 2;
  - nín thở tối đa **6 giây**;
  - **bỏ** các suy nghĩ gợi ý: `GET_UP`, `DAT_CHARGER`, `VIET_BED`, `HINT_1`, `HINT_2`;
  - quản lý **nghe cả tiếng cử động** (`move`, `step`) từ lúc mở cửa tới lúc rời phòng; **tiếng thở** chỉ bị nghe trong 5 giây im lặng sau câu hỏi.
- **Bỏ thời gian trống (D-040):** mỗi khoảng chờ trong vòng là "chờ tối đa N giây, hoặc tới khi xong hết nhiệm vụ của vòng". Xong hết thì diễn biến kế tiếp đến ngay.

## Vòng 1 (4:05–5:00)
### N1. Tủ của Đạt (khó hơn)
- Sổ của Đạt: *"Mật khẩu tủ: sinh nhật thằng thân nhất phòng. Đứa nào mở trộm là chết với tao."*
- Manh mối: **ảnh đội bóng khoa** (Đạt khoác vai Phúc; mặt sau ghi *"Anh em cây khế: Phúc & Đạt"*), **thẻ sinh viên của Phúc** (kẹp trong sách giáo trình của Phúc, ngày sinh **21/09/2006**).
- Thẻ của Đạt (sinh 14/07/2006) và thẻ của Việt là **mồi nhử**.
- **Mã: `2109`.** Không có nút gợi ý.
- **Sai 3 lần:** khóa kẹt 60 giây và kêu to (âm khóa báo động, phát `noise_emitted` bán kính 12 m).
- Trong tủ có **cục sạc**. Cắm ở chỗ dây sạc trên bàn của Trung.

### N2. Mạng chập chờn (4:28)
- Đèn cục phát tắt, cuộc gọi mất (`phone_call_lost`). Điện thoại báo "Mất kết nối".
- **Ổ điện kéo dài** dưới giường Phúc có 3 công tắc, chữ đã mờ:
  - **2** cấp điện cho cục phát (phích cắm cục phát quấn **băng keo đỏ**, công tắc 2 cũng có vệt đỏ);
  - **1** là laptop của Việt (không sao);
  - **3** là ấm siêu tốc: bật lên thì **chập**, cả ổ nhảy, tóe lửa, phải chờ 20 giây mới bật lại được.
- Cục phát khởi động 8 giây, đèn mạng vẫn đỏ: dưới gầm bàn có **2 sợi dây mạng tuột**: **xanh dương** (từ cục phát) và **xám** (từ laptop của Việt). Cắm sợi xanh vào **ổ mạng trên tường** thì có mạng; cắm sợi xám thì không có gì.
- Có mạng lại: cuộc gọi nối lại (`phone_call_restored`). Minh Nhật nói hai câu `N_BACK` và `N_MISSED`. Các câu thoại phát ra trong lúc mất mạng **không** hiện trong bản chép lời.
- **Tới 4:48 chưa sửa xong:** Minh Nhật tự nối lại từ phía cậu ấy (`N_BACK_REMOTE`).

### N3. Gõ tường với phòng 406
- **Khoa** (phòng 406, không có điện thoại) gõ tường theo **mã gõ tù nhân 5×5** (bỏ chữ J), không dấu:

  | | 1 | 2 | 3 | 4 | 5 |
  |---|---|---|---|---|---|
  | **1** | A | B | C | D | E |
  | **2** | F | G | H | I | K |
  | **3** | L | M | N | O | P |
  | **4** | Q | R | S | T | U |
  | **5** | V | W | X | Y | Z |

- Bảng mã kẹp trong **sổ hợp âm guitar của Việt** (giấy đọc được, không ghi tên bảng).
- **Diễn biến:**
  - 4:38: Khoa gõ **`CON SONG`** ("còn sống?"), lặp lại 2 lần.
  - Người chơi gõ lại **`CO`** ở tường 406: gõ N lần liền nhau cho mỗi số, ngừng khoảng 1 giây giữa hai số, khoảng 2,5 giây giữa hai chữ.
  - Đúng thì Khoa gõ **`SO GIUONG`** ("số giường"), gợi ý cho vòng 2. Sai hoặc 90 giây không trả lời thì Khoa im luôn.
- **Vòng 2, khoảng 5:40:** nghe qua tường quản lý vào phòng 406: "Giường số hai…", tiếng chém, rồi im lặng.

### N4. Giữ cửa (4:35)
- Cửa 407 lúc này **không chốt** (đầu vòng 1).
- Giọng Việt ngoài cửa (`KNOCK_VIET`), rồi **tay nắm cửa bị vặn mạnh, rung bản lề**.
- Có **10 giây** để chốt cửa (chốt của T-129/T-140; cờ `door_locked`).
- Không kịp: cửa bật mở, một bàn tay lôi Trung ra hành lang. Chết: `DEATH_DRAGGED_OUT`.
- Chốt kịp: tay nắm ngừng vặn, `KNOCK_VIET_2`, rồi tiếng dép đi xa.

## Vòng 2 (5:00–5:43)
### N5. Biên bản bị xé
- Ba mảnh giấy:
  - **mảnh 1** trong tủ của Việt (mở tủ);
  - **mảnh 2** dưới nệm đẫm máu của Phúc (giường 1, tầng trên: "Lật nệm");
  - **mảnh 3** trong sọt rác cạnh bàn.
- Mỗi mảnh đọc được một phần, có chữ bị đứt.
- Đủ 3 mảnh thì ghép thành **"Biên bản kiểm tra phòng ban đêm (mẫu cũ)"** đọc được trọn:
  - *"Cán bộ kiểm tra hỏi theo số giường đã đăng ký, không hỏi theo người."*
  - *"Giường trống: ghi 'vắng'. Giường có người nằm im: ghi 'đã kiểm tra'."*
  - *"Phòng còn đèn sáng: kiểm tra kỹ từng giường."*
  - *"Sinh viên không được tự ý đổi giường đã đăng ký."*
- Không có lựa chọn giả thuyết thêm (D-038): người chơi tự suy ra.

### N6. Xóa dấu vết sự sống
- Cuộc gọi để lại manh mối:
  - **Kiệt** chết khi màn hình điện thoại đang sáng: Minh Nhật *"Lúc ông ta vào, điện thoại Kiệt còn sáng… cậu ấy đang gọi với tụi mình."*
  - **Đăng** ngồi dưới đèn: *"Đèn phòng tao còn sáng, kệ, tao không tắt đâu."*
- **Lúc quản lý mở cửa 407**, nếu **đèn bàn còn sáng**, **điện thoại đang giơ**, hoặc **đèn pin đang bật** thì quản lý thấy và giết. Chết: `DEATH_SEEN`.
- Đèn bàn bật/tắt được: công tắc trên đèn bàn của Trung.

### N7. Cứu Minh Nhật (sau khi quản lý rời 407)
- Lựa chọn `TELL` có 4 câu, **10 giây**:
  1. *"Nằm giường của người đã chết, tắt hết đèn, nín thở khi ông ta hỏi xong."* **(đúng)**
  2. *"Nằm yên trên giường của mình, nín thở thật lâu."*
  3. *"Chui xuống gầm giường, tắt điện thoại."*
  4. *"Nằm giường của người đã chết, trả lời 'không có' khi ông ta hỏi."*
- Sai hoặc hết giờ: nghe quản lý tới phòng 203 qua cuộc gọi, Minh Nhật chết. Chết: `DEATH_LOST_NHAT` (*"Minh Nhật đã chết. Không còn ai giữ mạng nội bộ."*), làm lại vòng 2.

### N8. Theo dõi quản lý
- Tab **Sơ đồ** trên điện thoại: 6 tầng × 8 phòng của nhà B. Người chơi tự bấm đánh dấu phòng quản lý đã tới, dựa vào tiếng dao kéo lê (qua tầng) và tin trong nhóm.
- Game không tự hiện vị trí quản lý. Không bắt buộc, nhưng là cách duy nhất để đoán còn bao lâu ông ta tới 407.

## Phòng 407 mới (D-041)
- Phòng 407 **chiếm luôn chỗ phòng 408**: X 30→38, sâu tới Z khoảng −7. Cửa vào giữ ở X = 32 như cũ.
- Cửa 408 ngoài hành lang thành **cửa giả bị bịt** (hoặc tủ vòi chữa cháy), không mở được. Phòng 406 giữ nguyên (gõ tường).
- **Nhà vệ sinh riêng** trong phòng: bồn cầu, lavabo, gương, **vòi sen** (vòng 4 chương 2 dùng). Cửa nhà vệ sinh mở được.
- **Ban công nhỏ** phía cửa sổ: dây phơi, chậu cây, nhìn ra trời tối. Ban công **vẫn là trong phòng** (không phạm Tổng tắc).
- **Đồ đạc:** mỗi người một bàn học, kệ sách, tủ lạnh mini, nồi cơm điện, ấm siêu tốc (công tắc 3 của ổ điện), giá giày, balo, gương, quạt đứng, đồ ăn vặt, chăn gối lộn xộn. Giữ bốn giường, bốn tủ, mọi anchor đã có (dời vị trí theo phòng mới).

## Camera an ninh (D-041)
- **Vòng 2, đầu vòng:** Minh Nhật: *"Tôi vào được hệ thống camera của ký túc xá rồi. Mở tab Camera trên điện thoại."* (lời thoại mới).
- Điện thoại có **tab Camera**:
  - hình đen trắng, nhiễu, có tên camera (`CAM 102`…) và giờ;
  - đổi qua lại giữa các camera;
  - khi quản lý vào một phòng có camera, game phát `cctv_focus_requested(camera_id)`: điện thoại rung, hiện thông báo; giơ máy thì tự chuyển sang camera đó.
- **Bốn cảnh, đủ 4 người:**
  - **Hùng (102):** trả lời "có", bị giết.
  - **Kiệt (306):** trả lời "không có", **màn hình điện thoại đang sáng**.
  - **Bảo (209):** im lặng nhưng thở run, quản lý cúi sát nghe rồi giết.
  - **Đăng (106):** **đèn bàn sáng**, làm theo lời khuyên của Trung, vẫn chết.
- Mỗi cảnh cho thấy một manh mối cho nhiệm vụ N6. Máu me như video; "Giảm hù dọa" thì camera nhiễu trắng đúng lúc chém.
- Các phòng này là **phòng tiêu chuẩn** (dùng lại khung phòng 407 cũ 4×5 m, bày đồ khác), đặt ở một khu riêng ngoài tòa nhà, chỉ nhìn qua camera.
- **Camera hành lang tầng 4:** thấy quản lý đi tới 407 lúc cuối vòng 2.

## Cảnh chết (D-042)
Mọi cái chết của người chơi đều có **cảnh chết góc nhìn thứ nhất** (khoảng 3 giây) trước màn "Bạn đã chết".
- Core phát `EventBus.player_death_started(kind)`: lane A diễn cảnh bằng camera và hạt máu, lane D phủ máu lên màn hình, lane E phát âm. Sau đó core phát `player_failed(reason)` như cũ.

| `kind` | Khi nào | Cảnh |
|---|---|---|
| `fall_back` | Bước ra khỏi phòng (`DEATH_LEFT_ROOM`), bị lôi ra (`DEATH_DRAGGED_OUT`) | Cơ thể khựng lại, **máu phụt** từ ngực hoặc cổ vào tầm nhìn, **ngã ngửa ra sau**, camera đập xuống sàn rồi nhìn lên trần, máu loang, thở hắt, tối dần |
| `manager_kill` | Bị quản lý phát hiện (`DEATH_HEARD`, `DEATH_OWN_BED`, `DEATH_NOT_IN_BED`, `DEATH_SEEN`) | **Jumpscare:** camera bị khóa nhìn quản lý, ông ta lao tới, mặt sát camera, dao chém xuống, **máu bắn kín màn hình**, camera ngã nghiêng |
| `bed_burst` | Nằm lì trên giường lúc 4 giờ (`DEATH_STAYED_IN_BED`) | Máu trào lên từ dưới khung nhìn, cơ thể co giật, màn hình đỏ dần |
| `none` | Minh Nhật chết (`DEATH_LOST_NHAT`) | Không có cảnh của người chơi; nghe cảnh của Minh Nhật qua cuộc gọi rồi tối |

- **"Giảm hù dọa":** không có mặt sát camera và máu bắn kín màn hình; chỉ ngã và tối dần.

## Lý do chết mới
| Key | Câu |
|---|---|
| `DEATH_DRAGGED_OUT` | Một bàn tay lôi bạn ra khỏi phòng. |
| `DEATH_SEEN` | Quản lý thấy ánh sáng trong phòng. |
| `DEATH_LOST_NHAT` | Minh Nhật đã chết. Không còn ai giữ mạng nội bộ. |

## Phân việc (task card T-160…T-164)
| Lane | Việc |
|---|---|
| core T-160 | Luồng 8 nhiệm vụ, Insane, cắt thời gian trống, dữ liệu, lời thoại, giọng (pipeline T-159), ghép |
| A T-161 | Gõ tường (phát và nhận chuỗi gõ), tay nắm cửa bị vặn, công tắc đèn bàn, các chỗ lục (tủ Việt, lật nệm, sọt rác), ổ điện và dây mạng tương tác được, nín thở tối đa đặt được (6 giây), giới hạn số lần thử tủ |
| B T-162 | Ổ điện kéo dài 3 công tắc (chữ mờ, vệt đỏ), phích quấn băng keo đỏ, 2 dây mạng (xanh, xám) và ổ mạng trên tường, sọt rác, 3 mảnh giấy xé, tủ Việt mở được, nệm Phúc lật được, ảnh đội bóng, sổ hợp âm guitar, tay nắm cửa rung |
| D T-163 | Điện thoại "Mất kết nối" và nối lại; tab Sơ đồ; panel khóa số giới hạn 3 lần thử, khóa 60 giây |
| E T-164 | Tiếng gõ tường, cục phát khởi động, ổ điện chập, tay nắm cửa vặn, chuông báo khóa, chuông điện thoại trong cuộc gọi |
| B T-165 | Khu camera: 4 phòng tiêu chuẩn (102, 306, 209, 106), camera hành lang tầng 4, mô hình 4 sinh viên còn sống với các tư thế |
| C | Cập nhật bot cho 8 nhiệm vụ sau khi ghép |
