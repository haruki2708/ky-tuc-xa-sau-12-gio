# T-222 — Nâng vỏ phòng 407 (tường, trần, sàn, cửa, ban công) cho hợp đồ Tripo
- Lane: **chủ dự án + Claude** (chủ dự án tạo các cánh cửa và tay nắm trên Tripo; Claude làm phần còn lại, ghi "Claude làm thay B") | Trạng thái: **D-129: vào bản chơi (22/10/2026); D-130: người chơi tự đóng/mở cửa ban công làm cùng T-220 bước 5; D-131: đo FPS; D-132: tối ưu shader vỏ, 1080p thấp nhất 86 FPS, hình không đổi** | Agent: chủ dự án + Claude
- Quyết định:
  - **D-126**. Chủ dự án: "Tôi duyệt hướng này để bạn viết card T-222, BAN CÔNG THÊM CỬA".
  - **D-127**: cửa ban công là cửa cánh nhôm kính có tay nắm gạt, mở sẵn lúc vào chương.
  - **D-128**: lượt 1 (vỏ mới, ban công, cửa nhà tắm, cửa ban công, tay nắm Tripo) trong cảnh thử.
  - **D-129**: chủ dự án duyệt ảnh ("ok tôi thấy ok rồi đấy"), vỏ mới vào bản chơi.
  - **D-130**: người chơi tự đóng/mở cửa ban công để tới T-220 bước 5 ("chọn phương án a đi").
  - **D-131**: đo FPS ([báo cáo](../../tools/reports/D-131-room407-t222-performance.md)).
  - **D-132**: tối ưu shader vỏ ngay, hình không đổi ("chọn (a)").
- Phụ thuộc:
  - **G3** (T-215, D-103…D-114): vỏ phòng hiện là vỏ của góc phòng T-213, vật liệu CC0, dựng bằng `game/scenes/levels/room407/room407_furnish.gd` từ `game/data/room407/`;
  - **T-220, D-124:** tay nắm cửa gạt (`DoorHandles`, `HandTarget.lever`), camera nhìn theo tay nên khung cửa và tay nắm bị nhìn rất gần;
  - **D-125:** cửa nhà tắm mở 82°, cụm bồn rửa đã lùi 22 cm.

## Vì sao
Integrator đánh giá ngày 20/10 trên ảnh G3 (`art_source/graphics_upgrade/room407_furnished/previews/g3/`): đồ Tripo trông như đồ thật đã dùng lâu, còn vỏ phòng trông như mô hình sạch, nên đồ giống được dán vào.

| Phần | Điểm (Tripo ≈ 8/10) | Vấn đề |
|---|---|---|
| Tường | 5 | Phẳng, màu đều như mới sơn; vết bẩn là mảng xám dán lên, hình na ná nhau; không có gạch chân tường, vệt ố chảy, sơn bong, vết tay |
| Trần | 4 | Tối xỉn, phẳng; thiếu vôi ngả vàng, vết dột, vết nứt; đèn tuýp không máng |
| Sàn | 6 | Gạch sạch, bóng đều; ron không bẩn, không gạch nứt, không vệt nước từ nhà tắm |
| Cửa, khung cửa | 4 | Tấm phẳng sơn xanh, không khung, không bản lề, không ô pano |
| Ban công | 3 | Nhìn ra là một khoảng xanh trống; không có cửa |
| Nhà tắm | 6 | Gạch ổn; ron quá sạch, chân tường không ố, trần tối |
| Hành lang tầng 4 | 2 | Vẫn PS1; **không thuộc card này** (G5) |

## Mục tiêu
Vỏ phòng 407 cùng mức chân thật và mức cũ bẩn với đồ Tripo:
- trong **cảnh thử** trước, có ảnh trước/sau cùng góc và cùng đèn với G3;
- chủ dự án duyệt rồi mới vào bản chơi.

**Không đổi:** luật, độ khó, bố cục lối đi, va chạm của tường và sàn, vị trí đồ (trừ cửa ban công mới).

## Việc cần làm
1. **Cánh cửa và tay nắm (chủ dự án tạo trên Tripo):**
   - theo phiếu [`docs/handoff/TRIPO_CUA_PHONG407.md`](../handoff/TRIPO_CUA_PHONG407.md);
   - 3 cánh cửa (phòng, nhà tắm, ban công) và 1 tay nắm gạt.
   - Claude dựng thẳng, đặt bản lề đúng mép, giảm lưới và nướng như các đồ Tripo trước (`art_source/graphics_upgrade/tripo/bake_prop.py`).
   - Thay các tấm cửa phẳng hiện có; gắn tay nắm hai mặt bằng `DoorHandles`.
