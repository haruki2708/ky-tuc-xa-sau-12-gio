# T-187 — Hành lang nhà B rộng khoảng 4 m ở cả 4 tầng
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-187-wide-corridors`
- Phụ thuộc: T-112 (tầng 4), T-162, T-183. **Đọc D-058 trong `docs/DECISIONS.md`.**
- **Hạn đề xuất: hết ngày 2026-10-07.**

## Mục tiêu
Chủ dự án chơi thử chương 3 thấy hành lang quá hẹp (2,4 m): đông xác thì không có chỗ né. Quyết định D-058: **mọi hành lang của nhà B (tầng 1, 2, 3, 4) rộng khoảng 4 m**, kể cả tầng 4 mà chương 1–2 dùng.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Yêu cầu
1. **Mở ra phía lan can (+z)**:
   - sàn hành lang từ z = 0 tới **z = 4,0** (thay vì 2,4); trần, lan can, dây phơi, đèn trần dời theo;
   - **mọi thứ ở phía −z giữ nguyên**: tường phòng, cửa phòng (407, 203…), phòng 407 bản 2 và đồ trong phòng;
   - giữ nguyên trục x (0 tới 44) và cao độ các tầng (tầng 4 ở y = 0, mỗi tầng 3,3 m).
2. **Tầng 4** (`scenes/levels/floor4/`):
   - hành lang, hai đầu hồi, bàn trực, nhà vệ sinh chung;
   - các anchor của chương 1–2 nằm trong hành lang (`seg*_start`, `HallBoard`, `DarkSection`, `Slippers407`, `Speaker`, `ClotheslineExtraShirt`…): đặt lại hợp lý, **không đổi tên**;
   - lối vào hai cầu thang mà T-183 đã mở.
3. **Tầng 1–3 và vỏ nhà B** (`scenes/levels/campus/building_b.tscn`, `art_source/campus/`):
   - hành lang, chiếu nghỉ hai cầu thang, sảnh tầng 1;
   - mặt ngoài 6 tầng và mái theo bề sâu mới;
   - anchor trong hành lang (`ZombieSpawns/B1…B4`, `ZombieIdle/*`, `Extinguisher2F`, `FireDoor`, `Collapse2F`, `Paths/Nhat` đoạn trong nhà…) đặt lại cho hợp, **không đổi tên**;
   - **navmesh** phủ hành lang mới, nối thông 407 → nhà ăn như trước.
4. **Camera an ninh chương 1** (`scenes/levels/cctv/cctv_set.tscn`, mục `Corridor`): nếu đây là hình tầng 4 thì nới theo cho khớp.
5. **Vườn hoa:** kiểm tra mép vườn sát nhà B không đè lên hành lang mới; dời cây hoặc bồn hoa nếu cần.
6. **Không làm hỏng chương 1–2:**
   - phòng 407 và cửa 407 đúng chỗ cũ;
   - quản lý chương 1 đi được dọc hành lang (navmesh tầng 4);
   - CCTV vẫn chạy;
   - test cũ của lane B (`test_floor4`, `test_ch1v2`, `test_ch2_props`, `test_campus`) sửa theo số đo mới, không xóa test.
7. **Test mới:**
   - đo sàn hành lang mỗi tầng rộng khoảng 4 m (3,8–4,2 m);
   - capsule người chơi đi thẳng dọc hành lang cách tường phòng 3 m không vướng;
   - navmesh vẫn nối 407 tới nhà ăn.
8. **Ảnh:** hành lang tầng 4 và tầng 2 trước/sau, mặt ngoài nhà B.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh trước/sau
- [ ] Handoff: anchor nào đã dời (tên, tọa độ cũ, tọa độ mới) để core và lane C kiểm bot

## Handoff (agent điền)
