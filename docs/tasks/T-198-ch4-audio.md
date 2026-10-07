# T-198 — Chương 4: âm thanh (chuông mồi, đập cửa, thư viện, bệnh viện, giọng y tá, nhạc kết)
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-198-ch4-audio`
- Phụ thuộc: T-186, T-194 (**hợp đồng chung**, mã jumpscare), `docs/design/CH4_DESIGN.md`, D-067. Quy tắc cũ: **âm lượng nhỏ** (chủ dự án thích yên; chưa ai nghe âm chương 3, nên giữ ngưỡng của chương 3).
- **Hạn đề xuất:** 2026-10-10.

## Việc
1. **Chuông điện thoại mồi:** nghe `EventBus.phone_decoy_thrown(at, charges_left)`: phát **chuông** (loop 6 giây, tiếng điện thoại cũ rè, vị trí 3D tại `at`, nghe được xa khoảng 30 m, nhỏ ở gần), tắt đúng sau 6 giây; tiếng **chạm sàn** lúc rơi. Hết pin (`charges_left == 0`): tiếng "bíp" yếu lúc điện thoại tắt.
2. **Đập cửa phá được:** nghe `EventBus.door_damage_changed(id, fraction)`: tiếng đập mỗi 0,7 giây tăng dần theo `fraction` (`407`, `library_back`, và cửa phòng T-190); từ 0,3 thêm **tiếng gỗ nứt**, từ 0,6 **gỗ vỡ tung**, từ 0,8 **tiếng gầm gừ** sát cửa. Khi `door_burst` (cửa vỡ) thì **tiếng nổ gỗ** lớn nhất chương (nhưng vẫn trong ngưỡng).
3. **Thư viện:** không khí yên (tiếng ù đèn, giấy, kim loại), mưa bụi xa; jumpscare `librarian_rise` (ghế kéo, tiếng thở), `books_fall` (cả dãy sách rơi), `shelf_corpse` (xác rơi từ kệ), `back_door_hit` (cửa phụ bị đập bất ngờ). Mỗi mã có tiếng riêng, ngắn.
4. **Nhà B quay về:** tiếng **cầu thang đông xác** (nhiều gầm gừ nhẹ chồng nhau, theo `StairCrowd`; dùng nhóm âm xác của T-186, nhỏ hơn sân vận động), `knife_pull` (con dao trong phòng quản lý rút ra), `stairs_turn` (cả cầu thang quay đầu: tiếng áo, gầm khẽ), `hall_lights` (đèn hành lang tầng 4 tắt lần lượt: tiếng tách, ù tắt), `door_hand` (bàn tay thò qua lỗ cửa), `neck_hand` (bàn tay máu đặt lên cổ: im lặng bất thường rồi một tiếng thở).
5. **Loa và lời ký tên:** loa cười lạnh (vòng 5, ngắn) và đọc **"Trần Trung đã đăng ký thành công. Bạn là người sống sót."** (core cung cấp key chữ `SPK_CH4_*`; **voice**: giọng loa eSpeak đã có từ T-137, file `audio_source/` theo cách chương 3: `audio_source/ch4_voice_process.py`).
6. **Cảnh kết:**
   - **tiếng cơ thể mờ dần** (xa dần, nhạc ù, nhịp tim chậm lại);
   - **bệnh viện**: máy theo dõi (bíp đều, `monitor_skip` bỏ một nhịp rồi trở lại), tiếng bước chân y tá, cửa, nhạc rất nhẹ;
   - **giọng hai y tá** (nữ, hai giọng khác nhau; lời ở `CH4_DESIGN.md` "Lời thoại chính" và key `NEAR_CH4_NURSE_*` do core thêm); **nhạc kết** ngắn (nhẹ, không hù), dùng chung khi hiện thẻ "Hết chương 4".
7. **Nhạc chương 4:** một nhạc nền khẽ cho đường ngoài trời và thư viện (căng nhưng thưa), chuyển sang **im lặng gần như hoàn toàn** ở phòng 407 chỉ còn tiếng đập cửa và hơi thở; còi cứu hộ xa **to dần** từ 8:30 tới 9:00 (từ `GameState` mốc giờ hoặc `EventBus` giờ; lane E chọn).
8. **Test** (`game/tests/audio/`): mỗi mã jumpscare và tín hiệu ở trên phát đúng bus, đúng âm lượng trần, không phát trùng; chuông tự tắt sau 6 giây; không rò rỉ player âm khi đổi cảnh.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`, card này (Handoff). Ghi nguồn asset vào `CREDITS.md` của lane (CC0/CC-BY; âm tạo bằng công cụ thì ghi rõ).

