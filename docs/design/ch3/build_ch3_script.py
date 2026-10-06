"""Chapter 3 script: single source of truth (T-181, CH3_DESIGN.md, D-052…D-054).

Run from the repo root:  py -3 docs/design/ch3/build_ch3_script.py
It (re)writes:
  - the chapter-3 rows of game/localization/strings.csv (only keys made here),
  - game/data/messages/chat_ch3_*.tres (phone call lines),
  - game/data/rules/ch3.tres (rule book: General Rules + round 5),
  - docs/design/CH3_SCRIPT.md (readable script for the owner's review).
Edit the text here, never the generated files. Lines are written fresh for the
game, not copied from the source video (D-034).

Kinds: spk/rule = speaker; chat = phone call; near = said in person by a
companion walking with Trung (voiced at the companion); room = a voice in the
place (the canteen TV); think = Trung's thought (subtitle only); event = what
happens; death = death reason; section = heading.
"""
import csv
import io
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))

NAMES = {
    "minh_nhat": ("Minh Nhật · 203", "Minh Nhật · 203"),
    "ngu": ("Ngọc Ngư · 401 nhà A", "Ngọc Ngư · A-401"),
    "trung": ("Tôi", "Me"),
}
VOICES = {"loa": "Loa trường", "tv": "Tivi nhà ăn", "trung": "Trung (suy nghĩ, chỉ phụ đề)"}

