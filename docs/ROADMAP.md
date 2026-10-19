# Bản đồ lộ trình — "Ký túc xá sau 12 giờ"

> **Cập nhật:** 2026-10-16 (sau D-118: G3 xong, G4 bắt đầu bằng nhân vật quản lý, chủ dự án tự làm cùng integrator). Integrator cập nhật file này **mỗi khi qua một mốc** (chốt chương, đóng cổng G, đổi hướng lớn).
> Chi tiết từng ngày: `docs/STATUS.md`. Lý do từng quyết định: `docs/DECISIONS.md` (D-001…D-118).
> Ký hiệu: ✅ xong · 🔶 đang làm · ⬜ chưa bắt đầu · 📍 **đang ở đây**

## 1. Bản đồ tổng

![Bản đồ lộ trình](roadmap.svg)

(Ảnh `docs/roadmap.svg` sinh bằng `python docs/build_roadmap_svg.py`: sửa danh sách `phases` trong script rồi chạy lại khi cập nhật file này. Script cũng ghi lại mục 1 của file này.)

Bản chữ (xem được trong terminal / Notepad):

```text
[✅] GĐ 0  Demo PS1 (02–03/10) ............................ tag demo-v1
  │
[✅] GĐ 1  Đổi hướng: 4 chương, cốt truyện v2 (04/10) ...... D-029, D-034
  │
[🔶] GĐ 2  Làm 4 chương (04–10/10)
  │     ├─ [✅] Chương 1 Tổng tắc ........................ tạm chốt D-071
  │     ├─ [✅] Chương 2 Trò chơi ........................ tạm chốt D-073
  │     ├─ [🔶] Chương 3 Truy sát ........................ chơi thử dừng ở tầng 1
  │     └─ [⬜] Chương 4 Người sống sót .................. chưa chơi tay
  │
[🔶] GĐ 3  Đồ họa gần chân thực (từ 10/10, D-076)
  │     ├─ [✅] G0 Chuẩn bị .............................. D-079
  │     ├─ [✅] G1 Hợp đồng kỹ thuật (balo) .............. D-085
  │     ├─ [✅] G2 Mẫu balo Tripo, chọn lượt 2 ............ D-086
  │     ├─ [✅] G3 Phòng 407 đủ đồ vào bản chơi .......... D-103…D-114
  │     ├─ [📍] G4 Nhân vật: quản lý trước ............... ĐANG Ở ĐÂY (D-115…D-120, đã vào bản chơi, chờ chơi thử)
  │     ├─ [⬜] G4 Nhân vật chính có thân, tay cầm nắm thật  chờ 3 quyết định
  │     ├─ [⬜] G4 Xác sống, bạn học, bảo vệ
  │     └─ [⬜] G5 Hành lang tầng 4 → nhà B → khuôn viên → thư viện/bệnh viện
  │
[⬜] GĐ 4  Ghép bản hoàn chỉnh: chơi liền 4 chương, 1 file lưu (D-059)
  │
[⬜] GĐ 5  Phát hành theo chương
```

## 2. Từng giai đoạn

### Giai đoạn 0 — Demo PS1 (02–03/10) ✅
- Godot 4.7.2, đồ họa PS1, cơ chế "nội quy có bản bị sửa", 5 lane agent + integrator (D-001…D-028).
- Kết quả: demo 15–20 phút, tag `demo-v1` (bản chơi lưu ở `build/archive/demo-v1/`).

### Giai đoạn 1 — Đổi hướng thành game đầy đủ (04/10) ✅
- D-029: game 3–4 tiếng, **4 chương**, mỗi chương một đêm.
- D-034/D-035: cốt truyện chuyển thể video "Quy tắc kí túc xá lúc nửa đêm"; nhân vật Trần Trung (407), Lý Minh Nhật, Khương Ngọc Ngư. Thiết kế: `docs/design/STORY.md`.

### Giai đoạn 2 — Làm 4 chương (04–10/10)
| Chương | Đã làm | Chơi tay | Tình trạng |
|---|---|---|---|
| 1 Tổng tắc | Bản 1 (`v0.2-ch1`), bản 2 tám nhiệm vụ (`v0.3-ch1`), sửa giường/quản lý/gõ tường (D-069, D-070) | ✅ | **Tạm chốt D-071.** Phòng 407 mới (G3) đã chơi, 3 lỗi sửa ở D-113 |
| 2 Trò chơi | Nối từ gõ phím + từ điển Wiktionary (D-051), tắm/nhiệt độ, `v0.4-ch2`, nhắn cách qua màn (D-072) | ✅ trừ đoạn nhắn tin D-072 | **Tạm chốt D-073.** Nhà tắm mới (D-109) chờ chơi lại |
| 3 Truy sát | Khuôn viên gần kích thước thật, xác sống, thanh sắt, đồng đội đi theo; sửa D-061…D-065, D-074, D-075 | 🔶 tới tầng 1 nhà B | **Chờ chủ dự án chơi tiếp từ tầng 1** |
| 4 Người sống sót | Đối chiếu, gọi điện, bệnh viện, kết thúc; lồng tiếng (D-067, D-068) | ⬜ | **Chờ chủ dự án chơi lần đầu** |

Bản chơi hiện hành: `build/windows/KyTucXa.exe` **15/10 17:21** (sau D-113). Phiếu chơi thử: `docs/playtest/G3_PHONG407_QUICKTEST.md`.

