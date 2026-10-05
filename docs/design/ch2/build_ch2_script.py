"""Chapter 2 script: single source of truth (T-170, CH2_DESIGN.md, D-046, D-047).

Run from the repo root:  python docs/design/ch2/build_ch2_script.py
It (re)writes:
  - the chapter-2 rows of game/localization/strings.csv (old ones of the same
    prefixes are replaced),
  - game/data/messages/chat_ch2_*.tres (call lines and Trung's replies),
  - game/data/ch2/word_bank.json (word chain: words, loop, opening, steering),
  - game/data/ch2/shower.json (temperatures, rule, numbers),
  - game/data/rules/ch2.tres (rule book: General Rules + rounds 3 and 4),
  - docs/design/CH2_SCRIPT.md (readable script for the owner's review).
Edit the text here (and the words in word_bank.py), never the generated files.
"""
import csv
import io
import json
import os
import sys
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, HERE)
sys.dont_write_bytecode = True
import word_bank as wb  # noqa: E402

NAMES = {
    "minh_nhat": ("Minh Nhật · 203", "Minh Nhật · 203"),
    "ngu": ("Ngọc Ngư · 401 nhà A", "Ngọc Ngư · A-401"),
    "trung": ("Tôi", "Me"),
}
VOICES = {"loa": "Loa trường", "phuc": "Xác Phúc", "viet": "Xác Việt", "dat": "Xác Đạt", "trung": "Trung (suy nghĩ, chỉ phụ đề)"}