## Checklist hoàn thành
- [x] Chuông mồi 3D 6 giây, hết pin báo hiệu
- [x] Đập cửa theo `door_damage_changed`, nứt, vỡ, gầm
- [x] 10 mã jumpscare của chương 4 có tiếng
- [ ] Giọng loa ký tên, giọng 2 y tá, nhạc kết, máy theo dõi
- [x] Nhạc chương 4, còi cứu hộ to dần, im ở phòng 407
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Handoff: bảng âm và âm lượng, **nhờ chủ dự án nghe**

## Handoff (agent điền)

### Lane E — 2026-10-07

- Commit triển khai **`a36b97a`**, đã push lên `origin/lane-e/T-198-ch4-audio`; base `origin/main` **`ff17fb4`**. Chỉ sửa trong phạm vi audio và checklist/Handoff card. Không sửa `STATUS.md`, core, gameplay, scene môi trường hoặc CSV; không thêm plugin/cài công cụ.
- Tạo **29 âm/nhạc** + **7 bản giọng** (5 câu nguyên văn `CH4_DESIGN.md`; mỗi câu kết có hai giọng để core chọn). Pipeline offline tái tạo được, report SHA256/LUFS/peak/seed, raw/OGG qua LFS, `.import` và `.uid` kèm đủ. Raw + OGG mới 9.668.830 byte, file lớn nhất 864.044 byte. Nguồn/CC0/công cụ/AI-assisted đã ghi ở `game/audio/CREDITS.md`, giọng theo quy trình eSpeak T-137.
- `Ch4AudioRig` là root âm theo scene: chuông 3D 6 giây không gửi gameplay noise lần hai; cửa đập 0,7 giây, các ngưỡng lớp, burst chống trùng giữa fraction=1/API/death; 10 mã scare (monitor_skip là bỏ nhịp, không thêm tiếng hù); khoảng lặng 0,8 giây trước neck_hand; StairCrowd reuse T-186 giảm gain, tối đa 3 nguồn gần nhất; còi theo 510→540 phút, phòng 407 tắt nền; fade/tim chậm, bíp bệnh viện, Foley y tá/cửa, nhạc kết một lần.
- Thêm 9 test có decode/hash/loop/âm lượng, bus, tín hiệu lặp, kiểm tra 6 giây theo clock thật và pause, ngưỡng cửa, khoảng lặng, skip đúng một nhịp, death/reset, missing bank, free player theo scene và không thêm bus. Fixture nghe riêng `res://audio/test/ch4_audio_test.tscn`.

### Kết quả kiểm tra

