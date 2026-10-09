# Bàn giao điều phối dự án cho Claude Code trên web (thứ 7 10/10 – chủ nhật 11/10/2026)

> Viết bởi integrator (Claude Code ở máy chủ dự án, Opus 5.5) lúc 2026-10-10 01:30, trước khi tạm dừng 1–2 ngày vì hết hạn mức.
> Trong hai ngày này **bạn (phiên Claude Code trên web) là integrator/điều phối**, thay cho phiên ở máy. Đọc hết file này trước khi làm gì.
> Model: **Sonnet 5.5 (effort high)** cho việc thường; **Opus 5.5 (effort medium)** khi viết lời thoại/kịch bản, thiết kế, gỡ lỗi khó. Chủ dự án tự đổi model; tới đoạn cần đổi thì dừng và nhắc.

---

## 0. Prompt để chủ dự án dán vào phiên web
```
Bạn là integrator (điều phối) tạm thời của dự án game kinh dị Godot 4.7.2 "Ký túc xá sau 12 giờ",
thay cho phiên Claude Code ở máy chủ dự án trong 2 ngày (thứ 7 10/10 và chủ nhật 11/10/2026).
Repo: tuaanh666/ky-tuc-xa-sau-12-gio, nhánh main. Trả lời tôi bằng tiếng Việt; tài liệu tiếng Việt, code tiếng Anh.

Bước 1. Đọc kỹ docs/handoff/WEB_DIEU_PHOI_2_NGAY.md (toàn bộ), rồi làm mục 2 "Chuẩn bị máy" trong đó.
Bước 2. Đọc theo thứ tự ở mục 3 của file đó.
Bước 3. Chạy cả bộ test một lần trên main, ghi lại kết quả (đây là mốc; test FAIL ở lượt này là do môi trường Linux).
Bước 4. Tóm tắt ngắn cho tôi (dựa vào mục 1b): tiến độ từng chương, tôi đang chơi tới đâu, vừa sửa gì,
        việc tiếp theo là gì, và bạn sẽ làm gì khi tôi gửi góp ý.
Sau đó chờ tôi gửi góp ý chơi thử hoặc yêu cầu review nhánh lane.
```

---

## 1. Dự án trong 10 dòng
- Game kinh dị 3D góc nhìn thứ nhất, low-poly kiểu PS1, **Godot 4.7.2, GDScript**. Chuyển thể sát video YouTube "Quy tắc kí túc xá lúc nửa đêm" (D-034, D-035): Trần Trung (phòng 407 nhà B) sống sót qua 5 vòng quy tắc từ 4:00 đến 9:00 sáng; twist: động đất lúc 4 giờ, ký túc xá sập; vượt hết quy tắc thì tỉnh dậy ở bệnh viện.
- **4 chương** (D-029), mỗi chương 45–60 phút: 1 "Tổng tắc" (vòng 1–2), 2 "Trò chơi" (nối từ, tắm nước nóng), 3 "Truy sát" (xác sống khắp trường), 4 "Người sống sót" (thư viện, quay về 407, phiếu điều tra, kết).
- Chỉ một độ khó **Insane** (D-039); **không giải thích luật, không gợi ý** (D-038, D-055); có cảnh chết góc nhìn thứ nhất (D-042); bỏ thời gian trống khi xong việc (D-040).
- Người làm: **chủ dự án** (quyết thiết kế, chơi thử, dán prompt cho các agent), **integrator** (bạn, trong 2 ngày này), **5 lane agent A–E** (GPT/Codex, chạy ở máy chủ dự án trong `D:\GAME_WORK\lane-<x>`): A gameplay, B môi trường 3D, C QA và công cụ, D UI và đa ngôn ngữ, E âm thanh. Phạm vi file mỗi lane: `AGENTS.md` §3.
- **Sự thật nằm trong repo:** `docs/STATUS.md` (bảng task, "Việc tiếp theo"), `docs/DECISIONS.md` (D-001…D-074), `docs/tasks/T-*.md` (card có Handoff và Review), `docs/design/*` (thiết kế, kịch bản).

## 1b. Tiến độ dự án và đang sửa tới đâu (đọc kỹ nhất)

