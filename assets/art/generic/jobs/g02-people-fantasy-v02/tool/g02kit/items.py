"""Held items.  Every item is authored with its grip at (0, 0) and its business
end toward -y (up).  ``rest`` = direction for the r hand at rest (0 up, 180
down).  Hanging items (lantern, book, bag) are authored hanging (+y) and rest 0.
A layer is (suffix, dz, pieces, material, extra form keys); extra keys may hold
``variant: "front"`` (shown only when the arm points at the viewer) or
``variant: "side"`` (hidden then).
"""

from __future__ import annotations

import math

from .core import P

GLOW = {"radius": 3, "opacity": 0.55}
REG = {}


def reg(*names):
    def deco(fn):
        for n in names:
            REG[n] = fn
        return fn
    return deco


def icon_at(icon, s, grip, rot, **kw):
    """Place a 16-unit icon box of ``s`` px so icon point ``grip`` (units) lands on (0, 0)."""
    k = s / 16.0
    dx, dy = (grip[0] - 8.0) * k, (grip[1] - 8.0) * k
    r = math.radians(rot)
    rx, ry = dx * math.cos(r) - dy * math.sin(r), dx * math.sin(r) + dy * math.cos(r)
    return P(icon, -rx, -ry, s, s, rot=rot, fit="box", **kw)


def blade(length, width, y0=-16, tip=14):
    return [P("square", 0, y0 - length / 2.0, width, length), P("triangle", 0, y0 - length - tip / 2.0 + 2, width, tip)]


def item(it):
    t = it["type"]
    if t == "none":
        return [], None
    if t not in REG:
        raise KeyError(f"unknown item {t!r}")
    layers, rest = REG[t](it, it.get("mat", "steel"), it.get("mat2", "leather_dark"), it.get("accent", "bronze"))
    return layers, it.get("rest", rest)


# ------------------------------------------------------------------ blades
@reg("sword", "greatsword", "shortsword", "jian", "rapier", "wood_sword")
def _sword(it, m, m2, acc):
    t = it["type"]
    n, w = {"sword": (86, 9), "greatsword": (116, 13), "shortsword": (58, 9), "jian": (90, 6),
            "rapier": (98, 4), "wood_sword": (80, 8)}[t]
    L = [("blade", -0.2, blade(n, w, tip=14 if w > 5 else 10), "wood" if t == "wood_sword" else m, {})]
    if w >= 8:
        L.append(("fuller", -0.15, [P("square", 0, -16 - n / 2.0, 2, n - 10)], None, {"kind": "flat", "color": "coat_seam", "opacity": 0.5}))
    if t == "rapier":
        L.append(("guard", -0.1, [P("circle", 0, -11, 18, 13), P("square", 0, -14, 30, 4)], acc, {}))
    else:
        L.append(("guard", -0.1, [P("square", 0, -13, 22 if t in ("jian", "wood_sword") else 34, 7)], acc, {}))
    L.append(("grip", -0.3, [P("square", 0, 3, 7, 24)], m2, {}))
    L.append(("pommel", -0.1, [P("circle", 0, 17, 11, 11)], acc, {}))
    if t in ("jian", "wood_sword") and it.get("tassel", True):
        L.append(("tassel", -0.35, [P("droplet", 6, 30, 8, 20, flip="y", rot=-10)], it.get("tassel_mat", "cloth_red"), {}))
    return L, 212 if t != "greatsword" else 222


@reg("katana", "mono_blade")
def _katana(it, m, m2, acc):
    L = [("blade", -0.2, [P("square", 0, -60, 6.5, 90, rot=2.5), P("triangle", 1.8, -108, 6.5, 10, rot=6)], m, {})]
    if it["type"] == "mono_blade":
        L.append(("edge", -0.15, [P("square", -2.2, -60, 2, 86, rot=2.5)], it.get("glow", "neon_cyan"),
                  {"kind": "flat", "emit": 1.0, "glow": dict(GLOW, color="neon_glow_c")}))
    L.append(("guard", -0.1, [P("circle", 0, -13, 18, 7)], "iron_dark", {}))
    L.append(("grip", -0.3, [P("square", 0, 4, 7, 28)], m2, {}))
    L.append(("wrap", -0.25, [P("diamond", 0, -4, 5, 5, repeat={"line": [[0, -6], [0, 14]], "count": 4})], "cloth_white", {"kind": "flat"}))
    return L, 210


