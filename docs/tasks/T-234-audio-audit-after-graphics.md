# T-234 — Rà âm thanh sau đợt nâng đồ họa: vị trí nguồn âm và độ to
- Lane: E (Âm thanh) | Trạng thái: todo | Agent: tài khoản GPT lane E (D-141, từng làm lane B)
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
- [ ] Bảng vị trí nguồn âm chương 1–4, có node path và khoảng cách
- [ ] Bảng độ to mọi OGG so với mục tiêu
- [ ] Script đo chạy lại được; test (nếu có) đạt
- [ ] Báo cáo có đề xuất sửa xếp ưu tiên và danh sách nghe thử cho chủ dự án
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [ ] Handoff trung thực, có commit hash, ghi rõ "chưa nghe bằng tai"

## Cách kiểm tra
- Integrator đọc báo cáo, chạy lại script đo, thử lại vài kết luận "lệch".
- Chủ dự án nghe theo danh sách, rồi quyết lượt sửa.

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
