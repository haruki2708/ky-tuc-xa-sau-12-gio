# T-234 — Rà âm thanh sau đợt nâng đồ họa: vị trí nguồn âm và độ to
- Lane: E (Âm thanh) | Trạng thái: done (merge 08/11/2026) | Agent: tài khoản GPT lane E (D-141, từng làm lane B)
- Nhánh: `lane-e/T-234-audio-audit-after-graphics` từ `origin/main` mới nhất.
- Quyết định giao: **D-142** (chủ dự án chọn 07/11). Việc đầu của lane E mới.
- Lượt này **chỉ đo, kiểm tĩnh và báo cáo**. **Không đổi tiếng nào, không dời nguồn âm nào.**

## Bối cảnh
- Lần rà âm thanh phòng 407 gần nhất là [T-218](T-218-room407-object-audio.md) (15/10, D-111). Sau đó nhiều thứ đã đổi chỗ hoặc thêm mới:
  - vỏ phòng 407 mới, cửa ban công bản lề mở sẵn, cửa nhà tắm đổi bản lề theo vỏ (T-222, D-129);
  - nhà tắm sửa, màn tắm dời sang tường tây (D-109);
  - đồ chặn và đổi vị trí đồ (T-225), ổ điện, dây mạng, quạt đứng quay có tiếng ù (T-226, D-136);
  - quản lý Tripo, soi giường, đuổi theo (D-120, T-224);
  - âm báo cháy, chuông (T-212).
- Chủ dự án thích **âm nhỏ, nhẹ**. Mức mục tiêu đang dùng: `audio_source/README.md` (Ambience −24 LUFS, SFX −18 LUFS, ngoại lệ nhỏ hơn trong `TARGET_OVERRIDES`), số đo từng file trong `audio_source/build_report.json`.
- Agent không nghe được. Mọi kết luận về chất âm phải ghi "chờ chủ dự án nghe".

## Việc cần làm
1. **Vị trí nguồn âm khớp đồ:** liệt kê mọi nguồn âm 3D (`AudioStreamPlayer3D`, vùng âm `AmbientZone`, `ReverbZone`) ở phòng 407, nhà tắm, ban công, hành lang tầng 4, nhà vệ sinh chung; ở chương 1–4 (instance scene chương, `auto_start = false`, như test T-228; không chơi). Với mỗi nguồn gắn với một đồ vật (quạt, đèn tuýp, vòi sen, gương, cửa, ổ điện, loa…): đo khoảng cách từ nguồn âm tới **hình thật** của đồ (bounds model đang hiển thị). Bảng gồm: chương, node path, đồ vật, khoảng cách, đánh giá **OK / lệch / thiếu nguồn**, lý do. Ngưỡng "lệch" do bạn đề xuất kèm lý do (T-218 dùng cách tương tự).
2. **Độ to:** đo lại mọi file `game/audio/**/*.ogg` (LUFS tích hợp, true peak) bằng ffmpeg `loudnorm`, so với mục tiêu trong `audio_source/README.md` và `build_report.json`. Ghi file nào lệch quá 1 LU, file nào thiếu trong report. Kèm bus và gain trong game (`default_bus_layout.tres`, `volume_db` của player) để ước lượng mức nghe thật tương đối.
3. **Công cụ:** script đo trong `audio_source/` (ví dụ `audit_audio.py`), chạy lại được, đường dẫn ffmpeg như pipeline hiện có. Nếu kiểm vị trí cần Godot: test hoặc scene tạm trong `game/tests/audio/` (headless, không chơi).
4. **Báo cáo** `audio_source/reports/T-234-audio-audit.md`:
   - bảng mục 1 và mục 2;
   - **đề xuất sửa** xếp ưu tiên (dời nguồn nào, giảm hay tăng bao nhiêu dB), ghi rõ ai sửa: lane E (`game/audio/`, bus), lane B (nguồn âm nằm trong scene level), integrator (core, director);
   - **danh sách nghe thử cho chủ dự án**: mở scene nào, phím nào, đứng ở đâu, nghe gì, theo mẫu T-218 mục "Danh sách âm chủ dự án cần nghe". Ngắn, ưu tiên những chỗ nghi lệch.

