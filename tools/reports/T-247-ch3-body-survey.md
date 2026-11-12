# T-247 — Khảo sát đưa thân Trần Trung vào chương 3

Lane B (Claude, Opus 5.5), 12/11/2026. Nhánh `lane-b/T-247-protagonist-chapter3-survey`, gốc `origin/main` `fc57369` (card đọc ở commit `fc57369`).

**Lượt này không sửa game.** Thân được bật thử trong một cảnh tạm (`game/_probe_tmp/`, đã xoá): nạp `chapter3.tscn` thật, đặt `protagonist_body = true` trước khi vào cây (như chương 1–2), `auto_start = false`, rồi cho director chạy từng mốc bằng `run_from`. Người chơi đi bằng phím thật (đi, chạy, khom), đi cầu thang theo lưới dẫn đường như bot. Số đo lấy trên xương đã dựng. Ảnh 1080p trong `art_source/graphics_upgrade/protagonist/previews/t247/`.

Luật đã duyệt ở chương 1–2 giữ nguyên, chỉ đề xuất cho chương 3:
- đồ tầm bàn trở lên: đứng gập hông ≤ 40°;
- đồ thấp: cúi gập 1,4 s;
- tay phải cầm đồ; đang cầm vẫn làm việc khác bằng nắm tay đang cầm;
- tự bước tránh cánh cửa;
- chết thì thân ẩn, camera ngã như cũ (D-151).

## 1. Bảng quyết định cho chủ dự án

Mỗi dòng một thao tác. **In đậm** là phương án đề xuất. Cột cuối là việc phải làm nếu chọn đề xuất.

