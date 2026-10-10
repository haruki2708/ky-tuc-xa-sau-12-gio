# T-209 — G0 kiểm kê và thử vật liệu

**Bản nháp gửi G1; không phải bản thay phòng chơi.** Nguồn `origin/main` ở `e3ed54a`, có D-077/D-078. Chỉ sửa vùng B và Handoff/checklist T-209. G1/G2 chưa đủ; Meshy chưa gọi, credit 0.

## Đầu ra để web/integrator review

- [Manifest nháp](asset_manifest.json): 15 mục ưu tiên phòng 407/hành lang, bình cứu hỏa và nút/chuông. ID và cấu trúc **chưa phải schema C T-210**. Có scene/node nguồn, pivot/hướng, khoảng nhìn đề xuất, marker/tương tác cần giữ, nguồn/license và cách làm dự kiến.
- [Bảng số đo](MEASUREMENTS.md): 13 mục đã đo; hai mục runtime chưa có mesh tĩnh được tách rõ. Balo hiện hành 96 tam giác, cửa 120; cụm giường gồm mùng/biến thể nên không so số gộp với trần một model.
- `measured_assets.json`: đầu ra của `measure_assets.gd` sau lượt Godot được xếp. AABB là bounds gộp MeshInstance3D trong hệ cục bộ node, bao gồm biến thể ẩn; vị trí là transform cộng dồn tới root scene nguồn. Đếm material và texture **albedo** hiện có, không phải số tam giác mỗi frame/draw call/VRAM. Không tính geometry core sinh runtime, shader displacement hoặc MultiMesh; riêng nút/chuông ghi căn cứ mã nguồn trong manifest.
- [Brief/prompt](BRIEFS.md): tiếng Anh để operator/Blender dùng sau khi chốt G1/G2; chưa gửi dịch vụ.
- [Nguồn](CREDITS.md): dùng CC0 nội bộ; texture mới sinh bằng mã với seed cố định. Không nhập ảnh bên ngoài hoặc tự đổi license Pro Private.
- Scene thử: `res://scenes/levels/graphics_pilot/material_pilot.tscn`. Chụp 3 góc × 2 ánh sáng × before/after = 12 ảnh tại `previews/`; `capture_report.json` ghi camera/FOV, viewport thật, renderer, GPU và brightness. Ảnh này là **fixture tĩnh**, không phải bằng chứng chơi qua bốn chương.

## Số đo/chỗ nối cần giữ

| Mục | Căn cứ scene/code hiện hành | Hệ tọa độ / ràng buộc |
|---|---|---|
| Phòng 407 | Root `(30,0,0)`; sàn hộp `8 × 0.2 × 7`, tâm local `(4,-0.1,-3.5)`; tường `0.2 × 3 × 7` | Mặt sàn world y=0; phòng mở rộng còn phần Extension, không coi 8×7 là toàn bộ diện tích dùng |
| Giường A | local root `(0.65,0,-3)`; nệm y=0.43 / 1.20 | World x=30.65; giữ View/Exit và Corpse1/2 |
| Giường B | local root `(7.35,0,-2.7)`; nệm y=0.43 / 1.20 | World x=37.35; giữ View/Exit, Corpse4; không có Corpse3. README T-153 cũ còn x=3.35, **không dùng số cũ** |
| Cửa 407 | root/bản lề `(32.44,0.01,0)`, cánh đóng theo -X; mở yaw=-π/2 | Không recenter cánh. Giữ RulesPaper, HandlePivot, InteractShape và thời gian core gọi |
| Hành lang | sàn hộp 44×0.2×4; góc pilot từ x=28 tới x=40 | Giữ scene T-206; không chạy lại generator cũ, không sửa tấm 408 |
| Bình cứu hỏa | thân `(48.86,-5.8,2.4)`, tay cầm `(48.86,-5.5,2.4)`; marker `(48.83,-5.5,2.4)` | World/campus; marker lệch tâm thân, phải giữ. Collider tương tác `.5×.8×.5` do core sinh |
| Nút báo cháy | `_place_fire_alarm()`: tâm `(.9,-8.5,.12)`, visual `.22×.28×.06`, collider `.5×.6×.5` | Chỉ sinh runtime chương 3. B không sửa director; web nối asset sau G1 |
| Chuông | `FIRE_BELL_AT=(42,-9.9,2)` là điểm noise/crowd; âm thực cộng `(0,2.2,-1.8)` → `(42,-7.7,.2)` | **Hai điểm có vai trò khác nhau.** F/web chốt mount và kích thước visual; không kéo âm về nút |

