# T-270 — Chuyển động bước 4: đường tay của Trần Trung lấy từ clip Mixamo

- Lane: integrator | Trạng thái: **đang làm mẫu thử** (nhánh `t270-hand-paths`) | Agent: integrator
- **Model:** Mythos 5.2 xhigh (chủ dự án chọn)
- Quyết định nền: D-189, D-190, D-191, **D-192** (bước 4 trước, rồi bước 5; thêm động tác đứng dậy khỏi giường)

## 0. Hiện trạng (đọc code và video `t269_tay_cu_moi.mp4`, 24/11)
- Thao tác tay không phải giấy (cửa, tủ, công tắc, nút, tay nắm): bàn tay đi **đường thẳng** từ chỗ đang buông tới đồ vật, tốc độ theo `smoothstep` (`player_body.gd` `_tick_action`, pha REACH: `_from.lerp(_marker.global_position, reach)`). Lúc rút tay về cũng đường thẳng.
- Giấy đã có đường riêng (`_reach_path`, T-239).
- Ở góc nhìn người chơi, thân và tay trái gần như không lọt vào khung hình; cái thấy rõ là cánh tay phải và bàn tay. Vì vậy mẫu thử làm đường tay trước, phần thân theo clip (chỉ thấy trong gương) để sau.

## 1. Cách làm
- **Lấy đường tay từ clip Mixamo** (công cụ `art_source/graphics_upgrade/mixamo/`): đo cổ tay phải của clip trong đoạn "đưa tay tới" và đoạn "rút tay về", tách thành:
  - tiến độ dọc đường thẳng nối điểm đầu và điểm chạm (nhịp nhanh chậm của người thật);
  - độ lệch khỏi đường thẳng đó (đường cong: lên trên, ra ngoài), tính theo tỉ lệ chiều dài đường.
- **Áp vào game:** điểm tay = điểm trên đường thẳng của game theo tiến độ đó + độ lệch nhân chiều dài. Đầu và cuối trùng đúng chỗ cũ, nên **mốc chạm 0,45 giây, 1 giây cho thao tác và điểm chạm không đổi**.
- Bảng đường tay sinh ra thành file code `game/scripts/player/reach_paths.gd` (công cụ ghi, không sửa tay).
- Cờ `PlayerBody.reach_style` (`&"mx"` bật, mặc định tắt tới khi chủ dự án duyệt).

## 2. Mẫu thử (cổng duyệt)
- Hai đường: **bấm/với ngang tầm** (clip Button Pushing) và **tay nắm cửa** (clip Opening Door Inwards).
- Video cũ | mới bằng `protagonist_pilot.tscn -- --body-demo`: mắt người chơi và nhìn từ trong phòng.
- Chủ dự án ưng thì làm tiếp: cúi nhặt (1,4 giây), mở tủ, vung thanh sắt chương 3, cửa kẹt chương 2; sau đó mới tới phần thân theo clip (gương).

## 3. Việc khác trong D-192
- **Đứng dậy khỏi giường:** phiếu riêng T-271 sau mẫu thử này (đổi thời gian rời giường trong `player.gd`, cần chủ dự án chốt số giây).

## 4. Phải giữ
- 1 giây mỗi thao tác, cúi nhặt 1,4 giây, mốc chạm, tầm với, các hợp đồng T-239/T-241/T-242/T-243/T-249 (chân không nhấc, tay tự do không giơ, camera trước đầu).
- Cờ tắt thì mọi thứ như bản `6dfd01dd`.
