# Prompt bàn giao — Lane F (Âm thanh, tiếp nhận Lane E)

> **D-079, 11/10:** G0 đã review/ghép. Khi tiếp tục, fetch/rebase main chứa D-079 rồi đọc Review của card và [yêu cầu G1](REVIEW_G0_2026-10-11.md); không làm lại G0 theo đoạn prompt cũ. Đây là phần tiếp của gói đã giao, chưa mở Meshy trả phí hoặc production.

**10/10/2026, D-078:** chủ dự án cho lane E nghỉ vô thời hạn và chỉ định tài khoản GPT Plus mới làm lane F, tiếp nhận toàn bộ vai trò âm thanh của E. Task hiện tại **T-212**, giữ nguyên nội dung và trạng thái ready/G0. Astra điều phối tạm 10–11/10, Opus 5.5 ở máy nhận lại sau đó.

F sở hữu `audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`. Bao gồm bảo trì pipeline, SFX/âm môi trường/nhạc/giọng, bus và nguồn âm gắn model, test âm thanh, nguồn/license. Công việc trước mắt theo T-212; góp ý khác nhận card/phạm vi từ integrator. Không tự thu lại lời đã duyệt hoặc tái tạo toàn bộ âm đã có.

Workspace mới: `D:\GAME_WORK\lane-f`. Giữ nguyên workspace/nhánh E; lịch sử task và credits của E vẫn là lịch sử tác giả cũ. Những tài liệu cũ gọi E là bên phụ trách âm thanh được hiểu là F tiếp nhận từ D-078.

## 1. Prompt giao task (dán nguyên khối vào phiên agent dùng tài khoản GPT Plus mới)

```text
Bạn là agent Lane F (Âm thanh) của game Ký túc xá sau 12 giờ, Godot 4.7.2/GDScript.
Theo D-078, lane E nghỉ vô thời hạn; bạn tiếp nhận toàn bộ vai trò âm thanh của E.
Task hiện tại T-212: marker âm thanh và mẫu chuông báo cháy.
Trả lời/tài liệu tiếng Việt, code tiếng Anh. Integrator tạm là Astra ngày 10–11/10;
sau đó Claude Code ở máy dùng Opus 5.5 nhận lại. Claude web là lane core T-207.
Repo: https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio.git
Chỉ làm trong D:\GAME_WORK\lane-f; không sửa D:\GAME_DEMO hoặc workspace lane khác, kể cả lane-e.

1. Nếu chưa có workspace, clone repo vào D:\GAME_WORK\lane-f rồi cd vào đó.
   Nếu đã có thư mục, kiểm đúng repo và git status; giữ mọi thay đổi đang có, không clone đè.
   git fetch origin. Nhánh: lane-f/T-212-graphics-audio-anchors.
   Nếu local đã có thì switch và pull --ff-only; nếu chỉ origin có thì tạo tracking branch.
   Nếu chưa có thì tạo từ origin/main có D-078; không tạo/sửa nhánh lane-e/T-212.
   Nếu thấy remote E có thay đổi T-212 chưa ghép, báo integrator review trước để tránh làm trùng.
   Không tự sao chép workspace E hoặc cherry-pick thay đổi chưa review.
2. Đọc AGENTS.md, docs/STATUS.md, D-078 trong docs/DECISIONS.md,
   docs/design/GRAPHICS_UPGRADE_PLAN.md, docs/tasks/T-212-graphics-audio-anchors.md,
   docs/SETTINGS.md và mục 4 của docs/handoff/lane-f.md để tiếp nhận âm thanh cũ.
3. Làm G0 ngay: khảo sát nguồn âm/marker, chuẩn bị mẫu chuông và fixture nghe;
   gửi đầu ra cụ thể vào Handoff để integrator/web chốt G1.
   Những bước sau phụ thuộc G1/G2 chỉ làm khi điều kiện trong card đủ; không tự đoán API/setting.
   Chỉ sửa đúng vùng âm thanh và Handoff/checklist T-212. Giữ luật, timing và lời thoại.
   Core nối stream/sự kiện, A/B cung cấp marker; gửi yêu cầu ngoài phạm vi qua Handoff.
4. Meshy chưa được xác nhận mua/kết nối/ngân sách: không tiêu credit, không cài MCP/plugin.
   Không chạy bot chương 3–4 hoặc FPS. Phần chuẩn bị không cần chờ các quyền này.
   Không đổi tác giả/nguồn/license asset cũ từ E sang F; chỉ ghi F cho đóng góp mới của bạn.
5. Bàn giao từng phần bằng commit nhỏ “T-212: ...”; chưa ghi cả gói done khi mới xong G0.
   Trước commit: full pwsh tools/test.ps1 và pwsh tools/check.ps1; ghi RESULT và phần chưa kiểm.
   Phối hợp integrator xếp lượt full test/render trên Windows để tránh tranh tài nguyên.
   git push -u origin lane-f/T-212-graphics-audio-anchors.
   Không push main, không mở PR nếu chưa được yêu cầu.
6. Cập nhật Handoff/checklist card, báo: đã làm; test/check; dependency/mục chưa đạt;
   yêu cầu ngoài phạm vi; commit/nhánh; có chặn gì không. Không sửa STATUS/DECISIONS/Review.
   Kiểm tự động không thay cho nghe thật; chưa được chủ dự án nghe thì ghi còn chờ nghe.
```

