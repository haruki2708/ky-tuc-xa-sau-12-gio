# T-178 — Chương 2: xác đọc từ trong từ điển (ghép giọng theo tiếng)
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-178-ch2-syllable-voice`
- Phụ thuộc: T-175. **Đọc D-049, D-051 trong `docs/DECISIONS.md`.**
- **Hạn đề xuất: hết ngày 2026-10-07.**

## Mục tiêu
Từ D-051, xác biết khoảng **9 500 từ** của từ điển, không chỉ 266 từ của kho game. Từ của kho game vẫn có file giọng nguyên từ (`WORD_CH2_*.ogg`). Từ ngoài kho thì core gửi **chính chữ** (ví dụ `"khuất bóng"`), và `CorpseVoice` phải **ghép giọng từ từng tiếng**.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`

## Hợp đồng có sẵn (core, không sửa)
- `EventBus.chain_word_spoken(speaker, word_key)`: `word_key` là key `WORD_CH2_*` **hoặc** chữ thường tiếng Việt có dấu, hai tiếng cách nhau một dấu cách. Đọc chú thích mới trong `event_bus.gd`.
- `Ch2SyllableBank.clips_for(text) -> Array[Dictionary]` (`game/scripts/core/ch2_syllable_bank.gd`): mỗi tiếng một mục `{stream, start, length}` (giây). Cách phát: `play(start)`, dừng sau `length`. Trả mảng rỗng nếu thiếu tiếng nào.
- `Ch2SyllableBank.seconds_for(text)`: tổng thời lượng. Core chờ khoảng `seconds_for(text) / 0.72 + 0.3` giây cho lượt của xác.
- File giọng do core tạo (`audio_source/ch2_syllable_voices.py`): `game/audio/voice/vi/ch2_syllables_0..3.ogg`, giọng xác trung tính, có khoảng lặng 0,25 giây giữa các tiếng. **Không sửa các file này.** Cần giọng khác thì ghi "Yêu cầu thay đổi".

## Yêu cầu
1. `CorpseVoice.play_word(key)`:
   - key `WORD_CH2_*`: giữ nguyên cách cũ;
   - chữ thường: phát lần lượt các đoạn của `clips_for(key)` trên cùng bus méo riêng của xác, cùng `pitch_scale` từng xác, nghỉ khoảng 0,05–0,1 giây giữa hai tiếng; trả về tổng thời lượng sau khi đổi pitch;
   - `clips_for` rỗng: không phát gì, trả 0 (không bịa từ khác).
2. Đầu và cuối mỗi đoạn có fade rất ngắn (vài mili giây), không lách cách khi cắt.
3. Bị bịt miệng, ú ớ, lượt mới, chết, nạp checkpoint: dừng ngay như cách cũ, kể cả khi đang giữa hai tiếng.
4. Âm lượng ngang với từ nguyên khối (chủ dự án thích âm nhỏ).
5. Test: một từ ngoài kho (ví dụ `"khuất bóng"`) phát đủ 2 đoạn đúng thứ tự, dừng đúng khi có lượt mới; từ không có giọng trả 0; từ `WORD_CH2_*` không đổi.
6. Cảnh nghe thử (`audio/test/ch2_audio_test.tscn`): thêm phím đọc vài từ ghép theo tiếng.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ghi vào Handoff: nghe thử thấy thế nào (rõ chữ không, có lách cách không)
- [ ] Handoff: API, cách nghe thử

## Handoff (agent điền)