SCRIPT = [
    ("section", "Mở đầu chương 3 — 8:00", "", "", "", ""),
    ("event", "", "", "08:00", "Tiếp ngay sau chương 2: Trung trong phòng 407, cuộc gọi với Minh Nhật và Ngư vẫn mở. Checkpoint `ch3_b`.", ""),
    ("spk", "R5_INTRO", "loa", "08:00", "Vòng cuối cùng bắt đầu. Nhà trường quyết định nới lỏng yêu cầu.",
     "The final round begins. The school has decided to relax its requirements."),
    ("rule", "R5_1", "loa", "08:00", "Các bạn được phép rời phòng, đi lại ở mọi khu vực trong trường.",
     "You may leave your rooms and go anywhere on campus."),
    ("rule", "R5_2", "loa", "08:00", "Hãy mau chạy khỏi góc khuất nguy hiểm này.",
     "Hurry and run from this dangerous corner."),
    ("rule", "R5_3", "loa", "08:01", "Nhiệm vụ rất đơn giản: trong một giờ cuối cùng, tránh mọi sự truy sát và sống sót.",
     "Your task is simple: for this last hour, avoid every pursuit and stay alive."),
    ("think", "WHO", "trung", "08:01", "Truy sát…? Ai truy sát?", "Pursuit…? Who's pursuing?"),
    ("event", "", "", "08:01", "Ba xác Phúc, Việt, Đạt bật dậy, mắt đỏ sẫm, đứng lên chậm chạp giữa hai dãy giường (jumpscare 1, `roommates_rise`).", ""),
    ("chat", "N_ALL_UP", "minh_nhat", "08:01", "Chúng nó đứng dậy hết rồi! Cả tòa… hành lang chỗ tôi toàn người, mắt đỏ lòm.",
     "They're all up! The whole building… my corridor is full of them, red eyes."),
    ("chat", "N_OUT", "minh_nhat", "08:01", "Luật cấm rời phòng bị bỏ rồi. Ba đứa mình phải ra ngoài, gặp nhau.",
     "The rule about staying in is gone. The three of us have to get out and meet."),
    ("chat", "NGU_GARDEN", "ngu", "08:02", "Vườn hoa giữa nhà A với nhà B. Gặp ở đó. Chúng nó chậm lắm, đừng để bị dồn vào chỗ hẹp là được.",
     "The garden between building A and B. Meet there. They're slow, just don't get cornered somewhere narrow."),
    ("think", "RUN", "trung", "08:02", "Ra khỏi đây. Ngay.", "Get out. Now."),

    ("section", "Khu 1 — nhà B, tầng 4 xuống tầng 1 (8:02–8:10)", "", "", "", ""),
    ("event", "", "", "08:02", "N1: lách qua ba xác ra cửa. Đóng cửa 407 sau lưng thì chúng đập cửa khoảng 10 giây.", ""),
    ("event", "", "", "08:02", "Mở cửa ra hành lang: hàng chục bóng người mắt đỏ cùng quay đầu (jumpscare 2, `corridor_turn`).", ""),
    ("think", "STAIRS_FULL", "trung", "08:03", "Cầu thang chính kín rồi… Đầu kia còn cầu thang thoát hiểm.",
     "The main stairs are packed… There's the fire stairs at the other end."),
    ("event", "", "", "08:03", "N2: cửa cầu thang thoát hiểm khóa. Chìa trong ngăn kéo bàn trực tầng 4. Đồng hồ bàn trực dừng lúc 4:00, kính nứt (manh mối, không ai nói ra).", ""),
    ("think", "FIRE_LOCKED", "trung", "08:03", "Khóa rồi. Chìa… bàn trực.", "Locked. The key… the duty desk."),
    ("think", "KEY", "trung", "08:04", "Chìa cửa thoát hiểm.", "The fire door key."),
    ("event", "", "", "08:05", "N3: cầu thang thoát hiểm xuống tầng 3; tường nứt chéo. Một xác nằm sấp trên bậc bật dậy khi Trung bước qua (jumpscare 4, `stair_corpse`).", ""),
    ("event", "", "", "08:06", "N4: đoạn cầu thang tầng 2 xuống tầng 1 sập. Phải băng qua hành lang tầng 2.", ""),
    ("think", "COLLAPSE", "trung", "08:06", "Sập mất rồi… phải qua hành lang tầng hai.", "It's collapsed… I'll have to cross the second floor."),
    ("chat", "N_TRAPPED", "minh_nhat", "08:06", "Trung, cậu đang ở đâu? Tôi kẹt trong 203, chúng nó đang đập cửa!",
     "Trung, where are you? I'm stuck in 203, they're hammering the door!"),
    ("event", "", "", "08:06", "Tiếng đập cửa 203 vọng trong điện thoại (jumpscare 5, `door_203`).", ""),
    ("event", "", "", "08:07", "Trung đập bình cứu hỏa vào tường cuối hành lang (tiếng vang 25 m): đám xác bỏ cửa 203 kéo về phía tiếng động. Không ai gợi ý cách này (D-055). Minh Nhật chạy ra, từ đây đi cùng.", ""),
    ("near", "N_JOIN", "minh_nhat", "08:08", "Cảm ơn… Cầu thang chính, bên trái. Lúc nãy tôi thấy chỗ đó vãn rồi.",
     "Thanks… The main stairs, on the left. It looked clear a minute ago."),
    ("event", "", "", "08:09", "N5: tầng 1, cửa chính nhà B bị xích từ bên ngoài. Lối ra là cửa sổ vỡ trong phòng quản lý, phải cúi để chui qua; không ai gợi ý (D-055).", ""),
    ("near", "N_CHAINED", "minh_nhat", "08:09", "Xích từ bên ngoài… Ai khóa chứ?", "Chained from outside… Who locked it?"),
    ("event", "", "", "08:10", "Con dao của quản lý cắm trên bàn. Nhìn vào là có tiếng kéo lê dao vọng lại (jumpscare 3, `knife_drag`).", ""),
    ("think", "KNIFE", "trung", "08:10", "Dao của ông ta…", "His knife…"),

    ("section", "Khu 2 — vườn hoa (8:10–8:13)", "", "", "", ""),
    ("event", "", "", "08:10", "Tới vườn hoa: checkpoint `ch3_garden`. Ngư đứng trên ghế đá, cầm ba thanh sắt.", ""),
    ("near", "NGU_HERE", "ngu", "08:11", "Trung! Minh Nhật! Bên này!", "Trung! Minh Nhật! Over here!"),
    ("near", "NGU_BARS", "ngu", "08:11", "Cầm lấy, tháo từ thang giường đấy. Chúng nó chết rồi, không giết lại được đâu. Nhưng đập vào đầu thì nó đứng im một lúc.",
     "Take one, I pulled them off a bunk ladder. They're already dead, you can't kill them again. But hit the head and they freeze for a bit."),
    ("event", "", "", "08:12", "Một xác bò ra từ bồn hoa ngay chân Trung (jumpscare 6, `flowerbed_crawl`). Người chơi tự thử thanh sắt.", ""),
    ("near", "N_STADIUM", "minh_nhat", "08:12", "Ra sân vận động. Chỗ đó thoáng nhất, khó bị vây.",
     "To the stadium. It's the most open place, hard to get surrounded."),
    ("near", "NGU_GO", "ngu", "08:13", "Đi!", "Go!"),

    ("section", "Khu 3 — sân vận động (8:13–8:22)", "", "", "", ""),
    ("event", "", "", "08:14", "Checkpoint `ch3_stadium`. Đèn cột bật sáng một lần, lộ đàn xác ở cổng khán đài (jumpscare 7, `stadium_lights`). Xác tràn vào theo đợt từ bốn cổng.", ""),
    ("near", "NGU_KEEP", "ngu", "08:15", "Đừng đứng một chỗ! Chạy vòng, cắt qua sân!", "Don't stand still! Run the track, cut across the field!"),
    ("think", "LEGS", "trung", "08:17", "Chân nặng quá…", "My legs are so heavy…"),
    ("near", "N_BREATH", "minh_nhat", "08:18", "Tôi… sắp hết hơi rồi.", "I'm… almost out of breath."),
    ("event", "", "", "08:18", "Chỗ cao nhất khán đài, đứng yên thì nghe tiếng còi rất nhỏ vọng từ xa (manh mối, không ai nói ra).", ""),
    ("near", "N_NO_DEAD_END", "minh_nhat", "08:21", "Khoan. Vòng nào luật cũng chừa một đường sống. Không thể bắt mình chạy mãi thế này được. Đường sống phải ở đâu đó trong trường.",
     "Wait. Every round, the rules left a way out. They can't make us run forever. The way out has to be somewhere on campus."),
    ("near", "NGU_GATE", "ngu", "08:22", "Thì đi tìm. Ra cổng trường trước.", "Then let's find it. The front gate first."),

    ("section", "Khu 4 — cổng trường và nhà ăn (8:22–8:30)", "", "", "", ""),
    ("event", "", "", "08:23", "Checkpoint `ch3_gate`. Hàng bảo vệ đứng bất động trước cổng, cầm dùi cui điện. Bảo vệ gần nhất quay đầu nhìn Trung (jumpscare 8, `guard_turn`). Cột cổng nghiêng, biển tên trường rơi nửa (manh mối).", ""),
    ("near", "NGU_DONT", "ngu", "08:23", "Đừng đụng vào họ.", "Don't touch them."),
    ("near", "N_NO_WAY", "minh_nhat", "08:24", "Họ chặn kín cổng rồi. Lối này không ra được.", "They've sealed the gate. There's no way out here."),
    ("near", "NGU_CANTEEN", "ngu", "08:24", "Nhà ăn. Biết đâu trong đó có gì.", "The canteen. Maybe there's something in there."),
    ("event", "", "", "08:26", "Nhà ăn: bàn ghế đổ, nồi canh lạnh tanh, đồng hồ bếp dừng lúc 4:00. Tivi bật lên rè rè khi Trung đi ngang (jumpscare 9, `canteen_tv`) và đọc rõ bản tin động đất (D-055).", ""),
    ("room", "TV_NEWS", "tv", "08:26", "Tin khẩn. Lúc bốn giờ sáng nay, một trận động đất mạnh đã xảy ra. Các tòa ký túc xá của trường đổ sập hoàn toàn. Lực lượng cứu hộ đang đào bới, tìm người còn sống dưới đống đổ nát.",
     "Breaking news. At four o'clock this morning, a strong earthquake struck. The university's dormitory buildings collapsed completely. Rescue teams are digging through the rubble for survivors."),
    ("near", "N_NOTHING", "minh_nhat", "08:28", "Không có gì cả. Cứ tụ một chỗ thế này thì chậm quá.",
     "Nothing. Sticking together like this is too slow."),
    ("near", "N_SPLIT", "minh_nhat", "08:29", "Chia nhau ra. Ngư qua khu giảng đường, tôi qua nhà thi đấu, Trung qua thư viện. Thấy gì lạ thì gọi ngay.",
     "Let's split up. Ngư takes the lecture halls, I take the sports hall, Trung the library. Call the moment you see anything odd."),
    ("near", "NGU_OK", "ngu", "08:29", "Được. Đừng có chết đấy.", "Fine. Don't you dare die."),
    ("think", "LIBRARY", "trung", "08:30", "Thư viện…", "The library…"),
    ("event", "", "", "08:30", "Ba người tách ra ba hướng. Màn hình tối, thẻ \"Hết chương 3\" (lane D, `UI_CH3_END`), mở khóa chương 4.", ""),

    ("section", "Lý do chết mới", "", "", "", ""),
    ("death", "CH3_GRABBED", "", "", "Xác sống đã tóm được bạn.", "The dead caught you."),
    ("death", "CH3_SURROUNDED", "", "", "Bạn bị dồn vào giữa đám xác.", "You were cornered by the dead."),
    ("death", "CH3_GUARD", "", "", "Dùi cui điện giáng xuống người bạn.", "The stun baton came down on you."),
]