### Lộ trình tổng
| Giai đoạn | Trạng thái |
|---|---|
| Demo cũ (bỏ, tag `demo-v1`) | Xong, chỉ để tham khảo |
| Thiết kế v2 (STORY, D-034, D-035) | Xong, đã duyệt |
| Chương 1 "Tổng tắc" | Làm xong, đã sửa 2 đợt góp ý, **tạm chốt** (D-045, lại D-071) |
| Chương 2 "Trò chơi" | Làm xong, đã sửa 2 đợt góp ý, **tạm chốt** (D-057, lại D-073) |
| Chương 3 "Truy sát" | Làm xong, **đang chơi kiểm tra đợt 3**; đợt này đã sửa 3 lỗi (D-074, T-206) |
| Chương 4 "Người sống sót" | Làm xong, lời đã duyệt, có giọng; **chưa chơi kiểm tra lần nào** |
| Ghép bản hoàn chỉnh (D-059) | Chưa bắt đầu; làm sau khi cả 4 chương tạm chốt |
| Phát hành (bản quyền, nhãn nội dung, Steam/itch) | Chưa bắt đầu |

### Bảng từng chương
| | Chương 1 | Chương 2 | Chương 3 | Chương 4 |
|---|---|---|---|---|
| Thiết kế đã duyệt | Có (`CH1_V2_MISSIONS.md`) | Có (`CH2_DESIGN.md`) | Có (`CH3_DESIGN.md`) | Có (`CH4_DESIGN.md`, D-067) |
| Lời thoại đã duyệt | Có | Có (D-072 duyệt 09/10) | Có | Có (D-068) |
| Các lane đã ghép | Đủ | Đủ | Đủ | Đủ (T-195…T-198, T-200) |
| Test tự động | Đạt | Đạt | Đạt | Đạt (cả bộ 719/719) |
| Chủ dự án chơi tay bản mới nhất | Đạt (D-071) | Đạt, **trừ đoạn nhắn tin mới D-072 chưa chơi** | **Đang chơi**: tới tầng 2 thì gặp lỗi, đã sửa, chưa chơi lại | Chưa |
| Âm thanh đã nghe bằng tai | Một phần (chương 1 cũ) | Chưa nghe giọng cuộc gọi/loa (mới có tiếng từ T-200) | Chưa | Chưa |
| Bot chơi trọn | Có (bản cũ) | Khung có | Chưa chạy (D-068: không chạy) | Chưa có (T-199 chưa viết, không cần) |

### Đang sửa tới đâu (ngay lúc bàn giao)
- **Chủ dự án đang ở chương 3, bước 5 của `docs/playtest/CH3_QUICKTEST.md` (tầng 2 nhà B).** Đợt chơi gần nhất (bản 17:27 ngày 09/10) báo 3 lỗi, **cả 3 đã sửa và có trong bản 01:28**:
  1. Cửa sáng nhấp nháy cạnh phòng 407 → tấm bịt cửa 408 cũ trùng mặt tường; lane B sửa (T-206), đúng ở cả 4 chương.
  2. Đập bình cứu hỏa nhưng xác vẫn tới chặn cửa phòng 207 → xác thấy người chơi trên đường đi bộ về 207; core sửa: bị tiếng bình kéo đi thì chỉ để ý người chơi dưới 2 m, tới chiếu nghỉ khoảng 3 giây mới nhìn quanh lại (`_pull_crowd_203`, `_watch_crowd_pull` trong `chapter3_director.gd`).
  3. Minh Nhật tự hiện trong phòng 207 → cơ chế đuổi kịp ở chỗ khuất; core sửa: Minh Nhật chờ ở cửa 203 tới khi đám xác về chiếu nghỉ, rồi đi bộ ra (`_walk_out_nhat`).
- **Việc tiếp theo ngay:** chủ dự án chơi lại tầng 2 bằng bản 01:28 để xác nhận 3 sửa trên, rồi chơi tiếp các bước 6–13 (tầng 1 và cửa sổ phòng quản lý, vườn hoa và Ngư, sân vận động 4 phút, cổng và bảo vệ, nhà ăn và hết chương). Phần sau tầng 2 **chưa được chơi lại** từ các sửa D-061…D-065 (xác ra từ phòng, đồng đội đi theo, khán đài mới, trời đêm), nên có thể còn lỗi.
- **Không có việc nào đang làm dở trong code**, không có nhánh lane nào chờ review. `main` sạch, 719/719 test.

