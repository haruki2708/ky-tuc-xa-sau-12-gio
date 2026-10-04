# T-158 — Âm thanh chương 1: tòa nhà la hét, quản lý kéo dao, cuộc gọi, máu
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-158-ch1-audio`
- Phụ thuộc: T-131, T-133. Đọc `docs/design/STORY.md` v2 §0, §5, §9, và D-015…D-019, D-023 (chủ dự án thích nền **khẽ**).
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-159 ngay.

## Mục tiêu
Chương 1 diễn ra trong một căn phòng; âm thanh vẽ ra mọi thứ bên ngoài: tiếng la hét lan khắp tòa nhà, tiếng quản lý kéo dao từ tầng khác tới gần dần, tiếng người trong cuộc gọi nhóm chết. Nền vẫn khẽ; cú hù dựa vào độ tương phản.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (không sửa)
`EventBus.phone_call_incoming`, `phone_call_answered`, `phone_message_received` (`MessageData.spoken`), `chat_member_changed`, `survivor_count_changed`, `player_caught`, `player_hidden`, `breath_held`, `noise_emitted`, `puzzle_solved`, `chapter_started`.

## Yêu cầu
1. **Bộ âm quản lý** (`game/audio/entities/manager_audio.tscn`, node con của quản lý T-152):
   - API: `play_step()`, `play_drag(on: bool)`, `play_knock()`, `play_slash()`, `play_kill()`, `say(line_key: String)` (phát giọng của T-159 và trả về thời lượng).
   - **Dao kéo lê** trên gạch: liên tục, rợn, là dấu hiệu chính để biết quản lý ở đâu.
   - **Nghe qua tầng:** nguồn ở tầng khác bị lọc trầm và nhỏ hơn (mỗi tầng cao 3,3 m). Làm thành script dùng chung (ví dụ `floor_muffle.gd`) để nguồn 3D nào cũng gắn được.
   - **Nguồn "từ xa":** API để integrator đặt quản lý chỉ có âm ở một vị trí bất kỳ trong tòa nhà (khi ông ta ở phòng khác, ngoài tầm nhìn) mà không cần mô hình, ví dụ `ManagerAudio.place_at(position)`.
2. **Tòa nhà la hét:** 3–5 tiếng hét khác nhau, đặt ở nhiều vị trí và tầng, có độ trễ; một đợt cho lúc 4:00 (mở đầu), các tiếng rời cho lúc quản lý giết người ở phòng khác. API `Screams.play_wave(origin, count, spread_seconds)` hoặc tương tự.
3. **Điện thoại và cuộc gọi:**
   - chuông cuộc gọi "tít tít";
   - **bộ lọc giọng điện thoại** (band-pass, hơi rè) cho mọi câu `spoken` trong cuộc gọi;
   - tiếng mất kết nối; tiếng "rơi điện thoại, vỡ" khi một thành viên chết (nghe qua cuộc gọi).
   - Âm lượng giọng trong cuộc gọi nghe rõ, đã qua lọc.
4. **Máu và xác:** nhỏ giọt trên sàn gạch (vòng lặp, rất khẽ); tiếng sột soạt nhỏ khi xác đổi tư thế (`pose_changed` của T-152).
5. **Chém và giết:**
   - chém vào nệm hoặc gỗ (nhiều biến thể);
   - cảnh giết người chơi;
   - với "Giảm hù dọa" thì các âm này nhỏ và ít chi tiết hơn.
6. **Người chơi:**
   - tim đập rất khẽ khi nín thở, nhanh dần;
   - thở hắt khi hết hơi;
   - tiếng trèo lên giường tầng, tiếng sắt giường;
   - gõ tường sang phòng bên;
   - mở tủ khóa số; cắm sạc.
7. **Loa trường:** tiếng bật loa và nhiễu đầu câu kiểu "như trong tù" (giọng ở T-159). Giữ hệ `Speaker` hiện có.
8. **Nhạc:** drone rất thấp cho vòng 1; căng hơn khi quản lý tới gần (nghe khoảng cách tới 407, hoặc integrator đặt mức qua API); im bặt trước khi quản lý mở cửa 407.
9. **Mức âm lượng:** ghi LUFS từng âm trong Handoff. **Chủ dự án sẽ nghe và duyệt.**
10. **Scene thử** `audio/test/ch1_audio_test.tscn`: phím nghe từng âm; một nguồn quản lý đi từ tầng 6 xuống tầng 4 để nghe hiệu ứng qua tầng.
11. **Test:** đủ file, đúng bus, nguồn khác tầng bị lọc, API không lỗi khi thiếu stream.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `CREDITS.md` đủ nguồn và công cụ
- [ ] Handoff: danh sách âm và LUFS, API, cách nghe thử

## Bổ sung từ integrator (2026-10-04, sau khi viết luồng chương)
- Bộ âm quản lý "từ xa": node vào **group `manager_audio`**, có `place_at(position: Vector3)`.
- Tiếng la hét: node vào **group `screams`**, có `play_wave(origin: Vector3, count: int, spread_seconds: float)`.
- Hai node này nên được tạo sẵn trong một scene, ví dụ `res://audio/entities/ch1_audio.tscn`, để integrator instance vào `chapter1.tscn`.

## Handoff (agent điền)