2. **Khung cửa (Claude, Blender):**
   - khung gỗ có nẹp cho cửa phòng và cửa nhà tắm, khung nhôm cho cửa ban công;
   - sơn cũ, mòn ở chỗ hay chạm tay;
   - bản lề lộ ra ở mép cánh.
3. **Tường (Claude, Blender + CC0):**
   - texture vôi/sơn tường có hư hại thật (ambientCG hoặc Poly Haven, CC0), độ lồi lõm nhẹ (normal);
   - **gạch chân tường** cao khoảng 10 cm quanh phòng;
   - bẩn tự nhiên ở chân tường, góc phòng, quanh công tắc, ổ cắm, khung cửa, chỗ thang giường;
   - thay các mảng xám hiện tại bằng vệt ố chảy từ trần, sơn bong quanh ban công và nhà tắm (ẩm), vết trầy, vết băng keo, lỗ đinh.
4. **Trần (Claude):**
   - vôi trắng ngả vàng, vết dột loang, vết nứt, mạng nhện ở góc;
   - máng đèn tuýp, đế quạt trần.
5. **Sàn (Claude):**
   - gạch đã mòn: ron bẩn, vài viên nứt hoặc mẻ;
   - vệt nước và dấu chân ướt từ cửa nhà tắm ra;
   - độ bóng không đều (chỗ hay đi mờ hơn).
6. **Nhà tắm (Claude):** ron gạch bẩn, ố mốc ở chân tường và quanh ga thoát nước, trần vôi ẩm.
7. **Ban công (Claude):**
   - **cửa ban công mới** (D-126, D-127): cửa cánh nhôm kính, mở bằng tay như cửa phòng: bản lề, tay nắm gạt hai mặt, `HandTarget`, có va chạm;
   - lúc vào chương cửa **mở sẵn** (D-127); cánh mở không chắn lối ra ban công, không đè rèm, không thu hẹp lối qua cửa;
   - lan can thật, đồ phơi;
   - cảnh ngoài: dãy nhà ký túc đối diện có vài ô cửa sáng đèn, trời đêm, ánh trăng như D-113.
8. **Chỉ số:**
   - texture ≤ 2048²;
   - ghi nguồn CC0 vào `CREDITS.md`;
   - đo FPS phòng 407 sau khi xong (hỏi chủ dự án trước), so với D-114 (thấp nhất 97,7 FPS ở 1080p).
9. **Test:**
   - vỏ mới có đủ phần (chân tường, khung cửa, cửa ban công);
   - va chạm và lối đi không đổi (navmesh, tầm với của các điểm tương tác ở T-216);
   - cửa ban công mở/đóng bằng tay, không xuyên tường hay lan can;
   - các chương có đi ra ban công vẫn qua được.
10. **Ảnh trước/sau:** dùng lại các góc G3 (`room407_g3_capture.tscn`), thêm cận cảnh khung cửa, chân tường, trần, ban công.

## Cửa ban công (D-127, chủ dự án chọn 21/10/2026)
Chủ dự án chọn cả hai đề xuất của integrator:
1. **Kiểu cửa:** (a) cửa cánh nhôm kính có tay nắm gạt, dùng chung cơ chế tay nắm đã có. Không làm cửa lùa.
2. **Lúc vào chương:** (a) mở sẵn, thời gian các chương giữ nguyên. Người chơi vẫn đóng, mở bằng tay được (1 giây, D-121).

## Không làm
- Hành lang tầng 4 và các tầng khác: G5.
- Đồ vật trong phòng: đã duyệt ở D-097…D-102.

## Handoff (người làm điền)

### Lượt 1 (21–22/10/2026, Claude làm thay B, Opus 5.5): cảnh thử xong, chờ chủ dự án xem ảnh

**Bản chơi chưa đổi.** Vỏ mới chỉ bật khi `room407.gd` có `shell_t222 = true` (cảnh chụp `room407_g3_capture.tscn -- --g3-capture --shell-t222`). Cách dựng lại, cách làm: [`art_source/graphics_upgrade/room407_shell/README.md`](../../art_source/graphics_upgrade/room407_shell/README.md); nguồn: `CREDITS.md` cùng thư mục.

**Đã làm:**
- **Vỏ phòng dựng lại** (`build_shell.py`, 6 GLB ở `game/assets/models/graphics_pilot/room407_shell/`):
  - tường, trần, sàn, mặt ngoài ban công có hai lớp UV;
  - shader `game/rendering/room407_shell.gdshader` trộn texture CC0 với bản đồ bẩn vẽ riêng cho từng mặt (`make_shell_masks.py`): bong sơn, bẩn, vết nước có viền ố, mốc; trên sàn có bẩn ron, ướt, lối đi mòn;
  - gạch chân tường 10 cm quanh phòng;
  - sàn gạch xếp thẳng theo tường (bản cũ xếp chéo);
  - sàn nhà tắm gạch chống trơn.
