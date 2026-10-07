# T-198 — Âm thanh chương 4

29 âm mới tự tổng hợp CC0, 7 bản thoại eSpeak (5 câu nguyên văn thiết kế; 2 câu kết có cả hai giọng nữ). Chưa nghe bằng tai, chưa được chủ dự án duyệt. Không suy ra diễn biến/luật mới từ âm thanh.

## Tạo lại và đo

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' audio_source/ch4_process.py
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' audio_source/ch4_voice_process.py
pwsh tools/test.ps1 -Filter ch4_audio
```

Dùng Python stdlib, FFmpeg 9.0.2 và eSpeak NG 1.52.0 có sẵn dưới `D:\Tools`; không cài gì. SFX 48 kHz mono, raw PCM16 và Vorbis q4. Report `build_report.json` ghi seed, SHA256 raw/OGG, độ dài, LUFS, true peak, biên nối loop. Giọng: `audio_source/voice_ch4/build_report.json`. Script giọng xác nhận từng câu còn nguyên văn trong `CH4_DESIGN.md`, tìm khóa core khớp văn bản nếu đã có; hiện `core_keys=[]` vì main chưa cung cấp khóa CH4. Script không tạo khóa dịch hoặc sửa CSV.

| Âm/nhóm | Mục tiêu LUFS trước bus | Bus / gain runtime tối đa |
|---|---:|---|
| decoy_ring / phone_land / battery_empty | −42 / −41 / −49 | SFX / 0 dB, 3D 30 m |
| door_pound | −39 | SFX / −12→−2 dB theo fraction |
| wood_crack / wood_splinters | −43 / −42 | SFX / −6 dB |
| door_burst / door_burst_soft | −33 / −44 | SFX / 0 dB |
| library / drizzle | −54 / −56 | Ambience / 0 dB |
| librarian_rise / books_fall / shelf_corpse / back_door_hit | −40 / −39 / −38 / −38 | SFX / 0 dB; giảm hù −10 dB |
| knife_pull / stairs_turn / hall_lights / door_hand / neck_hand | −42 / −43 / −44 / −42 / −44 | SFX / 0 dB; giảm hù −10 dB |
| pa_laugh / pa_signed | −39 / −33 | Voice / 0 dB |
| Hai giọng y tá, cả hai biến thể câu kết | −34 | Voice / 0 dB |
| body_fade / heartbeat | −49 / −47 | Music / 0→−36; SFX / 0→−24 dB |
| monitor / nurse_step_01,02 / hospital_door | −49 / −46 / −46 | SFX / Footsteps / SFX, 0 dB |
| music_sparse / music_hospital / music_end | −53 / −56 / −51 | Music / 0 dB |
| T-186 zombie_growl sát cửa | −43 gốc | SFX / −6 dB |
| T-186 horde + 2 zombie_growl ở StairCrowd | −46 / −43 gốc | Ambience / −18 dB mỗi nguồn, tối đa 3 |
| T-186 rescue_siren | −57 gốc | Ambience / −18→0 dB, 8:30→9:00 |

Đo lại OGG lệch mục tiêu ≤1 LU, peak ≤−2 dBTP. Không boost trên 0 dB; trần file không phải khẳng định loudness tổng mix ở tai. Khoảng nghe 30 m là `max_distance`/suy hao 3D, cần chủ dự án nghe kiểm chứng trên thiết bị thật. Cửa vỡ là transient lớn nhất bộ SFX mới; âm lượng tổng còn phụ thuộc bus người chơi.

## Hợp đồng tích hợp cho core/A/B

Tạo **một `Ch4AudioRig`** làm con scene chương 4, sau đó gán các node thật. Không autoload; không để rig chương trước tiếp tục phát nền. Tất cả player và rig cửa đều là con của rig chương 4, nên giải phóng theo scene; không tạo bus phụ, không sửa bus chung. Nếu chuyển campus sang hospital bằng thay scene, tạo rig mới ở hospital và gọi `set_area("hospital")` sau khi gán marker.

```gdscript
var audio := Ch4AudioRig.new()
chapter_scene.add_child(audio)
audio.listener = player
audio.monitor_marker = hospital_monitor_marker # Có thể gán sau khi dựng bệnh viện.
audio.stair_points.assign(stair_crowd.get_children()) # Các Marker3D L1_01…L4_01.
audio.register_door(&"407", door_407)
audio.register_door(&"library_back", back_door)
# T-190: đăng ký từng cửa bằng đúng id trong door_damage_changed.
audio.scare_positions[&"librarian_rise"] = librarian_seat.global_position
audio.set_area(&"road")
```

- `set_area`: `road`, `library`, `return_b`, `stairs`, `407`, `hospital`; giá trị khác tắt nền. Core gọi theo scene/beat đã chốt; audio không tự đoán tọa độ hoặc diễn biến. Đăng ký vị trí cho 9 scare có clip bằng anchor T-194; mặc định nếu thiếu là vị trí rig, cần gán trước khi tích hợp thật.
- Tự nghe `phone_decoy_thrown`: hạ điện thoại + loop 6 giây tính theo thời gian scene (pause dừng); beep yếu khi hết pin. Trùng cùng vị trí/số pin không kéo dài chuông. Không phát `noise_emitted` lần hai. Vị trí `at` là điểm rơi do A cung cấp; audio không mô phỏng đường bay.
- `register_door(id, anchor)` chống đăng ký trùng. Rig theo anchor khi di chuyển; anchor bị free thì tắt âm. `door_damage_changed` >0 bắt đầu đập ngay rồi 0,7 giây/lần; gain tăng; lớp nứt/vỡ theo nhịp và growl từ 0,8. Fraction 0 hủy/reset đợt; core/A cần gửi 0 khi hủy đập/mở cửa. Fraction 1 phát burst một lần, hoặc core gọi `play_door_burst(id)` nếu cửa mở vỡ sớm. `player_death_started("door_burst")` dùng cửa vừa có damage, không nhân đôi burst; thiếu cửa đăng ký thì fallback SFX ở rig. Không đụng sức bền cửa hoặc AI.
- 10 mã `scare_triggered` đúng T-194, dedupe từng mã đến checkpoint. `neck_hand`: tắt âm thuộc rig ngay, chờ 0,8 giây rồi thở; giữ nền im đến khi core đổi area. Những emitter thuộc scene/lane khác phải được core tắt riêng, rig không mute bus chung.
- `StairCrowd`: tối đa 3 nguồn gần listener nhất trong 24 m, T-186 giảm −18 dB; không instantiate zombie hoặc sửa giới hạn đám đông.
- Còi nghe `time_changed`: clamped 510→540 phút; không chạy đồng hồ gameplay. Phòng 407 tắt nhạc, nền/còi/crowd/chuông; giữ cửa và scare/hơi thở. Không tự phát heartbeat ở phòng 407.
- `play_pa_laugh(at)` một lần/checkpoint, core chọn lúc vòng 5. `play_line(asset_id, at)` trả số giây của clip hoặc 0 nếu thiếu/trùng; phát trên Voice, **core phát subtitle bằng khóa thật và chờ thời lượng**. Không dùng Speaker đồng thời cho cùng câu.
- Asset `pa_signed` là nguyên văn lời ký tên. `nurse1_wake` / `nurse2_quake` đúng người nói trong thiết kế. `nurse1_all` / `nurse2_all` và `nurse1_alone` / `nurse2_alone` là các lựa chọn cho **cùng câu**, chỉ chọn một theo người nói core/chủ dự án chốt. Asset ID không phải khóa localization. Giọng `vi+f1` và `vi+f3`; PA giữ preset `loa` chương 1/3, mastering nhỏ hơn. Giọng Việt như pipeline hiện có; không tự tạo bản dịch.
- `fade_message_requested(seconds)` làm body fade giảm gain + tim thưa 0,8→2,4 giây trong cửa sổ do core truyền (12 giây theo thiết kế); không gửi lại chữ hoặc quyết định ending. Clip body dài 8 giây, đuôi tim tiếp tục đến hết cửa sổ.
- `ch4_ending` chuyển audio sang hospital; cần gán `monitor_marker` trước, hoặc gọi `hospital.enter_hospital(at)` khi marker sẵn sàng. Máy bíp mỗi 1 giây; `monitor_skip` bỏ đúng lần kế tiếp rồi trở lại, lặp signal không bỏ thêm. `hospital.play_nurse_step(at)` bus Footsteps luân phiên hai mẫu, `hospital.play_door(at)` SFX; core gọi theo animation. `chapter_finished(4)` phát đúng một nhạc kết.
- Checkpoint dừng tất cả, xóa dedupe; core gọi lại area/đăng ký anchor nếu thay node. Death chặn tín hiệu đến muộn. `stop_emitting()` là dừng vĩnh viễn rig trước khi queue_free; scene free ngắt kết nối EventBus tự động.

**Chưa tích hợp vào director/scene thật:** nhánh main cơ sở `ff17fb4` mới có hợp đồng T-194; chưa có director CH4 hoặc các khóa `SPK_CH4_*`, `NEAR_CH4_NURSE_*`. Yêu cầu core/A/B nối các API trên, chốt người đọc câu kết và khóa chữ. Không sửa file của lane khác trong T-198.

## Nghe thử (nhờ chủ dự án)

Godot F6 `res://audio/test/ch4_audio_test.tscn`. Đây là fixture riêng, không diễn kịch bản hoặc ghi save. Xem tên âm ở Output:

- Mũi tên trái/phải: chọn và nghe lần lượt 29 âm + 7 giọng; Space phát lại. 0 dừng/reset.
- 1: chuông 6 giây + beep hết pin ở 4 m. 2: tăng fraction cửa 0,2 mỗi lần, đến vỡ.
- 3: thư viện/còi 8:30; 4: StairCrowd; 5: im ở 407; 6: neck_hand có khoảng lặng.
- 7: fade 12 giây; 8: hospital/bíp đều; 9: bỏ một bíp; E: nhạc kết; Esc thoát.

Nhờ nghe tiếng rè và độ xa chuông, cửa vỡ có quá lớn không, tiếng thở sau khoảng lặng, giọng PA đọc tên Trần Trung, hai giọng y tá có đủ khác và rõ, còi/bệnh viện/nhạc kết có đủ nhỏ. Test headless kiểm tra asset/bus/gain/lifecycle, không thay thế duyệt tai hoặc chơi trọn chương.
