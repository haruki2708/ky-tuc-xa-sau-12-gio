"""Chapter 1 script: single source of truth (T-150 part 2, design v2 §5).

Run from the repo root:  python docs/design/ch1/build_ch1_script.py
It (re)writes:
  - the chapter-1 rows of game/localization/strings.csv (old ones of the same
    prefixes are replaced),
  - game/data/messages/chat_ch1_*.tres (group-call lines and Trung's replies),
  - game/data/documents/ch1_*.tres, game/data/puzzles/locker_combo_dat.tres,
  - docs/design/CH1_SCRIPT.md (readable script for the owner's review).
Edit the text here, never in the generated files.
"""
import csv
import io
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

# Group-call members: id -> (display name vi, en). Room numbers are building B
# unless noted.
NAMES = {
    "unknown": ("Người lạ", "Unknown caller"),
    "minh_nhat": ("Minh Nhật · 203", "Minh Nhật · 203"),
    "hung": ("Hùng · 102", "Hùng · 102"),
    "kiet": ("Kiệt · 306", "Kiệt · 306"),
    "bao": ("Bảo · 209", "Bảo · 209"),
    "dang": ("Đăng · 106", "Đăng · 106"),
    "son": ("Sơn · 504", "Sơn · 504"),
    "vinh": ("Vinh · 311", "Vinh · 311"),
    "tung": ("Tùng · 110", "Tùng · 110"),
    "ngu": ("Ngọc Ngư · 401 nhà A", "Ngọc Ngư · A-401"),
    "trung": ("Tôi", "Me"),
}
# Who speaks in the room or on the speaker (not in the call).
VOICES = {"loa": "Loa trường", "mgr": "Quản lý", "phuc": "Phúc", "viet": "Việt (ngoài cửa)",
          "dat": "Đạt", "trung": "Trung (suy nghĩ, chỉ phụ đề)"}

