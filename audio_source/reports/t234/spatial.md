# T-234 — bảng nguồn âm và vùng âm

Tự tạo bằng `audio_source/audit_audio_spatial.py`. Node path tương đối với root ChapterN. Khoảng cách là tới AABB world của mesh hiển thị gần nhất thuộc đúng đồ; không phải khoảng cách tới tam giác. Ngưỡng khảo sát đề xuất 0,15 m. `—` là chưa áp dụng, không phải 0 m. Mọi đánh giá chất âm: chưa nghe bằng tai, chờ chủ dự án nghe.

## Chương 1: 51 nguồn 3D

| Node path | Đồ / mesh | m | Đánh giá / lý do | Bus; gain player gốc; gain bus tổng |
|---|---|---:|---|---|
| `Floor4/Corridor/CorridorLight_401/LightHum` | `Floor4/Corridor/CorridorLight_401/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_401/LightHum/@AudioStreamPlayer3D@54` | `Floor4/Corridor/CorridorLight_401/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_402/LightHum` | `Floor4/Corridor/CorridorLight_402/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_402/LightHum/@AudioStreamPlayer3D@56` | `Floor4/Corridor/CorridorLight_402/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_403/LightHum` | `Floor4/Corridor/CorridorLight_403/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_403/LightHum/@AudioStreamPlayer3D@58` | `Floor4/Corridor/CorridorLight_403/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_404/LightHum` | `Floor4/Corridor/CorridorLight_404/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_404/LightHum/@AudioStreamPlayer3D@60` | `Floor4/Corridor/CorridorLight_404/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_405/LightHum` | `Floor4/Corridor/CorridorLight_405/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_405/LightHum/@AudioStreamPlayer3D@62` | `Floor4/Corridor/CorridorLight_405/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_406/LightHum` | `Floor4/Corridor/CorridorLight_406/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_406/LightHum/@AudioStreamPlayer3D@64` | `Floor4/Corridor/CorridorLight_406/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_407/LightHum` | `Floor4/Corridor/CorridorLight_407/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_407/LightHum/@AudioStreamPlayer3D@66` | `Floor4/Corridor/CorridorLight_407/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_408/LightHum` | `Floor4/Corridor/CorridorLight_408/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_408/LightHum/@AudioStreamPlayer3D@68` | `Floor4/Corridor/CorridorLight_408/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_Desk/LightHum` | `Floor4/Corridor/CorridorLight_Desk/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_Desk/LightHum/@AudioStreamPlayer3D@70` | `Floor4/Corridor/CorridorLight_Desk/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/YardInsects` | `—` | — | chưa áp dụng: Lớp nền sân ngoài hành lang, không gắn với một mô hình côn trùng. | Ambience; -5; 0 dB |
| `Floor4/Room407/Room407MainLight/LightHum` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0190 | OK: Đèn tuýp phòng 407. | Ambience; -10; 0 dB |
| `Floor4/Room407/Room407MainLight/LightHum/@AudioStreamPlayer3D@73` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0190 | OK: Đèn tuýp phòng 407. | Ambience; 0; 0 dB |
| `Floor4/Room407/FanAmbience` | `Floor4/Room407/Furnished/TripoProps/CeilingFan/fan_rotor/Blades` | 0.0000 | OK: Quạt trần; bounds mô hình đang hiển thị. | Ambience; -12; 0 dB |
| `Floor4/Room407/Anchors/Corpse1/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse1/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse2/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse2/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse4/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse4/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Furnished/TripoProps/StandingFan/Rotor/FanHum` | `Floor4/Room407/Furnished/TripoProps/StandingFan/FanBody` | 0.0000 | OK: Quạt đứng; dùng thân tĩnh, không dùng vệt nhòe cánh quay. | Ambience; -24; 0 dB |
| `Floor4/Washroom/WashroomLight/LightHum` | `Floor4/Washroom/WashroomLight/Fixture/Mesh` | 0.0400 | OK: Đèn nhà vệ sinh chung. | Ambience; -10; 0 dB |
| `Floor4/Washroom/WashroomLight/LightHum/@AudioStreamPlayer3D@101` | `Floor4/Washroom/WashroomLight/Fixture/Mesh` | 0.0400 | OK: Đèn nhà vệ sinh chung. | Ambience; 0; 0 dB |
| `Floor4/Washroom/WaterDrips` | `Floor4/Washroom/Tap_2/tap/tap_mesh` | 0.0560 | OK: Giọt nước cạnh vòi thứ ba; không đo tới cả phòng. | Ambience; -8; 0 dB |
| `Floor4/DutyDesk/SpeakerIdle` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Ambience; -28; 0 dB |
| `Floor4/Door407/Pivot/DoorLatch407/BlockedSound` | `Floor4/Door407/Pivot/HandlePivot/Lever` | 0.0000 | OK: Tiếng chốt bị chặn cạnh tay nắm 407. | SFX; -10; 0 dB |
| `Player/Footsteps` | `—` | — | chưa áp dụng: Bước chân theo Player, thân người chơi chưa có trong cảnh production này. | Footsteps; 0; 0 dB |
| `FloorSpeaker` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `FloorSpeaker/BackgroundStatic` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; -12; 0 dB |
| `FloorSpeaker/StaticBurst` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `FloorSpeaker/Speech` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `ManagerAudioFar/Step` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Drag` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Knock` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Slash` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Kill` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Speech` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `MissionAudio/Cue` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `MissionAudio/HandleLoop` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `MissionAudio/HandleRelease` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `KhoaTaps/Taps` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; -4 dB |
| `RoomDrips/Drip` | `—` | — | chưa áp dụng: Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể. | FloorMuffle_<instance>; 0; 0 dB |
| `RoomDrips/Rustle` | `—` | — | chưa áp dụng: Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể. | FloorMuffle_<instance>; 0; 0 dB |
## Chương 2: 60 nguồn 3D

| Node path | Đồ / mesh | m | Đánh giá / lý do | Bus; gain player gốc; gain bus tổng |
|---|---|---:|---|---|
| `Floor4/Corridor/CorridorLight_401/LightHum` | `Floor4/Corridor/CorridorLight_401/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_401/LightHum/@AudioStreamPlayer3D@274` | `Floor4/Corridor/CorridorLight_401/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_402/LightHum` | `Floor4/Corridor/CorridorLight_402/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_402/LightHum/@AudioStreamPlayer3D@276` | `Floor4/Corridor/CorridorLight_402/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_403/LightHum` | `Floor4/Corridor/CorridorLight_403/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_403/LightHum/@AudioStreamPlayer3D@278` | `Floor4/Corridor/CorridorLight_403/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_404/LightHum` | `Floor4/Corridor/CorridorLight_404/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_404/LightHum/@AudioStreamPlayer3D@280` | `Floor4/Corridor/CorridorLight_404/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_405/LightHum` | `Floor4/Corridor/CorridorLight_405/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_405/LightHum/@AudioStreamPlayer3D@282` | `Floor4/Corridor/CorridorLight_405/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_406/LightHum` | `Floor4/Corridor/CorridorLight_406/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_406/LightHum/@AudioStreamPlayer3D@284` | `Floor4/Corridor/CorridorLight_406/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_407/LightHum` | `Floor4/Corridor/CorridorLight_407/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_407/LightHum/@AudioStreamPlayer3D@286` | `Floor4/Corridor/CorridorLight_407/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_408/LightHum` | `Floor4/Corridor/CorridorLight_408/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_408/LightHum/@AudioStreamPlayer3D@288` | `Floor4/Corridor/CorridorLight_408/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_Desk/LightHum` | `Floor4/Corridor/CorridorLight_Desk/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_Desk/LightHum/@AudioStreamPlayer3D@290` | `Floor4/Corridor/CorridorLight_Desk/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/YardInsects` | `—` | — | chưa áp dụng: Lớp nền sân ngoài hành lang, không gắn với một mô hình côn trùng. | Ambience; -5; 0 dB |
| `Floor4/Room407/Room407MainLight/LightHum` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0190 | OK: Đèn tuýp phòng 407. | Ambience; -10; 0 dB |
| `Floor4/Room407/Room407MainLight/LightHum/@AudioStreamPlayer3D@293` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0190 | OK: Đèn tuýp phòng 407. | Ambience; 0; 0 dB |
| `Floor4/Room407/FanAmbience` | `Floor4/Room407/Furnished/TripoProps/CeilingFan/fan_rotor/Blades` | 0.0000 | OK: Quạt trần; bounds mô hình đang hiển thị. | Ambience; -12; 0 dB |
| `Floor4/Room407/Anchors/Corpse1/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse1/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse2/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse2/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse4/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse4/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Gag1/CorpseVoice/Voice` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Head/Nose` | 0.0333 | OK: Nguồn theo Gag/Head; chỉ pose khởi tạo. | CorpseVoice_<instance>; -6; 0 dB |
| `Floor4/Room407/Anchors/Gag1/CorpseVoice/Body` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Head/Nose` | 0.0333 | OK: Nguồn theo Gag/Head; chỉ pose khởi tạo. | SFX; 0; 0 dB |
| `Floor4/Room407/Anchors/Gag2/CorpseVoice/Voice` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Head/Nose` | 0.0333 | OK: Nguồn theo Gag/Head; chỉ pose khởi tạo. | CorpseVoice_<instance>; -6; 0 dB |
| `Floor4/Room407/Anchors/Gag2/CorpseVoice/Body` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Head/Nose` | 0.0333 | OK: Nguồn theo Gag/Head; chỉ pose khởi tạo. | SFX; 0; 0 dB |
| `Floor4/Room407/Anchors/Gag4/CorpseVoice/Voice` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Head/Nose` | 0.0333 | OK: Nguồn theo Gag/Head; chỉ pose khởi tạo. | CorpseVoice_<instance>; -6; 0 dB |
| `Floor4/Room407/Anchors/Gag4/CorpseVoice/Body` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Head/Nose` | 0.0333 | OK: Nguồn theo Gag/Head; chỉ pose khởi tạo. | SFX; 0; 0 dB |
| `Floor4/Room407/Anchors/ShowerStall/ShowerAudio/Water` | `—` | — | chưa áp dụng: Nguồn chờ tại khoang; Water/Cue được _aim khi phát. Xem bảng vị trí suy từ wiring. | Ambience; 0; 0 dB |
| `Floor4/Room407/Anchors/ShowerStall/ShowerAudio/Steam` | `—` | — | chưa áp dụng: Nguồn chờ tại khoang; Water/Cue được _aim khi phát. Xem bảng vị trí suy từ wiring. | Ambience; 0; 0 dB |
| `Floor4/Room407/Anchors/ShowerStall/ShowerAudio/Cue` | `—` | — | chưa áp dụng: Nguồn chờ tại khoang; Water/Cue được _aim khi phát. Xem bảng vị trí suy từ wiring. | SFX; 0; 0 dB |
| `Floor4/Room407/Furnished/TripoProps/StandingFan/Rotor/FanHum` | `Floor4/Room407/Furnished/TripoProps/StandingFan/FanBody` | 0.0000 | OK: Quạt đứng; dùng thân tĩnh, không dùng vệt nhòe cánh quay. | Ambience; -24; 0 dB |
| `Floor4/Washroom/WashroomLight/LightHum` | `Floor4/Washroom/WashroomLight/Fixture/Mesh` | 0.0400 | OK: Đèn nhà vệ sinh chung. | Ambience; -10; 0 dB |
| `Floor4/Washroom/WashroomLight/LightHum/@AudioStreamPlayer3D@321` | `Floor4/Washroom/WashroomLight/Fixture/Mesh` | 0.0400 | OK: Đèn nhà vệ sinh chung. | Ambience; 0; 0 dB |
| `Floor4/Washroom/WaterDrips` | `Floor4/Washroom/Tap_2/tap/tap_mesh` | 0.0560 | OK: Giọt nước cạnh vòi thứ ba; không đo tới cả phòng. | Ambience; -8; 0 dB |
| `Floor4/DutyDesk/SpeakerIdle` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Ambience; -28; 0 dB |
| `Floor4/Door407/Pivot/DoorLatch407/BlockedSound` | `Floor4/Door407/Pivot/HandlePivot/Lever` | 0.0000 | OK: Tiếng chốt bị chặn cạnh tay nắm 407. | SFX; -10; 0 dB |
| `Player/Footsteps` | `—` | — | chưa áp dụng: Bước chân theo Player, thân người chơi chưa có trong cảnh production này. | Footsteps; 0; 0 dB |
| `FloorSpeaker` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `FloorSpeaker/BackgroundStatic` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; -12; 0 dB |
| `FloorSpeaker/StaticBurst` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `FloorSpeaker/Speech` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `ManagerAudioFar/Step` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Drag` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Knock` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Slash` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Kill` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Speech` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `MissionAudio/Cue` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `MissionAudio/HandleLoop` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `MissionAudio/HandleRelease` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `KhoaTaps/Taps` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; -4 dB |
| `RoomDrips/Drip` | `—` | — | chưa áp dụng: Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể. | FloorMuffle_<instance>; 0; 0 dB |
| `RoomDrips/Rustle` | `—` | — | chưa áp dụng: Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể. | FloorMuffle_<instance>; 0; 0 dB |
## Chương 3: 76 nguồn 3D

