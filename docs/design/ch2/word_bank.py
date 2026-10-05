"""Chapter 2 word chain (CH2_DESIGN.md N1-N5): the closed word bank and its checks.

A word is two Vietnamese syllables. The next word must start with the last
syllable of the previous one, tone included. Corpses only say words from this
bank; the player picks among options built from it (T-170 director).

DEAD: words whose last syllable starts no word in the bank. Choosing one makes
the next corpse stall (N2 trap). LOOP: Minh Nhật's 8-word loop back to "học".
"""
import unicodedata

# word -> English gloss (shown in the English UI next to the Vietnamese word).
BANK = {
    # Minh Nhật's loop (N5).
    "học sinh": "pupil", "sinh viên": "student", "viên phấn": "chalk stick", "phấn đấu": "strive",
    "đấu tranh": "struggle", "tranh luận": "debate", "luận văn": "thesis", "văn học": "literature",
    # học / sinh / viên / phấn / đấu / tranh / luận / văn
    "học tập": "study", "học kỳ": "semester", "học phí": "tuition", "học trò": "pupil",
    "sinh nhật": "birthday", "sinh mạng": "a life", "sinh tử": "life and death", "sinh hoạt": "daily life",
    "viên thuốc": "pill", "viên gạch": "brick", "phấn khởi": "elated",
    "đấu trường": "arena", "đấu giá": "auction", "tranh cãi": "argue", "tranh giành": "fight over",
    "luận án": "dissertation", "luận điểm": "argument", "văn phòng": "office", "văn bản": "document", "văn hóa": "culture",
    # continuations
    "tập trung": "focus", "tập thể": "collective", "kỳ thi": "exam", "kỳ lạ": "strange", "phí tổn": "expense",
    "trò chơi": "game", "trò đùa": "joke", "nhật ký": "diary", "nhật thực": "solar eclipse",
    "mạng sống": "life", "mạng lưới": "network", "mạng nhện": "cobweb",
    "tử thần": "death (reaper)", "tử tế": "kind", "hoạt động": "activity", "thuốc độc": "poison", "thuốc ngủ": "sleeping pill",
    "gạch đá": "bricks and stones", "khởi đầu": "beginning", "khởi động": "warm up",
    "trường học": "school", "giá lạnh": "freezing", "cãi nhau": "quarrel", "giành giật": "snatch",
    "án mạng": "murder case", "điểm danh": "roll call", "điểm số": "score", "phòng ngủ": "bedroom", "phòng tắm": "bathroom",
    "bản án": "sentence (court)", "bản đồ": "map", "hóa đơn": "bill", "hóa trang": "costume make-up",
    "trung thành": "loyal", "thể thao": "sport", "thi cử": "exams", "lạ lùng": "strange",
    "tổn thương": "hurt", "chơi đùa": "play around", "đùa giỡn": "joke around",
    "ký túc": "dormitory", "ký tên": "sign", "ký ức": "memory", "thực tế": "reality", "thực hành": "practice",
    "sống sót": "survive", "sống còn": "life-or-death", "lưới điện": "power grid",
    "nhện độc": "poisonous spider", "thần kinh": "nerves", "thần chết": "Death", "tế bào": "cell",
    "động đất": "earthquake", "độc ác": "cruel", "ngủ gật": "doze off",
    "đá bóng": "football", "đầu óc": "mind", "đầu tiên": "first",
    "lạnh lùng": "cold-hearted", "nhau thai": "placenta", "giật mình": "startled",
    "mạng người": "a human life", "danh sách": "list", "số phận": "fate", "ngủ say": "sound asleep",
    "tắm rửa": "wash", "án tử": "death sentence", "đồ đạc": "belongings", "đơn độc": "alone",
    "trang phục": "clothing", "thành phố": "city", "thao thức": "sleepless", "cử chỉ": "gesture",
    "lùng sục": "hunt", "thương tích": "injury", "giỡn mặt": "mock",
    "túc trực": "keep watch", "tên tuổi": "name", "ức chế": "frustrated", "tế nhị": "tactful", "hành lang": "corridor",
    "còn sống": "still alive", "điện thoại": "phone", "kinh dị": "horror", "kinh hoàng": "terror",
    "chết đuối": "drown", "bào chữa": "defend", "đất đai": "land", "ác mộng": "nightmare",
    "gật đầu": "nod", "bóng tối": "darkness", "óc chó": "walnut", "tiên tri": "prophet",
    "thai nhi": "fetus", "mình mẩy": "body", "người chết": "the dead", "sách vở": "books",
    "phận sự": "duty", "say sưa": "absorbed", "rửa tay": "wash hands", "tử hình": "execution",
    "đạc điền": "land survey", "phục vụ": "serve", "phố xá": "streets", "thức tỉnh": "awaken",
    "chỉ huy": "command", "sục sạo": "rummage", "tích tắc": "tick-tock", "mặt nạ": "mask",
    "trực đêm": "night duty", "tuổi thơ": "childhood", "chế độ": "regime", "nhị phân": "binary", "lang thang": "wander",
    "sống chết": "life or death", "thoại bản": "script", "dị dạng": "deformed", "hoàng hôn": "dusk",
    "đuối sức": "exhausted", "chữa cháy": "firefighting", "đai lưng": "belt", "mộng du": "sleepwalk",
    "tối tăm": "gloomy", "chó dữ": "fierce dog", "tri thức": "knowledge", "nhi đồng": "children",
    "người lạ": "stranger", "vở kịch": "play (drama)", "sự thật": "truth",
    "tay chân": "hands and feet", "hình phạt": "punishment", "điền vào": "fill in",
    "vụ án": "case", "xá tội": "pardon", "tỉnh táo": "alert", "huy chương": "medal",
    "tắc nghẽn": "blocked", "nạ dòng": "middle-aged woman", "đêm khuya": "late night",
    "thơ ca": "poetry", "độ ẩm": "humidity", "phân xác": "dismember", "thang máy": "lift",
    "chết chóc": "carnage", "bản thân": "oneself", "dạng người": "human-shaped", "hôn mê": "coma",
    "sức lực": "strength", "cháy nhà": "house fire", "lưng chừng": "halfway",
    "du học": "study abroad", "tăm tối": "dark", "dữ dội": "violent", "thức ăn": "food",
    "đồng hồ": "clock", "lạ mặt": "unfamiliar", "kịch bản": "screenplay", "thật thà": "honest",
    "chân dung": "portrait", "phạt đền": "penalty kick", "vào học": "class starts", "chương trình": "programme",
    "nghẽn mạch": "clogged artery", "dòng máu": "bloodline", "khuya khoắt": "late at night",
    "ca đêm": "night shift", "ẩm ướt": "damp", "xác chết": "corpse", "máy móc": "machinery",
    "thân phận": "status", "mê cung": "maze", "lực lượng": "force", "nhà tắm": "bathroom",
    "chừng mực": "moderation", "dội nước": "pour water", "ăn năn": "repent",
    "hồ sơ": "file", "mặt mũi": "face", "thà rằng": "rather", "dung nhan": "looks", "đền mạng": "pay with one's life",
    "trình diện": "report in", "mạch máu": "blood vessel", "máu lạnh": "cold-blooded",
    "ướt sũng": "soaked", "chết người": "deadly", "móc túi": "pickpocket", "phận bạc": "ill-fated",
    "cung cấp": "supply", "lượng sức": "know one's strength", "tắm nắng": "sunbathe",
    "mực nước": "water level", "nước sôi": "boiling water", "năn nỉ": "plead",
    "sơ cứu": "first aid", "mũi dao": "knife tip", "nhan sắc": "beauty",
    "diện mạo": "appearance", "lạnh lẽo": "chilly", "sũng nước": "waterlogged", "người thân": "relative",
    "túi xách": "handbag", "bạc mệnh": "ill-fated", "cấp cứu": "emergency", "nắng nóng": "heatwave",
    "sôi sục": "seething", "nỉ non": "whisper sadly", "cứu sống": "save a life", "dao găm": "dagger",
    "sắc bén": "sharp", "mạo hiểm": "risky", "xách tay": "carry by hand", "mệnh lệnh": "order",
    "nóng bỏng": "scorching", "non nớt": "naive", "găm vào": "stab into",
    "bén lửa": "catch fire", "hiểm họa": "danger", "lệnh cấm": "ban", "bỏng rát": "burning pain",
    "lửa đỏ": "red flames", "họa sĩ": "painter", "cấm kỵ": "taboo",
    "đỏ au": "bright red", "sĩ tử": "exam candidate", "kỵ sĩ": "knight",
    # N2 dead ends (nothing in the bank starts with the last syllable).
    "trong sạch": "pure", "sạch sẽ": "clean", "xinh đẹp": "pretty", "đẹp đẽ": "lovely",
    "trong trắng": "innocent", "trắng trẻo": "fair-skinned", "dại khờ": "foolish", "khờ khạo": "naive",
    "nặng nhẹ": "heavy and light", "nhẹ nhõm": "relieved",
}
BANK = {w: g for w, g in BANK.items() if w}
# Bridges back to the core around "học" (so every live word can reach the loop).
BANK.update({
    "đêm trường": "long night", "tắm máu": "bloodbath", "máu thịt": "flesh and blood", "thịt người": "human flesh",
    "lạnh người": "chilled to the bone", "tội ác": "crime", "nước đá": "ice water", "tối mật": "top secret",
    "mật mã": "code", "mã số": "code number", "đỏ mặt": "blush", "ngủ đông": "hibernate", "đông người": "crowded",
    "táo bạo": "daring", "bạo lực": "violence", "lực sĩ": "strongman", "sự sống": "life",
    # Shortcuts into Minh Nhật's loop (any loop syllable joins it).
    "sinh học": "biology", "hóa học": "chemistry", "số học": "arithmetic", "thi đấu": "compete",
    "hôn nhân": "marriage", "nhân viên": "employee", "nhân văn": "humane", "nhân công": "labour",
    "công viên": "park", "công văn": "official letter", "kinh tế": "economy", "đồ án": "project",
    "thương nhân": "merchant", "người học": "learner",
    "mặt trận": "front line", "trận đấu": "match", "thân nhân": "next of kin",
    "lực học": "mechanics", "bức tranh": "painting",
    "bình luận": "comment",
    # N2 dead ends that start on a syllable the chain can reach.
    "người ngợm": "body (and all)", "thần thánh": "divine", "kinh khủng": "horrible", "mê man": "unconscious",
})