| # | Thao tác (chương 3) | Code hiện có (đo được) | Phương án | Việc nếu chọn đề xuất |
|---|---|---|---|---|
| 1 | **Cầm thanh sắt** (Ngư đưa, nhặt thêm) | Thanh là một hộp xám treo trước camera; tay thân trống. Nhìn từ ngoài thấy thanh lơ lửng cạnh ngực (ảnh `b1`, `b4`) | **(a) Thanh nằm trong nắm tay phải**, cầm như giẻ chương 2: đi lại thì buông dọc chân, góc mắt thấy đầu thanh và nắm tay<br>(b) Giữ thanh trước camera như nay, chỉ ẩn ở góc ngoài<br>(c) Hai tay cầm thanh trước ngực | Mô hình thanh sắt (Blender, ống thép ~0,85 m, cong dần theo số lần đập như nay); gắn vào bàn tay phải như `take_item` (T-243) |
| 2 | **Vung thanh sắt** (chuột trái, 0,55 s, tầm 1,5 m) | Chỉ hộp trước camera xoay; thân đứng yên (ảnh `b2`) | **(a) Bổ chéo từ vai phải xuống**: tay phải vung, ngực xoay theo, chân đứng nguyên; 0,55 s như cũ<br>(b) Đâm thẳng về trước<br>(c) Giữ như nay (chỉ thanh trước camera) | Động tác vung bằng IK tay phải và xoay ngực (`BodyLeanModifier` đã có). Thời gian, tầm, luật trúng đầu không đổi |
| 3 | **Nhặt thanh sắt dưới đất** | Với thân: cúi gập 1,4 s đúng luật T-241, nhưng thanh biến mất ngay lúc tay chạm và tay bật về ngay, thân đứng dậy tay không (ảnh `b4`) | **(a) Cúi gập 1,4 s, thanh vào tay lúc chạm rồi đứng dậy cầm thanh**<br>(b) Riêng thanh sắt cúi nhanh 1 s (đang bị đuổi)<br>(c) Bấm là có thanh, không động tác | Theo (1). Thêm: hai thanh B05 (cổng) và B06 (gần nhà ăn) nằm thấp hơn tầm lòng bàn tay 4 cm khi cúi (đo: vai cách thanh 0,574 m, tầm lòng bàn tay 0,535 m), nên **có thân thì không hiện lời nhắc**: nâng điểm cầm lên mặt thanh hoặc cho nắm bằng đầu ngón |
| 4 | **Ngư đưa thanh sắt** (vườn hoa, `give_bar`) | Ngư nói xong thì thanh hiện ngay trước camera | (a) Ngư chìa thanh, Trung đưa tay nhận (cần động tác cho Ngư; Ngư còn là khối PS1)<br>**(b) Thanh hiện thẳng trong nắm tay phải** khi Ngư nói xong (đợt này)<br>(c) Ngư đặt thanh lên ghế đá, người chơi tự nhặt (đổi cách chơi) | Theo (1). Làm (a) khi có mô hình Ngư thật |
| 5 | **Lấy chìa khoá cầu thang thoát hiểm** (bàn trực tầng 4) | `Ch3Use`, chưa có chỗ đặt tay: có thân vẫn bấm E là xong, không động tác. Chìa nằm ở 0,66 m, dưới mặt bàn 0,80 m, tức trong ngăn kéo (ảnh `b5`) | (a) Hai bước: mở ngăn kéo, rồi lấy chìa<br>**(b) Một thao tác 1 s**: đứng gập hông, kéo ngăn kéo ra, nhón chìa, chìa nằm trong nắm tay rồi cất<br>(c) Dời chìa lên mặt bàn, nhón như thẻ | Mô hình ngăn kéo trượt được và chỗ đặt tay (lane B), `HandTarget` cho `Use_FireKey` (core) |
| 6 | **Mở khoá cửa thoát hiểm** | `Ch3Use` phủ cả cánh, chưa có ổ khoá hay tay nắm; cánh là khối PS1. Chưa có chìa thì chỉ có suy nghĩ "Khóa rồi" (ảnh `b6`) | **(a) Có chìa: tra chìa vào ổ, vặn, đẩy cửa** (1 s); chưa có chìa: nắm tay nắm giật hai cái, cửa không mở<br>(b) Nắm tay nắm mở như cửa 407 (bỏ qua động tác chìa)<br>(c) Bấm như nay | Ổ khoá và tay nắm trên cánh (lane B, Blender), điểm đặt tay đi theo cánh (core) |
| 7 | **Đập bình cứu hoả tầng 2** (gây tiếng động cứu Minh Nhật) | `Ch3Use`, bấm E là phát tiếng 25 m; bình vẫn treo nguyên trên tường (ảnh `b7`) | **(a) Giật bình khỏi giá, đập đáy bình vào tường một cú, bình rơi xuống sàn** (khoảng 1 s)<br>(b) Đấm vào bình trên giá, bình rung<br>(c) Giật bình rồi ném xuống sàn | Tay phải nắm cổ bình (`ExtinguisherHandle` đã có), bình theo tay rồi rơi và nằm lại dưới sàn |
| 8 | **Bấm chuông báo cháy tầng 1** | `Ch3Use` ở 1,40 m, bấm E là xong; hộp đỏ do core vẽ tạm (ảnh `b8`) | (a) Ấn bằng đầu ngón, như công tắc chương 2<br>**(b) Đập lòng bàn tay vào nút** (lúc khẩn cấp)<br>(c) Kéo cần xuống | Chỗ đặt tay trên mặt hộp; hộp báo cháy thật (lane B) |
| 9 | **Đi, chạy trên cầu thang** (thoát hiểm, chính) | Thân dùng clip đi, chạy trên mặt phẳng. Đo: mũi chân lún vào bậc 4–6 cm khi đi, tới 25 cm khi chạy; chân kia lơ lửng tới 38 cm (ảnh `c1`–`c3`) | **(a) Bàn chân bám bậc bằng IK** (code, không cần clip mới)<br>(b) Clip đi cầu thang riêng (UAL/UAL2 không có, phải tạo trên Tripo)<br>(c) Giữ như nay (nhìn thẳng thì không thấy chân) | IK chân theo mặt bậc dưới mỗi bàn chân, dùng lại cách `BodyLeanModifier` giải lại chân |
| 10 | **Chui qua cửa sổ phòng quản lý** (khom, không ai chỉ lối, D-055) | Người chơi đi khom, khối va chạm tự bước lên bậu cao 1 m; thân đi khom trên không, chân lơ lửng 30–45 cm (ảnh `c4`) | (a) Thêm thao tác "Trèo qua" 1,5 s (tay chống bậu, một chân bước qua): **có lời nhắc là gợi ý lối thoát, trái D-055**<br>**(b) Không lời nhắc: đi khom qua như nay, tay chống bậu và chân bám bậu tự động khi đi ngang**<br>(c) Giữ như nay | IK chân (chung với dòng 9) và tay trái chống bậu khi khối va chạm đang trèo |
| 11 | **Nhìn lại phía sau khi đang chạy** | Quay chuột ra sau lúc chạy thì thân coi như chạy giật lùi: clip chạy phát ngược (ảnh `c5`) | **(a) Chân vẫn chạy theo hướng di chuyển, ngực và đầu ngoảnh theo camera** (tối đa khoảng 90°)<br>(b) Giữ chạy giật lùi như nay<br>(c) Quay ra sau thì thân quay theo, chạy lùi bằng clip đi lùi | Code locomotion (`_tick_locomotion`), không cần clip mới |
| 12 | **Hết thể lực** (thở dốc) | Không có tư thế riêng; chỉ tiếng thở | (a) Đứng yên lúc cạn sức thì chống tay lên gối (camera hạ xuống)<br>**(b) Chỉ ngực phập phồng, vai nhô theo nhịp thở** (camera không đổi)<br>(c) Giữ như nay | Nhịp thở trên ngực và vai (modifier nhỏ) |
| 13 | **Cảnh chết** `zombie_grab`, `guard_shock` | Thân ẩn, camera ngã như chương 1–2 (D-151); không xuyên camera (ảnh `a8`, `a9`) | **(a) Giữ như nay**<br>(b) Hiện hai cánh tay giơ lên đỡ trong góc mắt khi bị tóm<br>(c) Thân ngã cùng camera | Không |