Khoảng cách trong manifest là **đề xuất kiểm hình**, chưa phải số đo người chơi. B chưa hứa model mới tương thích rig A hoặc đặt tên marker mới. Chốt riêng mount chuông, hướng bình cứu hỏa và nguyên tắc wrapper transform tại G1.

## Cảnh thử làm gì

Lấy bản sao MeshInstance3D, Light3D, WorldEnvironment và hệ transform từ floor4 hiện hành nhưng không đưa scene nguồn vào cây chạy. Bản sao không script gameplay, audio, collision, nav hoặc bot; Label3D, particle và animation không được dựng lại. Đặt lại ba vật liệu sàn/tường mà `room407.gd` thường gán trong `_ready`; ẩn các lớp máu/rách chưa kích hoạt và mixer bị thay bởi màn hình. Đây là baseline tĩnh có giới hạn: không tái hiện mọi thay đổi tint/pose runtime của chapter, không dùng để nghiệm thu chữ trên biển/UI.

After chỉ thay vật liệu tường, gạch, thanh sắt giường và vải giường Trung. Sắt được gán từng surface, giữ gỗ/vải của GLB nhiều vật liệu; `bunk_trung` dùng alias iron→ink theo `build_assets.py`, không coi mọi texture ink là sắt. Bốn `StandardMaterial3D` dùng 12 map 256² (albedo, roughness, tangent normal), triplanar theo mét, lọc linear+mipmap. Không tăng mesh hoặc đổi ngưỡng production; chất liệu thủ tục là mẫu so sánh, **chưa đạt cam kết gần chân thực cuối**. Normal lấy từ height thủ tục, không có bake ánh sáng. Triplanar giúp thử tỉ lệ; UV cuối phải xử lý theo GLB ở G2.

Before bật filter PS1; after strength và global snap=0 trong tiến trình fixture. Brightness vẫn lấy `[video] brightness` qua API `Settings.get_value` đã có, chỉ đọc. Không thêm setting/key mới và không lưu `settings.cfg`.

Hai bộ ánh sáng: `game` sao môi trường/đèn khai báo trong scene (đèn chính phòng đang 0, đèn bàn .5; không giả lập flicker); `neutral` tạm ẩn đèn màu game, thêm đèn kiểm và ambient trung tính, tắt fog. Chuyển về game phục hồi trạng thái hiện ban đầu của đèn. Cặp before/after giữ camera/đèn giống nhau. Không LightmapGI/bake nguồn chuyển trạng thái. Cần kiểm đèn bật/tắt, máu/nệm rách và bốn chương khi G3 có wiring thật.

Góc `corridor` là ảnh đối chiếu filter và bối cảnh; G0 chưa nâng toàn bộ vật liệu hành lang. Không coi 12 m thấy qua camera là một module hành lang G2 đã hoàn thiện.

| Góc / ánh sáng | Trước | Sau |
|---|---|---|
| Phòng / trung tính | [PNG](previews/room_neutral_before.png) | [PNG](previews/room_neutral_after.png) |
| Phòng / game | [PNG](previews/room_game_before.png) | [PNG](previews/room_game_after.png) |
| Cận vật liệu / trung tính | [PNG](previews/materials_neutral_before.png) | [PNG](previews/materials_neutral_after.png) |
| Cận vật liệu / game | [PNG](previews/materials_game_before.png) | [PNG](previews/materials_game_after.png) |
| Hành lang / trung tính | [PNG](previews/corridor_neutral_before.png) | [PNG](previews/corridor_neutral_after.png) |
| Hành lang / game | [PNG](previews/corridor_game_before.png) | [PNG](previews/corridor_game_after.png) |