LOOP = ["học sinh", "sinh viên", "viên phấn", "phấn đấu", "đấu tranh", "tranh luận", "luận văn", "văn học"]
LOOP_STARTS = {w.split(" ")[0] for w in LOOP}
# Corpses' scripted opening (N1): Đạt ends on a hard syllable for Trung's first turn.
OPENING = ["điểm danh", "danh sách", "sách vở"]
# Dead ends the player may pick to make the next corpse stall (N2).
DEAD = {"sống sót", "chết chóc", "người ngợm", "thần thánh", "kinh khủng", "mê man", "lạnh lẽo"}
# Words that are not legal answers anywhere but look tempting (wrong tone or
# a near-miss start). Used only as traps, never said by corpses.
TRAPS = {
    "sính lễ": "wedding gifts", "xinh xắn": "cute", "vịn tay": "hold on", "phần thưởng": "reward",
    "dấu vết": "trace", "chanh chua": "sour", "luân hồi": "reincarnation", "vẫn còn": "still",
    "hộc tủ": "drawer", "khuất phục": "submit", "khuyết điểm": "flaw", "đêm đen": "dark night",
    "dễ dàng": "easy", "vỡ nát": "smashed", "vợ chồng": "husband and wife", "giễu cợt": "mock", "trừng phạt": "punish", "chục năm": "decades",
    "thơm tho": "fragrant", "dâng hiến": "devote", "rồi sao": "so what",
}
TRAPS = {w: g for w, g in TRAPS.items() if w}

