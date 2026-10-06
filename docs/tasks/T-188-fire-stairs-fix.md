# T-188 — Sửa cầu thang thoát hiểm: khối sập chặn đoạn tầng 3 → tầng 2 (lane E làm thay lane B)
- Lane: E (làm thay lane B, D-060) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-188-fire-stairs-fix`
- Phụ thuộc: T-183, T-187. **Đọc D-058, D-060 trong `docs/DECISIONS.md`**, card T-183 và T-187 (mục Handoff), `art_source/campus/README.md`, `art_source/wide_corridors/README.md`.
- **Hạn: càng sớm càng tốt** (chủ dự án đang chơi thử chương 3).

## Lỗi (chủ dự án chơi thử, integrator xác nhận)
Chương 3, khu nhà B: người chơi mở được cửa thoát hiểm tầng 4, xuống được tầng 3, nhưng **không xuống được tầng 2**. Theo thiết kế (`CH3_DESIGN.md` N3–N4): cầu thang thoát hiểm đi được 4 → 3 → 2; **chỉ đoạn 2 → 1 bị sập**.

**Nguyên nhân** (integrator đã đo):
- node `FireStairs/Collapse` trong `game/scenes/levels/campus/building_b.tscn` có hộp va chạm `BoxShape3D` id `s462` kích thước **(5, 2, 4.2)**, tâm **(46.5, −5.6, −2.1)**;
- hộp này phủ x 44–49, y −6,6…−4,6, z −4,2…0, tức **cả bề ngang buồng thang**, nên chôn mất chân đoạn thang `FireStairsDown3B` (x = 47,8, từ (47.8, −5.1, −4.6) xuống (47.8, −6.62, −0.2));
- bộ dựng: `art_source/campus/build_campus.py` dòng có `s.box('Collapse',(x0+2.5,y+1,-2.1),(5,2,4.2),'concrete',p)`.

Thử bằng một capsule cỡ người chơi (bán kính 0,3, cao 1,6) trượt dọc đoạn 3B: bị chặn bởi `Collapse` ngay đầu đoạn.

## Được phép sửa (ngoại lệ một lần, D-060)
- `art_source/campus/` (chỉ phần khối sập và đống đổ nát của cầu thang thoát hiểm),
- `game/scenes/levels/campus/building_b.tscn` (chỉ `FireStairs/Collapse` và đồ trang trí đổ nát quanh nó),
- `game/tests/levels/` (thêm test mới),
- card này (Handoff).
Không sửa phần khác của map, không đổi tên node hay anchor, không sửa code gameplay.

## Yêu cầu
1. **Khối sập chỉ chặn đoạn xuống tầng 1:** thu `Collapse` về nửa phía x 44–46,5 (phía bắt đầu đoạn 2 → 1, cùng phía với các đoạn "A"), ví dụ kích thước (2.5, 2, 4.2), tâm x = 45,25; giữ y, z. Sửa cả hộp va chạm lẫn mesh, và sửa dòng tương ứng trong `build_campus.py` cho khớp (không dựng lại toàn bộ map; xem cảnh báo trong `art_source/wide_corridors/README.md`).
2. **Không mở ra lối tắt:** người chơi vẫn **không** xuống được tầng 1 bằng cầu thang thoát hiểm (không nhảy hay rơi qua khe xuống chiếu nghỉ tầng 1). Nếu sau khi thu hộp còn khe hở, thêm khối đổ nát hoặc hàng rào chắn hợp lý.
3. **Đồ trang trí đổ nát** (`FireRubbleDetail` và tương tự): nếu có va chạm chặn đoạn 3B thì dời hoặc bỏ va chạm; nhìn vẫn phải thấy rõ là đoạn xuống tầng 1 bị sập.
4. **Test mới** (`game/tests/levels/`), **cho người chơi thật đi bộ**:
   - dùng `scenes/player/player.tscn` trong cảnh Floor4 + Campus như chương 3 (`Campus.set_fire_door_open(true)`), điều khiển bằng velocity/`move_and_slide` theo các điểm mốc: hành lang tầng 4 → qua cửa thoát hiểm → 4A → chiếu nghỉ giữa → 4B → 3A → chiếu nghỉ giữa → 3B → chiếu nghỉ tầng 2 → hành lang tầng 2;
   - kết quả: tới được hành lang tầng 2 (y khoảng −6,6) trong thời gian hợp lý;
   - thêm một test: từ chiếu nghỉ tầng 2 **không** xuống được tầng 1 bằng cầu thang thoát hiểm.
5. Chạy `pwsh tools/test.ps1` và `pwsh tools/check.ps1`; chụp ảnh chiếu nghỉ tầng 2 nhìn xuống đoạn sập.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Test đi bộ 4 → 2 PASS, test chặn 2 → 1 PASS
- [ ] Ảnh chiếu nghỉ tầng 2
- [ ] Handoff: đã sửa gì (kích thước, tọa độ), ghi rõ "lane E làm thay lane B (D-060)"

## Handoff (agent điền)