| Node path | Đồ / mesh | m | Đánh giá / lý do | Bus; gain player gốc; gain bus tổng |
|---|---|---:|---|---|
| `Floor4/Corridor/CorridorLight_401/LightHum` | `Floor4/Corridor/CorridorLight_401/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_401/LightHum/@AudioStreamPlayer3D@504` | `Floor4/Corridor/CorridorLight_401/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_402/LightHum` | `Floor4/Corridor/CorridorLight_402/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_402/LightHum/@AudioStreamPlayer3D@506` | `Floor4/Corridor/CorridorLight_402/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_403/LightHum` | `Floor4/Corridor/CorridorLight_403/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_403/LightHum/@AudioStreamPlayer3D@508` | `Floor4/Corridor/CorridorLight_403/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_404/LightHum` | `Floor4/Corridor/CorridorLight_404/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_404/LightHum/@AudioStreamPlayer3D@510` | `Floor4/Corridor/CorridorLight_404/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_405/LightHum` | `Floor4/Corridor/CorridorLight_405/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_405/LightHum/@AudioStreamPlayer3D@512` | `Floor4/Corridor/CorridorLight_405/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_406/LightHum` | `Floor4/Corridor/CorridorLight_406/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_406/LightHum/@AudioStreamPlayer3D@514` | `Floor4/Corridor/CorridorLight_406/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_407/LightHum` | `Floor4/Corridor/CorridorLight_407/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_407/LightHum/@AudioStreamPlayer3D@516` | `Floor4/Corridor/CorridorLight_407/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_408/LightHum` | `Floor4/Corridor/CorridorLight_408/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_408/LightHum/@AudioStreamPlayer3D@518` | `Floor4/Corridor/CorridorLight_408/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_Desk/LightHum` | `Floor4/Corridor/CorridorLight_Desk/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_Desk/LightHum/@AudioStreamPlayer3D@520` | `Floor4/Corridor/CorridorLight_Desk/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/YardInsects` | `—` | — | chưa áp dụng: Lớp nền sân ngoài hành lang, không gắn với một mô hình côn trùng. | Ambience; -5; 0 dB |
| `Floor4/Room407/Room407MainLight/LightHum` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0190 | OK: Đèn tuýp phòng 407. | Ambience; -10; 0 dB |
| `Floor4/Room407/Room407MainLight/LightHum/@AudioStreamPlayer3D@523` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0190 | OK: Đèn tuýp phòng 407. | Ambience; 0; 0 dB |
| `Floor4/Room407/FanAmbience` | `Floor4/Room407/Furnished/TripoProps/CeilingFan/fan_rotor/Blades` | 0.0000 | OK: Quạt trần; bounds mô hình đang hiển thị. | Ambience; -12; 0 dB |
| `Floor4/Room407/Anchors/Corpse1/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse1/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse2/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse2/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse4/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse4/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Furnished/TripoProps/StandingFan/Rotor/FanHum` | `Floor4/Room407/Furnished/TripoProps/StandingFan/FanBody` | 0.0000 | OK: Quạt đứng; dùng thân tĩnh, không dùng vệt nhòe cánh quay. | Ambience; -24; 0 dB |
| `Floor4/Washroom/WashroomLight/LightHum` | `Floor4/Washroom/WashroomLight/Fixture/Mesh` | 0.0400 | OK: Đèn nhà vệ sinh chung. | Ambience; -10; 0 dB |
| `Floor4/Washroom/WashroomLight/LightHum/@AudioStreamPlayer3D@551` | `Floor4/Washroom/WashroomLight/Fixture/Mesh` | 0.0400 | OK: Đèn nhà vệ sinh chung. | Ambience; 0; 0 dB |
| `Floor4/Washroom/WaterDrips` | `Floor4/Washroom/Tap_2/tap/tap_mesh` | 0.0560 | OK: Giọt nước cạnh vòi thứ ba; không đo tới cả phòng. | Ambience; -8; 0 dB |
| `Floor4/DutyDesk/SpeakerIdle` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Ambience; -28; 0 dB |
| `Floor4/Door407/Pivot/DoorLatch407/BlockedSound` | `Floor4/Door407/Pivot/HandlePivot/Lever` | 0.0000 | OK: Tiếng chốt bị chặn cạnh tay nắm 407. | SFX; -10; 0 dB |
| `Campus/Library/Light0_9/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light0_9/LightHum/@AudioStreamPlayer3D@1054` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light0_25/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light0_25/LightHum/@AudioStreamPlayer3D@1056` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light1_9/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light1_9/LightHum/@AudioStreamPlayer3D@1058` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light1_25/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light1_25/LightHum/@AudioStreamPlayer3D@1060` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light2_9/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light2_9/LightHum/@AudioStreamPlayer3D@1062` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light2_25/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light2_25/LightHum/@AudioStreamPlayer3D@1064` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Player/Footsteps` | `—` | — | chưa áp dụng: Bước chân theo Player, thân người chơi chưa có trong cảnh production này. | Footsteps; 0; 0 dB |
| `Chapter3Director/Ch3Environment/@AudioStreamPlayer3D@1211` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Chapter3Director/Guard01/@Node3D@1216/@AudioStreamPlayer3D@1217` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard02/@Node3D@1218/@AudioStreamPlayer3D@1219` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard03/@Node3D@1220/@AudioStreamPlayer3D@1221` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard04/@Node3D@1222/@AudioStreamPlayer3D@1223` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard05/@Node3D@1224/@AudioStreamPlayer3D@1225` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard06/@Node3D@1226/@AudioStreamPlayer3D@1227` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard07/@Node3D@1228/@AudioStreamPlayer3D@1229` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard08/@Node3D@1230/@AudioStreamPlayer3D@1231` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard09/@Node3D@1232/@AudioStreamPlayer3D@1233` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard10/@Node3D@1234/@AudioStreamPlayer3D@1235` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard11/@Node3D@1236/@AudioStreamPlayer3D@1237` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter3Director/Guard12/@Node3D@1238/@AudioStreamPlayer3D@1239` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `FloorSpeaker` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `FloorSpeaker/BackgroundStatic` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; -12; 0 dB |
| `FloorSpeaker/StaticBurst` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `FloorSpeaker/Speech` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `ManagerAudioFar/Step` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Drag` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Knock` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Slash` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Kill` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Speech` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `MissionAudio/Cue` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `MissionAudio/HandleLoop` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `MissionAudio/HandleRelease` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `KhoaTaps/Taps` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; -4 dB |
| `RoomDrips/Drip` | `—` | — | chưa áp dụng: Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể. | FloorMuffle_<instance>; 0; 0 dB |
| `RoomDrips/Rustle` | `—` | — | chưa áp dụng: Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể. | FloorMuffle_<instance>; 0; 0 dB |
## Chương 4: 86 nguồn 3D

| Node path | Đồ / mesh | m | Đánh giá / lý do | Bus; gain player gốc; gain bus tổng |
|---|---|---:|---|---|
| `Floor4/Corridor/CorridorLight_401/LightHum` | `Floor4/Corridor/CorridorLight_401/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_401/LightHum/@AudioStreamPlayer3D@1281` | `Floor4/Corridor/CorridorLight_401/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_402/LightHum` | `Floor4/Corridor/CorridorLight_402/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_402/LightHum/@AudioStreamPlayer3D@1283` | `Floor4/Corridor/CorridorLight_402/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_403/LightHum` | `Floor4/Corridor/CorridorLight_403/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_403/LightHum/@AudioStreamPlayer3D@1285` | `Floor4/Corridor/CorridorLight_403/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_404/LightHum` | `Floor4/Corridor/CorridorLight_404/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_404/LightHum/@AudioStreamPlayer3D@1287` | `Floor4/Corridor/CorridorLight_404/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_405/LightHum` | `Floor4/Corridor/CorridorLight_405/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_405/LightHum/@AudioStreamPlayer3D@1289` | `Floor4/Corridor/CorridorLight_405/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_406/LightHum` | `Floor4/Corridor/CorridorLight_406/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_406/LightHum/@AudioStreamPlayer3D@1291` | `Floor4/Corridor/CorridorLight_406/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_407/LightHum` | `Floor4/Corridor/CorridorLight_407/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_407/LightHum/@AudioStreamPlayer3D@1293` | `Floor4/Corridor/CorridorLight_407/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_408/LightHum` | `Floor4/Corridor/CorridorLight_408/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_408/LightHum/@AudioStreamPlayer3D@1295` | `Floor4/Corridor/CorridorLight_408/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/CorridorLight_Desk/LightHum` | `Floor4/Corridor/CorridorLight_Desk/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; -10; 0 dB |
| `Floor4/Corridor/CorridorLight_Desk/LightHum/@AudioStreamPlayer3D@1297` | `Floor4/Corridor/CorridorLight_Desk/Fixture/Mesh` | 0.0400 | OK: Đèn hành lang; con LightHum là tiếng chập theo cùng vị trí. | Ambience; 0; 0 dB |
| `Floor4/Corridor/YardInsects` | `—` | — | chưa áp dụng: Lớp nền sân ngoài hành lang, không gắn với một mô hình côn trùng. | Ambience; -5; 0 dB |
| `Floor4/Room407/Room407MainLight/LightHum` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0190 | OK: Đèn tuýp phòng 407. | Ambience; -10; 0 dB |
| `Floor4/Room407/Room407MainLight/LightHum/@AudioStreamPlayer3D@1300` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0190 | OK: Đèn tuýp phòng 407. | Ambience; 0; 0 dB |
| `Floor4/Room407/FanAmbience` | `Floor4/Room407/Furnished/TripoProps/CeilingFan/fan_rotor/Blades` | 0.0000 | OK: Quạt trần; bounds mô hình đang hiển thị. | Ambience; -12; 0 dB |
| `Floor4/Room407/Anchors/Corpse1/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse1/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse1/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse2/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse2/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse2/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse4/Body/CorpseAudio/Drip` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Anchors/Corpse4/Body/CorpseAudio/Rustle` | `Floor4/Room407/Anchors/Corpse4/Body/Rig/Hips/Chest/Hem` | 0.0250 | OK: Foley tại thân xác; kiểm pose khởi tạo, không chứng nhận mọi animation. | FloorMuffle_<instance>; 0; 0 dB |
| `Floor4/Room407/Furnished/TripoProps/StandingFan/Rotor/FanHum` | `Floor4/Room407/Furnished/TripoProps/StandingFan/FanBody` | 0.0000 | OK: Quạt đứng; dùng thân tĩnh, không dùng vệt nhòe cánh quay. | Ambience; -24; 0 dB |
| `Floor4/Washroom/WashroomLight/LightHum` | `Floor4/Washroom/WashroomLight/Fixture/Mesh` | 0.0400 | OK: Đèn nhà vệ sinh chung. | Ambience; -10; 0 dB |
| `Floor4/Washroom/WashroomLight/LightHum/@AudioStreamPlayer3D@1328` | `Floor4/Washroom/WashroomLight/Fixture/Mesh` | 0.0400 | OK: Đèn nhà vệ sinh chung. | Ambience; 0; 0 dB |
| `Floor4/Washroom/WaterDrips` | `Floor4/Washroom/Tap_2/tap/tap_mesh` | 0.0560 | OK: Giọt nước cạnh vòi thứ ba; không đo tới cả phòng. | Ambience; -8; 0 dB |
| `Floor4/DutyDesk/SpeakerIdle` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Ambience; -28; 0 dB |
| `Floor4/Door407/Pivot/DoorLatch407/BlockedSound` | `Floor4/Door407/Pivot/HandlePivot/Lever` | 0.0000 | OK: Tiếng chốt bị chặn cạnh tay nắm 407. | SFX; -10; 0 dB |
| `Campus/Library/Light0_9/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light0_9/LightHum/@AudioStreamPlayer3D@1831` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light0_25/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light0_25/LightHum/@AudioStreamPlayer3D@1833` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light1_9/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light1_9/LightHum/@AudioStreamPlayer3D@1835` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light1_25/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light1_25/LightHum/@AudioStreamPlayer3D@1837` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light2_9/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light2_9/LightHum/@AudioStreamPlayer3D@1839` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Campus/Library/Light2_25/LightHum` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -10; 0 dB |
| `Campus/Library/Light2_25/LightHum/@AudioStreamPlayer3D@1841` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Player/Footsteps` | `—` | — | chưa áp dụng: Bước chân theo Player, thân người chơi chưa có trong cảnh production này. | Footsteps; 0; 0 dB |
| `Chapter4Director/Ch3Environment/@AudioStreamPlayer3D@1987` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; 0; 0 dB |
| `Chapter4Director/Guard01/@Node3D@1992/@AudioStreamPlayer3D@1993` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard02/@Node3D@1994/@AudioStreamPlayer3D@1995` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard03/@Node3D@1996/@AudioStreamPlayer3D@1997` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard04/@Node3D@1998/@AudioStreamPlayer3D@1999` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard05/@Node3D@2000/@AudioStreamPlayer3D@2001` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard06/@Node3D@2002/@AudioStreamPlayer3D@2003` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard07/@Node3D@2004/@AudioStreamPlayer3D@2005` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard08/@Node3D@2006/@AudioStreamPlayer3D@2007` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard09/@Node3D@2008/@AudioStreamPlayer3D@2009` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard10/@Node3D@2010/@AudioStreamPlayer3D@2011` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard11/@Node3D@2012/@AudioStreamPlayer3D@2013` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Chapter4Director/Guard12/@Node3D@2014/@AudioStreamPlayer3D@2015` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `FloorSpeaker` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `FloorSpeaker/BackgroundStatic` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; -12; 0 dB |
| `FloorSpeaker/StaticBurst` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `FloorSpeaker/Speech` | `Floor4/DutyDesk/Speaker/pa_horn/pa_horn_mesh` | 0.0000 | OK: Loa trực tầng; idle và thoại dùng cùng hình loa. | Voice; 0; 0 dB |
| `ManagerAudioFar/Step` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Drag` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Knock` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Slash` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Kill` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `ManagerAudioFar/Speech` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; 0 dB |
| `MissionAudio/Cue` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `MissionAudio/HandleLoop` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `MissionAudio/HandleRelease` | `—` | — | chưa áp dụng: Rig dùng chung; _mission_cue dời cả rig tới router, tay nắm giữ vị trí lần trước. | SFX; 0; 0 dB |
| `KhoaTaps/Taps` | `—` | — | chưa áp dụng: Chưa phát ở snapshot; caller đặt vị trí trước sự kiện. Không kết luận lỗi vì đang ở gốc. | FloorMuffle_<instance>; 0; -4 dB |
| `RoomDrips/Drip` | `—` | — | chưa áp dụng: Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể. | FloorMuffle_<instance>; 0; 0 dB |
| `RoomDrips/Rustle` | `—` | — | chưa áp dụng: Lớp máu chung phòng tại hằng tọa độ; không đại diện một đồ vật cụ thể. | FloorMuffle_<instance>; 0; 0 dB |
| `Ch4AudioRig/@Node3D@2040/@AudioStreamPlayer3D@2041` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Ch4AudioRig/@Node3D@2040/@AudioStreamPlayer3D@2042` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Ch4AudioRig/@Node3D@2049/@AudioStreamPlayer3D@2050` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Ch4AudioRig/@Node3D@2049/@AudioStreamPlayer3D@2051` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Footsteps; 0; 0 dB |
| `Ch4AudioRig/@Node3D@2049/@AudioStreamPlayer3D@2052` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Voice; 0; 0 dB |
| `Ch4AudioRig/@AudioStreamPlayer3D@2055` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | SFX; 0; 0 dB |
| `Ch4AudioRig/@AudioStreamPlayer3D@2056` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Voice; 0; 0 dB |
| `Ch4AudioRig/@AudioStreamPlayer3D@2057` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -18; 0 dB |
| `Ch4AudioRig/@AudioStreamPlayer3D@2058` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -18; 0 dB |
| `Ch4AudioRig/@AudioStreamPlayer3D@2059` | `—` | — | chưa áp dụng: Rig ngoài khu tầng 4 hoặc dựng trước sự kiện; chưa đo với model trong phạm vi này. | Ambience; -18; 0 dB |

## Vị trí khi phát, suy từ wiring

Không di chuyển nguồn hay gọi phát âm. Lấy tọa độ anchor thật rồi đối chiếu code caller. Chưa xác nhận bằng chơi tay.

| Chương | Cue / nguồn | Anchor | Mesh gần nhất | m | Kết quả / căn cứ |
|---|---|---|---|---:|---|
| 1 | router_power_off / boot / online → router — `MissionAudio` | `Floor4/Room407/Anchors/Router` | `Floor4/Room407/Furnished/TripoProps/Router/router` | 0.0 | OK: _mission_cue → _router_position; đúng đồ phát bíp. |
| 1 | power_switch / power_short → ổ cắm dưới sàn — `MissionAudio` | `Floor4/Room407/Anchors/Router` | `Floor4/Room407/Anchors/PowerStrip/Case` | 3.9822 | lệch: _mission_cue dùng vị trí router cho cả tiếng ổ điện. |
| 1 | handle_rattle / handle_stop sau cue router → tay nắm 407 — `MissionAudio` | `Floor4/Room407/Anchors/Router` | `Floor4/Door407/Pivot/HandlePivot/Lever` | 2.9056 | lệch: _hold_the_door chỉ gọi set_handle_rattling, không đặt lại rig sau nhiệm vụ router. |
| 1 | handle_rattle khi bắt đầu riêng nhiệm vụ cửa — `MissionAudio/HandleLoop` | `MissionAudio` | `Floor4/Door407/Pivot/HandlePivot/Lever` | 0.4108 | lệch: Vị trí mặc định trước mọi cue; cũng không ở tay nắm. |
| 1 | FlickerBuzz lúc đèn chập chương 1 — `Floor4/Room407/Room407MainLight/FlickerBuzz` | `Floor4/Room407/Room407MainLight` | `Floor4/Room407/Furnished/fixtures/FluorescentTube` | 0.0479 | OK: Nguồn tạo lúc _set_flicker; suy vị trí con local zero, không phát sự kiện. |
| 2 | set_water → đầu vòi — `Floor4/Room407/Anchors/ShowerStall/ShowerAudio/Water` | `Floor4/Room407/Ch2Bathroom/Water` | `Floor4/Room407/Furnished/TripoProps/Shower/shower` | 0.0 | OK: ShowerAudio._aim resolve anchor hiện có khi API được gọi; không gọi phát hoặc dời nguồn trong khảo sát. |
| 2 | mirror_shiver → gương nhỏ — `Floor4/Room407/Anchors/ShowerStall/ShowerAudio/Cue` | `Floor4/Room407/Ch2Bathroom/Reflection` | `Floor4/Room407/Furnished/TripoProps/MirrorSmall/mirror_small` | 0.025 | OK: ShowerAudio._aim resolve anchor hiện có khi API được gọi; không gọi phát hoặc dời nguồn trong khảo sát. |
| 2 | play_door_push / door_burst → tay nắm nhà tắm — `Floor4/Room407/Anchors/ShowerStall/ShowerAudio/Cue` | `Floor4/Room407/Extension/BathroomDoor/Pivot/Handle` | `Floor4/Room407/Extension/BathroomDoor/Pivot/BathroomDoor/Lever_002` | 0.0073 | OK: ShowerAudio._aim resolve anchor hiện có khi API được gọi; không gọi phát hoặc dời nguồn trong khảo sát. |

## Vùng âm

Vùng âm là thể tích, không phải nguồn điểm. OK dưới đây chỉ có nghĩa vùng có BoxShape, không xác nhận vùng nghe bao phủ mọi chỗ đứng.

| Chương | Node path | Bounds world min → max | Preset / emitters |
|---|---|---|---|
| 1 | `Floor4/Corridor/ReverbZone` | [{'max': [44.0, 3.0, 4.0], 'min': [0.0, 0.0, 0.0]}] | 1; [] |
| 1 | `Floor4/Corridor/AmbientZone` | [{'max': [44.0, 3.0, 4.0], 'min': [0.0, 0.0, 0.0]}] | None; ['../CorridorLight_401/LightHum', '../CorridorLight_402/LightHum', '../CorridorLight_403/LightHum', '../CorridorLight_404/LightHum', '../CorridorLight_405/LightHum', '../CorridorLight_406/LightHum', '../CorridorLight_407/LightHum', '../CorridorLight_408/LightHum', '../CorridorLight_Desk/LightHum', '../YardInsects'] |
| 1 | `Floor4/Room407/ReverbZone` | [{'max': [37.9000015258789, 3.0, -0.0500001907348633], 'min': [30.1000003814697, 0.0, -6.94999980926514]}] | 0; [] |
| 1 | `Floor4/Room407/AmbientZone` | [{'max': [37.9000015258789, 3.0, -0.0500001907348633], 'min': [30.1000003814697, 0.0, -6.94999980926514]}] | None; ['../Room407MainLight/LightHum', '../FanAmbience'] |
| 1 | `Floor4/Washroom/ReverbZone` | [{'max': [5.90000009536743, 3.0, -0.0500001907348633], 'min': [0.0999999046325684, 0.0, -4.94999980926514]}] | 2; [] |
| 1 | `Floor4/Washroom/AmbientZone` | [{'max': [5.90000009536743, 3.0, -0.0500001907348633], 'min': [0.0999999046325684, 0.0, -4.94999980926514]}] | None; ['../WashroomLight/LightHum', '../WaterDrips'] |
| 1 | `Floor4/DutyDesk/ReverbZone` | [{'max': [44.0, 3.0, 4.0], 'min': [38.0, 0.0, 0.0]}] | 1; [] |
| 1 | `Floor4/DutyDesk/AmbientZone` | [{'max': [44.0, 3.0, 4.0], 'min': [38.0, 0.0, 0.0]}] | None; ['../SpeakerIdle'] |
| 2 | `Floor4/Corridor/ReverbZone` | [{'max': [44.0, 3.0, 4.0], 'min': [0.0, 0.0, 0.0]}] | 1; [] |
| 2 | `Floor4/Corridor/AmbientZone` | [{'max': [44.0, 3.0, 4.0], 'min': [0.0, 0.0, 0.0]}] | None; ['../CorridorLight_401/LightHum', '../CorridorLight_402/LightHum', '../CorridorLight_403/LightHum', '../CorridorLight_404/LightHum', '../CorridorLight_405/LightHum', '../CorridorLight_406/LightHum', '../CorridorLight_407/LightHum', '../CorridorLight_408/LightHum', '../CorridorLight_Desk/LightHum', '../YardInsects'] |
| 2 | `Floor4/Room407/ReverbZone` | [{'max': [37.9000015258789, 3.0, -0.0500001907348633], 'min': [30.1000003814697, 0.0, -6.94999980926514]}] | 0; [] |
| 2 | `Floor4/Room407/AmbientZone` | [{'max': [37.9000015258789, 3.0, -0.0500001907348633], 'min': [30.1000003814697, 0.0, -6.94999980926514]}] | None; ['../Room407MainLight/LightHum', '../FanAmbience'] |
| 2 | `Floor4/Washroom/ReverbZone` | [{'max': [5.90000009536743, 3.0, -0.0500001907348633], 'min': [0.0999999046325684, 0.0, -4.94999980926514]}] | 2; [] |
| 2 | `Floor4/Washroom/AmbientZone` | [{'max': [5.90000009536743, 3.0, -0.0500001907348633], 'min': [0.0999999046325684, 0.0, -4.94999980926514]}] | None; ['../WashroomLight/LightHum', '../WaterDrips'] |
| 2 | `Floor4/DutyDesk/ReverbZone` | [{'max': [44.0, 3.0, 4.0], 'min': [38.0, 0.0, 0.0]}] | 1; [] |
| 2 | `Floor4/DutyDesk/AmbientZone` | [{'max': [44.0, 3.0, 4.0], 'min': [38.0, 0.0, 0.0]}] | None; ['../SpeakerIdle'] |
| 3 | `Floor4/Corridor/ReverbZone` | [{'max': [44.0, 3.0, 4.0], 'min': [0.0, 0.0, 0.0]}] | 1; [] |
| 3 | `Floor4/Corridor/AmbientZone` | [{'max': [44.0, 3.0, 4.0], 'min': [0.0, 0.0, 0.0]}] | None; ['../CorridorLight_401/LightHum', '../CorridorLight_402/LightHum', '../CorridorLight_403/LightHum', '../CorridorLight_404/LightHum', '../CorridorLight_405/LightHum', '../CorridorLight_406/LightHum', '../CorridorLight_407/LightHum', '../CorridorLight_408/LightHum', '../CorridorLight_Desk/LightHum', '../YardInsects'] |
| 3 | `Floor4/Room407/ReverbZone` | [{'max': [37.9000015258789, 3.0, -0.0500001907348633], 'min': [30.1000003814697, 0.0, -6.94999980926514]}] | 0; [] |
| 3 | `Floor4/Room407/AmbientZone` | [{'max': [37.9000015258789, 3.0, -0.0500001907348633], 'min': [30.1000003814697, 0.0, -6.94999980926514]}] | None; ['../Room407MainLight/LightHum', '../FanAmbience'] |
| 3 | `Floor4/Washroom/ReverbZone` | [{'max': [5.90000009536743, 3.0, -0.0500001907348633], 'min': [0.0999999046325684, 0.0, -4.94999980926514]}] | 2; [] |
| 3 | `Floor4/Washroom/AmbientZone` | [{'max': [5.90000009536743, 3.0, -0.0500001907348633], 'min': [0.0999999046325684, 0.0, -4.94999980926514]}] | None; ['../WashroomLight/LightHum', '../WaterDrips'] |
| 3 | `Floor4/DutyDesk/ReverbZone` | [{'max': [44.0, 3.0, 4.0], 'min': [38.0, 0.0, 0.0]}] | 1; [] |
| 3 | `Floor4/DutyDesk/AmbientZone` | [{'max': [44.0, 3.0, 4.0], 'min': [38.0, 0.0, 0.0]}] | None; ['../SpeakerIdle'] |
| 4 | `Floor4/Corridor/ReverbZone` | [{'max': [44.0, 3.0, 4.0], 'min': [0.0, 0.0, 0.0]}] | 1; [] |
| 4 | `Floor4/Corridor/AmbientZone` | [{'max': [44.0, 3.0, 4.0], 'min': [0.0, 0.0, 0.0]}] | None; ['../CorridorLight_401/LightHum', '../CorridorLight_402/LightHum', '../CorridorLight_403/LightHum', '../CorridorLight_404/LightHum', '../CorridorLight_405/LightHum', '../CorridorLight_406/LightHum', '../CorridorLight_407/LightHum', '../CorridorLight_408/LightHum', '../CorridorLight_Desk/LightHum', '../YardInsects'] |
| 4 | `Floor4/Room407/ReverbZone` | [{'max': [37.9000015258789, 3.0, -0.0500001907348633], 'min': [30.1000003814697, 0.0, -6.94999980926514]}] | 0; [] |
| 4 | `Floor4/Room407/AmbientZone` | [{'max': [37.9000015258789, 3.0, -0.0500001907348633], 'min': [30.1000003814697, 0.0, -6.94999980926514]}] | None; ['../Room407MainLight/LightHum', '../FanAmbience'] |
| 4 | `Floor4/Washroom/ReverbZone` | [{'max': [5.90000009536743, 3.0, -0.0500001907348633], 'min': [0.0999999046325684, 0.0, -4.94999980926514]}] | 2; [] |
| 4 | `Floor4/Washroom/AmbientZone` | [{'max': [5.90000009536743, 3.0, -0.0500001907348633], 'min': [0.0999999046325684, 0.0, -4.94999980926514]}] | None; ['../WashroomLight/LightHum', '../WaterDrips'] |
| 4 | `Floor4/DutyDesk/ReverbZone` | [{'max': [44.0, 3.0, 4.0], 'min': [38.0, 0.0, 0.0]}] | 1; [] |
| 4 | `Floor4/DutyDesk/AmbientZone` | [{'max': [44.0, 3.0, 4.0], 'min': [38.0, 0.0, 0.0]}] | None; ['../SpeakerIdle'] |
