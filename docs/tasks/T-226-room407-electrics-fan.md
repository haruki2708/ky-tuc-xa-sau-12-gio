# T-226 — Phòng 407: ổ cắm, dây mạng, ổ mạng dựng bằng Blender; quạt đứng chạy
- Lane: **integrator** (Claude làm thay B/E) | Trạng thái: **xong (23/10/2026), chờ chủ dự án chơi bản build mới** | Agent: Claude Code ở máy (Opus 5.5)
- Quyết định: **D-136**.
- Liên quan:
  - [T-225](T-225-playtest-fixes-oct23.md): lần sửa trước, giữ khối tạm của đầu dây mạng;
  - D-099: quạt trần đã tách cánh theo cách này;
  - D-106: dây tròn có đầu cắm.

## Chủ dự án báo (23/10/2026)
> "về cơ bản tất cả lỗi đã sửa xong rồi, tôi mới chụp 3 bức ảnh để chỉnh sửa lại , 1 là ổ cắm( o_cam.png) vẫn là dạng hình khối, 2 là cái quạt (quat.png) tôi muốn quạt đấy đang quay ( tất nhiên quạt đã  cắm vào ổ cắm), 3 là cục dây mạng ( cun_day_mang.png) vẫn là dạng hình khối đi kèm với ổ cắm vẫn dạng khối. Cục dây mạng và ổ cắm thì cho tripo ai làm hả, còn cái quạt thì sao?"

## D-136: chủ dự án chọn
- **Ổ cắm, đầu dây mạng, ổ mạng trên tường:** Claude dựng bằng Blender. Công tắc là chi tiết rời bật/tắt được, kích thước 2–3 cm đúng thật, không tốn lượt Tripo.
- **Quạt đứng:** Claude tách cánh từ quạt Tripo đang có cho quay (như quạt trần D-099), cắm dây vào ổ tường gần nhất.
- **Tiếng quạt:** ù rất nhỏ.

## Đã làm (Claude làm thay)
1. **Đồ điện Blender** (`art_source/graphics_upgrade/room407_electrics/build_electrics.py`, README cùng thư mục):
   - ổ cắm nối dài: vỏ hai nửa có đường nối, 3 công tắc bập bênh đỏ, đèn báo, lỗ cắm tròn hai chân;
   - phích cắm laptop (đen), ấm đun (trắng), cục sạc router (đen, quấn băng keo đỏ như cũ);
   - đầu dây mạng RJ45: thân trong, 8 chân đồng, lẫy gài, chụp đuôi màu xanh hoặc xám theo dây;
   - mặt ổ mạng trên tường có 2 cổng.
2. **Ổ cắm trong game** (`ch1v2/power_strip.tscn`, `power_strip.gd`):
   - vỏ, công tắc, đèn của mẫu chuyển sang đúng các node `Case`, `SwitchN/Rocker`, `SwitchN/LED` mà luật chơi và vùng bấm của lane A đang dùng, nên bật/tắt, sập điện, tia lửa vẫn như cũ;
   - ổ cắm nằm cố định ở chỗ chương 1 vẫn dời tới (x 1,35; bỏ `STRIP_NUDGE`), để 3 dây điện cắm đúng vào 3 phích.
3. **Dây và ổ tường** (`ch1v2/cables.gd`):
   - đầu dây mạng là mẫu RJ45, nằm sát sàn; khi cắm vào ổ mạng thì đầu dây nằm đúng trong cổng;
   - khối xanh tạm của lane A đã ẩn (`chapter1_director.gd`);
   - 2 ổ tường Tripo mới (`placements.json`):
     - `SocketStrip` trên tường phía tây, sau giường A: dây ổ cắm nối dài cắm vào đây, đi vòng tránh quả bóng;
     - `SocketFan` trên vách nhà tắm cạnh quạt: dây quạt đi sát sàn từ chân quạt tới đây.
4. **Quạt đứng chạy** (`room407_furnished/split_standing_fan.py`, `room407.gd`):
   - quạt Tripo liền một khối; cánh được tách theo vị trí, nằm giữa lồng sau và lồng trước;
   - khoảng 570 mặt nan bị nướng dính màu cánh được lấy lại màu nan;
   - cánh quay 4,5 vòng/giây, kèm 2 bản cánh mờ đi sau làm vệt nhòe;
   - tiếng ù dùng lại `ceiling_fan.ogg`, rất nhỏ (−24 dB, chỉ nghe trong khoảng 5 m, cao giọng hơn một chút);
     như quạt trần, chỉ nghe khi người chơi ở trong phòng (`AmbientZone.add_emitter`); cảnh nghe thử T-218 tắt nó lúc mở.
   - Video: `build/graphics/room407/t226_quat.mp4` (không đưa vào git).

## Kiểm tra
- Ảnh trước/sau trong chương 1, đèn pin 1,5: `art_source/graphics_upgrade/room407_electrics/compare_t226.jpg`.
- Test:
  - `test_ch1v2.gd`: ổ cắm là mẫu Blender, đủ 3 phích, có băng keo đỏ, dây và ổ tường, đầu RJ45 nằm sàn;
  - giới hạn tam giác của ổ cắm nâng lên 8.000 (vỏ 3,2 nghìn và 3 phích, mỗi phích khoảng 1,1 nghìn; đồ Tripo trong phòng nướng ở 5 nghìn, D-093);
  - `test_room407_playable_furnished.gd`: cánh quạt quay quanh đúng trục, có 2 bản mờ, tiếng ù nhỏ trên bus Ambience, có ổ tường;
  - `test_chapter1.gd`: khối xanh đầu dây mạng đã ẩn.
  - lần chạy cả bộ đầu 849/850: cảnh nghe thử âm thanh T-218 đòi mọi nguồn im lúc mở, tiếng quạt đứng tự phát; đã sửa như trên.
  - **Cả bộ sau khi sửa: 850/850; `check.ps1` 0 lỗi.**
