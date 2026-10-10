# T-209 — Pipeline mỹ thuật và phòng 407 gần chân thực
- Lane: B | Trạng thái: **ready — G0** | Agent: lane B
- Nhánh: `lane-b/T-209-realistic-art-pilot`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 không cần Meshy. G1 theo T-207, rig theo T-208, manifest/công cụ T-210, settings T-211, marker âm T-212.
- Hạn đề xuất: phiên đầu gửi kiểm kê/ảnh tham chiếu/pilot vật liệu; mở rộng sau khi phòng mẫu được duyệt.

## Bối cảnh
Tầng 4/phòng 407 dùng chung cả bốn chương; map và đường đi đã sửa qua T-203/T-206, D-058/D-062/D-075. Godot dùng Forward+, shader PS1 chủ yếu albedo nearest. Khuôn viên đã chia cụm/giới hạn hiển thị; không chạy generator cũ làm mất sửa chữa. Nhân vật B đang tự dựng khớp, cần phối hợp adapter A.

## Việc và các phần có thể chia nhỏ
1. **G0 — kiểm kê và mẫu nhìn:** tạo `art_source/graphics_upgrade/README.md`, `asset_manifest.json` (bản nháp tới G1), `CREDITS.md` và brief/prompt tiếng Anh cho asset. Ghi mỗi món: scene đang dùng, kích thước/pivot/hướng đo được, khoảng cách nhìn, tương tác/marker phải giữ, nguồn/license, tự dựng hay Meshy. Ưu tiên phòng 407/hành lang và bình cứu hỏa/nút+chuông báo cháy.
2. Tạo cảnh thử riêng `game/scenes/levels/graphics_pilot/` dùng mesh hiện có/CC0 để so vật liệu và ánh sáng. Thử tường, gạch, sắt, vải; tắt PS1 trong cảnh thử nhưng giữ độ sáng hoạt động. Chụp trước/sau cùng góc bằng renderer thật; không đổi mặc định bốn chương trước G3.
3. **G2 — pipeline Meshy/Blender:** sau khi operator nhận ngân sách, thử một đạo cụ; kiểm mặt sau, normals, UV, texture, kích thước, pivot, vật liệu, LOD, import GLB. Mẫu thử đề xuất: balo, giày, bình cứu hỏa, quạt; không cần tạo cả bốn trong một lần hoặc vượt trần được giao. Ghi credit và công sửa từ log C, đánh giá giá trị trước khi tạo thêm.
4. **G2 — phòng mẫu và một nhân vật:** hoàn thiện module giường/cửa/tủ đúng kích thước bằng Blender, ánh sáng phòng 407 + 10–15 m hành lang. Dựng một sinh viên với rig/clip/marker theo contract A; kiểm đứng/đi/nằm/ngồi/quay đầu. Dùng shader PBR phù hợp, không đưa texture 4K/8K hàng loạt vào game.
5. **G3/G4 — sản xuất theo đợt:** phòng/tầng 4 → phần còn lại nhà B → quản lý/ba bạn/đồng đội/xác → vườn/sân/cổng/nhà ăn → thư viện/bệnh viện. Cùng bộ vật liệu và tỉ lệ; biến thể dùng lại mesh. Mỗi nhóm có ảnh và test rồi mới merge.

## Được phép sửa
Vùng B: `art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`; Handoff/checklist card. Prototype mới đặt dưới `graphics_upgrade`/`graphics_pilot` khi thích hợp. Không sửa core, AI/adapter vùng A, project.godot, SETTINGS, menu, audio. Cửa/core sinh ra bằng code phải gửi asset/đường dẫn cho web nối.

## Tiêu chuẩn và test
- Dùng kế hoạch §6; budget gần chân thực là đề xuất cho prototype, chưa tự nới các ngưỡng PS1 hiện có. Báo số tam giác/material/texture thật cho G1/G2; file <10 MB, Git LFS, commit import/uid cần thiết.
- Với đồ thay thật: bounds visual khớp collider, bản lề/giường/marker đúng; kiểm tia ngắm, đường đi và phòng 407 trong cả bốn chương. Không tái tạo z-fighting tấm 408; giữ các khoảng thông và tọa độ thế giới.
- Đèn có bật/tắt phải đổi sáng đúng; bake không để nguồn đèn đã tắt còn sáng sai cơ chế. Prototype không làm settings người dùng bị lưu đè.
- Chụp ảnh ở ánh sáng trung tính và trong cảnh game; so cùng camera. FPS chưa được phép thì ghi chưa đo. Mặt/tay/biến dạng animation cần ảnh thực, không chỉ text test.
- `pwsh tools/test.ps1`, `pwsh tools/check.ps1` đầy đủ. Ghi rõ cái gì mới ở cảnh thử, cái gì đã gắn vào chương.

## Checklist hoàn thành
- [ ] G0: kiểm kê/brief/nguồn và cảnh vật liệu riêng
- [ ] G1: manifest/marker/budget thử thống nhất
- [ ] G2: một asset đi hết pipeline và phòng mẫu có ảnh
- [ ] Nhân vật mẫu hoạt động với adapter A
- [ ] Các đợt G3/G4 có review riêng, test/check và người dùng duyệt hình

## Handoff (agent điền)
Chưa bắt đầu. Chưa có tài khoản/API/ngân sách Meshy được xác nhận; vẫn làm được toàn bộ G0.

## Review (integrator)
Chưa review triển khai. Chưa duyệt hình ảnh phòng mẫu hoặc đổi budget production.