RULE_LINES = [
    ("ch1_general_1", "RULE_CH1_GENERAL_1", "rules_heard", "obey"),
    ("ch1_general_2", "RULE_CH1_GENERAL_2", "new_rule", "old_rule_expires"),
    ("ch1_general_3", "RULE_CH1_GENERAL_3", "leave_room", "stay_in_room"),
    ("ch1_general_4", "RULE_CH1_GENERAL_4", "attack_staff", "never_attack"),
    ("ch1_general_5", "RULE_CH1_GENERAL_5", "each_hour", "survive_five_hours"),
    ("ch3_r5_1", "RULE_CH3_R5_1", "round5_movement", "may_leave_room"),
    ("ch3_r5_2", "RULE_CH3_R5_2", "round5_corner", "run_from_corner"),
    ("ch3_r5_3", "RULE_CH3_R5_3", "round5_pursuit", "avoid_pursuit"),
]
UI_ROWS = [
    ("PROMPT_CH3_TAKE_KEY", "Lấy chìa khóa", "Take the key"),
    ("PROMPT_CH3_UNLOCK", "Mở khóa cửa", "Unlock the door"),
    ("PROMPT_CH3_EXTINGUISHER", "Đập bình cứu hỏa", "Bang the extinguisher"),
    ("PROMPT_CH3_CLIMB", "Trèo qua cửa sổ (cúi)", "Climb through the window (crouch)"),
]
# Jumpscare ids core emits through EventBus.scare_triggered (lane E may add cues).
SCARES = ["roommates_rise", "corridor_turn", "knife_drag", "stair_corpse", "door_203", "flowerbed_crawl",
          "stadium_lights", "guard_turn", "canteen_tv"]