Không cần chọn (giữ như chương 1–2, đã chạy đúng ở chương 3):
- **Cửa 407, cửa nhà tắm, cửa ban công:** mở bằng tay như chương 1 (ảnh `a2`).
- **Đồ của phòng 407** (giấy, thẻ, ổ điện, tủ, thùng rác): chạy y như chương 1.
- **Đi khom:** dùng clip khom như chương 1 (ảnh `c6`).
- **Điện thoại tay trái, đèn pin:** ngoài trời vẫn đúng cách cầm T-239 (ảnh `c7`). Khi tay phải cầm thanh sắt thì cả hai tay đều bận, không xung đột.

## 2. Phần A — bật thân ở chương 3 (cảnh tạm)

| Mốc | Kết quả | Thứ hỏng hoặc lạ |
|---|---|---|
| `b` (phòng 407, nhà B) | Thân đứng đúng chỗ, mắt khớp camera (lệch 1,4 cm). Cửa 407 mở bằng tay | Không |
| `garden` (vườn hoa) | Thân, hai đồng đội vào đúng | **Người chơi đứng trên đầu Minh Nhật:** cả hai cùng đặt ở `Start_garden`, người chơi cao lên 1,7 m rồi rơi xuống (ảnh `a3`). Lỗi có từ trước (không do thân), thân chỉ làm lộ ra |
| `stadium` (sân vận động) | Chạy nước rút trông tự nhiên (ảnh `a6`) | Đứng yên 3–4 s ở điểm bắt đầu là bị đợt xác đầu tiên tóm (probe đứng yên). Không do thân |
| `gate` (cổng, nhà ăn) | Đúng | Đồng đội đứng sát ngay trước mặt lúc vào khu (ảnh `a7`) |
| `end3` | Đúng | Không |
| Cầu thang thoát hiểm, cầu thang chính | Đi và chạy xuống được | Chân lún và lơ lửng (bảng 1, dòng 9) |
| Cửa sổ phòng quản lý | Đi khom qua được | Chân lơ lửng (bảng 1, dòng 10) |
| Cảnh chết (`zombie_grab`, `guard_shock`) | Thân ẩn ngay khi bắt đầu chết, camera ngã như cũ | Không |
| Điện thoại, đèn pin ngoài trời | Đúng cách cầm T-239 | Không |

Không có lỗi script nào trong mọi lần chạy (15 lượt mở chương 3).

Thêm hai điều đo được, không phải lỗi:
- **Lúc chạy, mắt của thân lệch camera 20–27 cm** (clip chạy cúi người tới; lúc đứng lệch 1–5 cm). Góc thứ nhất không thấy vì đầu thân bị ẩn. Ngoài trời không có gương nên chưa gây hại gì. Nếu sau này có gương hay camera ngoài thì cần đặt mắt theo clip chạy.
- **Tán cây hình nón ở vườn hoa không có va chạm** (chỉ thân cây có), nên thân lẫn vào tán khi chạy sát (ảnh `a4`). Có từ trước.