# kind: spk, rule, room, think, chat, choice, event, death, section (as chapter 1).
SCRIPT = [
    ("section", "Mở đầu chương 2 — 6:00", "", "", "", ""),
    ("event", "", "", "06:00", "Tiếp ngay sau chương 1: Trung nằm trên giường của bạn đã chết, cuộc gọi với Minh Nhật và Ngư vẫn mở. Checkpoint `ch2_r3`.", ""),
    ("spk", "R2_END", "loa", "06:00", "Quy tắc vòng hai kết thúc. Số người sống sót hiện tại: hai mươi tám người.",
     "Round two is over. Students still alive: twenty-eight."),
    ("chat", "N_28", "minh_nhat", "06:00", "Hai mươi tám… Cả trường mấy nghìn người mà còn hai mươi tám.",
     "Twenty-eight… Thousands of students, and twenty-eight left."),
    ("spk", "R3_INTRO", "loa", "06:00", "Công việc kiểm tra phòng kết thúc. Đến giờ giải trí rồi. Chúng ta chơi nối từ nhé.",
     "The room check is over. Time for some fun. Let's play a word chain."),
    ("rule", "R3_1", "loa", "06:01", "Bốn người trong mỗi phòng bắt buộc tham gia. Nối lần lượt theo chiều kim đồng hồ, mỗi lượt dưới mười lăm giây.",
     "All four people in each room must play. Take turns clockwise, under fifteen seconds a turn."),
    ("rule", "R3_2", "loa", "06:01", "Từ nối là từ hai tiếng. Tiếng đầu phải trùng tiếng cuối của từ trước, đúng cả dấu.",
     "Each word has two syllables. Its first syllable must match the last syllable of the word before, tone and all."),
    ("rule", "R3_3", "loa", "06:01", "Trong ba lượt liền nhau không được lặp từ. Ai không nối được, chết.",
     "No word may repeat within three turns in a row. Whoever cannot go on, dies."),
    ("chat", "NGU_FOUR", "ngu", "06:01", "Bốn người? Phòng mình chỉ còn mỗi mình sống mà…",
     "Four people? I'm the only one alive in my room…"),
    ("event", "", "", "06:02", "Ba xác Phúc, Việt, Đạt cùng ngồi dậy trong vũng máu, mắt trống rỗng, quay về phía Trung (jumpscare 1). Lời của xác là giọng méo, không có trong cuộc gọi.", ""),
    ("chat", "N_SAT_UP", "minh_nhat", "06:02", "Bạn cùng phòng tôi… ngồi dậy rồi. Nó đang nhìn tôi.",
     "My roommates… they sat up. They're looking at me."),
    ("chat", "NGU_SAT_UP", "ngu", "06:02", "Bên mình cũng vậy. Ba đứa. Mắt trắng dã.",
     "Same here. All three. Their eyes are white."),
    ("event", "", "", "06:02", "Lượt mở đầu cố định (N1). Phúc: \"điểm danh\". Việt: \"danh sách\". Đạt: \"sách vở\", rồi quay sang nhìn Trung. Trung có 15 giây, chỉ có một từ đúng: \"vở kịch\".", ""),
    ("think", "VO", "trung", "06:02", "Vở… vở gì… nghĩ đi…", "Vở… vở what… think…"),
    ("event", "", "", "06:03", "Từ đây trò chơi chạy liên tục tới 7:00. Mỗi lượt của Trung: 4 phương án, 15 giây. Chọn sai hoặc hết giờ thì chết (DEATH_CH2_CHAIN_WRONG / DEATH_CH2_CHAIN_TIMEOUT). Ở nhà vệ sinh hoặc ban công thì không trả lời được.", ""),
    ("chat", "N_KEEP_UP", "minh_nhat", "06:04", "Đừng nghĩ lâu. Mười lăm giây trôi nhanh lắm.",
     "Don't think too long. Fifteen seconds goes fast."),

    ("section", "Vòng 3 — 6:05 đến 7:00: nối từ", "", "", "", ""),
    ("event", "", "", "06:06", "Lần đầu một xác bí lời (do Trung gài từ cụt hoặc do bị bịt miệng): xác ú ớ hết 15 giây, gục xuống, 10 giây sau bật dậy và bắt đầu chuỗi mới (jumpscare 3).", ""),
    ("chat", "NGU_CHEAT", "ngu", "06:08", "Nó gục rồi lại ngồi dậy… Chúng nó chết rồi thì sợ gì thua. Chỉ có tụi mình là không được sai.",
     "It fell and sat right back up… They're already dead, losing means nothing to them. We're the only ones who can't slip."),
    ("chat", "N_HOUR", "minh_nhat", "06:09", "Một tiếng. Tụi mình phải đúng suốt một tiếng.",
     "An hour. We have to be right for a whole hour."),
    ("event", "", "", "06:12", "Camera an ninh (D-046): điện thoại rung, CAM 310. Sinh viên phòng 310 im lặng quá 15 giây; ba xác cùng lao vào (jumpscare 4).", ""),
    ("chat", "N_310", "minh_nhat", "06:12", "Phòng 310… Cậu ấy không nói kịp. Đừng nhìn nữa.",
     "Room 310… He didn't answer in time. Don't watch."),
    ("event", "", "", "06:20", "N3: Ngư kể nửa đầu manh mối (D-046). Không ai nói tiếp ý \"bịt miệng\".", ""),
    ("chat", "NGU_CLUE", "ngu", "06:20", "Mình vừa nối vừa kéo tay đứa cùng phòng. Nó chẳng phản ứng gì, chỉ lo nối từ.",
     "I tugged my roommate's arm while we played. It didn't react at all, it just kept chaining words."),
    ("chat", "N_BRAVE", "minh_nhat", "06:20", "Cậu… gan thật đấy.", "You're… really brave."),
    ("event", "", "", "06:20", "Giẻ lau (nhà vệ sinh), khăn tắm (ban công), áo của Việt (tủ Việt). Cầm một món, tới sát xác, bấm E: bịt miệng (N4). Bịt lúc xác đang nói thì nó quay sang nhìn chằm chằm (jumpscare 2).", ""),
    ("event", "", "", "06:35", "N5: Minh Nhật gửi vòng lặp vào nhóm (giữ trong lịch sử chat). Chỉ có ích khi cả ba xác đã bị bịt: khi đó chuỗi chỉ còn từ của Trung.", ""),
    ("chat", "N_LOOP", "minh_nhat", "06:35", "Tôi nghĩ ra một vòng không bao giờ hết: học sinh, sinh viên, viên phấn, phấn đấu, đấu tranh, tranh luận, luận văn, văn học… rồi lại học sinh. Lái về chữ \"học\" rồi cứ thế lặp.",
     "I found a loop that never ends: học sinh, sinh viên, viên phấn, phấn đấu, đấu tranh, tranh luận, luận văn, văn học… and back to học sinh. Steer to \"học\" and repeat."),
    ("chat", "NGU_LOOP", "ngu", "06:36", "Không cần nghĩ nữa. Cứ lặp thôi.", "No more thinking. Just repeat it."),
    ("event", "", "", "06:40", "Đi trọn một vòng 8 từ (cả ba xác đã bị bịt) thì cắt thời gian trống, nhảy tới 7:00 (D-040).", ""),
    ("chat", "N_FEW", "minh_nhat", "06:50", "Nhóm im hết rồi. Chỉ còn tín hiệu của ba đứa mình.",
     "The group's gone quiet. Only our three signals left."),

    ("section", "7:00 — hết vòng 3", "", "", "", ""),
    ("spk", "R3_END", "loa", "07:00", "Quy tắc vòng ba kết thúc. Số người sống sót hiện tại: năm người.",
     "Round three is over. Students still alive: five."),
    ("event", "", "", "07:00", "Ba xác gục xuống giường. Checkpoint `ch2_r4`.", ""),
    ("chat", "NGU_FIVE", "ngu", "07:00", "Năm người… Cả trường còn năm người.", "Five… The whole school, five people."),

    ("section", "Vòng 4 — 7:00 đến 8:00: tắm nước nóng", "", "", "", ""),
    ("spk", "R4_INTRO", "loa", "07:00", "Trò chơi gắn kết tình bạn kết thúc. Đến giờ tắm nước nóng cho thoải mái rồi.",
     "The friendship game is over. Time for a nice hot shower."),
    ("rule", "R4_1", "loa", "07:01", "Mời mọi người vào nhà vệ sinh. Vòng này không có yêu cầu nào khác: chỉ cần thời gian xả nước vượt quá hai mươi lăm phút.",
     "Everyone, please go to your bathroom. No other requirement this round: the water must run for more than twenty-five minutes."),
    ("spk", "R4_ENJOY", "loa", "07:01", "Chúc các bạn tắm vui vẻ.", "Enjoy your shower."),
    ("event", "", "", "07:01", "N6: cửa nhà vệ sinh kẹt. Đẩy vai 3 lần; lần 3 cửa bật mở, hơi nóng phụt ra (jumpscare 5).", ""),
    ("think", "DOOR", "trung", "07:01", "Kẹt rồi… cửa phồng hết lên.", "It's stuck… the door's all swollen."),
    ("event", "", "", "07:02", "Vòi sen mất công tắc, thay bằng màn hình (UI_CH2_SHOWER_RULE). 30 lượt, mỗi lượt 2 phút trong game. Chọn Có thì phải đứng trong buồng tắm cả lượt; từ 50 độ là chết bỏng (DEATH_CH2_SCALDED); bước ra là chết (DEATH_CH2_SHOWER_BROKEN); không chọn là chết (DEATH_CH2_NO_CHOICE). Tới 8:00 chưa đủ 25 phút là chết (DEATH_CH2_SHORT_SHOWER).", ""),
    ("chat", "NGU_MUST", "ngu", "07:02", "Nghĩa là nếu chọn xả, bao nhiêu độ cũng phải đứng chịu hai phút.",
     "So if we pick yes, we stand under it for two minutes whatever the temperature."),
    ("chat", "N_WAIT", "minh_nhat", "07:02", "Khoan xả đã. Xem nó ra số gì.", "Don't run it yet. Let's see what numbers it gives."),
    ("event", "", "", "07:04", "Không ai nói quy luật (D-046). Màn hình giữ toàn bộ lịch sử nhiệt độ. Dãy: 67, 37, 8, 81, 96, 58, 37, 1, 19, 4, 43, 74, 19, 9, 94, 35, 86, 41, 52, 79, 63, 94, 31, 45, 91, 7, 71, 83, 13, 42.", ""),
    ("chat", "N_SEVENTY", "minh_nhat", "07:04", "Sáu mươi bảy độ… Chọn bừa là chín người.", "Sixty-seven degrees… Pick at random and you're cooked."),
    ("chat", "NGU_PATTERN", "ngu", "07:10", "Không thể là ngẫu nhiên. Luật nào cũng có kẽ hở, mấy vòng trước đều vậy.",
     "It can't be random. Every rule had a way out so far."),
    ("chat", "N_STEAM", "minh_nhat", "07:20", "Hơi nước mù hết màn hình rồi. Lau đi mà đọc.", "Steam's all over the screen. Wipe it to read."),
    ("event", "", "", "07:40", "N10: gọi cứu Ngư. Dãy của Ngư: 74, 15, 62. Lượt tới là 8x độ: phải chọn Không. Có 10 giây; sai thì Ngư chết và Trung thua (DEATH_CH2_LOST_NGU) (jumpscare 8).", ""),
    ("chat", "NGU_HELP", "ngu", "07:40", "Loa điện thoại mình bị nước vào rồi… Trung! Ba lần gần nhất bên mình: bảy mươi tư, mười lăm, sáu mươi hai. Lượt tới chọn gì? Nhanh lên!",
     "Water got into my phone… Trung! My last three: seventy-four, fifteen, sixty-two. What do I pick next? Hurry!"),
    ("choice", "NGU", "trung", "07:40",
     ["Đừng xả. Chọn Không.", "Xả đi. Chọn Có."],
     ["Don't run it. Pick no.", "Run it. Pick yes."]),
    ("chat", "NGU_SAVED", "ngu", "07:41", "…Tám mươi mốt độ. Cảm ơn… cảm ơn cậu, Trung.", "…Eighty-one degrees. Thank you… thank you, Trung."),
    ("chat", "NGU_SCREAM", "ngu", "07:41", "Nóng! Nóng quá… Trung…!", "It burns! It burns… Trung…!"),

    ("section", "8:00 — hết chương 2", "", "", "", ""),
    ("spk", "R4_END", "loa", "08:00", "Quy tắc vòng bốn kết thúc. Số người sống sót hiện tại: ba người.",
     "Round four is over. Students still alive: three."),
    ("chat", "N_THREE", "minh_nhat", "08:00", "Ba người. Cả trường… chỉ còn ba đứa mình.", "Three. The whole school… just the three of us."),
    ("think", "END", "trung", "08:00", "Còn một giờ nữa.", "One more hour."),

    ("section", "Lý do chết mới", "", "", "", ""),
    ("death", "CH2_CHAIN_WRONG", "", "", "Bạn đã nối sai.", "You chained the wrong word."),
    ("death", "CH2_CHAIN_TIMEOUT", "", "", "Bạn không nối kịp trong mười lăm giây.", "You didn't answer within fifteen seconds."),
    ("death", "CH2_SCALDED", "", "", "Nước sôi xối xuống người bạn.", "Boiling water poured over you."),
    ("death", "CH2_SHOWER_BROKEN", "", "", "Bạn đã chọn xả nước nhưng bước ra khỏi buồng tắm.", "You chose to run the water, then stepped out."),
    ("death", "CH2_NO_CHOICE", "", "", "Bạn không chọn khi đồng hồ đếm hết.", "You didn't choose before the countdown ended."),
    ("death", "CH2_SHORT_SHOWER", "", "", "Tới tám giờ, bạn vẫn chưa tắm đủ hai mươi lăm phút.", "At eight, you hadn't showered for twenty-five minutes."),
    ("death", "CH2_LOST_NGU", "", "", "Ngọc Ngư đã chết vì lời khuyên của bạn.", "Ngọc Ngư died because of your advice."),
]

