# T-187 — Hành lang nhà B rộng 4 m

Theo D-058, hành lang tầng 1–4 mở từ z=0..2,4 sang z=0..4,0;
x=0..44 và cao độ tầng giữ nguyên. Sàn, trần, lan can, dây phơi, đèn,
chiếu nghỉ, sảnh và vỏ tầng 5–6 mở về +z. Tường và cửa phía phòng,
phòng 407 bản 2 và nội thất không đổi. Bàn trực, bảng, loa và nhà vệ sinh
giữ vị trí gần tường; vùng âm thanh hành lang/bàn trực phủ chiều rộng mới.

Navmesh các tầng phủ phần hành lang mới. Tầng 4 có NavigationRegion và
link vào 407 để dùng độc lập trong chương 1–2; khi Campus gắn vào,
`campus.gd` tạm tắt hai node này để tránh trùng vùng nav, rồi khôi phục khi
Campus rời cây. Cửa thoát hiểm giữ API và chốt cũ; cánh mở rộng để không
thể lách qua mép mới khi cửa đóng. Lối ra sảnh nối lại với nav ngoài sân.
Vườn bắt đầu ở z=8, ngoài mép hành lang z=4 nên không cần dời cây/bồn.

`Corridor` của CCTV đã nới sàn, trần, đầu hồi, tường ngoài và đặt lại camera
nhìn về cửa phòng. Các phòng CCTV khác không đổi.

## Dựng lại

Chạy từ gốc repo, dùng Python stdlib có sẵn (máy này ở
`D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe`):

```powershell
python art_source/wide_corridors/widen_existing.py
python art_source/campus/build_campus.py --detail
python art_source/wide_corridors/report.py
```

`widen_existing.py` chỉ sửa các node cần thiết trong scene hiện tại và có
thể chạy lặp. Các thông số tương ứng trong nguồn generator tầng 4/CCTV
cũng được đồng bộ. **Không chạy lại toàn bộ `floor4/build_floor4.py` lên
bản tích hợp:** generator cũ chứa phòng 407 đời trước; patch hẹp giữ phòng
407 bản 2 hiện tại. Không có asset ngoài hoặc plugin mới.

## Kiểm tra và ảnh

```powershell
pwsh tools/test.ps1 -Filter levels
pwsh tools/test.ps1 -Filter wide_corridors
pwsh tools/test.ps1
pwsh tools/check.ps1
```

Test mới đo cả bốn tầng, cast liên tục capsule cao 1,75 m/bán kính 0,3 m
dọc z=3, kiểm tra sàn/lan can/chiếu nghỉ, cửa thoát hiểm, nav độc lập tầng 4
và camera CCTV. Test Campus hiện có kiểm tra nav 407 → nhà ăn.

Ảnh 1280×720 chụp bằng `capture.gd`, cùng camera/FOV trước và sau.
Ảnh trước lấy từ scene `8110f4b` trước khi đổi hình học. Để chụp lại ảnh sau:

```powershell
D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --path game --script ../art_source/wide_corridors/capture.gd -- --phase=after
```

| Góc nhìn | Trước | Sau |
|---|---|---|
| Hành lang tầng 4 | [Ảnh](previews/floor4_before.png) | [Ảnh](previews/floor4_after.png) |
| Hành lang tầng 2 | [Ảnh](previews/floor2_before.png) | [Ảnh](previews/floor2_after.png) |
| Mặt ngoài nhà B | [Ảnh](previews/building_b_before.png) | [Ảnh](previews/building_b_after.png) |

[Bảng mọi anchor đã dời](anchor_changes.md) được sinh từ snapshot JSON của
cùng fixture chụp ảnh. Các ảnh/metrics trong `art_source/campus/` là bằng
chứng T-183 trước đây, không phải số đo T-187. Chưa chơi thủ công xuyên
suốt chương 1–3; kết quả tự động cuối cùng ghi tại Handoff task T-187.
