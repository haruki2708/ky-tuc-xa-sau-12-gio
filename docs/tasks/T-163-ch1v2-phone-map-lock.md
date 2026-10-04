# T-163 — Chương 1 bản 2: mất kết nối, sơ đồ tòa nhà, khóa số giới hạn lần thử
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: done | Agent:
- Nhánh: `lane-d/T-163-ch1v2-phone-map-lock`
- Phụ thuộc: T-155, T-156. **Đọc kỹ `docs/design/CH1_V2_MISSIONS.md`** (D-039), đặc biệt N1, N2, N8.
- **Hạn: hết ngày 2026-10-06.**

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/tests/ui/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (core, không sửa)
`EventBus.phone_call_lost(call_id)`, `phone_call_restored(call_id)`; `PuzzleData.max_attempts`, `lockout_seconds`.

## Yêu cầu
1. **Mất kết nối** (màn hình điện thoại T-155):
   - khi `phone_call_lost`: màn cuộc gọi hiện "Mất kết nối mạng nội bộ…", danh sách thành viên mờ, biểu tượng mạng gạch chéo;
   - **các câu thoại `spoken` đến trong lúc mất kết nối không vào bản chép lời và không hiện phụ đề**;
   - khi `phone_call_restored`: trở lại bình thường, thêm một dòng hệ thống "Đã kết nối lại";
   - lưu và khôi phục trạng thái này trong `snapshot()/restore()`.
2. **Tab Sơ đồ** trên điện thoại:
   - lưới 6 tầng × 8 phòng nhà B (tầng 1 phòng 101–108 … tầng 6 phòng 601–608); phòng 407 đánh dấu "Phòng mình";
   - người chơi bấm vào một phòng để đánh dấu hoặc bỏ đánh dấu (một kiểu dấu, ví dụ chữ X đỏ); không tự hiện vị trí quản lý;
   - chuyển tab bằng phím rõ ràng, không đụng phím di chuyển hay 1–4 khi đang có lựa chọn (ví dụ Tab trái/phải trên điện thoại, hoặc lăn chuột ở thanh tab, ghi rõ trong Handoff);
   - dấu đánh lưu trong snapshot.
3. **Panel khóa số** (T-156):
   - tôn trọng `max_attempts`: sai đủ số lần thì khóa **kẹt** `lockout_seconds` giây: không nhận nhập, hiện đồng hồ đếm ngược, phát âm báo động (clip của lane E nếu có, không thì dùng âm hiện có);
   - phát `EventBus.noise_emitted(vị trí người chơi, 12.0, &"alarm")` một lần khi kẹt;
   - số lần sai lưu trong `GameState` (cờ `puzzle_attempts_<id>`) để tải lại checkpoint vẫn giữ;
   - `hint_document` rỗng thì không có nút gợi ý (đã có).
4. **Tab Camera (D-041):** đọc mục "Camera an ninh" trong `CH1_V2_MISSIONS.md`.
   - Mở khóa khi `EventBus.cctv_unlocked`.
   - Nguồn hình: các node trong group `cctv_feed`, mỗi node có `camera_id`, `label_key`, `get_texture()`. Core tạo các node này; lane D không tự dựng camera.
   - Hiển thị kiểu camera an ninh: đen trắng, nhiễu, dòng quét, chữ `CAM 102` và giờ trong game, chấm đỏ "REC". Shader riêng của lane D, độ phân giải thấp.
   - Đổi camera bằng nút trên tab (chuột, hoặc phím không đụng di chuyển).
   - `cctv_focus_requested(camera_id)`: rung và thông báo "Camera 102: có chuyển động"; nếu đang giơ máy thì tự chuyển sang camera đó.
   - Có "Giảm hù dọa": khi core phát `scare_triggered(&"cctv_kill")` thì màn hình nhiễu trắng trong khoảng 1,5 giây.
5. **Máu trên màn hình khi chết (D-042):** lớp phủ toàn màn hình (`ui/death/blood_overlay.tscn`) nghe `EventBus.player_death_started(kind)`:
   - `fall_back`, `bed_burst`: viền đỏ lan dần, vài vệt máu chảy xuống;
   - `manager_kill`: **vệt máu bắn kín** màn hình trong một khung hình, rồi chảy xuống;
   - nằm dưới màn chết (`DeathScreen`) và tự xóa khi `checkpoint_loaded`/`chapter_started`;
   - "Giảm hù dọa": chỉ viền tối, không vệt máu.
