# T-164 — Chương 1 bản 2: âm thanh nhiệm vụ mới
- Lane: E (Âm thanh) | Trạng thái: done | Agent:
- Nhánh: `lane-e/T-164-ch1v2-audio`
- Phụ thuộc: T-158. **Đọc `docs/design/CH1_V2_MISSIONS.md`** (D-039). Chủ dự án thích âm **nhỏ**; ghi LUFS.
- **Hạn: hết ngày 2026-10-06.**

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`

## Yêu cầu
1. **Gõ tường** (`wall_tap`): tiếng gõ khớp ngón tay lên tường vôi dày, 2–3 biến thể. API cho integrator phát một chuỗi gõ ở một vị trí 3D, ví dụ `WallTaps.play_sequence(position, groups: Array[int], gap_digit, gap_letter)`, với `groups` là số lần gõ của từng con số, kèm signal `sequence_finished`. Phía bên kia tường thì lọc trầm hơn.
2. **Cục phát wifi:** tiếng tắt nguồn; tiếng bíp khởi động; tiếng bíp báo có mạng.
3. **Ổ điện:** tiếng bật công tắc; **tiếng chập và tóe lửa** khi bật công tắc 3.
4. **Tay nắm cửa bị vặn mạnh:** vòng lặp tay nắm kim loại lạch cạch, bản lề rung; có phần kết thúc khi dừng.
5. **Khóa số kẹt:** chuông báo động ngắn, chói, nhưng vẫn trong mức đã duyệt (tham chiếu −30 LUFS).
6. **Chuông điện thoại của Kiệt nghe qua cuộc gọi** (một đoạn chuông khác chuông của Trung).
7. **Mất kết nối:** dùng lại `call_disconnect` của T-158; thêm tiếng nối lại.
8. **Cảnh chết (D-042):** nghe `EventBus.player_death_started(kind)`.
   - `fall_back`: máu phụt, thở hắt nghẹn, thân người đập xuống sàn gạch.
   - `bed_burst`: máu trào, co giật trên giường sắt.
   - `manager_kill`: dùng `manager_kill` của T-158 (đừng phát trùng nếu `Ch1PlayerAudio` đã phát), thêm tiếng thịt bị chém sát tai.
   - "Giảm hù dọa": nhẹ và ít chi tiết hơn.
9. **Camera an ninh:** tiếng rè nền rất khẽ khi xem tab Camera; tiếng nhiễu chuyển kênh. Cảnh giết trên camera nghe qua cuộc gọi (đã có), không cần thêm âm cho từng cảnh.
10. Ghi `CREDITS.md`, LUFS từng âm; cảnh thử nghe từng âm.
11. **Test:** đủ file, đúng bus, API chuỗi gõ đúng số nhịp và thứ tự.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Handoff: danh sách âm, LUFS, API

## Handoff (agent điền)

### 2026-10-05 — Lane E

**Đã làm:** commit `f8276fe` trên `lane-e/T-164-ch1v2-audio`, từ `origin/main` `c97874e`; đã push code và đủ 40 đối tượng LFS trước khi ghi Handoff. Thêm 20 âm CC0 tổng hợp gốc (code có OpenAI Codex hỗ trợ), raw WAV mono 48 kHz và OGG q4, pipeline tái tạo, report/hash/LUFS/peak, credits và scene nghe riêng từng âm. Tổng raw+OGG **4.161.408 byte**; đối chiếu đủ 40 SHA-256 PASS. Không sửa các WAV/OGG đã có, không thêm plugin/công cụ hoặc đổi bus layout. Các thay đổi runtime/test chỉ trong thư mục được phép.

**Âm mới và LUFS đo trên OGG** (trước gain nguồn/bus/khoảng cách):

| Tên file trong `game/audio/ch1v2/` (đuôi `.ogg`) | LUFS |
|---|---:|
| wall_tap_01 | -41.95 |
| wall_tap_02 | -42.05 |
| wall_tap_03 | -41.95 |
| router_power_off | -41.99 |
| router_boot | -39.96 |
| router_online | -40.05 |
| power_switch | -42.05 |
| power_short | -32.19 |
| handle_rattle | -40.01 |
| handle_stop | -42.10 |
| lock_alarm | -30.28 |
| kiet_ring | -35.95 |
| call_reconnect | -35.94 |
| death_fall_back | -32.19 |
| death_bed_burst | -34.09 |
| death_flesh | -34.10 |
| death_fall_soft | -41.97 |
| death_bed_soft | -43.98 |
| cctv_static | -54.38 |
| cctv_switch | -46.30 |

Peak lớn nhất bank mới **-12.21 dBTP**. Ba loop: handle_rattle, kiet_ring, cctv_static. Dùng lại call_disconnect, manager_kill và kill_soft của T-158, không xử lý lại chúng. Nguồn/giấy phép/cách tổng hợp từng nhóm ở [CREDITS](../../game/audio/CREDITS.md); số đo đầy đủ ở [report](../../audio_source/ch1v2/build_report.json).

**API:** chi tiết, giới hạn đầu vào và cách nghe ở [README T-164](../../audio_source/ch1v2/README.md).

- `WallTaps` (Node3D): `play_sequence(position, groups: Array[int], gap_digit=1.0, gap_letter=2.5) -> bool`; dãy phẳng hàng/cột 1–5, ví dụ CO `[1,3,3,4]`. Khoảng cách giữa đầu nhịp trong nhóm 0.28 s; sau nhóm chẵn dùng gap_digit, sau nhóm lẻ dùng gap_letter. `sequence_finished` sau đuôi nhịp cuối; hủy/restart không báo hoàn thành chuỗi cũ. `play_tap(position)`, `stop_emitting()`, `set_other_side(true)` LP900/giảm 4 dB; SFX không gian 3D. Pause đóng băng lịch, checkpoint hủy. Dùng rig riêng cho người chơi gõ đáp.
- `Ch1MissionAudio` (Node3D): `play_cue(name)` cho ba âm router, power_switch, power_short, lock_alarm; `set_handle_rattling(true/false)` điều khiển loop và đuôi dừng một lần. Tất cả SFX, không tự phát gameplay noise hoặc quyết định nhiệm vụ.
- Mở rộng `PhoneCallAudio` sẵn có: nghe `phone_call_lost/restored(call_id)`, cắt speech/chuông và bỏ hàng đợi lúc mất, không replay lời đã lỡ. `play_remote_ring(on, member_id=&"kiet")` cho chuông Kiệt; chuông/nối lại qua PhoneSFX. Trạng thái chết/rời của thành viên trong khi mất mạng vẫn được giữ.
- Mở rộng `Ch1PlayerAudio` sẵn có: nghe `player_death_started(kind)` cho fall_back/bed_burst/manager_kill/none. Chống phát base manager_kill trùng giữa player_caught và death_started ở cả hai thứ tự; reset theo checkpoint/chapter. Giảm hù dọa dùng hai bản soft, bỏ flesh, đổi được ngay lúc đang phát. `heartbeat_ramp_seconds=6.0` theo Insane, không quyết định gameplay hết hơi.
- `CctvAudio`: `set_viewing(on)`, `select_channel(camera_id)`. Chỉ phát rè khi xem thật; cùng kênh không phát nhiễu lại, hạ máy/reset dừng. Không bật từ thông báo cctv_focus_requested/cctv_unlocked; không thêm âm giết riêng trên camera.

**Kiểm tra đã chạy** bằng Godot 4.7.2:

```text
pwsh tools/test.ps1 -Filter audio
RESULT: 60 passed, 0 failed
pwsh tools/test.ps1
RESULT: 365 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Thêm 10 test kiểm tra đủ asset/hash/LUFS/loop, bus, chuỗi đúng nhịp/thứ tự/gap, input không hợp lệ, hủy/restart từ callback, muffle/pause/reset, mất mạng không phát lại, death không trùng/reduced, camera chỉ chạy khi xem, thiếu stream và shutdown. Scene `res://audio/test/ch1v2_audio_test.tscn` đã smoke headless 900 frame với `--max-fps 60 -- --ch1v2-audio-preview --quit-after-frames=900`: exit 0, không lỗi/cảnh báo. `git diff --check` PASS.

