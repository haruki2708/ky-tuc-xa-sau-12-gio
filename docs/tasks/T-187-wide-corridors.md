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
- [x] Ảnh trước/sau
- [x] Handoff: anchor nào đã dời (tên, tọa độ cũ, tọa độ mới) để core và lane C kiểm bot

## Handoff (agent điền)

### 2026-10-06 — Lane B

**Đã làm:** commit `927d23b`, đã push lên `lane-b/T-187-wide-corridors`.
Hành lang tầng 1–4 rộng 4 m về +z; đồng bộ sàn/trần, lan can, dây phơi,
đèn, chiếu nghỉ, sảnh và vỏ 6 tầng. Giữ x=0..44, cao độ tầng, tường/cửa
phía −z, phòng 407 bản 2 và nội thất. Bàn trực/nhà vệ sinh/đồ sát tường
giữ vị trí; vùng âm thanh mở theo hành lang. CCTV Corridor nới tương ứng,
camera vẫn nhìn cửa phòng. Vườn bắt đầu z=8, không đè mép hành lang z=4.

Navmesh phủ chiều rộng mới, vẫn nối 407 → nhà ăn. Floor4 có nav riêng cho
chương 1–2; Campus tạm tắt vùng/link trùng khi gắn vào và khôi phục khi rời
cây. Cửa thoát hiểm rộng theo chiếu nghỉ để không lách qua khi đóng; API,
chốt cửa và tên node giữ nguyên. Không thay đổi luật chơi/cốt truyện.

**Ảnh:** sáu PNG, cùng camera trước/sau; bản trước là scene `8110f4b`.

| Góc nhìn | Trước | Sau |
|---|---|---|
| Tầng 4 | [Ảnh](../../art_source/wide_corridors/previews/floor4_before.png) | [Ảnh](../../art_source/wide_corridors/previews/floor4_after.png) |
| Tầng 2 | [Ảnh](../../art_source/wide_corridors/previews/floor2_before.png) | [Ảnh](../../art_source/wide_corridors/previews/floor2_after.png) |
| Mặt ngoài nhà B | [Ảnh](../../art_source/wide_corridors/previews/building_b_before.png) | [Ảnh](../../art_source/wide_corridors/previews/building_b_after.png) |

**Anchor:** 58 dời, 168 giữ nguyên, không thêm/xóa/đổi tên trong hai cây
`Floor4/Anchors` và `Campus/Anchors`. Tọa độ global, đơn vị mét.
[Bảng đủ 58 tên và tọa độ cũ/mới](../../art_source/wide_corridors/anchor_changes.md)
kèm snapshot JSON trước/sau để core và Lane C dùng kiểm bot.

| Anchor (dưới `Anchors`) | Cũ (x, y, z) | Mới (x, y, z) |
|---|---|---|
| Floor4 `seg1_start` | (32, 0.03, 1.15) | (32, 0.03, 1.6) |
| Floor4 `seg5_start` | (32, 0.03, 1.15) | (32, 0.03, 2) |
| Floor4 `DarkSection` | (16, 1.5, 1.2) | (16, 1.5, 2) |
| Floor4 `ClotheslineExtraShirt` | (25.5, 1.76, 2.27) | (25.5, 1.76, 3.87) |
| Campus `FireDoor` | (44, 0, 1.2) | (44, 0, 2) |
| Campus `MainDoor1F` | (19.25, -9.9, 2.5) | (19.25, -9.9, 4.1) |
| Campus `Paths/Nhat/P02` | (13.75, -6.6, 1.2) | (13.75, -6.6, 2) |
| Campus `Paths/Nhat/P03` | (-1.2, -6.6, 1.2) | (-1.2, -6.6, 2) |
| Campus `Paths/Nhat/P05` | (-1.2, -9.9, 1.2) | (-1.2, -9.9, 2) |
| Campus `Paths/Nhat/P06` | (2.75, -9.9, 1.2) | (2.75, -9.9, 2) |

48 anchor còn lại là Campus `ZombieSpawns/B1..B4/S01..S06` và
`ZombieIdle/B1..B4/I01..I06`: z=1.3 → 2.1; x lần lượt 8,12,16,20,24,28;
y B1=-9.9, B2=-6.6, B3=-3.3, B4=0 giữ nguyên. `Extinguisher2F`,
`Collapse2F`, `Room203Door`, `FireKey`, `HallBoard`, `Slippers407`,
`Speaker` và các anchor phía phòng không dời.

**Kiểm tra thực tế:** Godot 4.7.2, ngày 2026-10-06.

```text
pwsh tools/test.ps1 -Filter levels (trước khi thêm file test mới)
RESULT: 71 passed, 0 failed
pwsh tools/test.ps1 -Filter wide_corridors
RESULT: 4 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
pwsh tools/test.ps1
RESULT: 579 passed, 1 failed
RESULT: test FAIL (engine error or missing successful runner result)
pwsh tools/test.ps1 -Filter ch3_tools (chạy riêng xác nhận lỗi)
RESULT: 5 passed, 1 failed
RESULT: test FAIL (engine error or missing successful runner result)
```

Lượt full đã PASS cả bốn test mới, các test Lane B hiện có, nav 407 → nhà
ăn và capsule dọc đường nav. Không có `SCRIPT ERROR`/`ERROR`; runner trả
FAIL do một test QA bên dưới. Log cục bộ: `build/t187/test-full.log`,
`check.log`, `test-levels.log`, `test-wide.log`, `test-ch3-tools.log`.
Đã xem ảnh trước/sau. Chưa chơi thủ công xuyên suốt chương 1–3, chưa chạy
bot playthrough/performance. Không chạy bot chương 2.

### Yêu cầu thay đổi ngoài phạm vi

**Lane C/core:** sửa
`game/tests/tools/test_ch3_tools.gd::test_preflight_never_claims_unbound_profile_is_complete`
(dòng 33–36). Test đọc profile thật `tools/ch3-profile.json`, rồi đòi
`POLICY.preflight(profile, true, count)` luôn báo thiếu với count=0,20,40.
Phần performance của profile hiện đã có đủ binding nên cả ba assertion
`expected false` thất bại. Chạy riêng tái hiện đúng lỗi; test, profile và
`game/scripts/debug/ch3_policy.gd` đều không đổi so với `8110f4b`.

Đề nghị dùng fixture cố ý thiếu binding cho test “unbound”, và kiểm tra
profile performance hiện tại bằng expectation phù hợp. Không xóa test
hoặc bỏ binding thật để làm xanh. Lane B không sửa các file ngoài phạm vi.

**Blocked:** chưa đạt checklist “full test PASS” vì lỗi QA trên; cần Lane
C/core sửa rồi chạy lại `pwsh tools/test.ps1`. Hai checklist còn lại đạt.
Không còn phần hình học dở hoặc câu hỏi thiết kế/cốt truyện.

[Hướng dẫn dựng lại và test](../../art_source/wide_corridors/README.md).
Dùng patch hẹp `widen_existing.py`; không dựng lại toàn bộ generator tầng 4
cũ lên phòng 407 bản 2. Nhánh không sửa `docs/STATUS.md`, không push main.