## Được phép sửa
- `audio_source/` (script mới, `audio_source/reports/` mới).
- `game/tests/audio/` (test hoặc công cụ kiểm mới).
- Card này: chỉ Checklist và Handoff.

## Không được
- **Không đổi file âm thanh, mức âm, bus, vị trí nguồn âm** trong lượt này (kể cả `default_bus_layout.tres`: Godot tự ghi đè sau test thì `git checkout -- game/default_bus_layout.tres`).
- Không sửa scene, script gameplay, core, level.
- Không chạy bot, không đo FPS, không tiêu credit Tripo.

## Checklist hoàn thành
- [x] Bảng vị trí nguồn âm chương 1–4, có node path và khoảng cách
- [x] Bảng độ to mọi OGG so với mục tiêu
- [x] Script đo chạy lại được; test (nếu có) đạt
- [x] Báo cáo có đề xuất sửa xếp ưu tiên và danh sách nghe thử cho chủ dự án
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [x] Handoff trung thực, có commit hash, ghi rõ "chưa nghe bằng tai"

## Cách kiểm tra
- Integrator đọc báo cáo, chạy lại script đo, thử lại vài kết luận "lệch".
- Chủ dự án nghe theo danh sách, rồi quyết lượt sửa.

## Handoff (agent điền)

### Lane E — 08/11/2026

- Nhánh `lane-e/T-234-audio-audit-after-graphics`, từ `origin/main` `85598c6`; đầu phiên working tree sạch, fetch/pull ff-only/LFS thành công. Đã bảo toàn toàn bộ staged/untracked bằng stash, rebase sạch và khôi phục index lên `0fe5e44` khi integrator push bản ghép T-231/T-232; không mất thay đổi.
- **Đã làm:** [báo cáo](../../audio_source/reports/T-234-audio-audit.md), bảng đủ 632 OGG, 273 nguồn 3D và 32 vùng trên bốn chương; 8 phép đối chiếu vị trí khi phát suy từ wiring. Snapshot không chạy truyện (`auto_start=false`), không chơi/bot/FPS. Không sửa waveform, gain, bus hay vị trí nguồn.
- **Kết quả chính:** không OGG lệch target quá 1 LU; 628 hash/LUFS khớp report, 4 chunk âm tiết chương 2 thiếu build report. Nguồn gắn đồ trong snapshot đều trong ngưỡng đề xuất 0,15 m. Wiring chương 1 dùng router cho tiếng ổ điện (3,9822 m), tiếng rung tay nắm giữ vị trí router (2,9056 m sau cue router; 0,4108 m khi vào riêng nhiệm vụ cửa). Chưa chơi để xác nhận các đường này. Ambience runtime mặc định 0 dB do settings, khác −3 dB trong layout.
- **Cách kiểm:** `py -3 audio_source/audit_audio.py --output audio_source/reports/t234`; `pwsh tools/test.ps1 -Filter audio_audit_snapshot`; `py -3 audio_source/audit_audio_spatial.py`. Snapshot thô và mọi log ở `build/`, không commit. Script chỉ đọc asset; hash trước/sau bảo vệ phép đo. Bảng khoảng cách tới AABB mesh thật có giới hạn nêu trong báo cáo, không dùng mesh đã ẩn của phòng cũ.
- **Đề xuất ngoài phạm vi:** integrator sửa caller ổ điện/tay nắm trong `chapter1_director.gd`; E hỗ trợ tách rig khi được card. Chủ dự án quyết nghe qua cửa ban công và mức burst đèn; B giữ quyền sửa zone/nguồn trong level. Không tự sửa core, level, settings/UI hoặc marker chuông T-212. Bổ sung hồ sơ chunk âm tiết là đề xuất lượt sau, chưa sửa generator hiện có.
- **Chưa kiểm:** chất âm, hướng nghe, mix cuối/loa thật, animation của quản lý/dao và mọi nguồn tạo muộn khi chơi. **Chưa nghe bằng tai, chờ chủ dự án nghe.** Hướng dẫn fixture và cảnh thật có trong báo cáo; không coi preview là bằng chứng wiring production đúng.
- **Kiểm tra cuối:** lượt Godot lane E 02:39:30–03:14:33 ngày 08/11 trên base `0fe5e44` (trùng `origin/main`), script `build/t234/verify.ps1`, log `build/t234/verification.log`: snapshot mới đạt, full test `RESULT: 864 passed, 0 failed`, check `RESULT: check 0 error(s)`, cả hai exit 0; khóa đã trả. Các lượt full trước (02:32 base cũ, 02:37) bị dừng giữa chừng, không có RESULT, không tính.

