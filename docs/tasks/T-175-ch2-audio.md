# T-175 — Chương 2: âm thanh nối từ, nước tắm, cảnh chết mới
- Lane: E (Âm thanh) | Trạng thái: done | Agent:
- Nhánh: `lane-e/T-175-ch2-audio`
- Phụ thuộc: T-158, T-164. **Đọc `docs/design/CH2_DESIGN.md`** (D-046).
- **Hạn: hết ngày 2026-10-07.**

## Mục tiêu
Âm thanh cho chương 2. Giọng đọc lời thoại và **giọng xác đọc từ nối** do core sinh bằng eSpeak (pipeline T-159); lane E làm hiệu ứng, xử lý giọng xác và rig phát.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Hợp đồng có sẵn (core, không sửa)
`EventBus.chain_turn_started`, `chain_word_spoken`, `corpse_state_changed`, `shower_choice_requested`, `shower_slot_finished`, `shower_steam_changed`, `player_death_started` (`corpse_lunge`, `scald`).

## Yêu cầu
1. **Giọng xác** (`CorpseVoice`, mỗi xác một rig 3D ở đầu xác): phát file từ `game/audio/voice/vi/WORD_CH2_*.ogg` (core sinh), xử lý cho ghê: hạ tông, méo, khàn. Ba xác ba màu giọng khác nhau. Trạng thái `mumble`: tiếng ú ớ qua giẻ.
2. **Âm nối từ:** tích tắc 15 giây (5 giây cuối gấp), tiếng xác gục xuống và bật dậy (xương kêu), tiếng rên khi bị bịt.
3. **Nhà vệ sinh:** cửa gỗ bị đẩy (3 mức), cửa bật mở và hơi nóng phụt ra; nước lạnh, ấm, sôi sùng sục (theo nhiệt độ, chọn nhanh khi lượt mới bắt đầu); hơi nước xì; tiếng bíp màn hình đếm ngược; tiếng gương (jumpscare 7).
4. **Cảnh chết:** `corpse_lunge` (ba xác cùng rít, cắn xé), `scald` (nước sôi, la hét nghẹn); bản "Giảm hù dọa".
5. **Camera vòng 3:** tiếng phòng khác thua (chỉ khi đang xem camera đó, như `CctvAudio`).
6. **Nhạc chương 2:** nền căng cho nối từ (nhịp theo lượt), nền ẩm nóng cho phòng tắm.
7. **Âm lượng nhỏ** như chương 1 (chủ dự án thích âm nhỏ); ghi LUFS. CC0, tự tổng hợp như T-164.
8. **Test và scene nghe** như T-164.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Scene nghe từng âm; credits; LUFS
- [x] Handoff: rig, API, tên file

## Handoff (agent điền)

### 2026-10-05 — Lane E

**Đã làm:** commit `fe0e60e` từ `origin/main` `c68888b`, nhánh `lane-e/T-175-ch2-audio`. Đã push triển khai và đủ 46 đối tượng LFS trước khi ghi Handoff. Thêm 23 âm CC0 tự tổng hợp, pipeline, raw WAV/OGG, report LUFS/hash/peak, rig và 11 test mới. Không sửa core/UI/gameplay, không thêm plugin/công cụ, không cài vào C:, không sửa bank chương 1 hoặc bus layout. Không tự sinh lời thoại/từ nối.

**Asset:** raw `audio_source/ch2/raw/<name>.wav`, runtime `game/audio/ch2/<name>.ogg`; tổng **7.981.108 byte**, mỗi file <10 MB. Kiểm tra 46 SHA-256 PASS, peak lớn nhất **−15.96 dBTP** trước bus/filter. Giấy phép, nguồn, công cụ và khai AI-assisted ở [CREDITS](../../game/audio/CREDITS.md). LUFS từng âm và API đầy đủ ở [README T-175](../../audio_source/ch2/README.md); số đo gốc ở [build_report.json](../../audio_source/ch2/build_report.json).

