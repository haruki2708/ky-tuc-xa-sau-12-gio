# Prompt bàn giao — Claude Code web, T-207

Claude web là lane core được giao theo D-077, làm trong checkout Linux cloud riêng. Integrator là Astra trong 10–11/10 rồi Claude Code ở máy dùng Opus 5.5. Không phải phiên web thay vai trò chủ dự án/integrator.

Task mới: **T-207**. T-192/T-201/T-204 là lịch sử đã ghép. Máy web không có GPU: không báo đã nhìn hình, đạt FPS, nghe âm hoặc export Windows.

**D-078:** lane F (tài khoản GPT Plus mới) tiếp nhận toàn bộ âm thanh và T-212 từ E nghỉ vô thời hạn. Contract dùng A/B/C/D/F; đối tác âm thanh và nhánh là `lane-f/T-212-graphics-audio-anchors`.

## 1. Prompt giao task (dán vào phiên web, chọn repo tuaanh666/ky-tuc-xa-sau-12-gio)
```text
Bạn là Claude Code web làm phần core theo D-077, task T-207: hợp đồng và tích hợp đồ họa gần chân thực.
Tiếng Việt cho trả lời/tài liệu, tiếng Anh cho code. Bạn làm trên nhánh riêng, integrator ở máy review/merge.

1. Kiểm git status; giữ mọi thay đổi đang có. git fetch origin; git lfs install; git lfs pull.
   Nhánh core/T-207-graphics-core-contract: nếu có local thì switch/pull --ff-only;
   nếu có remote thì tạo tracking branch; nếu chưa có thì tạo từ origin/main có D-077.
2. Đọc AGENTS.md, STATUS, D-076/D-077/D-078, docs/design/GRAPHICS_UPGRADE_PLAN.md,
   docs/tasks/T-207-graphics-core-contract.md và phạm vi/dependency T-208…T-212.
   F tiếp nhận vai trò âm thanh từ E; ghi owner F trong contract mới và phối hợp T-212 với F.
3. Dùng Godot 4.7.2 Linux; nếu thiếu, tải bản chính thức từ
   https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
   vào ~/tools, giải nén, đặt biến GODOT tới executable. Dùng PowerShell 7 nếu có.
   Chạy baseline toàn bộ test trước sửa. Có thể chạy trực tiếp:
   $GODOT --headless --path game --import
   $GODOT --headless --path game res://tests/run_tests.tscn
   Nếu dùng pwsh, export GODOT rồi chạy tools/test.ps1 và tools/check.ps1.
   Thiếu công cụ/check không chạy được thì ghi rõ; không ghi PASS giả và không sửa launcher của C.
4. G0 trước: ASSET_BINDINGS.md và INTEGRATION_CONTRACT.md trong docs/design/graphics/.
   Đo/đọc root, collider, marker, API/clip/timing thật; gửi contract sớm để các lane làm tiếp.
   Đề xuất settings/schema cho integrator, không tự ghi SETTINGS hoặc đổi project.godot.
   Wiring core chỉ khi G1 và dependency trong card đủ. Giữ logic, luật, save và tọa độ thế giới.
5. Không có Meshy key/ngân sách trên cloud; không gọi API trả phí/cài plugin/MCP, không làm asset B thay.
   Không chạy FPS, bot chương 3–4, chụp ảnh hay export Windows trên máy này.
6. Full test sau sửa + check nếu công cụ hỗ trợ; không có lỗi mới so với baseline.
   Lỗi nền ghi đúng tên/lệnh, không tự quy cho Linux nếu chưa chứng minh.
   Commit nhỏ “T-207: ...”, git push -u origin core/T-207-graphics-core-contract.
   Điền Handoff/checklist, ghi “Claude Code web làm phần core, D-077”, hai lượt test và phần chưa kiểm.
   Không push main, không sửa STATUS/DECISIONS/Review, không mở PR nếu chưa được yêu cầu.
7. Báo đã làm; test/check; phần thiếu/dependency; yêu cầu ngoài phạm vi; commit/nhánh và chặn.
   Mới xong G0 thì bàn giao G0, chưa đánh dấu toàn bộ T-207 done.
```

## 2. Prompt tiếp tục
```text
Tiếp tục T-207 theo docs/handoff/web.md mục 1 trên nhánh core/T-207-graphics-core-contract.
Kiểm máy cloud còn Godot/tools không, git status và git log -5; fetch/pull an toàn.
Đọc Handoff T-207 và STATUS/kế hoạch để biết G1/dependency đã ghép chưa, rồi làm phần được mở.
```

## 3. Prompt yêu cầu sửa
```text
Integrator trả T-207: fetch và đọc Review tại origin/main:docs/tasks/T-207-graphics-core-contract.md.
Rebase nhánh lên origin/main, sửa từng ý đúng phạm vi, chạy test/check, cập nhật Handoff và push.
Ghi rõ phần chưa kiểm được vì cloud không có GPU; integrator sẽ xác minh trên Windows.
```
