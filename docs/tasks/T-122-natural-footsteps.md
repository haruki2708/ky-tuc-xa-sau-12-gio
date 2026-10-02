# T-122 — Nhịp bước chân tự nhiên và dọn việc tồn từ T-101
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-122-natural-footsteps`
- Phụ thuộc: T-101 (done). Làm song song với T-123 của lane E (âm bước chân). **Integrator merge T-123 trước T-122.**

## Mục tiêu
Chủ dự án nhận xét tiếng bước chân **"kiểu robot"**. Một phần nguyên nhân nằm ở nhịp bước: hiện cứ 0,7 m phát một bước, bất kể đi hay chạy. Đi bộ 2,2 m/s ra khoảng 3 bước mỗi giây; chạy 3,6 m/s ra hơn 5 bước mỗi giây, đều tăm tắp. Người thật đi bộ khoảng 2 bước mỗi giây, chạy bước dài hơn và nhịp không đều tuyệt đối.

## Được phép sửa
`game/scenes/player/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/`

## Yêu cầu
1. **Độ dài bước theo tốc độ:**
   - Đi bộ (2,2 m/s): khoảng **1,1 m** mỗi bước, tức khoảng 2 bước mỗi giây.
   - Chạy (3,6 m/s): khoảng **1,4 m** mỗi bước, tức khoảng 2,6 bước mỗi giây.
   - Tốc độ ở giữa (đang tăng hoặc giảm tốc) thì nội suy. Các con số là `@export` để chỉnh được.
2. **Không đều tăm tắp:** mỗi bước lệch ngẫu nhiên khoảng ±6% độ dài.
3. **Đổi signal thành `footstep(surface: StringName, intensity: float)`:**
   - `intensity` = tốc độ ngang hiện tại chia cho tốc độ chạy, giới hạn trong 0–1. Đi bộ ra khoảng 0,6, chạy ra 1.
   - Lane E đổi `FootstepPlayer.play_footstep(surface, intensity = 0.5)` ở T-123, nên kết nối trong `main.tscn` vẫn chạy. Không sửa file của lane E.
4. **Head-bob khớp nhịp bước:** một chu kỳ nhún ứng với một bước chân. Khi đổi độ dài bước, nhịp nhún phải đổi theo, không lệch với tiếng bước.
5. **Dọn việc tồn từ Review T-101:**
   - `player_test.tscn`: đổi `ambient_light_source = 3` thành `2` để các hộp không bị đen.
   - Đổi tên `scripts/interaction/test_light_switch.gd` thành `demo_light_switch.gd` và cập nhật `player_test.tscn`. Nhớ đổi cả file `.uid` đi kèm.
6. **Test `game/tests/player/`:**
   - Đi bộ đều 5 giây ra khoảng 9–11 bước; chạy 5 giây ra khoảng 12–14 bước.
   - Khoảng cách giữa các bước không đều tuyệt đối, nhưng nằm trong ±6% (dùng seed cố định để test ổn định).
   - `intensity` khi đi nhỏ hơn khi chạy, và luôn nằm trong 0–1.
   - Các test bước chân cũ (không phát khi đứng yên, khi bay, khi đi vào tường; đúng `surface`) vẫn PASS.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền; ghi rõ phần nào **chưa thử bằng chuột/phím và tai thật**

## Cách kiểm tra
```
pwsh tools/test.ps1 -Filter player
```

## Handoff (agent điền)
