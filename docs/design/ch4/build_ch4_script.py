"""Chapter 4 script: single source of truth (T-194, CH4_DESIGN.md, D-067).

Run from the repo root:  py -3 docs/design/ch4/build_ch4_script.py
It (re)writes:
  - the chapter-4 rows of game/localization/strings.csv (only keys made here),
  - game/data/messages/chat_ch4_*.tres (phone call lines),
  - game/data/rules/ch4.tres (rule book: General Rules and the rules of all five
    rounds, for the library's "Đối chiếu" tab),
  - docs/design/CH4_SCRIPT.md (readable script for the owner's review).
Edit the text here, never the generated files. Lines are written fresh for the
game, not copied from the source video (D-034). No hints (D-038, D-055): calls
report what the friends see, never what to do; Trung has no hint thoughts.

Kinds: spk = speaker; chat = phone call; near = a voice in the place (the
nurses); say = Trung speaks aloud (subtitle only, Trung is never voiced);
doc = readable paper; solved = a line of the rule book's "Đối chiếu" tab (how
the player got through a round, plain facts); event = what happens;
death = death reason; section = heading.
"""
import csv
import io
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))

NAMES = {
    "minh_nhat": ("Minh Nhật", "Minh Nhật"),
    "ngu": ("Ngọc Ngư", "Ngọc Ngư"),
    "trung": ("Tôi", "Me"),
}
VOICES = {"loa": "Loa trường", "nurse1": "Y tá 1", "nurse2": "Y tá 2", "trung": "Trung"}

