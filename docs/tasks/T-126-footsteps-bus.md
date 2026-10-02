# T-126 — Bus âm thanh riêng cho bước chân
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không file âm thanh nào thay đổi hash
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