- **Vết bẩn theo vị trí thật:**
  - tường:
    - dầu tóc cạnh gối 4 giường;
    - tay bẩn quanh công tắc và mép cửa;
    - khói đen sau tủ lạnh;
    - ẩm chân tường lan từ nhà tắm ra (sơn phồng bong);
    - vệt dột;
    - mốc nhà tắm;
    - vết poster đã gỡ (keo vàng, lỗ đinh);
    - vết cào;
  - trần:
    - vết loang có vòng ố;
    - nứt;
    - khói đèn;
    - bụi quanh quạt;
    - mạng nhện 4 góc;
  - sàn:
    - dấu chân ướt từ cửa nhà tắm tới giường Trung;
    - vũng nước dưới bình lọc;
    - vết vòng xô;
    - vết giày.
- **Khung cửa:**
  - cửa phòng: khung gỗ sơn xanh có nẹp, 3 bản lề, ngưỡng đá;
  - cửa nhà tắm: khung kem;
  - cửa ban công: khung nhôm đặt sát mép ngoài tường để cánh mở ra ngoài gần 180°.
- **Máng đèn tuýp** men trắng ngả vàng, hai bóng.
- **Cửa Tripo** (`prep_doors.py`, `prep_lever.py`, `../tripo/bake_prop.py` thêm `--low`):
  - cửa nhà tắm: cắt khung, tô lại chỗ tay nắm in sẵn, lấy mặt trước làm mặt sau (lá sách xuyên cửa), 4.281 tam giác;
  - cửa ban công: cắt khung, ép núm tay nắm, 4.170 tam giác;
  - tay nắm: xoay về quy ước `DoorHandles`, đế 54 mm, 2.940 tam giác;
  - mỗi cánh gắn 2 tay nắm Tripo ở phía chốt, gắn tĩnh;
  - cửa phòng vẫn là tấm tạm, chờ lượt 2.
- **Cửa ban công (D-127):** cánh treo trên `fixtures/BalconyDoorPivot`, mở sẵn 172°, áp vào tường ngoài phía đông. Test kiểm cánh không chắn lối, không chạm vách ngăn và lan can.
- **Ban công** (trước đây vô hình trong bản chơi vì phần PS1 bị ẩn):
  - sàn gạch, vách ngăn, lan can xây có gờ, trần ban công, ga thoát nước, vòi nước;
  - 2 áo phơi Tripo;
  - khăn chương 2 (`TowelSpot`, đồ cầm được) dời lên dây phơi mới (2,8; 2,15; −7,85) và vẽ bằng khăn Tripo. Chỉ áp dụng với vỏ mới; vỏ cũ vẫn để ở (2,8; 1,8; −8,12), chỗ đó trước nay khăn lơ lửng.
- **Bên ngoài** (`build_outside.py`, khoảng 22.600 tam giác):
  - ban công hàng xóm 6 tầng ở cả hai phía;
  - sân, cây, đèn sân;
  - dãy ký túc đối diện cách 22 m, vài ô cửa sáng đèn;
  - trời đêm có trăng; trời và ô cửa sáng không bị sương mù che.
- **Test** `game/tests/levels/test_room407_shell.gd`, 8 test:
  - đủ phần;
  - chỉ để nhìn (không thêm va chạm);
  - shader có bản đồ bẩn;
  - phần tường cửa đi theo tường hành lang;
  - cửa nhà tắm Tripo quay theo bản lề;
  - cửa ban công mở đúng chỗ;
  - khăn trên dây;
  - vỏ cũ giữ nguyên;
  - texture ≤ 2048.

### Lượt 1b (22/10/2026): cửa phòng Tripo lượt 2

- Chủ dự án tạo `door_room_r2.glb` (một cánh, 5 ô pano).
- Claude cắt khung, bỏ tay nắm và ổ khóa, lấy mặt trước làm mặt sau, nướng còn 5.057 tam giác.
- Tay nắm Tripo hai mặt ở phía chốt (x 1,615). `floor4.gd` treo chúng lên `Door407/Pivot/HandlePivot` (dời về trục tay nắm) và ẩn tay nắm hộp PS1, nên cảnh rung tay nắm từ hành lang vẫn rung. Vỏ cũ không đổi.
- Tay nắm nướng lại còn 1.372 tam giác.
- 9 test.

### Lượt 2 (22/10/2026, D-129): vào bản chơi (Claude làm thay B, Opus 5.5)

