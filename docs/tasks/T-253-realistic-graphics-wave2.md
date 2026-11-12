# T-253 — Đồ hoạ thật đợt 2: hành lang tầng 3→1, phòng 203, sảnh, phòng quản lý, bình cứu hoả, hộp báo cháy (nhà B)
- Lane: **chưa giao** (chờ chủ dự án duyệt ảnh đợt 1 [T-250](T-250-realistic-graphics-wave1.md) và mẫu thử lane Codex [T-252](T-252-floor4-rooms-sample-codex.md)) | Trạng thái: chờ | Agent: lane B (Opus 5.5 xhigh/max), hoặc chia cho lane Codex nếu T-252 đạt.
- Nhánh: `lane-<x>/T-253-realistic-graphics-wave2` từ `origin/main` mới nhất (sau khi T-250 merge).
- Quyết định: **D-165, D-166** (10 đợt theo đường người chơi đi; dựng bằng Blender theo chất lượng phòng 407, không ưng thì đổi Tripo; nhà B cũ vừa; ánh sáng giữ như nay). Card viết sẵn 13/11/2026 để giao ngay khi đợt 1 được duyệt.

## 1. Phạm vi (`art_source/graphics_upgrade/realistic_map/PLAN.md` mục 2–4)
| Mã | Khu | Scene và node | Làm, phải giữ |
|---|---|---|---|
| A08 | Tầng 3 nhà B | `campus/building_b.tscn` → `Floor3`, `KitDetail3` | Hành lang, vách, bảng số, đèn, lan can (bộ dùng chung với tầng 2 và 1, theo kiểu đợt 1); phòng sau cửa chỉ làm mặt nhìn thấy. Giữ chặn cửa, chỗ xác xuất hiện và phá cửa. |
| A09 | Tầng 2, phòng 203 | `Floor2`, `KitDetail2`, `Room203Bed`, `Room203Desk` | Như A08; phòng 203 dùng giường và bàn bản nhẹ của phòng 407. Giữ cửa 203 mở lúc đầu, chỗ Minh Nhật, tuyến cứu, `Room203Door` (13,75; −6,6; 0). |
| A10 | Tầng 1, sảnh, phòng quản lý, cửa sổ | `Floor1`, `KitDetail1`, `MainDoor`, `ManagerDesk`, `Knife`, `Window*`, `GlassShard`, `LobbyRail` | Sảnh, cửa chính và xích, bàn quản lý, dao, khung cửa sổ, kính vỡ. **Bậu cửa sổ và đường bước khớp va chạm** (T-247 dòng 10; `ManagerWindow` (4; −8,9; −7,6), bậu cao 1 m). Cửa chính vẫn không là lối thoát; cửa sổ vẫn đi khom qua, không thêm gợi ý (D-055). |
| A11 | Bình cứu hoả tầng 2, hộp báo cháy tầng 1 | `BuildingB/FireExtinguisher`, `ExtinguisherHandle`; `Anchors/FireAlarm1F` (core dựng hộp lúc chạy) | **Dựng bằng Blender** (PLAN đề xuất Tripo cho bình; D-166: Blender trước). Gá bình, cổ bình và tay cầm rõ; hộp báo cháy có mặt nút. Giữ `Use_Extinguisher2F` (48,83; −5,5; 2,4), `Use_FireAlarm1F` (0,9; −8,5; 0,12; cao 1,4 m), âm thanh, tầm thu hút. Hộp báo cháy do core dựng: lane làm glb, ghi "Yêu cầu thay đổi" để integrator thay chỗ core dựng hộp. |

Động tác Trần Trung ở đây (T-247 dòng 7 bình cứu hoả, 8 báo cháy, 10 cửa sổ) **không làm ở card này**; chỉ dựng hình sao cho làm được sau (bình tách khỏi gá, nút báo cháy là node riêng, bậu khớp va chạm).

## 2. Cách làm, kiểm, phạm vi file
- Như [T-250](T-250-realistic-graphics-wave1.md) mục 3–6, dùng lại bộ vật liệu và chi tiết đợt 1 đã được duyệt.
- Ngân sách (PLAN mục 6): A08–A10 ≤ 0,50 ms cho tầng đang đi (không vẽ nội thất ba tầng cùng lúc); A11 ≤ 0,10 ms.
- Ảnh trước/sau 1080p trong chương 3 thật: `art_source/graphics_upgrade/realistic_map/previews/wave2/` (ảnh hiện trạng `previews/survey/16`–`25`).
- Được sửa: phần hình A08–A11 trong `campus/building_b.tscn`, `art_source/graphics_upgrade/realistic_map/wave2/`, `game/assets/models/graphics_pilot/realistic_map/wave2/`, `game/assets/textures/`, test mới `game/tests/levels/`, card này.
- Không được: va chạm, navmesh, director, `Ch3Use`, luật; Tripo; bot, FPS.

## Checklist
- [ ] A08 tầng 3
- [ ] A09 tầng 2, phòng 203
- [ ] A10 tầng 1, sảnh, phòng quản lý, cửa sổ
- [ ] A11 bình cứu hoả, hộp báo cháy
- [ ] Test, full test, check, ảnh, Handoff

## Handoff
(lane được giao điền)