def prune():
    """Keeps the live words that the loop reaches and that reach "học" again,
    plus dead ends starting on a syllable such a word ends with."""
    live = {w for w in BANK if w not in DEAD}
    table, ends = {}, {}
    for w in live:
        table.setdefault(w.split(" ")[0], []).append(w)
        ends.setdefault(w.split(" ")[1], []).append(w)
    forward, frontier = set(LOOP), list(LOOP)
    while frontier:
        for u in table.get(frontier.pop().split(" ")[1], []):
            if u not in forward:
                forward.add(u)
                frontier.append(u)
    back = {w for w in live if w.split(" ")[1] == "học"}
    frontier = list(back)
    while frontier:
        for u in ends.get(frontier.pop().split(" ")[0], []):
            if u not in back:
                back.add(u)
                frontier.append(u)
    core = forward & back
    core_ends = {w.split(" ")[1] for w in core}
    core_starts = {w.split(" ")[0] for w in core}
    dead = {w for w in DEAD if w in BANK and w.split(" ")[0] in core_ends and w.split(" ")[0] in core_starts}
    return {w: BANK[w] for w in sorted(core | dead)}, dead


ALL_WORDS = dict(BANK)
BANK, DEAD = prune()

TONES = {"̀", "́", "̃", "̉", "̣"}


