# T-186 — Chương 3: tiếng xác sống, thanh sắt, thở dốc, ngoài trời, nhạc chương 3
- Lane: E (Âm thanh) | Trạng thái: done | Agent:
- Nhánh: `lane-e/T-186-ch3-audio`
- Phụ thuộc: T-164, T-175, T-178. **Đọc `docs/design/CH3_DESIGN.md`** (D-052, D-054).
- **Hạn đề xuất: hết ngày 2026-10-08.**

## Mục tiêu
Âm thanh cho chương ngoài trời đông xác. Chủ dự án **thích âm nhỏ**: tiếng nền khẽ, căng thẳng đến từ bước chân và tiếng lạ.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Hợp đồng có sẵn (core, không sửa). Đọc chú thích trong `event_bus.gd`, mục "Chapter 3"
- `zombie_woke`, `zombie_stunned`, `bar_picked`, `bar_swung(hit, hits_left)`, `bar_broken`, `stamina_changed(value, exhausted)`, `companion_state_changed`, `guard_warned`, `player_death_started(&"zombie_grab"|&"guard_shock")`, `scare_triggered`, `noise_emitted`.
- Lane A (T-182) cho node xác `Zombie`. Gắn rig âm thanh theo cách của T-175 (core gọi `new()` rồi gắn), ghi API vào Handoff.

## Yêu cầu
1. **Xác sống** (rig gắn vào từng xác, tối đa khoảng 40 xác; chỉ 6–8 xác gần nhất được phát âm):
   - gầm gừ khàn, thở rít khi săn, im khi ngủ;
   - bước chân lê;
   - tiếng **bầy** xa: một vòng lặp chung, to dần theo số xác đang săn;
   - tiếng đập cửa (cửa 407, 203).
2. **Thanh sắt:** vung (vút), trúng đầu (bịch nặng, không quá máu), trượt, tiếng cong kim loại khi gần gãy, tiếng gãy.
3. **Người chơi:** thở dốc theo `stamina_changed` (nặng dần, gấp khi cạn), tim đập khi cạn; bước chân chạy trên gạch, cỏ, bê tông.
4. **Môi trường ngoài trời:**
   - gió nhẹ, côn trùng tắt hẳn (thế giới chết);
   - xa xa thỉnh thoảng có tiếng hét;
   - **còi cứu hộ rất nhỏ** (manh mối động đất), chỉ nghe ở chỗ cao khán đài (`Clues/SirenSpot` của lane B), rất khẽ, dễ bỏ qua;
   - mỗi khu một nền riêng: sân vận động vang rộng, nhà ăn kín, cầu thang dội.
5. **Bảo vệ:** tiếng điện rè của dùi cui khi `guard_warned`.
6. **Nhạc chương 3** (theo kiểu `Ch2Music`):
   - nền căng khi chạy, dồn khi đợt xác tràn vào sân vận động;
   - lặng khi ở nhà ăn;
   - cuối chương một nốt dài.
7. **Cảnh chết:** `zombie_grab` (vồ, xé, cắn sát tai), `guard_shock` (điện giật, ngã). Có bản nhẹ cho "Giảm hù dọa".
8. **Âm lượng:** đo LUFS như các đợt trước; **giữ mức nhỏ**. Ghi "chưa nghe bằng tai" nếu chưa nghe.
9. **Test và cảnh nghe thử** `audio/test/ch3_audio_test.tscn`: phím cho từng nhóm âm; test giới hạn số xác phát âm, thở theo thể lực, còi chỉ ở chỗ cao.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] CREDITS ghi nguồn (tự tổng hợp hoặc CC0/CC-BY)
- [x] Handoff: rig, API, cách nghe thử, đã nghe hay chưa

## Handoff (agent điền)

### Bàn giao 2026-10-06 — Lane E

- Commit triển khai: `b47092a` — `T-186: add chapter three audio rigs and measured sound bank`; đã push lên `origin/lane-e/T-186-ch3-audio` cùng 70 object LFS trước khi điền Handoff này. Không push main, không sửa STATUS/core/gameplay/campus, không thêm plugin hoặc cài công cụ.
- Hoàn thành trong phạm vi Lane E: 35 âm tổng hợp CC0, raw + OGG + import/UID, pipeline tái tạo/đo LUFS, rig xác/bầy/thanh sắt/stamina/môi trường/còi/bảo vệ/nhạc, hai cảnh chết có bản nhẹ, bước cỏ/bê tông, preset vang và cảnh nghe thử. Giữ nguyên waveform chương cũ. Tổng raw+OGG 11.981.062 byte, file lớn nhất 864.044 byte; peak file lớn nhất −15,13 dBTP. Không tạo lời thoại/cốt truyện.
- Nguồn/tác giả/công cụ và AI-assisted đã ghi tại `game/audio/CREDITS.md`. Bảng LUFS từng file, API chi tiết, thông số và phím: [audio_source/ch3/README.md](../../audio_source/ch3/README.md). Hash/seed/peak/loop: `audio_source/ch3/build_report.json`.

