# T-126 — Bus âm thanh riêng cho bước chân
- Lane: E (Âm thanh) | Trạng thái: done | Agent:
- Nhánh: `lane-e/T-126-footsteps-bus`
- Phụ thuộc: T-123 (done). **Đọc `docs/SETTINGS.md`** (mục `[audio] footsteps_db`). Làm song song với T-116 của lane D.

## Mục tiêu
Chủ dự án đã chỉnh độ to bước chân nhiều lần (D-015…D-019). Menu cài đặt (T-116) sẽ có thanh trượt **Bước chân** riêng, nên bước chân cần một bus riêng.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Yêu cầu
1. Thêm bus **`Footsteps`** vào `default_bus_layout.tres`, gửi (send) vào bus `SFX`, để reverb của `ReverbZone` trên bus SFX vẫn áp dụng cho bước chân. Volume mặc định 0 dB.
2. `FootstepPlayer` dùng bus `Footsteps` thay vì `SFX`.
3. **Không đổi** file âm thanh nào. Độ to bước chân đã được chủ dự án duyệt (D-019).
4. Cập nhật `audio_source/README.md` (danh sách bus).
5. **Test `game/tests/audio/`:**
   - Có đủ 6 bus: `Master`, `Ambience`, `SFX`, `Voice`, `Music`, `Footsteps`. `Footsteps` gửi vào `SFX`.
   - `FootstepPlayer` phát trên bus `Footsteps`.
   - Sửa các test cũ đang kiểm tra "đúng 5 bus" hoặc "bước chân trên bus SFX".

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không file âm thanh nào thay đổi hash
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Phiên 2026-10-02 — Lane E / Codex

**Đã làm**
- Nhánh `lane-e/T-126-footsteps-bus`, workspace `D:\GAME_WORK\lane-e`, tạo từ `origin/main` tại `7552c07`. Commit triển khai **`4bf033a`** (`T-126: route footsteps through a dedicated bus into SFX`) đã push thành công lên nhánh task.
- Thêm bus thứ sáu `Footsteps`, mặc định **0 dB**, không mute, không effect riêng, send vào `SFX`. Routing: `FootstepPlayer → Footsteps → SFX (ReverbZone) → Master`.
- `FootstepPlayer._ready()` chọn bus `Footsteps`; giữ nguyên gain, intensity, pitch, lựa chọn bank/biến thể và WAV/OGG đã duyệt ở D-019.
- README cập nhật danh sách/routing sáu bus và trách nhiệm Lane D áp dụng `[audio] footsteps_db` theo `docs/SETTINGS.md`. Mức âm lượng/mute của SFX và Master vẫn ảnh hưởng bước chân qua bus cha.
- Sửa test cũ từ 5 thành 6 bus; kiểm tra routing Footsteps→SFX, gain 0 dB, không mute, SFX còn reverb enabled, playback đi/chạy và scene thử đều dùng Footsteps. Không thêm plugin/công cụ hoặc cài phần mềm.

**Kiểm tra đã chạy**
- `pwsh tools/test.ps1`: **`RESULT: 83 passed, 0 failed`**, exit 0. Có warning dự kiến từ test dữ liệu sai của GameState/Checkpoint; không có ERROR/script error trong lượt PASS.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0.
- SHA256 thực của từng WAV/OGG đối chiếu với `oid sha256` trong Git LFS pointer ở `origin/main`: **`AUDIO HASH RESULT: 34 files match origin/main SHA256`**. Không chạy lại pipeline hoặc chỉnh file âm thanh/import.
- `git diff --cached --check` sạch. Trước commit triển khai chỉ có bốn file đổi: `audio_source/README.md`, `game/default_bus_layout.tres`, `game/scripts/audio/footstep_player.gd`, `game/tests/audio/test_audio.gd`; card này chỉ sửa checklist/Handoff. Không sửa texture import ngoài phạm vi.
- Lượt test sandbox đầu tiên FAIL do không ghi được `user://` (checkpoint/settings/log) và không đọc certificate store. Đã chạy lại ngoài sandbox: PASS như trên; không sửa code lane khác để xử lý lỗi môi trường.

**Còn dở / cách kiểm tra**
- Checklist card đã đạt đủ. **Chưa nghe bằng tai trong phiên T-126**, chưa kiểm tra thanh trượt menu T-116 vì nhánh nền hiện chưa có triển khai đó. Test đã xác nhận playback/routing và ReverbZone; không dùng kết quả headless để khẳng định cảm nhận âm thanh.
- Chạy lại hai lệnh test/check từ gốc repo. Có thể mở `res://audio/test/zones_test.tscn`, đi/chạy qua các phòng để nghe reverb; trong Audio panel chỉnh bus Footsteps để thay riêng mức bước chân. Sau khi merge T-116, Lane D kiểm tra thanh trượt Bước chân dùng `footsteps_db`.

**Yêu cầu thay đổi ngoài phạm vi**
- Không có. Lane D tiếp tục T-116 theo hợp đồng sẵn có: áp dụng `[audio] footsteps_db` lên bus tên chính xác `Footsteps` (mặc định 0 dB, −40…+6 dB). Không cần sửa Player/scene main, thêm autoload/signal hoặc cập nhật hợp đồng cài đặt cho T-126.
- Không có câu hỏi luật chơi/cốt truyện phát sinh.

**Blocked:** Không còn chặn kỹ thuật. Lỗi mạng/quyền sandbox đã xử lý bằng chạy ngoài sandbox; commit triển khai đã push thành công. Phần UI thanh trượt thuộc T-116 và không chặn task bus này.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`.** Sau merge: `test.ps1` → `RESULT: 119 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi, gọn. Bus `Footsteps` gửi vào `SFX`, nên bước chân vẫn nhận reverb theo khu. Đã đối chiếu 34 file âm thanh với hash trên `main`: không đổi byte nào (D-019 giữ nguyên).
- Integrator thêm test core `test_footsteps_volume_setting_reaches_footsteps_bus`: `Settings.set_value("audio", "footsteps_db")` đổi đúng bus, và thanh trượt "Bước chân" hiện trong menu tạm dừng của `main.tscn`.

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
