# T-175 — Chương 2: âm thanh nối từ, nước tắm, cảnh chết mới
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Scene nghe từng âm; credits; LUFS
- [ ] Handoff: rig, API, tên file

## Handoff (agent điền)
