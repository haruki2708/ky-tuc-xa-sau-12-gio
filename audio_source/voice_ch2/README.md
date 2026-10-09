# T-205 — Năm câu gọi vòng 3

Chủ dự án đã duyệt nguyên văn cả 5 câu trong phiên Lane E ngày 2026-10-09.
Nguồn lời: cột `vi` của `game/localization/strings.csv` trên nhánh
`core/T-204-ch2-tell-friends-loop`, commit `13b5d68`. Không thu các lựa chọn của Trung.

Tái tạo riêng 5 câu bằng công cụ đã có trên ổ D (chạy tại gốc repo):

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' audio_source/ch2_voice_process.py --keys CHAT_CH2_N_HOW CHAT_CH2_NGU_HOW CHAT_CH2_N_TOLD CHAT_CH2_NGU_TOLD CHAT_CH2_N_CAUGHT
```

`--keys` chỉ thay raw WAV, OGG/import và các mục report của key được chọn;
không xóa hay tái tạo các giọng còn lại. Chạy không có `--keys` vẫn tái tạo
toàn bộ danh sách thoại chương 2 từ script hiện tại.

Preset giữ cùng chương 2/D-051: Minh Nhật `vi+m2`, pitch 46; Ngư `vi+f2`,
pitch 58; cả hai 188 WPM (150 × 1,25, làm tròn), target −26 LUFS.
Giữ nguyên dấu ba chấm để ngắt câu; riêng N_CAUGHT thêm rung giọng nhẹ
`vibrato=f=7:d=0.08` sau bộ lọc gốc, không thêm hoặc bỏ từ.
Master mono 48 kHz Vorbis bằng FFmpeg, fade đầu 5 ms/cuối 50 ms như pipeline cũ.

| Key (tiền tố CHAT_CH2_) | Giọng | Giây raw | LUFS | True peak dBTP |
|---|---|---:|---:|---:|
| N_HOW | Minh Nhật | 4,338 | −26,15 | −5,02 |
| NGU_HOW | Ngư | 3,807 | −26,06 | −6,97 |
| N_TOLD | Minh Nhật | 3,358 | −26,10 | −5,07 |
| NGU_TOLD | Ngư | 3,231 | −26,08 | −6,96 |
| N_CAUGHT | Minh Nhật | 2,488 | −26,21 | −3,49 |

`build_report.json` lưu nguyên lời, speaker, filter, target/LUFS/peak và SHA256
của raw/OGG mới. Mức chấp nhận theo pipeline chương 2: lệch target ≤1,5 LU,
true peak ≤−1 dBTP. Report cũ được giữ nguyên cho các file không tái tạo.

**Chưa nghe bằng tai.** Nhờ chủ dự án nghe 5 OGG trên, đặc biệt độ ngắt và
sắc thái hoảng của N_CAUGHT; thử lựa chọn đúng/sai khi ghép luồng T-204.
Test cảnh thật kiểm tra các message phát qua `PhoneVoice`, không thay thế
việc nghe duyệt hoặc chơi thử luồng đầy đủ.
