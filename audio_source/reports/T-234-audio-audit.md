# T-234 — Rà âm thanh sau đợt đồ họa

Ngày đo: 08/11/2026, lane E. Base ban đầu: `85598c6`; đã rebase lên `0fe5e44` và lấy lại snapshot trên bản ghép mới. Số đo file được cập nhật cùng base trong JSON. Chỉ đo file, lấy snapshot cảnh và đọc wiring; không thay âm, gain, bus, vị trí nguồn hay luật chơi. **Chưa nghe bằng tai, chờ chủ dự án nghe.**

## Kết quả và phạm vi

- Đo lại **632/632 OGG**: không file lệch mục tiêu quá 1 LU; độ lệch lớn nhất **0,85 LU** (`voice/vi/WORD_CH2_DON_DOC.ogg`). True peak cao nhất **−2,62 dBTP**. **628 file** có build report: hash và LUFS đo lại đều khớp; không report mồ côi hoặc trùng. Bốn chunk âm tiết chương 2 chưa có build report, nhưng đo được và gần mục tiêu −30 LUFS của pipeline.
- Instance bốn scene chương, `auto_start=false`, không điều khiển người chơi, không gọi phát âm hay chạy đoạn truyện. Ghi **273 AudioStreamPlayer3D, 32 vùng âm**: chương 1/2/3/4 lần lượt 51/60/76/86 nguồn. Trong đó **213 nguồn** thuộc Floor4 hoặc các rig dùng chung của tầng 4; 60 nguồn khác của chương 3–4 được giữ trong bảng để không mất kiểm kê, không đo model ngoài vùng được giao.
- **154 nguồn có đồ tương ứng và mesh hiển thị** đều nằm trong ngưỡng khảo sát 0,15 m. **119 nguồn còn lại** là lớp nền không có một đồ cụ thể, rig chờ sự kiện hoặc ngoài vùng tầng 4; không gán nhãn OK vị trí cho chúng.
- Đối chiếu code phát hiện **hai vấn đề wiring chương 1**: tiếng ổ cắm đặt tại router (lệch khoảng **3,98 m** tới ổ điện dưới sàn); tiếng rung tay nắm giữ vị trí rig MissionAudio tại router sau nhiệm vụ mạng (lệch **2,91 m** tới tay nắm). Chưa tái hiện bằng chơi tay; không sửa trong lượt này.

## Bằng chứng và cách chạy lại

| Tệp | Nội dung |
|---|---|
| [t234/spatial.md](t234/spatial.md) | Đủ từng chương, node path, mesh đối chiếu, khoảng cách, đánh giá, gain; 32 vùng và 8 vị trí suy từ wiring |
| [t234/spatial.json](t234/spatial.json) | Tọa độ world, bounds mesh được chọn, gain/bus chain, trạng thái nguồn và phạm vi nghe |
| [t234/loudness.md](t234/loudness.md) | Bảng đủ 632 OGG: LUFS, true peak, target, độ lệch target/report, tình trạng hash/report |
| [t234/loudness.csv](t234/loudness.csv) | Bảng lọc/sắp xếp cho integrator |
| [t234/loudness.json](t234/loudness.json) | Số đo, SHA256, nguồn target và nội dung report đối chiếu cho từng file |

Từ gốc `D:\GAME_WORK\lane-e2`:

```powershell
py -3 audio_source/audit_audio.py --output audio_source/reports/t234
# Theo luật Lượt Godot; có thể dùng filter ngắn khi người khác giữ lượt.
pwsh tools/test.ps1 -Filter audio_audit_snapshot
py -3 audio_source/audit_audio_spatial.py
```