6. **Test:** mất/nối lại kết nối và câu bị bỏ lỡ; snapshot; sơ đồ đánh dấu và lưu; khóa kẹt sau 3 lần sai, đếm ngược, mở lại.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh chụp: mất kết nối, sơ đồ, camera, khóa kẹt (vi và en)
- [x] Handoff

## Handoff (agent điền)

### Đã làm (2026-10-05, Lane D)
- Base `c97874e` (`origin/main`), commit triển khai `8843256`, đã push lên `lane-d/T-163-ch1v2-phone-map-lock` trước khi cập nhật Handoff. Chỉ sửa phạm vi card và thêm 17 key vi/en; không sửa core, dữ liệu nhiệm vụ hay STATUS.
- Cuộc gọi mất mạng: lọc đúng `call_id`, dòng mất kết nối, biểu tượng mạng gạch chéo, thành viên mờ. Câu `spoken` nhận trong lúc mất mạng không vào lịch sử, không phát phụ đề; nối lại ghi đúng một dòng hệ thống, không phát lại câu đã bỏ lỡ. Hết pin xóa trạng thái cuộc gọi.
- Sơ đồ đủ 48 phòng 101–608, đánh dấu X đỏ bằng tay, chú thích 407 là phòng mình. Không đọc vị trí quản lý. Snapshot JSON vẫn version 1, tương thích bản cũ; thêm mất mạng, dấu phòng, tab, trạng thái mở khóa camera và camera đang chọn.
- Camera lấy texture trực tiếp từ group `cctv_feed`, không tạo camera gameplay. Shader đen trắng, nhiễu, dòng quét, lấy mẫu 320×180; nhãn camera, giờ và chấm đỏ REC. Focus làm điện thoại rung nhẹ và hiện thông báo trên điện thoại 5 giây; chỉ tự đổi tab/camera khi đang giơ máy, không tự giơ máy. Khi bật Giảm hù dọa, không rung và `cctv_kill` che hoàn toàn hình bằng nhiễu trắng 1,5 giây.
- Khóa `max_attempts > 0` có nút **Thử mở**: chỉ tính mã đã xác nhận, không tính các nấc xoay trung gian. Đủ lần sai thì vô hiệu hóa vòng số/nút thử, đếm ngược và phát âm fallback hiện có; phát noise một lần tại `player_path` (mặc định `../Player`), bán kính 12 m, source `alarm`. Khóa không giới hạn giữ hành vi tự kiểm tra cũ.
- Lưu số lần sai ở `puzzle_attempts_<id>` và giây kẹt còn lại ở `puzzle_lockout_<id>` trong GameState; đóng/mở panel không xóa. Đếm khi panel đang mở hoặc gameplay đang chạy; menu khác tạm dừng đồng hồ. Hết thời gian thì nhận mã lại và reset số lần sai về 0. Khôi phục checkpoint không phát lại âm/noise. Đây là trạng thái tại thời điểm checkpoint được lưu, không ghi đè checkpoint cũ sau mỗi lần thử.
- `ui/death/blood_overlay.tscn` layer 29, dưới DeathScreen 30: viền đỏ lan/vệt chảy cho fall_back, bed_burst; manager_kill phủ máu ngay khung hình đầu rồi chảy. Giảm hù dọa chỉ viền tối. Không pause/giữ input; tự xóa khi checkpoint/chương bắt đầu; `none` không phủ máu.
- Thêm 5 test hồi quy về mất/nối mạng, câu bị bỏ lỡ, snapshot cũ/mới, điều khiển và dấu phòng, camera/accessibility, khóa 3 lần/60 giây/noise/khôi phục/mở lại, lifecycle hiệu ứng chết.