```text
pwsh tools/test.ps1 -Filter ch4_audio
RESULT: 9 passed, 0 failed
pwsh tools/test.ps1
RESULT: 610 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Các lượt PASS chạy Godot 4.7.2 ngoài sandbox: trong sandbox Godot báo không đọc được kho chứng chỉ Windows. `git diff --check` sạch; 132 file triển khai đều trong allowlist. Chưa nghe bằng tai, chưa chạy/chơi xuyên chương 4; không chạy bot dài. Các checkbox đã đánh dấu là mức **bank/rig/fixture**, chưa khẳng định tích hợp vào game thật.

### Bảng âm và âm lượng

Mức dưới là LUFS mục tiêu trước bus; đo OGG sai lệch ≤1 LU và peak ≤−2 dBTP. Gain runtime ≤0 dB. Chi tiết từng tên/mức đo, source report và API trong [audio_source/ch4/README.md](../../audio_source/ch4/README.md).

| Nhóm | LUFS mục tiêu | Bus / gain |
|---|---|---|
| Chuông / chạm sàn / pin hết | −42 / −41 / −49 | SFX, 3D 30 m |
| Đập / nứt / mảnh gỗ | −39 / −43 / −42 | SFX; đập −12→−2 dB, lớp −6 dB |
| Cửa vỡ / giảm hù | −33 / −44 | SFX, 0 dB |
| 9 clip scare | −38…−44 | SFX, 0 dB; giảm hù −10 dB |
| Thư viện / mưa | −54 / −56 | Ambience |
| StairCrowd T-186 | gốc −46/−43 | Ambience, −18 dB mỗi nguồn, tối đa 3 |
| Còi T-186 | gốc −57 | Ambience, −18→0 dB từ 8:30→9:00 |
| Cười PA / lời ký tên / y tá | −39 / −33 / −34 | Voice |
| Fade / tim / monitor | −49 / −47 / −49 | Music / SFX / SFX |
| Bước y tá / cửa viện | −46 / −46 | Footsteps / SFX |
| Nhạc thưa / viện / kết | −53 / −56 / −51 | Music |

### Còn dở, yêu cầu thay đổi ngoài phạm vi

- **Mục checklist giọng thoại giữ chưa đạt trọn vẹn:** đã có 7 clip, hai giọng nữ `vi+f1`/`vi+f3`, PA preset hiện có, nhạc kết và monitor chạy trong fixture. Tuy nhiên main cơ sở chưa có `SPK_CH4_*`, `NEAR_CH4_NURSE_*`, director/script CH4. Report voice ghi `core_keys=[]`; chưa thể kiểm chứng câu/khóa/phụ đề đúng nhịp game thật. Không tự đặt khóa hoặc viết nội dung mới.
- **Yêu cầu core/T-194:** cấp khóa thoại và nối `Ch4AudioRig.play_line(asset_id, at)` cùng subtitle/chờ thời lượng; gọi `play_pa_laugh(at)` đúng vòng 5. `pa_signed`, `nurse1_wake`, `nurse2_quake` tương ứng nguyên văn thiết kế. **Câu hỏi:** y tá 1 hay 2 đọc câu kết? Đã xuất `nurse1_all`/`nurse2_all` và `nurse1_alone`/`nurse2_alone`; core chọn một giọng theo thiết kế chốt, không phát cả hai.
- **Yêu cầu core/A/B:** instance đúng một rig làm con scene CH4, gán listener, các vị trí scare, StairCrowd và MonitorAudioMarker; đăng ký cửa 407/library_back/T-190, gửi fraction 0 khi hủy đập/mở cửa, gọi `play_door_burst(id)` nếu burst không đi qua fraction=1. Gọi area theo beat, bước/cửa y tá theo animation; tắt emitter chương trước để khoảng lặng thực sự chỉ còn âm yêu cầu. Nếu đổi hẳn scene campus→hospital, dựng rig hospital mới rồi gán marker/area. API/mẫu code đã có trong README; không tự sửa file ngoài lane.
- **Nhờ chủ dự án nghe duyệt** fixture F6: mũi tên chọn 36 asset, Space nghe lại, 0 reset; 1 chuông; 2 tăng damage; 3 thư viện; 4 crowd; 5 phòng407; 6 neck; 7 fade; 8 viện; 9 skip; E nhạc kết. Cần nghe độ nhỏ, độ xa chuông, cửa vỡ, phát âm Trần Trung, độ rõ/khác nhau của hai y tá và nhạc viện/kết. Chưa có xác nhận cảm nhận.
- **Blocked (tích hợp):** chờ khóa thoại/director/scene CH4 ngoài phạm vi Lane E. Phần bank/rig/test/fixture của Lane E đã xong và push; không có lỗi test hoặc chặn công cụ còn tồn tại.

## Review (integrator)
