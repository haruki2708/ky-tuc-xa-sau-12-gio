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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Test đi bộ 4 → 2 PASS, test chặn 2 → 1 PASS
- [x] Ảnh chiếu nghỉ tầng 2
- [x] Handoff: đã sửa gì (kích thước, tọa độ), ghi rõ "lane E làm thay lane B (D-060)"

## Handoff (agent điền)

### 2026-10-06 — lane E làm thay lane B (D-060)

**Đã sửa và push:** `3deae70` — `T-188: unblock floor three to two fire stairs and test player traversal`, nhánh `lane-e/T-188-fire-stairs-fix`. Commit triển khai và ảnh LFS đã push trước khi điền Handoff này.

- Thu `FireStairs/Collapse`: tâm **(46,5; −5,6; −2,1) → (45,25; −5,6; −2,1)**; cả collision `s462` và mesh `s463` từ **(5; 2; 4,2) → (2,5; 2; 4,2)**. Khối sập chỉ phủ x=44…46,5 phía vế A; vế 3B trở lại chiếu nghỉ tầng 2 được thông.
- `FireRubbleDetail`: position **(22; 0; 0)**, scale **(0,5; 1; 1)**, tương đương `x_mới = 44 + (x_cũ − 44)/2`. Gom chunk/rebar về nửa sập; các chi tiết này vốn không có collision. Không sửa UpperRubble hoặc đồ trang trí khác.
- Đồng bộ đúng phần khối sập trong `build_campus.py` và phần Fire trong `detail.py`; **không chạy dựng lại toàn bộ map**. Không đổi tên/tọa độ anchor, không sửa gameplay, hành lang hay phần khác của scene.
- Không thêm rào hoặc collision mới: các test người thật kiểm tra bảy hướng tiếp cận trên chiếu nghỉ, ba mép trên 3B × đi/nhảy đều không xuống tầng 1. Không suy diễn thêm luật chơi hoặc cơ chế nhảy; xung nhảy chỉ dùng trong test để thử khe hở.

**Kiểm chứng bằng player thật:** `game/tests/levels/test_fire_stairs.gd` dùng Floor4 + Campus, gọi `Campus.set_fire_door_open(true)`, instance `scenes/player/player.tscn` (capsule 1,75 m, bán kính 0,3 m). Test tự cấp velocity/trọng lực và gọi `move_and_slide`, không dịch chuyển trực tiếp giữa các waypoint của tuyến 4 → 2. Tốc độ đi 2,2 m/s, mỗi waypoint tối đa 360 physics frame (~6 giây ở 60 Hz).

- Trên hình học cũ, test đi bộ tái hiện FAIL: chân player **(47,678; −5,031; −4,513)**, collider **`Collapse`** chặn trước chiếu nghỉ tầng 2. Lượt baseline sandbox cũng có lỗi kho chứng chỉ Windows của Godot; lượt xác nhận sau sửa chạy ngoài sandbox, không còn lỗi đó.
- Sau sửa, tuyến đủ cửa → 4A → turn → 4B → 3A → turn → 3B → chiếu nghỉ → hành lang tầng 2 PASS, chân player **(42,118; −6,600; 1,997)**, đang đứng trên sàn.
- Test chặn: bảy vị trí x=44,35/45,25/46,35/46,6/46,9/47,8/48,65 trên chiếu nghỉ tầng 2 thử chạy vào vế sập; thêm đi ngược lên 3B rồi đi/nhảy ngang trái tại z=−0,6/−2,4/−4,5. Không lượt nào xuống dưới y=−6,9 (tầng 1 ở −9,9). Xung nhảy thử 4,5 m/s (~1 m); không sửa input/gameplay. Đây là các probe xác định, không phải tuyên bố đã thử mọi quỹ đạo.

```text
pwsh tools/test.ps1 -Filter fire_stairs
RESULT: 3 passed, 0 failed

pwsh tools/test.ps1
RESULT: 583 passed, 0 failed

pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Cả ba test mới cũng PASS trong lượt full. Hai file Python qua kiểm tra cú pháp AST. `git diff --check` sạch; đã hoàn tác `default_bus_layout.tres` do Godot tự ghi lại, không đưa thay đổi ngoài phạm vi vào commit.

**Ảnh:** [chiếu nghỉ tầng 2 nhìn vào đoạn sập](../../art_source/campus/previews/fire_stairs_floor2_fixed.png), 1280×720, đã mở xem. Camera cao 1,6 m trên sàn tầng 2; khối sập bên trái, lối 3B bên phải thông. Ảnh render Godot thật, không sửa ảnh. Script tái chụp: `art_source/campus/fire_stairs_capture.gd`; [hướng dẫn/thông số đầy đủ](../../art_source/campus/fire_stairs_fix.md).

**Còn gì dở / checklist:** không còn mục checklist chưa đạt. **Chưa chơi thủ công chương 3 trong bản tích hợp, chưa export lại Windows**; đã kiểm tra tự động và xem ảnh. Không chạy bot playthrough chương 2/3.

**Yêu cầu thay đổi ngoài phạm vi:** không có yêu cầu sửa file ngoài phạm vi. Integrator merge nhánh và export lại để chủ dự án thử bản sửa; Lane E không làm trong bản tích hợp và không push main.

**Blocked:** không có. Không có câu hỏi luật chơi/cốt truyện mới.