**Cách nghe:** mở scene trên, F6; trái/phải/Space chọn/nghe riêng 20 clip; F1 chuỗi CO, F2 đổi bên tường; F3–F9 router/ổ điện/tay nắm/báo động; K/L/R chuông Kiệt/mất mạng/nối lại; 1–4 cảnh chết; C/N xem camera/đổi kênh; 0 dừng/reset, Esc thoát. Đổi giảm hù dọa trong menu trước khi chạy fixture để so sánh. Tên âm in ở console.

**Còn dở / giới hạn:** hai mục checklist đã đạt. **Chưa nghe bằng tai**, chưa được chủ dự án duyệt chất âm/mix và chưa export Windows. Số đo/headless không thay thế nghe thử. Luồng 8 nhiệm vụ/camera mới chưa được ghép trong phạm vi lane E; cần các điểm nối dưới đây rồi nghe và kiểm thử trên bản tích hợp. Không có câu hỏi mới về cốt truyện/luật chơi; caller dùng mốc trong đặc tả đã duyệt.

### Yêu cầu thay đổi ngoài phạm vi

1. **Core/Lane A, T-160/T-161:** gắn WallTaps và Ch1MissionAudio tại vị trí đạo cụ; gọi chuỗi đã mã hóa, cue router/công tắc/chập và bật/tắt tay nắm theo trạng thái nhiệm vụ. Giữ logic công tắc 3, lời Khoa, nhịp lặp và chốt cửa ở gameplay. Không dùng cùng rig cho tiếng đáp của người chơi khi chuỗi bên kia vẫn chạy.
2. **Core, D-042:** phát `player_death_started(kind)` một lần trước player_failed; đồng bộ hoạt cảnh khoảng 3 s (âm thân chạm sàn tại khoảng 1.6 s của fall_back). Ch1PlayerAudio hiện có là nơi phát base manager_kill. Nếu node ManagerAudio khác đã phát base thì đặt `handle_player_caught=false` để tránh trùng ngoài node; không thêm death-audio node thứ hai.
3. **Core:** phát phone_call_lost/restored với đúng call_id đang hoạt động; gọi play_remote_ring(true/false) đúng mốc chuông Kiệt. PhoneCallAudio hiện có đã nhận signal, không cần tạo thêm node. Đồng bộ heartbeat_ramp_seconds nếu core đổi thời gian nín thở từ 6 s.
4. **Lane D, T-163:** tạo CctvAudio và gọi set_viewing theo tab Camera thực sự đang hiển thị, select_channel khi đổi kênh; dừng khi rời tab/mất quyền xem. Gọi lock_alarm một lần lúc khóa kẹt, chọn một chủ thể phát để tránh trùng; gameplay noise bán kính 12 m vẫn do UI/core xử lý.

Không yêu cầu signal, setting, autoload hoặc bus mới. **Blocked: không có trong phạm vi Lane E**; chờ integrator nối API và chủ dự án nghe duyệt.

### Review (integrator, 2026-10-05)
- **Đạt, đã merge.** Đúng phạm vi; 20 âm mới, 10 test; LUFS ghi đủ; trung thực về việc chưa nghe bằng tai. **Chủ dự án cần nghe.**
- **Ghép vào chương 1:**
  - `Ch1MissionAudio` (`MissionAudio`): `router_power_off`, `router_boot`, `router_online`, `power_switch`, `power_short`, tay nắm cửa vặn;
  - `WallTaps` (`KhoaTaps`, `set_other_side(true)`): chuỗi gõ của Khoa theo từng từ;
  - `PhoneCallAudio.play_remote_ring` cho chuông của Kiệt;
  - mất kết nối và cảnh chết dùng signal có sẵn.
- Còn lại cho lane D (T-163): `CctvAudio.set_viewing/select_channel`, `lock_alarm` khi khóa kẹt.

