# T-217 — Khung đọc giấy hiện đúng ảnh chụp và thẻ sinh viên
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent: Gemini 3.8 Flash trong Antigravity (D-108)
- Phụ thuộc: D-106, **D-110** trên `main`. Quyết định giao: D-110 (chủ dự án: "ok tôi đồng ý, bạn thực hiện đi").
- Nhánh: `lane-d/T-217-document-view-looks` từ `origin/main` mới nhất. Làm trong `D:\GAME_WORK\lane-d` theo `docs/handoff/lane-d.md` mục 0.

## Bối cảnh
- Ở D-106, giấy trong phòng 407 đã có hình riêng theo kiểu: bản photo, viết tay, có dấu đỏ, thông báo, sổ ghi, ảnh chụp, ảnh gia đình. Texture nằm trong `game/assets/textures/papers/`.
- Khi người chơi bấm đọc, khung đọc `game/ui/document/document_view.tscn` (`game/scripts/ui/document_view.gd`, nền `game/scripts/ui/paper_surface.gd`) **luôn vẽ một tờ giấy A4**, kể cả với ảnh chụp và thẻ sinh viên 9×6 cm. Nhìn vật là ảnh mà đọc lại ra tờ giấy viết tay.
- **D-110** thêm trường `DocumentData.look` (file `game/scripts/core/document_data.gd`, chỉ integrator sửa):
  - `&""`: tờ giấy thường, vẽ theo `style` như cũ;
  - `&"photo"`, `&"photo_family"`: ảnh in; chữ trong tài liệu là **mặt sau** ảnh (hoặc lời tả mặt trước);
  - `&"card"`: thẻ sinh viên.
- Tài liệu đang dùng look:

  | id | look | Nội dung chữ |
  |---|---|---|
  | `ch1_team_photo` | photo | mặt trước + mặt sau (2 dòng) |
  | `ch1_viet_photo` | photo_family | 1 dòng mặt sau |
  | `ch1_dat_card`, `ch1_phuc_card`, `ch1_viet_card` | card | họ tên, ngày sinh, ký túc xá |

## Việc cần làm
1. `document_view.gd` đọc `_document.look`:
   - **photo / photo_family:** hiện tấm ảnh in dùng đúng texture `res://assets/textures/papers/photo.png` / `photo_family.png` (viền trắng như ảnh in, hơi nghiêng hoặc có bóng nhẹ được). Tiêu đề và chữ hiện như mặt sau ảnh: chữ viết tay trên giấy ảnh, đặt cạnh hoặc dưới tấm ảnh. Không che hình.
   - **card:** hiện thẻ nằm ngang, tỷ lệ thẻ sinh viên (khoảng 85,6 × 54), có dải màu đầu thẻ, ô ảnh thẻ trống/mờ, chữ họ tên/ngày sinh/ký túc xá trên thẻ. Không cần logo trường thật.
   - Look rỗng: giữ nguyên hiện tại, không đổi giao diện các kiểu giấy cũ (so ảnh `game/ui/document/previews/*_vi.png`).
2. Giữ nguyên: tên node `Root/Paper/Content/Title`, `Scroll/Lines`, `Stamp`, `Hint`; cách mở/đóng, tạm dừng, phím. `ch4_form.gd` vẫn dùng `paper_surface.gd` như cũ.
3. Chữ đọc được ở 1280×720 và 1920×1080, tiếng Việt và tiếng Anh, không tràn khung, không bị cắt dấu.
4. Thêm ảnh xem trước `photo_vi.png`, `photo_family_vi.png`, `card_vi.png` vào `game/ui/document/previews/` bằng cùng cách các ảnh cũ được tạo (nếu không chụp được trên máy thì ghi trong Handoff để integrator chụp).
5. Test mới `game/tests/ui/test_document_view_looks.gd`:
   - mỗi look hiện đúng texture/khung;
   - mọi `text_keys` của tài liệu đều có trên màn;
   - kiểu giấy cũ vẫn ra `Paper` như trước;
   - ở 1280×720 nội dung nằm trong màn.

## Được phép sửa
- `game/ui/document/document_view.tscn`, `game/scripts/ui/document_view.gd`.
- `game/scripts/ui/paper_surface.gd`: chỉ **thêm** nhánh vẽ mới; không đổi màu, nét, viền của các style cũ.
- File mới trong `game/ui/document/` (cảnh con, ảnh xem trước), `game/ui/theme/` (chỉ thêm style mới, không đổi style cũ).
- `game/tests/ui/` (file mới).
- `game/localization/strings.csv`: chỉ thêm key `UI_` mới (vi + en) nếu cần, ví dụ nhãn "Mặt sau".
- `CREDITS.md` nếu thêm font/texture (OFL/CC0/CC-BY).

## Không được
- Không sửa `document_data.gd`, file `.tres` trong `game/data/documents/`, `readable.gd`, texture trong `game/assets/textures/papers/` (chỉ đọc).
- Không đổi nội dung chữ, key cũ, lời thoại, luật. Không đổi sổ tay (`notebook`).
- Không xóa hay đổi tên file nào (luật cứng mục 0 của `lane-d.md`).

## Bàn giao (theo `lane-d.md` 0.1 Bước 5–6)
- `pwsh tools/test.ps1` rồi `pwsh tools/check.ps1`, chép nguyên văn hai dòng RESULT; commit hash đã push.
- Handoff: việc đã làm; danh sách file xóa/đổi tên ("không có"); ảnh xem trước; phần integrator cần chụp 720p/1080p (vi/en); phần chưa làm; yêu cầu thay đổi.

## Handoff (agent điền)

## Review (integrator)