## 3. Phần B — mọi thao tác bằng tay của chương 3

### Nhóm 1: đồ đã có `HandTarget` (31 đồ, lấy bằng code)
- **Phòng 407: 23 đồ**, gồm giấy và thẻ, tủ, đệm, thùng rác, ổ điện, dây mạng, ổ mạng, đèn bàn, gõ tường, tủ Đạt, cửa 407 và chốt, cửa nhà tắm, cửa ban công.
  - Chạy y như chương 1: cùng chỗ đứng, cùng cách với (đứng gập hông, cúi gập, nhón).
  - Số đếm khác bảng T-231 (28) vì nay có thêm hai cửa mở bằng tay (T-242) và cửa 407 nhận tay.
- **Thanh sắt: 7 thanh.** Sáu thanh do director đặt, một thanh trên quầy thư viện.

| Thanh | Chỗ | Cao so với sàn | Có thân: với được không |
|---|---|---|---|
| B01 | Vườn hoa, trên giường tầng đổ | 0,12 m | Cúi gập, 160 chỗ đứng |
| B02 | Sân vận động | 0,06 m | Cúi gập, 64 chỗ đứng |
| B03 | Sân vận động | 0,14 m | Cúi gập, 160 chỗ đứng |
| B04 | Đường nội bộ | 0,06 m | Cúi gập, 64 chỗ đứng |
| **B05** | Cổng trường | 0,02 m | **Không** (thiếu 4 cm, bảng 1 dòng 3) |
| **B06** | Gần nhà ăn | 0,02 m | **Không** |
| Quầy thư viện | Trong thư viện | 0,92 m | Không vào được ở chương 3 (thư viện đóng) |

- Người chơi chưa có thân thì vẫn nhặt được cả 7 thanh như cũ (không đổi gì).
- Có thân, mất B05 và B06 thì vẫn còn thanh của Ngư và 4 thanh khác, nên không kẹt chương. Nhưng nên sửa trước khi bật thân.

### Nhóm 2: `Ch3Use` (core tạo bằng code, chưa có chỗ đặt tay)
| `Ch3Use` | Chỗ, cao so với sàn | Có thân hôm nay | Đề xuất T-231 | Đề xuất động tác |
|---|---|---|---|---|
| `Use_FireKey` | Ngăn kéo bàn trực tầng 4, 0,66 m | Bấm E là xong | PINCH trên thân chìa | Bảng 1 dòng 5 |
| `Use_FireDoor` | Cánh cửa cầu thang thoát hiểm | Như trên | GRIP mặt cánh (còn chờ chốt) | Bảng 1 dòng 6 |
| `Use_Extinguisher2F` | Tường cuối hành lang tầng 2, 1,10 m | Như trên | GRIP mặt trên tay cầm | Bảng 1 dòng 7 |
| `Use_FireAlarm1F` | Chân cầu thang chính tầng 1, 1,40 m | Như trên | PINCH mặt trước hộp | Bảng 1 dòng 8 |

Có thân mà chưa có chỗ đặt tay thì `PlayerBody.can_handle` trả `false`, nên E vẫn chạy như khi không có thân. Không hỏng gì, chỉ thiếu động tác.

### Thứ khác
- **Thanh sắt khi vung, khi gãy:** gãy thì hiện nay hộp biến mất. Đề xuất: thanh gãy đôi rơi khỏi tay (đi cùng bảng 1 dòng 1–2).
- **Đồng đội** (Minh Nhật, Ngư) và **bảo vệ** là khối PS1, đứng cạnh thân Tripo nên chênh lệch rất rõ (ảnh `a5`, `a7`). Không thuộc việc thân; ghi lại để chủ dự án biết.
- **Các cửa phòng tầng 2–4** (xác phá cửa): người chơi không dùng tay, không cần làm.

### Luật chương 1–2 dùng lại được không
| Luật | Dùng lại ở chương 3 |
|---|---|
| Đứng gập hông ≤ 40° | Có: chìa khoá, bình cứu hoả, báo cháy, cửa thoát hiểm |
| Cúi gập 1,4 s (D-157) | Có: nhặt thanh sắt (trừ khi chọn bảng 1 dòng 3b) |
| Tay phải cầm đồ (T-243) | Có: thanh sắt, chìa khoá trong lúc ra cửa |
| Đang cầm vẫn làm việc khác bằng nắm tay đang cầm (D-162) | Có: cầm thanh sắt mà mở cửa, bấm báo cháy |
| Tự bước tránh cánh cửa (T-242) | Có, cho cửa thoát hiểm nếu mở bằng tay |