SCRIPT = [
    ("section", "Mở đầu chương 4 — 8:30", "", "", "", ""),
    ("event", "", "", "08:30", "Tiếp ngay sau chương 3: ba người vừa tách nhau ở cửa nhà ăn. Ngư chạy về phía giảng đường, Minh Nhật về phía nhà thi đấu. Trung đứng ở cửa phía tây nhà ăn. Cuộc gọi nhóm vẫn mở. Checkpoint `ch4_split`.", ""),
    ("chat", "NGU_GO", "ngu", "08:30", "Giữ máy nhé. Có chuyện gì thì la lên.",
     "Keep the line open. Shout if anything happens."),
    ("chat", "N_GO", "minh_nhat", "08:30", "Thư viện nằm giữa giảng đường với sân vận động. Đi đường lớn, đừng chui vào lối hẹp.",
     "The library is between the lecture halls and the stadium. Stick to the main road, stay out of the narrow paths."),

    ("section", "Khu 1 — đường tới thư viện (8:30–8:40)", "", "", "", ""),
    ("event", "", "", "08:30", "Xác rải rác dọc đại lộ, thức khi Trung tới gần khoảng 25 m. Trung có thanh sắt mới (8 lần đánh). Tiếng còi cứu hộ rất nhỏ, to dần.", ""),
    ("chat", "NGU_LECTURE", "ngu", "08:31", "Tới giảng đường rồi. Nhiều cửa, nhiều dãy ghế, mình dụ chúng chạy vòng được.",
     "I'm at the lecture halls. Lots of doors, lots of rows of seats, I can lead them around in circles."),
    ("chat", "N_GYM", "minh_nhat", "08:34", "Nhà thi đấu rộng mà trống trơn. Toàn xác. Tôi đang núp sau khán đài.",
     "The gym is huge and empty. Nothing but them. I'm hiding behind the bleachers."),
    ("event", "", "", "08:38", "Cửa chính thư viện bị chặn bằng bàn ghế từ bên trong. Lối vào là cửa phụ phía sau; không ai chỉ (D-055).", ""),

    ("section", "Khu 2 — thư viện (8:40–8:50)", "", "", "", ""),
    ("event", "", "", "08:40", "Vào qua cửa phụ: checkpoint `ch4_library`. Đám xác dồn tới cửa phụ và bắt đầu đập (cửa chịu khoảng 75 giây).", ""),
    ("event", "", "", "08:40", "Thủ thư xác ngồi sau quầy bật dậy (jumpscare `librarian_rise`). Trên quầy có một thanh sắt.", ""),
    ("doc", "ch4_map", "", "08:41", "", ""),
    ("doc", "ch4_diary", "", "08:42", "", ""),
    ("event", "", "", "08:42", "Tầng 2: bàn đọc có sổ quy tắc mở sẵn. Tab Đối chiếu hiện luật cả 5 vòng và cạnh mỗi vòng là cách Trung đã qua. Gạch chân một dòng của luật vòng 5; sai không phạt, không gợi ý.", ""),
    ("solved", "R2", "", "", "Nằm lên giường của người đã chết, tắt hết đèn, nín thở. Ông ta chém nát giường trống.",
     "Lay on a dead roommate's bed, all lights off, held my breath. He hacked my empty bed apart."),
    ("solved", "R3", "", "", "Bịt miệng cả ba. Lặp một vòng từ cho tới hết giờ.",
     "Gagged all three. Looped one chain of words until time ran out."),
    ("solved", "R4", "", "", "Tìm ra quy luật nhiệt độ. Chỉ chọn Có ở những lượt an toàn.",
     "Worked out the temperature pattern. Said Yes only on the safe turns."),
    ("chat", "NGU_NO_EXIT", "ngu", "08:41", "Lạ thật. Cửa nào ở đây cũng thông ra ngoài, mà ra ngoài thì toàn xác. Chạy mãi chẳng thấy lối nào gọi là thoát.",
     "This is weird. Every door here leads outside, and outside it's all of them. I keep running and there's nothing you could call a way out."),
    ("chat", "N_LINE", "minh_nhat", "08:44", "Tôi đọc lại luật trong sổ. Có một câu cứ lấn cấn… mà nghĩ mãi chưa ra.",
     "I read the rules again. One line keeps bugging me… and I can't work out why."),
    ("chat", "NGU_TRUNG", "ngu", "08:47", "Trung? Cậu tới thư viện chưa? Còn nghe được không?",
     "Trung? Did you make it to the library? Can you still hear me?"),
    ("event", "", "", "08:47", "Tầng 3: cả dãy sách rơi (`books_fall`); một xác nằm trên kệ rơi xuống chân (`shelf_corpse`). Cửa phụ bị đập mạnh (`back_door_hit`).", ""),
    ("event", "", "", "08:48", "Gạch chân đúng dòng \"Hãy mau chạy khỏi góc khuất nguy hiểm này.\" thì sổ hiện ghi chú của chính Trung: \"Câu này thừa.\" Không ai nói gì thêm.", ""),

    ("section", "Khu 3 — về nhà B (8:50–8:55)", "", "", "", ""),
    ("event", "", "", "08:50", "Cửa phụ vỡ, xác tràn vào thư viện. Trung rời đi, quay về nhà B (khoảng 190 m), vào qua cửa sổ phòng quản lý (cúi). Checkpoint `ch4_return`.", ""),
    ("chat", "N_WHERE", "minh_nhat", "08:52", "Trung, chỗ cậu sao rồi? Bên tôi bắt đầu đông lên.",
     "Trung, how's it going there? It's getting crowded on my side."),
    ("event", "", "", "08:53", "Phòng quản lý: con dao trên bàn rút ra một mình, kèm tiếng kéo lê (jumpscare `knife_pull`).", ""),

    ("section", "Khu 4 — cầu thang chính (8:55–8:58)", "", "", "", ""),
    ("event", "", "", "08:55", "Cầu thang chính đầy xác chen chậm (3 con mỗi chiếu nghỉ). Ba cách qua: ném điện thoại (phím G) làm mồi, tối đa 3 lần; thanh sắt; từ tầng 2 đi ngang hành lang sang cầu thang thoát hiểm.", ""),
    ("event", "", "", "08:55", "Đặt chân lên bậc đầu: cả cầu thang quay đầu cùng lúc (`stairs_turn`).", ""),
    ("chat", "N_LOST", "minh_nhat", "08:56", "Trung? Trung ơi? Cậu đang ở…",
     "Trung? Trung? Where are y—"),
    ("event", "", "", "08:56", "Mất sóng. Tầng 4: hành lang trống, đèn tắt lần lượt từ cuối hành lang về phía Trung (`hall_lights`).", ""),

    ("section", "Khu 5 — phòng 407 (8:58–9:00)", "", "", "", ""),
    ("event", "", "", "08:58", "Vào 407, chốt cửa: checkpoint `ch4_407`. Xác đập cửa; cửa chịu 90 giây (nứt, thủng, rồi bàn tay thò qua lỗ `door_hand`).", ""),
    ("event", "", "", "08:58", "Ba chỗ tìm giả: tủ quần áo, tấm trần, ô thông gió. Không có gì.", ""),
    ("event", "", "", "08:59", "Lật vạt giường 1, 2, 4: mỗi vạt một mảnh chữ loang. Ghép ba mảnh thành Phiếu điều tra người sống sót sau thảm họa động đất. Ô họ tên để trống.", ""),
    ("event", "", "", "08:59", "Cắn ngón tay, viết \"Trần Trung\" vào ô họ tên trước khi cửa vỡ.", ""),
    ("event", "", "", "09:00", "Xác tràn vào rồi khựng lại, ngồi xổm tại chỗ. Một bàn tay đầy máu đặt lên cổ Trung rồi dừng (`neck_hand`). Loa cười một tiếng ngắn, lạnh.", ""),
    ("spk", "REGISTERED", "loa", "09:00", "Trần Trung đã đăng ký thành công. Bạn là người sống sót.",
     "Trần Trung has been registered. You are a survivor."),

    ("section", "Cảnh kết (9:00)", "", "", "", ""),
    ("event", "", "", "09:00", "Cơ thể Trung mờ dần. Điện thoại còn sáng: 12 giây để nhắn vào nhóm. Kết thật nếu tin nhắn chứa \"vạt giường\" (không phân biệt dấu, hoa thường).", ""),
    ("chat", "N_GOT", "minh_nhat", "09:00", "Vạt giường…? Trung? Trung!",
     "Bed slats…? Trung? Trung!"),
    ("event", "", "", "09:00", "(Chỉ ở kết thật: Minh Nhật kịp đọc tin.) Màn hình tối, tiếng máy theo dõi. Phòng bệnh viện, ánh sáng trắng.", ""),
    ("near", "NURSE1_AWAKE", "nurse1", "", "Tỉnh rồi! Cậu nằm yên, đừng cử động.",
     "He's awake! Lie still, don't move."),
    ("near", "NURSE2_QUAKE", "nurse2", "", "Động đất đó cậu. Trường cậu gần tâm chấn lắm, mấy tòa ký túc xá sập ngay lúc bốn giờ sáng.",
     "It was an earthquake. Your school was right by the epicentre. Several dormitories went down at four in the morning."),
    ("near", "NURSE1_LUCKY", "nurse1", "", "Lúc đào được cậu ra, cậu vẫn còn thở. Coi như nhặt lại được cái mạng.",
     "When they dug you out you were still breathing. You got your life back."),
    ("say", "TRUNG_ASK", "trung", "", "Còn… ai nữa không?", "Is there… anyone else?"),
    ("event", "", "", "", "Kết thật: hai giường bên cạnh có thẻ tên Lý Minh Nhật và Khương Ngọc Ngư.", ""),
    ("near", "NURSE2_ALL", "nurse2", "", "Hai bạn bên cạnh được đưa ra cùng đợt với cậu. Vẫn đang hôn mê, nhưng qua cơn nguy rồi.",
     "The two next to you came out with you. Still unconscious, but out of danger."),
    ("event", "", "", "", "Kết một mình: hai giường bên cạnh trống.", ""),
    ("near", "NURSE2_ALONE", "nurse2", "", "Tòa của cậu… chỉ có mình cậu ra được.",
     "Your building… you were the only one who made it out."),
    ("event", "", "", "", "Thẻ \"Hết chương 4\", lời cảm ơn, credits.", ""),

    ("section", "Lý do chết mới", "", "", "", ""),
    ("death", "CH4_GRABBED", "", "", "Xác sống đã tóm được bạn.", "A zombie got hold of you."),
    ("death", "CH4_STAIRS", "", "", "Bạn bị kẹt giữa đám xác trên cầu thang.", "You were caught in the crowd on the stairs."),
    ("death", "CH4_LIBRARY", "", "", "Cửa thư viện vỡ. Chúng tràn vào.", "The library door gave way. They poured in."),
    ("death", "CH4_DOOR", "", "", "Cánh cửa không trụ được nữa.", "The door couldn't hold any longer."),
]
# Papers (DocumentData at game/data/documents/<id>.tres): id -> style, title, lines.
DOCUMENTS = {
    "ch4_map": ("notice", ("SƠ ĐỒ KHUÔN VIÊN", "CAMPUS MAP"), [
        ("Giảng đường · Thư viện · Nhà thi đấu · Sân vận động · Nhà ăn · Cổng trường · Ký túc xá A · Ký túc xá B",
         "Lecture halls · Library · Gym · Stadium · Canteen · Main gate · Dormitory A · Dormitory B"),
        ("(Hai ô ký túc xá bị khoanh bút đỏ. Mực đã phai.)",
         "(The two dormitories are circled in red pen. The ink has faded.)"),
    ]),
    "ch4_diary": ("log", ("SỔ TRỰC THƯ VIỆN — ca đêm", "LIBRARY NIGHT LOG"), [
        ("3:52. Nước trong cốc gợn thành vòng. Chó ngoài cổng sủa mãi không thôi.",
         "3:52. The water in my cup rippled in rings. The dogs by the gate won't stop barking."),
        ("3:57. Đèn chớp hai lần. Ghi lại, sáng mai báo bảo trì.",
         "3:57. The lights flickered twice. Noted, report to maintenance in the morning."),
    ]),
}
# The rule book of chapter 4: General Rules and the rules of all five rounds
# (the library compares them). Fields copied from ch1, ch2 and ch3 rule sets.
RULE_LINES = [
    ("ch1_general_1", "RULE_CH1_GENERAL_1", "rules_heard", "obey"),
    ("ch1_general_2", "RULE_CH1_GENERAL_2", "new_rule", "old_rule_expires"),
    ("ch1_general_3", "RULE_CH1_GENERAL_3", "leave_room", "stay_in_room"),
    ("ch1_general_4", "RULE_CH1_GENERAL_4", "attack_staff", "never_attack"),
    ("ch1_general_5", "RULE_CH1_GENERAL_5", "each_hour", "survive_five_hours"),
    ("ch1_r2", "RULE_CH1_R2", "room_check", "stay_still_in_bed"),
    ("ch2_r3_1", "RULE_CH2_R3_1", "word_chain_turns", "all_four_play"),
    ("ch2_r3_2", "RULE_CH2_R3_2", "word_chain_match", "match_syllable"),
    ("ch2_r3_3", "RULE_CH2_R3_3", "word_chain_repeat", "no_repeat"),
    ("ch2_r4_1", "RULE_CH2_R4_1", "shower", "run_25_minutes"),
    ("ch3_r5_1", "RULE_CH3_R5_1", "round5_movement", "may_leave_room"),
    ("ch3_r5_2", "RULE_CH3_R5_2", "round5_corner", "run_from_corner"),
    ("ch3_r5_3", "RULE_CH3_R5_3", "round5_pursuit", "avoid_pursuit"),
]
# The redundant line of round 5 (D-067): the library's underline must pick it.
REDUNDANT_RULE = "ch3_r5_2"
UI_ROWS = [
    ("PROMPT_CH4_DESK", "Mở sổ quy tắc", "Open the rule book"),
    ("PROMPT_CH4_MAP", "Xem sơ đồ", "Look at the map"),
    ("PROMPT_CH4_DIARY", "Đọc sổ trực", "Read the night log"),
]
# Jumpscare ids core emits through EventBus.scare_triggered (lane E cues them).
SCARES = ["librarian_rise", "books_fall", "shelf_corpse", "back_door_hit", "knife_pull", "stairs_turn",
          "hall_lights", "door_hand", "neck_hand", "monitor_skip"]
