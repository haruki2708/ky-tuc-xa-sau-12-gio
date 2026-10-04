# T-159 — Giọng chương 1: loa trường, quản lý, các thành viên cuộc gọi nhóm
- Lane: E (Âm thanh) | Trạng thái: done | Agent: **Claude làm thay** (agent E hết hạn mức; chủ dự án yêu cầu)
- Nhánh: `lane-e/T-159-ch1-voices`
- Phụ thuộc: T-137 (pipeline giọng TTS), T-158 (làm ngay sau). Câu thoại do integrator viết trong T-150 phần 2 (key `SPK_CH1_*`, `MGR_*`, `CHAT_CH1_*` trong `strings.csv`, và `game/data/messages/`); **bắt đầu khi integrator báo câu thoại đã lên `main`**, dự kiến sáng 2026-10-06.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Chương 1 có nhiều giọng:
- **Loa trường:** lạnh, đều đều, như loa trong trại giam. Khác hẳn giọng loa của demo cũ.
- **Quản lý:** trầm, đục, chậm, đáng sợ.
- **Các thành viên cuộc gọi nhóm:** Minh Nhật (bình tĩnh, rõ ràng) và khoảng 6 sinh viên khác. Mỗi người một giọng phân biệt được; có người hoảng loạn, có người khóc, có người chửi.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`

## Yêu cầu
1. Sinh giọng TTS cho mọi key `SPK_CH1_*` (loa), `MGR_*` (quản lý) và mọi `MessageData` có `spoken = true` (key `CHAT_CH1_*`).
   - Dùng công cụ của T-137 hoặc công cụ khác **cho phép dùng thương mại**; ghi `CREDITS.md`.
   - Chọn giọng theo `sender` của từng tin nhắn. Bảng `sender` → giọng ghi trong Handoff.
   - Bản tiếng Anh dùng giọng Việt kèm phụ đề (D-006), trừ khi pipeline có sẵn giọng Anh tốt.
2. **Xử lý:**
   - loa: méo nhẹ, vang hành lang (qua `Speaker`);
   - quản lý: hạ tông, thêm độ đục; nghe 3D qua `manager_audio` (T-158);
   - thành viên cuộc gọi: qua bộ lọc điện thoại của T-158. Câu la hét hoặc khóc có thể thêm hiệu ứng nhưng giữ âm lượng trong mức đã duyệt.
3. **Thời lượng từng câu** tra được (như `speaker_voice_bank.gd`), để integrator xếp lịch cuộc gọi.
4. Thiếu clip thì rơi về phụ đề, không lỗi.
5. **Test:** mọi key `spoken` và `SPK_CH1_*`, `MGR_*` có clip; tra thời lượng được; đúng bus.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `CREDITS.md` cập nhật
- [ ] Handoff: bảng giọng, thời lượng, LUFS, cách nghe thử

## Handoff (agent điền)

### Phiên 2026-10-04 — Claude làm thay
- **Pipeline:** `audio_source/ch1_voice_process.py`. Đọc danh sách câu và người nói từ `docs/design/ch1/build_ch1_script.py`, đọc lời từ `strings.csv`.
  - Mỗi người một giọng eSpeak NG: biến thể, tốc độ, cao độ, chuỗi FFmpeg, LUFS (bảng `VOICES`).
  - **Loa:** lạnh, chậm, qua bộ lọc loa như T-137, −26 LUFS.
  - **Quản lý:** hạ tông 0,8 lần, đục, chậm, −27.
  - **Thành viên cuộc gọi:** giọng sạch, chưa lọc điện thoại (bộ lọc của T-158 áp lúc chạy), −25 đến −27. Bảo có rung giọng.
  - **Ba bạn càu nhàu trong phòng:** khẽ, −32. **Việt ngoài cửa:** lọc như nghe qua cửa, −33.
- **58 câu** chỉ có bản tiếng Việt; khi chơi bằng tiếng Anh vẫn nghe giọng Việt, phụ đề tiếng Anh (D-006). `SpeakerVoiceBank` và `Ch1AudioBank.voice` rơi về `vi/` khi thiếu `en/`. `SpeakerVoiceBank` nhận thêm tiền tố `RULE_CH1_`. "(cười khàn khàn)" của quản lý đọc thành "Khà… khà… khà.".
- **Luồng chương:**
  - chờ đúng độ dài câu thật (`_voice_seconds`);
  - phát giọng ba bạn từ đúng giường, giọng Việt từ ngoài cửa (`_room_line`);
  - lời quản lý phát qua `ManagerAudio.say` (T-158).
- **Test:** `test_every_chapter_1_line_has_a_voice` (mọi câu đều có giọng, loa có cả `vi` và `en`); `test_audio` thêm 58 file vào danh sách. Toàn bộ 305/305 PASS.
- **Chưa nghe bằng tai.** eSpeak là giọng máy, nghe rất "robot". **Chủ dự án cần nghe** và quyết có giữ hay tìm công cụ TTS tốt hơn (phải cho phép dùng thương mại, D-006).
- Kịch bản còn chờ chủ dự án duyệt. Sửa lời thì chạy lại `docs/design/ch1/build_ch1_script.py` rồi `audio_source/ch1_voice_process.py`.