### Nhật ký gần đây (để hiểu nhịp làm việc)
| Ngày | Việc |
|---|---|
| 07/10 | Chương 4 thiết kế (D-067), giao 4 lane, ghép xong (T-194…T-198); chủ dự án duyệt lời (D-068); phát hiện cuộc gọi chương 2–4 chưa từng có tiếng → T-200 (lane E) |
| 08/10 | Ghép T-200; chủ dự án chơi chương 1 → 5 góp ý (D-069) → T-201 (Claude Code web, core), T-202 (lane A), T-203 (lane B) |
| 09/10 | Ghép T-201…T-203 (integrator sửa thêm 3 chỗ sau ghép, D-070); chương 1 tạm chốt (D-071); chương 2 góp ý nhắn tin (D-072) → T-204 (web), T-205 (lane E), ghép; chương 2 tạm chốt (D-073); chương 3 báo 3 lỗi → D-074 sửa core, T-206 lane B |
| 10/10 01:28 | Ghép T-206, export bản 01:28, bàn giao cho phiên web |

## 2. Chuẩn bị máy (Linux cloud, không cần sudo; cài vào ~/tools)
```
git lfs install; git lfs pull
mkdir -p ~/tools && cd ~/tools
curl -LO https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
unzip -o Godot_v4.7.2-stable_linux.x86_64.zip && chmod +x Godot_v4.7.2-stable_linux.x86_64
export GODOT=~/tools/Godot_v4.7.2-stable_linux.x86_64
# PowerShell 7 (tar.gz Linux x64, bản 7.x mới nhất ở github.com/PowerShell/PowerShell/releases) vào ~/tools/pwsh
cd <repo>; $GODOT --headless --path game --import
```
- **Chạy test:** `GODOT=$GODOT ~/tools/pwsh/pwsh tools/test.ps1` (lọc: `-Filter chapter3`) và `~/tools/pwsh/pwsh tools/check.ps1`. Nếu `test.ps1` hỏng trên Linux, chạy thẳng:
  `XDG_DATA_HOME=$(mktemp -d) $GODOT --headless --path game res://tests/run_tests.tscn` (thêm `-- --filter=chapter3` để lọc). Dòng cuối phải là `RESULT: N passed, 0 failed`.
- **Mốc hiện tại trên Windows:** `RESULT: 719 passed, 0 failed`, `RESULT: check 0 error(s)` (commit `b4a6a06`). Bộ test đầy đủ chạy khoảng 10–12 phút.
- **Chạy thử cảnh thật:** tạo scene tạm `game/_tmp/probe.tscn` + `probe.gd` (Node, `_ready` dựng cảnh chương, `director.auto_start = false`, in ra `print("PROBE ...")`, cuối cùng `App.quit()`), chạy `$GODOT --headless --path game res://_tmp/probe.tscn`, **xóa `game/_tmp` trước khi commit**. **Không dùng `godot -s script.gd`**: chế độ `-s` không nạp autoload `EventBus` nên báo lỗi giả. Nếu script trong probe lỗi cú pháp thì Godot treo (không tới `App.quit()`): luôn chạy kèm `timeout 280`.

### Máy cloud KHÔNG làm được (và cách xử lý)
| Không làm được | Cách xử lý |
|---|---|
| Xuất `.exe` (`tools/export.ps1` cần Windows) | Nhờ chủ dự án chạy ở máy: **đóng Godot editor (không lưu)** → `cd D:\GAME_DEMO` → `git pull` → `pwsh tools/export.ps1` → xem giờ file `build\windows\KyTucXa.exe`. Báo chủ dự án đúng giờ build để họ chắc đang chơi bản mới. |
| Chụp ảnh Forward+, đo FPS (không có card đồ họa) | Việc hình ảnh: yêu cầu lane B chụp ảnh trước/sau trong Handoff (lane B chạy trên Windows). Đo FPS / bot chơi thật: **hỏi chủ dự án trước** (tốn RAM, lâu; D-068: không chạy bot chương 3, 4). |
| Chơi tay | Mọi lỗi phải tái hiện bằng test hoặc probe cảnh thật; ghi rõ "chưa chơi tay" khi báo. |

