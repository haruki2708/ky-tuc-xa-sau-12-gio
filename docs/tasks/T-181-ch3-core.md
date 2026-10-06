# T-181 — Chương 3: hợp đồng chung, kịch bản, luồng 4 khu, ghép (core)
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude
- Phụ thuộc: `docs/design/CH3_DESIGN.md` (D-052, D-053, D-054).
- **Hạn đề xuất:** kịch bản 2026-10-07; ghép 2026-10-09; bản chơi thử khoảng 2026-10-10.

## Việc
- **Hợp đồng chung (xong 2026-10-06):** EventBus mục "Chapter 3" (`zombie_woke`, `zombie_stunned`, `bar_picked`, `bar_swung`, `bar_broken`, `stamina_changed`, `companion_state_changed`, `guard_warned`); dùng lại `noise_emitted`, `player_caught(&"zombie"|&"guard")`, `player_death_started(&"zombie_grab"|&"guard_shock")`. Tên scene, node, anchor ghi trong các card T-182…T-186.
- **Kịch bản** `docs/design/ch3/build_ch3_script.py`: lời loa vòng 5, chat (Minh Nhật, Ngư), lời nói trực tiếp của đồng đội, suy nghĩ của Trung, lý do chết `DEATH_CH3_*`, giấy tờ (sổ trực, biển báo), sổ quy tắc `data/rules/ch3.tres`, `CH3_SCRIPT.md`; giọng eSpeak.
- **Luồng** `scripts/core/chapter3_director.gd` (kế thừa `Chapter1Director` như chương 2) và `scenes/main/chapter3.tscn` (Floor4 + Campus + UI):
  - 4 khu, checkpoint `ch3_b`, `ch3_garden`, `ch3_stadium`, `ch3_gate`;
  - đợt xác theo khu và theo giờ, giới hạn số xác hoạt động;
  - dẫn đồng đội theo đường của lane B;
  - cắt thời gian trống; kết chương mở khóa chương 4.
- **Ghép** T-182…T-186, test, export.

## Handoff
### Phiên 2026-10-06 (Claude): kịch bản, luồng 4 khu, ghép 5 lane
- **Kịch bản** `docs/design/ch3/build_ch3_script.py` → `CH3_SCRIPT.md`, `data/rules/ch3.tres`, 4 tin nhắn gọi, 44 chuỗi; lời Minh Nhật và Ngư nói trực tiếp có key `NEAR_CH3_*` (giọng phát tại chỗ nhân vật). D-055: bỏ 2 câu gợi ý, tivi nói rõ chuyện động đất. Giọng: `audio_source/ch3_voice_process.py`, 25 câu (Minh Nhật, Ngư ×1,25; tivi qua loa nhỏ rè).
- **Luồng** `scripts/core/chapter3_director.gd` (`Chapter3Director extends Chapter1Director`), `scenes/main/chapter3.tscn` (Floor4 + Campus + UI); `App.CHAPTER_SCENES[3]`; `chapter1_main._director()` nhận cả director chương 3.
  - Khu `b`: loa vòng 5 → ba bạn cùng phòng thành xác (mô hình lane B) → ra hành lang (`corridor_turn`) → chìa khóa và cửa thoát hiểm (`Ch3Use`) → tầng 3, tầng 2 → bình cứu hỏa phát tiếng 25 m → Minh Nhật đi cùng → tầng 1 → vườn hoa.
  - Khu `garden`: Ngư ở ghế đá, tới gần thì trao thanh sắt (`give_bar(8)`, trừ khi đã nhặt); đợt xác; ra sân vận động.
  - Khu `stadium`: đèn sân chớp một lần; mỗi 25 giây một đợt 6 xác trong 240 giây (theo `time_scale`); còi chỉ bật ở khán đài; ra cổng.
  - Khu `gate`: bảo vệ quay đầu khi tới gần 12 m; nhà ăn: tivi bật và đọc bản tin; chia nhau ra; `end3` mở khóa chương 4, `chapter_finished(3)` (thẻ của lane D).
  - Nạp checkpoint giữa chương: đứng ở `Start_<khu>`, đồng đội bắt đầu từ điểm chờ của khu (bản sao đường từ điểm đó).
