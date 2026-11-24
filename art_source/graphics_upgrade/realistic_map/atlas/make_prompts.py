# -*- coding: utf-8 -*-
"""One GPT image prompt per still of build/graphics/anh_hien_trang/ (D-199), as a page the owner opens in a
browser: thumbnail, the prompt, a copy button, the name to save the result under.

    python -I art_source/graphics_upgrade/realistic_map/atlas/make_prompts.py

Writes build/graphics/anh_hien_trang/PROMPT_GPT.html (not committed). Each prompt = the shared rules (keep the camera
and the layout, the picture is a reference to rebuild the scene from) + the area + what is in that frame + its light.
"""
import glob
import html
import os
import re
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../../../build/graphics/anh_hien_trang"))

DORM_ROOM = ("cream-yellow limewashed walls with damp stains and peeling patches, beige ceramic floor tiles with dirty grout, "
             "green-painted steel bunk beds, white mosquito netting, grey steel lockers with dents and stickers, worn wooden desks")

# area folder -> (Vietnamese name, place, materials, wear, small details)
AREAS = {
    "01_phong_407": ("Phòng 407",
        "Room 407, a cramped four-bed student dorm room of about 8 x 7 m on the 4th floor, with a small tiled bathroom and a narrow balcony behind an aluminium-and-glass door.",
        DORM_ROOM + ", a reed mat, thin cotton blankets, plastic stools, an old ceiling fan",
        "a room four students have lived in for years: scuffed walls at bed height, tape marks, rust at the feet of the beds, water stains under the window, dust on the fan",
        "phone chargers and cables, instant-noodle cups, slippers, books, hangers, a calendar"),
    "02_tang_4_hanh_lang": ("Tầng 4: hành lang",
        "The open-air access corridor of the 4th floor of dorm block B: 44 m long, room doors on one side, a green steel railing open to the night on the other, a small duty desk and a fire-exit door at the east end.",
        "cream-yellow limewashed walls with rain streaks, old ceramic floor tiles, green-painted wooden doors with aluminium number plates, green steel railing, bare fluorescent batten lights on a stained concrete ceiling",
        "decades of use: dirt along the skirting, chipped door paint, rust on the railing, cobwebs near the lamps, patches where the limewash has flaked",
        "slippers and shoes outside doors, buckets, brooms, laundry, exposed electrical conduit"),
    "03_tang_4_nha_ve_sinh": ("Tầng 4: nhà vệ sinh chung",
        "The shared washroom of the 4th floor: a row of toilet stalls with half-closed green doors and a long tiled washing trough under a mirror.",
        "small mint-green wall tiles with dark grout, a tiled trough with old brass taps, a spotted mirror, a wet cement floor, green-painted stall doors",
        "damp everywhere: mould in the grout, rust streaks under taps and hinges, limescale, a stained ceiling",
        "soap bars, a plastic scoop, a rag, a floor drain, drips and puddles"),
    "04_tang_4_cac_phong_khac": ("Tầng 4: các phòng 401–406, 408",
        "The other four-bed dorm rooms of the 4th floor (401-406, 408). Same building as room 407, but each belongs to different students.",
        DORM_ROOM,
        "lived-in rooms: scuffed walls, tape marks, rust at the feet of the beds, dusty fans",
        "clothes on lines, backpacks, books, slippers, plastic basins, fans, rice cookers"),
    "05_cau_thang_chinh": ("Cầu thang chính nhà B",
        "The main staircase of dorm block B, an enclosed concrete stairwell running from the 4th floor to the ground floor.",
        "grey cement steps with worn anti-slip grooves, a dark green gloss-painted dado under cream limewash, green steel balusters with a dark wooden handrail, rough concrete soffits",
        "heavy foot traffic: polished step edges, hand grime on the handrail and the wall, chipped paint, dust in the corners",
        "cigarette ends, a dropped slipper, cobwebs, a conduit with a switch"),
    "06_cau_thang_thoat_hiem": ("Cầu thang thoát hiểm",
        "The fire staircase at the east end of dorm block B, behind a green steel fire door. An earthquake has cracked its walls and collapsed part of a lower flight.",
        "grey cement steps, a dark green gloss-painted dado under cream limewash, green steel railing, a green-painted steel fire door with a lever handle",
        "little used and dusty; fresh earthquake damage: cracked plaster, broken concrete with exposed rebar, dust and small rubble",
        "concrete crumbs, dust, a fire extinguisher sign, cobwebs"),
    "07_tang_3": ("Tầng 3",
        "The open-air access corridor of the 3rd floor of dorm block B: room doors on one side, a green steel railing open to the night on the other.",
        "cream limewash above a dark green gloss-painted dado, a grey cement floor, green-painted wooden doors with number plates, green steel railing, concrete beams with fluorescent battens",
        "dirt along the skirting, chipped paint, rust on the railing, flaking limewash",
        "slippers outside doors, buckets, brooms, exposed electrical conduit"),
    "08_tang_2": ("Tầng 2",
        "The open-air access corridor of the 2nd floor of dorm block B and two of its rooms (203 and 207).",
        "cream limewash above a dark green gloss-painted dado, a grey cement floor, green-painted wooden doors with number plates, green steel bunk beds inside the rooms",
        "dirt along the skirting, chipped paint, rust, flaking limewash",
        "slippers outside doors, buckets, exposed electrical conduit"),
    "09_tang_1_sanh": ("Tầng 1: sảnh và phòng quản lý",
        "The ground floor of dorm block B: the lobby corridor, the chained glass main doors, the dorm manager's small room and a fire-alarm box.",
        "cream limewash above a dark green gloss-painted dado, a grey terrazzo or cement floor, aluminium-framed glass doors, an old wooden desk, steel window bars",
        "a busy entrance: scuffed dado, worn floor by the doors, fingerprints on the glass, dusty window bars",
        "a noticeboard, a key cabinet, a thermos, newspapers, a wall clock"),
    "10_vuon_hoa": ("Vườn hoa trước nhà B",
        "The courtyard garden between dorm blocks A and B, at night.",
        "grey interlocking concrete pavers, raised planters with white-limewashed kerbs and clipped hedges, frangipani and crape-myrtle trees, polished-stone benches, globe-topped lamp posts, yellow dorm blocks behind",
        "moss between the pavers, cracked kerbs, fallen leaves and petals, stains under the benches",
        "fallen leaves, litter, a dropped bag or shoe"),
    "11_nha_B_mat_ngoai": ("Nhà B: mặt ngoài",
        "The outside of dorm block B, a long five-storey 1990s Vietnamese dormitory, at night.",
        "yellow limewashed render with grey rain streaks, open access corridors with green railings at the front, barred windows, air-conditioner units and small balconies at the back, concrete sunshades",
        "black mould under ledges, rust stains under window bars and air-conditioners, patched render",
        "laundry on balconies, drain pipes, cables, a few lit windows"),
    "12_nha_A_giang_duong_nha_the_chat": ("Nhà A, giảng đường, nhà thể chất",
        "Other campus buildings seen from outside at night: dorm block A, the flat-roofed lecture block and the gymnasium with a vaulted roof.",
        "yellow limewashed render with grey rain streaks, regular grids of steel-framed windows, concrete sunshades, a corrugated vaulted roof on the gymnasium",
        "black mould under ledges, rust stains under window bars, patched render, grass growing at the foot of the walls",
        "drain pipes, cables, air-conditioner units, a few curtains behind dark windows"),
    "13_duong_cay_hang_rao": ("Đường, cây, hàng rào",
        "The campus roads, trees and boundary fences at night.",
        "old cracked asphalt with faded white lines, concrete kerbs, tropical almond, flamboyant and African mahogany trees, steel street-lamp poles, B40 chain-link fencing on steel posts",
        "potholes and patches in the asphalt, weeds along the kerbs, leaf litter, rust on poles and fence",
        "fallen leaves and branches, litter, dropped belongings"),
    "14_san_van_dong": ("Sân vận động",
        "The campus stadium at night: a 400 m running track around a football pitch, with concrete stands under a tin roof.",
        "worn red rubber track with faded white lane lines, dry patchy grass, bare weathered concrete terraces, a corrugated tin roof on steel trusses with some sheets missing, steel floodlight masts, chain-link fence",
        "sun-bleached track, bald patches in the grass, stained concrete, rust on the steelwork",
        "dropped shoes and bottles, leaves, puddles"),
    "15_cong_truong": ("Cổng trường",
        "The main gate of the university, seen from inside the campus at night, damaged by an earthquake.",
        "grey interlocking pavers, limewashed masonry gate pillars (the west one leaning and cracked), a green iron two-leaf gate, a steel arch with a blue tin name sign hanging half-fallen, a yellow guard booth, a limewashed boundary wall with vertical iron bars",
        "cracked masonry, peeling limewash, rust on the ironwork, dirt at the foot of the wall",
        "traffic cones, dropped belongings, fallen leaves, bits of broken plaster"),
    "16_nha_an": ("Nhà ăn",
        "The student canteen: a large dining hall with a serving counter, a kitchen and a store room behind it, and its yellow facade.",
        "white floor tiles reflecting fluorescent tubes, cream walls, steel tables with attached round plastic stools, a stainless serving counter, black menu boards, stainless kitchen hood and gas stoves, steel shelving",
        "grease and soot in the kitchen, mop marks and scuffs on the tiles, stained ceiling panels, chipped table edges",
        "trays, bowls, chopstick holders, dropped food, napkins, crates"),
    "17_thu_vien": ("Thư viện",
        "The three-storey campus library at night, inside and out.",
        "yellow render outside with dark glass windows and curtains; inside: tiled floors, a stained grid ceiling, grey steel bookshelves full of worn books, wooden reading tables, a wooden librarian's counter with an old computer; on the 3rd floor old wooden shelves on a bare cement floor",
        "dusty shelves, yellowed book spines, water stains on the ceiling tiles, worn floor between the shelves",
        "loose papers, stacked books, a book trolley, index cards, a wall clock"),
    "18_phong_407_chuong_4": ("Phòng 407 ở chương 4",
        "Room 407 later the same night, after it has been ransacked: mattresses, blankets and pillows pulled onto the floor, bed slats exposed, the entrance door battered.",
        DORM_ROOM + ", torn mattresses, bare wooden bed slats",
        "a lived-in room turned upside down: scuffed walls, splintered wood around the door lock, dust shaken loose",
        "scattered clothes, books, cables, slippers"),
    "19_cctv": ("Trường quay CCTV",
        "Other dorm rooms and corridors of the same campus, seen from ceiling-corner security cameras.",
        "cream-yellow limewashed walls with damp stains, tile or cement floors, green steel bunk beds with mosquito nets, grey steel lockers, green-painted wooden doors with number plates",
        "scuffed walls, tape marks, rust, dust",
        "clothes, books, slippers, cables"),
    "20_benh_vien": ("Phòng bệnh (đoạn kết)",
        "A ward in an ordinary Vietnamese public hospital, in the morning.",
        "pale walls above a teal-green dado, small floor tiles, a grid ceiling, white steel hospital beds with white bedding, a teal privacy curtain on a ceiling track, bedside cabinets, an IV stand",
        "a clean but old ward: chipped bed paint, scuffed dado, slightly yellowed ceiling tiles",
        "a water bottle, a medical chart, slippers under a bed, a folded blanket"),
}