## 3. Đọc theo thứ tự
1. `AGENTS.md`, `CLAUDE.md`.
2. `docs/STATUS.md`: mục "Việc tiếp theo" và bảng task (từ T-160 trở xuống, nhất là T-190…T-206).
3. `docs/DECISIONS.md`: **D-049 tới D-074** (mới nhất).
4. `docs/design/STORY.md`, `CH1_V2_MISSIONS.md`, `CH2_DESIGN.md`, `CH3_DESIGN.md`, `CH4_DESIGN.md` (mục "Đã chốt"), các kịch bản `CH1_SCRIPT.md` … `CH4_SCRIPT.md`.
5. Card mới nhất: `docs/tasks/T-201` … `T-206` (đọc mục Handoff và Review để thấy cách review).
6. Hướng dẫn chơi thử: `docs/playtest/CH1_QUICKTEST.md`, `CH2_WALKTHROUGH.md`, `CH3_QUICKTEST.md`, `CH4_QUICKTEST.md`.
7. Các prompt giao việc: `docs/handoff/lane-a.md` … `lane-e.md`, `web.md` (mục 1 = giao task, 2 = tiếp tục, 3 = yêu cầu sửa).

## 4. Trạng thái lúc bàn giao (2026-10-10 01:30)
- **Bản build chủ dự án đang chơi:** `build/windows/KyTucXa.exe` **2026-10-10 01:28** (commit `b4a6a06`, có đủ mọi sửa tới T-206). Máy chủ dự án đã mở khóa tới chương 4.
- **Chương 1:** tạm chốt lại (D-071) sau D-069, D-070: nằm giường người chết (1, 2, 4) + tắt đèn là sống, không cần nín thở; quản lý từ hành lang tới, mở cửa chậm, săn người trốn ngoài giường; gõ tường nhịp 3–1, gõ sai được gõ lại trong 90 giây.
- **Chương 2:** tạm chốt lại (D-073). D-072 (Trung nhắn cách qua vòng 3 cho hai bạn; qua vòng 3 ở từ lặp thứ 4) **chỉ kiểm bằng test, chủ dự án chưa chơi tay đoạn này**.
- **Chương 3:** **đang chơi kiểm tra.** Lần chơi gần nhất báo 3 lỗi, đã sửa (D-074): xác tầng 2 bám theo tiếng bình cứu hỏa, Minh Nhật đi bộ ra từ 203, tấm bịt 408 nhấp nháy (T-206, đúng ở cả 4 chương). Chờ chủ dự án chơi tiếp từ tầng 2 trở đi (vườn hoa, sân vận động, cổng, nhà ăn) và gửi góp ý.
- **Chương 4:** đã ghép đủ (T-194…T-198, T-200 giọng); lời đã duyệt (D-068); chủ dự án **chưa chơi kiểm tra**.
- **Âm thanh chưa ai nghe bằng tai:** giọng cuộc gọi và loa chương 2–4 (lần đầu có tiếng từ T-200), giọng chương 4 (loa, y tá), âm thanh chương 3–4.
- **Không có nhánh lane nào đang chờ review.** Số tiếp theo: **T-207**, **D-075**.
- **Việc treo nhỏ:** tên trường trên biển cổng (STORY nói trường không tên); nhà ăn T-189 (Claude dựng thay lane B) chờ chủ dự án xem.
- **Sau khi cả 4 chương tạm chốt:** giai đoạn "Ghép bản hoàn chỉnh" (D-059, 4–6 ngày): chơi liền mạch, đồng bộ đồ họa, ánh sáng 4h→9h, rà soát liền mạch, một tiến trình lưu, bot cả 4 chương. **Chưa bắt đầu; không tự bắt đầu trong 2 ngày này** trừ khi chủ dự án yêu cầu (lúc đó chỉ viết kế hoạch để duyệt).