### Giai đoạn 3 — Đồ họa gần chân thực (từ 10/10, D-076) 📍
Mục tiêu: hình gần thật, 1080p/60 FPS trên RTX 3050 Laptop. Đồ vật tạo bằng **Tripo AI** (gói Studio Pro, D-080/D-084), chỉnh trong Blender, đưa vào Godot. Kế hoạch: `docs/design/GRAPHICS_UPGRADE_PLAN.md`.

| Cổng | Nội dung | Tình trạng |
|---|---|---|
| G0 Chuẩn bị | 6 gói việc T-207…T-212 khảo sát, đo, công cụ | ✅ D-079 |
| G1 Hợp đồng kỹ thuật | Công cụ kiểm asset, hồ sơ balo, giấy phép Tripo (D-084) | ✅ D-085 |
| G2 Thử Tripo | Balo Tripo lượt 2 xanh navy | ✅ D-086 |
| G3 Phòng 407 vào bản chơi | Tripo 3 đợt (70 món) + mùng, chiếu, gạch, decal bằng Blender (D-089…D-101) → vào bản chơi cả 4 chương (D-103) → ánh sáng (D-104), gương phản chiếu thật (D-105), giấy và dây điện (D-106), sửa nhà tắm (D-109), khung đọc ảnh/thẻ (D-112), sửa 3 lỗi chủ dự án báo + phòng tối hẳn (D-113). **1080p thấp nhất 97,7 FPS (D-114).** Bộ lọc PS1 mặc định tắt | ✅ chủ dự án duyệt độ tối và hết lỗi |
| **G4 Nhân vật** | **Quản lý trước** (D-115): nam ~45 tuổi, đồng phục quản lý trường học, mặt kinh dị, dao phay. Lane C làm thử mẫu MPFB (D-117) nhưng chủ dự án chọn bỏ; **chủ dự án tự làm, integrator hỗ trợ** (D-118). Phiếu Tripo `docs/handoff/TRIPO_QUAN_LY.md`; bài học kỹ thuật trong card T-219. Tripo: thân, 6 động tác, dao, chìa khóa, thẻ (D-119); chủ dự án duyệt, mắt trắng đục, vào bản chơi chương 1 và gương chương 2 (D-120) | 📍 **chờ chơi thử** |
| G4 tiếp | Nhân vật chính có thân và tay cầm nắm, mở cửa như thật; nhân vật khác đi không trượt chân; xác sống, 2 bạn học, bảo vệ | ⬜ chờ chủ dự án chốt 3 câu (mục 3) |
| G5 Mở rộng cảnh | Hành lang tầng 4 → nhà B → khuôn viên → thư viện/bệnh viện | ⬜ |

### Giai đoạn 4 — Ghép bản hoàn chỉnh (D-059) ⬜
Khoảng 4–6 ngày: hết chương tự sang chương sau, **một file lưu xuyên suốt**, đồng bộ đồ họa giữa các chương, ánh sáng 4 giờ → 9 giờ, rà chi tiết liền mạch (đồ đạc, xác, chat, ai sống), bot cả 4 chương, đo FPS, chơi tay trọn game. Thứ tự so với G4/G5 do chủ dự án chốt khi tới.

### Giai đoạn 5 — Phát hành ⬜
Phát hành theo chương (D-029). Nền tảng, giá, ngày: chưa quyết. Steam yêu cầu khai báo nội dung AI (`AGENTS.md` §5).

## 3. Việc đang chờ chủ dự án (để tiếp tục)
1. 📍 **Quản lý (T-219):** đã vào bản chơi (D-120). Chủ dự án chơi thử chương 1 (quản lý vào phòng, hỏi, rạch giường, mở cửa, cảnh camera) và chương 2 (bóng trong gương nhà tắm), báo chỗ chưa ổn.
2. **Học làm động tác (tùy chọn):** integrator soạn trang hướng dẫn Blender cho người mới (tạo dáng, đặt mốc, xuất file) khi chủ dự án muốn bắt đầu.
3. **Nhân vật chính có thân/tay thật**, chốt 3 câu trước khi viết card T-220:
   - thấy cả người (cúi thấy chân, có bóng, trong gương; integrator đề xuất) hay chỉ hai tay;
   - thao tác bằng tay mất khoảng 0,5–1 giây: giữ thời gian luật (khó hơn chút) hay nới thời gian ở đoạn bị đuổi;
   - nguồn chuyển động: chỉ CC0 + chỉnh tay, hay thêm quay video + AI motion capture trả phí.
4. **Chơi thử** bản 15/10 17:21 theo `docs/playtest/G3_PHONG407_QUICKTEST.md`: chương 2 (nhà tắm mới, đoạn nhắn tin D-072), chương 3 từ tầng 1 (báo cháy, 4 xác sống), chương 4 lần đầu.

## 4. Đội làm
- **Integrator:** Claude Code ở máy (Opus 5.5).
- **Lane:** A gameplay, B môi trường/3D (**đang hết hạn mức**), C QA/công cụ, D giao diện/đa ngôn ngữ (Gemini 3.8 Flash, D-108), F âm thanh (Claude Code web, D-108). Hiện không lane nào có việc dở.
- **Quản lý (T-219):** chủ dự án + integrator, không giao lane (D-118).
- Lúc lane hết hạn mức: integrator làm thay, ghi "Claude làm thay".
- Việc nhỏ có thể giao lane rảnh: con dấu tiếng Anh xuống dòng, thẻ sinh viên thừa dòng "Cuộn để đọc tiếp", đèn pin chói trắng khi sát vật dưới 1 m.
