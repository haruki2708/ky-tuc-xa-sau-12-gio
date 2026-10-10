# T-212 — Âm thanh theo model mới và chuông báo cháy
- Lane: E | Trạng thái: **ready — G0** | Agent: lane E
- Nhánh: `lane-e/T-212-graphics-audio-anchors`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 độc lập, marker G1 với A/B/web, nối core sau T-207/T-209.
- Hạn đề xuất: phiên đầu có khảo sát marker và mẫu chuông nhỏ để nghe; đồng bộ từng đợt model sau.

## Bối cảnh
Chuông tầng 1 D-075 đang dùng `res://audio/ch1v2/lock_alarm.ogg`, SFX, -4 dB; core giữ thời lượng và sự kiện kéo xác. Người dùng thích âm thanh nhỏ. Quản lý có `BladeTip`; nguồn tiếng gần đầu/tay có thể lệch khi đổi rig. Giọng thoại hiện có đã duyệt, nhiều phần còn chờ nghe bằng tai.

## Việc
1. **G0:** kiểm các nguồn âm bám nhân vật/đồ vật: đầu/miệng, dao, bước chân, cửa, bình cứu hỏa, chuông. Ghi NodePath/marker/event/timing và owner vào Handoff để web đưa vào contract; không tạo cơ chế noise AI mới từ animation.
2. Làm mẫu chuông báo cháy riêng nhỏ, có nguồn/license rõ (CC0/CC-BY hoặc âm tự tạo khai báo phù hợp), dưới `game/audio/graphics_upgrade/` và nguồn ở `audio_source/`. Tạo fixture nghe trong vùng E, cung cấp đường dẫn stream và cách loop/stop. Không tự sửa hằng `FIRE_BELL_STREAM` trong core.
3. **Sau G1:** hỗ trợ marker mới do A/B cung cấp, nguồn âm đi theo model khi di chuyển/animation, không nhân đôi tiếng từ clip và code. Giữ semantics sự kiện, bán kính nghe AI và timing luật; đề xuất đổi âm lượng để người dùng nghe riêng.
4. **G2/G3:** kiểm vật liệu mới với tiếng cửa/kim loại/vải/bước chân bằng asset hiện có, chỉ bổ sung khi thiếu thật. Kiểm ngắt tiếng khi pause/chết/reload và cảnh chuyển. Không thu lại hoặc sửa lời thoại đã duyệt trong task này.
5. Lập danh sách nghe thử: chuông tầng 1, dao/người quản lý, tiếng bình chữa cháy, giọng/tiếng xác và cảnh phòng mẫu. Chủ dự án nghe rồi mới ghi đạt cảm nhận âm lượng.

## Được phép sửa
Vùng E: `audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`; Handoff/checklist card. Không sửa core, model/scene B, gameplay A, settings hoặc strings thoại. Gửi yêu cầu wiring cho T-207, marker cho A/B.

## Test và bằng chứng
- Stream load/decode, loop/stop/pause và dọn player đúng; không nguồn trùng khi reload hoặc thay visual. Marker mất phải báo/fallback theo contract, không phát ở gốc thế giới vô tình.
- Fixture giúp nghe, nhưng chỉ cảnh thật sau ghép mới chứng minh chuông phát đúng nơi và chỉ chương 3. Kiểm phối hợp core: 20 giây theo D-075, sự kiện mồi không phát đôi.
- `pwsh tools/test.ps1`, `pwsh tools/check.ps1` đầy đủ; ghi rõ “chưa ai nghe” khi mới kiểm tự động. Không đổi âm lượng toàn game để bù một sample.

## Checklist hoàn thành
- [ ] G0: bảng marker/event và mẫu chuông có nguồn
- [ ] G1: thống nhất attachment/timing
- [ ] Nối model mới qua đúng owner, không tiếng/sự kiện trùng
- [ ] Test/check PASS và checklist nghe thật
- [ ] Người dùng nghe xác nhận; phần chưa nghe vẫn ghi chờ

## Handoff (agent điền)
Chưa bắt đầu; chưa có xác nhận nghe mẫu chuông mới.

## Review (integrator)
Chưa review triển khai.