# kind: spk (speaker), rule (speaker, also a rule-book line), mgr (manager),
#       room (voice in the room), think (Trung's thought, subtitle only),
#       chat (spoken in the group call), choice (Trung's options),
#       event (stage direction, no text), death (death-screen reason)
# Each: (kind, id, who, time, vi, en)  — for choice: vi/en are lists.
SCRIPT = [
    ("section", "Mở đầu — 4:00", "", "", "", ""),
    ("event", "", "", "04:00", "Trung nằm trên giường số 3, tỉnh giấc vì tiếng loa. Đèn tắt, chỉ có ánh xanh từ cửa sổ.", ""),
    ("spk", "WARN", "loa", "04:00", "Chú ý. Một phút nữa, người nào còn nằm trên giường sẽ chết.",
     "Attention. In one minute, anyone still lying in bed will die."),
    ("room", "PHUC_GRUMBLE", "phuc", "04:00", "Ai mở loa giờ này vậy trời…", "Who turns the speaker on at this hour…"),
    ("room", "DAT_GRUMBLE", "dat", "04:00", "Bốn giờ sáng đó. Để người ta ngủ với.", "It's four in the morning. Let people sleep."),
    ("room", "VIET_GRUMBLE", "viet", "04:00", "Kệ nó. Ngủ tiếp đi.", "Ignore it. Go back to sleep."),
    ("think", "GET_UP", "trung", "04:00", "Tỉnh rồi thì đi vệ sinh luôn vậy.", "Since I'm awake, I might as well go to the toilet."),
    ("event", "", "", "04:01", "Hết 60 giây thật. Còn nằm trên giường thì chết (DEATH_STAYED_IN_BED). Trung đã ra nhà vệ sinh chung cuối hành lang thì nghe tiếng la hét lan khắp tòa nhà.", ""),
    ("think", "RETURN", "trung", "04:03", "Sao im lặng quá vậy…", "Why is it so quiet…"),
    ("think", "BLOOD", "trung", "04:03", "Máu… Phúc? Việt? Đạt?", "Blood… Phúc? Việt? Đạt?"),
    ("event", "", "", "04:03", "Ba bạn nằm chết trên giường 1, 2, 4; máu nhỏ xuống sàn.", ""),
    ("think", "NO_SIGNAL", "trung", "04:04", "Không có sóng. Gọi cấp cứu cũng không được.", "No signal. I can't even call for help."),
    ("event", "", "", "04:04", "Trung chạm vào nắm cửa định chạy đi thì loa đọc Tổng tắc.", ""),
    ("spk", "GENERAL_INTRO", "loa", "04:04", "Toàn thể sinh viên chú ý. Sau đây là Tổng tắc của ký túc xá.",
     "Attention, all students. These are the General Rules of the dormitory."),
    ("rule", "GENERAL_1", "loa", "04:04", "Mọi quy tắc phải được nghe rõ và làm đúng. Ai vi phạm sẽ chết ngay tại chỗ.",
     "Every rule must be heard and obeyed. Anyone who breaks one dies on the spot."),
    ("rule", "GENERAL_2", "loa", "04:04", "Khi quy tắc mới được công bố, quy tắc cũ hết hiệu lực. Không có quy tắc nào lặp lại.",
     "When a new rule is announced, the old one expires. No rule is ever repeated."),
    ("rule", "GENERAL_3", "loa", "04:04", "Không sinh viên nào được rời khỏi phòng của mình. Ai rời phòng sẽ chết.",
     "No student may leave their own room. Anyone who leaves will die."),
    ("rule", "GENERAL_4", "loa", "04:04", "Không được tấn công quản lý ký túc xá, bảo vệ hay bất kỳ nhân viên nào.",
     "Do not attack the dorm manager, the guards or any staff."),
    ("rule", "GENERAL_5", "loa", "04:04", "Mỗi giờ sẽ có một quy tắc mới, trong năm giờ. Ai còn sống đến cuối cùng sẽ được rời đi an toàn.",
     "Every hour brings a new rule, for five hours. Whoever is still alive at the end may leave safely."),
    ("think", "HAND_OFF", "trung", "04:05", "Suýt nữa thì… Tay mình vẫn còn trên nắm cửa.", "That was close… My hand was still on the handle."),

    ("section", "Vòng 1 — 4:05 đến 5:00: bị giam trong phòng", "", "", "", ""),
    ("event", "", "", "04:05", "Từ đây bước qua ngưỡng cửa là chết (DEATH_LEFT_ROOM). Checkpoint `r1_start`.", ""),
    ("think", "WALL", "trung", "04:06", "Phòng bên cạnh không ai trả lời. Không một tiếng động.", "No one answers next door. Not a sound."),
    ("event", "", "", "04:10", "Điện thoại: cuộc gọi từ Người lạ (`stranger_call`). Bắt máy thì vào cuộc gọi nhóm.", ""),
    ("chat", "N_HELLO", "minh_nhat", "04:10", "Alo? Nghe được không? Tôi là Minh Nhật, phòng 203 nhà B.",
     "Hello? Can you hear me? I'm Minh Nhật, room 203, building B."),
    ("chat", "N_HOW", "minh_nhat", "04:10", "Hồi trước rảnh quá, tôi dựng một nhóm gọi qua mạng nội bộ của ký túc xá. Không cần sóng, chỉ cần còn wifi trong tòa nhà.",
     "I got bored once and set up a group call over the dorm's local network. No signal needed, just the building's wifi."),
    ("choice", "INTRO", "trung", "04:11",
     ["Tôi là Trung, phòng 407. Phòng tôi… chết hết rồi.", "Cậu gọi được thật à? Ngoài kia còn ai không?"],
     ["I'm Trung, room 407. Everyone in my room… is dead.", "You can actually call? Is anyone else out there?"]),
    ("chat", "N_TOGETHER", "minh_nhat", "04:11", "Tôi đang mời mọi máy còn kết nối. Phải bám vào nhau mà sống.",
     "I'm inviting every phone still connected. We have to hold on to each other to survive."),
    ("event", "", "", "04:12", "Thành viên lần lượt vào nhóm: Hùng, Đăng, Bảo, Sơn, Kiệt, Tùng, Vinh và khoảng 15 người không nói gì (tổng 23).", ""),
    ("chat", "HUNG_JOKE", "hung", "04:12", "Hùng đây, 102. Chắc trường bày trò diễn tập thôi, ai lại làm thật.",
     "Hùng here, 102. Must be some school drill. Nobody would do this for real."),
    ("chat", "DANG_ANGRY", "dang", "04:13", "Diễn tập cái đầu mày! Ba thằng phòng tao nằm chết trên giường kìa!",
     "Drill my ass! Three guys in my room are lying dead in their beds!"),
    ("chat", "BAO_CRY", "bao", "04:13", "Bảo, phòng 209… tôi sợ lắm… máu chảy xuống tận sàn…",
     "Bảo, room 209… I'm so scared… the blood is dripping onto the floor…"),
    ("chat", "SON_QUIET", "son", "04:14", "Sơn, 504. Hai phòng bên cạnh tôi không còn tiếng gì nữa.",
     "Sơn, 504. The two rooms next to mine have gone completely silent."),
    ("chat", "KIET_ASK", "kiet", "04:15", "Có ai thử ra ngoài chưa? Biết đâu xuống được tới cổng?",
     "Has anyone tried going outside? Maybe we can reach the gate?"),
    ("chat", "TUNG_GO", "tung", "04:15", "Tùng, 110. Phòng tao ở tầng một, sát cổng. Để tao chạy ra gọi người.",
     "Tùng, 110. I'm on the ground floor, right by the gate. I'll run out and get help."),
    ("chat", "N_STOP", "minh_nhat", "04:15", "Đừng! Tổng tắc điều ba, rời phòng là chết!",
     "Don't! General Rule three: leave your room and you die!"),
    ("chat", "TUNG_OUT", "tung", "04:16", "Tao mở cửa rồi. Hành lang không có ai cả. Thấy chưa, có gì đâ…",
     "Door's open. The corridor's empty. See, there's noth—"),
    ("event", "", "", "04:16", "Tùng chết: tiếng hét, điện thoại rơi vỡ, tên Tùng xám lại.", ""),
    ("chat", "HUNG_SHAKEN", "hung", "04:16", "Tùng? Tùng ơi?", "Tùng? Tùng?"),
    ("think", "RULE_REAL", "trung", "04:17", "Loa không đùa. Không được ra khỏi phòng.", "The speaker isn't joking. I can't leave the room."),
    ("chat", "N_BATTERY", "minh_nhat", "04:18", "Mọi người để ý pin. Cuộc gọi này ngốn pin lắm. Mất kết nối là coi như một mình.",
     "Watch your battery, everyone. This call eats power. Lose the connection and you're on your own."),
    ("think", "LOW_BATTERY", "trung", "04:18", "Pin còn ít quá. Dây sạc của mình còn đây, nhưng cục sạc đâu…",
     "My battery's almost gone. My cable's here, but where's the charger…"),
    ("think", "DAT_CHARGER", "trung", "04:19", "Hôm qua Đạt mượn cục sạc của mình rồi khóa trong tủ…",
     "Đạt borrowed my charger yesterday and locked it in his locker…"),
    ("event", "", "", "04:20", "Câu đố: tủ khóa số của Đạt (`locker_combo_dat`, mã 1407). Sổ tay Đạt: \"mật khẩu là sinh nhật tao\"; thẻ sinh viên: sinh ngày 14/07/2006. Mở tủ, lấy cục sạc, cắm ở ổ cạnh bàn Trung.", ""),
    ("think", "CHARGING", "trung", "04:25", "Đang sạc rồi. Phải ở gần ổ điện.", "It's charging. I have to stay near the socket."),
    ("event", "", "", "04:35", "Cám dỗ: tiếng gõ cửa và giọng Việt ngoài hành lang. Mở cửa thì hành lang trống, có dấu chân máu đi xa; bước ra là chết.", ""),
    ("room", "KNOCK_VIET", "viet", "04:35", "Trung ơi, mở cửa cho tao. Tao ra ngoài đi vệ sinh, giờ không vào được…",
     "Trung, open the door for me. I went to the toilet and now I can't get back in…"),
    ("think", "VIET_BED", "trung", "04:35", "Việt… đang nằm trên giường kia mà.", "But Việt… is lying in that bed right there."),
    ("room", "KNOCK_VIET_2", "viet", "04:36", "Ra đây với tao đi. Ngoài này không có ai đâu.", "Come out here with me. There's nobody out here."),
    ("chat", "VINH_ASK", "vinh", "04:37", "Vinh, 311. Có ai nghe tiếng bạn cùng phòng gọi ngoài cửa không? Tôi vừa nghe…",
     "Vinh, 311. Has anyone heard their roommate calling from outside the door? I just did…"),
    ("chat", "N_DONT_OPEN", "minh_nhat", "04:37", "Đừng ra. Mở cửa thì chưa sao, nhưng bước qua ngưỡng cửa là hết.",
     "Don't go out. Opening the door may be fine, but step over the threshold and it's over."),
    ("chat", "N_THEORY", "minh_nhat", "04:50", "Loa nói mỗi giờ một quy tắc mới. Năm giờ sẽ có quy tắc thứ hai. Phải nghe thật kỹ từng chữ.",
     "The speaker said a new rule every hour. At five there'll be a second one. We have to listen to every single word."),
    ("choice", "WORDS", "trung", "04:50",
     ["Ừ. Tôi sẽ ghi lại từng chữ.", "Nghe kỹ thì được gì? Nó muốn giết thì giết thôi."],
     ["Okay. I'll write down every word.", "What's the point? If it wants to kill us, it will."]),
    ("chat", "N_WORDS_REPLY", "minh_nhat", "04:51", "Quy tắc chưa nói dối lần nào. Nếu có đường sống, nó nằm trong câu chữ.",
     "The rules haven't lied once. If there's a way out, it's in the wording."),
    ("spk", "R1_END", "loa", "05:00", "Vòng một kết thúc. Số sinh viên còn sống: ba trăm năm mươi hai.",
     "Round one is over. Students still alive: three hundred and fifty-two."),
    ("chat", "SON_352", "son", "05:00", "Ba trăm năm mươi hai… cả trường mấy nghìn người mà…",
     "Three hundred fifty-two… there were thousands of us…"),

    ("section", "Vòng 2 — 5:00 đến 6:00: quản lý kiểm tra phòng", "", "", "", ""),
    ("rule", "R2", "loa", "05:00", "Vòng hai. Trong một giờ tới, nhà trường kiểm tra phòng. Mỗi tòa nhà có một quản lý. Sinh viên hãy nằm yên trên giường và hợp tác với công việc của quản lý.",
     "Round two. Over the next hour the school will inspect the rooms. Each building has one manager. Students must stay still in bed and cooperate with the manager's work."),
    ("chat", "N_BEDS", "minh_nhat", "05:01", "Lên giường hết đi. Nhanh lên.", "Everyone, get in bed. Now."),
    ("think", "GET_IN_BED", "trung", "05:01", "Phải lên giường trước khi ông ta tới.", "I need to be in bed before he gets here."),
    ("event", "", "", "05:01", "Checkpoint `r2_start`. Tiếng dao kéo lê bắt đầu vọng từ tầng một.", ""),
    ("chat", "HUNG_KNOCK", "hung", "05:05", "Có người gõ cửa phòng tao… Quản lý tới rồi.", "Someone's knocking on my door… The manager's here."),
    ("mgr", "ASK_HUNG", "mgr", "05:05", "Đinh Xuân Hùng. Có ở đây không?", "Đinh Xuân Hùng. Are you here?"),
    ("chat", "HUNG_YES", "hung", "05:05", "Dạ… dạ có. Em đây ạ.", "Y-yes. I'm here, sir."),
    ("mgr", "GOOD", "mgr", "05:05", "Tốt. Vậy thì đến lượt cậu.", "Good. Then it's your turn."),
    ("event", "", "", "05:06", "Hùng chết (qua cuộc gọi: tiếng chém, tiếng hét, điện thoại vỡ).", ""),
    ("chat", "N_ANALYZE", "minh_nhat", "05:07", "Quy tắc bảo nằm yên trên giường và hợp tác. Hùng trả lời thật mà vẫn chết. Hay là chữ \"hợp tác\" có vấn đề?",
     "The rule says stay in bed and cooperate. Hùng told the truth and still died. Could the word \"cooperate\" be the catch?"),
    ("choice", "THEORY", "trung", "05:07",
     ["Hay là đừng trả lời gì cả?", "Hay là phải nói mình không có ở đây?", "Tôi không biết. Chưa đủ thông tin."],
     ["Maybe don't answer at all?", "Maybe you have to say you're not here?", "I don't know. Not enough to go on."]),
    ("chat", "N_UNKNOWN", "minh_nhat", "05:08", "Chưa biết được. Ai đó… sẽ phải thử.", "No way to know yet. Someone… will have to try."),
    ("chat", "KIET_306", "kiet", "05:12", "Sao ông ta lên 306 rồi? Không đi theo số phòng à?", "Why is he at 306 now? He's not going in order?"),
    ("mgr", "ASK_BED_3", "mgr", "05:12", "Giường số ba. Có ở đây không?", "Bed three. Is anyone here?"),
    ("chat", "KIET_NO", "kiet", "05:12", "Không… không có ai ở đây hết.", "N-no… there's nobody here."),
    ("mgr", "WHY_NOT", "mgr", "05:12", "Nằm ngoan trên giường thế kia, sao lại nói không có?", "Lying so nicely in bed, and you say nobody's here?"),
    ("event", "", "", "05:13", "Kiệt chết.", ""),
    ("chat", "BAO_209", "bao", "05:20", "Ông ta tới 209 rồi… tôi phải làm sao… làm sao bây giờ…", "He's at 209… what do I do… what do I do…"),
    ("chat", "N_TRY_SILENT", "minh_nhat", "05:20", "Bảo, thử im lặng. Ông ta hỏi gì cũng đừng trả lời.", "Bảo, try staying silent. Whatever he asks, don't answer."),
    ("mgr", "ASK_BED_4", "mgr", "05:21", "Giường số bốn. Có ở đây không?", "Bed four. Is anyone here?"),
    ("event", "", "", "05:21", "Im lặng rất lâu (khoảng 8 giây).", ""),
    ("mgr", "LAUGH", "mgr", "05:22", "(cười khàn khàn)", "(a hoarse chuckle)"),
    ("event", "", "", "05:22", "Bảo chết.", ""),
    ("chat", "DANG_CURSE", "dang", "05:23", "Im lặng cũng chết! Thế này thì làm cái quái gì mới đúng!", "Silence gets you killed too! What the hell are we supposed to do?!"),
    ("chat", "DANG_HERE", "dang", "05:28", "106… ông ta tới 106 rồi. Phòng tao. Nói gì đi, tao phải làm gì?", "106… he's at 106. My room. Say something, what do I do?"),
    ("choice", "ADVISE", "trung", "05:28",
     ["Trùm chăn kín người lại!", "Hô to tên mày với số giường!", "Chạm vào ông ta, cho ông ta biết mày còn sống!"],
     ["Pull the blanket over your whole body!", "Shout your name and bed number!", "Touch him, show him you're alive!"]),
    ("mgr", "ASK_BED_2", "mgr", "05:29", "Giường số hai. Có ở đây không?", "Bed two. Is anyone here?"),
    ("event", "", "", "05:29", "Đăng chết, dù người chơi khuyên gì.", ""),
    ("chat", "N_ALL_FAIL", "minh_nhat", "05:32", "Sơn trùm chăn, Vinh hô tên, có người còn chạm vào ông ta… Không cách nào được cả.",
     "Sơn hid under his blanket, Vinh shouted his name, someone even touched him… Nothing works."),
    ("event", "", "", "05:33", "Sơn, Vinh và những người im lặng lần lượt xám tên.", ""),
    ("chat", "N_JUST_US", "minh_nhat", "05:38", "Trong nhóm… chỉ còn tôi với cậu.", "In the group… it's just you and me now."),
    ("think", "DRAG", "trung", "05:40", "Tiếng kéo dao… ở ngay tầng này.", "That dragging blade… it's on this floor."),
    ("event", "", "", "05:43", "Checkpoint `r2_manager` (người chơi phải đang nằm trên một giường). Tiếng gõ cửa 407. Quản lý mở cửa, vào phòng.", ""),
    ("think", "HINT_1", "trung", "05:43", "Quy tắc chỉ nói \"nằm yên trên giường\". Nó không nói giường của ai.",
     "The rule only says \"stay in bed\". It never says whose bed."),
    ("think", "HINT_2", "trung", "05:43", "Ông ta sẽ hỏi giường số ba, giường của mình. Nếu mình không nằm ở đó…",
     "He'll ask for bed three, my bed. If I'm not lying in it…"),
    ("event", "", "", "05:43", "HINT_1 chỉ hiện từ lần chết thứ hai ở cảnh này, HINT_2 từ lần thứ ba.", ""),
    ("event", "", "", "05:44", "Quản lý hỏi giường số ba (MGR ASK_BED_3), chờ. Không nằm giường nào: chết (DEATH_NOT_IN_BED). Nằm giường số 3: chết (DEATH_OWN_BED). Có tiếng thở hoặc nhúc nhích: chết (DEATH_HEARD). Nằm giường bạn, nín thở: quản lý cười rồi chém nát giường số 3, bỏ đi.", ""),
    ("think", "SURVIVED", "trung", "05:46", "Ông ta chém nát giường của mình… rồi bỏ đi.", "He hacked my bed to pieces… and walked away."),
    ("think", "WHY", "trung", "05:46", "Việc của quản lý không phải kiểm tra phòng. Mà là dọn sạch người sống. \"Hợp tác\"… là nằm như người chết.",
     "The manager's job isn't inspecting rooms. It's clearing out the living. \"Cooperate\"… means lying there like the dead."),
    ("choice", "TELL", "trung", "05:47",
     ["Nhật! Nằm lên giường của bạn cùng phòng đã chết. Đừng nằm giường mình, nín thở!"],
     ["Nhật! Lie on your dead roommate's bed. Not your own. Hold your breath!"]),
    ("chat", "N_THANKS", "minh_nhat", "05:52", "Ông ta vừa chém nát giường tôi… Tôi còn sống. Cảm ơn cậu, Trung.",
     "He just shredded my bed… I'm alive. Thank you, Trung."),
    ("chat", "N_NETWORK", "minh_nhat", "05:54", "Để tôi thử mở rộng mạng… Được rồi, bắt được nhà A bên kia vườn hoa.",
     "Let me try widening the network… Got it, I've reached building A across the garden."),
    ("chat", "NGU_HELLO", "ngu", "05:55", "Các cậu là… ai vậy? Nhà A, phòng 401, Khương Ngọc Ngư.", "Who… are you? Building A, room 401, Khương Ngọc Ngư."),
    ("chat", "NGU_LUCK", "ngu", "05:56", "Lúc quản lý tới, tôi đang ở cửa sổ gọi người. Không kịp về giường mình nên nằm đại lên giường bạn… Chắc nhờ vậy mà sống.",
     "When the manager came I was at the window calling for help. I couldn't get back to my bed, so I lay on my roommate's… That must be why I'm alive."),
    ("chat", "NGU_ALONE", "ngu", "05:57", "Hình như cả nhà A… chỉ còn mình tôi.", "I think in all of building A… I'm the only one left."),
    ("spk", "R2_END", "loa", "06:00", "Vòng hai kết thúc. Số sinh viên còn sống: hai mươi tám.",
     "Round two is over. Students still alive: twenty-eight."),
    ("think", "END", "trung", "06:00", "Hai mươi tám người. Còn ba vòng nữa.", "Twenty-eight people. Three rounds to go."),
    ("event", "", "", "06:00", "Hết chương 1. Mở khóa chương 2.", ""),

    ("section", "Lý do chết (màn chết)", "", "", "", ""),
    ("death", "STAYED_IN_BED", "", "", "Bạn vẫn nằm trên giường khi hết một phút.", "You were still in bed when the minute ran out."),
    ("death", "LEFT_ROOM", "", "", "Bạn đã bước ra khỏi phòng.", "You stepped out of your room."),
    ("death", "NOT_IN_BED", "", "", "Bạn không nằm trên giường khi quản lý vào phòng.", "You weren't in bed when the manager came in."),
    ("death", "OWN_BED", "", "", "Quản lý tìm thấy bạn trên giường của chính mình.", "The manager found you in your own bed."),
    ("death", "HEARD", "", "", "Quản lý nghe thấy bạn.", "The manager heard you."),
]

