# T-178 — Chương 2: xác đọc từ trong từ điển (ghép giọng theo tiếng)
- Lane: E (Âm thanh) | Trạng thái: done | Agent:
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ghi vào Handoff: nghe thử thấy thế nào (rõ chữ không, có lách cách không)
- [x] Handoff: API, cách nghe thử

## Handoff (agent điền)

### 2026-10-06 — Lane E

**Đã làm:** commit `c00afda`, từ `origin/main` `e09451b`, đã push lên `lane-e/T-178-ch2-syllable-voice` trước khi ghi Handoff. CorpseVoice nhận chữ hai tiếng qua API/signal hiện có, nạp `Ch2SyllableBank.clips_for(text)` và phát cả hai tiếng đúng thứ tự. Từ `WORD_CH2_*` giữ nguyên OGG, gain −6 dB, pitch/bus riêng và cách tính thời lượng cũ. Không sửa core, từ điển, bảng tiếng, script sinh giọng hoặc bốn bank OGG của core. Không thêm plugin/công cụ và không sửa bus layout.

**Quyết định kỹ thuật:** helper `CorpseSyllablePhrase.build(clips, pitch)` seek và giải mã đúng start/length của hai đoạn vào một PCM16 tạm trong RAM. Fade tuyến tính 5 ms ở đầu/cuối từng đoạn và khoảng nghỉ 80 ms giữa tiếng đã tính bù pitch. Phát trên `_voice` 3D hiện có; không dùng timer theo frame để cắt bank dài, tránh lộ tiếng kế tiếp hoặc mất fade khi FPS thấp. Không tạo asset âm thanh mới, không cache toàn từ điển. Thiếu một tiếng hoặc range sai thì không phát nửa từ; lời trước đó được dừng, trả 0. Giới hạn hai đoạn, tối đa 3 s/đoạn để chặn dữ liệu lỗi.

**API:** `CorpseVoice.play_word(key_or_text) -> float`, ví dụ `play_word("khuất bóng")`. Trả tổng length/pitch + 0.08 giây (sai số vài mẫu), ở Phúc/Việt/Đạt lần lượt khoảng 1.061/1.197/0.964 s cho ví dụ này; nằm trong ngân sách chờ của core. Gain, LP/distortion và pitch .82/.72/.91 không đổi. Lượt mới, bịt miệng, mumble, chết, checkpoint/chapter, stop_emitting đều dừng toàn bộ playback, kể cả trong khoảng nghỉ; không có callback bật lại tiếng thứ hai. Pause đóng băng audio; key rỗng/gagged vẫn ú ớ như cũ. Chi tiết ở [syllable_playback.md](../../audio_source/ch2/syllable_playback.md).

**Âm lượng:** script audit chỉ đọc nguồn và so sánh bằng FFmpeg trên 8 từ của vòng từ đã có, cùng pitch .72/gain −6 dB, trước distortion/LP/không gian. Chênh trung bình **+0.35 LU**, từ **−1.03 đến +2.22 LU** so với từ nguyên khối; giữ mức cũ. Không tuyên bố loudness mọi từ/mix giống hệt. [Report](../../audio_source/ch2/syllable_audit.json) ghi LUFS từng từ và hash bốn bank; chạy lại bằng `py -3 audio_source/ch2_syllable_audit.py`. Nguồn/giấy phép giọng giữ theo core; đã ghi cập nhật credits, không sinh lời thoại.

**Kiểm tra đã chạy bằng Godot 4.7.2:**

```text
pwsh tools/test.ps1 -Filter corpse_syllables
RESULT: 8 passed, 0 failed
pwsh tools/test.ps1
RESULT: 489 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

8 test mới kiểm tra nội dung hai đoạn với mẫu nguồn/thứ tự/pitch/gain; fade đầu/cuối và khoảng im; missing trả 0; OGG nguyên từ không đổi; dừng trong tiếng đầu và giữa tiếng; gag/mumble/thay từ; pause và kết thúc đúng; dữ liệu lỗi; phím nghe luân phiên ba từ qua ba giọng. Dựng PCM quan sát khoảng 11–19 ms trong test, không phải cam kết FPS. Lần test đầu trong sandbox bị lỗi kho chứng chỉ Windows và một assertion về nội suy mẫu; đã chỉnh phép kiểm tra fade phù hợp resampler, chạy lại ngoài sandbox PASS. Full test/check exit 0. Không chạy bot dài chương 2 hoặc export.

Scene `res://audio/test/ch2_audio_test.tscn` đã smoke headless 180 frame với `--max-fps 60 -- --ch2-syllable-preview --quit-after-frames=180`: exit 0, không lỗi/cảnh báo. `git diff --check` PASS; kiểm tra Git xác nhận bank giọng/script core không đổi. Godot tự chuẩn hóa bus layout đã được trả về bản gốc, không đưa vào commit.

**Cách nghe thử:** mở scene trên, F6. Phím **B** lần lượt đọc “khuất bóng”, “bóng đèn”, “đèn dầu”, mỗi từ qua Phúc → Việt → Đạt, tên/thời lượng ở console. **V** nghe từ nguyên khối để so sánh. **T** đổi lượt để cắt lời; **1/2/3** đổi sang ú ớ; **0** dừng/reset; **Esc** thoát App.quit. Mỗi lần B dừng mix trước đó để nghe riêng; các phím T-175 giữ nguyên.

**Nghe thử thấy thế nào / còn dở:** **chưa nghe bằng tai**, vì phiên này chỉ xác minh bằng dữ liệu âm và headless; chưa kết luận được độ rõ dấu/âm sắc hay có lách cách cảm nhận được. Fade về mẫu 0 và khoảng nghỉ im đã được test, nhưng không thay thế nghe. Do vậy **giữ checklist nghe chưa đạt** (2/3 mục đã đạt); cần chủ dự án/integrator nghe B/V và ghi nhận cảm nhận trước khi đánh dấu. Không ghi giả là đã nghe.

### Yêu cầu thay đổi ngoài phạm vi

Không cần sửa file ngoài phạm vi: core đã gửi chữ và tính thời gian chờ đủ, API/signal giữ nguyên. Không yêu cầu sửa giọng nguồn. Nếu nghe duyệt thấy phát âm/chất giọng chưa đạt, gửi ví dụ từ và profile để core/Lane E xử lý đúng nguồn.

**Blocked:** không bị chặn triển khai hoặc test; còn bước xác nhận bằng tai từ người nghe. Không có câu hỏi mới về luật chơi/cốt truyện.

### Review (integrator, 2026-10-06)
- **Đạt, đã merge** (`9d3531b`). Ghép hai tiếng vào PCM trong RAM thay cho cắt bằng timer theo frame: hợp lý, không lộ tiếng bên cạnh trong file ghép khi FPS thấp; dừng được giữa hai tiếng.
- Ngân sách thời gian khớp core (`seconds_for / 0.72 + 0.3`).
- **Còn mở:** mục nghe thử. Integrator chưa nghe; chờ chủ dự án nghe phím B/V trong `audio/test/ch2_audio_test.tscn` hoặc trong bản export.