@reg("cutlass", "dagger", "knife", "axe", "hammer", "sledgehammer", "pickaxe", "bat", "wrench", "cleaver", "machete")
def _diag(it, m, m2, acc):
    icon, s, g, r = {"cutlass": ("cutlass", 78, (3.6, 12.6), 208), "dagger": ("dagger", 48, (3.3, 12.9), 205),
                     "knife": ("knife", 54, (3.6, 12.6), 205), "cleaver": ("knife", 62, (3.6, 12.6), 200),
                     "axe": ("axe", 84, (3.6, 12.6), 205), "hammer": ("hammer", 70, (3.4, 12.8), 200),
                     "sledgehammer": ("sledgehammer", 96, (2.8, 13.4), 212), "pickaxe": ("pickaxe", 88, (3.0, 13.2), 205),
                     "bat": ("baseball_bat", 88, (2.4, 13.8), 208), "wrench": ("wrench", 60, (3.0, 13.2), 200),
                     "machete": ("cutlass", 70, (3.6, 12.6), 206)}[it["type"]]
    L = [("head", -0.2, [icon_at(icon, s, g, -45)], m, {})]
    if it["type"] == "machete":
        L.append(("tape", -0.15, [P("square", 0, 6, 9, 14)], "cloth_khaki", {}))
    return L, r


@reg("shovel")
def _shovel(it, m, m2, acc):
    return [("head", -0.2, [icon_at("shovel", 92, (13.3, 2.7), 135)], m, {})], 196


@reg("spear", "halberd", "pitchfork", "staff", "shakujo", "glaive", "pole", "broom", "duster", "scepter", "trident")
def _pole(it, m, m2, acc):
    t = it["type"]
    top = {"spear": -128, "halberd": -128, "pitchfork": -122, "staff": -126, "shakujo": -126, "glaive": -124,
           "pole": -44, "broom": -100, "duster": -46, "scepter": -58, "trident": -124}[t]
    bottom = {"pole": 20, "duster": 18, "scepter": 16, "broom": 70}.get(t, 66)
    shaft_w = {"pole": 10, "scepter": 6, "duster": 5}.get(t, 7)
    shaft = it.get("shaft", "gold" if t == "scepter" else "wood")
    L = [("shaft", -0.3, [P("square", 0, (top + bottom) / 2.0, shaft_w, bottom - top)], shaft, {})]
    if t in ("spear", "halberd"):
        L.append(("tip", -0.2, [P("droplet", 0, top - 12, 15, 36)], m, {}))
        if it.get("tassel"):
            L.append(("tassel", -0.25, [P("cloud", 0, top + 10, 20, 12), P("droplet", 0, top + 20, 14, 18, flip="y")], it["tassel"], {}))
    if t == "halberd":
        L.append(("axe", -0.25, [P("moon", -15, top + 14, 26, 34, rot=-90)], m, {}))
    if t in ("pitchfork", "trident"):
        L.append(("fork", -0.2, [P("square", 0, top, 26, 6)] + [P("square", x, top - 14, 4, 28) for x in (-11, 0, 11)], m, {}))
    if t == "staff":
        L.append(("head", -0.2, [P("moon", 4, top - 14, 26, 34, rot=-30)], shaft, {}))
        L.append(("gem", -0.1, [P("gem", 0, top - 14, 20, 18)], it.get("gem", "plasma"),
                  {"kind": "flat", "emit": 0.9, "glow": dict(GLOW, color=it.get("glow", "lamp_glow"))}))
    if t == "shakujo":
        L.append(("ring", -0.2, [P("circle", 0, top - 16, 32, 36), P("circle", 0, top - 16, 22, 26, op="sub"),
                                 P("circle", -14, top - 4, 9, 9), P("circle", 14, top - 4, 9, 9)], acc, {}))
    if t == "glaive":
        L.append(("blade", -0.2, [P("moon", -8, top - 18, 30, 58, rot=-60)], m, {}))
    if t == "pole":
        L.append(("cap", -0.2, [P("hexagon", 0, top - 4, 16, 16)], m2, {}))
    if t == "broom":
        L.append(("bristles", -0.2, [P("bell", 0, top - 20, 34, 46, crop=[1.6, 3.4, 14.4, 12], flip="y")], "straw", {}))
        L.append(("bind", -0.15, [P("square", 0, top + 2, 12, 6)], "rope", {}))
    if t == "duster":
        L.append(("feathers", -0.2, [P("feather", -6, top - 12, 18, 30, rot=-20), P("feather", 6, top - 12, 18, 30, rot=20, flip="x"),
                                     P("feather", 0, top - 18, 18, 30)], it.get("feather", "cloth_grey"), {}))
    if t == "scepter":
        L.append(("orb", -0.2, [P("circle", 0, top - 8, 18, 18)], acc, {}))
        L.append(("gem", -0.1, [P("gem", 0, top - 9, 11, 10)], it.get("gem", "cloth_red"), {"kind": "flat"}))
    rest = {"broom": 12, "duster": 0, "scepter": 0, "pole": 196}.get(t, -8)
    return L, rest