```text
py -3 audio_source/audit_audio.py --output audio_source/reports/t234
RESULT: audit measured 632 files; 0 target deviations; 4 missing reports; 0 unmeasurable
pwsh tools/test.ps1 -Filter audio_audit_snapshot
RESULT: 1 passed, 0 failed
pwsh tools/test.ps1 -Filter audio
RESULT: 126 passed, 0 failed
py -3 audio_source/audit_audio_spatial.py
RESULT: spatial audit 273 sources, 32 zones, 8 wiring projections
Kiểm toán học point-to-AABB và đối chiếu hash/coverage 632 file:
RESULT: audit math and 632-file evidence integrity PASS
RESULT: Python syntax PASS
RESULT: spatial evidence coverage PASS
pwsh tools/test.ps1
RESULT: 864 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Commit triển khai: `0aaa330` (`T-234: Add audio audit tools, chapter snapshot and report`), push nhánh `lane-e/T-234-audio-audit-after-graphics`. **Claude làm thay** commit, push và phần Handoff này: lane E hết hạn mức khi lượt full test/check đang chạy nền (kết quả trên là của lượt đó). Blocked: không.

## Review (integrator, 08/11/2026)
- **Đạt, merge vào `main`.** Đúng phạm vi lane E: chỉ thêm script đo trong `audio_source/`, báo cáo `audio_source/reports/`, một test snapshot trong `game/tests/audio/`. Không đổi file âm, gain, bus hay vị trí nguồn.
- **Claude làm thay** commit, push và Handoff: lane E hết hạn mức khi lượt full test/check đang chạy nền. Integrator đọc log lượt đó (`build/t234/verification.log` ở `lane-e2`): full `RESULT: 864 passed, 0 failed`, check `RESULT: check 0 error(s)`, trên base `0fe5e44` trùng `main`, nên không chạy lại.
- Integrator kiểm lại kết luận "lệch" trong code: `chapter1_director.gd::_mission_cue()` luôn dời MissionAudio về router, nên tiếng công tắc/chập ổ điện phát ở router (lệch khoảng 4 m); `_hold_the_door()` bật rung tay nắm mà không dời nguồn về cửa. **Đúng, là lỗi của core**; sửa trong task riêng của integrator (0 dB, chỉ dời vị trí), xong thì nhờ chủ dự án nghe lại.
- Điểm cần chủ dự án quyết (báo cáo mục "Đề xuất sửa"): nghe chuyển vùng phòng 407 → ban công; burst đèn chập có gắt không. Danh sách nghe thử: báo cáo mục "Danh sách nghe thử cho chủ dự án". **Chưa nghe bằng tai.**
- Ghi chú nhỏ: test snapshot ghi `build/t234/spatial_raw.json` mỗi lần chạy full test (thư mục build, không commit): chấp nhận.
- **08/11, integrator sửa 2 lỗi vị trí âm (P1 của báo cáo), 0 dB:** `chapter1_director.gd` đặt tiếng công tắc ở đúng nút vừa bấm, tiếng chập ở ổ cắm, tiếng router ở router (`_mission_cue(cue, at)`, `_strip_position`); rung tay nắm và tiếng nhả ở `Door407/Pivot/HandlePivot` (`_set_handle_rattling`), không bị cue router kéo đi. **Claude làm thay lane E** phần `game/scripts/audio/ch1_mission_audio.gd`: `play_cue(cue, at)`, `set_handle_rattling(on, at)` đặt từng nguồn thay vì dời cả rig. Test: `test_chapter1.gd::test_mission_sounds_come_from_the_strip_the_router_and_the_handle`, `test_ch1v2_audio.gd` thêm kiểm vị trí. **Chưa nghe bằng tai:** chủ dự án nghe theo mục 1 danh sách nghe thử của báo cáo.
