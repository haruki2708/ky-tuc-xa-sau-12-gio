extends Node3D
## Stills of the whole map as main has it (owner's request, 24/11/2026): every area once, in the real chapter scenes,
## director held, HUD and player hidden, lights as the chapter opens. The owner compares them with generated pictures.
## Copy with capture_atlas.tscn into game/_probe_tmp/ and run one chapter per Godot (Lượt Godot):
##   godot --path game res://_probe_tmp/capture_atlas.tscn -- --chapter=1|3|4 [--only=<area or id>,...]
## Writes build/graphics/anh_hien_trang/<area>/ch<N>_<id>[_den_pin|_den_tuyp].jpg at 1920 x 1080.
## The views are the ones the ten waves, T-255 and T-256 were reviewed with, plus room 407's own.
const OUTPUT := "res://../build/graphics/anh_hien_trang/"
## T-273: with `--look=1` (rendering/map_look.gd) send the stills to `--out=<folder under build/graphics>`.
const RESOLUTION := Vector2i(1920, 1080)
const WARD_Y := 300.0

## Per view: "a" area folder, "id", "eye", "target", "fov"; "torch" (the phone torch); "lights": room 407's states,
## one still each ("tube", "torch"); "open": floor-4 room doors; "bath"/"balcony": that room's inner doors;
## "bath407": room 407's bathroom door; "fire": the fire door; "bopen": doors under Campus/BuildingB;
## "lib": the library's back door.
const CH1 := [
	{"a": "01_phong_407", "id": "01_tu_cua_vao", "eye": Vector3(32.0, 1.6, -0.35), "target": Vector3(34.3, 0.85, -4.6), "fov": 80.0, "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "02_giuong_phia_tay", "eye": Vector3(33.2, 1.65, -0.9), "target": Vector3(31.0, 0.75, -3.0), "fov": 78.0, "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "03_giuong_phia_dong", "eye": Vector3(34.9, 1.65, -0.9), "target": Vector3(37.0, 0.75, -2.8), "fov": 78.0, "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "04_tu_do", "eye": Vector3(32.6, 1.5, -2.6), "target": Vector3(30.4, 1.1, -1.0), "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "05_tu_cuoi_phong_nhin_ra_cua", "eye": Vector3(34.5, 1.6, -6.3), "target": Vector3(32.0, 1.0, -0.5), "fov": 80.0, "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "06_nhin_ra_ban_cong", "eye": Vector3(33.6, 1.6, -1.2), "target": Vector3(33.0, 1.1, -7.8), "fov": 80.0, "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "07_tran_va_quat", "eye": Vector3(33.0, 1.5, -1.0), "target": Vector3(34.5, 2.9, -3.5), "fov": 80.0, "lights": ["tube"]},
	{"a": "01_phong_407", "id": "08_san_nha", "eye": Vector3(34.2, 2.75, -0.45), "target": Vector3(32.4, 0.0, -2.7), "fov": 80.0, "lights": ["tube"]},
	{"a": "01_phong_407", "id": "09_goc_tay_cuoi_phong", "eye": Vector3(34.6, 1.6, -3.0), "target": Vector3(30.6, 0.9, -6.4), "fov": 80.0, "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "10_cua_nha_tam", "eye": Vector3(34.6, 1.6, -2.6), "target": Vector3(36.4, 1.0, -5.5), "bath407": true, "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "11_trong_nha_tam", "eye": Vector3(36.0, 1.6, -4.45), "target": Vector3(37.2, 0.9, -6.7), "fov": 85.0, "bath407": true, "lights": ["torch"]},
	{"a": "01_phong_407", "id": "12_nha_tam_nhin_nguoc", "eye": Vector3(37.3, 1.6, -6.4), "target": Vector3(35.9, 1.1, -4.3), "fov": 85.0, "bath407": true, "lights": ["torch"]},
	{"a": "01_phong_407", "id": "13_ban_cong", "eye": Vector3(34.9, 1.6, -7.7), "target": Vector3(30.5, 1.1, -8.1), "fov": 80.0, "lights": ["tube", "torch"]},
	{"a": "01_phong_407", "id": "14_ban_cong_nhin_ra_ngoai", "eye": Vector3(32.5, 1.6, -7.4), "target": Vector3(30.0, -2.0, -40.0), "lights": ["tube"]},
	{"a": "01_phong_407", "id": "15_mat_sau_nha_B_tu_ban_cong", "eye": Vector3(30.8, 1.6, -8.25), "target": Vector3(18.0, 0.8, -7.8)},
	{"a": "01_phong_407", "id": "16_cua_407_tu_hanh_lang", "eye": Vector3(31.0, 1.6, 2.6), "target": Vector3(32.0, 1.05, 0.0), "torch": true},

	{"a": "02_tang_4_hanh_lang", "id": "01_hanh_lang_nhin_ve_tay", "eye": Vector3(36, 1.65, 2.3), "target": Vector3(6, 1.0, 1.6)},
	{"a": "02_tang_4_hanh_lang", "id": "02_hanh_lang_nhin_ve_dong", "eye": Vector3(4, 1.65, 2.0), "target": Vector3(34, 1.0, 1.8)},
	{"a": "02_tang_4_hanh_lang", "id": "03_day_cua_phong", "eye": Vector3(13, 1.6, 2.6), "target": Vector3(17, 0.4, 0.3), "torch": true},
	{"a": "02_tang_4_hanh_lang", "id": "04_do_phoi", "eye": Vector3(24, 1.65, 2.8), "target": Vector3(25.5, 1.7, 3.87), "torch": true},
	{"a": "02_tang_4_hanh_lang", "id": "05_do_hanh_lang", "eye": Vector3(18, 1.65, 1.8), "target": Vector3(19, 0.3, 0.35), "torch": true},
	{"a": "02_tang_4_hanh_lang", "id": "06_ban_truc", "eye": Vector3(37.3, 1.65, 3.1), "target": Vector3(40, 1.25, 0.4)},
	{"a": "02_tang_4_hanh_lang", "id": "07_ban_truc_den_pin", "eye": Vector3(37.3, 1.65, 3.1), "target": Vector3(40, 1.25, 0.4), "torch": true},
	{"a": "02_tang_4_hanh_lang", "id": "08_mat_ban_truc", "eye": Vector3(40.25, 1.5, 1.35), "target": Vector3(40.0, 0.8, 0.4), "fov": 65.0, "torch": true},
	{"a": "02_tang_4_hanh_lang", "id": "09_tuong_ban_truc", "eye": Vector3(40.9, 1.6, 2.6), "target": Vector3(39.0, 2.0, 0.1), "torch": true},
	{"a": "02_tang_4_hanh_lang", "id": "10_cua_thoat_hiem", "eye": Vector3(39.5, 1.65, 1.6), "target": Vector3(44, 1.3, 2.4), "torch": true},
	{"a": "02_tang_4_hanh_lang", "id": "11_bien_thoat_hiem", "eye": Vector3(40.5, 1.6, 1.8), "target": Vector3(44, 2.5, 2.5), "torch": true},
	{"a": "02_tang_4_hanh_lang", "id": "12_nhin_ra_vuon_va_nha_A", "eye": Vector3(37, 1.62, 3.3), "target": Vector3(22, -1.0, 54)},
	{"a": "02_tang_4_hanh_lang", "id": "13_nhin_ra_ngoai_rong", "eye": Vector3(20, 1.62, 3.3), "target": Vector3(22, -3.0, 40)},

	{"a": "03_tang_4_nha_ve_sinh", "id": "01_cua_vao_toi", "eye": Vector3(3, 1.65, 0.8), "target": Vector3(2.5, 1.1, -3.5)},
	{"a": "03_tang_4_nha_ve_sinh", "id": "02_cua_vao", "eye": Vector3(3, 1.65, 0.8), "target": Vector3(2.5, 1.1, -3.5), "torch": true},
	{"a": "03_tang_4_nha_ve_sinh", "id": "03_mang_rua", "eye": Vector3(2.4, 1.65, -1), "target": Vector3(0.2, 1.3, -2.3), "torch": true},
	{"a": "03_tang_4_nha_ve_sinh", "id": "04_buong", "eye": Vector3(3.6, 1.6, -1.6), "target": Vector3(2.6, 0.7, -4.4), "torch": true},
	{"a": "03_tang_4_nha_ve_sinh", "id": "05_guong", "eye": Vector3(1.55, 1.62, -1.35), "target": Vector3(0.14, 1.55, -2.2), "torch": true},
	{"a": "03_tang_4_nha_ve_sinh", "id": "06_mang_rua_gan", "eye": Vector3(1.3, 1.45, -0.45), "target": Vector3(0.3, 0.85, -2.6), "torch": true},
	{"a": "03_tang_4_nha_ve_sinh", "id": "07_tu_cuoi_nhin_ra", "eye": Vector3(0.9, 1.7, -3.0), "target": Vector3(5.6, 1.2, -0.8), "torch": true},

	{"a": "04_tang_4_cac_phong_khac", "id": "01_cua_401_tu_hanh_lang", "eye": Vector3(9.4, 1.65, 2.9), "target": Vector3(8.0, 1.2, -2.5), "open": ["401"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "02_phong_401", "eye": Vector3(8.0, 1.6, -0.4), "target": Vector3(8.0, 1.0, -6.5), "open": ["401"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "03_phong_401_nhin_nguoc", "eye": Vector3(7.5, 1.6, -6.3), "target": Vector3(8.6, 1.1, -0.5), "open": ["401"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "04_nha_tam_401", "eye": Vector3(8.7, 1.65, -3.3), "target": Vector3(9.4, 0.9, -6.6), "open": ["401"], "bath": ["401"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "05_ban_cong_401", "eye": Vector3(7.35, 1.6, -7.5), "target": Vector3(9.6, 1.0, -8.3), "open": ["401"], "balcony": ["401"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "06_phong_402", "eye": Vector3(12.0, 1.6, -0.4), "target": Vector3(12.0, 1.0, -6.5), "open": ["402"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "07_phong_402_nhin_nguoc", "eye": Vector3(13.4, 1.6, -6.3), "target": Vector3(11.4, 1.1, -0.5), "open": ["402"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "08_phong_403", "eye": Vector3(16.0, 1.6, -0.4), "target": Vector3(16.0, 1.0, -6.5), "open": ["403"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "09_phong_404", "eye": Vector3(20.0, 1.6, -0.4), "target": Vector3(20.0, 1.0, -6.5), "open": ["404"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "10_phong_404_nhin_nguoc", "eye": Vector3(21.0, 1.6, -6.3), "target": Vector3(19.4, 1.1, -0.5), "open": ["404"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "11_phong_405", "eye": Vector3(24.0, 1.6, -0.4), "target": Vector3(24.0, 1.0, -6.5), "open": ["405"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "12_phong_406", "eye": Vector3(28.0, 1.6, -0.4), "target": Vector3(28.0, 1.0, -6.5), "open": ["406"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "13_phong_408", "eye": Vector3(42.0, 1.6, -0.4), "target": Vector3(40.4, 1.0, -6.5), "open": ["408"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "14_phong_408_nhin_nguoc", "eye": Vector3(41.5, 1.6, -6.4), "target": Vector3(40.0, 1.1, -0.8), "open": ["408"], "torch": true},
	{"a": "04_tang_4_cac_phong_khac", "id": "15_nha_tam_408", "eye": Vector3(40.0, 1.65, -3.3), "target": Vector3(38.6, 0.9, -6.6), "open": ["408"], "bath": ["408"], "torch": true},
]

const CH3 := [
	{"a": "05_cau_thang_chinh", "id": "01_tu_tang_4", "eye": Vector3(-1, 1.65, 2.5), "target": Vector3(-3.8, -0.7, -1.4), "torch": true},
	{"a": "05_cau_thang_chinh", "id": "02_giua_nhip", "eye": Vector3(-3.8, 0.85, -2.0), "target": Vector3(-3.4, -1.2, -5.6), "torch": true},
	{"a": "05_cau_thang_chinh", "id": "03_chieu_nghi", "eye": Vector3(-3.6, -0.05, -5.4), "target": Vector3(-1.2, -2.0, -1.5), "torch": true},
	{"a": "05_cau_thang_chinh", "id": "04_chieu_toi_tang_3", "eye": Vector3(0.6, -1.65, 2.2), "target": Vector3(-3.5, -2.6, 0.0)},
	{"a": "05_cau_thang_chinh", "id": "05_tang_2", "eye": Vector3(-1.2, -4.95, 2.8), "target": Vector3(-3.6, -6.6, -2.0), "torch": true},
	{"a": "05_cau_thang_chinh", "id": "06_tang_1_nhin_len", "eye": Vector3(-3.8, -8.25, 1.2), "target": Vector3(-3.0, -6.0, -4.0), "torch": true},
	{"a": "05_cau_thang_chinh", "id": "07_chan_cau_thang", "eye": Vector3(-1, -8.25, 2.6), "target": Vector3(-3.7, -7.7, -1.5), "torch": true},
	{"a": "05_cau_thang_chinh", "id": "08_loi_len_bi_chan", "eye": Vector3(-2.5, 1.65, 2.6), "target": Vector3(-2.0, 3.6, -1.0), "torch": true},

	{"a": "06_cau_thang_thoat_hiem", "id": "01_cua_dong", "eye": Vector3(41.5, 1.65, 2.4), "target": Vector3(44, 1.1, 2), "torch": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "02_o_khoa", "eye": Vector3(43.1, 1.5, 2.3), "target": Vector3(44, 1.05, 1.95), "fov": 60.0, "torch": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "03_cua_mo", "eye": Vector3(40.4, 1.65, 2.9), "target": Vector3(45.0, 1.0, 1.6), "fov": 70.0, "torch": true, "fire": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "04_chieu_nghi_tang_4", "eye": Vector3(46.5, 1.65, 2.5), "target": Vector3(45.2, -0.7, -1.4), "torch": true, "fire": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "05_giua_nhip", "eye": Vector3(45.2, 0.85, -2.0), "target": Vector3(45.6, -1.2, -5.6), "torch": true, "fire": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "06_cho_re", "eye": Vector3(45.4, -0.05, -5.4), "target": Vector3(47.8, -2.0, -1.5), "torch": true, "fire": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "07_tang_3", "eye": Vector3(47.8, -1.65, 1.5), "target": Vector3(45.2, -3.3, -2.5), "torch": true, "fire": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "08_cho_sap", "eye": Vector3(47.5, -4.95, 1.8), "target": Vector3(46, -7.2, -1.5), "torch": true, "fire": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "09_vet_nut", "eye": Vector3(47.3, -2.4, -1.4), "target": Vector3(48.9, -2.0, -3.0), "fov": 65.0, "torch": true, "fire": true},
	{"a": "06_cau_thang_thoat_hiem", "id": "10_binh_chua_chay_tang_2", "eye": Vector3(45, -4.95, 2.7), "target": Vector3(48.83, -5.5, 2.4), "torch": true},

	{"a": "07_tang_3", "id": "01_hanh_lang_tu_tay", "eye": Vector3(1, -1.65, 2.5), "target": Vector3(30, -2, 1)},
	{"a": "07_tang_3", "id": "02_hanh_lang_tu_dong", "eye": Vector3(43, -1.65, 2.6), "target": Vector3(15, -2, 1)},
	{"a": "07_tang_3", "id": "03_cua_phong", "eye": Vector3(21.6, -1.6, 2.7), "target": Vector3(24.75, -2.0, 0), "torch": true},
	{"a": "07_tang_3", "id": "04_den_hanh_lang", "eye": Vector3(9.5, -1.7, 3.2), "target": Vector3(13.5, -0.35, 2.0), "fov": 65.0},
	{"a": "07_tang_3", "id": "05_lan_can", "eye": Vector3(24, -1.65, 1.6), "target": Vector3(27.5, -2.7, 4.1), "torch": true},
	{"a": "07_tang_3", "id": "06_phong_mo_cua", "eye": Vector3(18.6, -1.65, 2.6), "target": Vector3(19.4, -2.5, -3.5), "torch": true, "bopen": ["Floor3/Door3"]},
	{"a": "07_tang_3", "id": "07_chan_tuong", "eye": Vector3(31.5, -2.0, 2.4), "target": Vector3(33.5, -3.0, 0.0), "torch": true, "fov": 65.0},

	{"a": "08_tang_2", "id": "01_hanh_lang_tu_tay", "eye": Vector3(1, -4.95, 2.5), "target": Vector3(30, -5.3, 1)},
	{"a": "08_tang_2", "id": "02_hanh_lang_tu_dong", "eye": Vector3(43, -4.95, 2.6), "target": Vector3(15, -5.3, 1)},
	{"a": "08_tang_2", "id": "03_cua_203", "eye": Vector3(15, -4.95, 2.8), "target": Vector3(13.75, -5.5, -0.5), "torch": true},
	{"a": "08_tang_2", "id": "04_phong_203", "eye": Vector3(13.8, -4.95, -0.8), "target": Vector3(14.2, -5.3, -4), "torch": true},
	{"a": "08_tang_2", "id": "05_phong_203_nhin_nguoc", "eye": Vector3(14.5, -4.95, -5), "target": Vector3(13.75, -5.4, 0), "torch": true},
	{"a": "08_tang_2", "id": "06_giuong_203", "eye": Vector3(14.6, -5.1, -2.2), "target": Vector3(12.0, -5.7, -4.8), "torch": true},
	{"a": "08_tang_2", "id": "07_phong_207", "eye": Vector3(33.6, -4.95, 2.6), "target": Vector3(35.9, -5.7, -3.2), "torch": true, "bopen": ["Floor2/Door6"]},

	{"a": "09_tang_1_sanh", "id": "01_sanh_nhin_ve_tay", "eye": Vector3(19, -8.25, 2.5), "target": Vector3(2.7, -8.7, 0.2), "torch": true},
	{"a": "09_tang_1_sanh", "id": "02_sanh_nhin_ve_dong", "eye": Vector3(15.5, -8.25, 1.6), "target": Vector3(40, -8.7, 2.2)},
	{"a": "09_tang_1_sanh", "id": "03_tu_cau_thang_chinh", "eye": Vector3(-0.6, -8.25, 2.6), "target": Vector3(30, -8.6, 1.6)},
	{"a": "09_tang_1_sanh", "id": "04_hop_bao_chay", "eye": Vector3(-0.5, -8.25, 2.4), "target": Vector3(0.2, -8.5, 0.7), "torch": true},
	{"a": "09_tang_1_sanh", "id": "05_cua_chinh", "eye": Vector3(18.0, -8.25, 0.9), "target": Vector3(19.25, -8.8, 4.1), "torch": true},
	{"a": "09_tang_1_sanh", "id": "06_xich_cua_chinh", "eye": Vector3(18.7, -8.55, 3.3), "target": Vector3(19.25, -8.85, 4.2), "torch": true, "fov": 60.0},
	{"a": "09_tang_1_sanh", "id": "07_cua_phong_quan_ly", "eye": Vector3(2.75, -8.25, 2.6), "target": Vector3(2.9, -8.8, -3.5)},
	{"a": "09_tang_1_sanh", "id": "08_phong_quan_ly", "eye": Vector3(2.7, -8.25, -0.8), "target": Vector3(2, -8.7, -4), "torch": true},
	{"a": "09_tang_1_sanh", "id": "09_ban_va_dao", "eye": Vector3(2.7, -8.35, -2.1), "target": Vector3(1.4, -9.1, -3.2), "torch": true, "fov": 65.0},
	{"a": "09_tang_1_sanh", "id": "10_cua_so_phong_quan_ly", "eye": Vector3(3.8, -8.25, -5.3), "target": Vector3(4, -8.7, -7.6), "torch": true},
	{"a": "09_tang_1_sanh", "id": "11_cua_so_tu_ngoai", "eye": Vector3(4.6, -8.3, -11.6), "target": Vector3(4, -8.6, -7.6), "torch": true},
	{"a": "09_tang_1_sanh", "id": "12_hoc_tuong", "eye": Vector3(8.0, -8.25, 2.8), "target": Vector3(8.25, -8.9, -3.0), "torch": true},
	{"a": "09_tang_1_sanh", "id": "13_trong_hoc_tuong", "eye": Vector3(8.25, -8.3, 0.4), "target": Vector3(6.4, -9.2, -1.6), "torch": true},

	{"a": "10_vuon_hoa", "id": "01_loi_vao", "eye": Vector3(15.5, -8.3, 15.5), "target": Vector3(22.5, -8.0, 27.5)},
	{"a": "10_vuon_hoa", "id": "02_ghe_da", "eye": Vector3(30.5, -8.3, 27.2), "target": Vector3(22, -8.4, 27.4)},
	{"a": "10_vuon_hoa", "id": "03_ghe_da_den_pin", "eye": Vector3(24.6, -8.3, 25.4), "target": Vector3(21.8, -9.1, 28.4), "torch": true},
	{"a": "10_vuon_hoa", "id": "04_giuong_do", "eye": Vector3(24.8, -8.3, 17.4), "target": Vector3(22.0, -8.5, 22.0), "torch": true},
	{"a": "10_vuon_hoa", "id": "05_cot_den", "eye": Vector3(4.6, -8.3, 27.6), "target": Vector3(1.0, -7.7, 24.0)},
	{"a": "10_vuon_hoa", "id": "06_tu_tang_4_nhin_xuong", "eye": Vector3(22, 1.6, 3.3), "target": Vector3(22, -9.9, 25)},
	{"a": "10_vuon_hoa", "id": "07_vuon_nhin_sang_nha_A", "eye": Vector3(22, -8.2, 30), "target": Vector3(22, -2.5, 54)},
	{"a": "10_vuon_hoa", "id": "08_vuon_nhin_ve_dong", "eye": Vector3(22, -8.2, 26), "target": Vector3(60, -6.0, 62)},

	{"a": "11_nha_B_mat_ngoai", "id": "01_mat_truoc", "eye": Vector3(22, -8.2, 27), "target": Vector3(22, 4.6, 4)},
	{"a": "11_nha_B_mat_ngoai", "id": "02_mat_truoc_gan", "eye": Vector3(10, -8.2, 12), "target": Vector3(18, 5.0, 3)},
	{"a": "11_nha_B_mat_ngoai", "id": "03_mat_sau", "eye": Vector3(19, -8.3, -16.5), "target": Vector3(23, -5.5, -7.7)},
	{"a": "11_nha_B_mat_ngoai", "id": "04_mat_sau_rong", "eye": Vector3(30, -8.0, -30), "target": Vector3(20, 0.0, -7.7)},
	{"a": "11_nha_B_mat_ngoai", "id": "05_mat_sau_tu_xa", "eye": Vector3(24.0, -6.5, -24.0), "target": Vector3(24.0, 1.2, -7.5), "fov": 60.0},

	{"a": "12_nha_A_giang_duong_nha_the_chat", "id": "01_chan_nha_A", "eye": Vector3(18.0, -8.3, 49.0), "target": Vector3(21.5, -6.6, 54)},
	{"a": "12_nha_A_giang_duong_nha_the_chat", "id": "02_cua_so_nha_A", "eye": Vector3(15.5, -8.2, 46.0), "target": Vector3(18.0, -1.6, 54)},
	{"a": "12_nha_A_giang_duong_nha_the_chat", "id": "03_goc_nha_A", "eye": Vector3(52, -8.2, 44), "target": Vector3(30, -4.0, 56)},
	{"a": "12_nha_A_giang_duong_nha_the_chat", "id": "04_giang_duong", "eye": Vector3(-10, -8.2, 158), "target": Vector3(-10, -3.0, 180)},
	{"a": "12_nha_A_giang_duong_nha_the_chat", "id": "05_goc_giang_duong", "eye": Vector3(42, -8.2, 170), "target": Vector3(10, -3.0, 182)},
	{"a": "12_nha_A_giang_duong_nha_the_chat", "id": "06_goc_nha_the_chat", "eye": Vector3(12, -8.2, 76), "target": Vector3(-14, -5.0, 92)},
	{"a": "12_nha_A_giang_duong_nha_the_chat", "id": "07_cua_nha_the_chat", "eye": Vector3(-27.5, -8.3, 82.5), "target": Vector3(-30, -7.2, 90)},

	{"a": "13_duong_cay_hang_rao", "id": "01_dai_lo", "eye": Vector3(125, -8.3, -16.2), "target": Vector3(160, -8.4, -12.5)},
	{"a": "13_duong_cay_hang_rao", "id": "02_do_ben_duong", "eye": Vector3(152, -8.2, -13.5), "target": Vector3(140, -9.0, -21.5), "torch": true},
	{"a": "13_duong_cay_hang_rao", "id": "03_duong_phia_tay", "eye": Vector3(45, -8.2, -15.5), "target": Vector3(85, -8.6, -22)},
	{"a": "13_duong_cay_hang_rao", "id": "04_cay_sau_nha_B", "eye": Vector3(-2, -8.2, -24), "target": Vector3(-14, -4.0, -10)},
	{"a": "13_duong_cay_hang_rao", "id": "05_mai_che", "eye": Vector3(32, -8.2, -18.5), "target": Vector3(30, -8.4, -27), "torch": true},
	{"a": "13_duong_cay_hang_rao", "id": "06_ki_ot", "eye": Vector3(213, -8.2, 9.5), "target": Vector3(219, -8.5, 17), "torch": true},
	{"a": "13_duong_cay_hang_rao", "id": "07_nhanh_dong", "eye": Vector3(310, -8.2, 40), "target": Vector3(310, -8.5, 120)},
	{"a": "13_duong_cay_hang_rao", "id": "08_vong_bac", "eye": Vector3(140, -8.2, 250), "target": Vector3(220, -8.5, 246)},
	{"a": "13_duong_cay_hang_rao", "id": "09_rao_tay", "eye": Vector3(-74.5, -8.3, 99), "target": Vector3(-80, -8.0, 115), "torch": true},
	{"a": "13_duong_cay_hang_rao", "id": "10_rao_bac", "eye": Vector3(100, -8.2, 283), "target": Vector3(125, -8.2, 290), "torch": true},

	{"a": "14_san_van_dong", "id": "01_cong_tay", "eye": Vector3(100.5, -8.3, 167.5), "target": Vector3(150, -8.6, 166)},
	{"a": "14_san_van_dong", "id": "02_vao_san", "eye": Vector3(115, -8.3, 166), "target": Vector3(165, -9.0, 190)},
	{"a": "14_san_van_dong", "id": "03_duong_chay", "eye": Vector3(117.5, -8.3, 194), "target": Vector3(150, -9.7, 206), "torch": true},
	{"a": "14_san_van_dong", "id": "04_khung_thanh", "eye": Vector3(163, -8.3, 157), "target": Vector3(149, -8.9, 166.5), "torch": true},
	{"a": "14_san_van_dong", "id": "05_khan_dai", "eye": Vector3(165, -8.3, 195), "target": Vector3(178, -5.2, 221)},
	{"a": "14_san_van_dong", "id": "06_tu_dinh_khan_dai", "eye": Vector3(196.5, -1.55, 226.6), "target": Vector3(196, -9.6, 172)},
	{"a": "14_san_van_dong", "id": "07_gam_khan_dai", "eye": Vector3(167.5, -8.3, 231.2), "target": Vector3(162.5, -9.4, 223.5), "torch": true},
	{"a": "14_san_van_dong", "id": "08_dau_khan_dai", "eye": Vector3(146, -8.3, 232), "target": Vector3(160, -6.2, 219), "torch": true},
	{"a": "14_san_van_dong", "id": "09_cong_tay_bac", "eye": Vector3(147, -8.3, 203), "target": Vector3(149, -8.0, 222)},
	{"a": "14_san_van_dong", "id": "10_cot_den_pha", "eye": Vector3(124, -8.3, 197), "target": Vector3(112, 1.5, 210)},
	{"a": "14_san_van_dong", "id": "11_toan_san_tu_khan_dai", "eye": Vector3(200, -4.0, 222), "target": Vector3(200, -7.5, 160)},

	{"a": "15_cong_truong", "id": "01_tu_xa", "eye": Vector3(220, -8.3, -25), "target": Vector3(220, -7.4, -57)},
	{"a": "15_cong_truong", "id": "02_di_toi", "eye": Vector3(205, -8.3, -16), "target": Vector3(229, -8.2, -55)},
	{"a": "15_cong_truong", "id": "03_tru_tay", "eye": Vector3(203.5, -8.3, -49.5), "target": Vector3(209.5, -6.2, -58.6), "torch": true},
	{"a": "15_cong_truong", "id": "04_bien_truong", "eye": Vector3(219, -8.3, -46), "target": Vector3(217.5, -5.4, -59), "torch": true},
	{"a": "15_cong_truong", "id": "05_rao_chan", "eye": Vector3(209.5, -8.3, -43.5), "target": Vector3(214, -9.3, -49.5), "torch": true},
	{"a": "15_cong_truong", "id": "06_chot_bao_ve", "eye": Vector3(233.5, -8.3, -45), "target": Vector3(240, -8.2, -53.8), "torch": true},
	{"a": "15_cong_truong", "id": "07_cua_so_chot", "eye": Vector3(240.4, -8.15, -50.5), "target": Vector3(240.1, -9.0, -53.3), "torch": true},
	{"a": "15_cong_truong", "id": "08_tuong_rao_dong", "eye": Vector3(252, -8.3, -51.5), "target": Vector3(238, -8.4, -59.8), "torch": true},
	{"a": "15_cong_truong", "id": "09_tuong_rao_tay", "eye": Vector3(191, -8.3, -51), "target": Vector3(206, -8.3, -59.8), "torch": true},
	{"a": "15_cong_truong", "id": "10_san_lat", "eye": Vector3(226, -8.4, -39), "target": Vector3(219, -9.9, -50), "torch": true},
	{"a": "15_cong_truong", "id": "11_nhin_ra_pho", "eye": Vector3(220.5, -8.3, -43), "target": Vector3(220, -8.3, -72)},

	{"a": "16_nha_an", "id": "01_mat_truoc", "eye": Vector3(190, -8.3, 8.0), "target": Vector3(190, -6.8, 20)},
	{"a": "16_nha_an", "id": "02_mat_truoc_cheo", "eye": Vector3(176.5, -8.3, 12.5), "target": Vector3(186, -7.0, 20), "torch": true},
	{"a": "16_nha_an", "id": "03_tu_cua_vao", "eye": Vector3(190, -8.3, 20.8), "target": Vector3(180, -8.6, 36)},
	{"a": "16_nha_an", "id": "04_ti_vi", "eye": Vector3(177.5, -8.3, 34.2), "target": Vector3(170.3, -7.6, 32), "torch": true},
	{"a": "16_nha_an", "id": "05_quay", "eye": Vector3(180.5, -8.3, 38.6), "target": Vector3(176.5, -8.7, 42.6), "torch": true},
	{"a": "16_nha_an", "id": "06_tu_quay_nhin_ra", "eye": Vector3(184, -8.3, 40.2), "target": Vector3(192, -8.4, 20)},
	{"a": "16_nha_an", "id": "07_ban_an", "eye": Vector3(172.6, -8.3, 29.8), "target": Vector3(184, -9.0, 26.5), "torch": true},
	{"a": "16_nha_an", "id": "08_dau_dong", "eye": Vector3(201.5, -8.3, 31.5), "target": Vector3(209.6, -8.4, 32.5), "torch": true},
	{"a": "16_nha_an", "id": "09_bep", "eye": Vector3(192, -8.3, 44.6), "target": Vector3(192, -7.7, 51.8), "torch": true},
	{"a": "16_nha_an", "id": "10_kho", "eye": Vector3(202, -8.3, 44.4), "target": Vector3(202.5, -8.6, 51.5), "torch": true},
	{"a": "16_nha_an", "id": "11_kho_goc_ben", "eye": Vector3(201.5, -8.3, 50.8), "target": Vector3(208.6, -8.7, 46.5), "torch": true},
	{"a": "16_nha_an", "id": "12_cua_sau", "eye": Vector3(202.5, -8.3, 59.0), "target": Vector3(201.5, -8.4, 52), "torch": true},
	{"a": "16_nha_an", "id": "13_dai_dat_dong", "eye": Vector3(216.5, -8.3, 14.0), "target": Vector3(211, -8.9, 40)},
	{"a": "16_nha_an", "id": "14_dai_dat_sau", "eye": Vector3(173.5, -8.3, 58.5), "target": Vector3(200, -8.7, 51)},
	{"a": "16_nha_an", "id": "15_dai_dat_tay", "eye": Vector3(167.2, -8.3, 14.5), "target": Vector3(169.5, -8.4, 36)},
]

const CH4 := [
	{"a": "17_thu_vien", "id": "01_mat_truoc", "eye": Vector3(59.0, -8.3, 180.5), "target": Vector3(66.0, -5.0, 195.0), "fov": 80.0},
	{"a": "17_thu_vien", "id": "02_mat_ben", "eye": Vector3(92.0, -8.3, 186.0), "target": Vector3(70.0, -4.8, 200.0)},
	{"a": "17_thu_vien", "id": "03_mat_dong", "eye": Vector3(98.0, -8.3, 203.0), "target": Vector3(85.0, -5.5, 213.0), "fov": 80.0},
	{"a": "17_thu_vien", "id": "04_cua_sau_tu_ngoai", "eye": Vector3(66.0, -8.3, 231.0), "target": Vector3(65.0, -8.5, 225.0), "torch": true},
	{"a": "17_thu_vien", "id": "05_tang_1_tu_cua_sau", "eye": Vector3(65.0, -8.3, 224.2), "target": Vector3(58.5, -9.0, 206.5), "torch": true, "lib": true},
	{"a": "17_thu_vien", "id": "06_tang_1_rong", "eye": Vector3(80.5, -8.25, 213.6), "target": Vector3(52.0, -8.9, 205.0), "torch": true, "fov": 80.0},
	{"a": "17_thu_vien", "id": "07_tang_1_phia_bac", "eye": Vector3(66.5, -8.3, 212.5), "target": Vector3(50.0, -8.9, 220.0), "torch": true, "fov": 80.0},
	{"a": "17_thu_vien", "id": "08_quay_thu_thu", "eye": Vector3(61.4, -8.35, 209.4), "target": Vector3(57.4, -9.1, 206.1), "torch": true},
	{"a": "17_thu_vien", "id": "09_ban_do", "eye": Vector3(47.25, -8.3, 211.0), "target": Vector3(45.2, -8.15, 211.0), "torch": true},
	{"a": "17_thu_vien", "id": "10_cua_truoc_tu_trong", "eye": Vector3(66.2, -8.3, 201.0), "target": Vector3(65.0, -8.9, 195.3), "torch": true},
	{"a": "17_thu_vien", "id": "11_cau_thang", "eye": Vector3(77.7, -8.3, 196.4), "target": Vector3(82.0, -6.9, 206.5), "torch": true},
	{"a": "17_thu_vien", "id": "12_dau_cau_thang_tang_2", "eye": Vector3(81.0, -5.0, 210.6), "target": Vector3(60.0, -5.6, 214.0), "torch": true, "fov": 80.0},
	{"a": "17_thu_vien", "id": "13_o_cau_thang_tang_2", "eye": Vector3(75.5, -5.0, 211.5), "target": Vector3(80.0, -6.0, 202.0), "torch": true},
	{"a": "17_thu_vien", "id": "14_ban_doc_tang_2", "eye": Vector3(61.2, -5.0, 213.0), "target": Vector3(57.8, -5.8, 216.2), "torch": true},
	{"a": "17_thu_vien", "id": "15_tang_2_rong", "eye": Vector3(66.0, -5.0, 210.0), "target": Vector3(50.0, -5.6, 200.0), "torch": true, "fov": 80.0},
	{"a": "17_thu_vien", "id": "16_tang_3_rong", "eye": Vector3(80.6, -1.7, 213.4), "target": Vector3(54.0, -2.6, 219.0), "torch": true, "fov": 80.0},
	{"a": "17_thu_vien", "id": "17_tang_3_phia_nam", "eye": Vector3(65.0, -1.7, 210.0), "target": Vector3(50.0, -2.4, 199.0), "torch": true, "fov": 80.0},
	{"a": "17_thu_vien", "id": "18_tang_3_ke_sach", "eye": Vector3(57.7, -1.7, 213.6), "target": Vector3(57.0, -2.3, 218.0), "torch": true},
	{"a": "17_thu_vien", "id": "19_dai_dat_tay", "eye": Vector3(40.5, -8.3, 230.0), "target": Vector3(44.0, -9.3, 205.0), "torch": true},
	{"a": "17_thu_vien", "id": "20_duong_toi_thu_vien", "eye": Vector3(15, -8.2, 168), "target": Vector3(55, -8.0, 196)},

	{"a": "18_phong_407_chuong_4", "id": "01_tu_cua_vao", "eye": Vector3(32.0, 1.6, -0.35), "target": Vector3(34.3, 0.85, -4.6), "fov": 80.0, "torch": true},
	{"a": "18_phong_407_chuong_4", "id": "02_giuong_phia_tay", "eye": Vector3(33.2, 1.65, -0.9), "target": Vector3(31.0, 0.75, -3.0), "fov": 78.0, "torch": true},
	{"a": "18_phong_407_chuong_4", "id": "03_giuong_phia_dong", "eye": Vector3(34.9, 1.65, -0.9), "target": Vector3(37.0, 0.75, -2.8), "fov": 78.0, "torch": true},
	{"a": "18_phong_407_chuong_4", "id": "04_san_nha", "eye": Vector3(34.2, 2.75, -0.45), "target": Vector3(32.4, 0.0, -2.7), "fov": 80.0, "torch": true},
	{"a": "18_phong_407_chuong_4", "id": "05_tran_va_o_thong_gio", "eye": Vector3(31.4, 1.6, -0.6), "target": Vector3(35.2, 2.55, -1.8), "fov": 80.0, "torch": true},
	{"a": "18_phong_407_chuong_4", "id": "06_cua_tu_trong", "eye": Vector3(33.3, 1.6, -2.9), "target": Vector3(32.0, 1.05, -0.05), "torch": true},
	{"a": "18_phong_407_chuong_4", "id": "07_cua_tu_hanh_lang", "eye": Vector3(31.0, 1.6, 2.6), "target": Vector3(32.0, 1.05, 0.0), "torch": true},
	{"a": "18_phong_407_chuong_4", "id": "08_loi_tay_nha_an", "eye": Vector3(166.2, -8.3, 40.5), "target": Vector3(172, -8.4, 40.5), "torch": true},
]

var camera: Camera3D
var torch: SpotLight3D
var eye_rig: Node3D
var count := 0
var missing: PackedStringArray = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	var from_env := OS.get_environment("ATLAS_" + name.to_upper())
	return from_env if not from_env.is_empty() else fallback


func _rig() -> void:
	# The washroom mirror and room 407's mirrors follow a rig with a "body" (washroom_real.gd); room 407 blends its
	# night toward any "Flashlight" under the current camera (room407.gd).
	eye_rig = Node3D.new()
	var rig_script := GDScript.new()
	rig_script.source_code = "extends Node3D\nvar body := true\n"
	rig_script.reload()
	eye_rig.set_script(rig_script)
	eye_rig.name = "CaptureEye"
	add_child(eye_rig)
	var head := Node3D.new()
	head.name = "Head"
	eye_rig.add_child(head)
	camera = Camera3D.new()
	head.add_child(camera)
	camera.near = 0.05
	camera.far = 4000.0
	camera.make_current()
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	torch.visible = false
	camera.add_child(torch)


func _snap(area: String, file: String) -> void:
	for frame in range(40):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var folder := OUTPUT.replace("anh_hien_trang", _arg("out", "anh_hien_trang")) + area + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var image: Image = get_viewport().get_texture().get_image()
	image.save_jpg(folder + file, 0.92)
	print("CAPTURE: %s/%s draws %d vram %d MB" % [area, file,
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
	count += 1


func _open(node: Node, opened: Array[Node], label: String) -> void:
	if node != null and node.has_method("set_open"):
		node.call("set_open", true)
		opened.append(node)
	else:
		missing.append(label)


func _shoot(scene: Node3D, chapter: int, view: Dictionary) -> void:
	var floor4 := scene.get_node_or_null("Floor4") as Node3D
	var campus := scene.get_node_or_null("Campus") as Node3D
	var room: Node = floor4.get_node_or_null("Room407") if floor4 != null else null
	var opened: Array[Node] = []
	if floor4 != null:
		for number: String in view.get("open", []):
			_open(floor4.get_node_or_null("Corridor/LockedDoor_" + number), opened, "door " + number)
		for key: String in ["bath", "balcony"]:
			for number: String in view.get(key, []):
				var part := "Interior/BathroomDoor" if key == "bath" else "Outdoor/BalconyDoor"
				_open(floor4.get_node_or_null("Rooms/Room%s/%s" % [number, part]), opened, "%s %s" % [key, number])
	if campus != null:
		if view.get("fire", false):
			_open(campus.get_node_or_null("BuildingB/FireDoor"), opened, "fire door")
		for path: String in view.get("bopen", []):
			_open(campus.get_node_or_null("BuildingB/" + path), opened, path)
		if view.get("lib", false):
			_open(campus.get_node_or_null("Library/BackDoor"), opened, "library back door")
	var bath407: bool = view.get("bath407", false)
	if bath407 and room != null:
		room.call("set_bathroom_door_open", true)
	eye_rig.global_position = view.eye
	camera.position = Vector3.ZERO
	camera.look_at(view.target)
	camera.fov = view.get("fov", 75.0)
	camera.make_current()
	var tube: Light3D = room.get_node_or_null("Room407MainLight") as Light3D if room != null else null
	var tube_was: Array = [tube.visible, tube.light_energy] if tube != null else []
	var states: Array = view.get("lights", ["torch" if view.get("torch", false) else "plain"])
	for state: String in states:
		torch.visible = state == "torch"
		if view.has("lights") and tube != null:
			tube.visible = state == "tube"
			tube.light_energy = float(tube.get("flicker_energy")) if state == "tube" else 0.0
		var suffix: String = {"torch": "_den_pin", "tube": "_den_tuyp", "plain": ""}[state]
		if not view.has("lights") and String(view.id).ends_with("den_pin"):
			suffix = ""
		await _snap(view.a, "ch%d_%s%s.jpg" % [chapter, view.id, suffix])
	torch.visible = false
	if tube != null:
		tube.visible = tube_was[0]
		tube.light_energy = tube_was[1]
	if bath407 and room != null:
		room.call("set_bathroom_door_open", false)
	for node in opened:
		node.call("set_open", false)
	if not opened.is_empty() or bath407:
		for frame in range(20):
			await get_tree().process_frame


func _cctv(scene: Node3D) -> void:
	var set_root := scene.get_node_or_null("Chapter1Director/CctvSet") as Node3D
	if set_root == null:
		missing.append("CctvSet")
		return
	for source: Camera3D in set_root.find_children("*", "Camera3D", true, false):
		var label := String(set_root.get_path_to(source)).replace("/", "_")
		eye_rig.global_position = source.global_position
		camera.position = Vector3.ZERO
		camera.global_basis = source.global_basis
		camera.fov = source.fov
		camera.make_current()
		await _snap("19_cctv", "ch1_%s.jpg" % label)


func _ward(scene: Node3D) -> void:
	var director := scene.get_node("Chapter4Director")
	for kind: StringName in [&"all", &"alone"]:
		var old := director.get("_hospital") as Node3D
		if old != null:
			old.queue_free()
			director.set("_hospital", null)
			await get_tree().process_frame
		GameState.set_flag(&"ch4_ending", String(kind))
		director.set("_ending_kind", kind)
		director.call("_show_hospital")
		EventBus.ch4_ending.emit(kind)
		for frame in range(3):
			await get_tree().process_frame
		var ward := director.get("_hospital") as Node3D
		var wake := ward.get_node("Camera_Wake") as Camera3D
		var ending := "ket_ca_ba" if kind == &"all" else "ket_mot_minh"
		wake.make_current()
		await get_tree().create_timer(0.4).timeout
		await _snap("20_benh_vien", "ch4_%s_01_khung_tinh_day.jpg" % ending)
		camera.environment = (ward.get_node("Environment") as WorldEnvironment).environment
		for extra: Array in [["02_goc_phong", Vector3(2.15, 2.35, 2.65), Vector3(-0.7, 0.55, -1.2), 75.0],
				["03_canh_giuong", Vector3(-0.82, 1.45, 1.0), Vector3(0.15, 0.68, -0.25), 70.0]]:
			eye_rig.global_position = extra[1] + Vector3(0, WARD_Y, 0)
			camera.position = Vector3.ZERO
			camera.look_at(extra[2] + Vector3(0, WARD_Y, 0))
			camera.fov = extra[3]
			camera.make_current()
			await _snap("20_benh_vien", "ch4_%s_%s.jpg" % [ending, extra[0]])
		camera.environment = null


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	AudioServer.set_bus_mute(0, true)
	var chapter := _arg("chapter", "1").to_int()
	var only := _arg("only", "").split(",", false)
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	_rig()
	# Let the chapter's own lights and streamed parts settle before the first still.
	await get_tree().create_timer(2.0).timeout
	var views: Array = {1: CH1, 3: CH3, 4: CH4}.get(chapter, [])
	for view: Dictionary in views:
		if not only.is_empty() and not (String(view.a) in only or String(view.id) in only):
			continue
		await _shoot(scene, chapter, view)
	if chapter == 1 and (only.is_empty() or "19_cctv" in only):
		await _cctv(scene)
	if chapter == 4 and (only.is_empty() or "20_benh_vien" in only):
		await _ward(scene)
	for label in missing:
		print("MISSING: %s" % label)
	print("RESULT: atlas chapter %d, %d images, %d missing" % [chapter, count, missing.size()])
	App.quit()