@reg("bow")
def _bow(it, m, m2, acc):
    return [("limb", 0.6, [P("moon", -10, 0, 36, 132, rot=-45, crop=[0, 0, 16, 16])], it.get("mat", "wood"), {}),
            ("string", 0.55, [P("square", -2, 0, 1.6, 118)], "cloth_cream", {"kind": "flat"})], 0


@reg("shield_kite", "shield_round")
def _shield(it, m, m2, acc):
    if it["type"] == "shield_kite":
        L = [("shield", 0.8, [P("shield", 0, 2, 62, 80)], it.get("mat", "wood"), {})]
        if it.get("mark") == "cross":
            L.append(("mark", 0.85, [P("square", 0, 0, 8, 40), P("square", 0, -6, 30, 8)], it.get("mark_mat", "cloth_red"), {"kind": "flat"}))
        L.append(("rim", 0.9, [P("shield", 0, 2, 62, 80), P("shield", 0, 2, 52, 70, op="sub")], it.get("rim", "iron"), {}))
    else:
        L = [("shield", 0.8, [P("circle", 0, 0, 66, 66)], it.get("mat", "wood"), {}),
             ("boss", 0.9, [P("circle", 0, 0, 20, 20), P("circle", 0, 0, 66, 66), P("circle", 0, 0, 58, 58, op="sub")],
              it.get("rim", "iron"), {})]
    return L, 0


@reg("fist")
def _fist(it, m, m2, acc):
    return [("fist", 0.5, [P("circle", 0, -2, 32, 30), P("circle", -9, -12, 12, 10), P("circle", 3, -14, 12, 10)],
             it.get("mat", "skin"), {"variant": "front"})], 180



# ------------------------------------------------------------------ guns (side view + front view for "aim")
def _front_gun(body_mat, size=18, glow=None):
    L = [("front_body", 0.5, [P("square", 0, -6, size, size * 0.85), P("square", 0, 8, size * 0.55, 14)], body_mat, {"variant": "front"}),
         ("front_bore", 0.6, [P("circle", 0, -8, size * 0.5, size * 0.5)], "void", {"variant": "front", "kind": "flat"})]
    if glow:
        L[1] = ("front_bore", 0.6, [P("circle", 0, -8, size * 0.52, size * 0.52)], glow,
                {"variant": "front", "kind": "flat", "emit": 1.0, "glow": dict(GLOW, color="neon_glow_c")})
    return L