### Rig và API chính

- Core tạo `.new()` và `add_child` trong scope chương 3. Gán tham chiếu/export trước add; gọi API sau ready. `stop_emitting()` trước dỡ scene là khóa vĩnh viễn của instance.
- Một `Ch3HordeAudio.listener = player`; `register(ZombieAudio)` cho mỗi xác. `voice_limit` mặc định 8, clamp runtime tối đa 8; có thể đặt 6. Chỉ các xác săn, eligible, gần nhất và dưới 60 m phát riêng. Mỗi xác tối đa 2 player (giọng + Foley bước/đập), cộng một loop bầy chung tăng gain theo `hunting_count/40`. Đã thử 40 node, chuyển listener, stun, occlusion flag, free, checkpoint/death.
- `ZombieAudio` là child từng Zombie, tự nhận woke/stunned theo identity. Gameplay gọi `set_hunting(false)` khi ngủ, `set_hunting(true)` khi hồi stun nếu không emit lại woke; `set_eligible(false)` khi khuất/cập nhật thưa; `play_step()` theo bước thực tế, `play_door_hit()` theo cú đập cửa 407/203. `hissing` chọn thở rít hoặc gầm; không có timer AI trong audio. Pool dùng `unregister`/`set_hunting(false)`, không dùng stop vĩnh viễn.
- `Ch3PlayerAudio` tự nhận stamina/bar; pant tăng mức/nhịp khi hụt thể lực, tim khi exhausted; hit/miss/cong còn 1–2 hit/gãy. **Không phát gameplay noise.** `FootstepPlayer.play_footstep(surface, intensity)` thêm grass/concrete, tile giữ bank cũ, đều qua Footsteps.
- `Ch3Environment.set_area(stairs/stadium/canteen/garden/road/gate)`; gán `insect_emitters` và `scream_points`. Côn trùng tắt cả khi chết/checkpoint; tiếng hét xa mỗi 30–55 s, không tự đoán vị trí map. `ReverbZone.Preset` thêm STADIUM/CANTEEN/STAIRS và giữ cơ chế fade/restore bus cũ.
- `Ch3SirenAudio.listener = player` root ở chân, `high_spot = campus.get_anchor("Clues/SirenSpot")`; `set_enabled(true)` trong vùng khán đài/sân, false khi rời. Điều kiện nghe: xz trong 2,5 m, y lệch ≤0,6 m so marker sàn cao, đứng yên ≤0,12 m/s. Không hardcode tọa độ campus; dưới khán đài, ở cao nơi khác hoặc đang đi đều im. Còi đo −56,96 LUFS. Reset/death/end tắt; core bật lại khi phù hợp.
- `Ch3GuardAudio` child mỗi guard, nhận đúng `guard_warned`; điện spatial ≤10 m. `Ch3Music.set_area`, `set_running`, `set_wave`; crossfade 1,5 s, nhà ăn im, `chapter_finished(3)` phát nốt kết một lần. Death/end khóa nguồn để signal muộn không bật lại; checkpoint nhận trạng thái mới từ core.
- Dùng lại **một `Ch1PlayerAudio` có sẵn** cho `zombie_grab`/`guard_shock`; thêm directory chương 3, dedupe, giảm hù dọa đổi sang bản nhẹ khi đang phát; không phát nhầm manager kill khi `player_caught(zombie/guard)` đến trước death.

### Kiểm tra đã chạy

```text
py -3 audio_source/ch3_process.py
CH3 RESULT: 35 assets validated; raw + OGG = 11981062 bytes

pwsh tools/test.ps1 -Filter ch3_audio
RESULT: 14 passed, 0 failed

pwsh tools/test.ps1
RESULT: 525 passed, 0 failed

pwsh tools/check.ps1
RESULT: check 0 error(s)
```