# Keys this script made before (removed on the next run): D-055 dropped the hints.
RETIRED = {"CHAT_CH3_N_SOUND", "NEAR_CH3_N_WINDOW"}
PREFIXES = ("SPK_CH3_", "RULE_CH3_", "ROOM_CH3_", "THINK_CH3_", "CHAT_CH3_", "NEAR_CH3_", "NAME_CH3_",
            "PROMPT_CH3_", "DEATH_CH3_")


def key_of(kind, ident):
    return {"spk": "SPK_CH3_", "rule": "RULE_CH3_", "room": "ROOM_CH3_", "think": "THINK_CH3_",
            "chat": "CHAT_CH3_", "near": "NEAR_CH3_", "death": "DEATH_"}[kind] + ident


def minutes(clock):
    h, m = clock.split(":")
    return int(h) * 60 + int(m)


def tres_message(mid, sender, text_key, mins):
    return ('[gd_resource type="Resource" script_class="MessageData" load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="res://scripts/core/message_data.gd" id="1_msg"]\n\n'
            '[resource]\nscript = ExtResource("1_msg")\nid = &"%s"\nsender = &"%s"\nsender_name_key = "NAME_CH3_%s"\n'
            'text_key = "%s"\nminutes = %d\noutgoing = false\nspoken = true\n'
            % (mid, sender, sender.upper(), text_key, mins))