@reg("pistol", "revolver", "flintlock", "raygun", "steam_pistol", "smart_pistol")
def _pistol(it, m, m2, acc):
    t = it["type"]
    icon, s, g = {"pistol": ("gun", 46, (4.2, 11.2)), "revolver": ("gun", 50, (4.2, 11.2)), "flintlock": ("flintlock", 56, (3.2, 11.8)),
                  "raygun": ("laser_gun", 50, (5.0, 12.0)), "steam_pistol": ("flintlock", 52, (3.2, 11.8)),
                  "smart_pistol": ("gun", 48, (4.2, 11.2))}[t]
    body = {"flintlock": "wood", "steam_pistol": "brass"}.get(t, m)
    L = [("gun", -0.1, [icon_at(icon, s, g, -90)], body, {"variant": "side"})]
    if t == "revolver":
        L.append(("cyl", 0.0, [P("circle", 5, -16, 13, 13)], m, {"variant": "side"}))
    if t == "flintlock":
        L.append(("barrel", 0.0, [P("square", 1.5, -26, 6, 30)], "iron", {"variant": "side"}))
    if t == "steam_pistol":
        L.append(("tank", 0.0, [P("cylinder", 8, -14, 12, 16)], "bronze", {"variant": "side"}))
    if t in ("raygun", "smart_pistol"):
        L.append(("cell", 0.0, [P("circle", 1, -22, 8, 8)], it.get("glow", "neon_cyan"),
                  {"variant": "side", "kind": "flat", "emit": 0.9, "glow": dict(GLOW, color="neon_glow_c")}))
    L += _front_gun(body, 20 if t != "flintlock" else 18, glow="neon_cyan" if t in ("raygun", "smart_pistol") else None)
    return L, 196


@reg("rifle", "shotgun", "laser_rifle", "musket", "smart_rifle")
def _rifle(it, m, m2, acc):
    t = it["type"]
    wood = it.get("stock", "wood" if t in ("rifle", "shotgun", "musket") else "iron_dark")
    blen = {"musket": 96, "shotgun": 58, "rifle": 80, "laser_rifle": 70, "smart_rifle": 74}[t]
    L = [("barrel", -0.2, [P("square", 0, -26 - blen / 2.0, 6 if t != "shotgun" else 9, blen)], m, {"variant": "side"}),
         ("body", -0.1, [P("square", 0, -14, 12, 34), P("square", 3, 20, 14, 34, rot=8)], wood, {"variant": "side"})]
    if t in ("laser_rifle", "smart_rifle"):
        L.append(("coil", 0.0, [P("square", 0, -40, 12, 22)], "iron_dark", {"variant": "side"}))
        L.append(("glow", 0.05, [P("square", 0, -40, 4, 18)], it.get("glow", "neon_cyan"),
                  {"variant": "side", "kind": "flat", "emit": 1.0, "glow": dict(GLOW, color="neon_glow_c")}))
    L += _front_gun(m, 22, glow="neon_cyan" if t in ("laser_rifle", "smart_rifle") else None)
    return L, 198


# ------------------------------------------------------------------ hanging / small props
@reg("lantern", "lamp_electric")
def _lantern(it, m, m2, acc):
    frame = "iron" if it["type"] == "lantern" else "iron_dark"
    return [("handle", -0.1, [P("circle", 0, 2, 16, 14), P("circle", 0, 2, 10, 8, op="sub")], frame, {}),
            ("body", 0.1, [P("triangle", 0, 13, 26, 11), P("square", 0, 31, 24, 28), P("square", 0, 47, 28, 7)], frame, {}),
            ("glass", 0.2, [P("square", 0, 31, 15, 20)], "glass" if it["type"] == "lantern" else "neon_amber",
             {"kind": "flat", "emit": 1.0, "glow": dict(GLOW, color="lamp_glow")})], 0


@reg("book", "ledger", "bible")
def _book(it, m, m2, acc):
    mat = it.get("mat", {"book": "leather_red", "ledger": "leather_tan", "bible": "leather_dark"}[it["type"]])
    L = [("book", 0.1, [P("square", 0, 18, 30, 38)], mat, {}), ("pages", 0.15, [P("square", 0, 36, 26, 4)], "paper", {}),
         ("clasp", 0.2, [P("square", 13, 18, 6, 10)], acc, {})]
    if it["type"] == "bible":
        L.append(("mark", 0.25, [P("square", 0, 16, 4, 16), P("square", 0, 12, 12, 4)], "gold", {"kind": "flat"}))
    return L, 0


@reg("cross", "holy_cross")
def _cross(it, m, m2, acc):
    return [("cross", -0.2, [P("square", 0, -24, 8, 52), P("square", 0, -34, 28, 8)], it.get("mat", "gold"),
             {"shade": {"highlight_amount": 0.8}})], 0