RULE_LINES = [
    ("ch1_general_1", "RULE_CH1_GENERAL_1", "rules_heard", "obey"),
    ("ch1_general_2", "RULE_CH1_GENERAL_2", "new_rule", "old_rule_expires"),
    ("ch1_general_3", "RULE_CH1_GENERAL_3", "leave_room", "stay_in_room"),
    ("ch1_general_4", "RULE_CH1_GENERAL_4", "attack_staff", "never_attack"),
    ("ch1_general_5", "RULE_CH1_GENERAL_5", "each_hour", "survive_five_hours"),
    ("ch2_r3_1", "RULE_CH2_R3_1", "word_chain", "all_four_play"),
    ("ch2_r3_2", "RULE_CH2_R3_2", "word_chain", "match_syllable"),
    ("ch2_r3_3", "RULE_CH2_R3_3", "word_chain", "no_repeat"),
    ("ch2_r4_1", "RULE_CH2_R4_1", "shower", "run_25_minutes"),
]
UI_ROWS = [
    ("UI_CH2_END", "Hết chương 2", "End of chapter 2"),
    ("UI_CH2_SHOWER_RULE", "Chọn có xả nước trong 2 phút tới hay không. Đã chọn thì bắt buộc làm theo. Nếu không, chết.",
     "Run the water for the next 2 minutes? Whatever you choose, you must do it. Otherwise, you die."),
    ("UI_CH2_SHOWER_YES", "CÓ", "YES"),
    ("UI_CH2_SHOWER_NO", "KHÔNG", "NO"),
    ("UI_CH2_SHOWER_TEMP", "Nhiệt độ: %d °C", "Temperature: %d °C"),
    ("UI_CH2_SHOWER_PROGRESS", "Đã tắm %d/25 phút", "Showered %d/25 min"),
    ("UI_CH2_CHAIN_DEAF", "Họ không nghe thấy bạn", "They can't hear you"),
    ("PROMPT_CH2_TAKE_RAG", "Lấy giẻ lau", "Take the rag"),
    ("PROMPT_CH2_TAKE_TOWEL", "Lấy khăn tắm", "Take the towel"),
    ("PROMPT_CH2_TAKE_SHIRT", "Lấy áo của Việt", "Take Việt's shirt"),
    ("PROMPT_CH2_GAG", "Bịt miệng", "Gag"),
    ("PROMPT_CH2_BASH_DOOR", "Đẩy cửa", "Shove the door"),
    ("PROMPT_CH2_WIPE", "Lau màn hình", "Wipe the screen"),
    ("CCTV_CH2_CAM_310", "CAM 310 · nhà B", "CAM 310 · Bldg B"),
    ("CCTV_CH2_CAM_HALL_310", "CAM T3 · hành lang 310", "CAM F3 · corridor 310"),
]
SHOWER = {
    "player": [67, 37, 8, 81, 96, 58, 37, 1, 19, 4, 43, 74, 19, 9, 94, 35, 86, 41, 52, 79, 63, 94, 31, 45, 91, 7, 71, 83, 13, 42],
    "ngu_history": [74, 15, 62], "ngu_next": 81, "ngu_slot": 20,
    "lethal": 50, "cold": 10, "slot_minutes": 2, "need_minutes": 25,
}
PREFIXES = ("SPK_CH2_", "RULE_CH2_", "ROOM_CH2_", "THINK_CH2_", "CHAT_CH2_", "CHOICE_CH2_", "NAME_CH2_", "UI_CH2_",
            "PROMPT_CH2_", "WORD_CH2_", "DEATH_CH2_", "CCTV_CH2_")


