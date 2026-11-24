# Kế hoạch nâng chuyển động: Trần Trung và quản lý (tham khảo Mixamo)

- Viết: 22/11/2026, integrator (Mythos 5.2). Trạng thái: **24/11: bước 3 phần đầu xong (D-191: đứng, đi, chạy Mixamo); bước 4 xong (D-193, [T-270](../tasks/T-270-motion-step4-hand-paths.md): đường tay đo từ clip Button Pushing và cú vung thanh sắt liền mạch; phần thân theo clip không làm, nên câu "phương án lùi" của bước 4 ở mục dưới không còn áp dụng); theo D-192 dừng ở đây, bước 5 (quản lý) và đứng dậy khỏi giường làm khi chủ dự án gọi. Đứng dậy khỏi giường xong (D-194, [T-271](../tasks/T-271-bed-get-up.md): rời giường tầng dưới 2,0 giây, clip Getting Up). **Bước 5 (quản lý) chủ dự án cho bỏ (D-195)**: quản lý giữ dáng đi và cú chém Mixamo của T-268, các động tác khác như cũ. Phần còn lại của bước 3 (xoay tại chỗ, cầu thang, dáng khom thấp hơn) chỉ làm khi chủ dự án gọi.** Trước đó: **chủ dự án đã trả lời mục 7 (D-189): chấp nhận giấy phép; chỉ lấy chuyển động, integrator tải qua Chrome của chủ dự án; bỏ qua bước 0 và câu hỏi chơi thử lúc này; integrator làm cả. Bước 1 xong (56 clip, 22/11). Bước 2 (mẫu thử) xong ở [T-268](../tasks/T-268-mixamo-motion-pilot.md), chờ chủ dự án duyệt video; card T-268 mục 0 sửa vài nhận định ở mục 1 dưới đây (camera không gắn vào đầu khi đi, đi ngang, bảng xương, `fix_silhouette`).**
- Yêu cầu của chủ dự án (22/11): cử động tay chân, cầm đồ, mở cửa và chuyển động cả người của nhân vật chính và quản lý phải tự nhiên hơn; nguồn tham khảo là https://www.mixamo.com.
- Số tiếp theo khi chốt: D-189; card T-268 trở đi.

## 1. Hiện trạng (khảo sát code 22/11, chưa chạy Godot)

### 1a. Trần Trung (`game/scripts/player/player_body.gd`, 2.755 dòng)
- **Thân:** Tripo, có ở chương 1–3. Chương 4 chưa có thân.
- **Chỉ có 10 clip:**
  - của Tripo: `idle`, `walk`, `run`, `sit`;
  - mượn từ gói CC0 Quaternius (D-143): ngồi xổm đứng yên, ngồi xổm đi, đứng dậy từ tư thế nằm, trèo bục 1 m, bị đẩy lùi, vừa đi vừa bê đồ.
- **Đi lùi** là clip đi tới phát ngược. **Đi ngang** là clip đi tới phát chậm lại.
- **Chuyển giữa hai clip** chỉ là pha trộn 0,2 giây (`AnimationPlayer`). Không có đoạn bắt đầu bước, dừng bước, đứng lên, ngồi xuống.
- **Xoay tại chỗ:** chân bước theo bằng clip đi phát chậm, không có động tác xoay riêng.
- **Mọi thao tác tay đều do code tính (IK), không có clip nào:** với lấy đồ, cầm, đọc giấy, đặt xuống, cúi nhặt, nhón với cao, gạt tay nắm cửa, hích vai, nhét đồ vào miệng xác, vung thanh sắt. 12 bộ chỉnh xương lo phần này (gập hông, xoay ngực, nâng vai, khép ngón, xoay cổ tay…).
- **Thời gian thao tác là luật chơi:** 1 giây mỗi thao tác (D-121), cúi nhặt 1,4 giây (D-157).

### 1b. Quản lý (`game/scripts/entity/manager.gd`)
- **6 clip, cắt từ 4 động tác Tripo:**