- `git diff --check`/staged diff sạch; toàn bộ thay đổi code/asset đúng phạm vi. Không đổi bus layout, không chạy bot chương 2 dài.
- Lần test mới đầu tiên: 12 assertion tests pass nhưng Godot báo resources còn giữ lúc thoát, nên **lần đó FAIL**. Đã thêm dừng nguồn/đợi audio thread trước free trong teardown fixture/test; bản cuối 14 test và toàn bộ 525 test PASS, không còn lỗi engine ở cuối.
- Bao phủ asset decode/hash/LUFS/loop, nearest/cap 8, nguồn xa/khuất/stun/free, pant/heartbeat/pause/recovery, bar không emit noise trùng, còi chỉ cao + đứng yên, tắt côn trùng qua chết/checkpoint, guard identity, hai death/reduced/signal order, canteen/end note, footsteps không lặp, restore reverb, thiếu bank và teardown cảnh nghe thử.

### Cách nghe thử; còn dở

- Chạy scene `res://audio/test/ch3_audio_test.tscn` bằng Godot. Đây là fixture nghe âm với 40 node giả, không phải campus/gameplay thật. Mũi tên/Space lần lượt nghe 35 clip; `1` bầy xác, `D` đập cửa; `2/M/B` bar hit/miss/gãy; `3/4/R` thể lực nửa/cạn/hồi; `T/Y/U` bước gạch/cỏ/bê tông; `5/F` gió/hét xa; `6/G` lên cao nghe còi/xuống đất kiểm tra im; `7` điện; `8/9/C/S/E` nhạc chạy/đợt sân/nhà ăn/cầu thang/nốt cuối; `Z/X` hai death; `0` reset, Esc thoát. Bật “Giảm hù dọa” trong cài đặt để so bản nhẹ. Chi tiết ở README.
- **Chưa nghe bằng tai, chưa duyệt cảm nhận hoặc loudness tổng mix; chưa playtest campus thật.** LUFS chỉ là phép đo file trước cộng nhiều nguồn/bus/khoảng cách. Các bài test dùng node giả và signal thật của EventBus.
- Không còn checklist chưa đạt trong phạm vi card. Việc gắn vào bản tích hợp và nghe duyệt vẫn chờ integrator/chủ dự án, không được coi là đã hoàn thành playtest.

### Yêu cầu thay đổi ngoài phạm vi

1. **Core:** gắn các rig/API trên vào chương 3, cấp lại area/running/wave/siren và trạng thái xác sau checkpoint; giữ một owner cảnh chết, tắt nhạc/nguồn chương cũ. Đã có đủ signal, không yêu cầu autoload/plugin/signal mới.
2. **Lane A:** nối nhịp bước, đập cửa, hồi stun, eligibility khi khuất/ticking thưa; surface grass/concrete/tile và trạng thái chạy thật. Tránh để `Ch1PlayerAudio` phát gasp cũ đồng thời pant chương 3 nếu nguồn noise vẫn dùng `breath` bán kính ≥4 m.
3. **Lane B/core:** gắn marker `Clues/SirenSpot` ở sàn cao nơi đứng nghe, volume gọi enable/disable còi, ReverbZone đúng khu; cung cấp điểm hét xa và danh sách emitter côn trùng cũ cần tắt. Kiểm tra trên bản đồ thật sau merge.
4. **Câu hỏi không chặn rig:** core có cần gọi cue theo ID `scare_triggered` cụ thể ngoài bước/đập cửa/death đã có không? Chưa có ID thống nhất trong hợp đồng nên Lane E không tự ánh xạ. `companion_state_changed` không được dùng để tự sinh lời thoại.

**Blocked:** Không có chặn kỹ thuật trong phạm vi Lane E. Tích hợp core/Lane A/B và nghe bằng tai còn chờ các bước ngoài phạm vi nêu trên.

### Review (integrator, 2026-10-06)
- **Đạt, đã merge.** 35 âm tự tổng hợp CC0, tối đa 8 xác phát tiếng, thở dốc theo thể lực, còi chỉ nghe ở chỗ cao khi đứng yên, cảnh chết có bản nhẹ.
- Yêu cầu cho lane A đã chép vào card T-182 (mục 10). Yêu cầu cho core (gắn rig, đặt khu, bật còi) làm trong T-181.
- Câu hỏi về `scare_triggered`: core sẽ phát ID jumpscare theo `CH3_DESIGN.md` (ví dụ `&"roommates_rise"`, `&"stadium_lights"`) và ghi danh sách vào Handoff T-181; lane E nối sau nếu cần âm riêng.
- **Còn mở:** nghe bằng tai (chủ dự án hoặc integrator).