## 4. Phần C — động tác thân riêng của chương 3

Chấm trên thân chương 1–2 hiện có.

| Động tác | Chấm | Đo hoặc thấy | Đề xuất |
|---|---|---|---|
| Chạy dài, chạy nước rút | **Tự nhiên** | Trông tự nhiên (ảnh `a6`, `b3`); bàn chân không trượt đã có test ở chương 1 | Giữ |
| Chạy cùng đồng đội | **Tự nhiên** (thân); đồng đội PS1 | Chưa quay cảnh chạy cạnh đồng đội; thân chạy giống hệt khi chạy một mình | Giữ |
| Chạy du kích ở sân vận động (đổi hướng liên tục) | **Hơi gượng** (theo code, chưa quay) | Thân xoay dần theo hướng chạy, không nghiêng người vào khúc cua | Sau này: nghiêng thân vào khúc cua (không gấp) |
| Đi xuống cầu thang | **Hơi gượng** | Mũi chân lún 4–6 cm, chân kia lơ lửng | Bảng 1 dòng 9 |
| Chạy xuống cầu thang | **Sai** | Mũi chân lún tới 25 cm, chân lơ lửng tới 38 cm | Bảng 1 dòng 9 |
| Qua cửa khi đang chạy | **Chưa thử** | Đã đi bộ qua cửa thoát hiểm (mở sẵn sau khi mở khoá) bình thường; chưa thử lúc chạy | Thử ở card 1 |
| Khom, đi khom | **Tự nhiên** | (ảnh `c6`) | Giữ |
| Chui qua cửa sổ | **Sai** | Đi khom trên không 30–45 cm | Bảng 1 dòng 10 |
| Nấp | Không có chỗ nấp riêng ở chương 3 (phòng 207 chỉ là phòng mở) | | Không cần |
| Nhìn lại phía sau khi chạy | **Sai** | Clip chạy phát ngược | Bảng 1 dòng 11 |
| Bị xác tóm, cảnh chết | **Tự nhiên** (như chương 1–2) | Thân ẩn, camera không xuyên thân | Bảng 1 dòng 13 |
| Jumpscare (xác bò ra từ bồn hoa, xác bật dậy trên bậc…) | **Chưa thử** | Theo code: jumpscare không đụng tới thân hay camera người chơi | Thử ở card 1 |
| Tay trái và điện thoại | **Tự nhiên** | Cầm đúng T-239 cả khi chạy | Giữ |
| Hết thể lực | **Hơi gượng** (không có gì) | | Bảng 1 dòng 12 |

## 5. Phần D — rủi ro và việc cần chủ dự án cho phép (chỉ ghi, chưa làm)

### FPS (không đo)
- Chương 3 vốn nặng nhất: hành lang tầng 4 có 1% thấp nhất 42–57 FPS (T-237), sân vận động tới 30–40 xác ngoài trời.
- Thân tốn khoảng 0,4–1,6 ms mỗi khung (đo ở chương 2, T-243): da Tripo, hai lưới (góc mắt và gương), bản sao tay trái cho gương (T-245).
- Ngoài trời không có gương, nhưng lưới gương vẫn đổ bóng. Chỗ nghi nặng nhất: sân vận động lúc đông xác, và hành lang tầng 4 nhìn dọc ra khuôn viên.
- **Cần chủ dự án cho phép** để đo FPS chương 3 có thân, cùng chỗ với T-237 cộng sân vận động 40 xác.

### Bot chương 3 (không chạy)
- Bot (`tools/ch3-profile.json`, `ch3_actions.gd`) đi bằng phím thật và gọi thẳng hàm của director cho các thao tác (lấy chìa, mở cửa, đập bình, báo cháy). Có thân thì các thao tác này **vẫn tức thì**, vì bot không bấm E.
- Rủi ro khi đã làm theo bảng 1:
  - Nếu vung thanh sắt khoá di chuyển, `strike_blocker` (bấm chuột rồi đi tiếp) có thể chậm, xác đuổi kịp. Đề xuất: vung không khoá di chuyển, như hiện nay.
  - Nếu đi cầu thang có IK chân, bot không bị ảnh hưởng (chỉ hình).
  - Lỗi đứng trên đầu Minh Nhật ở `ch3_garden` có thể làm bot lệch đường ở khu vườn.