Nhận xét G0: gạch và vải bớt nhiễu nearest/dither; mùng, tủ và vách Extension còn texture/geometry PS1. Ánh sáng game đang tối, chưa đủ đánh giá chi tiết mặt/tay. Chưa có bevel, UV hoàn thiện, bộ bẩn do sử dụng hoặc rig mới; cần G2 và review người dùng để chốt chất lượng gần chân thực. Kết quả kiểm chứng cuối xem Handoff T-209.

## Chạy lại sau khi được xếp lượt Windows

Chạy từ `D:\GAME_WORK\lane-b`; không chạy đồng thời với full test/render lane khác. Không đóng/kill tiến trình của lane khác. Script `tools/test.ps1` tự import và tự cô lập dữ liệu test. Lượt render/đo nên đặt APPDATA tạm dưới `build/graphics-pilot-userdata` để không tác động dữ liệu người chơi qua autoload; phục hồi biến môi trường sau chạy. Không truyền tham số autoplay/FPS.

```powershell
python art_source/graphics_upgrade/generate_materials.py
# Full test tự import các PNG/script mới trước khi chạy probe/capture.
pwsh tools/test.ps1
& D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game res://scenes/levels/graphics_pilot/measure_assets.tscn -- --pilot-measure
& D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --path game --rendering-method forward_plus --windowed --resolution 1280x720 res://scenes/levels/graphics_pilot/material_pilot.tscn -- --pilot-capture
pwsh tools/check.ps1
```

1280×720 dùng review vật liệu, **không chứng minh mục tiêu 1080p/60 FPS**. Chưa được đo FPS. Không export game, không thay mặc định. `game/tests/levels/test_graphics_pilot.gd` kiểm fixture không có script gameplay/collision/audio và không ghi settings, kiểm chuyển trước/sau phục hồi material và giữ brightness.

## Các quyết định cần G1/G2

1. Web/C thống nhất ID/schema manifest, quy ước bounds (assembly so với từng mesh, biến thể ẩn), hướng/pivot và số material/texture cần thu thập. Probe của B là báo cáo khảo sát, không thay công cụ QA C.
2. Web/A chốt visual root, rig/clip và marker. B giữ các path hiện hành; không tự nối model vào director hoặc adapter.
3. Web/F chốt visual chuông tại nguồn âm xa nút, kích thước/mount/basis, tránh thay đổi điểm noise/crowd.
4. D/web chốt contract settings; G0 chỉ dùng brightness hiện hành, không đề xuất key giả định trong code.
5. Integrator duyệt budget thử dựa số đo; người dùng/operator cấp kết nối, trần credit, license trước một asset Meshy. Dự kiến chọn balo đầu tiên, chưa đặt tác vụ.
6. Người dùng review ảnh thực trước khi G2/G3; test ray/collision/nav/đèn trong cả bốn chương và nhân vật có ảnh biến dạng còn chưa đạt. G0 không đồng nghĩa T-209 done.

Đối chiếu ngày 11/10 với draft T-207 `4fc4999` trên nhánh `core/T-207-graphics-core-contract`: đề xuất `FireBellMount` khớp vị trí âm nêu trên, nhưng chưa được ghép main. Schema `asset_id/scene_path/binding/...` của web là đầu vào cho C/B ở G1; dữ liệu nháp hiện tại chưa tự nhận tương thích schema đó. Các key video mới chưa được dùng. Cửa chương 3–4 có proxy/Blocker khác chương 1–2; fixture tĩnh này không chứng minh tương tác của cả hai cơ chế.