def syllables(word):
    parts = word.split(" ")
    assert len(parts) == 2, word
    return parts


def toneless(syllable):
    decomposed = unicodedata.normalize("NFD", syllable)
    return unicodedata.normalize("NFC", "".join(c for c in decomposed if c not in TONES))


def starts():
    table = {}
    for w in BANK:
        table.setdefault(syllables(w)[0], []).append(w)
    return table


def steer_distances():
    """Turns of the player's own words needed to end on "học" from each live word."""
    table = starts()
    result = {}
    for w in BANK:
        if w in DEAD:
            continue
        dist, frontier, seen = None, [w], {w}
        for step in range(len(BANK)):
            if any(syllables(v)[1] in LOOP_STARTS for v in frontier):
                dist = step
                break
            nxt = []
            for v in frontier:
                for u in table.get(syllables(v)[1], []):
                    if u not in seen and u not in DEAD:
                        seen.add(u)
                        nxt.append(u)
            if not nxt:
                break
            frontier = nxt
        result[w] = dist
    return result


def check():
    """Raises on any hole: the player must always have an answer."""
    table = starts()
    problems = []
    for w in BANK:
        last = syllables(w)[1]
        if w in DEAD:
            if last in table:
                problems.append("dead end continues: %s -> %s" % (w, table[last]))
        elif last not in table:
            problems.append("no continuation after: %s" % w)
    for a, b in zip(LOOP, LOOP[1:] + LOOP[:1]):
        if syllables(a)[1] != syllables(b)[0]:
            problems.append("loop broken: %s / %s" % (a, b))
    for a, b in zip(OPENING, OPENING[1:]):
        if syllables(a)[1] != syllables(b)[0]:
            problems.append("opening broken: %s / %s" % (a, b))
    # Every live word can reach "học" (steering to Minh Nhật's loop).
    for w, d in steer_distances().items():
        if d is None:
            problems.append("cannot steer to học from: %s" % w)
    for t in TRAPS:
        if t in BANK:
            problems.append("trap also in bank: %s" % t)
    return problems


if __name__ == "__main__":
    issues = check()
    dist = steer_distances()
    print("words", len(BANK), "dead", len(DEAD), "traps", len(TRAPS), "issues", len(issues),
          "max steer", max(d for d in dist.values() if d is not None))
    for i in issues:
        print(" ", i)