# Readable papers in room 407. id -> (style, title vi/en, [lines vi/en])
DOCUMENTS = {
    "ch1_dat_note": ("handwritten", ("Sổ tay của Đạt", "Đạt's notebook"), [
        ("Mật khẩu tủ: sinh nhật tao. Đứa nào mở trộm là chết với tao.", "Locker code: my birthday. Whoever opens it behind my back is dead meat."),
        ("Thứ hai: trả cục sạc cho Trung.", "Monday: give Trung his charger back."),
    ]),
    "ch1_dat_card": ("stamped", ("Thẻ sinh viên", "Student ID card"), [
        ("Họ tên: Phạm Thành Đạt", "Name: Phạm Thành Đạt"),
        ("Ngày sinh: 14/07/2006", "Date of birth: 14/07/2006"),
        ("Ký túc xá: phòng 407, nhà B", "Dormitory: room 407, building B"),
    ]),
    "ch1_phuc_schedule": ("handwritten", ("Lịch thi của Phúc", "Phúc's exam schedule"), [
        ("Giải tích 2: thứ hai, 7 giờ 30. KHÔNG ĐƯỢC NGỦ QUÊN.", "Calculus 2: Monday, 7:30. DO NOT OVERSLEEP."),
        ("Hứa với mẹ kỳ này qua hết các môn.", "Promised Mom I'd pass everything this term."),
    ]),
    "ch1_viet_photo": ("handwritten", ("Mặt sau tấm ảnh gia đình", "Back of a family photo"), [
        ("Học xong thì về quê làm thầy giáo nghe con. Ba mẹ.", "Finish school and come home to teach, son. Mom and Dad."),
    ]),
}
PUZZLES = {"locker_combo_dat": ("PUZZLE_LOCKER_DAT_TITLE", ("Tủ của Đạt", "Đạt's locker"), "1407", "ch1_dat_card")}