ROOM_GENERIC = "inside this room: green bunk beds with mosquito nets, steel lockers, desks, a ceiling fan, clothes on a line, the students' belongings"

# area -> id -> what is in the frame (a tuple overrides the area for that still)
FRAMES = {
    "01_phong_407": {
        "01_tu_cua_vao": "the whole room from just inside the entrance door: bunk beds with mosquito nets on both sides, desks, a low folding table with a meal on a reed mat in the middle, a standing fan, a rice cooker on a small cabinet, T-shirts on a clothes line, the white bathroom door and the dark balcony window at the back",
        "02_giuong_phia_tay": "the west side: grey steel lockers, a green bunk bed with a mosquito net, a wooden desk with a red plastic stool, T-shirts on hangers overhead",
        "03_giuong_phia_dong": "the east side: a bunk bed with a red blanket, two grey lockers with sticky notes, the white bathroom door with a vent grille, a rice cooker on a small white cabinet, a standing fan",
        "04_tu_do": "the green wooden entrance door from inside, a jacket on a wall hook, a row of grey-blue steel lockers with one door open, the corner of a bunk bed with its mosquito net",
        "05_tu_cuoi_phong_nhin_ra_cua": "from the back of the room toward the entrance door: desks with a lamp, a red stool, backpacks on the floor, a standing fan in the foreground, a clothes line",
        "06_nhin_ra_ban_cong": "from the middle of the room toward the back wall: bunk beds either side, a desk, a standing fan, a rice cooker, the dark blue night window and the door to the balcony",
        "07_tran_va_quat": "the ceiling: an old ceiling fan, a ceiling access panel, damp stains, the top of the clothes line and of a mosquito net",
        "08_san_nha": "a high view down onto the floor: beige ceramic tiles, a reed mat with a low meal table and bowls, lockers, small belongings scattered around",
        "09_goc_tay_cuoi_phong": "the back-west corner: a bunk bed, a desk with books and a red stool, a standing fan in the foreground, a wall shelf, the window to the balcony",
        "10_cua_nha_tam": "the open bathroom doorway seen from the room: white wooden frame, white tiles and a toilet inside, a rice cooker and a standing fan in the foreground",
        "11_trong_nha_tam": "inside the small bathroom: white wall tiles, a wall shower with exposed pipes, a toilet, a pink plastic basin and bottles on the dark floor, a towel on a hook",
        "12_nha_tam_nhin_nguoc": "inside the bathroom looking back at its open door: white tiles, a small wall sink under a mirror",
        "13_ban_cong": "the narrow balcony: rough yellow wall, the aluminium-and-glass door, laundry and a blue towel hanging, a low parapet wall",
        "14_ban_cong_nhin_ra_ngoai": "looking out over the balcony parapet: a blue towel hanging on the right, another dorm block with a few lit windows in the distance, the night sky",
        "15_mat_sau_nha_B_tu_ban_cong": "looking along the back of the dorm block from the balcony: rough rendered wall close on the left, balconies and a few lit windows receding into the dark",
        "16_cua_407_tu_hanh_lang": "room 407's green wooden door seen from the corridor, a printed sheet of rules taped to it, the aluminium number plate above it, a second door frame to the right, a doormat on the tiles",
    },
    "02_tang_4_hanh_lang": {
        "01_hanh_lang_nhin_ve_tay": "the whole corridor looking west: the green railing and the night on the left, room doors on the right, fluorescent battens on the ceiling",
        "02_hanh_lang_nhin_ve_dong": "the whole corridor looking east: room doors on the left, the green railing and the night on the right, fluorescent battens on the ceiling",
        "03_day_cua_phong": "a row of green room doors with slippers, a blue basin, a red bucket and a broom left outside them",
        "04_do_phoi": "laundry hung to dry on the railing side of the corridor",
        "05_do_hanh_lang": "things left along the wall: a red bucket, a dustpan and brush, cardboard boxes beside a door",
        "06_ban_truc": "the floor's duty desk at the east end: a small wooden desk with a desk lamp and a ledger, a cork noticeboard with papers, a wall loudspeaker",
        "07_ban_truc": "the floor's duty desk at the east end: a small wooden desk with a desk lamp and a ledger, a cork noticeboard with papers, a wall loudspeaker",
        "08_mat_ban_truc": "the top of the duty desk, close: desk lamp, ledger, an old telephone, the drawer",
        "09_tuong_ban_truc": "the wall above the duty desk: cork noticeboard, wall loudspeaker, the corridor receding behind",
        "10_cua_thoat_hiem": "the green steel fire-exit door at the east end of the corridor, with its lever handle",
        "11_bien_thoat_hiem": "the upper wall and ceiling beside the fire exit",
        "12_nhin_ra_vuon_va_nha_A": "looking out over the green railing from the 4th floor, down to the courtyard garden and across to the opposite dorm block, at night",
        "13_nhin_ra_ngoai_rong": "a wide view over the green railing from the 4th floor: the courtyard garden's planters and paths far below, the night beyond",
    },
    "03_tang_4_nha_ve_sinh": {
        "01_cua_vao_toi": "the washroom from its entrance: three green stall doors ahead, stained mint tiles, a fluorescent tube on the ceiling",
        "02_cua_vao": "the washroom from its entrance: three green stall doors ahead, stained mint tiles, a fluorescent tube on the ceiling",
        "03_mang_rua": "the long tiled washing trough with taps along the wall, the mirror above it, stall doors beyond",
        "04_buong": "the toilet stalls: half-open green doors, mint tiles with rust and mould streaks",
        "05_guong": "the wall mirror above the washing trough, close",
        "06_mang_rua_gan": "along the tiled washing trough, close: taps, a soap dish, a pink sponge, water stains",
        "07_tu_cuoi_nhin_ra": "from the back of the washroom looking out toward its entrance and the corridor",
    },
    "04_tang_4_cac_phong_khac": {
        "01_cua_401_tu_hanh_lang": "room 401's door standing open, seen from the corridor; slippers and a blue bucket outside",
        "02_phong_401": "room 401 from its door; " + ROOM_GENERIC,
        "03_phong_401_nhin_nguoc": "room 401 from the back toward its door: a wooden cabinet with a small appliance on top, a clothes line, a bunk bed, a desk with books and a red stool",
        "04_nha_tam_401": "room 401's small bathroom through its open door: white tiles, a toilet, shower pipes",
        "05_ban_cong_401": "room 401's balcony: a blue towel on a line, a red basin of laundry on the floor, the parapet, another block with lit windows beyond",
        "06_phong_402": "room 402 from its door; " + ROOM_GENERIC,
        "07_phong_402_nhin_nguoc": "room 402 from the back toward its door: clothes on hangers, a rice cooker in the foreground, a bunk bed",
        "08_phong_403": "room 403 from its door; " + ROOM_GENERIC,
        "09_phong_404": "room 404 from its door; " + ROOM_GENERIC,
        "10_phong_404_nhin_nguoc": "room 404 from the back toward its door; " + ROOM_GENERIC,
        "11_phong_405": "room 405 from its door; " + ROOM_GENERIC,
        "12_phong_406": "room 406 from its door; " + ROOM_GENERIC,
        "13_phong_408": "room 408 from its door: bunk beds on both sides, a clothes-drying rack, desks, a wastepaper bin, the bathroom door at the back",
        "14_phong_408_nhin_nguoc": "room 408 from the back toward its door; " + ROOM_GENERIC,
        "15_nha_tam_408": "room 408's small bathroom through its open door: white tiles, a toilet, shower pipes, a pink basin",
    },
    "05_cau_thang_chinh": {
        "01_tu_tang_4": "the top of the staircase on the 4th floor, looking down the first flight",
        "02_giua_nhip": "half-way down a flight: cement steps, green balusters with a wooden handrail, the green dado",
        "03_chieu_nghi": "the half-landing where the flight turns back",
        "04_chieu_toi_tang_3": "the 3rd-floor landing with the flight going up, unlit",
        "05_tang_2": "the 2nd-floor landing with the flight going down",
        "06_tang_1_nhin_len": "from the ground floor looking up the first flight",
        "07_chan_cau_thang": "the foot of the staircase on the ground floor",
        "08_loi_len_bi_chan": "looking up at the way to the roof, which is blocked: the underside of the flight above and a broken concrete edge",
    },
    "06_cau_thang_thoat_hiem": {
        "01_cua_dong": "the closed green steel fire door at the end of the 4th-floor corridor",
        "02_o_khoa": "the fire door's lock and lever handle, close, on scratched green-painted steel",
        "03_cua_mo": "the fire door standing open, the fire staircase beyond it",
        "04_chieu_nghi_tang_4": "the fire-stair landing on the 4th floor: steel railing, the flight going down, a red plastic stool and small things by the door",
        "05_giua_nhip": "half-way down a flight of the fire stairs",
        "06_cho_re": "where the fire stairs turn: railing, the next flight going down",
        "07_tang_3": "the 3rd-floor landing of the fire stairs",
        "08_cho_sap": "the collapsed part: a pile of broken concrete slabs and rubble blocking the flight down",
        "09_vet_nut": "a long earthquake crack in the stairwell wall",
        "10_binh_chua_chay_tang_2": "a red fire extinguisher on the wall of the 2nd-floor landing, with an instruction sign beside it",
    },
    "07_tang_3": {
        "01_hanh_lang_tu_tay": "the whole 3rd-floor corridor from its west end",
        "02_hanh_lang_tu_dong": "the whole 3rd-floor corridor from its east end: room doors on the right, the railing and the night on the left",
        "03_cua_phong": "a room door with its number plate",
        "04_den_hanh_lang": "a fluorescent batten under a concrete ceiling beam, the corridor below it",
        "05_lan_can": "the green steel railing and the campus at night beyond it",
        "06_phong_mo_cua": "a room door standing open, a glimpse of the dark room inside",
        "07_chan_tuong": "the foot of the wall: green dado, skirting, the dirty edge of the floor",
    },
    "08_tang_2": {
        "01_hanh_lang_tu_tay": "the whole 2nd-floor corridor from its west end: room doors on the left, the railing and the night on the right",
        "02_hanh_lang_tu_dong": "the whole 2nd-floor corridor from its east end",
        "03_cua_203": "the open door of room 203 with its number plate, a bunk bed visible inside",
        "04_phong_203": "inside room 203, a tidy student's room: bunk beds, a desk, lockers",
        "05_phong_203_nhin_nguoc": "room 203 from the back toward its open door",
        "06_giuong_203": "a bunk bed in room 203, close",
        "07_phong_207": "the open door of room 207 and the bare room inside",
    },
    "09_tang_1_sanh": {
        "01_sanh_nhin_ve_tay": "the ground-floor lobby corridor looking west toward the manager's room",
        "02_sanh_nhin_ve_dong": "the ground-floor lobby looking east: the glass main doors on the right, the corridor receding",
        "03_tu_cau_thang_chinh": "the lobby corridor seen from the foot of the main stairs",
        "04_hop_bao_chay": "a red push-button fire-alarm box on the wall near the stairs",
        "05_cua_chinh": "the glass main entrance doors, chained shut",
        "06_xich_cua_chinh": "the chain and padlock on the handles of the glass doors, close",
        "07_cua_phong_quan_ly": "the doorway of the dorm manager's room, from the lobby",
        "08_phong_quan_ly": "inside the dorm manager's small room: desk, chair, cabinet",
        "09_ban_va_dao": "the manager's wooden desk with a kitchen knife stuck upright in the desktop",
        "10_cua_so_phong_quan_ly": "the barred window of the manager's room, from inside",
        "11_cua_so_tu_ngoai": "the same barred window from outside the building",
        "12_hoc_tuong": "a recess in the lobby wall, from the corridor",
        "13_trong_hoc_tuong": "inside the recess in the lobby wall",
    },
    "10_vuon_hoa": {
        "01_loi_vao": "entering the garden: pavers, raised planters with clipped hedges, small trees, dorm block A behind",
        "02_ghe_da": "a polished-stone bench in front of a planter with a flowering tree",
        "03_ghe_da": "a polished-stone bench in front of a planter with a flowering tree, closer",
        "04_giuong_do": "a steel bunk bed lying overturned on the pavers",
        "05_cot_den": "a globe-topped lamp post, the corner of a dorm block behind",
        "06_tu_tang_4_nhin_xuong": "the garden seen from the 4th-floor corridor above",
        "07_vuon_nhin_sang_nha_A": "from the garden toward the front of dorm block A, a flowering tree in the middle",
        "08_vuon_nhin_ve_dong": "across the planters toward the buildings further east",
    },
    "11_nha_B_mat_ngoai": {
        "01_mat_truoc": "the front of dorm block B: open access corridors with railings and lit ceiling lamps on every floor, stair cores at both ends, trees in front",
        "02_mat_truoc_gan": "the front of dorm block B from close, looking up at its corridors",
        "03_mat_sau": "the back of dorm block B from close, looking up: rows of barred windows and air-conditioner units, balconies with laundry on the top floor",
        "04_mat_sau_rong": "the back of dorm block B from further away",
        "05_mat_sau_tu_xa": "the back of dorm block B, the 4th-floor balconies in the middle of the frame",
    },
    "12_nha_A_giang_duong_nha_the_chat": {
        "01_chan_nha_A": "the foot of dorm block A: ground-floor wall, windows, paving",
        "02_cua_so_nha_A": "looking up at dorm block A: a grid of windows, some with curtains, air-conditioner units",
        "03_goc_nha_A": "a corner of dorm block A across the grounds",
        "04_giang_duong": "the flat-roofed lecture block: a long facade with a regular grid of windows, the entrance in the middle",
        "05_goc_giang_duong": "a corner of the lecture block",
        "06_goc_nha_the_chat": "the gymnasium: a hall with a vaulted roof and a yellow gable wall",
        "07_cua_nha_the_chat": "the entrance door of the gymnasium",
    },
    "13_duong_cay_hang_rao": {
        "01_dai_lo": "the main campus avenue: asphalt with faded lines, kerbs, grass verges, street trees and lamp poles, a low building far ahead",
        "02_do_ben_duong": "belongings dropped at the roadside",
        "03_duong_phia_tay": "the road on the west side under spreading trees",
        "04_cay_sau_nha_B": "the trees behind dorm block B",
        "05_mai_che": "a steel bicycle shelter with a few bicycles, the white boundary wall behind",
        "06_ki_ot": "a small snack kiosk with a red tin roof, a bicycle beside it",
        "07_nhanh_dong": "the east branch road disappearing into the dark",
        "08_vong_bac": "the north loop road",
        "09_rao_tay": "the west boundary: chain-link fence on steel posts, a tree, the corner of the gymnasium",
        "10_rao_bac": "the north boundary: chain-link fence on steel posts",
    },
    "14_san_van_dong": {
        "01_cong_tay": "the stadium's west gate: two white concrete gate posts, a paved path, chain-link fence, the stand's roof beyond",
        "02_vao_san": "just inside the west gate: the track and pitch, a stand in the distance",
        "03_duong_chay": "the curve of the red running track with its white lane lines, dry grass inside it",
        "04_khung_thanh": "a football goal on the patchy pitch",
        "05_khan_dai": "the main stand: bare concrete terraces under a cantilevered tin roof on steel trusses, a few roof sheets missing",
        "06_tu_dinh_khan_dai": "from the top of the stand, down over the terraces to the track and pitch",
        "07_gam_khan_dai": "under the stand: raking concrete beams, columns, bare earth",
        "08_dau_khan_dai": "the end of the stand from the side",
        "09_cong_tay_bac": "the north-west gate and fence, the stand beside it",
        "10_cot_den_pha": "a tall steel floodlight mast",
        "11_toan_san_tu_khan_dai": "the whole pitch and track from the stand",
    },
    "15_cong_truong": {
        "01_tu_xa": "the gate from a distance: paved forecourt, gate pillars, the fallen sign, the guard booth",
        "02_di_toi": "walking toward the gate across the forecourt: a street lamp, parked cars, dropped belongings",
        "03_tru_tay": "the leaning west gate pillar of cracked limewashed masonry",
        "04_bien_truong": "the steel arch with the blue tin sign hanging half-fallen, a row of uniformed guards standing in the gateway",
        "05_rao_chan": "a red-and-white road barrier and traffic cones",
        "06_chot_bao_ve": "the yellow guard booth with its window, traffic cones in front, the white boundary wall and trees behind",
        "07_cua_so_chot": "looking into the guard booth through its window",
        "08_tuong_rao_dong": "the boundary wall east of the gate: limewashed masonry with vertical iron bars, the guard booth at its end",
        "09_tuong_rao_tay": "the boundary wall west of the gate: limewashed masonry with vertical iron bars",
        "10_san_lat": "the forecourt's interlocking pavers with dropped belongings, the gate behind",
        "11_nhin_ra_pho": "looking out through the gate to the street outside",
    },
    "16_nha_an": {
        "01_mat_truoc": "the front of the canteen: a red sign over the entrance canopy, barred windows in the yellow wall, the lit hall visible through the doors, a drinks fridge and bicycles outside",
        "02_mat_truoc_cheo": "the front of the canteen from an angle",
        "03_tu_cua_vao": "the dining hall from its entrance: white floor tiles reflecting ceiling tubes, rows of steel tables with attached stools, the serving counter at the back",
        "04_ti_vi": "a wall-mounted television in the dining hall",
        "05_quay": "the serving counter: a stainless tray rail, black menu boards above, a dark hatch into the kitchen",
        "06_tu_quay_nhin_ra": "from the serving counter back across the hall to the entrance",
        "07_ban_an": "dining tables with attached red and blue round stools, trays and litter on the floor",
        "08_dau_dong": "the east end of the dining hall",
        "09_bep": "the kitchen: a stainless hood over gas stoves with big pots, a wall clock, a soot-stained wall, a steel worktable",
        "10_kho": "the store room from its door",
        "11_kho_goc_ben": "the store room: steel shelving with cardboard boxes, a bare cement floor",
        "12_cua_sau": "the canteen's back door from outside",
        "13_dai_dat_dong": "the ground east of the canteen: a red steel kiosk, a small yellow-and-blue stall, a bicycle",
        "14_dai_dat_sau": "the ground behind the canteen",
        "15_dai_dat_tay": "the canteen's west wall with its barred windows",
    },
    "17_thu_vien": {
        "01_mat_truoc": "the front of the library: three storeys, yellow walls, dark windows with curtains, the entrance",
        "02_mat_ben": "the library from the side",
        "03_mat_dong": "the east face of the library",
        "04_cua_sau_tu_ngoai": "the library's back door from outside",
        "05_tang_1_tu_cua_sau": "the ground floor seen through the open back door",
        "06_tang_1_rong": "the ground floor, wide: rows of grey steel bookshelves, a tiled floor, a stained grid ceiling, the librarian's counter with an old computer, a framed map on the far wall",
        "07_tang_1_phia_bac": "the north side of the ground floor: bookshelves, loose papers on the tiles",
        "08_quay_thu_thu": "the librarian's wooden counter: an old CRT computer, an office chair, a book trolley",
        "09_ban_do": "a framed printed map of the campus on the wall",
        "10_cua_truoc_tu_trong": "the front double door from inside",
        "11_cau_thang": "the library staircase going up from the ground floor",
        "12_dau_cau_thang_tang_2": "the top of the stairs on the 2nd floor, looking across the reading room",
        "13_o_cau_thang_tang_2": "the stairwell opening on the 2nd floor with its guard railing",
        "14_ban_doc_tang_2": "a reading table with chairs and open books",
        "15_tang_2_rong": "the 2nd floor, wide: bookshelves and reading tables",
        "16_tang_3_rong": "the 3rd floor, wide: an old book store with wooden shelves on a bare cement floor",
        "17_tang_3_phia_nam": "the south side of the 3rd floor: old wooden shelves",
        "18_tang_3_ke_sach": "old wooden bookshelves on the 3rd floor, close",
        "19_dai_dat_tay": "the ground west of the library",
        "20_duong_toi_thu_vien": "the path from the lecture block toward the library",
    },
    "18_phong_407_chuong_4": {
        "01_tu_cua_vao": "the whole ransacked room from just inside the entrance door",
        "02_giuong_phia_tay": "the west side: lockers, a stripped bunk bed with its mosquito net, a desk",
        "03_giuong_phia_dong": "the east side: a bunk bed, lockers, the bathroom door, a rice cooker on a small cabinet, a standing fan",
        "04_san_nha": "a high view down onto the floor with the bedding thrown about",
        "05_tran_va_o_thong_gio": "the ceiling with its access panel and ceiling fan, and the ventilation louvre high on the wall",
        "06_cua_tu_trong": "the green entrance door from inside, a guitar and a desk to the left, lockers to the right",
        "07_cua_tu_hanh_lang": "room 407's door seen from the corridor, with the printed sheet of rules and the number plate",
        "08_loi_tay_nha_an": ("the canteen's west side door standing open, the lit dining hall inside, a yellow wall with an air-conditioner unit, grass in front", "16_nha_an"),
    },
    "19_cctv": {
        "Corridor_Cam": "a dorm corridor: green room doors, a number plate, tile floor",
        "Room102_Cam": "room 102: bunk beds with mosquito nets, lockers, a ceiling fan, a desk; one figure on a bed",
        "Room102_Hall_Cam": "the corridor outside room 102: its green door and number plate, a stained wall",
        "Room106_Cam": "room 106: bunk beds with mosquito nets, lockers, a ceiling fan, a desk with a lamp; one figure on a bed",
        "Room106_Hall_Cam": "the corridor outside room 106: its green door and number plate, a stained wall",
        "Room209_Cam": "room 209: bunk beds with mosquito nets, lockers, a ceiling fan, a desk; one figure on a bed",
        "Room209_Hall_Cam": "the corridor outside room 209: its green door and number plate, a stained wall",
        "Room306_Cam": "room 306: bunk beds with mosquito nets, lockers, a ceiling fan, a desk with a phone; one figure on a bed",
        "Room306_Hall_Cam": "the corridor outside room 306: its green door and number plate, a stained wall",
        "Room310_Cam": "room 310: two bunk beds facing each other, lockers in the foreground, a ceiling fan; two figures sitting on the beds",
        "Room310_Hall_Cam": "the corridor outside room 310: its green door and number plate, a stained wall",
    },
    "20_benh_vien": {
        "ket_ca_ba_01_khung_tinh_day": "the view of a patient lying in bed: a white blanket and the patient's bandaged hand in the foreground, a teal curtain ahead with the shadows of two nurses on it, the neighbouring beds with name cards, the grid ceiling",
        "ket_ca_ba_02_goc_phong": "the ward from a high corner: the teal curtain on its ceiling track, three beds with patients, bedside cabinets, an IV stand",
        "ket_ca_ba_03_canh_giuong": "beside the bed: white bedding, an IV stand, a bedside cabinet, a tall window, the neighbouring bed with a patient",
        "ket_mot_minh_01_khung_tinh_day": "the view of a patient lying in bed: a white blanket and the patient's bandaged hand in the foreground, a teal curtain ahead with the shadows of two nurses on it, the neighbouring beds empty and made, the grid ceiling",
        "ket_mot_minh_02_goc_phong": "the ward from a high corner: the teal curtain on its ceiling track, one bed with a patient and two empty made beds, bedside cabinets, an IV stand",
        "ket_mot_minh_03_canh_giuong": "beside the bed: white bedding, an IV stand, a bedside cabinet, a tall window, an empty made bed next to it",
    },
}