- **Cần chủ dự án cho phép** để chạy bot `ch3` sau khi bật thân.

### Tripo
- Không cần tạo gì nếu chọn theo đề xuất: thanh sắt, ổ khoá, ngăn kéo, hộp báo cháy dựng bằng Blender; động tác làm bằng code.
- Chỉ cần Tripo nếu chọn bảng 1 dòng 9b (clip đi cầu thang riêng) hoặc dòng 4a (động tác cho Ngư, sau khi có mô hình Ngư). **Không tiêu credit.**

## 6. Đề xuất chia việc

| Thứ tự | Card (đề xuất) | Nội dung | Lane | Ước lượng |
|---|---|---|---|---|
| 1 | Thân vào chương 3 và thanh sắt | Bật `protagonist_body` ở `chapter3.tscn`; thanh sắt thật trong tay phải: cầm, chạy, vung, gãy, nhặt, Ngư đưa (bảng 1 dòng 1–4); chỗ cầm B05, B06 | B (thân, mô hình thanh), A duyệt chỗ cầm thanh | 1 phiên dài |
| 2 | Các việc nhà B bằng tay | Chìa trong ngăn kéo, cửa thoát hiểm có ổ khoá, bình cứu hoả, báo cháy (dòng 5–8) | B (mô hình), core (`HandTarget` cho `Ch3Use`) | 1 phiên |
| 3 | Chân trên cầu thang, bậu cửa sổ, ngoảnh lại khi chạy, thở dốc (dòng 9–12) | IK chân, tay chống bậu, xoay ngực khi chạy | B | 1 phiên |
| 4 | Kiểm cuối | Test chương 3 có thân, bot `ch3`, đo FPS (cần cho phép); ảnh, video cho chủ dự án | B và C | nửa phiên |

Lỗi có từ trước, ghi cho integrator (không thuộc thân):
- Người chơi và Minh Nhật cùng xuất hiện ở `Start_garden` khi chơi lại từ checkpoint vườn hoa.
- Tán cây vườn hoa không có va chạm.

## 7. Câu hỏi cho chủ dự án
1. Chọn phương án cho 13 dòng ở bảng 1 (hoặc "theo đề xuất").
2. Riêng **dòng 10, cửa sổ phòng quản lý**: D-055 nói không ai chỉ lối này, nên mình đề xuất **không thêm lời nhắc** ("Trèo qua"), chỉ cho tay chân tự bám bậu khi đi khom qua. Chủ dự án đồng ý không?
3. Cho phép **đo FPS chương 3 có thân** và **chạy bot `ch3`** ở bước kiểm cuối (card 4 ở mục 6) không?
4. Có muốn làm dòng 4a (Ngư chìa thanh tận tay) ngay khi có mô hình Ngư thật không, hay giữ (b) lâu dài?

## Ảnh (`art_source/graphics_upgrade/protagonist/previews/t247/`, 1080p, chương 3 thật)
`_mat` là mắt người chơi, `_ngoai` là nhìn từ ngoài. Ngoài trời chụp với ánh sáng của chương (đêm, sương).

| Tiền tố | Nội dung |
|---|---|
| `a1`–`a9` | Phần A: các mốc, cửa 407, đứng trên đầu Minh Nhật, tán cây, chạy ở sân, cổng, cảnh chết |
| `b1`–`b4` | Thanh sắt: cầm, vung, chạy, nhặt (cúi và ngay sau khi nhặt) |
| `b5`–`b8` | `Ch3Use`: chìa khoá, cửa thoát hiểm, bình cứu hoả, báo cháy |
| `c1`–`c7` | Cầu thang (đi, chạy), cửa sổ, chạy giật lùi, đi khom, điện thoại |

Đã tự xem từng tấm. Hai ảnh `a8`, `a9` (cảnh chết) có lớp máu của giao diện; nhìn từ ngoài khi chết không có thân (đúng D-151) nên chỉ giữ góc mắt.
