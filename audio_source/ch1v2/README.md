# T-164 — âm nhiệm vụ chương 1 bản 2

20 âm tổng hợp gốc, CC0, code có OpenAI Codex hỗ trợ (AI-assisted), không bản thu/model/âm từ game hoặc video. Nguồn từng file ở `game/audio/CREDITS.md`. **Chưa nghe bằng tai**; số đo và test không xác nhận chất âm tự nhiên hoặc thay chủ dự án duyệt mix.

## Pipeline

`py -3 audio_source/ch1v2_process.py`, từ gốc repo. Python/FFmpeg đã có, không cài thêm gì. Raw PCM16 mono 48 kHz ở `audio_source/ch1v2/raw/`; OGG q4 ở `game/audio/ch1v2/`. Seed 16401–16420. Chỉ đọc helper cũ, không chạy lại hoặc ghi đè bank cũ. HP35/LP8500, fade one-shot, crossfade 1 s cho ba loop. Bản chết soft bỏ máu/hơi nghẹn và thêm LP700. Camera band-pass 350–4200 Hz. Gain từ loudnorm, đo lại OGG: sai số ≤1 LU, peak ≤−2 dBTP, biên loop <0.01; ngân sách raw+OGG <10 MB. Report `build_report.json` chứa seed, thời lượng, LUFS, peak, hash WAV/OGG. LUFS là asset trước gain nguồn/bus/khoảng cách, không phải loudness tổng mix.

## API và điểm cần tích hợp

### Gõ tường

Gắn `WallTaps` lên Node3D tại tường, class trong `game/scripts/audio/wall_taps.gd`.

```gdscript
# CO trong bảng mã đã duyệt: C=(1,3), O=(3,4).
wall_audio.play_sequence(wall_position, [1, 3, 3, 4], 1.0, 2.5)
```

- `groups: Array[int]` là dãy phẳng các số hàng/cột, mỗi số 1–5. Sau nhóm chỉ số chẵn dùng gap_digit, sau nhóm lẻ dùng gap_letter; `tap_interval=0.28` giữa các nhịp cùng nhóm. **Mọi gap tính từ đầu nhịp cuối tới đầu nhịp tiếp theo**. Caller tự mã hóa chữ/lặp câu, không có logic truyện hoặc giải mã tại audio. Nguồn 3D SFX, ba biến thể luân phiên, unit_size 3 m.
- Trả bool: yêu cầu hợp lệ true, sai vị trí/gap/count hoặc gọi trước ready false và không phá chuỗi đang chạy. Giới hạn 128 nhóm; gap hữu hạn và ≥tap_interval, interval≥0.05 s. Dữ liệu lịch được chụp lại, sửa Array đầu vào không đổi chuỗi.
- Signal `tap_played(group_index,tap_index)` dùng chỉ số từ 0. `sequence_finished` phát đúng một lần sau đuôi 0.5 s của nhịp cuối; chuỗi rỗng hoàn tất ngay. Thiếu clip vẫn giữ lịch/signal; không phát audio. Hủy/restart không emit finished cho chuỗi bị bỏ. Callback có thể hủy/restart an toàn.
- `play_tap(position)` cho một nhịp của người chơi; dùng **rig riêng** nếu muốn gõ đáp trong khi rig bên kia đang gõ. `stop_emitting()` hủy; checkpoint/chapter cũng hủy; pause giữ lịch. Đồng hồ process bắt kịp các nhịp đúng thứ tự nếu một frame bị trễ; không cam kết độ chính xác theo sample ở FPS quá thấp.
- `set_other_side(true)` (mặc định) LP24 ở 900 Hz, giảm thêm 4 dB; false nghe cùng bên. Dùng FloorMuffle có sẵn, bổ sung maximum_cutoff_hz/extra_loss_db với mặc định trung tính để rig cũ không đổi. Vẫn có suy hao qua tầng nếu cần; cấu hình listener/floor_base_y như T-158. Không thêm hoặc sửa bus layout toàn cục.

### Router, ổ điện, khóa, tay nắm

`Ch1MissionAudio` (Node3D) đặt tại đạo cụ; `play_cue(name)` nhận router_power_off/router_boot/router_online/power_switch/power_short/lock_alarm. Tất cả SFX, unit_size 2 m. Mỗi rig có một player cue; dùng rig riêng cho đạo cụ khác nhau. Caller quyết định công tắc nào chập, thời gian khởi động router hoặc điều kiện khóa kẹt; audio không suy luận từ ID nhiệm vụ và không tự emit noise_emitted.

`set_handle_rattling(true)` bật loop handle_rattle; gọi true nhiều lần không restart. False dừng loop rồi phát handle_stop một lần; gọi false lặp lại không phát đuôi lần nữa. Bật lại hủy đuôi đang phát. Checkpoint/chapter/shutdown dừng **không có đuôi**. `stop_emitting()` khóa rig, lượt mới dùng node mới. Thiếu stream an toàn.

### Điện thoại

Mở rộng **PhoneCallAudio hiện có**, không thêm node thay thế. phone_call_lost/restored phải cùng call_id và đang trong cuộc gọi. Mất mạng: dừng speech/chuông Kiệt, bỏ cả hàng đợi, phát lại call_disconnect của T-158 qua PhoneSFX. Tin spoken trong lúc mất bị bỏ, không replay khi nối lại; callback restored phát call_reconnect một lần. Thành viên chết trong thời gian mất vẫn được ghi trạng thái, không phát âm chết sau khi nối lại. UI/transcript thuộc T-163.