## 5. Quy tắc làm việc (bắt buộc)
1. **Quyết định thiết kế (luật chơi, cốt truyện, độ khó, lời thoại) là của chủ dự án.** Có góp ý thiết kế: đưa 2–4 phương án kèm đề xuất (dòng đầu "(Recommended)"), hỏi bằng công cụ hỏi lựa chọn; ghi câu trả lời thành **D-xxx** trong `docs/DECISIONS.md` (ngày, quyết định, ngữ cảnh: lời chủ dự án và phương án nào được chọn).
2. **Việc của lane chỉ làm thay khi chủ dự án yêu cầu**, và ghi "Claude làm thay" (hoặc "Claude Code web làm thay") vào card và STATUS. Trước khi giao việc cho lane: **hỏi chủ dự án lane đó còn hạn mức không**. Khi hỏi "ai sửa", đưa lựa chọn: làm thay / giao lane.
3. **Sau MỌI thay đổi (kể cả tài liệu, dữ liệu, profile):** chạy cả bộ test và `tools/check.ps1` trước khi commit; **không commit khi test FAIL**, **không nới ngưỡng test** để cho qua. Commit message tiếng Anh, cuối message thêm dòng `Co-Authored-By` theo hướng dẫn của phiên. Push lên `main`. Chưa push thì nói rõ là chưa push.
4. Mọi lỗi chủ dự án báo: **tái hiện bằng test hoặc probe cảnh thật** trước, rồi sửa, viết test (kiểm ngược: bỏ phần sửa thì test phải FAIL), chạy cả bộ test, push, nhờ chủ dự án export, báo giờ build.
5. **Không cài gì ngoài ~/tools**, không thêm plugin/addon, không đổi phiên bản Godot, không C#. Asset chỉ CC0/CC-BY (ngoại lệ duy nhất: từ điển chương 2, CC BY-SA, D-051).
6. Trả lời chủ dự án **ngắn, tiếng Việt, kết luận trước**; báo trung thực cái gì chưa kiểm (chưa chơi tay, chưa nghe, chưa chụp ảnh).
7. Chủ dự án thích **âm thanh nhỏ**; hỏi họ nghe thử trước khi coi âm thanh là xong.

## 6. Các quy trình

### 6.1 Nhận góp ý chơi thử
1. Tách từng ý: lỗi hay thiết kế.
2. Lỗi: tìm code liên quan, viết probe tái hiện **đúng cách người chơi làm** (đi bộ đúng tốc độ, không dịch chuyển tức thì: bài học D-074), tìm nguyên nhân gốc, sửa, test.
3. Nếu lỗi nằm trong file lane: hỏi chủ dự án "làm thay hay giao lane". Giao lane thì viết card (mục 6.2).
4. Ghi D-xxx cho mỗi đợt góp ý (kể cả lỗi, để có lịch sử), cập nhật STATUS ("Việc tiếp theo" và bảng task).

### 6.2 Giao việc cho lane (card)
- File mới `docs/tasks/T-<số>-<mo-ta>.md` theo mẫu card gần nhất (T-202, T-206): tiêu đề, dòng Lane | Trạng thái | Agent, Nhánh `lane-<x>/T-<số>-<mo-ta>`, Phụ thuộc (D-xxx), Hạn đề xuất; **Bối cảnh** (số đo thật, đường dẫn node, tọa độ); **Việc** (đánh số, cụ thể); **Test** bắt buộc (trên cảnh thật, có kiểm ngược); **Được phép sửa**; **Checklist**; `## Handoff (agent điền)`; `## Review (integrator)`.
- Sửa prompt §1 trong `docs/handoff/lane-<x>.md` cho trỏ tới card mới (tên nhánh, đường dẫn card, "T-xxx: ..."). Thêm dòng vào bảng task trong STATUS. Commit, push, rồi nói chủ dự án dán prompt §1 nào cho lane nào.
- Việc phần core mà chủ dự án muốn giao cho "Claude Code web" khác: dùng `docs/handoff/web.md` (nhánh `core/T-xxx-...`, ngoại lệ phạm vi ghi trong card).

### 6.3 Review và ghép nhánh lane
1. `git fetch origin`; `git log --oneline main..origin/<nhánh>`; `git diff --stat main...origin/<nhánh>`; đọc mục Handoff của card trên nhánh (`git show origin/<nhánh>:docs/tasks/T-xxx.md`).
2. Đọc diff code chính. Kiểm: đúng card, đúng phạm vi file, có test thật, không nới test, không đụng file lane khác (nếu có, xem có hợp lý không).
3. `git merge --no-ff origin/<nhánh> -m "Merge T-xxx-... (lane X): <tóm tắt>"`. Xung đột `strings.csv` thường gặp: giữ key của cả hai bên.
4. Chạy test đầy đủ **sau khi ghép**. Ghép nhiều nhánh cùng lúc dễ lộ lỗi mà từng nhánh không thấy (T-201/T-202/T-203: 3 test chỉ FAIL khi đủ cả ba). Lane A có chế độ bắt buộc: `-- --filter=ch1_bunks_manager --t202-integration`.
5. Ghi mục Review trong card (đã kiểm gì, sửa gì sau ghép, còn gì), đổi trạng thái card thành done, cập nhật STATUS, commit, push, nhờ export.