| Clip trong game | Nguồn | Ghi chú |
|---|---|---|
| `stand` | idle | |
| `walk` | walk | |
| `ask` | wait | chống nạnh (D-120) |
| `slash` | slash, đoạn 1,15–3,10 s | |
| `kill` | slash, đoạn 1,15–2,30 s | một cú bổ |
| `lunge` | run | động tác chạy thường, dùng làm cú lao tới |

- Chuyển clip: pha trộn 0,3 giây. Quay người: xoay đều 6 rad/giây, chân không bước.
- Mở cửa: chỉ một bộ chỉnh đưa tay trái ra (`ArmReachModifier`), thân không tham gia.
- Dao: cổ tay phải bị khoá theo dáng `stand` ở mọi clip (`BoneLockModifier`), vì động tác Tripo để tay như tay không.

### 1c. Vì sao trông chưa tự nhiên (nhận định từ code, cần video để xác nhận ở bước 0)
1. Quá ít clip, và không có động tác chuyển tiếp. Người thật không đổi tư thế bằng cách "mờ dần" sang tư thế khác.
2. Đi lùi và đi ngang dùng lại clip đi tới.
3. Thao tác tay do code tính nên tay tới đúng chỗ, nhưng thân gần như đứng yên: thiếu dồn trọng tâm, thiếu vai và lưng đi theo tay, thiếu nhịp nhanh chậm.
4. Clip Tripo có lỗi riêng: bước đi dài ngắn không đều, dáng đứng tự dồn trọng tâm sau 6 giây.
5. Quản lý: cú lao tới là động tác chạy thường; quay người không bước chân; mở cửa chỉ có một cánh tay.

## 2. Mixamo: dùng được gì

**Phần tôi chưa xác minh được:**
- Trang mixamo.com là ứng dụng cần đăng nhập Adobe, nên tôi không mở được thư viện và **chưa tự xem động tác nào**. Tên clip ở mục 4 là từ khoá để tìm, chủ dự án chọn bằng mắt.
- Trang FAQ chính thức của Adobe chặn truy cập tự động, nên phần giấy phép bên dưới dựa trên các bài trích FAQ ở diễn đàn Adobe và itch.io. **Chủ dự án cần đọc FAQ chính thức khi đăng nhập** (mục 7, câu 1).

**Về kỹ thuật thì rất hợp:**
- Khung xương của Trần Trung và quản lý (Tripo dựng) **dùng đúng tên xương của Mixamo** (`mixamorig:…`). Dự án đã có bảng nối tên Mixamo sang khung xương chuẩn của Godot (`trung_bone_map.tres`).
- Vì vậy clip Mixamo đưa vào theo đúng đường các clip Quaternius đang đi: thêm một thư viện clip, không phải dựng lại nhân vật.
- Theo hiểu biết chung của tôi về Mixamo (chưa kiểm lại): miễn phí, cần tài khoản Adobe; tải dạng FBX; chọn được "Without Skin" (chỉ lấy chuyển động), 30 khung/giây, và ô "In Place" cho các clip đi, chạy.

**Về giấy phép:**
- Các nguồn tìm được nói: dùng được miễn phí bản quyền cho dự án thương mại, kể cả game; **không được phát tán file gốc cho người ngoài nhóm**.
- Mixamo **không phải CC0 hay CC-BY**, nên vướng luật `AGENTS.md` mục giấy phép. Cần một quyết định ngoại lệ, như D-084 đã làm cho Tripo.
- Đề xuất cách giữ an toàn:
  - file FBX gốc chỉ nằm ở `build/graphics/staging/mixamo/` (không commit);
  - repo chỉ chứa file đã đóng gói cho game; repo đang để riêng tư. Nếu sau này mở công khai repo thì phải gỡ các file này ra trước;
  - ghi nguồn từng clip vào `CREDITS.md`.

