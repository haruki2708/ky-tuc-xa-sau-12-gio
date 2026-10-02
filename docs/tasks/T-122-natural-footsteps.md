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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền; ghi rõ phần nào **chưa thử bằng chuột/phím và tai thật**

## Cách kiểm tra
```
pwsh tools/test.ps1 -Filter player
```

## Handoff (agent điền)

### Phiên 2026-10-02 — Lane A
- Đã thêm `walk_step_length = 1.1`, `sprint_step_length = 1.4` và `step_length_variation = 0.06` dạng export. Độ dài bước nội suy theo tốc độ ngang thực tế trong khoảng 2,2–3,6 m/s; dưới tốc độ đi bộ dùng độ dài đi bộ, trên tốc độ chạy dùng độ dài chạy. Mỗi bước lấy một hệ số ngẫu nhiên mới trong khoảng 0,94–1,06 bằng RNG riêng.
- Signal mới: `footstep(surface: StringName, intensity: float)`, intensity là tốc độ ngang / 3,6, clamp 0–1. Giữ cách đọc metadata `surface` và giá trị mặc định `concrete`.
- Âm bước chân và head-bob dùng chung tiến độ bước 0–1. Khi đổi tốc độ, giữ phần bước đã đi; khoảng dịch chuyển còn dư được chuyển sang bước tiếp theo. Một chu kỳ bob ứng với một signal, kể cả khi có jitter hoặc thay đổi tốc độ. Bob tắt được như trước; chỉ quãng đường di chuyển ngang trên mặt đất mới tích lũy bước.
- Đã sửa `player_test.tscn` sang `ambient_light_source = 2`; đổi `test_light_switch.gd` thành `demo_light_switch.gd`, giữ nguyên UID và cập nhật đường dẫn scene.
- Thêm 5 test, cập nhật test cũ cho signal hai tham số và độ dài bước mới: nhịp đi/chạy đều 5 giây, jitter, nội suy/giá trị export/intensity, bob đồng bộ qua thay đổi tốc độ. RNG test dùng seed 122. Kiểm tra khoảng cách jitter dùng dịch chuyển mẫu 1 mm, cho phép sai số đo 2 mm tại thời điểm phát signal; kiểm tra nhịp 5 giây dùng physics thật. Các test đứng yên, bay, tường chắn và surface vẫn PASS.
- T-123 đã được integrator merge trong lúc làm task. Đã cập nhật nhánh lên `origin/main` tại `7989978` trước khi chạy test toàn dự án; không sửa code/asset Lane E hay scene main. Kết nối signal hiện có tương thích hai tham số.
- Commit code: `a211ff9` — `T-122: Add speed-based jittered footsteps synchronized with head bob`; đã push lên `origin/lane-a/T-122-natural-footsteps` trước khi điền Handoff.

### Kết quả kiểm tra
- `pwsh tools/test.ps1 -Filter player`: **`RESULT: 19 passed, 0 failed`**, exit code 0.
- `pwsh tools/test.ps1` sau khi cập nhật T-123: **`RESULT: 70 passed, 0 failed`**, exit code 0. Bao gồm test kết nối bước chân/âm môi trường trong main và load tất cả scene.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit code 0.
- `git diff --cached --check`: sạch trước commit code; thay đổi của task chỉ thuộc các thư mục cho phép và checklist/Handoff card này.
- Lượt test player đầu trong sandbox có 19 test đạt nhưng script trả FAIL vì Godot bị chặn ghi log `user://` và đọc kho chứng chỉ Windows. Đã chạy lại ngoài sandbox qua cơ chế cấp quyền để có các kết quả PASS sạch phía trên.
- **Chưa thử bằng chuột/phím và tai thật**: chưa mở editor/F6 để tự đi/chạy, nghe độ tự nhiên/to nhỏ của bước chân, đánh giá cảm giác head-bob hay nhìn trực tiếp ánh sáng hộp. Không coi test headless là kiểm duyệt cảm nhận. Không còn code đang làm dở.
- Cách kiểm tra thủ công tiếp: mở `game/project.godot`, chạy scene main, WASD đi và Shift chạy để nghe nhịp mới cùng bank âm T-123; đổi `head_bob_enabled` và các export độ dài bước trên Player để so sánh. Mở `player_test.tscn`, F6 để xem hộp dưới ánh sáng ambient và thử tương tác E/chuột trái.

### Yêu cầu thay đổi / chặn
- Không có yêu cầu sửa ngoài phạm vi; dependency T-123 đã có trên main. Không còn blocker triển khai/test/push; phần cảm nhận thủ công cần chủ dự án/integrator kiểm tra tiếp.
- Git LFS ban đầu lỗi mạng sandbox làm checkout dở. Đã lưu bản dở vào stash `Recovery: partial T-122 checkout after sandbox LFS failure`, sau đó checkout lại thành công với quyền truy cập mạng. Stash dự phòng này còn giữ cục bộ, không thuộc commit task; không cần áp dụng lại. Không cài phần mềm, không thêm plugin, không làm việc trong bản tích hợp.
