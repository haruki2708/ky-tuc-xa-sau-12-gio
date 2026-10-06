# T-192 — Chương 3: khán đài sân vận động làm lại, rải đồ cho khuôn viên bớt trống
- Lane: B | Trạng thái: todo (làm **sau T-190**) | Agent:
- Nhánh: `lane-b/T-192-stands-props`
- Phụ thuộc: T-183, T-189, T-190. **Đọc D-054, D-064, D-065 trong `docs/DECISIONS.md`**, card T-183 (Handoff), `art_source/campus/README.md`.

## Vì sao (chủ dự án chơi thử chương 3, 2026-10-07)
1. "Sân vận động hình như **không có khán đài**, và một khán đài chỗ ngồi nho nhỏ **bị lỗi nằm bên ngoài** sân vận động."
   Integrator đo: khán đài chính (`MainBleachers`, x 158–238, z 216–228) chỉ cao 3 m và nằm **sau hàng rào** z = 212, cách đường chạy 4 m: trong sương gần như không thấy. Khán đài phụ (`SecondaryBleachers`, x 168–228, z 108–113, 4 bậc) nằm **ngoài hàng rào phía nam** z = 120, cách sân 7 m.
2. "Map hơi rộng nên **nhiều chỗ trống trải** quá." Chủ dự án chọn **giữ kích thước** (D-054), **rải thêm đồ** (D-064). Ảnh đường từ vườn hoa ra sân vận động hiện chỉ có cây và cột đèn.

## Được phép sửa
`art_source/campus/`, `game/assets/models/` (mô hình mới, ghi CREDITS), `game/scenes/levels/campus/`, `game/tests/levels/`, card này (Handoff). Không sửa code core, lane A, lane E.

**Cảnh báo dựng map:** giữ các thay đổi đã có trên `main`: T-187 (hành lang 4 m), T-188 (khối sập), T-189 (nhà ăn, `canteen_cn.py`), T-190 (cửa phòng), D-062 (bình cứu hỏa tầng 2 ở x = 39,5), D-065 (màu trời đêm). Chạy bộ dựng xong thì xem `git diff` và chỉ giữ phần của card này.

## Yêu cầu
### 1. Khán đài
- **Khán đài chính (bắc):** sát đường chạy (mép trước khoảng z = 212,5), dài khoảng 80 m, **khoảng 16–20 bậc** (cao 6–8 m), có **mái che trên cột** và lan can; nhìn rõ từ giữa sân trong sương. Người chơi lên được từ đường chạy bằng 2–3 lối cầu thang; bậc có navigation cho xác và đồng đội (xác leo chậm do lane A tự xử lý theo độ dốc).
- **Khán đài phụ (nam):** đặt sát đường chạy phía nam (mép z khoảng 119,5), thấp hơn (6–8 bậc), có lối lên. **Bỏ khán đài nhỏ cũ ở z 108.**
- Hàng rào: thành tường thấp trước khán đài, có khe ở các lối lên.
- **Giữ 4 lối xác tràn vào** (D-053 N7). Cổng bắc và nam đang ở giữa (x 193–203) sẽ bị khán đài che: dời ra hai đầu khán đài hoặc làm đường hầm dưới khán đài, rồi dời `Anchors/ZombieSpawns/Stadium` tương ứng. Giữ tên anchor.
- **Giữ ý nghĩa anchor:** `Clues/SirenSpot` ở chỗ cao nhất khán đài chính (tiếng còi chỉ nghe khi đứng yên ở đó); `BarSpawns/B03` và ống sắt (`LoosePipe*`) ở **gầm khán đài chính**, nhặt được (core có test tia ngắm); `Start_stadium` giữ nguyên.

### 2. Rải đồ (giữ kích thước map)
Dọc mọi đường người chơi đi (nhà B → vườn hoa → đường x = 80 ra sân vận động → đường z = −15 ra cổng → sân cổng → nhà ăn) và quanh các khu:
- xe máy, xe đạp đổ; vài ô tô (một chiếc bật đèn khẩn cấp không cần); nhà để xe có mái; ki-ốt hoặc quầy nước đóng cửa; ghế đá, bồn cây, thùng rác, biển chỉ đường, bảng tin;
- đồ của người chạy loạn: ba lô, giày, dép, điện thoại vỡ, giấy tờ, khay cơm; vài **xác nằm** (chỉ là mô hình tĩnh, không phải xác sống);
- **dấu động đất** (D-053, manh mối không ai nói ra): đường nứt, cây đổ, cột đèn nghiêng hoặc đổ, kính vỡ, gạch vụn dưới chân các tòa nhà;
- hàng cây dày hơn ở hai bên đường; một vài cụm đèn đường còn sáng để có chỗ sáng chỗ tối.
- **Mật độ:** đứng ở bất kỳ điểm nào trên đường đi, trong tầm 30 m luôn thấy vài thứ đáng nhìn. Không chặn đường: mỗi tuyến giữ lối trống ít nhất 4 m; đồ lớn đăng ký `obstacle()` để navigation tránh.
- **Hiệu năng:** đồ lặp dùng `MultiMeshInstance3D`; giữ ngân sách tam giác như T-183; không thêm đèn có bóng đổ.

### 3. Test và ảnh
- Người chơi đi bộ (như test T-188): từ đường chạy lên tới bậc cao nhất khán đài chính; tới được `BarSpawns/B03`.
- Navigation: có đường từ `Start_garden` → `Start_stadium` → `Start_gate` → cửa nhà ăn; xác trong sân tới được bậc khán đài.
- `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS; ảnh: sân nhìn từ cổng tây, khán đài chính từ giữa sân, hai đoạn đường.
- FPS: integrator đo lại sau khi merge (cần chủ dự án cho phép).

## Checklist hoàn thành
- [ ] Khán đài chính to, sát đường chạy, có mái, lên được; khán đài phụ phía nam sát sân; bỏ khán đài nhỏ cũ
- [ ] 4 lối xác vào, `ZombieSpawns/Stadium` cập nhật; `SirenSpot`, `B03`, ống sắt đúng chỗ
- [ ] Rải đồ dọc mọi tuyến, dấu động đất, không chặn đường
- [ ] Test đi bộ, test navigation PASS; test.ps1, check.ps1 PASS; ảnh
- [ ] Handoff: tọa độ mới của khán đài, cổng, anchor đã dời; số tam giác

## Handoff (agent điền)

## Review (integrator)