- **Bản chơi dùng vỏ mới:** `room407.gd` `shell_t222` mặc định bật. Tắt thì về vỏ góc T-213: `room407_g3_capture.tscn -- --g3-capture --shell-corner` vẫn chụp được ảnh trước; không cờ thì chụp đúng phòng như trong game.
- **Cửa ban công có bản lề và va chạm** (`game/scenes/levels/room407/balcony_door.tscn`, `balcony_door.gd`):
  - `room407.gd` đặt `Extension/BalconyDoor` lên trục bản lề của vỏ, treo cánh Tripo lên `Pivot` của nó;
  - hộp va chạm lấy đúng kích thước cánh, không tính tay nắm;
  - mở sẵn đúng góc vỏ dựng (172°, D-127), `set_open(false)` đóng kín ô cửa;
  - như cửa nhà tắm, đây chỉ là hình khối: chương nào cần đóng/mở thì gọi `set_open`.
- **Người chơi chưa tự đóng/mở cửa ban công trong bản chơi** (giống cửa nhà tắm). Nếu cho đóng thì quản lý (chương 1) phải biết mở cửa này như cửa nhà tắm, và đường ra ban công thêm 1 giây. **D-130:** chủ dự án chọn để tới T-220 bước 5.
- **Cảnh thử T-220** (`protagonist_pilot.tscn`):
  - tay nắm Tripo nhận tay ở cửa phòng, cửa nhà tắm và cửa ban công (`DoorHandles.take`, điểm nắm trên thanh gạt Tripo);
  - cửa ban công mở/đóng bằng tay: phải ra ban công, đứng trước cánh đang áp tường;
  - lệnh chụp có `--shots=a,b` để chụp lại vài ảnh; thêm 2 ảnh `balcony_door_*`.
- **Test** `test_room407_shell.gd`, 14 test, thêm:
  - va chạm đúng bằng cánh;
  - đóng kín ô cửa; quay từ đóng tới mở không lấn vào phòng, không xuyên lan can hay vách ngăn;
  - tay nắm phía tường không chạm tường;
  - cánh mở cách mọi cạnh đường đi của quản lý (`ManagerNavigation`) từ 0,3 m trở lên;
  - tay nắm Tripo của 3 cửa nhận tay, ấn thì thanh gạt đi xuống;
  - bản chơi dùng vỏ mới; vỏ cũ vẫn dựng được.
- Cả bộ test: 834/834.

### Đo FPS (22/10/2026, D-131)

[Báo cáo](../../tools/reports/D-131-room407-t222-performance.md). Cách đo giống D-114, thêm 3 góc ban công, vỏ cũ đo lại cùng lúc để so.
- 1080p vẫn đạt ≥60 ở mọi góc: thấp nhất 75 FPS (`door_overview`, đèn trần nhấp nháy), 94 FPS khi chỉ có đèn pin. D-114 vỏ cũ: 97,7 và 124.
- Các góc trong phòng chậm hơn vỏ cũ 20–25%, góc nặng nhất thêm khoảng 2,9 ms mỗi frame.
- Nguyên nhân chính là shader bẩn `game/rendering/room407_shell.gdshader`: tường và trần đọc 9 texture mỗi điểm ảnh. Thay bằng chất liệu thường thì gần bằng vỏ cũ. Cảnh bên ngoài tốn khoảng 0,5 ms; khung cửa gần như không tốn gì.
- Phần dư cho G4 ở góc nặng nhất còn khoảng 3,4 ms (D-114: 6,5 ms).

### Tối ưu shader vỏ (22/10/2026, D-132, Claude làm thay B)

[Báo cáo mục 4](../../tools/reports/D-131-room407-t222-performance.md).
- `game/rendering/room407_shell.gdshader` chỉ đọc 3 texture lớp sơn bong ở chỗ sơn thật sự bong (theo mặt nạ: 1–2% tường và trần, 13% ban công), và chỉ đọc nhiễu thô ở chỗ có vết nước hoặc mốc. Sàn không còn đọc nhiễu thô (không dùng tới).
- Gradient lấy trước khi rẽ nhánh (`textureGrad`), nên mức mip giữ nguyên. Chỗ bị bỏ qua vốn trộn với trọng số 0, nên về toán học hình không đổi.
- **Hình:** 38 ảnh (19 góc × đèn pin/đèn trần) lệch tối đa 1/255 so với trước; ảnh so sánh `art_source/graphics_upgrade/room407_shell/previews/compare_d132.jpg`.
- **FPS 1080p:** góc nặng nhất từ 75 lên 86 (13,3 → 11,6 ms mỗi frame); khi chỉ có đèn pin thấp nhất 112 FPS; dư khoảng 5 ms cho G4 (D-114: 6,5 ms).
- Cả bộ test: 834/834.

**Chưa làm:**
- người chơi tự đóng/mở cửa ban công trong bản chơi: làm cùng T-220 bước 5 (D-130).