Lệnh Python thứ nhất chỉ đọc OGG, dùng `loudnorm=I=-24:TP=-2:LRA=7:print_format=json`, lấy **input_i/input_tp**, đẩy output vào null; không normalize/encode file. `I=-24` là tham số phân tích hợp lệ, **không thay target riêng từng âm**. Nó kiểm hash trước/sau mỗi file, đọc target từ report bank hoặc `process.py:TARGET_OVERRIDES` bằng AST, không chạy generator. FFmpeg theo `--ffmpeg`, `FFMPEG`, PATH hoặc `D:\Tools\ffmpeg\`; phiên đo dùng phiên bản ghi trong JSON. Log console ở `build/t234-loudness.log`.

Test xuất dữ liệu thô vào `build/t234/spatial_raw.json` (không commit). Script thứ hai chỉ xử lý snapshot, không mở Godot. Kết quả hiện tại lấy từ lượt **lọc riêng**, không dùng dữ liệu người chơi hoặc một lần chạy bot. Đường dẫn `@AudioStreamPlayer3D@...` là tên Godot sinh cho con tiếng chập; số thay đổi giữa các lần chạy. Bus riêng `FloorMuffle_<instance>` / `CorpseVoice_<instance>` được chuẩn hóa phần ID trong bảng; giữ đầy đủ chain và gain đo được.

`streams: []` trong snapshot không tự có nghĩa thiếu âm: AmbientEmitter dùng bản `duplicate()` không giữ resource_path, còn cue/giọng nhiều loại chỉ gán stream lúc phát. Bank file được kiểm độc lập đầy đủ trong bảng loudness; kết luận thiếu nguồn chỉ dựa vào cây node và wiring, không dựa riêng trường streams.

## Vị trí nguồn âm

Khoảng cách = giá trị nhỏ nhất từ điểm nguồn tới **AABB world của từng mesh hiển thị thuộc đúng đồ**. Không lấy AABB gộp cả phòng hay mesh đã ẩn của đồ PS1 cũ. Điểm nằm trong bounds có khoảng cách 0; **0 không chứng minh nằm trên mặt mesh**. World AABB là phép kiểm thô, có thể bao cả khoảng trống khi model xoay; không thay đo tam giác, skinning hoặc nghe định hướng.

Đề xuất ngưỡng rà **0,15 m**, dùng để tìm chỗ nên xem lại, chưa là tiêu chuẩn thiết kế được chủ dự án chốt. Nó cho phép nguồn ở trong vỏ đồ hoặc lệch vài cm do chốt/tay nắm; các lệch 0,4–4 m vẫn nổi rõ. T-218 từng dùng 0,10 m tới tâm quạt/đèn; báo cáo này đo tới bounds nên không so hai loại khoảng cách như cùng một phép đo. Giữ cả tọa độ/bounds để integrator đổi ngưỡng khi cần.

### Các đồ trong tầng 4

Node path dưới đây tương đối root ChapterN. Bảng đầy đủ từng nguồn/phần con nằm trong `spatial.md`.

| Chương | Nguồn / đồ | Khoảng cách tới bounds | Đánh giá |
|---|---|---:|---|
| 1–4 | `Floor4/Room407/FanAmbience` → CeilingFan | 0 m | OK vị trí quạt trần |
| 1–4 | `Floor4/Room407/Furnished/TripoProps/StandingFan/Rotor/FanHum` → FanBody | 0 m | OK; gắn vào rotor, đối chiếu thân tĩnh để tránh bounds vệt nhòe |
| 1–4 | `Floor4/Room407/Room407MainLight/LightHum` và con tiếng chập → hai ống tuýp | 0,019 m | OK; không nhầm tâm giữa hai ống là trên mặt ống |
| 1–4 | `Floor4/Corridor/CorridorLight_401…408` và `_Desk` / LightHum, con tiếng chập → Fixture/Mesh | 0,040 m | OK cho chín đèn; hình hành lang vẫn là bản hiện hành trước T-233 |
| 1–4 | `Floor4/Washroom/WashroomLight/LightHum` và con → Fixture/Mesh | 0,040 m | OK nhà vệ sinh chung |
| 1–4 | `Floor4/Washroom/WaterDrips` → Tap_2 | 0,056 m | OK; chỉ một nguồn giọt nước cạnh vòi thứ ba, không kết luận hai vòi kia thiếu âm |
| 1–4 | `Floor4/DutyDesk/SpeakerIdle`, `FloorSpeaker` và ba lớp con → loa PA | 0 m | OK; không coi nhiều lớp loa là phát trùng khi chưa kiểm lúc phát |
| 1–4 | `Floor4/Door407/Pivot/DoorLatch407/BlockedSound` → HandlePivot/Lever | 0 m | OK riêng tiếng chốt bị chặn; khác với tiếng rung ở MissionAudio |
| 1–4 | Corpse1/2/4 / Body/CorpseAudio / Drip, Rustle | Trong 0,15 m | OK pose ban đầu; chưa kiểm khi xác chuyển pose |
| 2 | Gag1/2/4 / CorpseVoice / Voice, Body → mesh đầu tương ứng | Trong 0,15 m | OK pose ban đầu; follow Head hiện có, chưa kiểm mọi animation |
| 2 | ShowerAudio / Water, Steam, Cue | Không chấm vị trí chờ | Đang tại tâm khoang, chưa phát; không báo sai là vòi/gương bị dời về khoang |

### Vị trí khi phát, suy từ wiring

Không gọi sự kiện gameplay hoặc di chuyển nguồn trong khảo sát này. Lấy vị trí **anchor thật** sau dựng cảnh, sau đó tính khoảng cách mà code sẽ dùng khi phát.

| Chương / cue | Nguồn → đồ | m | Đánh giá và căn cứ |
|---|---|---:|---|
| 1: router off/boot/online | MissionAudio/Cue tại `Room407/Anchors/Router` → Router Tripo | 0 | OK; `_mission_cue()` dùng `_router_position()` |
| 1: power_switch/power_short | Cùng nguồn tại Router → `Room407/Anchors/PowerStrip` dưới sàn | **3,9822** | **Lệch**; `_on_strip_switch()` gọi `_mission_cue()` cho cả hai âm. Đối chiếu đúng ổ điện Blender tương tác, không nhầm ổ Tripo trên bàn |
| 1: handle_rattle/handle_stop sau nhiệm vụ mạng | MissionAudio/HandleLoop, HandleRelease giữ vị trí Router → tay nắm 407 | **2,9056** | **Lệch**; `_hold_the_door()` không đặt lại vị trí trước `set_handle_rattling()` |
| 1: vào riêng nhiệm vụ cửa, chưa có cue router | Vị trí mặc định MissionAudio (32; 1; −0,5) → tay nắm | **0,4108** | **Lệch**; mức lệch phụ thuộc đường vào nhiệm vụ, cần nghe cả hai đường |
| 1: đèn chập | FlickerBuzz được dựng dưới Room407MainLight → ống tuýp | 0,0479 | OK theo code `_set_flicker()`; nguồn này chưa tồn tại trong snapshot tĩnh |
| 2: nước | `Ch2Bathroom/Water` → Shower Tripo | 0 | OK theo `ShowerAudio._aim(WATER_ANCHORS)` |
| 2: mirror_shiver | `Ch2Bathroom/Reflection` → MirrorSmall | 0,0250 | OK theo MIRROR_ANCHORS; vị trí gương đã lùi theo vỏ mới |
| 2: đẩy/phá cửa nhà tắm | `Extension/BathroomDoor/Pivot/Handle` → lever hiển thị | 0,0073 | OK theo DOOR_ANCHORS; không còn dùng tâm khoang như ghi chú cũ trước review T-218 |

Căn cứ: `game/scripts/core/chapter1_director.gd` (`_on_strip_switch`, `_mission_cue`, `_hold_the_door`, `_set_flicker`), `game/scenes/main/chapter1_main.gd::_place_audio`, `game/scripts/audio/shower_audio.gd`. Đo vị trí của các anchor này, không chạy chúng.

### Vùng âm và nguồn chưa có

Mỗi chương có bốn cặp AmbientZone/ReverbZone: hành lang, phòng 407, nhà vệ sinh chung, bàn trực. Phòng 407 bao world x=30,10…37,90; y=0…3; z=−6,95…−0,05; hành lang x=0…44, z=0…4. Nhà tắm trong phòng dùng chung vùng 407, **không có ReverbZone nhà tắm riêng**. Đây là hiện trạng, không tự quyết thêm preset BATHROOM.

Ban công nằm ngoài mặt z=−6,95 của vùng 407. Không có AmbientZone/ReverbZone riêng ở ban công và không có nguồn giọt nước riêng dưới vòi ban công. Khi ra ngoài vùng, fade có thể giảm cả quạt dù cửa ban công mở; chưa kiểm đi qua biên hoặc nghe mức chuyển. Cần chủ dự án chọn có muốn nghe xuyên cửa/âm nền ban công không.

| Đồ / trường hợp | Trạng thái nguồn | Cách hiểu |
|---|---|---|
| Vòi ban công, cửa ban công | **Thiếu nguồn riêng** trong snapshot và wiring level đã rà | Chưa có yêu cầu vòi chạy; cửa production đang mở sẵn, thao tác cửa chờ bước nhân vật. Không tự tạo tiếng chỉ vì có model |
| Cửa nhà tắm / cửa 407 mở thường | Chưa tìm được cue mở/đóng thường nối trực tiếp ở level | Đã có chốt 407, rung tay nắm chương 1, đẩy/phá cửa chương 2; không gộp thành “mọi cửa im” |
| Tiếng bíp bộ đếm vòi sen | Có `Ch2Countdown` dùng **AudioStreamPlayer 2D**, không phải thiếu file hay nguồn | Không nằm trong danh sách 3D theo card; có chủ đích UI/cảnh báo hay phải ở bảng sen là câu hỏi thiết kế, chưa đổi |
| Quản lý Tripo / dao | ManagerAudioFar tồn tại nhưng chưa có quản lý đang thực hiện cảnh | Không chấm sáu nguồn tại gốc là lỗi. `manager.gd::_sync_audio` đặt rig theo quản lý, riêng Drag theo BladeTip; chưa đo model/dao khi bước, soi giường, chém |
| Chuông báo cháy tầng 1 | Nguồn dựng khi `_ring_bell()` chạy, ngoài snapshot và ngoài vùng tầng 4 | Production vẫn `ch1v2/lock_alarm.ogg`, SFX −4 dB, unit_size=8; mẫu T-212 chưa nối. Marker và deadline vẫn thuộc hợp đồng T-212, không tạo lỗi mới từ việc snapshot không có chuông |

## Mức âm, bus và ước lượng tương đối

Mọi file được so với **target cụ thể**, không lấy mặc định Ambience −24 / SFX −18 áp lên toàn bộ giọng/nhạc. `ceiling_fan` có override **−34 LUFS** trong `process.py`, dù đoạn ví dụ README chưa kể đủ override; không đề xuất tăng về −24. Các mục tiêu nhỏ đã chốt được giữ nguyên.

| File thiếu build report | LUFS đo | dBTP | Target pipeline | Δ LU |
|---|---:|---:|---:|---:|
| `voice/vi/ch2_syllables_0.ogg` | −29,98 | −8,21 | −30 | +0,02 |
| `voice/vi/ch2_syllables_1.ogg` | −29,98 | −7,74 | −30 | +0,02 |
| `voice/vi/ch2_syllables_2.ogg` | −29,98 | −8,08 | −30 | +0,02 |
| `voice/vi/ch2_syllables_3.ogg` | −29,97 | −7,99 | −30 | +0,03 |

Các chunk có mapping riêng ở `game/data/ch2/corpse_syllables.json`, được tạo bởi `audio_source/ch2_syllable_voices.py`. **Thiếu build report không đồng nghĩa thiếu asset hay thiếu nguồn gốc.** Số đo nguyên chunk không mô tả mọi từ ghép/cắt PCM ở runtime; cần nghe riêng T-178 khi có card.

| Bus | Gửi về | Gain trong layout | Gain snapshot mặc định |
|---|---|---:|---:|
| Master | đầu ra | 0 | 0 |
| Ambience | Master | −3 | **0** |
| SFX | Master | 0 | 0 |
| Voice | Master | 0 | 0 |
| Music | Master | 0 | 0 |
| Footsteps | SFX | 0 | 0 |
| PhoneVoice | Voice | 0 | 0 |
| PhoneSFX | SFX | 0 | 0 |

Chênh Ambience là do `game/scripts/ui/settings.gd` áp mặc định `[audio] ambience_db=0` theo `docs/SETTINGS.md` lên AudioServer. Đo trong môi trường test cô lập, không đọc cài đặt thật của chủ dự án. Không coi −3 dB của layout là mức runtime cố định. PhoneVoice/PhoneSFX có HP300/LP3400 và distortion; SFX/Ambience có reverb. FloorMuffle thêm bus riêng, giảm 8 dB/tầng và lọc; KhoaTaps còn lọc xuyên tường. Các hiệu ứng này không thể quy đổi đầy đủ bằng cộng dB đơn thuần.

Ước lượng dưới đây chỉ là **LUFS file + gain player cơ sở + gain bus tuyến tính**, trước attenuation, max_db, pitch ngẫu nhiên, fade vùng, reverb, EQ, distortion, limiter và tổng nhiều nguồn. **Không phải LUFS tại tai**, không dùng để duyệt âm lượng. Bảng `spatial.json` lưu gain snapshot, gain gốc AmbientEmitter, biến thiên, unit_size/max_distance và chain thực từng nguồn; gain lúc vùng chưa mở không được dùng thay gain thiết kế.

| Âm / nguồn | LUFS file | Player cơ sở | Bus runtime | Tổng cộng đơn giản |
|---|---:|---:|---|---:|
| Quạt trần / FanAmbience | −34,15 | −12 | Ambience 0 | −46,15 |
| Quạt đứng / FanHum | −34,15 | −24 | Ambience 0 | −58,15 |
| Ù đèn / LightHum | −43,98 | −10 | Ambience 0 | −53,98 |
| Chập đèn / fluorescent_flicker | −18,01 | khoảng −10 khi phát | Ambience 0 | khoảng −28,01 |
| Giọt nước WC chung | −18,05 | −8 | Ambience 0 | −26,05 |
| Loa idle / fluorescent_flicker | −18,01 | −28 | Ambience 0 | −46,01 |
| Nền rè loa / speaker_static | xấp xỉ −32 | −12 | Voice 0 | xấp xỉ −44 |
| Bíp/công tắc MissionAudio | Theo từng file ch1v2 | 0 | SFX 0 | Bằng mức file trước khoảng cách |
| Nước / ShowerAudio Water | Theo water_cold/warm/boiling | 0 | Ambience 0 | Bằng mức file trước khoảng cách |
| Giọng cuộc gọi | Theo key, thường khoảng −26 | 0 | PhoneVoice → Voice | Chưa tính lọc/distortion điện thoại |
| Xác chương 2 / Voice | Chunk khoảng −30 | −6 | CorpseVoice → Voice | Khoảng −36 trước pitch/lọc/ghép |

Quạt đứng nhỏ hơn quạt trần **12 dB ở gain nguồn**, nhưng unit_size 1/max_distance 5 khác quạt trần 4/22, nên không suy ra mọi chỗ nghe đều chênh đúng 12 dB. Chập đèn có mức file cao hơn tiếng ù khoảng 26 LU; đây là khác biệt cũ giữa burst và loop, không tự kết luận lỗi hoặc giảm âm. Gain con tiếng chập trong snapshot đang là 0 vì chưa gọi `flicker()`; hàm đó chép gain của hum lúc phát. Các gain của nguồn dùng lại, cue động và âm 2D phải đọc theo caller, không gán một bus duy nhất cho toàn bộ file chỉ dựa tên thư mục.

## Đề xuất sửa, chưa áp dụng

| Ưu tiên | Đề xuất | Owner / phạm vi | Gain đề xuất |
|---|---|---|---|
| P1 | Tách vị trí tiếng ổ điện và router: power_switch/power_short theo ổ điện thật hoặc switch đang dùng; router_* giữ tại router | **Integrator**: chapter1_director. E hỗ trợ rig nếu được card; không sửa core từ lane E | **0 dB thay đổi**; sửa vị trí trước rồi nghe lại |
| P1 | Khi bắt đầu rung tay nắm, đặt nguồn tại `Door407/Pivot/HandlePivot`; giữ khi cửa xoay, không để cue router kéo nguồn tay nắm theo | **Integrator** giữ caller; **E** có thể tách player/anchor trong audio theo card sau. **B** chỉ sửa scene level nếu cần marker mới | **0 dB thay đổi** |
| P2 | Bổ sung report SHA256/LUFS/peak cho bốn chunk âm tiết, giữ nguyên waveform và lời | **E**, nếu được card bổ sung hồ sơ pipeline; dữ liệu mapping core không tự sửa | **0 dB thay đổi** |
| P2 | Nghe chuyển vùng phòng → ban công; phương án A giữ fade hiện tại, B kéo dài vùng/để nghe xuyên cửa. Đề xuất thử nghe A trước vì chưa có bằng chứng khó chịu | **Chủ dự án chọn**; **B** sở hữu zone level, E tư vấn mức; integrator nối khi cần | Chưa đề xuất tăng/giảm trước khi nghe |
| P2 | Nghe riêng burst đèn so hum và tiếng quạt đứng ở gần/xa; chỉ thử giảm burst 2–3 dB nếu chủ dự án thấy gắt | **Chủ dự án chọn**; **E** audio, **B** thuộc tính nguồn level, integrator phần FlickerBuzz caller | Giữ hiện hành; −2…−3 dB chỉ là phương án nghe A/B sau, chưa chốt |
| P3 | Nếu cần đồng nhất Ambience layout và settings, xác nhận baseline mong muốn trước | **Integrator + D** hợp đồng settings/UI; E chỉ đổi bus sau card | Không tự đổi 0 về −3 hoặc ngược lại |

Không đề xuất thêm nguồn cho mọi đồ im lặng. Nhận xét “thiếu nguồn riêng” ở bảng trên là kiểm kê, chưa phải yêu cầu thiết kế được duyệt. Không mở lại lỗi N_GOT của T-200 vì integrator đã xử lý.

## Danh sách nghe thử cho chủ dự án

Xếp lượt Godot trước khi mở. Mỗi lần nghe giữ cùng cài đặt Master/các bus và cùng thiết bị; nếu âm quá nhỏ ghi vị trí nghe và cài đặt, chưa tự tăng toàn game.

1. **Ưu tiên ổ điện và tay nắm chương 1:** mở `res://scenes/main/chapter1.tscn`, F9 → **Mất mạng** (nhãn “Mất mạng” trong menu); đi WASD, dùng phím tương tác hiện trên HUD tại ổ điện. Đứng cạnh ổ dưới sàn rồi nhìn/nghe về kệ router: tiếng công tắc và chập đang có vẻ phát từ đâu. Chơi tiếp đến **Giữ cửa** để kiểm tiếng rung sau khi rig từng phát tại router; đứng sát tay nắm và quay đầu. Nếu dùng F9 nhảy riêng Giữ cửa, ghi riêng vì vị trí nguồn ban đầu khác đường chơi liên tục. Agent chưa chạy các bước này.
2. **So chất âm cue riêng:** F6 `res://audio/test/ch1v2_audio_test.tscn`, F6 công tắc, F7 chập điện, F8 bật/tắt rung tay nắm, 0 dừng. Đây là fixture ở vị trí thử, **không chứng minh wiring chương 1 đúng**.
3. **Phòng 407/nhà tắm:** F6 `res://audio/graphics_upgrade/room407_audio_preview.tscn`; C giữa phòng, F quạt trần, L đèn, K chập, B cửa nhà tắm, 1/2/3 nước, M gương, T so vị trí trước T-218, Space dừng. Nghe hướng nước/gương và đèn có gắt/click không. Fixture này chủ động tắt quạt đứng và không dựng FlickerBuzz của director; cần nghe thêm trong chương 1/2 thật.
4. **Quạt đứng và biên ban công:** chương 1, đứng trước quạt khoảng 1 m rồi lùi 3–5 m; đi tới cửa ban công đang mở và ra ngoài, nghe fade có đột ngột không. Chú ý nguồn quạt nhỏ, không yêu cầu tự tăng để nghe rõ mọi nơi. Không có phím solo quạt đứng trong preview T-218 hiện hành.
5. **Chuông T-212:** F6 `res://audio/graphics_upgrade/fire_bell_preview.tscn`; 1 mẫu mới, 3 mẫu cũ, C ở 8 m, lên/xuống ở 2/20 m, trái/phải kiểm hướng, 2 loop, P pause, 0 dừng. Mẫu mới vẫn chờ duyệt; không suy mức nghe ở fixture thành kết quả chuông tầng 1 production.