## 2. Prompt tiếp tục

```text
Tiếp tục T-212 ở D:\GAME_WORK\lane-f, nhánh lane-f/T-212-graphics-audio-anchors.
Kiểm git status, fetch, switch/pull --ff-only an toàn; đọc Handoff tại docs/tasks/T-212-graphics-audio-anchors.md.
Đọc AGENTS, STATUS và kế hoạch đồ họa để biết G1/G2 đã đủ chưa; rebase origin/main khi cần,
giữ công việc cục bộ. Tiếp tục phần được mở và bàn giao theo docs/handoff/lane-f.md mục 1.
Lane E vẫn nghỉ vô thời hạn; không dùng workspace/nhánh E để làm việc mới.
```

## 3. Prompt yêu cầu sửa

```text
Integrator trả T-212: git fetch origin; đọc Review trên origin/main:docs/tasks/T-212-graphics-audio-anchors.md.
Rebase nhánh lane-f/T-212-graphics-audio-anchors lên origin/main, sửa từng ý đúng phạm vi.
Chạy full test/check, cập nhật Handoff và push nhánh; nêu rõ phần chưa kiểm/đang chờ.
```

## 4. Đọc thêm khi tiếp nhận công việc cũ của E

- `game/audio/CREDITS.md` và các README trong `audio_source/`: nguồn, giấy phép, công cụ và pipeline đã có. Dùng lại công cụ trong `D:\Tools`; không cài vào C: hoặc tái tạo giọng chỉ vì đổi tài khoản agent.
- `docs/tasks/T-198-ch4-audio.md`, `docs/tasks/T-200-ch4-voices-call-audio.md`, `docs/tasks/T-205-ch2-tell-voices.md`: đọc Handoff/Review về âm chương 4, cuộc gọi/loa chương 2–4 và lời chương 2 đã duyệt. Các task này đã ghép, giữ tên E trong lịch sử.
- `docs/SETTINGS.md`: D ghi cấu hình; F đọc và áp dụng phần âm thanh thuộc phạm vi. Không tự sửa key/default chung.
- Phần nghe thử còn mở xem STATUS: âm lượng/giọng chưa được chủ dự án nghe không coi là đã nghiệm thu. Chủ dự án thích âm nhỏ; gửi fixture và hướng dẫn nghe cụ thể.

Việc tạo prompt này chưa khởi chạy phiên F, chưa clone workspace và chưa triển khai T-212. F tự ghi kết quả thật sau khi nhận việc.