def key_of(kind, ident, n=None):
    base = {"spk": "SPK_CH2_", "rule": "RULE_CH2_", "room": "ROOM_CH2_", "think": "THINK_CH2_",
            "chat": "CHAT_CH2_", "choice": "CHOICE_CH2_", "death": "DEATH_"}[kind] + ident
    return base if n is None else "%s_%d" % (base, n)


def slug(word):
    flat = unicodedata.normalize("NFD", word.replace("đ", "d").replace("Đ", "D"))
    return "".join(c for c in flat if unicodedata.category(c) != "Mn").upper().replace(" ", "_")


def word_keys():
    keys, used = {}, {}
    for word in sorted(set(wb.BANK) | set(wb.TRAPS)):
        base = "WORD_CH2_" + slug(word)
        used[base] = used.get(base, 0) + 1
        keys[word] = base if used[base] == 1 else "%s_%d" % (base, used[base])
    return keys


def check_shower():
    seq = SHOWER["player"]
    problems = []
    for a, b in zip(seq, seq[1:]):
        if b // 10 != (a // 10 + a % 10) % 10:
            problems.append("rule broken at %d -> %d" % (a, b))
    h = SHOWER["ngu_history"] + [SHOWER["ngu_next"]]
    for a, b in zip(h, h[1:]):
        if b // 10 != (a // 10 + a % 10) % 10:
            problems.append("Ngư rule broken at %d -> %d" % (a, b))
    safe_after = sum(1 for t in seq[6:] if t < SHOWER["lethal"])
    if safe_after * SHOWER["slot_minutes"] < SHOWER["need_minutes"] + SHOWER["slot_minutes"]:
        problems.append("no spare slot after slot 6 (%d safe)" % safe_after)
    return problems


