# T-178 — xác đọc từ ghép theo tiếng

`CorpseVoice.play_word(key) -> float` vẫn nhận key `WORD_CH2_*`, đồng thời nhận chữ từ core qua `chain_word_spoken(speaker, word_key)`. Nhánh key cũ nạp đúng OGG nguyên khối, không đổi pitch, gain −6 dB, bus méo riêng → Voice hoặc thời lượng. Không sửa `audio_source/ch2_syllable_voices.py`, `ch2_syllables_0..3.ogg`, bảng tiếng hay core.

## Phát và dừng

Với chữ, gọi `Ch2SyllableBank.clips_for(text)`; chỉ nhận đủ hai mục `{stream, start, length}`. Thiếu tiếng hoặc khoảng cắt không hợp lệ thì dừng lời trước đó, không phát phần còn lại và trả 0. Các quy tắc chuẩn hóa chữ tiếng Việt vẫn do helper core xử lý. Key rỗng hoặc xác đã bị bịt giữ cách cũ: ú ớ và trả 0.

`CorpseSyllablePhrase.build(clips, pitch)` giải mã đúng khoảng start/length của từng tiếng, ghép tuần tự vào **một AudioStreamWAV tạm trong RAM**, PCM16 stereo ở sample rate của AudioServer. Không ghi asset mới và không cache cả từ điển. Đầu/cuối mỗi đoạn có ramp tuyến tính **5 ms**, giữa hai tiếng có **80 ms** im lặng sau khi áp dụng pitch. Không thêm khoảng im sau tiếng cuối. Core vẫn chờ đủ: thời lượng trả về = tổng length/pitch + 0.08 (sai số tối đa vài mẫu); nhỏ hơn ngân sách `seconds_for(text)/0.72+0.3` ở cả ba profile.

Quyết định kỹ thuật: cắt và fade trong PCM thay vì chờ timer từng khung hình gọi stop() trên một OGG dài. Nhờ vậy FPS thấp không làm lộ tiếng kế tiếp trong bank, fade vài mili giây và khoảng nghỉ chạy theo đồng hồ âm thanh. Dùng API [AudioStreamPlayback](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayback.html) để start tại offset và mix đúng số frame; [AudioStreamWAV](https://docs.godotengine.org/en/stable/classes/class_audiostreamwav.html) chứa PCM tạm. Giới hạn hai đoạn, mỗi đoạn tối đa 3 s để không giải mã cả bank khi dữ liệu hỏng.

Phát trên `_voice` 3D hiện có, pitch Phúc .82 / Việt .72 / Đạt .91, gain và bus unchanged. Do cả từ là một playback, các lệnh dừng sẵn có (bịt miệng, mumble, lượt mới, chết, checkpoint, chapter, stop_emitting) dừng cả tiếng đang nói lẫn tiếng chưa tới; không có callback/timer có thể bật tiếng thứ hai trở lại. Pause đóng băng playback; thay từ thay luôn PCM cũ. Test kiểm tra dừng cả trong tiếng đầu và trong khoảng nghỉ.

Với “khuất bóng”: khoảng **1.061 / 1.197 / 0.964 s** ở Phúc/Việt/Đạt. Phép đo test lần đầu dựng PCM khoảng 11–19 ms trên máy này, chỉ là quan sát của lần chạy, không phải bảo đảm FPS trên mọi máy. Không chạy bot chương 2 dài hoặc đo FPS của cả chương.

## Âm lượng và nguồn

Hai nguồn đều dùng giọng eSpeak trung tính của core, cùng target −30 LUFS và xử lý nguồn của T-176. T-178 giữ nguyên biên độ bên trong đoạn, chỉ hạ hai mép fade; không tự tăng gain hay normalize từng tiếng. Test so sánh PCM nội dung với nguồn trong sai số lượng tử 16 bit.

`py -3 audio_source/ch2_syllable_audit.py` chỉ đọc file nguồn, tạo WAV tạm bên trong audio_source rồi dọn; báo cáo `syllable_audit.json`. So sánh độc lập bằng FFmpeg trên 8 từ của vòng từ đã có, cùng pitch .72 và gain −6 dB, **trước bus méo/LP/không gian**:

| Từ | Ghép tiếng (LUFS) | Nguyên khối (LUFS) | Chênh LU |
|---|---:|---:|---:|
| học sinh | -36.76 | -35.74 | -1.02 |
| sinh viên | -37.33 | -36.30 | -1.03 |
| viên phấn | -34.56 | -36.18 | +1.62 |
| phấn đấu | -33.54 | -35.59 | +2.05 |
| đấu tranh | -34.30 | -36.52 | +2.22 |
| tranh luận | -36.09 | -35.83 | -0.26 |
| luận văn | -36.60 | -35.96 | -0.64 |
| văn học | -36.10 | -35.98 | -0.12 |

Chênh trung bình **+0.35 LU**, phạm vi −1.03…+2.22 LU; đủ gần để giữ mức cũ và chờ nghe duyệt. Đây là số đo trên mẫu so sánh, không chứng minh mọi từ hay toàn mix có loudness giống hệt. Report lưu hash bốn OGG gốc. Nguồn/giấy phép giọng theo mục eSpeak chương 2 trong `game/audio/CREDITS.md`; T-178 không sinh giọng, không lấy thêm từ điển, không tạo nội dung thoại mới.

## Nghe thử

Mở `res://audio/test/ch2_audio_test.tscn`, F6:

- **B:** luân phiên “khuất bóng”, “bóng đèn”, “đèn dầu”; mỗi từ qua Phúc → Việt → Đạt. Tên từ/giọng/thời lượng in ở console. Mỗi lần bấm dừng mix trước đó để nghe riêng.
- **V:** từ nguyên khối có sẵn, luân phiên ba giọng như cũ.
- **T:** chuyển lượt để thử cắt ngay lời đang phát. **1/2/3:** thay bằng tiếng ú ớ. **0:** dừng/reset; **Esc:** thoát qua App.quit.
- Các phím hiệu ứng, nước, nhạc, chết và camera của T-175 giữ nguyên.

Smoke tự động: Godot console `--headless --path game res://audio/test/ch2_audio_test.tscn --max-fps 60 -- --ch2-syllable-preview --quit-after-frames=180`.

**Chưa nghe bằng tai.** Chưa thể kết luận phát âm rõ dấu, âm sắc có tự nhiên hay có tiếng lách cách cảm nhận được. Test đã kiểm tra fade về mẫu 0, khoảng nghỉ im, nội dung/thứ tự, mức âm, pause và hủy; chủ dự án/integrator cần nghe B/V rồi xác nhận checklist nghe. Không thay giọng nguồn khi chưa có yêu cầu từ core/chủ dự án.