| Nhóm | Tên file (bỏ đuôi) / LUFS |
|---|---|
| Xác | corpse_mumble −40.02; corpse_fall −38.10; corpse_revive −38.20; corpse_gag −40.04 |
| Đếm ngược | chain_tick −47.95; shower_beep −46.05 |
| Cửa | door_push_01 −41.97; door_push_02 −40.01; door_push_03 −37.98; door_burst −34.20 |
| Nước/hơi | water_cold −46.32; water_warm −44.34; water_boiling −40.22; steam_hiss −48.34 |
| Gương | mirror_shiver −37.97 |
| Cảnh chết | death_corpse_lunge −32.03; death_scald −32.20; death_corpse_soft −41.99; death_scald_soft −42.22 |
| Camera | camera_room_loss −42.13 |
| Nhạc | music_chain −48.01; music_shower −50.14; music_turn −48.02 |

**Rig/API:**

- `CorpseVoice` (Node3D tại đầu mỗi xác), export speaker phuc/viet/dat ↔ giường1/2/4. `play_word(key) -> float` đọc `voice/vi/WORD_CH2_*.ogg`, trả độ dài sau pitch; thiếu file trả0/im. Nghe chain_word_spoken và corpse_state_changed. Ba pitch .82/.72/.91, distortion/LP qua bus tạm riêng → Voice; body → SFX. `set_mumbling(on)` ú ớ LP650, trạng thái gagged giữ qua gục/sống lại, reset mới xóa. Lượt mới cắt lời/mumble lượt cũ, không sửa gameplay hay phụ đề.
- `Ch2Countdown` (một Node): nghe chain_turn_started/word_spoken/choice_made; `start(seconds)`/`cancel()`. Tích tắc mỗi1s, 5s cuối mỗi.5s; 15s có19nhịp, không tick ở0. Pause đóng băng; timeout chỉ dừng âm, không quyết định chết. Có signal ticked cho QA.
- `ShowerAudio` (Node3D): **`set_water(temperature, running)` gọi ngay khi công bố nhiệt độ đầu lượt**; lạnh<10, ấm<50, sôi≥50; cùng loại không restart. `set_steam(level)` nhận0…1; nước/hơi → Ambience. Choice requested/made điều khiển beep SFX. **shower_slot_finished chỉ dừng nước** theo hợp đồng cuối lượt; không phát muộn/tự đoán nhiệt độ. `play_door_push(1..3)`, `play_cue("door_burst"/"mirror_shiver")` do caller chọn mốc.
- `Ch1PlayerAudio` mở rộng player_death_started cho corpse_lunge/scald; clip3s, chốt một lần mỗi lượt sống, bản giảm hù dọa và đổi sang soft ngay khi bật tùy chọn. Không tạo death-audio thứ hai; chặn player_caught cũ phát manager_kill theo sau.
- `CctvAudio` mở rộng **`play_room_loss(camera_id) -> bool`**, chỉ phát khi đang xem đúng kênh; ẩn/khác kênh/thiếu file/đang phát trảfalse. Đổi kênh/hạ máy/reset dừng; xem lại không tự replay. Cần caller phát tại mốc sự kiện, không dùng cctv_focus_requested để suy ra người chơi đang xem.
- `Ch2Music` → Music: `set_round(&"chain" / &"shower" / &"")`, chuyển nền1.5s, pulse theo chain_turn_started. Chapter2 bắt đầu chain; shower_choice_requested chuyển shower khi đang hoạt động. Core đặt lại round sau checkpoint. Mọi rig có stop_emitting, kế thừa pause; chapter/checkpoint/death dừng nguồn/lịch.

**Kiểm tra đã chạy, Godot 4.7.2:**

```text
pwsh tools/test.ps1 -Filter ch2_audio
RESULT: 11 passed, 0 failed
pwsh tools/test.ps1
RESULT: 425 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Test bao phủ decode/hash/LUFS/loop, ba profile/bus giọng và giải phóng bus, nạp key an toàn/thiếu clip, gag giữ qua revive,19nhịp đúng hạn/pause, chuyển nước và không tiết lộ nhiệt độ trước chọn, steam/reset, death lặp/reduced, camera đúng kênh/không replay và nhạc đổi vòng. Test voice dùng clip phi ngôn ngữ trong resource cache để kiểm tra đường nạp và độ dài, **không phải kiểm tra lời đọc từ thật**. Full test exit0; có warning fixture Light switch chưa gắn đèn, không phải lỗi audio. `git diff --check` PASS.

**Scene nghe:** F6 `res://audio/test/ch2_audio_test.tscn`, trái/phải/Space solo23clip, tên ở console. 1/2/3: ú ớ ba xác; V: từ thật khi core thêm bank; T: lượt15s; F1/F2/F3 nước5/37/81độ; F4 hơi; F5 beep8s; F6 cửa bật; F7 gương; L/S cảnh chết; C camera; M/N nhạc nối từ/tắm;0reset;Esc App.quit. Đổi giảm hù dọa trong menu trước khi thử L/S. Smoke headless với `--max-fps 60 -- --ch2-audio-preview --quit-after-frames=180` exit0, không lỗi/cảnh báo.