**Mixamo mạnh và yếu ở đâu:**
- Mạnh: chuyển động cả người quay từ người thật: đứng, đi các hướng, chạy, ngồi xổm, xoay tại chỗ, bắt đầu và dừng bước, cúi nhặt, đẩy, chém, bị đánh, đứng dậy.
- Yếu: tay không biết đồ vật của game nằm ở đâu. Tay nắm cửa, tờ giấy, điện thoại vẫn phải do IK đưa tay tới đúng chỗ.
- Kết luận: **dùng Mixamo làm lớp thân, giữ IK làm lớp tay.** Không thay cái này bằng cái kia.

## 3. Nguyên tắc
1. **Không đổi luật chơi:** giữ 1 giây và 1,4 giây cho thao tác, tốc độ đi, chạy, tầm với, vùng tương tác, thời điểm quản lý chém. Clip mới được co giãn cho vừa các mốc này.
2. **Góc nhìn thứ nhất:** mắt người chơi gắn theo đầu của thân. Clip nào lắc đầu mạnh sẽ gây chóng mặt, nên chọn clip êm và đo độ lệch của mắt cho từng clip (code đã có sẵn phép đo này).
3. **Chân không trượt:** tốc độ phát clip khớp với tốc độ di chuyển thật (code đã đo sải chân từng clip).
4. **Làm mẫu trước, duyệt bằng video cạnh nhau (cũ | mới), rồi mới làm hàng loạt.** Như các đợt đồ hoạ.
5. Mỗi bước có test giữ hợp đồng cũ; test nào ghim tư thế cũ thì cập nhật có lý do, không nới.

## 4. Các bước

| Bước | Việc | Ai | Kết quả để duyệt |
|---|---|---|---|
| 0 | **Quay hiện trạng.** Video từng động tác của hai nhân vật trong game thật (khoảng 35 động tác), bảng chấm Tự nhiên / Hơi gượng / Sai | integrator | Video và bảng; chủ dự án đánh dấu chỗ khó chịu nhất |
| 1 | **Phiếu tải Mixamo** `docs/handoff/MIXAMO_DONG_TAC.md`: từng động tác cần tải, từ khoá tìm, tiêu chí chọn, thiết lập khi tải | integrator viết, **chủ dự án tải** | File FBX trong `build/graphics/staging/mixamo/` |
| 2 | **Mẫu thử.** Công cụ đóng gói (FBX → thư viện clip), rồi 6 động tác mẫu: Trung đứng, đi tới, đi lùi, đi ngang; quản lý đi, chém | integrator | Video cũ / mới cạnh nhau. **Cổng duyệt: chủ dự án ưng mới làm tiếp** |
| 3 | **Trần Trung, di chuyển:** đi bốn hướng, chạy, ngồi xổm bốn hướng, bắt đầu và dừng bước, xoay tại chỗ, đứng lên, ngồi xuống, lên xuống cầu thang | integrator | Video chương 1 và 3; test |
| 4 | **Trần Trung, tay và thân khi thao tác:** thân dồn trọng tâm và vai lưng đi theo tay khi với, cúi nhặt, mở cửa, đẩy cửa, bê đồ, vung thanh sắt; dáng cầm đồ, cầm điện thoại, đọc giấy | integrator | Video từng loại thao tác; test tay cũ vẫn đạt |
| 5 | **Quản lý:** đứng, đi, hỏi, chém, giết, lao tới bằng clip mới; thêm xoay người có bước chân, mở cửa cả người, nhìn quanh khi soát giường; cảnh trên camera an ninh | integrator | Video chương 1; test quản lý |
| 6 | **Rà cả ba chương có thân**, full test, check, bản chơi | integrator | Bản chơi; chủ dự án chơi thử |

**Từ khoá tìm trên Mixamo (bản nháp cho phiếu ở bước 1):**
- Trần Trung:
  - đứng: idle, breathing idle, nervous/scared idle;
  - đi và chạy: walking, walking backward, left/right strafe walk, jog/run forward, start walking, stop walking, left/right turn 90;
  - ngồi xổm: crouch idle, crouched walking (tới, lùi, trái, phải), stand to crouch, crouch to stand;
  - thao tác (lấy dáng thân): picking up object, opening door, pushing, carrying, sitting, getting up, climbing, walking up/down stairs;
  - chương 3: melee swing (gậy), hit reaction, stumble backward.