### 6.4 Lời thoại, chữ hiển thị
- **Không sửa tay** `strings.csv` cho các key do bộ sinh tạo. Sửa ở bộ sinh rồi chạy lại: `python docs/design/ch1/build_ch1_script.py` (tương tự ch2, ch3, ch4). Bộ sinh ghi lại khối key của mình xuống cuối file (thứ tự dòng đổi là bình thường); key bị bỏ khỏi bộ sinh **không tự bị xóa** (xóa tay, như `DOC_CH1_TAP_CHART_3…6`).
- Lời mới phải được **chủ dự án duyệt**; ghi "đã duyệt" vào D-xxx; giọng do lane E thu sau khi duyệt (đặt tên theo key trong `game/audio/voice/vi/<KEY>.ogg`).
- **Bẫy:** `test_audio.gd::test_all_ogg_load_and_decode_with_correct_loop_flags` đòi mọi key bắt đầu bằng `SPK_CH1_`, `RULE_CH1_`, `MGR_CH1_`, `CHAT_CH1_`, `ROOM_CH1_`, `SPK_CH2_`, `RULE_CH2_`, `CHAT_CH2_`, `WORD_CH2_`, `SPK_CH3_`, `RULE_CH3_`, `CHAT_CH3_`, `NEAR_CH3_`, `ROOM_CH3_` (và 16 giọng chương 4 trong `Ch4AudioBank.VOICES`) phải có file `game/audio/voice/vi/<KEY>.ogg`. Thêm câu có giọng mà chưa có OGG thì test FAIL. Cách đã dùng (D-072): để lời mới trên **nhánh của task** (`core/T-xxx`), lane E tách nhánh từ đó, ghép cả hai cùng lúc.

## 7. Kiến trúc nhanh
- **Cảnh chính:** `game/scenes/main/chapter1.tscn` … `chapter4.tscn`; cả 4 dùng chung tầng 4 `game/scenes/levels/floor4/floor4.tscn` (→ `corridor.tscn`, phòng 407 `room_407.tscn`). Chương 3–4 thêm khuôn viên `game/scenes/levels/campus/campus.tscn` (tầng 4 ở y = 0, mặt đất y = −9,9; hệ tọa độ chung D-059).
- **Luồng (core):** `game/scripts/core/chapter1_director.gd` (`Chapter1Director`: stage, checkpoint, `_line` cuộc gọi, `_choice`, `_die`, `_wait_until(cond, giây, scaled)`), `chapter2_director.gd` kế thừa, `chapter3_director.gd` kế thừa (xác, đồng đội, thanh sắt, vùng), `chapter4_director.gd` kế thừa chương 3. Test chỉnh `director.time_scale = 0.002` để tua nhanh; `_wait_until(..., false)` là thời gian thật.
- **Giao tiếp:** autoload `EventBus` (`game/scripts/core/event_bus.gd`), `GameState` (cờ), `RuleSystem`, `Checkpoint`, `App`.
- **Test:** `game/tests/<core|player|levels|ui|audio|tools>/`, mỗi file `extends TestCase` (`game/tests/test_case.gd`), runner `res://tests/run_tests.tscn`.
- **Gỡ lỗi:** menu F9 khi chạy từ Godot (không có trong `.exe`): `game/scripts/debug/` (lane C). Bot: `tools/playthrough.ps1`, profile `tools/ch*-profile.json` (chỉ chạy khi chủ dự án cho).
- **Thực thể:** `game/scripts/entity/` (lane A): `zombie.gd` (nhìn 25 m trong hình nón, nghe tiếng, đập cửa qua `ZombieDoor`), `companion.gd` (đi theo, đuổi kịp ở chỗ khuất khi xa hơn 30 m hoặc kẹt 4 giây), `manager.gd` (`hunt`, `open_door`).