`play_remote_ring(on, member_id=&"kiet")` phát chuông Kiệt khác chuông Trung qua **PhoneSFX → SFX** đã có. Chỉ khi đang nối cuộc gọi, không restart khi true lặp. Tự dừng khi mất mạng, thành viên đó chết/rời, hết cuộc gọi, checkpoint/chapter hoặc shutdown. Core gọi đúng lúc Kiệt reo máy, không tự đoán câu thoại/mốc truyện. `mission_directory` có thể rỗng để test thiếu file.

### Cảnh chết

Mở rộng **Ch1PlayerAudio hiện có** nghe player_death_started(kind); không thêm một death-audio node thứ hai.

- fall_back: death_fall_back, máu/hơi nghẹn rồi thân đập gạch khoảng 1.6 s; bed_burst: death_bed_burst, máu/hơi và giật khung sắt, dài 3 s. Đây là timing âm khởi đầu; Lane A/core đồng bộ hoạt cảnh theo D-042.
- manager_kill: base manager_kill của T-158 trên Foley, thêm death_flesh trên DeathDetail (SFX, tại listener). Nếu Ch1PlayerAudio đã phát base từ player_caught hoặc play_action, không phát base lại; thứ tự player_caught/death_started và signal lặp đều được chặn. Chốt theo lượt sống, reset ở checkpoint_loaded/chapter_started. `none` không phát cảnh chết người chơi; âm chết qua cuộc gọi vẫn do PhoneCallAudio.
- Nếu nơi khác đã tự phát ManagerAudio.play_kill, đặt `handle_player_caught=false` để Ch1PlayerAudio bỏ base ở cả hai signal; chỉ giữ detail. Caller không được đồng thời tự phát cùng clip ở node thứ ba.
- Giảm hù dọa: fall/bed dùng death_fall_soft/death_bed_soft nhỏ và ít lớp hơn; manager dùng kill_soft của T-158, bỏ hoàn toàn flesh. Bật settings trong lúc đang phát thay ngay bản soft/dừng flesh. Không tự bật lại chi tiết khi tắt tùy chọn giữa cảnh.
- Không thay thời điểm chết/player_failed, không đổi gameplay. Tim T-158 vẫn rất khẽ, nay export `heartbeat_ramp_seconds=6` theo Insane; chỉ tăng nhịp, không tự quyết lúc hết hơi. Nếu core cấu hình thời gian nín thở khác thì đặt export cùng giá trị.

### Camera

`CctvAudio` (Node) tạo trước UI. **Lane D gọi `set_viewing(true)` chỉ khi tab Camera hiện thật**, false khi rời tab/đóng máy/mất quyền xem. `select_channel(camera_id)` phát nhiễu khi ID khác ID đã chọn, kể cả chọn đầu tiên; gọi lại cùng ID không phát lại. SFX cho cả static −54 LUFS và switch −46 LUFS. phone_raised(false), checkpoint/chapter và shutdown tự dừng. **Không** bật từ cctv_focus_requested/cctv_unlocked: đó là thông báo, không chứng minh người chơi đang xem. Không phát thêm âm giết camera vì cuộc gọi đã có.

Giống rig T-158, các node kế thừa pause; không đặt Always nếu muốn pause toàn bộ SFX. Dừng/giải phóng qua App.quit; không thêm autoload/input action/settings. Không sửa file ngoài lane E để ghép nhiệm vụ.

## Nghe thử

F6 `res://audio/test/ch1v2_audio_test.tscn`, hoặc:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/ch1v2_audio_test.tscn --windowed --resolution 960x540
```

| Phím | Âm/API |
|---|---|
| Trái/phải/Space | Chọn/nghe 20 clip riêng, tên ở console; solo không áp dụng giảm hù dọa |
| F1 / F2 | Chuỗi CO / đổi bên tường (LP hoặc dry) |
| F3 / F4 / F5 | Router tắt / khởi động / có mạng |
| F6 / F7 | Công tắc / chập |
| F8 | Bật/tắt vặn tay nắm, nghe phần kết |
| F9 | Báo khóa kẹt |
| K / L / R | Nhận cuộc gọi fixture và chuông Kiệt / mất mạng / nối lại |
| 1 / 2 / 3 / 4 | fall_back / bed_burst / manager_kill / none qua signal |
| C / N | Bật-tắt xem camera / đổi kênh |
| 0 / Esc | Reset/dừng / thoát App.quit |

Đổi giảm hù dọa trong menu game trước khi mở fixture, thử lại phím 1–3; scene không ghi settings. Chuỗi CO ở F1 chỉ thử mã đã duyệt, không phải toàn lịch thoại của Khoa. Từng phím API có thể trộn với âm đang chạy; bấm 0 trước nếu muốn tách riêng. Mũi tên tự reset mix để solo.

QA headless: thêm `--headless --max-fps 60 -- --ch1v2-audio-preview --quit-after-frames=900` vào lệnh scene. Không dùng fixed-fps tăng tốc cho phép kiểm tra audio drain. Test: `pwsh tools/test.ps1 -Filter audio`, rồi full test và check.