PREFIXES = ("SPK_CH1_", "RULE_CH1_", "MGR_CH1_", "ROOM_CH1_", "THINK_CH1_", "CHAT_CH1_", "CHOICE_CH1_",
            "DEATH_", "NAME_CH1_", "DOC_CH1_", "PUZZLE_LOCKER_DAT_")


def key_of(kind, ident, n=None):
    base = {"spk": "SPK_CH1_", "rule": "RULE_CH1_", "mgr": "MGR_CH1_", "room": "ROOM_CH1_", "think": "THINK_CH1_",
            "chat": "CHAT_CH1_", "choice": "CHOICE_CH1_", "death": "DEATH_"}[kind] + ident
    return base if n is None else "%s_%d" % (base, n)


def minutes(clock):
    h, m = clock.split(":")
    return int(h) * 60 + int(m)


def tres_message(mid, sender, text_key, mins, outgoing, spoken):
    return ('[gd_resource type="Resource" script_class="MessageData" load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="res://scripts/core/message_data.gd" id="1_msg"]\n\n'
            '[resource]\nscript = ExtResource("1_msg")\nid = &"%s"\nsender = &"%s"\nsender_name_key = "NAME_CH1_%s"\n'
            'text_key = "%s"\nminutes = %d\noutgoing = %s\nspoken = %s\n'
            % (mid, sender, sender.upper(), text_key, mins, "true" if outgoing else "false", "true" if spoken else "false"))