**Còn dở / giới hạn:** checklist3/3 đạt ở phạm vi Lane E. **Chưa nghe bằng tai**, chưa được chủ dự án duyệt mix, chưa export/chơi toàn chương2. Tại base c68888b chưa có WORD_CH2 nên chưa xác nhận độ rõ dấu, chất khàn, độ dài và LUFS của lời thật sau xử lý. Cần core giao voice bank rồi nghe trên bản ghép; không tự lấy/tạo từ hay giọng thay thế. D-047 đã duyệt thiết kế; không có câu hỏi mới về luật/cốt truyện.

### Yêu cầu thay đổi ngoài phạm vi

1. **Core/T-170:** sinh và khai nguồn `game/audio/voice/vi/WORD_CH2_*.ogg` từ kho từ/kịch bản đã duyệt; giữ âm lượng nhỏ, gửi LUFS giọng nguồn. Sau khi có bank cần kiểm tra độ rõ tiếng Việt qua ba profile; thời lượng sau hạ pitch dài thêm, dùng play_word trả về hoặc chờ tương ứng trước khi sang lượt. Không phát thêm bản voice thường song song với CorpseVoice.
2. **Core/Lane A/B:** gắn ba CorpseVoice vào đầu xác, một Ch2Countdown cho vòng3; emit đúng giường/speaker/state. Sau checkpoint phát lại gagged cho xác còn bị bịt. Ghép Ch1PlayerAudio hiện có với death_started, đồng bộ hoạt cảnh3s; không tạo death-audio thứ hai hoặc tự phát trùng lunge trên từng xác.
3. **Core/Lane A:** gắn ShowerAudio tại vòi/cửa; gọi set_water ngay đầu lượt sau lựa chọn và công bố nhiệt độ. Hợp đồng hiện chỉ có shower_slot_finished cuối lượt nên audio không tự đoán thời điểm/nhiệt độ. Gọi các cue đẩy cửa1–3, mở cửa và gương theo nhiệm vụ; gameplay noise thuộc caller. Nếu chọn dùng signal mới cho đầu lượt, core sở hữu thay đổi EventBus và báo lại Lane E.
4. **Core/Lane D:** tại mốc camera phòng khác thua gọi CctvAudio.play_room_loss với đúng ID trên rig đang theo dõi tab/kênh thật. Gắn Ch2Music cho chapter2; sau restore ch2_r4 gọi set_round(shower) sau reset. Kiểm tra mix điện thoại/camera để không phát hai âm chết cùng sự kiện ngoài ý muốn.

**Blocked:** không có chặn triển khai trong phạm vi Lane E; kiểm chứng giọng từ thật đang phụ thuộc voice bank của core và ghép chương2. Không coi headless PASS là đã nghe/duyệt âm.

### Review (integrator, 2026-10-05)
- **Đạt, đã merge.** Đúng phạm vi; 23 âm, 11 test, LUFS ghi đủ. Ghép:
  - `CorpseVoice` ở `Gag1/2/4` (miệng xác);
  - `Ch2Countdown`;
  - `ShowerAudio` ở buồng tắm: nước theo nhiệt độ khi công bố, hơi nước, đẩy cửa 1–3, cửa bật mở, gương;
  - `Ch2Music` đổi theo vòng.
- Lượt của xác chờ đúng độ dài từ sau khi hạ giọng.
- Chưa: `CctvAudio.play_room_loss` (chưa có rig `CctvAudio` nào trong chương; cần tab Camera báo kênh đang xem).
- **Chủ dự án cần nghe**, nhất là giọng xác đọc từ.