RETIRED = set()
PREFIXES = ("SPK_CH4_", "CHAT_CH4_", "NEAR_CH4_", "SAY_CH4_", "DOC_CH4_", "NAME_CH4_", "PROMPT_CH4_",
            "DEATH_CH4_", "UI_CH4_SOLVED_")


def key_of(kind, ident):
    return {"spk": "SPK_CH4_", "chat": "CHAT_CH4_", "near": "NEAR_CH4_", "say": "SAY_CH4_",
            "doc": "DOC_CH4_", "solved": "UI_CH4_SOLVED_", "death": "DEATH_"}[kind] + ident


def minutes(clock):
    h, m = clock.split(":")
    return int(h) * 60 + int(m)


def tres_message(mid, sender, text_key, mins):
    return ('[gd_resource type="Resource" script_class="MessageData" load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="res://scripts/core/message_data.gd" id="1_msg"]\n\n'
            '[resource]\nscript = ExtResource("1_msg")\nid = &"%s"\nsender = &"%s"\nsender_name_key = "NAME_CH4_%s"\n'
            'text_key = "%s"\nminutes = %d\noutgoing = false\nspoken = true\n'
            % (mid, sender, sender.upper(), text_key, mins))


def main():
    rows, messages = [], {}
    for sid, (vi, en) in NAMES.items():
        rows.append(("NAME_CH4_" + sid.upper(), vi, en))
    for doc_id, (_style, (title_vi, title_en), lines) in DOCUMENTS.items():
        stem = "DOC_" + doc_id.upper()
        rows.append((stem + "_TITLE", title_vi, title_en))
        for n, (vi, en) in enumerate(lines, 1):
            rows.append(("%s_%d" % (stem, n), vi, en))
    for kind, ident, who, clock, vi, en in SCRIPT:
        if kind in ("section", "event", "doc"):
            continue
        key = key_of(kind, ident)
        # strings.csv writes a line break as the two characters backslash-n (Godot unescapes it).
        rows.append((key, vi.replace("\n", "\\n"), en.replace("\n", "\\n")))
        if kind == "chat":
            messages[key.lower()] = tres_message(key.lower(), who, key, minutes(clock))
    rows.extend(UI_ROWS)

    path = os.path.join(ROOT, "game", "localization", "strings.csv")
    text = open(path, encoding="utf-8").read()
    generated = {row[0] for row in rows}
    kept = [line for line in text.split("\n")
            if line and not (line.startswith(PREFIXES) and line.split(",", 1)[0] in generated | RETIRED)]
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
        if name.startswith("chat_ch4_") and name.endswith(".tres"):
            os.remove(os.path.join(mdir, name))
    for mid, body in messages.items():
        open(os.path.join(mdir, mid + ".tres"), "w", encoding="utf-8", newline="\n").write(body)

    ddir = os.path.join(ROOT, "game", "data", "documents")
    for doc_id, (style, _title, lines) in DOCUMENTS.items():
        stem = "DOC_" + doc_id.upper()
        keys = ", ".join('"%s_%d"' % (stem, n) for n in range(1, len(lines) + 1))
        open(os.path.join(ddir, doc_id + ".tres"), "w", encoding="utf-8", newline="\n").write(
            '[gd_resource type="Resource" script_class="DocumentData" load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="res://scripts/core/document_data.gd" id="1_doc"]\n\n'
            '[resource]\nscript = ExtResource("1_doc")\nid = &"%s"\ntitle_key = "%s_TITLE"\nstyle = &"%s"\n'
            'source = &"%s"\nrule_ids = Array[StringName]([])\ntext_keys = Array[String]([%s])\n'
            % (doc_id, stem, style, doc_id, keys))

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
    open(os.path.join(ROOT, "game", "data", "rules", "ch4.tres"), "w", encoding="utf-8", newline=nl).write(nl.join(body))

    out = ["# Kịch bản chương 4 \"Người sống sót\"", "",
           "> **Chờ chủ dự án duyệt lời.** Sinh tự động từ `docs/design/ch4/build_ch4_script.py`. Thiết kế: `docs/design/CH4_DESIGN.md` (D-067). Lời viết mới cho game, không chép nguyên văn video (D-034). Không có câu gợi ý (D-038, D-055).",
           "",
           "Ký hiệu: **Loa** · 📞 = trong cuộc gọi · 🗣 = nói tại chỗ (y tá) · 💬 = Trung nói (chỉ phụ đề) · 📄 = giấy đọc được · ✔ = dòng trong tab Đối chiếu · `[…]` = diễn biến.",
           "", "## Nhân vật",
           "| Tên | Ở đâu | Chương 4 |", "|---|---|---|",
           "| Trần Trung | thư viện, rồi phòng 407 | Một mình; nhận ra câu thừa, quay về, ký tên |",
           "| Lý Minh Nhật | nhà thi đấu | Chỉ nghe qua cuộc gọi (D-067) |",
           "| Khương Ngọc Ngư | giảng đường | Chỉ nghe qua cuộc gọi (D-067) |",
           "| Hai y tá | bệnh viện | Kể chuyện động đất |", ""]
    for kind, ident, who, clock, vi, en in SCRIPT:
        if kind == "section":
            out += ["", "## " + ident, ""]
            continue
        t = ("**%s** " % clock) if clock else ""
        line = vi.replace("\n", " / ")
        if kind == "event":
            out.append("- %s`[%s]`" % (t, line))
        elif kind == "spk":
            out.append("- %s**Loa:** %s" % (t, line))
        elif kind == "chat":
            out.append("- %s📞 **%s:** %s" % (t, NAMES[who][0], line))
        elif kind == "near":
            out.append("- %s🗣 **%s:** %s" % (t, VOICES[who], line))
        elif kind == "say":
            out.append("- %s💬 **Trung:** %s" % (t, line))
        elif kind == "doc":
            _style, (title_vi, _title_en), lines = DOCUMENTS[ident]
            out.append("- %s📄 **%s:** %s" % (t, title_vi, " / ".join(vi for vi, _en in lines)))
        elif kind == "solved":
            out.append("- ✔ **Đối chiếu, vòng %s:** %s" % (ident[1:], line))
        elif kind == "death":
            out.append("- **%s:** %s" % (ident, line))
    out += ["", "## Mã jumpscare (cho lane E)", "", ", ".join("`%s`" % s for s in SCARES),
            "", "## Dòng luật thừa (phán quyết của core)", "", "`%s`: \"Hãy mau chạy khỏi góc khuất nguy hiểm này.\"" % REDUNDANT_RULE]
    open(os.path.join(ROOT, "docs", "design", "CH4_SCRIPT.md"), "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    print("rows", len(rows), "messages", len(messages))


if __name__ == "__main__":
    main()