def main():
    rows = []
    for sid, (vi, en) in NAMES.items():
        rows.append(("NAME_CH1_" + sid.upper(), vi, en))
    messages = {}
    for kind, ident, who, clock, vi, en in SCRIPT:
        if kind in ("section", "event"):
            continue
        if kind == "choice":
            for n, (v, e) in enumerate(zip(vi, en), 1):
                key = key_of(kind, ident, n)
                rows.append((key, v, e))
                mid = key.lower()
                messages[mid] = tres_message(mid, "trung", key, minutes(clock), True, False)
            continue
        key = key_of(kind, ident)
        rows.append((key, vi, en))
        if kind == "chat":
            mid = key.lower()
            messages[mid] = tres_message(mid, who, key, minutes(clock), False, True)
    for doc_id, (style, title, lines) in DOCUMENTS.items():
        rows.append(("DOC_CH1_%s_TITLE" % doc_id[4:].upper(), title[0], title[1]))
        for n, (v, e) in enumerate(lines, 1):
            rows.append(("DOC_CH1_%s_%d" % (doc_id[4:].upper(), n), v, e))
    for pid, (title_key, title, _, _) in PUZZLES.items():
        rows.append((title_key, title[0], title[1]))

    # strings.csv: drop old rows of our prefixes, append fresh ones.
    path = os.path.join(ROOT, "game", "localization", "strings.csv")
    text = open(path, encoding="utf-8").read()
    kept = [line for line in text.split("\n") if line and not line.startswith(PREFIXES)]
    buf = io.StringIO()
    writer = csv.writer(buf, lineterminator="\n")
    seen = set(line.split(",", 1)[0] for line in kept)
    for row in rows:
        if row[0] in seen:
            raise SystemExit("duplicate key " + row[0])
        seen.add(row[0])
        writer.writerow(row)
    open(path, "w", encoding="utf-8", newline="\n").write("\n".join(kept) + "\n" + buf.getvalue())

    # Messages.
    mdir = os.path.join(ROOT, "game", "data", "messages")
    os.makedirs(mdir, exist_ok=True)
    for name in os.listdir(mdir):
        if name.startswith(("chat_ch1_", "choice_ch1_")) and name.endswith(".tres"):
            os.remove(os.path.join(mdir, name))
    for mid, body in messages.items():
        open(os.path.join(mdir, mid + ".tres"), "w", encoding="utf-8", newline="\n").write(body)

    # Documents and puzzle.
    ddir = os.path.join(ROOT, "game", "data", "documents")
    for doc_id, (style, title, lines) in DOCUMENTS.items():
        stem = doc_id[4:].upper()
        keys = ", ".join('"DOC_CH1_%s_%d"' % (stem, n) for n in range(1, len(lines) + 1))
        open(os.path.join(ddir, doc_id + ".tres"), "w", encoding="utf-8", newline="\n").write(
            '[gd_resource type="Resource" script_class="DocumentData" load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="res://scripts/core/document_data.gd" id="1_doc"]\n\n'
            '[resource]\nscript = ExtResource("1_doc")\nid = &"%s"\ntitle_key = "DOC_CH1_%s_TITLE"\nstyle = &"%s"\n'
            'source = &"%s"\nrule_ids = Array[StringName]([])\ntext_keys = Array[String]([%s])\n'
            % (doc_id, stem, style, doc_id, keys))
    pdir = os.path.join(ROOT, "game", "data", "puzzles")
    for pid, (title_key, _, solution, hint) in PUZZLES.items():
        open(os.path.join(pdir, pid + ".tres"), "w", encoding="utf-8", newline="\n").write(
            '[gd_resource type="Resource" script_class="PuzzleData" load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="res://scripts/core/puzzle_data.gd" id="1_puz"]\n\n'
            '[resource]\nscript = ExtResource("1_puz")\nid = &"%s"\nkind = &"combination"\ntitle_key = "%s"\n'
            'solution = "%s"\nlabel_keys = Array[String]([])\nhint_document = &"%s"\n' % (pid, title_key, solution, hint))

    # Readable script for review.
    out = ["# Kịch bản chương 1 \"Tổng tắc\"", "",
           "> **Bản nháp, chờ chủ dự án duyệt.** Sinh tự động từ `docs/design/ch1/build_ch1_script.py`; muốn sửa lời thì báo integrator (hoặc sửa file nguồn rồi chạy lại). Thiết kế: `docs/design/STORY.md` §5.",
           "",
           "Ký hiệu: **Loa** = loa trường · **Quản lý** · *(trong phòng)* = giọng nghe trực tiếp · 📞 = trong cuộc gọi nhóm · 💭 = suy nghĩ của Trung (chỉ phụ đề) · ▶ = lựa chọn của người chơi · `[…]` = diễn biến.",
           "",
           "## Nhân vật trong cuộc gọi",
           "| Tên | Phòng | Tính cách | Kết cục |", "|---|---|---|---|",
           "| Lý Minh Nhật | 203 nhà B | Bình tĩnh, giỏi phân tích, lập nhóm gọi | Sống (nhờ Trung) |",
           "| Hùng | 102 | Hay đùa, lạc quan | Trả lời \"có\": chết |",
           "| Đăng | 106 | Nóng nảy, chửi thề | Chết dù làm theo lời khuyên nào |",
           "| Bảo | 209 | Sợ hãi, hay khóc | Im lặng: vẫn chết |",
           "| Kiệt | 306 | Lo lắng, hay hỏi | Trả lời \"không có\": chết |",
           "| Vinh | 311 | Liều | Hô tên: chết |",
           "| Sơn | 504 | Trầm, ít nói | Trùm chăn: chết |",
           "| Tùng | 110 | Bốc đồng | Ra khỏi phòng ở vòng 1: chết |",
           "| Khương Ngọc Ngư | 401 nhà A | Gan dạ | Vào nhóm cuối chương |",
           ""]
    for kind, ident, who, clock, vi, en in SCRIPT:
        if kind == "section":
            out += ["## " + ident, ""]
            continue
        t = ("**%s** " % clock) if clock else ""
        if kind == "event":
            out.append("- %s`[%s]`" % (t, vi))
        elif kind in ("spk", "rule"):
            out.append("- %s**Loa:** %s" % (t, vi))
        elif kind == "mgr":
            out.append("- %s**Quản lý:** %s" % (t, vi))
        elif kind == "room":
            out.append("- %s**%s** *(trong phòng)*: %s" % (t, VOICES[who], vi))
        elif kind == "think":
            out.append("- %s💭 %s" % (t, vi))
        elif kind == "chat":
            out.append("- %s📞 **%s:** %s" % (t, NAMES[who][0], vi))
        elif kind == "choice":
            out.append("- %s▶ **Trung chọn:** %s" % (t, " / ".join("(%d) %s" % (n, v) for n, v in enumerate(vi, 1))))
        elif kind == "death":
            out.append("- **%s:** %s" % (ident, vi))
    out += ["", "## Giấy tờ đọc được trong phòng 407", ""]
    for doc_id, (style, title, lines) in DOCUMENTS.items():
        out.append("- **%s:** %s" % (title[0], " · ".join(v for v, _ in lines)))
    out.append("- **Tủ của Đạt:** mã `1407` (ngày sinh 14/07 trên thẻ sinh viên).")
    open(os.path.join(ROOT, "docs", "design", "CH1_SCRIPT.md"), "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    print("rows", len(rows), "messages", len(messages))


if __name__ == "__main__":
    main()