def minutes(clock):
    h, m = clock.split(":")
    return int(h) * 60 + int(m)


def tres_message(mid, sender, text_key, mins, outgoing, spoken):
    return ('[gd_resource type="Resource" script_class="MessageData" load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="res://scripts/core/message_data.gd" id="1_msg"]\n\n'
            '[resource]\nscript = ExtResource("1_msg")\nid = &"%s"\nsender = &"%s"\nsender_name_key = "NAME_CH2_%s"\n'
            'text_key = "%s"\nminutes = %d\noutgoing = %s\nspoken = %s\n'
            % (mid, sender, sender.upper(), text_key, mins, "true" if outgoing else "false", "true" if spoken else "false"))


def main():
    problems = wb.check() + check_shower()
    if problems:
        raise SystemExit("\n".join(problems))
    rows, messages = [], {}
    for sid, (vi, en) in NAMES.items():
        rows.append(("NAME_CH2_" + sid.upper(), vi, en))
    for kind, ident, who, clock, vi, en in SCRIPT:
        if kind in ("section", "event"):
            continue
        if kind == "choice":
            for n, (v, e) in enumerate(zip(vi, en), 1):
                key = key_of(kind, ident, n)
                rows.append((key, v, e))
                messages[key.lower()] = tres_message(key.lower(), "trung", key, minutes(clock), True, False)
            continue
        key = key_of(kind, ident)
        rows.append((key, vi, en))
        if kind == "chat":
            messages[key.lower()] = tres_message(key.lower(), who, key, minutes(clock), False, True)
    keys = word_keys()
    for word, key in keys.items():
        gloss = wb.BANK.get(word) or wb.TRAPS.get(word)
        rows.append((key, word, "%s (%s)" % (word, gloss)))
    rows.extend(UI_ROWS)

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

    mdir = os.path.join(ROOT, "game", "data", "messages")
    for name in os.listdir(mdir):
        if name.startswith(("chat_ch2_", "choice_ch2_")) and name.endswith(".tres"):
            os.remove(os.path.join(mdir, name))
    for mid, body in messages.items():
        open(os.path.join(mdir, mid + ".tres"), "w", encoding="utf-8", newline="\n").write(body)

    # Word chain data for the director (T-170).
    table = wb.starts()
    steer = {}
    dist = wb.steer_distances()
    for syllable, words in table.items():
        live = [w for w in words if w not in wb.DEAD and dist.get(w) is not None]
        if live:
            steer[syllable] = keys[min(live, key=lambda w: (dist[w], w))]
    data = {
        "words": {keys[w]: {"text": w, "first": wb.syllables(w)[0], "last": wb.syllables(w)[1],
                            "dead": w in wb.DEAD} for w in sorted(wb.BANK)},
        "traps": {keys[w]: {"text": w, "first": wb.syllables(w)[0], "last": wb.syllables(w)[1]} for w in sorted(wb.TRAPS)},
        "loop": [keys[w] for w in wb.LOOP],
        "opening": [keys[w] for w in wb.OPENING],
        "steer": steer,
        "seconds": 15.0,
        "options": 4,
        "no_repeat_window": 3,
    }
    ddir = os.path.join(ROOT, "game", "data", "ch2")
    os.makedirs(ddir, exist_ok=True)
    json.dump(data, open(os.path.join(ddir, "word_bank.json"), "w", encoding="utf-8", newline="\n"), ensure_ascii=False, indent=1)
    json.dump(SHOWER, open(os.path.join(ddir, "shower.json"), "w", encoding="utf-8", newline="\n"), ensure_ascii=False, indent=1)

    nl = "\n"
    body = ['[gd_resource type="Resource" script_class="RuleSet" load_steps=%d format=3]%s' % (len(RULE_LINES) + 3, nl),
            '[ext_resource type="Script" path="res://scripts/core/rule_set.gd" id="1_set"]',
            '[ext_resource type="Script" path="res://scripts/core/rule_data.gd" id="2_rule"]' + nl]
    for rid, key, situation, action in RULE_LINES:
        body.append(nl.join([
            '[sub_resource type="Resource" id="Rule_%s"]' % rid, 'script = ExtResource("2_rule")', 'id = &"%s"' % rid,
            'text_key = "%s"' % key, "is_fake = false", 'source = &"speaker"', 'situation = &"%s"' % situation,
            'action = &"%s"' % action, "penalty = 0", 'consequence = &""', "fatal = false", ""]))
    body.append(nl.join(["[resource]", 'script = ExtResource("1_set")',
                         'rules = Array[ExtResource("2_rule")]([%s])' % ", ".join('SubResource("Rule_%s")' % r[0] for r in RULE_LINES), ""]))
    open(os.path.join(ROOT, "game", "data", "rules", "ch2.tres"), "w", encoding="utf-8", newline=nl).write(nl.join(body))

    out = ["# Kịch bản chương 2 \"Trò chơi\"", "",
           "> **Bản nháp chờ chủ dự án duyệt.** Sinh tự động từ `docs/design/ch2/build_ch2_script.py` (từ nối ở `word_bank.py`). Thiết kế: `docs/design/CH2_DESIGN.md` (D-046, D-047).",
           "",
           "Ký hiệu: **Loa** · *(trong phòng)* = giọng nghe trực tiếp · 📞 = trong cuộc gọi · 💭 = suy nghĩ của Trung (chỉ phụ đề) · ▶ = lựa chọn · `[…]` = diễn biến.",
           "", "## Nhân vật trong cuộc gọi",
           "| Tên | Ở đâu | Kết cục chương 2 |", "|---|---|---|",
           "| Lý Minh Nhật | 203 nhà B | Sống |",
           "| Khương Ngọc Ngư | 401 nhà A | Sống nếu Trung khuyên đúng lúc 7:40 |", ""]
    for kind, ident, who, clock, vi, en in SCRIPT:
        if kind == "section":
            out += ["", "## " + ident, ""]
            continue
        t = ("**%s** " % clock) if clock else ""
        if kind == "event":
            out.append("- %s`[%s]`" % (t, vi))
        elif kind in ("spk", "rule"):
            out.append("- %s**Loa:** %s" % (t, vi))
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
    out += ["", "## Kho từ nối (%d từ, %d từ cụt, %d từ bẫy)" % (len(wb.BANK), len(wb.DEAD), len(wb.TRAPS)), "",
            "- **Mở đầu:** " + " → ".join(wb.OPENING) + " → *(Trung)* vở kịch",
            "- **Vòng lặp của Minh Nhật:** " + " → ".join(wb.LOOP) + " → học sinh …",
            "- **Từ cụt (gài bẫy xác, N2):** " + ", ".join(sorted(wb.DEAD)),
            "- **Từ bẫy (không bao giờ đúng):** " + ", ".join(sorted(wb.TRAPS)),
            "- **Kiểm tra tự động:** mọi từ (trừ từ cụt) đều nối tiếp được và lái về được vòng lặp; xa nhất %d lượt." % max(d for d in wb.steer_distances().values() if d is not None),
            "", "<details><summary>Toàn bộ kho từ</summary>", "",
            ", ".join(sorted(w for w in wb.BANK if w not in wb.DEAD)), "", "</details>", "",
            "## Vòng 4: nhiệt độ", "",
            "- **Quy luật (không ai nói ra, D-046):** hàng chục lần sau = hàng đơn vị của tổng hai chữ số lần trước.",
            "- **Dãy của Trung (30 lượt):** " + ", ".join(str(t) for t in SHOWER["player"]),
            "- **Dãy của Ngư (7:40):** %s → lượt tới %d độ (phải khuyên Không)." % (", ".join(str(t) for t in SHOWER["ngu_history"]), SHOWER["ngu_next"]),
            "- Từ 50 độ là chết bỏng; cần 25 phút (13 lượt Có an toàn); sau lượt 6 còn %d lượt an toàn." % sum(1 for t in SHOWER["player"][6:] if t < SHOWER["lethal"])]
    open(os.path.join(ROOT, "docs", "design", "CH2_SCRIPT.md"), "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    print("rows", len(rows), "messages", len(messages), "words", len(keys))


if __name__ == "__main__":
    main()
