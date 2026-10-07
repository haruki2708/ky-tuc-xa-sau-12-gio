# T-200 — 16 giọng Chương 4 đã duyệt (D-068)

Văn bản lấy **nguyên cột `vi` của `game/localization/strings.csv`**, không bỏ dấu ba chấm hoặc viết lại câu. Kịch bản duyệt: `docs/design/CH4_SCRIPT.md`. Không thu `SAY_CH4_TRUNG_ASK`; Trung không có giọng. Người đọc câu kết đã chốt là **y tá 2 ở cả hai kết**.

| Key | Giọng / WPM / pitch | Mục tiêu LUFS | Bus |
|---|---|---:|---|
| SPK_CH4_REGISTERED | vi+m1 / 132 / 30, preset loa cũ | −33 | Voice |
| CHAT_CH4_NGU_GO, NGU_LECTURE, NGU_NO_EXIT, NGU_TRUNG | vi+f2 / 188 / 58, Ngư Ch3 | −26 | PhoneVoice |
| CHAT_CH4_N_GO, N_GYM, N_LINE, N_WHERE, N_LOST, N_GOT | vi+m2 / 188 / 46, Minh Nhật Ch3 | −26 | PhoneVoice |
| NEAR_CH4_NURSE1_AWAKE, NURSE1_LUCKY | vi+f1 / 145 / 54 | −34 | Voice |
| NEAR_CH4_NURSE2_QUAKE, NURSE2_ALL, NURSE2_ALONE | vi+f3 / 150 / 62 | −34 | Voice |

Các tên rút gọn cùng hàng dùng tiền tố đầu hàng. Minh Nhật/Ngư lấy trực tiếp preset Ch3 (150 ×1,25 làm tròn 188 WPM), không tăng tốc lần hai ở runtime. Giữ PA/y tá nhỏ theo T-198; cuộc gọi giữ −26 LUFS của Ch3. Tất cả OGG đo lại lệch mục tiêu ≤1 LU, true peak ≤−2 dBTP. Limiter trước Vorbis chặn transient TTS, không sửa từ; ngưỡng tuyến tính 0,63, không auto gain. Report `build_report.json` ghi nguyên văn, người đọc, tham số giọng, thời lượng, LUFS/peak và SHA256 raw/OGG.

## Tái tạo

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' audio_source/ch4_voice_process.py
pwsh tools/test.ps1 -Filter ch4
```

Dùng eSpeak NG 1.52.0 và FFmpeg 9.0.2 đã có ở `D:\Tools`, Python stdlib; không tải/cài phần mềm, không dùng neural voice, bản thu người hoặc dịch vụ mạng. Raw: `audio_source/voice_ch4/raw/<KEY>.wav`. Runtime: `game/audio/voice/vi/<KEY>.ogg` và `.import`, cùng cách Ch3. **Bỏ toàn bộ 7 bản nháp raw/OGG/import T-198 trong `game/audio/ch4_voice/`** vì một số lời và người nói đã thay đổi. Không giữ alias nháp có thể phát nhầm lời cũ. `Ch4AudioBank.voice` và API preview `play_line` chỉ nhận 16 key mới; core sử dụng các đường phát có sẵn.

## Runtime và kiểm tra

- `PhoneCallAudio` nhận `CHAT_CH1_`…`CHAT_CH4_` qua cùng kiểm ký tự viết hoa/số/gạch dưới; giữ queue, spoken flag, bỏ câu của thành viên chết/rời, không replay câu bị mất sóng. `chapter_started(2…4)` mở cuộc gọi ngay, không chuông; `checkpoint_loaded` dùng `GameState.chapter` đã restore. Call ID nội bộ `ch2_group`, `ch3_group`, `ch4_group` (khớp core Ch4). Chương 1 giữ incoming/answer như cũ; stop vĩnh viễn không bị start/checkpoint làm sống lại.
- `SpeakerVoiceBank` đã mở allowlist an toàn cho SPK/RULE Ch1…4; trước T-200 chỉ nhận Ch1 nên PA Ch4 không thể đọc file dù có clip. Vẫn chặn path traversal, khóa thường và `RULE_3` chưa che. Voice tiếng Việt fallback khi UI tiếng Anh như D-006.
- Test audio tải scene thật `chapter1.tscn`…`chapter4.tscn`, `auto_start=false`, phát giao thức `chapter_started` như director rồi `phone_message_received`; kiểm đúng `PhoneCallAudio/Speech`, file và bus. Thử checkpoint, loss/restore và không nhấc máy ở Ch2…4; thử Ch1 vẫn cần nhấc máy. Thử PA và cả 5 câu y tá qua đường phát của director tại Nurse1/Nurse2 thật. Không chạy bot Ch3/Ch4.
- **Yêu cầu core ngoài phạm vi:** `Chapter4Director` ở đoạn kết thật hiện chỉ `_network_up = true` trước `_line("n_got")`, trong khi ở cầu thang đã phát `phone_call_lost("ch4_group")`. Cần phát `EventBus.phone_call_restored.emit(&"ch4_group")` trước `_line("n_got")` để đồng bộ audio. T-200 giữ hợp đồng loss/restore, không tự cho riêng một key vượt trạng thái mất sóng. Không sửa core trong lane E.

## Nhờ chủ dự án nghe

F6 `res://audio/test/ch4_audio_test.tscn`; mũi tên chọn 29 SFX/nhạc rồi 16 câu mới, Space nghe lại, 0 dừng. Giọng chat preview đi qua PhoneVoice giống điện thoại. Cần nghe tên Trần Trung, nhịp/độ rõ của hai bạn, câu N_LOST dừng ở dấu “…”, sự khác nhau của hai y tá, cả hai câu kết và âm lượng nhỏ. **Chưa nghe bằng tai/chưa duyệt cảm nhận.** Test headless xác nhận phát/đo, không thay thế nghe hoặc chơi lại trọn chương.
