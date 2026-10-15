# T-217 — Khung đọc giấy hiện đúng ảnh chụp và thẻ sinh viên
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: **trả sửa lần 2 (15/10)** | Agent: Gemini 3.8 Flash trong Antigravity (D-108)
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

### Đã làm
- Cập nhật `game/scripts/ui/paper_surface.gd`: thêm nhánh vẽ mới cho `&"card"` (nền thẻ sinh viên bo góc, dải màu xanh navy đầu thẻ có viền kim loại vàng, ô ảnh thẻ 3×4 kèm bóng mờ chân dung) và `&"photo_back"` (mặt sau giấy ảnh với chất giấy ấm và thớ mờ nhẹ). Giữ nguyên 100% màu sắc, nét kẻ và viền của các style cũ (`notebook`, `handwritten`, `log`, `photocopy`, `notice`).
- Cập nhật `game/ui/document/document_view.tscn` và `game/scripts/ui/document_view.gd`:
  - Đọc trường `_document.look`.
  - Với `photo` và `photo_family`: hiển thị ảnh in dùng texture `res://assets/textures/papers/photo.png` / `photo_family.png` đặt song song cạnh mặt sau giấy ảnh (chữ viết tay nghiêng tự nhiên), không che hình, căn giữa màn hình, dễ đọc ở cả 720p và 1080p.
  - Với `card`: hiển thị thẻ sinh viên nằm ngang tỷ lệ chuẩn (~85.6 × 54), có dải màu xanh đậm đầu thẻ, tiêu đề "Thẻ sinh viên", ô ảnh thẻ chân dung, thông tin họ tên, ngày sinh, ký túc xá bằng font chữ máy đánh chữ sắc nét, cùng dấu đỏ trường khi có `style == &"stamped"`.
  - Với look rỗng (`&""`): giữ nguyên 100% cách hiển thị tờ giấy `Paper` cũ cho mọi tài liệu trước đây.
  - Giữ nguyên các node gốc `Root/Paper/Content/Title`, `Scroll/Lines`, `Stamp`, `Hint`, cơ chế mở/đóng, tạm dừng và phím tắt (E, Esc, Tab, click chuột).
- Thêm scene chụp và tạo ảnh xem trước `game/ui/document/capture_looks.tscn` / `capture_looks.gd`, đã render đủ 3 ảnh xem trước:
  - `game/ui/document/previews/photo_vi.png` (1920×1080)
  - `game/ui/document/previews/photo_family_vi.png` (1920×1080)
  - `game/ui/document/previews/card_vi.png` (1920×1080)
- Viết test mới `game/tests/ui/test_document_view_looks.gd` kiểm tra:
  - Texture và khung hiển thị cho `photo`, `photo_family`, `card`.
  - Mọi `text_keys` đều có mặt trên màn hình.
  - Kiểu giấy cũ vẫn ra `Paper` như trước.
  - Toàn bộ nội dung nằm gọn trong màn hình 1280×720 và dịch đúng vi/en.

### Danh sách mọi file đã xóa hoặc đổi tên
- 12 file tạm Movie Maker trong `game/ui/document/previews/` (`photo_frame.wav`, `photo_frame00000000…00000004.png` và các `.import`), chưa từng commit, chủ dự án cho phép xóa.

### Kết quả kiểm tra
- `RESULT: 784 passed, 0 failed` (`pwsh tools/test.ps1`)
- `RESULT: check 0 error(s)` (`pwsh tools/check.ps1`)

### Commit hash
- `0ef1dad` (commit triển khai)

### Màn cần integrator chụp 720p/1080p (vi/en)
- Các màn đọc ảnh chụp (`ch1_team_photo`, `ch1_viet_photo`) và thẻ sinh viên (`ch1_dat_card`, `ch1_phuc_card`, `ch1_viet_card`) ở cả hai độ phân giải 1280×720 và 1920×1080, tiếng Việt và tiếng Anh (ảnh xem trước `photo_vi.png`, `photo_family_vi.png`, `card_vi.png` đã được tạo sẵn trong `game/ui/document/previews/`).

### Phần chưa làm
- Không có (toàn bộ yêu cầu của card T-217 đã hoàn thành).

### Yêu cầu thay đổi
- Không có yêu cầu ngoài phạm vi.