- Quản lý:
  - đứng và đi: menacing/standing idle, slow walk, turn in place, looking around;
  - hỏi: hands on hips, arguing/talking;
  - dao: stabbing, downward slash, charge/run with weapon;
  - cửa: opening door.

**Thứ tự và phụ thuộc:** bước 3, 4, 5 đều cần bước 2 được duyệt. Bước 3 làm trước bước 4, vì thao tác tay dựng trên dáng đứng mới. Bước 5 độc lập với 3 và 4, nhưng máy chỉ chạy được một Godot nên vẫn làm lần lượt.

**Ai làm:** đề xuất integrator làm cả sáu bước (Mythos 5.2 hoặc Fable 5.2, effort high). Lý do: việc này sửa `player_body.gd` và `manager.gd` (core và phần cũ của lane A), và ở T-241 chính Fable 5.2 mới sửa dứt điểm được động tác với tay. Lane B (tối đa Opus 5.5) có thể nhận phần đóng gói clip nếu chủ dự án muốn chia việc.

## 5. Rủi ro
- **Giấy phép** (mục 2): cần chủ dự án đọc FAQ và chốt ngoại lệ.
- **Chóng mặt ở góc nhìn thứ nhất:** clip quay từ người thật có nhún đầu. Cách giảm: chọn clip êm, giới hạn độ lệch mắt, có thể giữ mắt ổn định tách khỏi đầu.
- **Lệch dáng khi chuyển khung xương:** Tripo dựng xương dáng chữ A, Mixamo dáng chữ T. Dự án đã xử lý việc này cho clip Quaternius (`fix_silhouette`); mẫu thử ở bước 2 sẽ cho thấy có đủ không.
- **Test ghim tư thế cũ:** khoảng 10 file test tay và thân (T-239, T-241, T-242, T-243, T-249…) đo vị trí tay, mắt, độ gập. Dáng đứng mới sẽ làm lệch số đo; phải rà từng test.
- **Bước 4 khó nhất:** trộn clip người thật với IK mà tay vẫn tới đúng chỗ trong đúng 1 giây. Nếu trộn không đẹp thì phương án lùi là giữ IK như nay và chỉ thêm chuyển động thân nhẹ.
- **Máy ít RAM:** mỗi bước kết thúc bằng full test chạy trực tiếp từng phần, như T-266 và T-267.

## 6. Ngoài phạm vi
- Xác sống, bạn học, bảo vệ (T-221, chờ mẫu Tripo).
- Thân Trần Trung ở chương 4 (chưa có; việc riêng).
- Đổi luật, tốc độ, thời gian thao tác.

## 7. Câu hỏi cho chủ dự án
1. **Giấy phép Mixamo:** bạn đọc FAQ chính thức (helpx.adobe.com, "Mixamo FAQ") khi đăng nhập rồi cho biết có chấp nhận ngoại lệ không. Đề xuất: chấp nhận, với cách giữ an toàn ở mục 2.
2. **Tải bằng nhân vật nào:** (a) dùng hình nhân mặc định của Mixamo, chỉ lấy chuyển động; (b) tải Trần Trung và quản lý lên Mixamo để clip khớp tỉ lệ người. Đề xuất (a): không phải đưa nhân vật của dự án lên dịch vụ ngoài, và đường chuyển khung xương đã có sẵn.
3. **Chỗ nào bạn thấy khó chịu nhất hiện nay?** Kể 3–5 chỗ, hoặc để tôi quay video hiện trạng (bước 0) cho bạn đánh dấu. Đề xuất: làm bước 0.
4. **Lượt chơi thử (D-176):** chơi trước hay sau đợt chuyển động này? Đề xuất: sau bước 2 (mẫu thử) thì chơi một lượt bản hiện tại, vì bước 3–5 còn dài; lỗi gameplay tìm sớm thì sửa sớm.
5. **Ai làm:** integrator làm cả, hay chia phần đóng gói cho lane B? Đề xuất: integrator làm cả.
