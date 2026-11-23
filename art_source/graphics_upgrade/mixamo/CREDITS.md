# Credits — động tác Mixamo cho Trần Trung và quản lý (T-268, D-189)

| File game | Clip Mixamo (tên trên trang, mô tả) | File gốc trong staging | Tác giả / công cụ | Quyền dùng |
|---|---|---|---|---|
| `game/assets/models/characters/mixamo/trung_mixamo.res`: `idle` | Neutral Idle | `trung/idle_neutral.fbx` | Mixamo (Adobe); đóng gói, chuyển khung xương: Claude (`pack_mixamo.ps1`, `pack_mixamo.gd`) | Ngoại lệ **D-189** |
| `trung_mixamo.res`: `idle_breathing` | Breathing Idle | `trung/idle.fbx` | Như trên | D-189 |
| `trung_mixamo.res`: `walk_fwd` | Standard Walk | `trung/walk_fwd.fbx` | Như trên | D-189 |
| `trung_mixamo.res`: `walk_back` | Walking Backwards | `trung/walk_back.fbx` | Như trên | D-189 |
| `trung_mixamo.res`: `walk_left` | Left Strafe Walking | `trung/walk_left.fbx` | Như trên | D-189 |
| `trung_mixamo.res`: `walk_right` | Right Strafe Walking | `trung/walk_right.fbx` | Như trên | D-189 |
| `game/assets/models/characters/mixamo/manager_mixamo.res`: `walk` | Walking (Male Brutal Walk) | `manager/walk_brutal.fbx` | Như trên; nướng lên khung xương Tripo của quản lý | D-189 |
| `manager_mixamo.res`: `slash` | Standing Melee Attack Downward (Downward Attack With Axe), đoạn 0–1,2 s, đuôi 0,3 s hoà về khung đầu | `manager/slash_downward.fbx` | Như trên | D-189 |

- **Nguồn:** [mixamo.com](https://www.mixamo.com/), tải ngày 22/11/2026 bằng tài khoản Adobe của chủ dự án, qua Chrome của chủ dự án (integrator điều khiển, D-189). Nhân vật X Bot; FBX Binary, Without Skin, 30 khung/giây, không giảm keyframe; tích In Place nếu clip có ô này.
- **Quyền dùng (D-189):** chủ dự án chấp nhận điều khoản Mixamo như một ngoại lệ của luật CC0/CC-BY (`AGENTS.md`). Dùng miễn phí bản quyền trong game thương mại; không phát tán file gốc ra ngoài nhóm. Vì vậy:
  - FBX gốc chỉ nằm ở `build/graphics/staging/mixamo/`, không commit (`.gitignore` chặn `*.fbx`). Repo chỉ lưu hash: `SHA256SUMS.txt` (đủ 56 file đã tải).
  - Repo chỉ chứa thư viện đã chuyển sang khung xương của game (`.res`). **Phải gỡ thư mục `game/assets/models/characters/mixamo/` trước khi mở repo công khai.**
  - Chỉ lấy động tác. Không tải nhân vật của dự án lên Mixamo.
- **Cách đóng gói:** xem `README.md` cùng thư mục.
- **Ghi chú Steam (AI):** động tác là dữ liệu quay chuyển động của Mixamo, không do AI tạo. Phần chuyển khung xương do script của dự án làm (Claude viết).
- Clip đã tải nhưng chưa dùng (56 file, xem `docs/handoff/MIXAMO_DONG_TAC.md`) chưa vào game. Mỗi khi đóng gói thêm clip, thêm một dòng vào bảng trên.