OUTDOOR = {"10_vuon_hoa", "11_nha_B_mat_ngoai", "12_nha_A_giang_duong_nha_the_chat", "13_duong_cay_hang_rao", "14_san_van_dong", "15_cong_truong"}


def lighting(area: str, name: str) -> str:
    if area == "20_benh_vien":
        return "soft morning daylight from the windows and the ward's ceiling lights. This scene is not at night."
    if area == "19_cctv":
        return "the room's or the corridor's own weak ceiling light, at night."
    if name.endswith("_den_tuyp"):
        return "one old fluorescent tube on the ceiling, slightly green-white, at night; dark blue night outside the window."
    if "den_pin" in name:
        return ("the only strong light is the torch of a phone held by the viewer: keep its round beam in the same place and the same size, "
                "and keep everything outside the beam nearly as dark as in the original.")
    if area in OUTDOOR or name[4:] in ("01_mat_truoc", "02_mat_ben", "03_mat_dong", "20_duong_toi_thu_vien", "13_dai_dat_dong", "14_dai_dat_sau", "15_dai_dat_tay"):
        return "night under an overcast dark sky; light only from the lamps and lit windows that are in the picture and a faint cool ambient."
    return "night; light only from the lamps that are in the picture and a faint ambient from outside. Keep the same parts dark."