def main():
    rows, messages = [], {}
    for sid, (vi, en) in NAMES.items():
        rows.append(("NAME_CH3_" + sid.upper(), vi, en))
    for kind, ident, who, clock, vi, en in SCRIPT:
        if kind in ("section", "event"):
            continue
        key = key_of(kind, ident)
        rows.append((key, vi, en))
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
        if name.startswith("chat_ch3_") and name.endswith(".tres"):
            os.remove(os.path.join(mdir, name))
    for mid, body in messages.items():
        open(os.path.join(mdir, mid + ".tres"), "w", encoding="utf-8", newline="\n").write(body)

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
    open(os.path.join(ROOT, "game", "data", "rules", "ch3.tres"), "w", encoding="utf-8", newline=nl).write(nl.join(body))

    out = ["# Kịch bản chương 3 \"Truy sát\"", "",
           "> **Chờ chủ dự án duyệt.** Sinh tự động từ `docs/design/ch3/build_ch3_script.py`. Thiết kế: `docs/design/CH3_DESIGN.md` (D-052, D-053, D-054). Lời viết mới cho game, không chép nguyên văn video (D-034).",
           "",
           "Ký hiệu: **Loa** · 📞 = trong cuộc gọi · 🗣 = nói trực tiếp khi đi cùng · 📺 = tivi · 💭 = suy nghĩ của Trung (chỉ phụ đề) · `[…]` = diễn biến.",
           "", "## Nhân vật",
           "| Tên | Ở đâu | Chương 3 |", "|---|---|---|",
           "| Lý Minh Nhật | 203 nhà B | Kẹt trong phòng, Trung kéo xác đi để cứu; đi cùng từ tầng 2 |",
           "| Khương Ngọc Ngư | 401 nhà A | Chờ ở vườn hoa, phát thanh sắt; đi cùng từ vườn hoa |", ""]
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
            out.append("- %s📺 **%s:** %s" % (t, VOICES[who], vi))
        elif kind == "think":
            out.append("- %s💭 %s" % (t, vi))
        elif kind == "chat":
            out.append("- %s📞 **%s:** %s" % (t, NAMES[who][0], vi))
        elif kind == "near":
            out.append("- %s🗣 **%s:** %s" % (t, NAMES[who][0].split(" · ")[0], vi))
        elif kind == "death":
            out.append("- **%s:** %s" % (ident, vi))
    out += ["", "## Mã jumpscare (cho lane E)", "", ", ".join("`%s`" % s for s in SCARES)]
    open(os.path.join(ROOT, "docs", "design", "CH3_SCRIPT.md"), "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    print("rows", len(rows), "messages", len(messages))


if __name__ == "__main__":
    main()
