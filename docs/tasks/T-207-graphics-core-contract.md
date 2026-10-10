# T-207 — Hợp đồng và tích hợp core cho đồ họa gần chân thực
- Lane: core, **Claude Code web làm phần core theo D-077** | Trạng thái: **ready — G0** | Agent: Claude web
- Nhánh: `core/T-207-graphics-core-contract`, tạo từ `origin/main` có D-077.
- Phụ thuộc: D-076, D-077; đọc `docs/design/GRAPHICS_UPGRADE_PLAN.md`. G0 độc lập; wiring sau G1 và đầu ra T-208…T-212 tương ứng.
- Hạn đề xuất: gửi hợp đồng sơ bộ trong phiên đầu 10–11/10; phần tích hợp theo từng đợt, không hứa hoàn thành cả game trong hai ngày.

## Bối cảnh
Tầng 4/phòng 407 dùng chung bốn chương. Director chương 2–4 kế thừa nhau; core vẫn tự tạo hình nút báo cháy trong `_place_fire_alarm`, giữ `FireAlarm1F`, `FIRE_ALARM_AT`, `FIRE_BELL_AT`, `FIRE_BELL_SECONDS`, `FIRE_BELL_STREAM`. D-075 kéo bốn xác, chuông chỉ chương 3. Nhân vật gọi `set_body`, pose, marker; hình mới phải khớp luật cũ.

## Việc theo từng phần bàn giao
1. **G0 — khảo sát và hợp đồng:** tạo `docs/design/graphics/ASSET_BINDINGS.md`: scene/chương, root/NodePath thật, collider, marker, API/signal, clip/timing và bên sở hữu. Bắt đầu với cửa/giường 407, ba xác, quản lý, đồng đội, bình cứu hỏa, chuông tầng 1. Ghi transform thật từ scene/mã nguồn; không bịa số đo. Kiểm các nơi core đang dựng visual hoặc hardcode đường dẫn.
2. Tạo `docs/design/graphics/INTEGRATION_CONTRACT.md`: cách giữ root, chuẩn hóa visual, gọi adapter, nhận marker, fallback khi model thiếu, trách nhiệm A/B/C/D/F (F tiếp nhận âm thanh từ E theo D-078). Tiếp nhận đề xuất schema/asset ID/settings của các lane qua Handoff; chỉ ghi thay đổi tối thiểu cần cho pilot. Ghi riêng đề xuất key/default/ai ghi/ai đọc để integrator cập nhật `docs/SETTINGS.md` ở G1.
3. **Sau G1:** chuẩn bị điểm nối core nhỏ, có test hành vi thật, model cũ vẫn hoạt động. Không thêm hệ thống registry/autoload tổng quát nếu không có nhu cầu cụ thể. Chưa đổi main scene, mặc định hình ảnh hay luật chơi.
4. **G2/G3:** khi asset B/âm F và adapter A đã có, nối từng phần vào core. Với chuông, chỉ thay phần nhìn/nguồn âm; giữ tọa độ mồi, bán kính tiếng động, số xác, thời lượng và điều kiện chỉ chương 3. Không gọi cùng sự kiện từ cả animation mới lẫn director gây kích hoạt hai lần.
5. Ghi bảng đầu ra đã sẵn sàng/chờ dependency, cách quay lại bản trước, lệnh kiểm trên Windows cho integrator. Phần đồ họa thực phải được máy có GPU kiểm sau.

## Được phép sửa — ngoại lệ cho web D-077
Chỉ `docs/design/graphics/INTEGRATION_CONTRACT.md`, `docs/design/graphics/ASSET_BINDINGS.md`, `game/scripts/core/` và `game/scenes/main/` **ở các điểm nối visual của card**, `game/tests/core/`, Handoff/checklist card này. Đổi `game/project.godot`, `docs/SETTINGS.md`, `game/data/` hay file lane phải ghi yêu cầu cho integrator, chưa tự sửa. Không sửa STATUS/DECISIONS, lời thoại, save/checkpoint, AI hay file B/A/D/F/C.

## Test và bằng chứng
- Linux cloud: chạy toàn bộ test baseline trước sửa, sau sửa và check; ghi lỗi nền nếu có, không tự quy lỗi là do Linux khi chưa có bằng chứng. Không được thêm lỗi mới. Nếu launcher không chạy được, dùng Godot 4.7.2 headless trực tiếp và ghi lệnh/giới hạn check.
- Khi có wiring: test trên scene chương thật, cả có/thiếu visual mới; flags, tín hiệu, kết quả sống/chết và timing liên quan phải giữ đúng. Gỡ wiring cần thiết hoặc bỏ marker bắt buộc phải khiến test hợp đồng thất bại; không chấp nhận test chỉ gọi mock.
- Chuông vẫn chỉ chương 3, không tự phát thêm ở chương 4 kế thừa; một lần dùng chỉ phát một sự kiện mồi. Kiểm các hồi quy D-069…D-075 tương ứng.
- Cloud không có GPU: không báo đã chụp/đạt FPS/chơi tay. Integrator chạy lại đầy đủ trên Windows trước merge.

## Checklist hoàn thành
- [ ] G0: bảng binding có căn cứ, contract và yêu cầu settings gửi review
- [ ] G1: contract đã được integrator ghép; dependency xác định rõ
- [ ] Wiring từng phần giữ hành vi cũ và có test phù hợp
- [ ] Test baseline/sau sửa/check được ghi trung thực
- [ ] Handoff nêu phần còn chờ, không ghi done cả gói khi mới xong G0

## Handoff (agent điền)
Chưa bắt đầu. Đã có phân công; chưa có kết quả triển khai.

## Review (integrator)
Chưa review triển khai. Mốc G1/G3 cần review riêng; không coi card là kết quả nghiệm thu.
