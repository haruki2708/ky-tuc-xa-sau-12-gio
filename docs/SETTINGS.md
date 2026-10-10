# Hợp đồng cài đặt (`user://settings.cfg`)

Đây là hợp đồng chung giữa các lane. Muốn thêm hoặc đổi một mục, ghi "Yêu cầu thay đổi" trong task card; integrator sẽ cập nhật file này.

## Quy tắc
- **Lane D ghi** (menu cài đặt). Lane khác **chỉ đọc**.
- Đọc bằng `ConfigFile` trực tiếp. Thiếu file hoặc thiếu mục thì dùng giá trị mặc định trong bảng. Giá trị sai kiểu hoặc ngoài khoảng thì cũng dùng mặc định.
- Khi đổi một mục, lane D **lưu file trước**, sau đó emit `EventBus.settings_changed(section, key)`. Lane đọc nghe signal này, đọc lại đúng mục của mình và áp dụng ngay, không cần khởi động lại game.
- Lúc khởi động, mỗi lane đọc mục của mình trong `_ready()`.
- Không lưu gì khác vào file này ngoài các mục trong bảng.

## Các mục
| Mục | Kiểu | Mặc định | Khoảng | Ai áp dụng | Ghi chú |
|---|---|---|---|---|---|
| `[ui] locale` | String | `"vi"` | `vi`, `en` | D | Đã có từ T-104 |
| `[ui] content_warning_seen` | bool | `false` | | D | Màn cảnh báo nội dung đã hiện lần đầu (T-139) |
| `[audio] master_db` | float | `0.0` | −40…+6 | D | Đặt `AudioServer.set_bus_volume_db` cho bus `Master`; ≤ −40 thì mute bus |
| `[audio] ambience_db` | float | `0.0` | −40…+6 | D | Bus `Ambience` |
| `[audio] sfx_db` | float | `0.0` | −40…+6 | D | Bus `SFX` |
| `[audio] footsteps_db` | float | `0.0` | −40…+6 | D | Bus `Footsteps` (lane E thêm ở T-126). Bus chưa có thì ẩn thanh trượt |
| `[audio] voice_db` | float | `0.0` | −40…+6 | D | Bus `Voice` |
| `[audio] music_db` | float | `0.0` | −40…+6 | D | Bus `Music` |
| `[input] mouse_sensitivity` | float | `0.002` | 0.0005…0.006 | A | Player đọc |
| `[video] head_bob` | bool | `true` | | A | Player đọc; tắt cho người dễ say 3D |
| `[video] ps1_strength` | float | `1.0` | 0…1 | B | Filter PS1 đọc; 0 là tắt filter (D-005) |
| `[video] brightness` | float | `1.0` | 0.5…1.5 | B | Filter PS1 đọc, áp dụng kể cả khi `ps1_strength = 0` |
| `[accessibility] reduce_scares` | bool | `false` | | core, A, F | Giảm hù dọa (D-024): StoryDirector bỏ jumpscare hình ảnh và sting mạnh; thực thể truy đuổi chậm hơn; tiếng thì thầm nhỏ hơn. F tiếp nhận trách nhiệm âm thanh của E theo D-078; key và hành vi giữ nguyên |

## Tạm dừng
- Lane D mở menu tạm dừng bằng phím `pause` (Esc), đặt `get_tree().paused`, rồi emit `EventBus.game_paused(paused)`.
- Bắt hoặc thả chuột: Player (lane A) làm theo `game_paused`. Player **không tự xử lý Esc** nữa (T-125).
