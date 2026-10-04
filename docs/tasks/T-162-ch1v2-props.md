# T-162 — Chương 1 bản 2: đạo cụ và trạng thái phòng 407
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-162-ch1v2-props`
- Phụ thuộc: T-153, T-154. **Đọc kỹ `docs/design/CH1_V2_MISSIONS.md`** (D-039).
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Mô hình, anchor và trạng thái trong phòng 407 cho 8 nhiệm vụ mới. Phong cách PS1 như T-153/T-154; giấy phép CC0, CC-BY hoặc tự làm; ghi `CREDITS.md`.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
1. **Ổ điện kéo dài** dưới giường Phúc (anchor `Anchors/PowerStrip`):
   - 3 công tắc có đèn; chữ số 1, 2, 3 đã mờ; **công tắc 2 có vệt sơn đỏ**;
   - API `set_switch(i, on)`, `set_tripped(bool)` (tắt hết đèn công tắc), `spark()` (tóe lửa ngắn);
   - mỗi công tắc có node con `Switch1..3` để lane A gắn vùng tương tác.
2. **Phích cắm cục phát** quấn **băng keo đỏ**, dây chạy từ cục phát xuống ổ điện.
3. **Hai dây mạng** dưới gầm bàn: **xanh dương** (từ cục phát) và **xám** (từ laptop của Việt).
   - Mỗi dây có đầu tuột nằm trên sàn (anchor `Anchors/LanBlueEnd`, `LanGrayEnd`).
   - **Ổ mạng trên tường** (`Anchors/LanWallPort`).
   - API `set_plugged(cable_id, plugged)`: đầu dây vào ổ hoặc nằm lại trên sàn.
4. **Cục phát:** đèn nguồn và đèn mạng riêng. API `set_power(bool)`, `set_network(state)` với state là `&"off"`, `&"booting"` (nhấp nháy), `&"red"`, `&"ok"`.
5. **Tủ Việt mở được:** `Anchors/VietLocker` có `set_open(bool)`; mảnh giấy 1 nằm trong.
6. **Nệm Phúc lật được:** `Anchors/PhucMattress` có `set_lifted(bool)`; dưới nệm có mảnh giấy 2 đẫm máu (không chi tiết giải phẫu).
7. **Sọt rác** cạnh bàn (`Anchors/TrashBin`), mảnh giấy 3 vo nằm trong.
8. **Mô hình giấy xé:** 3 mảnh (dùng chung một scene, tham số mảnh 1/2/3).
9. **Ảnh đội bóng khoa** (Đạt khoác vai Phúc), đặt trên kệ của Đạt (`Anchors/TeamPhoto`). **Sổ hợp âm guitar** của Việt cạnh cây đàn (`Anchors/GuitarSongbook`). **Thẻ sinh viên của Phúc** kẹp trong sách giáo trình của Phúc (`Anchors/PhucCard`).
10. **Tay nắm cửa 407 rung:** `Door407.rattle(seconds)`: tay nắm xoay qua lại, cánh cửa rung nhẹ trong khung (không mở). Có `stop_rattle()`.
11. **Đèn bàn của Trung:** API `set_desk_lamp(on)` trên `Room407` (tắt hẳn ánh sáng và vùng sáng). Anchor `Anchors/DeskLampSwitch` cho lane A.
12. **Anchor hai bức tường gõ** (`WallKnock406`, `WallKnock408` đã có): kiểm tra vị trí dễ bấm từ giường.
13. **Test và preview:** đủ anchor; các API trạng thái chạy đúng; ảnh preview từng món và cảnh dưới gầm bàn có ổ điện, dây mạng.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `CREDITS.md` đủ nguồn; ảnh preview
- [ ] Handoff: anchor, API

## Handoff (agent điền)