@reg("parasol", "umbrella")
def _parasol(it, m, m2, acc):
    return [("shaft", -0.3, [P("square", 0, 40, 5, 90)], "iron_dark", {}),
            ("canopy", -0.2, [P("droplet", 0, 56, 26, 76, flip="y")], it.get("mat", "cloth_black"), {}),
            ("handle", -0.1, [P("moon", -4, -6, 14, 14, rot=90)], "iron_dark", {})], 18


@reg("cane")
def _cane(it, m, m2, acc):
    return [("shaft", -0.3, [P("square", 0, 46, 6, 96)], it.get("mat", "wood"), {}),
            ("knob", -0.1, [P("circle", 0, -4, 13, 11)], acc, {})], 8


@reg("beads")
def _beads(it, m, m2, acc):
    return [("beads", 0.1, [P("circle", 0, 20, 6, 6, repeat={"ellipse": [0, 22, 10, 20], "count": 14})], it.get("mat", "wood"), {}),
            ("tassel", 0.1, [P("droplet", 0, 48, 8, 14, flip="y")], "cloth_red", {})], 0


@reg("shuriken")
def _shuriken(it, m, m2, acc):
    return [("star", 0.2, [P("star", 0, -2, 24, 24)], m, {}), ("hole", 0.25, [P("circle", 0, -2, 6, 6)], "void", {"kind": "flat"})], 0


@reg("fan", "war_fan")
def _fan(it, m, m2, acc):
    w = 46 if it["type"] == "fan" else 60
    ribs = [P("square", 13 * math.sin(math.radians(a)), -13 * math.cos(math.radians(a)), 2, 24, rot=a) for a in (-50, -25, 0, 25, 50)]
    return [("fan", 0.2, [P("umbrella", 0, -22, w, w * 0.62, crop=[0.6, 2.3, 15.4, 8.7])], it.get("mat", "cloth_red"), {}),
            ("ribs", 0.25, ribs, "wood" if it["type"] == "fan" else "iron", {"kind": "flat", "clip_to": "fan"})], 0


@reg("clipboard")
def _clipboard(it, m, m2, acc):
    return [("board", 0.1, [P("square", 0, 22, 30, 40)], "wood", {}), ("paper", 0.15, [P("square", 0, 24, 24, 32)], "paper", {}),
            ("clip", 0.2, [P("square", 0, 4, 12, 7)], "steel", {})], 0


@reg("syringe")
def _syringe(it, m, m2, acc):
    return [("barrel", -0.1, [P("square", 0, -14, 10, 26)], "glass", {"opacity": 0.85}),
            ("fluid", -0.05, [P("square", 0, -10, 6, 16)], it.get("fluid", "rad_green"), {"kind": "flat"}),
            ("needle", -0.15, [P("square", 0, -34, 2, 16)], "steel", {}),
            ("plunger", -0.2, [P("square", 0, 4, 4, 14), P("square", 0, 11, 14, 4)], "steel", {})], 180


@reg("scalpel")
def _scalpel(it, m, m2, acc):
    return [("blade", -0.2, [P("droplet", 0, -20, 5, 14)], "steel", {}), ("handle", -0.15, [P("square", 0, -2, 5, 22)], "chrome", {})], 190


@reg("baton", "club")
def _baton(it, m, m2, acc):
    t = it["type"]
    L = [("rod", -0.2, [P("square", 0, -30, 9 if t == "baton" else 13, 62)], it.get("mat", "rubber" if t == "baton" else "wood"), {}),
         ("grip", -0.25, [P("square", 0, 6, 8, 16)], "leather_dark", {})]
    if t == "baton":
        L.append(("side", -0.3, [P("square", 7, 0, 12, 5)], "rubber", {}))
    return L, 200


@reg("magnifier")
def _magnifier(it, m, m2, acc):
    return [("handle", -0.2, [P("square", 0, -8, 6, 26)], "wood", {}),
            ("rim", -0.1, [P("circle", 0, -34, 28, 28), P("circle", 0, -34, 20, 20, op="sub")], acc, {}),
            ("lens", -0.15, [P("circle", 0, -34, 20, 20)], "lens", {"opacity": 0.7})], 18


