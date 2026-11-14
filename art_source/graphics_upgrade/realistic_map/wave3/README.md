# Đồ hoạ thật đợt 3 — T-259 (D-166): vườn hoa trước nhà B

Card: `docs/tasks/T-259-realistic-graphics-wave3-garden.md`. Dựng bằng script Blender, texture vẽ bằng code
(numpy + Pillow). Không Tripo, không extension Blender, không ảnh AI.

**Lượt 1 (14/11/2026): góc mẫu quanh ghế Ngư và các phương án để chủ dự án chọn.** `garden.tscn` chưa sửa:
`capture_wave3.gd` gắn góc mẫu vào cảnh chương 3 thật lúc chạy (ẩn hình PS1 của `Bed1_1`, `Bed2_1`, hai cây, bụi,
hoa của hai bồn, `NguBench`, hai chân ghế, `Paving/Mesh`, `GardenLights_0_0`) rồi chụp. Lượt 2 sẽ gắn hẳn vào
`garden.tscn` theo phương án đã chọn.

## Dựng lại
```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave3/make_wave3_textures.py        # khoảng 1 phút
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave3/build_garden_pilot.py   # [-- trees beds plantings paving bench lamp]
python -B art_source/graphics_upgrade/realistic_map/wave3/make_wave3_materials.py       # .tres, shader lá, .import glb và texture
godot --headless --path game --import   # lần đầu chạy hai lần
```
`make_wave3_materials.py` viết `.import` của mọi PNG mới **trước** khi Godot nhập: `compress/mode=2` (nén VRAM),
`compress/normal_map=1` cho bản đồ normal, mipmap bật. Đã kiểm: cả 23 texture nhập thành `s3tc`.