## 8. Bài học đã trả giá (đọc kỹ)
1. **Bot và test gọi đồ vật trực tiếp**, người chơi thì phải ngắm tới được: mọi thứ người chơi phải với tới cần test **"tia ngắm"** bằng `InteractRay` thật (T-202: giường Trung 0/36 tia vì một hộp va chạm kín).
2. **Test dịch chuyển tức thì người chơi che giấu lỗi**: D-074, xác thấy người chơi trên đường đi bộ về phòng 207 nhưng test cũ đặt thẳng người chơi vào phòng. Mô phỏng đi bộ ~2,2 m/s mỗi khung vật lý.
3. **Lưới đường đi ngoài trời đăng ký qua nhiều khung vật lý**: chờ tới khi điểm cần kiểm có trên lưới rồi mới kiểm đường.
4. **Không gọi `NavigationServer3D.map_get_closest_point` mỗi nhịp cho mỗi xác** (rất chậm trên lưới ngoài trời).
5. **Xác phải nhắm thẳng qua cửa đóng** mới đập cửa; nhắm chéo thì trượt dọc cánh cửa.
6. **Hai mặt phẳng trùng nhau** (z-fighting) trông như "cửa sáng nhấp nháy" (T-206).
7. Godot **không import lại mô hình khi chỉ sửa script import**: đổi một tham số trong file `.import` (ví dụ `nodes/root_name`) để ép mọi máy import lại.
8. **Godot editor có thể tự lưu file** khi chủ dự án mở để xem map. Trước khi chủ dự án export hoặc trước khi ghép nhánh trên máy họ: nhờ đóng editor (không lưu), rồi `git checkout` các file editor đã sửa.
9. **Dừng Godot giữa lúc `test.ps1` chạy** thì nó vẫn chạy tiếp sang `check.ps1` và chồng với lượt mới: dừng cả chuỗi lệnh.
10. GitHub đôi khi trả lỗi 500 hoặc LFS "Unable to verify locks" khi push: chờ rồi thử lại (lặp mỗi phút), không đổi cấu hình repo.
11. Cửa 407 của lane B đặt `is_open = true` ngay **lúc bắt đầu** mở chậm; muốn biết mở xong thì dùng `manager.door_opened` hoặc thời lượng.
12. `PhoneCallAudio`/`SpeakerVoiceBank` từng chỉ nhận key chương 1 (cuộc gọi chương 2–3 không có tiếng suốt nhiều ngày mà không ai biết): khi thêm loại nội dung mới, kiểm bằng cảnh thật rằng nó **thật sự phát**.

## 9. Kế hoạch đề xuất cho 2 ngày
1. **Chương 3:** chờ góp ý (chủ dự án đang chơi từ tầng 2 trở đi với bản 01:28). Xử lý theo mục 6.1.
2. **Chương 4:** khi chương 3 ổn, nhờ chủ dự án chơi `CH4_QUICKTEST.md`; nhắc các câu hỏi cuối file đó (cầu thang chính, 90 giây ở 407, lời thoại, bệnh viện).
3. **Nghe âm thanh:** nhắc chủ dự án nghe giọng cuộc gọi chương 2–4 và giọng chương 4 trong lúc chơi; góp ý âm lượng giao lane E.
4. Mỗi lần chương nào ổn: ghi **D-xxx "tạm chốt lại chương N"**.
5. **Không** bắt đầu giai đoạn D-059, **không** chạy bot/đo FPS khi chưa được phép.

## 10. Khi hết 2 ngày: bàn giao lại cho phiên ở máy
Trước khi chủ dự án tắt phiên web (hoặc khi họ nói "bàn giao lại"):
1. Cập nhật `docs/STATUS.md` (dòng "Cập nhật lần cuối", "Việc tiếp theo", bảng task).
2. Viết `docs/handoff/NHAT_KY_WEB_2026-10-10_11.md`: việc đã làm theo ngày; D-xxx mới; card mới và trạng thái; nhánh lane đang chờ review; build cuối cùng chủ dự án đã export (giờ, commit); việc còn dở; bài học mới.
3. Chạy test và check, commit, push. Báo chủ dự án commit cuối cùng.
