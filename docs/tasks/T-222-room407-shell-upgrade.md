# T-222 — Nâng vỏ phòng 407 (tường, trần, sàn, cửa, ban công) cho hợp đồ Tripo
- Lane: **chủ dự án + Claude** (chủ dự án tạo các cánh cửa và tay nắm trên Tripo; Claude làm phần còn lại, ghi "Claude làm thay B") | Trạng thái: **mới (D-126); cửa ban công đã chọn (D-127); chờ chủ dự án tạo cửa trên Tripo** | Agent: chủ dự án + Claude
- Quyết định:
  - **D-126**. Chủ dự án: "Tôi duyệt hướng này để bạn viết card T-222, BAN CÔNG THÊM CỬA".
  - **D-127**: cửa ban công là cửa cánh nhôm kính có tay nắm gạt, mở sẵn lúc vào chương.
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
