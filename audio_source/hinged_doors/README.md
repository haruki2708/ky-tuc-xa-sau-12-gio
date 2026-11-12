# T-244 — Tiếng cửa gỗ và nhôm kính, bản chờ nghe

**Chưa nghe bằng tai, chờ chủ dự án nghe.** Phương án nhỏ, an toàn cho phiên chạy ngầm D-164; chất âm và mức nghe thực tế **chờ chủ dự án chọn/nghe**.

Tạo lại từ gốc repo: `py -3 audio_source/hinged_doors/process_doors.py`.
Python stdlib tổng hợp theo seed 24400–24403, không sample ngoài. Dùng helper đọc/ghi, đo loudnorm và import của `audio_source/process.py`, không chạy hay đổi bank cũ. FFmpeg có sẵn ở `D:/Tools/ffmpeg`, phiên bản thực trong `build_report.json`. WAV mono PCM16 48 kHz nằm trong `raw/`; OGG Vorbis quality 4 mono 48 kHz nằm trong `game/audio/hinged_doors/`, không loop. Gain tuyến tính hiệu chỉnh từ PCM theo số đo OGG; không encode nối nhiều lượt. Báo cáo chứa hash WAV/OGG, dung lượng, thời lượng giải mã, LUFS và true peak. Mỗi file nhỏ hơn 10 MB và được Git LFS quản lý.

| File OGG | LUFS | True peak dBTP | Ý định tổng hợp |
|---|---:|---:|---|
| `wood_open` | −36,05 | −24,54 | Ma sát trầm, bản lề gỗ kẽo kẹt nhẹ, 0,5 giây |
| `wood_close` | −42,12 | −20,73 | Chạm khung gỗ ngắn và chốt sau 0,12 giây |
| `aluminium_glass_open` | −36,25 | −22,92 | Ma sát khô, ít âm bản lề hơn gỗ, 0,5 giây |
| `aluminium_glass_close` | −42,13 | −21,75 | Khung nhôm chạm, vài cộng hưởng kính nhỏ tắt nhanh |

Nguồn 3D dùng bus SFX, gain −6 dB, trần gain khoảng cách −6 dB, bán kính tối đa 8 m, một tiếng tại một thời điểm. Tiếng đóng có transient nên chọn mục tiêu thấp hơn tiếng mở 6 LU để đỉnh không vượt −20 dBTP ở file. Số đo không khẳng định âm nghe giống vật liệu thật hay chủ dự án thích.

## Gắn vào game

`HingedDoorAudio.attach_all(room)` gọi sau `Protagonist.attach`, **chỉ chương 1**. Lặp lại không tạo nguồn trùng. Tìm hai cửa theo card, không tự tạo HingedDoor; nguồn nằm ở grip đầu tiên trên tay nắm và đi theo cánh. Không đổi gameplay hay phát `EventBus` noise. Mở có thời lượng dương phát ngay; đóng đợi `settled(false)`; mở tới chỗ dừng âm còn lại. Không kéo dài/pitch tiếng mở theo thời gian quay: clip ma sát ngắn bắt đầu khi cánh bắt đầu chuyển động. Đảo chiều dừng tiếng cũ, hủy chốt đang chờ. `seconds = 0` hoàn toàn im lặng, kể cả khi ngắt một lượt mở/đóng đang chạy. Pause theo cây scene.

**Lưu ý main hiện tại đã có T-243:** chương 2 cũng có thân và HingedDoor ban công; khác dòng hiện trạng cũ trong card T-244. `chapter1_main.gd` dùng chung các chương, nên integrator phải giới hạn lời gọi bằng `has_node("Chapter1Director")`, không chỉ `protagonist_body`. Lane E không sửa file đó.

## Nghe thử

Mở `res://audio/test/hinged_door_audio_test.tscn` bằng F6 (lấy lượt Godot trước), hoặc:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/hinged_door_audio_test.tscn --windowed --resolution 1280x720
```

Cảnh riêng dùng phòng 407 thật, camera cố định ở ba chỗ đứng, tắt các nguồn âm có sẵn trong fixture để nghe riêng cửa. Không chạy director, bot, thay setting hay lưu game. Không có chữ giao diện mới.

| Phím | Thao tác |
|---|---|
| `1` / `2` | Mở / đóng cửa nhà tắm gỗ |
| `3` / `4` | Mở / đóng cửa ban công nhôm kính |
| `5` | Mở ban công với yêu cầu 0,5 giây như quản lý (HingedDoor vẫn giới hạn tốc độ) |
| `C` / `B` / `V` | Đứng trong phòng / nhà tắm / ngoài ban công |
| `R` | Đặt tức thời: nhà tắm đóng, ban công mở; phải im lặng |
| `Space` | Dừng mọi tiếng, kết thúc lượt quay tức thời |
| `Esc` | Thoát |

Nghe từng cặp đóng/mở từ cả ba chỗ, thử đảo chiều nhanh và R trong lúc quay. Chủ dự án chọn mức có đủ nghe nhẹ ở gần không, hai vật liệu có phân biệt được không, tiếng nhôm/kính có quá sắc không. Headless chỉ kiểm stream/playback, tín hiệu và vị trí, không xác nhận loa hoặc chất lượng cảm nhận. Cảnh nghe riêng không mô phỏng cách âm qua tường; integrator ghép xong cần nghe trong mix chương 1.

Kiểm tự động: `pwsh tools/test.ps1 -Filter test_hinged_door_audio` theo lượt Godot. Test dựng chương 1 `auto_start=false`, kiểm từng cửa mở/đóng, vị trí đi theo tay nắm, attach lặp, đặt tức thời và ngắt/đảo chiều; kiểm phím cảnh nghe và ba vị trí listener.