def prompt(area: str, name: str, frame: str) -> str:
    _, place, materials, wear, details = AREAS[area]
    night = "" if area == "20_benh_vien" else "\n- the night-time mood: do not turn it into day;"
    return f"""Edit the attached image. It is a screenshot from a first-person horror game set on an old Vietnamese university campus. Repaint it so that it looks like a real photograph of this exact place, taken from the exact same camera position.

PLACE: {place}
IN THIS FRAME: {frame}.
LIGHT: {lighting(area, name)}

KEEP EXACTLY (the result will be used as a reference to rebuild the 3D scene):
- the camera position, angle, field of view and the 16:9 framing;
- the layout: every wall, floor, ceiling, door, window, stair, railing and large object stays where it is, with the same size and the same basic colour;
- any readable text exactly as written; add no new text, logos or watermarks;
- blocky low-poly human figures, if the image has any: leave them as they are, they are placeholders;{night}

MAKE MORE REAL:
- materials: {materials};
- age and use: {wear};
- light: natural falloff, soft contact shadows where things meet the floor and the walls, a little bounce light, believable reflections on tiles, glass and metal;
- small things that belong here ({details}), only where they would not block where a person walks.

DO NOT: add or remove doors, windows, furniture, buildings, vehicles or people; change the proportions of the space; add depth-of-field blur, film grain, lens flare, heavy fog or dramatic colour grading. It must stay something a real-time game engine could show."""


