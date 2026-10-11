# T-212 — Âm thanh theo model mới và chuông báo cháy

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](../handoff/T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

> **D-080, 11/10:** chuyển sang **Tripo AI**; giữ G0 đã ghép và task/nhánh hiện có. Đọc [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md). Handoff/checklist G0 bên dưới là lịch sử; chưa có Tripo asset hoặc client live.

- Lane: F | Trạng thái: **G0 đã review/ghép (D-079); G1 tiếp tục, toàn gói chưa done** | Agent: lane F, tài khoản GPT Plus mới do chủ dự án chỉ định (D-078)
- Nhánh: `lane-f/T-212-graphics-audio-anchors`, từ `origin/main` có D-078; workspace riêng `D:\GAME_WORK\lane-f`.
- Phụ thuộc: D-076/D-077/D-078; G0 độc lập, marker G1 với A/B/web, nối core sau T-207/T-209.
- Hạn đề xuất: phiên đầu có khảo sát marker và mẫu chuông nhỏ để nghe; đồng bộ từng đợt model sau.

## Bối cảnh
Lane E tạm nghỉ vô thời hạn. F nhận nguyên task T-212 và toàn bộ trách nhiệm âm thanh trước đây của E theo D-078; không đổi mã task hoặc tạo bản song song. Đọc `docs/handoff/lane-f.md` để tiếp nhận pipeline và phần nghe thử còn mở. Không ghi đè workspace/nhánh E hoặc đổi tên tác giả trong credits cũ.

Chuông tầng 1 D-075 đang dùng `res://audio/ch1v2/lock_alarm.ogg`, SFX, -4 dB; core giữ thời lượng và sự kiện kéo xác. Người dùng thích âm thanh nhỏ. Quản lý có `BladeTip`; nguồn tiếng gần đầu/tay có thể lệch khi đổi rig. Giọng thoại hiện có đã duyệt, nhiều phần còn chờ nghe bằng tai.

## Việc
1. **G0:** kiểm các nguồn âm bám nhân vật/đồ vật: đầu/miệng, dao, bước chân, cửa, bình cứu hỏa, chuông. Ghi NodePath/marker/event/timing và owner vào Handoff để web đưa vào contract; không tạo cơ chế noise AI mới từ animation.
2. Làm mẫu chuông báo cháy riêng nhỏ, có nguồn/license rõ (CC0/CC-BY hoặc âm tự tạo khai báo phù hợp), dưới `game/audio/graphics_upgrade/` và nguồn ở `audio_source/`. Tạo fixture nghe trong vùng F, cung cấp đường dẫn stream và cách loop/stop. Không tự sửa hằng `FIRE_BELL_STREAM` trong core.
3. **Sau G1:** hỗ trợ marker mới do A/B cung cấp, nguồn âm đi theo model khi di chuyển/animation, không nhân đôi tiếng từ clip và code. Giữ semantics sự kiện, bán kính nghe AI và timing luật; đề xuất đổi âm lượng để người dùng nghe riêng.
4. **G2/G3:** kiểm vật liệu mới với tiếng cửa/kim loại/vải/bước chân bằng asset hiện có, chỉ bổ sung khi thiếu thật. Kiểm ngắt tiếng khi pause/chết/reload và cảnh chuyển. Không thu lại hoặc sửa lời thoại đã duyệt trong task này.
5. Lập danh sách nghe thử: chuông tầng 1, dao/người quản lý, tiếng bình chữa cháy, giọng/tiếng xác và cảnh phòng mẫu. Chủ dự án nghe rồi mới ghi đạt cảm nhận âm lượng.

## Được phép sửa
Vùng F (toàn bộ vùng âm thanh cũ của E): `audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`; Handoff/checklist card. Không sửa core, model/scene B, gameplay A, settings hoặc strings thoại. Gửi yêu cầu wiring cho T-207, marker cho A/B.

## Test và bằng chứng
- Stream load/decode, loop/stop/pause và dọn player đúng; không nguồn trùng khi reload hoặc thay visual. Marker mất phải báo/fallback theo contract, không phát ở gốc thế giới vô tình.
- Fixture giúp nghe, nhưng chỉ cảnh thật sau ghép mới chứng minh chuông phát đúng nơi và chỉ chương 3. Kiểm phối hợp core: 20 giây theo D-075, sự kiện mồi không phát đôi.
- `pwsh tools/test.ps1`, `pwsh tools/check.ps1` đầy đủ; ghi rõ “chưa ai nghe” khi mới kiểm tự động. Không đổi âm lượng toàn game để bù một sample.

## Checklist hoàn thành
- [x] G0: bảng marker/event và mẫu chuông có nguồn
- [ ] G1: thống nhất attachment/timing
- [ ] Nối model mới qua đúng owner, không tiếng/sự kiện trùng
- [x] Test/check PASS và checklist nghe thật (G0; nghe nghiệm thu vẫn chờ)
- [ ] Người dùng nghe xác nhận; phần chưa nghe vẫn ghi chờ

## Handoff (agent điền)
### Lane F — 10–11/10/2026, bàn giao G0 để review G1

**Chỉ hoàn thành đầu ra chuẩn bị G0, chưa done T-212.** Workspace mới `D:\GAME_WORK\lane-f`, clone đúng repo; status sạch sau clone, đã fetch. Nhánh `lane-f/T-212-graphics-audio-anchors` tạo từ `origin/main` **`e3ed54a` có D-078**. Không có remote nhánh `*T-212*` tại lượt fetch đầu, nên không phát hiện thay đổi T-212 của E cần review. Không truy cập/sao chép workspace E; credits cũ giữ nguyên. Đã đọc tiếp nhận T-198/T-200/T-205; yêu cầu restored ở kết chương 4 đã được integrator giải quyết theo Review T-200, không mở lại lỗi cũ.

### Đầu ra cụ thể

- `game/audio/graphics_upgrade/fire_bell_soft.ogg`: mẫu riêng tự tổng hợp CC0, mono 48 kHz, 4 giây, import **loop=false**; SFX/gain −4 dB chỉ áp dụng trong fixture. Chưa sửa `FIRE_BELL_STREAM` hoặc bus/settings.
- `audio_source/graphics_upgrade/fire_bell_process.py`, `raw/fire_bell_soft.wav`, `build_report.json`: nguồn tái tạo, hash và số đo. OGG **−35,97 LUFS**, peak **−22,14 dBTP**, chênh biên **0,0015163**, **17.756 byte**; raw **384.044 byte**. Chuông cũ target −30 LUFS, ứng viên mới target −36; mức thích hợp ở tai còn chờ nghe, không đổi gain toàn game.
- `game/audio/graphics_upgrade/CREDITS.md`: nguồn/CC0 và OpenAI Codex/Python/FFmpeg cho đóng góp mới F; không gán lại asset/helper của E cho F.
- `game/audio/graphics_upgrade/fire_bell_preview.tscn` + `.gd`: bắt đầu im lặng, so sánh mẫu/cũ cùng vị trí, loop bản sao, pause/stop/reload, deadline nghe 20 giây độc lập. Hướng dẫn chi tiết và danh sách nghe tại `audio_source/graphics_upgrade/README.md`.
- `game/tests/audio/test_graphics_fire_bell.gd`: kiểm decode/hash, không đổi loop tài nguyên dùng chung, loop qua cuối clip, pause/stop/dọn nguồn và deadline. Chưa lấy kiểm tự động thay nghe thật.

### Khảo sát marker/event/timing hiện hành — căn cứ `e3ed54a`

Các đường tương đối trong bảng tính từ root được nêu, không phải API mới. Tọa độ/chuyển động ghi từ source, chưa đo cảnh render/model mới. Owner F giữ player/stream; A/B cung cấp attachment và core nối sự kiện theo phân công.

| Nguồn | NodePath/marker và vị trí hiện có | Event/timing cần giữ | Owner / đầu vào cần G1 |
|---|---|---|---|
| Quản lý: nói, bước, chém/gõ | `manager.gd::_sync_audio()` đặt `audio_rig` tại root quản lý; `ManagerAudio` tạo `Speech`, `Step`, `Knock`, `Slash`, `Kill` tại local zero. **Speech hiện chưa bám đầu/miệng**. Rig có thể được cấp qua export/group `manager_audio`, hoặc instance `audio/entities/manager_audio.tscn` dưới quản lý. | A gọi `say`, `play_step`, `play_slash`; bước theo quãng đường **0,7 m** khi chạm sàn; chém theo vòng `_tick_slash`, không theo nhát animation mới; lời theo độ dài clip +0,4 s. | A giữ cadence/state, B cung cấp đầu/tay/chân; core/web chốt cách resolve marker, F gắn nguồn sau G1. |
| Kéo dao quản lý | `audio_rig/Drag`; model tìm `BladeTip`, fallback `Visual/Fallback/BladePivot/BladeTip` (local **0, −1,15, 0** tính từ BladePivot). `_sync_audio` cập nhật world position của Drag. | `play_drag(moved > 0.0001 and is_on_floor())`, stop ở trạng thái/cảnh hiện có; không thêm nhát từ clip. | A giữ mapping BladeTip/fallback; B marker dao trên rig mới; F chỉ áp attachment đã chốt. |
| Miệng xác chương 2 | `Floor4/Room407/Anchors/Gag1`, `Gag2`, `Gag4`; core tạo con `CorpseVoice/Voice` và `Body`. `ch2/gag_anchor.gd` dùng `../CorpseN/Body/Rig/Hips/Chest/Head`, offset local **(0, 0,005, −0,14)**, priority 10 cập nhật mỗi frame. | `chain_word_spoken`, `chain_turn_started`, `corpse_state_changed`; bịt miệng/mumble cắt/lọc giọng theo state. Reset chapter/checkpoint/death hiện có; không đổi lời. | B/A bảo toàn marker miệng khi pose/rig đổi. Marker mất hiện giữ transform cũ, chưa báo; cần contract xử lý lỗi. |
| Foley xác chương 1 | `Floor4/Room407/Anchors/Corpse{1,2,4}/Body/CorpseAudio`, core gán `UnseenPoser`; `RoomDrips` riêng tại world **(32, 0,3, −3)**. | `CorpseAudio`/poser và phase hiện có; không thêm trigger từ animation. | B cung cấp vị trí thân/giường; core nối khi thay model; F giữ asset/tín hiệu cũ. |
| Xác di chuyển chương 3/4 | Core `_dress` thêm `ZombieAudio` và `AudioLink` dưới từng Zombie; Voice/Foley hiện tại local zero của rig, chưa resolve đầu/chân. `head_position()` của A là API gameplay, không tự coi thành API audio mới. | `Ch3ZombieLink.STRIDE = 0.8 m`; `zombie_woke/stunned`, hunting/eligible; horde giữ giới hạn tối đa 8 nguồn gần trong 60 m. `play_door_hit()` do core gọi theo tiến trình đập, khoảng 0,7 s. | A/B chốt đầu/chân/tay; core giữ link/horde và hồi phục stun, F không thêm clock AI. |
| Bước chân người chơi | `Player/Footsteps` trong `chapter1…4.tscn`, player phát signal `footstep(surface, intensity)` tới `FootstepPlayer.play_footstep`; tại root Player. | `player.gd::_update_steps_and_bob` theo chuyển động, noise **1,5/5/12 m** cúi/đi/chạy do A phát; không phát noise từ F/animation. Bus Footsteps → SFX. | A giữ cadence/surface/intensity; B giữ metadata vật liệu; không bắt buộc gắn rig chân cho người chơi ngôi thứ nhất. |
| Cửa 407/cửa phòng | B: cửa 407 có `Pivot/HandlePivot`; `RoomDoor` có `Hinge`, chuyển 0,3 s. `Ch4AudioRig.register_door(id, anchor)` tạo rig và cập nhật theo world position anchor, `Ch4DoorAudio` phát các lớp SFX; core đăng ký `407`/`library_back` và cửa đã nối. Cửa mở thường không thấy tự gọi bank `wood_door_open/close` trong script B đã khảo sát. | `door_damage_changed(id, fraction)`; đập **0,7 s**, lớp nứt/mảnh/gầm theo fraction **0,3/0,6/0,8**, burst một lần ở 1; 0 reset. Không phát thêm ở cả code và clip. | B chốt marker trên cánh/tay nắm; core/A giữ open/damage; F tái dùng bank gỗ/kim loại/vải sau G2 nếu phù hợp. |
| Bình cứu hỏa tầng 2 | `Campus/Anchors/Extinguisher2F`, local **(48,83, −5,5, 2,4)** trong campus. Core `_use` tạo Ch3Use ở anchor; chưa thấy SFX riêng nhận source `extinguisher`. Listener `_on_noise` của `Ch1PlayerAudio` chỉ xử lý breath. | `used` → flag `ch3_alarm` → `noise_emitted(position, 25.0, &"extinguisher")` và `_pull_crowd_203`; chỉ một sự kiện gameplay. | B marker va chạm bình; core quyết định caller SFX, không nhân đôi noise. F đề nghị nghe thử âm kim loại có sẵn sau khi core chốt ngữ cảnh; G0 không tự thêm API. |
| Nút báo cháy và chuông tầng 1 | `Campus/Anchors/FireAlarm1F` do core tạo lúc chạy, **khác vị trí nguồn chuông**. Core tạo `Chapter3Director/FireBell` tại `FIRE_BELL_AT + (0,2.2,-1.8)` = world **(42, −7,7, 0,2)**. `FIRE_BELL_AT` là **(42, −9,9, 2)**. | Chỉ `_chapter()==3`, `_bell_rung` chặn dùng lặp; một noise **45 m** ở FIRE_BELL_AT và một lần kéo crowd; thời lượng hằng **20 s**; hiện `play()`/`await finished` theo wall clock, SFX −4 dB, unit_size 8. | B cung cấp marker treo chuông riêng, core giữ vị trí AI và timing; F cấp stream, không phát ở nút bấm và không tự sửa core. |

Căn cứ source bổ sung: `game/scripts/audio/{manager_audio,corpse_voice,corpse_audio,zombie_audio,ch3_horde_audio,ch4_door_audio,ch4_audio_rig}.gd`, `game/scripts/core/{chapter2_director,chapter3_director,ch3_zombie_link}.gd`, `game/scripts/entity/manager.gd`, `game/scripts/player/player.gd`, `game/scenes/levels/ch2/gag_anchor.gd`, `game/scenes/levels/room407/room407_anchors.tscn`, `game/scenes/levels/campus/campus.tscn`. Chưa sửa bất kỳ file nguồn cũ nào trong danh sách này.

### Yêu cầu ngoài phạm vi gửi Astra / web T-207 / A / B

1. **Web/core G1:** chốt danh sách attachment, root tính NodePath, owner cập nhật transform sau pose, và xử lý marker thiếu. Đề nghị báo rõ asset/marker thiếu một lần và tắt nguồn; fallback chỉ về marker/root đã được contract cho phép, không vô tình phát world origin. Đây là đề xuất, chưa thêm API hoặc tự chọn tên marker mới.
2. **A/B:** chốt đầu/miệng, BladeTip, bước chân, tay/điểm va cửa/bình; chuông có marker treo riêng với nút FireAlarm1F. Đảm bảo một caller cho mỗi tiếng, giữ AI noise và clock trong code gameplay.
3. **Core:** review `_ring_bell()` trước đổi stream: asset mặc định không loop để không kẹt `await finished`. Nếu chọn loop phải có stop/deadline độc lập; kiểm pause/chết/reload và giới hạn 20 giây trong cảnh thật. Vòng chờ hiện chỉ xét hết hạn/chết giữa clip, có thể vượt mốc/cắt trễ; không coi fixture là đã sửa lỗi này. Giữ chapter 3 only và một sự kiện noise.
4. **Core/B + F sau G1:** xác nhận thiếu SFX bình chữa cháy và caller/marker chính thức trước khi bổ sung; không dùng sự kiện AI làm lý do tự đổi cơ chế. Chủ dự án nghe ứng viên chuông trước khi chốt gain/stream.
5. **Lượt Windows:** integrator đã bàn giao lượt F ngày 11/10; kiểm danh sách tiến trình lúc 03:37 (UTC+7), không có Godot lane khác. Đã chạy tuần tự full test rồi full check; cả hai đạt. Kiểm lại lúc 04:11:38 không còn Godot. **F đã nhả lượt Godot.** Không render/FPS/bot.

### Kiểm tra / RESULT / phần chưa đạt

```text
py -3 audio_source/graphics_upgrade/fire_bell_process.py
RESULT: fire bell signal validation PASS; listening pending
RESULT: deterministic WAV/OGG rebuild PASS (hai lượt, SHA256 giống nhau)
RESULT: Python syntax PASS
git diff --check
RESULT: PASS

pwsh tools/test.ps1
RESULT: 725 passed, 0 failed (exit 0)
pwsh tools/check.ps1
RESULT: check 0 error(s) (exit 0; 336 script parse PASS)
```

Ba test Godot mới đều PASS; đã giữ metadata `.uid`/`.import` do Godot sinh. Lượt full test đầu 03:37–03:44 phát hiện thiếu OGG mới trong kiểm kê `test_audio.gd`; dừng riêng lượt F, thêm đúng file vào danh sách (không bỏ assertion), rồi chạy lại full suite từ đầu khoảng 03:44–04:04. Full check chạy sau đó 04:04–04:11, ngày 11/10/2026 UTC+7. Log cục bộ: `build/t212-g0/first-test-interrupted.log`, `full-test.log`, `full-check.log`; lượt đầu không có kết quả full PASS. Loại diff tự định dạng lại `default_bus_layout.tres` của import, giữ bus gốc. **Chưa ai nghe mẫu mới; còn chờ nghe thật.** Chưa kiểm cảnh thật, model/rig mới, missing-marker fallback, pause/chết/reload chuông production, chương 3 only sau ghép; chưa có G1/G2 được ghép. Không chạy FPS/bot, không Meshy/credit/plugin, không đổi luật/timing/lời thoại.

**Commit G0:** `T-212: prepare audio anchor survey and fire bell audition` (commit chứa Handoff này). Nhánh bàn giao/push `lane-f/T-212-graphics-audio-anchors`, base `e3ed54a`; chỉ thay vùng audio và Handoff/checklist card. Không push main, không mở PR. **Blocked:** không còn chặn kiểm tra G0. Phần nối phụ thuộc G1 được ghép main, còn chờ nghe thật; không tự triển khai G2/G3, không ghi toàn bộ T-212 done.

### Lane F — phản hồi Review G0 và D-080, 11/10/2026

**Đã fetch/rebase sạch lên `origin/main` `acbf771` có D-080**, giữ nhánh `lane-f/T-212-graphics-audio-anchors`. Trước rebase working tree sạch, không có thay đổi cục bộ cần stash. G0 `2dcd25a` đã được ghép cùng các lane; không tạo lại âm/fixture, không đổi mã task. Đã đọc bàn giao Tripo, Review G0 chung, Review T-212 và contract/bindings trên main. Đây là phản hồi tài liệu cho Astra/A/B tổng hợp G1, **không phải xác nhận G1 đã chốt**.

**D-080:** nhận hướng Tripo Studio thủ công → GLB → Blender → Godot. F nhận attachment trên model đã được B chuẩn hóa, không tiêu thụ GLB/rig thô theo suy đoán tên bone. Studio/API tách ví; không có ngân sách/key/ngoại lệ license được cấp. Không dùng API, không tạo tác vụ trả phí, không cài plugin/MCP. Asset âm CC0 của F và nguồn/credits lịch sử của E giữ nguyên, không đổi tác giả sang Tripo. Balo tĩnh không phải chờ chuông/rig âm thanh để chốt G1 riêng.

**Đầu mối hiện hành theo thông báo chủ dự án:** Astra điều phối (Integrator) đã nhận T-207 thay Claude web. Mọi yêu cầu core/hợp đồng kỹ thuật của F dưới đây gửi Astra; các tên web trong Handoff G0/Review cũ là lịch sử, không còn là tuyến giao việc hiện tại.

#### Xác nhận attachment gửi Astra T-207, A T-208, B T-209

| Mục | F xác nhận để tổng hợp | Còn cần owner bàn giao trước khi F dùng |
|---|---|---|
| Mount chuông | Đồng ý tên **dự kiến** `Campus/Anchors/FireBellMount`; nguồn âm world **(42.0, -7.7, 0.2)**. Giữ riêng mồi/noise tại **(42.0, -9.9, 2.0)**, bán kính 45 m. Tọa độ world không được ghi thẳng thành local nếu root campus đổi transform. | B kiểm mặt tường, basis, kích thước trong renderer rồi giao scene/NodePath; Astra (integrator/core) ghép contract. Đối chiếu source `acbf771`: `campus.tscn` chưa có node này; F chưa coi mount là dependency tồn tại. |
| Nút bấm | `FireAlarm1F` vẫn do core tạo **chỉ chương 3**. Chuông không phát tại nút bấm, không phát noise theo từng nhát âm. | B giao visual riêng, core instance; không thêm nút tương tác sẵn vào campus dùng chung chương 4. |
| Dao quản lý | Giữ `_sync_audio()` do A quản lý: `Drag` theo `BladeTip`; các nguồn khác hiện tại theo body/root. Không biến marker phát âm thành điểm nghe AI. | B/A giao đường dẫn BladeTip tường minh và thứ tự cập nhật sau animation; xử lý model bị thay/xóa trong cùng frame, tránh cache node cũ. F không tự chuyển Speech sang Head trước G1. |
| Xác/miệng | **Gag1/2/4 hiện bám Head mỗi frame**, priority 10, offset `(0, 0.005, -0.14)` qua `gag_anchor.gd`; `CorpseVoice` và `GagSpot` dưới anchor cũng đi theo. Giữ cơ chế này, không tạo thêm một nguồn theo Mouth. | B/A giữ nguồn Head đã cập nhật, phân quyền transform giữa procedural và animation; Astra xác định binding cho cả 3 xác 407 và 3 xác CCTV 310, không suy rằng mỗi xác CCTV có cùng rig audio. |
| Đầu/chân/thân nhân vật | F đọc attachment đã thống nhất; cadence bước, trạng thái, limiter horde và timer vẫn thuộc caller hiện hành. Không phát âm hoặc sự kiện AI lần hai từ animation. | A/B chốt Head/pose/lifecycle và fallback, gồm warn/quay đầu guard, UnseenPoser, door_burst. Chưa có API consumer mới để F nối. |
| Marker thiếu hoặc model bị thay | Theo hướng Review: giữ model/hành vi cũ và báo thiếu, không vô tình phát tại world origin; chỉ dùng fallback đã được contract chấp nhận. | Astra/A/B chốt đường fallback cụ thể và owner cảnh báo một lần. F không thêm fallback mới hoặc đoán attachment. |

#### Stream và deadline W2 gửi Astra/core

- Ứng viên tiếp tục là `res://audio/graphics_upgrade/fire_bell_soft.ogg`, **4.0 s, mono 48 kHz, `loop=false`**, −35.97 LUFS; không sửa OGG/import/gain từ G0. SHA256 `5784f0c25de27f719444760f13eaa5d4435263c3bf826d89287488a8b70abcf4`. Stream production vẫn `res://audio/ch1v2/lock_alarm.ogg` (1.5 s), SFX −4 dB, unit_size 8 m.
- F đồng ý yêu cầu **W2 dùng deadline 20 giây độc lập `finished`**; clip finite có thể phát lại, clip loop phải bị stop bằng deadline/lifecycle của core. Không sửa shared resource để bật loop; nếu cần thì dùng bản sao riêng. Không thêm timer gameplay ở rig F và không phát lại noise từ audio.
- **Chưa chốt cách tính thời gian khi pause:** core hiện dùng `Time.get_ticks_msec()` và chỉ kiểm lại sau `finished`; fixture F dùng 20 giây hoạt động, pause dừng Timer. Hai cách này không được coi là tương đương. Astra (integrator/core) cần ghi semantics pause trong G1 trước wiring W2; F không lấy hành vi fixture làm quyết định thiết kế production.
- Death/reset/unload phải hủy player và mọi lịch phát lại, không để callback cũ tạo âm sau reload; bấm lần hai không có nguồn hoặc mồi thứ hai. Đây là điều kiện kiểm W2 của core sau contract, chưa phải kết quả đã đạt.

| Ca kiểm cần có khi W2 được phép nối | Bằng chứng cần từ core / F phối hợp |
|---|---|
| Stream cũ finite 1.5 s, mẫu F finite 4 s, bản sao bật loop | Đều bị cắt bởi deadline 20 s, không đợi clip kết thúc để vượt hạn; báo thời điểm thực và sai số frame đo được. |
| Pause trước hạn rồi resume | Âm pause đúng; đồng hồ theo semantics đã được integrator chốt, không suy từ fixture. |
| Chết/reset/reload/chuyển cảnh giữa clip | Không còn player/lịch phát lại; không nguồn trùng sau dựng lại. |
| Bấm lặp/chương 4 | Một noise 45 m và một nguồn cho lượt hợp lệ chương 3; chương 4 không được dựng nút chỉ vì campus có visual/mount. |
| Mount bị bỏ/đổi tên; model thay cùng frame | Cảnh báo/fallback đúng contract, không phát tại gốc thế giới hoặc giữ attachment đã free. |

#### Nghe mẫu hiện có — chỉ chạy trong lượt Godot được bàn giao

Từ `D:\GAME_WORK\lane-f` (không tự mở fixture trong phiên tài liệu này):

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/graphics_upgrade/fire_bell_preview.tscn --windowed --resolution 960x540
```

Mở cảnh im lặng. `1` mẫu mới một lượt; `2` loop để nghe ít nhất 60 giây; `3` âm cũ; `4` deadline fixture 20 giây; `P` pause/resume; `0` stop; `R` reload; `Esc` thoát. Nguồn mặc định trước listener 8 m; lên/xuống thử 2/20 m, trái/phải thử hướng, `C` về giữa 8 m. Hướng dẫn đầy đủ: `audio_source/graphics_upgrade/README.md`. **Chưa được chủ dự án nghe; chưa nghiệm thu chất âm/âm lượng hoặc mix cảnh thật.**

#### Kiểm tra và trạng thái bàn giao sau D-080

- Đợt này chỉ thêm phản hồi trong Handoff T-212; không sửa Review/STATUS/DECISIONS, runtime, audio asset hoặc scene.
- Đối chiếu với G0 `2dcd25a`: toàn bộ `audio_source/graphics_upgrade/`, `game/audio/graphics_upgrade/` và test fixture giữ nguyên; SHA256 ứng viên khớp report, import vẫn finite. Không chạy lại generator.
- `git diff --check`: PASS. Full `pwsh tools/test.ps1` / `pwsh tools/check.ps1`: **NOT RUN cho phản hồi mới — chờ integrator bàn giao lượt Windows**. Không lấy 725/0 G0 hoặc 743/0 trong commit D-080 của integrator làm kết quả của phiên F này. Không render/FPS/bot.
- Commit/push phản hồi mới: chưa thực hiện, chờ full test/check trước commit. Nhánh giữ `lane-f/T-212-graphics-audio-anchors`, base mới `acbf771`. Đã gửi yêu cầu xếp lượt; F hiện không giữ tiến trình/lượt Godot.
- **Chờ:** B xác nhận mount/render; A/B chốt attachment/lifecycle; Astra (integrator/core) ghép G1 và chốt pause W2; chủ dự án nghe. Không bị chặn do chưa có Tripo API. G1 đạo cụ tĩnh có thể tiếp tục độc lập; T-212 chưa done.

### Lane F — đối chiếu D-081 và nhận lượt Windows, 11/10/2026

**Bản cập nhật này thay trạng thái chờ lượt ở phản hồi D-080 phía trên.** Đã bảo toàn Handoff chưa commit bằng stash `T-212: preserve pending D-080 handoff before D-081 rebase`, fetch và rebase sạch lên `origin/main` **`d6d76f3`**; apply stash không xung đột. Giữ nhánh T-212 và G0 đã nhận; không tạo lại âm/fixture. Đã đọc `T207_G1_ASTRA_2026-10-11.md`, contract đặc biệt **§4–5**, và Review D-081 trong card. Astra là đầu mối core/T-207; Review và lịch sử tác giả giữ nguyên.

#### Đối chiếu contract và đề xuất fallback cụ thể gửi Astra/A/B

| Điểm | F xác nhận theo D-081 | F đề xuất cho dependency còn thiếu — chưa triển khai |
|---|---|---|
| Head/Gag (§4) | Head phải cập nhật trước consumer âm/hitbox/LOS/camera đọc; Gag đang theo Head mỗi frame, không là tọa độ cố định. Giữ pick volume/offset, pose/state riêng và scope xác 407/CCTV 310. | B/A công bố NodePath và thứ tự cập nhật khi animation/procedural cùng chạy. Nếu model mới thiếu Head bắt buộc, QA phải FAIL; ưu tiên giữ model cũ còn hợp lệ. Nếu cả attachment cũ không còn hợp lệ, dừng nguồn phụ thuộc attachment và cảnh báo một lần theo đối tượng/marker; không nhận root tùy ý làm miệng. Astra/A/B chốt owner fallback trước nối. |
| Dao quản lý (§4) | Chỉ `Drag` theo `BladeTip`; Speech và các kênh hiện ở body/root không được tự chuyển sang Head. Giữ cadence/noise và caller A. | A ưu tiên tip hợp lệ của model; khi thiếu dùng marker sẵn có `Visual/Fallback/BladePivot/BladeTip` nếu node còn hợp lệ. Nếu cả hai thiếu, dừng riêng Drag và báo thiếu, không phát tại world origin. A quản lý resolve lại khi thay model; F không tự cache bone hoặc tạo marker khác. |
| Voice/Foley zombie (§4) | Giữ nguồn tại root ZombieAudio như hiện hành. Đây là binding có chủ đích, không phải fallback cho miệng/đầu. | Nếu rig bị gỡ hoặc model đổi trong frame, A/core quản lý lifecycle và một rig hợp lệ; F không nối hai nguồn cũ/mới hoặc chuyển âm sang Head khi chưa có dependency. |
| FireBellMount (§5) | Tên **dự kiến** `Campus/Anchors/FireBellMount`, world `(42,-7.7,0.2)`; phải qua B kiểm mặt tường/basis/kích thước bằng renderer. Marker chưa thành dependency được duyệt chỉ từ tên trong contract. | Đề nghị Astra giữ vị trí nguồn âm hằng hiện hành `(42,-7.7,0.2)` làm fallback tương thích nếu marker vắng; báo một lần, QA marker vẫn FAIL khi đã trở thành bắt buộc. Đây là đề xuất chờ Astra/B, không tự áp code hoặc lấy `(0,0,0)`. |
| Nút và mồi (§5) | Core tạo nút chỉ chương 3 tại `(0.9,-8.5,0.12)`, vùng dùng `(0.5,0.6,0.5)`; B cấp visual riêng. Noise một lần tại `(42,-9.9,2)`, 45 m, không đổi nơi kéo crowd. | W1/core do Astra nối sau visual B; không gắn nút tương tác sẵn vào campus chung chương 4. Nguồn âm/marker không được phát lại noise. |
| Stream và W2 (§5, §8) | Giữ file F 4 s finite, `loop=false`, source/hash/license G0. Chưa được nghe/duyệt, chưa thay `FIRE_BELL_STREAM`. Deadline 20 s độc lập `finished`, dọn khi chết/reset. | W2 còn cần **stream được duyệt + mount B + contract vòng đời**. Contract mới chưa ghi pause tiêu hao wall time hay chỉ thời gian hoạt động; Astra cần chốt và kiểm. Fixture pause Timer không là quyết định production. Ma trận finite/loop/pause/death/reset ở phản hồi trên tiếp tục là đầu vào kiểm W2. |

F đồng ý các ràng buộc §4–5; **các đề xuất fallback trên không tự trở thành API/contract đã duyệt**. Giữ fallback đang có đến khi Astra/A/B chốt; không dùng fallback để cho asset thiếu marker vượt QA. Không cần thay code/asset F trong lượt đối chiếu này. G1 balo theo §2–3 tiến hành độc lập, không chờ chuông/rig/settings.

**Yêu cầu gửi Astra:** chốt semantics pause W2 và owner cắt/hủy player khi death/reset/reload; review fallback mount/BladeTip/Head cùng A/B; chỉ mở W2 sau đủ ba dependency §8. F cung cấp stream finite và lệnh nghe ở Handoff trên, chờ chủ dự án nghe thật. Tripo tiếp tục Studio thủ công → GLB → Blender → Godot; không chi credit, không dùng API/key hoặc cài plugin/MCP trong phần âm thanh.

#### Lượt kiểm mới và bàn giao

- Integrator đã bàn giao lượt Windows cho F sau D. Trước rebase đã kiểm tiến trình: không còn Godot lane khác. Chạy tuần tự full `pwsh tools/test.ps1` rồi `pwsh tools/check.ps1` sau cập nhật; không render/FPS/bot, không mở fixture nghe trong lượt này.
- **Kết quả mới trên base D-081, 11/10/2026 (UTC+7):** `pwsh tools/test.ps1` → **RESULT: 743 passed, 0 failed**, exit 0; 14:53:02–15:13:57. Sau đó `pwsh tools/check.ps1` → **RESULT: check 0 error(s)**, exit 0, **344 script parse PASS**; 15:14:08–15:21:37. Log cục bộ `build/t212-d081/full-test.log`, `build/t212-d081/full-check.log`. Không lấy kết quả G0/D-080 thay lượt này. `git diff --check` PASS; diff mới chỉ trong Handoff T-212, không sửa Review hoặc code/asset.
- **Commit phản hồi:** `T-212: align audio handoff with D-081 contract` (commit chứa mục này), nhánh bàn giao/push `lane-f/T-212-graphics-audio-anchors`, base `d6d76f3`. Nội dung Handoff chưa commit từ trước đã được giữ và ghép vào bản này; stash bảo toàn vẫn được giữ để đối chiếu. Không push main hoặc mở PR. **Không còn chặn kiểm tra/bàn giao tài liệu.** T-212 chưa done; còn dependency A/B/Astra và nghe thật. Kiểm tiến trình lúc 15:21:38 không còn Godot: **F đã nhả lượt Godot.**

## Review (integrator)

### 11/10/2026 — Astra, D-079

- Nhận **G0** từ lane F, commit `2dcd25a`; ghép cùng năm nhánh còn lại. **Chưa đánh dấu toàn bộ T-212 done.**
- Nhận âm CC0 tổng hợp, preview im khi mở và 3 test; không thay stream production. Giữ loop=false vì core hiện await finished; deadline W2 thuộc web sau G1. Nguồn âm và mồi AI là hai vị trí khác nhau. Chưa được người dùng nghe, chưa nghiệm thu âm thanh cuối.
- Phạm vi diff đạt; không nới test, không đổi gameplay/default. Không sửa code lane trong lượt review này.
- Full Windows test/check bản ghép và kiểm `--t202-integration` là điều kiện trước commit. Kết quả thực/thời điểm/log ở message commit `D-079`; không dùng số test lane riêng thay kết quả tích hợp.
- Đọc [báo cáo chung và yêu cầu G1](../handoff/REVIEW_G0_2026-10-11.md), làm phần Review của lane trên nhánh hiện có sau fetch/rebase; không tự dùng contract G0 như API production đã chốt. Chưa chạy Meshy trả phí hoặc FPS/bot.

### 11/10/2026 — cập nhật D-080, Astra

- Nhà cung cấp hiện hành: **Tripo AI**. Tiếp tục phần việc trong [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md); không làm lại G0 hoặc đổi source/credits lịch sử.
- Tripo Studio/API tách ví; đường thủ công không cần client API. B/C cập nhật brief/metadata/QA đúng dịch vụ; A/D/F/web giữ ràng buộc gameplay đã review. Chưa cấp ngân sách/ngoại lệ license hoặc triển khai API live.

### 11/10/2026 — D-081, đổi đầu mối core

Astra làm thay Claude web ở T-207; gửi yêu cầu core/contract về Astra. Đọc contract G1 cập nhật và [bảng việc từng lane](../handoff/T207_G1_ASTRA_2026-10-11.md), tiếp tục task/nhánh hiện có. Giữ lịch sử G0; không sửa file lane khác hoặc coi quy ước mới là bằng chứng validator/asset đã đạt.