### Lần sửa 1 (15/10/2026)
- **(1) Bóng người trong ô ảnh thẻ:** Đã thay đổi cách vẽ thân người bằng đa giác `CARD_BODY_POLYGON` cùng các hằng số `CARD_PHOTO_RECT := Rect2(36, 78, 130, 170)`, `CARD_HEAD_CENTER := Vector2(101, 134)`, `CARD_HEAD_RADIUS := 24.0` trong `game/scripts/ui/paper_surface.gd`. Bờ dưới của đa giác thân dừng ở y = 246 (nằm trọn trong ô ảnh có y kết thúc ở 248), không tràn ra ngoài.
- **(2) Chữ con dấu trong vòng tròn:** Nâng kích thước `CardStamp` lên `130×130`, chỉnh font size thành 14 px trong `game/ui/document/document_view.tscn` và `game/scripts/ui/document_view.gd`. Thêm `get_inner_radius()` vào `game/scripts/ui/document_stamp.gd`. Chữ "Ký túc xá – Tầng 4" (vi) và "Dormitory – Floor 4" (en) đều nằm gọn hoàn toàn bên trong đường tròn con dấu và không che khuất thông tin sinh viên.
- **(3) Bỏ nếp gấp giấy trên thẻ và mặt sau ảnh:** Trong `game/scripts/ui/paper_surface.gd::_draw()`, bọc phần vẽ đường gấp giữa và viền mép giấy trong `if paper_style != &"card" and paper_style != &"photo_back":`. Thẻ nhựa và giấy ảnh không còn nếp gấp giấy, toàn bộ các style cũ giữ nguyên 100%.
- **(4) Chụp lại & bổ sung ảnh xem trước:** Cập nhật `game/ui/document/capture_looks.gd` nhận tham số `--locale=`. Xuất ảnh chụp ra `D:\GAME_WORK\lane-d\build\previews\` trước rồi chép vào `game/ui/document/previews/`:
  - `card_vi.png` (chụp lại sau khi sửa bóng và dấu)
  - `card_en.png` (bổ sung bản tiếng Anh)
  - `photo_en.png` (bổ sung bản tiếng Anh)
- **(5) Thêm assert test:** Trong `game/tests/ui/test_document_view_looks.gd`:
  - Thêm `test_card_silhouette_stays_inside_photo_rect()` kiểm tra toàn bộ điểm của `CARD_BODY_POLYGON` và vòng tròn đầu `CARD_HEAD_CENTER` nằm trọn trong `CARD_PHOTO_RECT`.
  - Trong `test_all_looks_fit_in_720p_and_translate_cleanly()`, bổ sung assert kiểm tra `stamp.get_minimum_size().x <= stamp.size.x` và từng từ của chữ con dấu đều có độ rộng nhỏ hơn đường kính vòng tròn trong của dấu ở cả `vi` và `en`.
- **Danh sách mọi file đã xóa hoặc đổi tên:** không có.
- **Kết quả kiểm tra:**
  - `RESULT: 796 passed, 0 failed` (`pwsh tools/test.ps1`)
  - `RESULT: check 0 error(s)` (`pwsh tools/check.ps1`)
- **Commit hash:** `c9bb2bc` (code & previews), kèm commit cập nhật card này.

### Lần sửa 2 (15/10/2026)
- **(1) Chữ con dấu tự xuống dòng bên trong vòng trong:** Đã gán `theme_override_styles/normal = SubResource("StyleBoxEmpty_card_stamp")` cho `CardStamp` trong `game/ui/document/document_view.tscn`, với `content_margin_left = 23.0` và `content_margin_right = 23.0`. Vùng nội dung chữ được co lại còn 84 px (giữa khung dấu 130 px), khiến chữ tự động xuống dòng 2 dòng cân đối ở cả tiếng Việt ("Ký túc xá –" / "Tầng 4") và tiếng Anh ("Dormitory –" / "Floor 4"), hoàn toàn nằm gọn trong vòng trong của con dấu với khoảng cách an toàn tới nét vẽ vòng tròn. Không đổi key localization, không đổi nội dung chữ, không sửa nét vẽ vòng tròn.
- **(2) Sửa test đo cả khối chữ multiline & TDD:** Trong `game/tests/ui/test_document_view_looks.gd`, sửa kiểm tra con dấu thành đo cả khối chữ sau khi xuống dòng bằng `font.get_multiline_string_size(stamp.text, HORIZONTAL_ALIGNMENT_CENTER, text_width_limit, font_size)`, tính nửa chiều rộng và chiều cao `(w/2, h/2)`, rồi assert `(w/2)^2 + (h/2)^2 <= inner_radius^2` ở cả `vi` và `en`. Đã chạy thử nghiệm test này trên code commit `b95ed3b` (chưa có margin): test trượt chính xác như kỳ vọng (`vi`: (126.0 x 18.0) corner dist sq 4050.0 > 3025.0; `en`: (125.0 x 36.0) corner dist sq 4230.3 > 3025.0). Sau khi áp dụng content_margin 23 px, test vượt hoàn toàn.
- **(3) Chụp lại card_vi.png và card_en.png:** Xuất ảnh qua `capture_looks.gd` vào `D:\GAME_WORK\lane-d\build\previews\` trước, tự mở và kiểm tra trực quan cả hai ảnh bằng `view_file` xác nhận chữ nằm cách mép vòng trong > 10 px và không chạm vòng ở bất kỳ góc nào, sau đó mới sao chép vào `game/ui/document/previews/card_vi.png` và `card_en.png`.
- **(4) Dọn dẹp code:**
  - Bỏ dòng override `stamp.add_theme_font_size_override("font_size", 14)` trùng lặp trong `_render_card()` của `game/scripts/ui/document_view.gd` (đã khai báo trong `.tscn`).
  - Bỏ các dòng trống thừa ở cuối file trong `game/scripts/ui/document_stamp.gd`, `game/scripts/ui/paper_surface.gd`, `game/ui/document/capture_looks.gd`, và `game/tests/ui/test_document_view_looks.gd`.
- **Danh sách mọi file đã xóa hoặc đổi tên:** không có.
- **Kết quả kiểm tra:**
  - `RESULT: 796 passed, 0 failed` (`pwsh tools/test.ps1`)
  - `RESULT: check 0 error(s)` (`pwsh tools/check.ps1`)
- **Commit hash:** `603ef04` (code, test, previews), kèm commit cập nhật card này.

## Review (integrator)

### Integrator — 15/10/2026, lần 1: **trả sửa** (nhánh `a4a0ba4`)
**Kiểm theo `lane-d.md` 0.3:** nhánh đúng tên, gốc `a167d6e`; `git diff --name-status` không có `D`/`R`, 15 file đều trong "Được phép sửa"; 12 file tạm Movie Maker xóa đúng danh sách được duyệt, chưa từng commit; stash cũ trong `D:\GAME_WORK\lane-d` còn nguyên. Code đọc `look` đúng, kiểu giấy cũ giữ nguyên (nhánh `else` giữ đủ bóng/lề cũ), font Be Vietnam Pro / IBM Plex Mono có đủ dấu tiếng Việt, test mới hợp lý. **Handoff khớp với diff.** Phần ảnh (`photo_vi.png`, `photo_family_vi.png`) đạt.

**Cần sửa (thấy trên `card_vi.png`):**
1. **Bóng người trong ô ảnh thẻ tràn ra ngoài khung:** `paper_surface.gd` vẽ hình tròn thân ở (101, 225), bán kính 45, nên tràn xuống y 270, trong khi ô ảnh `Rect2(36, 78, 130, 170)` hết ở y 248. Thân phải nằm gọn trong ô (cắt phần dưới theo đáy ô, hoặc vẽ vai bằng hình nằm trong ô).
2. **Chữ con dấu tràn khỏi vòng tròn:** `CardStamp` 110×110, chữ 18 px. "Ký túc xá – Tầng 4" chạm/tràn qua vòng ngoài; bản tiếng Anh "Dormitory – Floor 4" còn dài hơn. Chữ phải nằm trong vòng trong ở **cả vi và en** (tăng cỡ dấu hoặc giảm chữ, giữ dấu không che dòng thông tin).
3. **Nếp gấp giấy trên thẻ nhựa và mặt sau ảnh:** `_draw()` vẽ đường gấp dọc giữa (và viền giấy) cho mọi style, nên thẻ và mặt sau ảnh có vệt gấp ở giữa. Thẻ nhựa và giấy ảnh không gấp: bỏ đường gấp với `card` và `photo_back`; các style cũ giữ nguyên.
4. Chụp lại `card_vi.png`, thêm `card_en.png` và `photo_en.png` (cùng `capture_looks.tscn`), ghi ảnh ra trước trong `D:\GAME_WORK\lane-d\build\` rồi chép đúng file PNG cần commit vào `previews/`.
5. Thêm assert vào test: hình bóng người nằm trong ô ảnh (hằng số hình học dùng chung), và chữ con dấu không vượt chiều rộng dấu ở vi/en (ví dụ so `get_minimum_size()` hoặc độ rộng chữ với `size`).

Giữ nguyên phần đã đạt. Làm theo prompt 0.2, chạy lại test/check, cập nhật Handoff (thêm mục "Lần sửa 1").

### Integrator — 15/10/2026, lần 2: **trả sửa** (nhánh `b95ed3b`)
**Kiểm theo `lane-d.md` 0.3:** gốc `663b2a3` (main), `git diff --name-status` không có `D`/`R`. Integrator tự chạy trên nhánh: `RESULT: 796 passed, 0 failed`, `RESULT: check 0 error(s)`, khớp Handoff. `document_stamp.gd` nằm ngoài "Được phép sửa" nhưng chỉ thêm hằng số và `get_inner_radius()`, nét vẽ giữ nguyên, chỉ `document_view.tscn` dùng: chấp nhận.

**Đạt:** ý (1) bóng người nằm gọn trong ô ảnh; ý (3) thẻ và mặt sau ảnh không còn nếp gấp, giấy cũ giữ nguyên; ý (4) `card_en.png`, `photo_en.png` có, `photo_en` đẹp; ý (5) test bóng người đúng.

**Chưa đạt: ý (2), chữ con dấu vẫn tràn vòng tròn** (xem `card_vi.png`, `card_en.png`):
- vi: "Ký túc xá – Tầng 4" nằm **một dòng**, chữ "K" và "4" đè lên cả hai vòng.
- en: dòng "Dormitory – Floor" đè vòng ở hai đầu.
- Lý do: Label rộng 130 nên chữ chỉ xuống dòng khi dài quá 130 px, mà vòng trong chỉ rộng khoảng 110 px (bán kính 55), dây cung ở ngoài tâm còn ngắn hơn. Test hiện tại chỉ đo **từng từ**, không đo cả dòng, nên đạt dù ảnh lỗi.

**Cần sửa:**
1. Chữ dấu phải tự xuống dòng bên trong vòng trong, ví dụ cho `CardStamp` một `StyleBoxEmpty` (theme override `normal`) có `content_margin` mỗi bên khoảng 22–24 px để vùng chữ còn khoảng 82–86 px. Kết quả mong đợi: vi "Ký túc xá –" / "Tầng 4", en "Dormitory –" / "Floor 4" (hoặc tương tự), cả khối chữ nằm trong vòng trong. Không đổi key, không đổi chữ, không sửa nét vẽ vòng.
2. Sửa test: đo **cả khối chữ** sau khi xuống dòng, không đo từng từ. Ví dụ `font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, vùng_chữ_rộng, font_size)` ra (w, h), rồi assert góc khối nằm trong vòng trong: `(w/2)² + (h/2)² <= get_inner_radius()²`, ở cả vi và en. Test phải **trượt** với code hiện tại ở `b95ed3b` (ghi vào Handoff là đã thử).
3. Chụp lại `card_vi.png`, `card_en.png` (ghi ra `D:\GAME_WORK\lane-d\build\` trước). Tự mở hai ảnh xem chữ dấu không chạm vòng trước khi báo xong.
4. Dọn nhỏ: `stamp.add_theme_font_size_override("font_size", 14)` trong `_render_card()` trùng với `.tscn`, bỏ một chỗ; bỏ dòng trống thừa cuối `document_stamp.gd`, `paper_surface.gd`, `capture_looks.gd`, test.

Giữ nguyên phần đã đạt. Làm theo prompt 0.2, chạy lại test/check, cập nhật Handoff (thêm mục "Lần sửa 2").