- **Nối lane:**
  - mô hình lane B cho từng xác (`zombie_01…10`), đồng đội, bảo vệ;
  - `ZombieAudio` và `Ch3ZombieLink` (core) trên mỗi xác: săn, đủ điều kiện phát tiếng, bước chân theo quãng đường;
  - `Ch3HordeAudio`, `Ch3PlayerAudio`, `Ch3Environment`, `Ch3Music`, `Ch3SirenAudio`, `Ch3GuardAudio`;
  - `ch3_status` và `ch3_end_card` (lane D);
  - thể lực bật khi vào chương 3;
  - `player_caught(&"zombie")` → `DEATH_CH3_GRABBED`, `&"guard"` → `DEATH_CH3_GUARD`.
- **Lỗi tìm thấy khi ghép:** điểm thanh sắt `BarSpawns/B01` (vườn hoa) nằm **trong** khối va chạm của giường tầng đổ, không nhặt được. Core đặt mọi thanh sắt lên bề mặt đầu tiên phía trên điểm đánh dấu (`_settle_bars`). Lane B nên sửa điểm B01 khi có dịp.
- **Test:** `test_chapter3.gd` (8): đủ thành phần; khu B tới vườn hoa; bị tóm thì chết và nạp lại; Ngư trao thanh sắt; đợt xác ở sân và đèn chớp; cổng, nhà ăn, hết chương; bảo vệ giết; **tia "aim" tới được** chìa khóa, cửa, bình cứu hỏa và 6 thanh sắt (đứng hoặc cúi). `test_chapter3_data.gd` (3).
- **Chưa làm:** đo FPS có vẽ hình (cần chủ dự án cho phép), điền `tools/ch3-profile.json` cho bot, hướng dẫn chơi thử chương 3, chơi tay toàn chương, nghe âm thanh.
- Integrator sửa `test_ch3_ui.gd::test_ch3_death_reasons…`: core đã có chữ thật cho `DEATH_CH3_*` nên test kiểm chữ thật thay cho bảng dịch tạm.
- **Đo FPS** (integrator, được chủ dự án cho phép, 2026-10-06; `tools/ch3-profile.json` điền `performance`): RTX 3050 Laptop, Ryzen 5 5600H, 1280 × 720, VSync tắt, Forward+. FPS trung bình mọi khu từ 117 trở lên, kể cả với 40 xác; vườn hoa nặng nhất (40 xác: trung bình 117–173, p95 15–23 ms, frame tệ nhất 38–49 FPS). Một lần giật 84,8 ms khi công cụ thả 40 xác cùng lúc ở đầu nhà B (game thật thả theo đợt 6). Công cụ báo FAIL chỉ vì frame đó (ngưỡng tệ nhất 30 FPS).
- **Đo FPS lại 2026-10-07** (sau T-190, T-192; chủ dự án cho phép; cùng máy, 1280 × 720, VSync tắt): lần đầu **FAIL** (vườn hoa 40 xác trung bình 84, khung tệ nhất 25 FPS). Nguyên nhân: bản sửa xác lún sàn (`Ch3Actor._lift_out_of_floor`, D-062) hỏi `NavigationServer3D.map_get_closest_point` mỗi xác mỗi nhịp, rất chậm trên lưới ngoài trời. Sửa: chỉ kiểm khi bước đi gần như không nhích, dò bằng một tia ngắn xuống sàn. Đo lại **PASS**: 40 xác trung bình nhà B 229–346, vườn hoa 107–196 (tệ nhất 38), sân vận động 473–521, cổng 309, nhà ăn 174 FPS. Không xác: mọi khu trên 220 FPS (đồ rải T-192 không làm nặng hình).