def frame_id(name: str) -> str:
    stem = re.sub(r"^ch\d_", "", name)
    return re.sub(r"_den_(pin|tuyp)$", "", stem)


def main() -> int:
    missing, cards, total, first = [], [], 0, 0
    for area in sorted(AREAS):
        files = sorted(glob.glob(os.path.join(ROOT, area, "*.jpg")))
        names = [os.path.splitext(os.path.basename(f))[0] for f in files]
        rows = []
        for name in names:
            entry = FRAMES.get(area, {}).get(frame_id(name))
            if entry is None:
                missing.append(f"{area}/{name}")
                continue
            frame, context = entry if isinstance(entry, tuple) else (entry, area)
            # One still per camera is enough to start with: the tube-lit one where a camera has both.
            twin = name.endswith("_den_pin") and name[:-8] + "_den_tuyp" in names
            total += 1
            first += 0 if twin else 1
            text = html.escape(prompt(context, name, frame))
            rows.append(f"""<div class="card{' twin' if twin else ''}" id="{area}-{name}">
<a href="{area}/{name}.jpg" target="_blank"><img loading="lazy" src="{area}/{name}.jpg" alt=""></a>
<div class="side"><div class="name">{area}/<b>{name}.jpg</b>{' <span class="tag">ảnh phụ (cùng góc, đèn pin)</span>' if twin else ''}</div>
<textarea readonly rows="7">{text}</textarea>
<div class="row"><button class="copy">Chép prompt</button>
<span class="save">Lưu ảnh GPT thành: <code>{name}_gpt.png</code> <button class="copyname" data-name="{name}_gpt">Chép tên</button></span>
<label><input type="checkbox" class="done" data-key="{area}/{name}"> đã làm</label></div></div></div>""")
        cards.append(f'<h2 id="{area}">{html.escape(AREAS[area][0])} <small>{area} · {len(rows)} ảnh</small></h2>\n' + "\n".join(rows))
    nav = " · ".join(f'<a href="#{a}">{html.escape(AREAS[a][0])}</a>' for a in sorted(AREAS))
    page = f"""<!doctype html><html lang="vi"><head><meta charset="utf-8"><title>Prompt GPT cho ảnh hiện trạng</title>
<style>
body{{font:15px/1.5 Segoe UI,Arial,sans-serif;background:#16181c;color:#e6e6e6;margin:0 auto;max-width:1200px;padding:16px}}
a{{color:#8ab4f8}} h1{{font-size:22px}} h2{{margin:36px 0 10px;border-bottom:1px solid #3a3f47;padding-bottom:4px}} small{{color:#9aa0a6;font-weight:normal;font-size:13px}}
.guide{{background:#20242b;border:1px solid #3a3f47;border-radius:8px;padding:10px 16px}}
.card{{display:flex;gap:12px;background:#20242b;border:1px solid #3a3f47;border-radius:8px;padding:10px;margin:10px 0;flex-wrap:wrap}}
.card.finished{{opacity:.45}} .card img{{width:384px;max-width:100%;height:auto;border-radius:4px;display:block}}
.side{{flex:1;min-width:300px}} .name{{margin-bottom:6px;word-break:break-all}} .tag{{color:#f0b35a;font-size:13px}}
textarea{{width:100%;box-sizing:border-box;background:#111317;color:#cfd3d8;border:1px solid #3a3f47;border-radius:4px;font:12px/1.4 Consolas,monospace}}
.row{{display:flex;gap:14px;align-items:center;flex-wrap:wrap;margin-top:6px}} button{{background:#2f6fed;color:#fff;border:0;border-radius:4px;padding:6px 12px;cursor:pointer}}
button.copyname{{background:#3a3f47;padding:3px 8px}} code{{background:#111317;padding:1px 5px;border-radius:3px}}
.bar{{position:sticky;top:0;background:#16181c;padding:8px 0;border-bottom:1px solid #3a3f47;z-index:2}}
body.onlyfirst .card.twin{{display:none}}
</style></head><body>
<h1>Prompt GPT cho {total} ảnh hiện trạng</h1>
<div class="guide"><ol>
<li>Mở một cuộc trò chuyện tạo ảnh trong GPT, kéo ảnh gốc vào (bấm vào ảnh thu nhỏ để mở ảnh đủ cỡ; file nằm ngay trong thư mục khu).</li>
<li>Bấm <b>Chép prompt</b>, dán vào GPT, gửi.</li>
<li>Lưu ảnh GPT với tên ghi sẵn (tên ảnh gốc thêm <code>_gpt</code>), vào thư mục <code>build/graphics/anh_gpt/&lt;tên khu&gt;/</code>. Tên đúng thì integrator biết ảnh ứng với camera nào.</li>
<li>Nếu GPT dời tường, cửa, đồ lớn hoặc đổi góc máy: bảo nó làm lại, "keep the layout and the camera exactly as in the original".</li>
</ol>
<p>Nên làm thử một khu trước rồi mới làm cả map. {first} ảnh là mỗi góc máy một ảnh; {total - first} ảnh còn lại là cùng góc máy chụp bằng đèn pin (phòng 407), không cần làm ngay.</p></div>
<div class="bar"><label><input type="checkbox" id="onlyfirst" checked> Ẩn ảnh phụ</label> · <span id="count"></span><br>{nav}</div>
{''.join(cards)}
<script>
function put(text){{if(navigator.clipboard&&window.isSecureContext){{return navigator.clipboard.writeText(text)}}
const t=document.createElement('textarea');t.value=text;document.body.appendChild(t);t.select();document.execCommand('copy');t.remove();return Promise.resolve()}}
function flash(b,label){{const old=b.textContent;b.textContent=label;setTimeout(()=>b.textContent=old,1200)}}
function load(){{try{{return JSON.parse(localStorage.getItem('atlas_done')||'{{}}')}}catch(e){{return {{}}}}}}
let done=load();
function count(){{const n=document.querySelectorAll('.done:checked').length;document.getElementById('count').textContent='Đã làm '+n+' / {total}'}}
document.querySelectorAll('.card').forEach(c=>{{
 const box=c.querySelector('.done');box.checked=!!done[box.dataset.key];c.classList.toggle('finished',box.checked);
 box.onchange=()=>{{done[box.dataset.key]=box.checked;c.classList.toggle('finished',box.checked);try{{localStorage.setItem('atlas_done',JSON.stringify(done))}}catch(e){{}};count()}};
 c.querySelector('.copy').onclick=e=>put(c.querySelector('textarea').value).then(()=>flash(e.target,'Đã chép'));
 c.querySelector('.copyname').onclick=e=>put(e.target.dataset.name).then(()=>flash(e.target,'Đã chép'));
}});
const only=document.getElementById('onlyfirst');only.onchange=()=>document.body.classList.toggle('onlyfirst',only.checked);only.onchange();count();
</script></body></html>"""
    with open(os.path.join(ROOT, "PROMPT_GPT.html"), "w", encoding="utf-8", newline="\n") as file:
        file.write(page)
    print(f"{total} prompts ({first} first-pass), {len(missing)} stills without a frame text")
    for name in missing:
        print("MISSING", name)
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