@reg("ladle")
def _ladle(it, m, m2, acc):
    return [("shaft", -0.2, [P("square", 0, -26, 5, 60)], "wood", {}), ("bowl", -0.1, [P("circle", 0, -60, 20, 15)], "iron", {})], 200


@reg("lute")
def _lute(it, m, m2, acc):
    return [("neck", -0.3, [P("square", 0, -36, 8, 60), P("square", 0, -70, 12, 12)], "wood", {}),
            ("body", 0.4, [P("circle", 0, 8, 42, 48)], it.get("mat", "wood"), {}),
            ("hole", 0.45, [P("circle", 0, 2, 11, 11)], "void", {"kind": "flat"})], 38


@reg("gohei", "talisman", "scroll", "wanted")
def _paper(it, m, m2, acc):
    t = it["type"]
    if t == "gohei":
        return [("stick", -0.2, [P("square", 0, -28, 5, 64)], "wood", {}),
                ("paper", -0.1, [P("lightning_bolt", -8, -58, 12, 30), P("lightning_bolt", 8, -58, 12, 30, flip="x")], "cloth_white", {})], -10
    if t == "talisman":
        return [("paper", 0.2, [P("square", 0, -22, 16, 40)], "paper", {}),
                ("ink", 0.25, [P("square", 0, -26, 3, 26), P("circle", 0, -36, 8, 8)], "cloth_red", {"kind": "flat"})], 0
    if t == "wanted":
        return [("paper", 0.2, [P("square", 0, 20, 30, 38)], "paper", {}),
                ("face", 0.25, [P("circle", 0, 16, 14, 14), P("square", 0, 32, 20, 3)], "paper_mark", {"kind": "flat"})], 0
    return [("scroll", 0.2, [P("square", 0, 18, 18, 34), P("cylinder", 0, 0, 24, 8), P("cylinder", 0, 36, 24, 8)], "paper", {}),
            ("rod", 0.25, [P("square", 0, 0, 28, 4), P("square", 0, 36, 28, 4)], "wood", {})], 0


@reg("hook")
def _hook(it, m, m2, acc):
    return [("cuff", 0.1, [P("cylinder", 0, 0, 20, 14)], "leather_dark", {}),
            ("hook", 0.2, [P("hook", 0, 22, 26, 30, crop=[3, 5, 13, 16])], "steel", {})], 0


@reg("spyglass")
def _spyglass(it, m, m2, acc):
    return [("tube", -0.1, [P("square", 0, -22, 13, 44), P("square", 0, -50, 9, 18)], "brass", {}),
            ("rings", -0.05, [P("square", 0, -40, 15, 4), P("square", 0, -4, 15, 4)], "leather_dark", {})], 20


@reg("lasso")
def _lasso(it, m, m2, acc):
    return [("rope", 0.3, [P("circle", 0, 24, 40, 34), P("circle", 0, 24, 32, 26, op="sub"), P("square", 0, 4, 4, 14)], "rope", {})], 0


@reg("dynamite")
def _dynamite(it, m, m2, acc):
    return [("sticks", 0.2, [P("square", x, -16, 8, 28) for x in (-8, 0, 8)], "cloth_red", {}),
            ("band", 0.25, [P("square", 0, -16, 26, 5)], "rope", {}),
            ("fuse", 0.2, [P("square", 3, -36, 2, 12, rot=20)], "rope", {}),
            ("spark", 0.3, [P("star", 6, -44, 8, 8)], "neon_amber", {"kind": "flat", "emit": 1.0})], 0