Sau đó mới nghe rộng hơn giọng cuộc gọi/loa chương 2–4, y tá hai kết và từ ghép xác theo các fixture chương. Toàn bộ đánh giá chất âm, độ rõ lời, mức dễ chịu và định hướng thực: **chưa nghe bằng tai, chờ chủ dự án nghe**.

## Phần chưa kiểm và giới hạn

- Không chơi, không bot, không FPS; không chạy các sự kiện mission, vòi sen, chuông, chém dao hoặc đổi animation để đo. Tọa độ dự đoán từ wiring được tách rõ khỏi snapshot thật.
- Chưa nghe/render, chưa đo mix cuối từ listener, occlusion, loop click hay chất lượng loa laptop/tai nghe. Không lấy true peak của từng file làm bảo đảm mix không clip.
- Chưa đo mọi frame của quản lý Tripo, xác, cửa chuyển động; chưa đo nguồn tạo muộn ngoài tám trường hợp suy wiring nêu trên. `auto_start=false` không tạo mọi nguồn của cả cuộc chơi.
- Đã lấy lại snapshot sau bản ghép T-231/T-232 (`0fe5e44`). Chưa khảo sát model mới ở các nhánh chưa merge vào base; nếu core hoặc scene được cập nhật tiếp, phải lấy lại snapshot trước khi dùng khoảng cách để sửa.
- Báo cáo và dữ liệu có thể tái tạo trong phạm vi lane E. Log full test/check và RESULT cuối cùng ghi trong Handoff của card T-234; không commit log hoặc `spatial_raw.json`.