### Điều khiển và kiểm tra
- Giơ điện thoại bằng Q như cũ. `[` / `]` đổi tab (bỏ qua Camera khi chưa mở khóa); có nút chuột trên thanh tab. Không đổi mouse mode hay pause gameplay.
- Tab Sơ đồ: mũi tên chọn phòng, Enter đánh dấu/bỏ dấu; có thể bấm trực tiếp ô phòng khi con trỏ đang hiển thị. Tab Camera: `,` / `.` hoặc hai nút mũi tên để đổi camera. WASD, Q/F, Tab sổ và lựa chọn 1–4 giữ nguyên.
- Chạy `pwsh tools/test.ps1`: **`RESULT: 360 passed, 0 failed`**, exit 0. Chạy `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0. Log tại `build/T-163/test.log`, `build/T-163/check.log` (ignored). Có warning UID texture của model kit có sẵn; không có engine error.
- Đã chụp và xem ảnh 1920×1080 tại `game/ui/phone_missions_previews/`: `lost_vi/en`, `map_vi/en`, `camera_vi/en`, `lock_vi/en`; thêm `blood_vi`, `blood_reduced_vi`, `static_vi`. PNG qua LFS, kèm `.import`, nguồn trong CREDITS.md. Đã thu gọn nút để sơ đồ không lấn dải phụ đề.
- Scene thử riêng: `res://ui/phone_missions_preview.tscn`, đối số `-- --missions-ui=map_vi` (các mode khác theo tên ảnh), chụp frame 4 với `--fixed-fps 30 --quit-after-frames=8`. Dùng APPDATA riêng trên D: vì mode accessibility đổi setting của môi trường thử.
- Ảnh camera dùng **fixture** ảnh hành lang của dự án để kiểm tra hợp đồng texture/shader; không phải ảnh camera gameplay thật. Chưa chơi trọn chương 1 v2 sau ghép, chưa chạy bot v2/export/package, chưa nghe đánh giá chất lượng âm báo động.

### Yêu cầu thay đổi ngoài phạm vi
1. **Core T-160:** cập nhật `game/data/puzzles/locker_combo_dat.tres` theo N1: `solution = "2109"`, `max_attempts = 3`, `lockout_seconds = 60.0`, `hint_document = &""`. Base hiện vẫn 1407/có hint/không giới hạn, nên panel gameplay chỉ bật giới hạn sau thay đổi dữ liệu này. Không tăng số lần sai thêm tại station để tránh đếm hai lần.
2. **Core T-160:** ghép `res://ui/death/blood_overlay.tscn` vào `game/scenes/main/chapter1.tscn`; phát `player_death_started(kind)` trước `player_failed(reason)` như D-042. Giữ PuzzlePanel cạnh Player hoặc đặt `player_path` đúng để noise có vị trí thực.
3. **Core T-160 + B T-165:** ghép node `cctv_feed` có `camera_id`, `label_key`, `get_texture()`, phát unlock/focus/scare đúng beat; phát lost/restored với ID cuộc gọi hiện tại. UI và các signal đã sẵn sàng; không thêm dựng cảnh/camera trong lane D.
4. **Lane E T-164:** khi clip khóa báo động có sẵn, gán `PuzzlePanel.alarm_sound` thay fallback `door_latch.ogg`; bảo đảm phần voice cũng bỏ câu nói trong khoảng mất mạng (UI chỉ sở hữu lịch sử/phụ đề).
5. **Core export:** loại `ui/phone_missions_previews/*`, `ui/phone_missions_preview*`, `scripts/ui/phone_missions_preview.gd*` khỏi bản phát hành. **Lane C:** bot khóa giới hạn cần bấm `Root/Card/Content/Submit` sau khi đặt các vòng số.

### Còn dở / chặn
- Không còn mục checklist chưa đạt trong phạm vi Lane D. Không bị chặn triển khai; các bước ghép cảnh/dữ liệu/âm thanh/bot nêu trên thuộc lane khác.
- Không thêm luật chơi hay lời thoại cốt truyện; dùng dữ liệu đã chốt trong đặc tả và fixture kỹ thuật tách riêng. Chưa có câu hỏi thiết kế mới.

### Review (integrator, 2026-10-05)
- **Đạt, đã merge.** Đúng phạm vi; 5 test mới; ảnh preview đủ vi/en; lọc đúng `call_id` (`stranger_call`); giảm hù dọa được tôn trọng.
- **Ghép:**
  - `blood_overlay.tscn` thêm lúc chạy trong `chapter1_main.gd`;
  - `PuzzlePanel.alarm_sound` dùng `audio/ch1v2/lock_alarm.ogg` của E;
  - dữ liệu `locker_combo_dat` đã là 2109, tối đa 3 lần, kẹt 60 giây, không gợi ý (core làm từ trước);
  - loại ảnh và scene preview khỏi export.
- **Integrator thêm vào `phone_tools.gd`:** thuộc tính chỉ-đọc `current_tab` để bot xác nhận tab Sơ đồ/Camera.
- Test `test_puzzle_variable_dials_wrong_then_correct...` đổi theo khóa giới hạn: chỉ kiểm tra khi bấm "Thử mở". Bot bấm `Submit` sau khi xoay số.
- Toàn bộ test 405/405.