Ảnh: chép `capture_wave3.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn script đó (không commit), rồi theo Lượt Godot:
```
godot --path game res://_probe_tmp/capture_wave3.tscn -- --configs=before,t1,t2,t3
godot --path game res://_probe_tmp/capture_wave3.tscn -- --configs=mix --extra=mix:plumeria+lagerstroemia/a/block/white --views=bench_wide,bench_close,entry,floor4
godot --path game res://_probe_tmp/capture_wave3.tscn -- --configs=f2 --extra=f2:plumeria/b/block/white --views=bed_close,bench_close,bench_wide
godot --path game res://_probe_tmp/capture_wave3.tscn -- --configs=p2 --extra=p2:plumeria/a/red/white --views=bench_wide,bench_close,entry,floor4
godot --path game res://_probe_tmp/capture_wave3.tscn -- --configs=k2 --extra=k2:plumeria/a/block/yellow --views=bed_close,bench_wide
python -B art_source/graphics_upgrade/realistic_map/wave3/make_wave3_sheets.py --refs <thư mục ảnh tham chiếu>
```
Sáu đèn `Flicker*` của vườn được giữ sáng (0,35) khi chụp để các phương án sáng như nhau; trong game chúng vẫn nhấp nháy.

## Phương án (ảnh ở `../previews/wave3/`)
| Mã | Là gì | Tam giác (bản gần / xa) | Vật liệu | Cách vẽ lá |
|---|---|---|---|---|
| T1 | Hoa sứ / hoa đại (*Plumeria obtusa*): cành mập rẽ đôi, chùm lá dài ở đầu cành, hoa trắng nhuỵ vàng | 6.170 / 262 | 2 (vỏ cây, atlas lá) | lá thật từng chiếc (3 × 3 đỉnh, gập theo gân giữa, cong rủ), hoa là thẻ chéo; bản xa: một thẻ quạt lá mỗi đầu cành |
| T2 | Bàng Đài Loan (*Terminalia mantaly*): thân thẳng, 7 tầng cành ngang | 1.788 / 207 | 2 | thẻ "đĩa" hoa thị lá nhỏ nằm gần ngang trên từng cành, thêm thẻ nhìn ngang |
| T3 | Bằng lăng (*Lagerstroemia speciosa*): thân chẻ ba, tán tròn, chùm hoa tím ở ngọn, vài cành lá già đỏ | 1.256 / 230 | 2 | 260 thẻ cành lá trên vỏ tán elip, 16 chùm hoa thẻ chéo |
| F1 | Viền chuỗi ngọc vàng xén phẳng + 4 bụi trang đỏ (mỗi bụi 3 chùm hoa = 12 khóm như PS1) | 892 + 432 hàng rào / bồn | 2 (atlas cây bụi, mặt hàng rào) | hàng rào là khối có texture lá + thẻ lá rối trên mặt; bụi là 40 thẻ quanh tâm |
| F2 | 4 khóm cẩm tú mai + 12 khóm dừa cạn hồng/trắng + cỏ ven viền, đất lộ hơn | 432 / bồn | 1 | thẻ quanh tâm khóm, cỏ là thẻ chéo |
| K1 / K2 | Viền bồn gạch trát, quét vôi trắng (K1) hoặc sơn vàng (K2), bẩn chân, bong sơn góc, rêu | 432 + 252 đất / bồn | 2 (shader vỏ phòng 407, đất) | — |
| P1 | Gạch block "con sâu" xám 225 × 112,5 mm | 12 (cả sân 44 × 40 m) | 1 (shader vỏ phòng 407, mặt nạ bẩn cả sân) | — |
| P2 | Gạch đỏ "lá dừa" 300 × 300 mm, rãnh xương cá, lát chéo ô | 12 | 1 | — |
| Ghế | Ghế đá mài của Ngư: mặt ghế, hai chân bản, đế | 428 | 1 | — |
| Đèn | Cột đèn sân vườn cầu tròn: đế bê tông, chân đúc, cột thép sơn xanh, cầu sứ phát sáng theo đèn | 1.148 | 3 | — |

Mọi cây: phần dưới 2 m nằm trong khối `CanopyCollision` của T-251 (script kiểm từng đỉnh: 0 đỉnh ra ngoài, lề
nhỏ nhất 1 cm); dưới 1,2 m chỉ có thân, bán kính ≤ 0,13 m như thân PS1. Lá, hoa không đổ bóng (`cast_shadow` tắt
trên node `Leaves*`, `Planting*`); thân, cành đổ bóng. Lá: shader `materials/foliage.gdshader`, cắt alpha (không trộn),
hai mặt, pháp tuyến hướng ra ngoài tán cho cả hai mặt, xuyên sáng nhẹ, gần như không bóng gương.

## Nguồn
Texture tự vẽ (CC0, dự án). Scan dùng lại, đã có trong game (CC0 Poly Haven): Painted Plaster Wall (viền bồn),
Peeling Painted Wall (bong sơn), Green Metal Rust (cột đèn), Plastered Wall 04 (đế đèn, `W1Concrete`), đá mài tự vẽ
của đợt 1 (ghế). Ảnh tham chiếu loài cây (`../previews/wave3/references.jpg`, chỉ để so, không đưa vào game):
| Ảnh | Tác giả | Giấy phép | Nguồn |
|---|---|---|---|
| Hoa sứ / hoa đại (Plumeria), cây trồng ven đường | BISLTAIO Tosmacia | CC0 | https://commons.wikimedia.org/wiki/File:SZ_%E6%B7%B1%E5%9C%B3_Shenzhen_%E7%A6%8F%E7%94%B0_Futian_%E4%B8%8B%E6%B2%99%E6%9D%B1%E6%B6%8C%E4%B8%80%E8%B7%AF_XiaSha_DongYong_1st_Road_%E9%9B%9E%E8%9B%8B%E8%8A%B1%E6%A8%B9_Plumeria_tree_June_2024_R12S.jpg |
| Hoa sứ trắng (Plumeria obtusa): hoa, lá | Christian Grenier | CC0 | https://commons.wikimedia.org/wiki/File:Plumeria_obtusa.jpg |
| Bàng Đài Loan (Terminalia mantaly) | Forestowlet | CC0 | https://commons.wikimedia.org/wiki/File:Terminalia_mantaly001.jpg |
| Bằng lăng (Lagerstroemia speciosa) | Idk1989 | CC BY 4.0 | https://commons.wikimedia.org/wiki/File:Lagerstroemia_Speciosa_Tree.jpg |
| Trang (Ixora coccinea) | Wilfredor | CC0 | https://commons.wikimedia.org/wiki/File:Ixora_coccinea_(Rubiaceae).jpg |
| Chuỗi ngọc (Duranta erecta), hàng rào | Forest and Kim Starr | CC BY 3.0 US | https://commons.wikimedia.org/wiki/File:Starr-090609-0287-Duranta_erecta-hedge_fruiting_habit-Haiku-Maui_(24667499920).jpg |
| Cẩm tú mai (Cuphea hyssopifolia) | Melburnian | CC BY 2.5 | https://commons.wikimedia.org/wiki/File:Cuphea_hyssopifolia.jpg |
| Dừa cạn (Catharanthus roseus) trong bồn | cultivar413 | CC BY 2.0 | https://commons.wikimedia.org/wiki/File:Chicago_Botanic_Gdn,_Heritage_Gdn,_Psychic_bed_180719_336_Catharanthus_roseus_%27Mega_Bloom_Pink_Halo%27_Rose_Periwinkle,_Ageratum_%27Everest_Blue%27_Floss_Flower.jpg |