@reg("tablet", "cyberdeck", "scanner", "geiger", "phone", "camcorder")
def _device(it, m, m2, acc):
    t = it["type"]
    w, h = {"tablet": (30, 40), "cyberdeck": (44, 26), "scanner": (24, 34), "geiger": (30, 24), "phone": (16, 28), "camcorder": (34, 22)}[t]
    glow = it.get("glow", {"geiger": "rad_green", "camcorder": "ember_red"}.get(t, "neon_cyan"))
    L = [("case", 0.2, [P("square", 0, 18, w, h)], it.get("mat", "iron_dark"), {}),
         ("screen", 0.25, [P("square", 0, 16, w * 0.7, h * 0.55)], glow, {"kind": "flat", "emit": 0.8, "opacity": 0.85})]
    if t == "cyberdeck":
        L.append(("keys", 0.27, [P("square", -14, 26, 5, 3, repeat={"grid": [5, 2], "step": [7, 5]})], "chrome", {"kind": "flat"}))
        L.append(("cable", 0.15, [P("square", 20, 2, 3, 26, rot=-30)], "rubber", {}))
    if t == "geiger":
        L.append(("probe", 0.1, [P("square", -18, 12, 6, 20, rot=-30)], "chrome", {}))
    if t == "camcorder":
        L.append(("lens", 0.3, [P("circle", -18, 18, 14, 14)], "lens", {}))
    return L, 0


@reg("candle", "crystal_ball", "flower", "coin_pouch", "basket", "sack", "balloon", "rattle", "bells", "sickle", "gift", "bottle")
def _misc(it, m, m2, acc):
    t = it["type"]
    if t == "candle":
        return [("dish", 0.1, [P("circle", 0, 2, 26, 8)], "brass", {}), ("wax", 0.12, [P("square", 0, -12, 10, 24)], "bone", {}),
                ("flame", 0.2, [P("droplet", 0, -30, 8, 13)], "flame", {"kind": "flat", "emit": 1.0,
                                                                        "glow": dict(GLOW, color="flame_glow")})], 0
    if t == "crystal_ball":
        return [("base", 0.1, [P("square", 0, 4, 20, 8)], "brass", {}),
                ("ball", 0.2, [P("circle", 0, -14, 30, 30)], "plasma", {"opacity": 0.8, "emit": 0.6,
                                                                       "glow": dict(GLOW, color="plasma_glow")})], 0
    if t == "flower":
        return [("stem", -0.2, [P("square", 0, -18, 3, 36)], "cloth_green", {}),
                ("bloom", -0.1, [P("flower", 0, -40, 20, 20)], it.get("mat", "cloth_red"), {})], 0
    if t == "coin_pouch":
        return [("pouch", 0.2, [P("pouch", 0, 18, 30, 30)], "leather_tan", {}), ("coin", 0.25, [P("coin", 10, 30, 10, 10)], "gold", {})], 0
    if t == "basket":
        return [("basket", 0.2, [P("shopping_basket", 0, 20, 40, 32, crop=[0.5, 5.5, 15.5, 15.5])], "straw", {}),
                ("herbs", 0.15, [P("leaf", -8, 6, 14, 18, rot=-20), P("leaf", 6, 4, 14, 18, rot=25), P("sprout", 0, 2, 16, 16)],
                 "cloth_green", {})], 0
    if t == "sack":
        return [("sack", 0.9, [P("pouch", 0, 26, 64, 64)], it.get("mat", "cloth_red"), {})], 0
    if t == "balloon":
        return [("string", -0.3, [P("square", 0, -40, 1.6, 80)], "cloth_white", {"kind": "flat"}),
                ("balloon", -0.2, [P("circle", 0, -96, 38, 44), P("triangle", 0, -73, 8, 6, flip="y")], it.get("mat", "cloth_red"),
                 {"shade": {"highlight_amount": 0.8}})], 0
    if t == "rattle":
        return [("handle", -0.2, [P("square", 0, -8, 5, 18)], "wood", {}), ("head", -0.1, [P("circle", 0, -22, 16, 16)], "cloth_sky", {})], 0
    if t == "bells":
        return [("handle", -0.2, [P("square", 0, -10, 5, 22)], "wood", {}),
                ("bells", -0.1, [P("bell", x, -30 + abs(x) * 0.4, 12, 12) for x in (-9, 0, 9)], "gold", {})], 0
    if t == "sickle":
        return [("handle", -0.2, [P("square", 0, -6, 6, 26)], "wood", {}), ("blade", -0.1, [P("moon", 6, -30, 24, 30, rot=40)], "iron", {})], 200
    if t == "gift":
        return [("box", 0.3, [P("gift", 0, -4, 28, 28)], "cloth_green", {})], 0
    return [("bottle", 0.2, [P("potion", 0, 14, 22, 30)], it.get("mat", "glass"), {"opacity": 0.9})], 0
