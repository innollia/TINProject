import json, math, os, sys

OUT = r"C:\projects\TINProject\modules\sideview_ecosystem\content"
TILE = 24.0
TARGET = {"speck": 96.0, "hand": 240.0, "doll": 384.0}
GAP_MULT = {"SEAL": 0.20, "HAIRLINE": 0.35, "TIGHT": 0.85, "FIT": 2.60, "WIDE": 4.20}
problems = []


class Room:
    def __init__(self, rid, band, w, h, place_id=""):
        self.id, self.band, self.w, self.h, self.place_id = rid, band, w, h, place_id
        self.g = [["#"] * w for _ in range(h)]
        self.exits, self.passages, self.triggers, self.shelters, self.dens, self.tethered = [], [], [], [], [], []

    def fill(self, x0, y0, x1, y1, ch="."):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.g[y][x] = ch
        return self

    def exit(self, eid, side, a, b, to_room, to_exit):
        for i in range(a, b + 1):
            x, y = {"left": (0, i), "right": (self.w - 1, i), "top": (i, 0), "bottom": (i, self.h - 1)}[side]
            self.g[y][x] = "."
        self.exits.append({"id": eid, "side": side, "from": a, "to": b, "to_room": to_room, "to_exit": to_exit})
        return self

    def passage(self, **p):
        self.passages.append(p)
        return self

    def trigger(self, tid, obj, cell, span):
        self.triggers.append({"id": tid, "object": obj, "cell": list(cell), "span": list(span)})
        return self

    def shelter(self, sid, cell):
        self.shelters.append({"id": sid, "cell": list(cell)})
        return self

    def den(self, did, cell, lineage_of, stage=0):
        self.dens.append({"id": did, "cell": list(cell), "lineage_of": lineage_of, "stage": stage})
        return self

    def tether(self, axis_id, archetype, cell, rung):
        self.tethered.append({"axis_id": axis_id, "archetype": archetype, "cell": list(cell), "rung": rung})
        return self

    def to_json(self):
        d = {"id": self.id, "band": self.band, "target_body_px": TARGET[self.band], "place_id": self.place_id,
             "tiles": ["".join(r) for r in self.g], "exits": self.exits, "passages": self.passages,
             "triggers": self.triggers, "shelters": self.shelters, "dens": self.dens, "tethered": self.tethered}
        return d

    def check(self):
        where = self.id
        if not (12 <= self.h <= 200 and 16 <= self.w <= 240):
            problems.append(f"{where} size {self.w}x{self.h}")
        module = TARGET[self.band] / 2.75
        salt_ok = set()
        for p in self.passages:
            cx, cy = p["cell"]; sx, sy = p["span"]
            if cx < 0 or cy < 0 or cx + sx > self.w or cy + sy > self.h:
                problems.append(f"{where}/{p['id']} rect outside"); continue
            for y in range(cy, cy + sy):
                for x in range(cx, cx + sx):
                    if self.g[y][x] != ".":
                        problems.append(f"{where}/{p['id']} over solid at {x},{y}"); break
            if p["kind"] == "GAP" and sx * TILE < GAP_MULT[p["width_class"]] * module + 2 * TILE:
                problems.append(f"{where}/{p['id']} gap rect too narrow")
            if p["kind"] == "STEP" and sy * TILE < p["height_px"]:
                problems.append(f"{where}/{p['id']} step rect too low")
            if p["kind"] == "DROP":
                if abs(sy * TILE - p["fall_px"]) > TILE:
                    problems.append(f"{where}/{p['id']} drop height {sy * TILE} vs {p['fall_px']}")
                if cy + sy >= self.h or any(self.g[cy + sy][x] not in "#sd" for x in range(cx, cx + sx)):
                    problems.append(f"{where}/{p['id']} no floor below drop")
        for t in self.triggers:
            cx, cy = t["cell"]; sx, sy = t["span"]
            bottom = cy + sy - 1
            row = [self.g[bottom][x] for x in range(cx, cx + sx)]
            if t["object"] == "salt_bed":
                if any(c != "s" for c in row):
                    problems.append(f"{where}/{t['id']} salt row")
                for x in range(cx, cx + sx):
                    salt_ok.add((x, bottom))
            if t["object"] == "collapse_floor" and any(c != "#" for c in row):
                problems.append(f"{where}/{t['id']} collapse row not solid")
        for y in range(self.h):
            for x in range(self.w):
                if self.g[y][x] == "s" and (x, y) not in salt_ok:
                    problems.append(f"{where} salt outside bed at {x},{y}")
        for s in self.shelters:
            x, y = s["cell"]
            if self.g[y][x] != "." or self.g[y + 1][x] not in "#sd":
                problems.append(f"{where}/{s['id']} shelter footing")


def gap(pid, cell, span, width_class, drift=False):
    d = {"id": pid, "kind": "GAP", "cell": list(cell), "span": list(span), "width_class": width_class}
    if drift:
        d["drift"] = True
    return d


rooms = {}
def R(rid, band, w, h, place_id=""):
    r = Room(rid, band, w, h, place_id)
    rooms[rid] = r
    return r

# ---------------- reg_filter_bed (speck) ----------------
R("filter_bed_00", "speck", 40, 24).fill(1, 1, 38, 22) \
    .exit("e", "right", 11, 22, "filter_bed_01", "w").shelter("shelter_fb_00", (4, 22))
R("filter_bed_01", "speck", 48, 24).fill(1, 1, 46, 22).fill(1, 11, 8, 11, "#") \
    .exit("w", "left", 11, 22, "filter_bed_00", "e").exit("nw", "left", 1, 10, "seed_vault_04", "e") \
    .exit("e", "right", 11, 22, "filter_bed_02", "w").den("den_fb_01_0", (24, 22), "arc_skitter")
fb2 = R("filter_bed_02", "speck", 56, 28).fill(1, 1, 54, 26).fill(14, 26, 19, 26, "s")
fb2.exit("w", "left", 15, 26, "filter_bed_01", "e").exit("e", "right", 15, 26, "filter_bed_03", "w")
fb2.trigger("salt_bed_fb_02", "salt_bed", (14, 23), (6, 4))
fb2.passage(id="step_fb_02_up", kind="STEP", cell=[36, 18], span=[6, 9], height_px=200.0)
R("filter_bed_03", "speck", 48, 28).fill(1, 1, 46, 26) \
    .exit("w", "left", 15, 26, "filter_bed_02", "e").exit("e", "right", 15, 26, "filter_bed_04", "w")
R("filter_bed_04", "speck", 56, 28).fill(1, 1, 54, 26) \
    .exit("w", "left", 15, 26, "filter_bed_03", "e").exit("e", "right", 15, 26, "filter_bed_05", "w") \
    .passage(id="wall_fb_04_a", kind="BREAK", cell=[44, 1], span=[2, 26], hp=2)
R("filter_bed_05", "speck", 48, 28).fill(1, 1, 46, 26) \
    .exit("w", "left", 15, 26, "filter_bed_04", "e").exit("e", "right", 15, 26, "ash_terrace_00", "w")

# ---------------- reg_ash_terrace ----------------
R("ash_terrace_00", "speck", 48, 28, "place.ruined_garden").fill(1, 1, 46, 26) \
    .exit("w", "left", 15, 26, "filter_bed_05", "e").exit("e", "right", 15, 26, "ash_terrace_01", "w") \
    .tether("fix.gardener", "arc_brood", (24, 26), "speck")
at1 = R("ash_terrace_01", "speck", 52, 39).fill(1, 1, 50, 26).fill(1, 28, 50, 37).fill(20, 27, 28, 27)
at1.fill(29, 33, 31, 33, "=")
at1.exit("w", "left", 15, 26, "ash_terrace_00", "e").exit("e", "right", 28, 37, "ash_terrace_02", "w")
at1.shelter("shelter_at_01", (8, 26)).passage(**gap("gap_at_01_wide", (20, 27), (9, 11), "WIDE"))
at2 = R("ash_terrace_02", "speck", 48, 24).fill(1, 1, 46, 22).fill(2, 8, 20, 8, "#").fill(8, 8, 13, 8)
at2.exit("w", "left", 13, 22, "ash_terrace_01", "e").exit("e", "right", 11, 22, "ash_terrace_03", "w")
at2.den("den_at_02_0", (30, 22), "arc_brood").passage(**gap("gap_at_02_drift", (8, 8), (6, 6), "FIT", True))
at3 = R("ash_terrace_03", "hand", 60, 98).fill(1, 1, 58, 12).fill(14, 13, 21, 13, "=").fill(34, 13, 45, 13)
at3.fill(14, 14, 21, 96).fill(1, 85, 21, 96).fill(30, 14, 58, 23).fill(47, 19, 49, 19, "=")
at3.exit("w", "left", 1, 12, "ash_terrace_02", "e").exit("e", "right", 14, 23, "ash_terrace_04", "w")
at3.exit("sw", "left", 85, 96, "ash_terrace_06", "e")
at3.passage(**gap("gap_at_03_fit", (34, 13), (12, 11), "FIT"))
at3.passage(id="drop_at_03", kind="DROP", cell=[14, 14], span=[8, 83], fall_px=2000.0)
at4 = R("ash_terrace_04", "hand", 40, 145).fill(1, 1, 38, 30).fill(9, 32, 28, 143).fill(1, 118, 38, 143)
at4.exit("w", "left", 21, 30, "ash_terrace_03", "e").exit("e", "right", 118, 143, "ash_terrace_05", "w")
at4.trigger("collapse_floor_at_04", "collapse_floor", (9, 1), (20, 31))
at4.passage(id="drop_at_04", kind="DROP", cell=[9, 32], span=[20, 112], fall_px=2700.0)
R("ash_terrace_05", "hand", 40, 30).fill(1, 1, 38, 28) \
    .exit("w", "left", 3, 28, "ash_terrace_04", "e").exit("e", "right", 3, 28, "bone_shelf_00", "w") \
    .den("den_at_05_0", (20, 28), "arc_warden")
at6 = R("ash_terrace_06", "hand", 48, 34).fill(1, 1, 46, 32).fill(18, 30, 27, 30, "#")
at6.exit("e", "right", 21, 32, "ash_terrace_03", "sw").exit("w", "left", 7, 32, "seed_vault_00", "e")
at6.trigger("collapse_floor_at_06", "collapse_floor", (18, 1), (10, 30))

# ---------------- reg_bone_shelf (doll) ----------------
bs0 = R("bone_shelf_00", "doll", 56, 40, "place.tea_stair").fill(1, 1, 54, 38)
bs0.exit("w", "left", 13, 38, "ash_terrace_05", "e").exit("e", "right", 21, 38, "bone_shelf_01", "w")
bs0.passage(id="step_bs_00_up", kind="STEP", cell=[36, 25], span=[6, 14], height_px=290.0)
bs0.tether("fix.butler", "arc_maw", (20, 38), "hand")
R("bone_shelf_01", "doll", 56, 30).fill(1, 1, 54, 28) \
    .exit("w", "left", 11, 28, "bone_shelf_00", "e").exit("e", "right", 11, 28, "bone_shelf_02", "w") \
    .shelter("shelter_bs_01", (8, 28)).passage(id="wall_bs_01_a", kind="BREAK", cell=[44, 1], span=[3, 28], hp=4)
bs2 = R("bone_shelf_02", "doll", 64, 45).fill(1, 1, 62, 25).fill(1, 27, 62, 43).fill(24, 26, 41, 26)
bs2.fill(43, 35, 48, 35, "=")
bs2.exit("w", "left", 8, 25, "bone_shelf_01", "e").exit("e", "right", 26, 43, "bone_shelf_03", "w")
bs2.passage(**gap("gap_bs_02_fit", (24, 26), (18, 18), "FIT")).den("den_bs_02_0", (32, 43), "arc_anchor")
R("bone_shelf_03", "doll", 48, 30).fill(1, 1, 46, 28) \
    .exit("w", "left", 11, 28, "bone_shelf_02", "e").exit("e", "right", 11, 28, "bone_shelf_04", "w")
bs4 = R("bone_shelf_04", "doll", 56, 39).fill(1, 1, 54, 28).fill(1, 30, 54, 37).fill(30, 29, 36, 29)
bs4.fill(38, 34, 41, 34, "=")
bs4.exit("w", "left", 11, 28, "bone_shelf_03", "e").exit("e", "right", 30, 37, "bone_shelf_05", "w")
bs4.trigger("salt_dust_bed_bs_04", "salt_dust_bed", (10, 20), (10, 9))
bs4.passage(**gap("gap_bs_04_tight", (30, 29), (7, 9), "TIGHT"))
bs5 = R("bone_shelf_05", "doll", 48, 40).fill(1, 1, 46, 19).fill(1, 21, 46, 38).fill(20, 20, 27, 20)
bs5.exit("w", "left", 12, 19, "bone_shelf_04", "e").exit("e", "right", 21, 38, "bone_shelf_06", "w")
bs5.passage(id="plate_bs_05", kind="PRESS", cell=[20, 20], span=[8, 1], mass_required=0.80)
bs5.den("den_bs_05_0", (10, 19), "arc_maw")
bs6 = R("bone_shelf_06", "doll", 40, 88).fill(1, 1, 38, 18).fill(22, 19, 29, 19).fill(10, 20, 29, 86).fill(1, 61, 38, 86)
bs6.exit("w", "left", 1, 18, "bone_shelf_05", "e").exit("e", "right", 61, 86, "seed_vault_00", "w")
bs6.trigger("collapse_floor_bs_06", "collapse_floor", (10, 1), (12, 19))
bs6.passage(id="drop_bs_06", kind="DROP", cell=[10, 20], span=[20, 67], fall_px=1600.0)

# ---------------- reg_seed_vault (hand) ----------------
sv0 = R("seed_vault_00", "hand", 60, 70, "place.mirror_march").fill(20, 1, 58, 28).fill(1, 30, 58, 65).fill(30, 29, 40, 29)
for y in (35, 41, 47, 53, 59):
    sv0.fill(30, y, 40, y, "=")
sv0.exit("w", "left", 40, 65, "bone_shelf_06", "e").exit("e", "right", 3, 28, "ash_terrace_06", "w")
sv0.exit("e2", "right", 40, 65, "seed_vault_01", "w")
sv0.trigger("salt_dust_bed_sv_00", "salt_dust_bed", (6, 50), (10, 16)).tether("fix.mirror", "arc_warden", (48, 28), "hand")
sv1 = R("seed_vault_01", "hand", 60, 37).fill(1, 1, 58, 29).fill(36, 31, 58, 35).fill(40, 30, 45, 30)
sv1.exit("w", "left", 4, 29, "seed_vault_00", "e2").exit("e", "right", 31, 35, "seed_vault_02", "w")
sv1.trigger("narrow_cradle_sv_01", "narrow_cradle", (14, 20), (8, 10))
sv1.passage(**gap("gap_sv_01_tight", (40, 30), (6, 6), "TIGHT"))
for i, x in enumerate((15, 18, 21)):
    sv1.den("den_sv_01_%d" % i, (x, 29), "arc_skitter")
R("seed_vault_02", "hand", 40, 16).fill(1, 1, 38, 14) \
    .exit("w", "left", 10, 14, "seed_vault_01", "e").exit("e", "right", 3, 14, "seed_vault_03", "w")
R("seed_vault_03", "hand", 40, 16).fill(1, 1, 38, 14) \
    .exit("w", "left", 3, 14, "seed_vault_02", "e").exit("e", "right", 3, 14, "seed_vault_04", "w") \
    .shelter("shelter_sv_03", (20, 14))
sv4 = R("seed_vault_04", "hand", 40, 83).fill(1, 1, 38, 14).fill(20, 15, 27, 81).fill(1, 72, 38, 81)
sv4.exit("w", "left", 3, 14, "seed_vault_03", "e").exit("e", "right", 72, 81, "filter_bed_01", "nw")
sv4.passage(id="drop_sv_04", kind="DROP", cell=[20, 15], span=[8, 67], fall_px=1600.0)

REGIONS = [
    ("reg_filter_bed", "여과층", ["filter_bed_%02d" % i for i in range(6)], [
        ("filter_bed_00", "filter_bed_01", ""), ("filter_bed_01", "filter_bed_00", ""),
        ("filter_bed_01", "filter_bed_02", ""), ("filter_bed_02", "filter_bed_01", ""),
        ("filter_bed_02", "filter_bed_03", "step_fb_02_up"), ("filter_bed_03", "filter_bed_02", ""),
        ("filter_bed_03", "filter_bed_04", ""), ("filter_bed_04", "filter_bed_03", ""),
        ("filter_bed_04", "filter_bed_05", "wall_fb_04_a"), ("filter_bed_05", "filter_bed_04", "wall_fb_04_a"),
        ("filter_bed_05", "ash_terrace_00", "")]),
    ("reg_ash_terrace", "재해단", ["ash_terrace_%02d" % i for i in range(7)], [
        ("ash_terrace_00", "filter_bed_05", ""), ("ash_terrace_00", "ash_terrace_01", ""),
        ("ash_terrace_01", "ash_terrace_00", ""), ("ash_terrace_01", "ash_terrace_02", "gap_at_01_wide"),
        ("ash_terrace_02", "ash_terrace_01", "gap_at_01_wide"), ("ash_terrace_02", "ash_terrace_03", ""),
        ("ash_terrace_03", "ash_terrace_02", ""), ("ash_terrace_03", "ash_terrace_04", "gap_at_03_fit"),
        ("ash_terrace_04", "ash_terrace_03", "gap_at_03_fit"), ("ash_terrace_04", "ash_terrace_05", "drop_at_04"),
        ("ash_terrace_03", "ash_terrace_06", "drop_at_03"), ("ash_terrace_05", "bone_shelf_00", ""),
        ("ash_terrace_06", "seed_vault_00", "")]),
    ("reg_bone_shelf", "골격단", ["bone_shelf_%02d" % i for i in range(7)], [
        ("bone_shelf_00", "ash_terrace_05", ""), ("bone_shelf_00", "bone_shelf_01", "step_bs_00_up"),
        ("bone_shelf_01", "bone_shelf_00", ""), ("bone_shelf_01", "bone_shelf_02", "wall_bs_01_a"),
        ("bone_shelf_02", "bone_shelf_01", "wall_bs_01_a"), ("bone_shelf_02", "bone_shelf_03", "gap_bs_02_fit"),
        ("bone_shelf_03", "bone_shelf_02", "gap_bs_02_fit"), ("bone_shelf_03", "bone_shelf_04", ""),
        ("bone_shelf_04", "bone_shelf_03", ""), ("bone_shelf_04", "bone_shelf_05", "gap_bs_04_tight"),
        ("bone_shelf_05", "bone_shelf_04", "gap_bs_04_tight"), ("bone_shelf_05", "bone_shelf_06", "plate_bs_05"),
        ("bone_shelf_06", "seed_vault_00", "drop_bs_06")]),
    ("reg_seed_vault", "씨앗고고", ["seed_vault_%02d" % i for i in range(5)], [
        ("seed_vault_00", "ash_terrace_06", ""), ("seed_vault_00", "seed_vault_01", ""),
        ("seed_vault_01", "seed_vault_00", ""), ("seed_vault_01", "seed_vault_02", "gap_sv_01_tight"),
        ("seed_vault_02", "seed_vault_01", "gap_sv_01_tight"), ("seed_vault_02", "seed_vault_03", ""),
        ("seed_vault_03", "seed_vault_02", ""), ("seed_vault_03", "seed_vault_04", ""),
        ("seed_vault_04", "seed_vault_03", ""), ("seed_vault_04", "filter_bed_01", "drop_sv_04")]),
]

ARCHETYPES = {
    "arc_skitter": dict(axis_name="skitter", rung="speck", variant_rungs=["speck", "hand"], density=0.22, hp=1.0, move_speed=96.0, chase_speed_mult=1.0, think_period=0.16, sense_radius_px=260.0, hearing_radius_px=300.0, fov_deg=118.0, reaction_latency=[0.05, 0.14], aggression=0.20, courage=0.85, attack_range_ratio=0.22, attack_windup=0.22, attack_damage=1.0, body_parts=8, confined_only=False, graze_radius_px=0.0, pack_bonus_count=0,
                        lineage=[("arc_skitter", 0.3), ("arc_skitter", 0.3), ("arc_brood", 0.2), ("", 0.0)]),
    "arc_warden": dict(axis_name="warden", rung="hand", variant_rungs=["hand", "doll"], density=0.75, hp=2.4, move_speed=72.0, chase_speed_mult=1.0, think_period=0.28, sense_radius_px=420.0, hearing_radius_px=380.0, fov_deg=96.0, reaction_latency=[0.10, 0.25], aggression=0.55, courage=0.40, attack_range_ratio=0.20, attack_windup=0.34, attack_damage=1.0, body_parts=12, confined_only=False, graze_radius_px=40.0, pack_bonus_count=0,
                       lineage=[("arc_warden", 0.25), ("arc_warden", 0.25), ("arc_maw", 0.15), ("", 0.0)]),
    "arc_maw": dict(axis_name="maw", rung="hand", variant_rungs=["hand", "doll"], density=0.60, hp=1.8, move_speed=132.0, chase_speed_mult=1.25, think_period=0.20, sense_radius_px=520.0, hearing_radius_px=460.0, fov_deg=74.0, reaction_latency=[0.08, 0.18], aggression=0.95, courage=0.25, attack_range_ratio=0.18, attack_windup=0.30, attack_damage=1.0, body_parts=10, confined_only=False, graze_radius_px=0.0, pack_bonus_count=0,
                    lineage=[("arc_maw", 0.3), ("arc_maw", 0.2), ("", 0.0)]),
    "arc_anchor": dict(axis_name="anchor", rung="doll", variant_rungs=["doll"], density=1.20, hp=3.2, move_speed=84.0, chase_speed_mult=0.90, think_period=0.34, sense_radius_px=700.0, hearing_radius_px=520.0, fov_deg=110.0, reaction_latency=[0.16, 0.30], aggression=0.70, courage=0.60, attack_range_ratio=0.14, attack_windup=0.46, attack_damage=1.0, body_parts=11, confined_only=True, graze_radius_px=30.0, pack_bonus_count=0,
                       lineage=[("arc_anchor", 0.2), ("arc_anchor", 0.2), ("arc_anchor", 0.1), ("", 0.0)]),
    "arc_brood": dict(axis_name="brood", rung="speck", variant_rungs=["speck", "hand"], density=0.30, hp=1.2, move_speed=108.0, chase_speed_mult=1.15, think_period=0.22, sense_radius_px=300.0, hearing_radius_px=360.0, fov_deg=132.0, reaction_latency=[0.06, 0.16], aggression=0.35, courage=0.70, attack_range_ratio=0.22, attack_windup=0.26, attack_damage=0.6, body_parts=9, confined_only=False, graze_radius_px=90.0, pack_bonus_count=3,
                      lineage=[("arc_brood", 0.35), ("arc_skitter", 0.2), ("", 0.0)]),
}


def write(rel, data):
    path = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(data, ensure_ascii=False, indent=1) + "\n")


def main():
    for r in rooms.values():
        r.check()
    by_room = {r.id: r for r in rooms.values()}
    for r in rooms.values():
        for e in r.exits:
            o = by_room.get(e["to_room"])
            back = [b for b in (o.exits if o else []) if b["id"] == e["to_exit"]]
            if not back or back[0]["to_room"] != r.id or back[0]["to_exit"] != e["id"]:
                problems.append(f"{r.id}/{e['id']} unpaired"); continue
            opp = {"left": "right", "right": "left", "top": "bottom", "bottom": "top"}
            if opp[e["side"]] != back[0]["side"] or e["to"] - e["from"] != back[0]["to"] - back[0]["from"]:
                problems.append(f"{r.id}/{e['id']} side/length mismatch")
    if problems:
        print("\n".join(problems))
        sys.exit(1)
    write("schema_version.json", {"schema": 1, "content_seed": 418324771})
    write("regions/index.json", {"schema": 1, "regions": [g[0] for g in REGIONS], "start_room": "filter_bed_00", "start_shelter": "shelter_fb_00", "start_rung": "speck"})
    for rid, name, room_ids, links in REGIONS:
        write(f"regions/{rid}.json", {"schema": 1, "id": rid, "display_name": name,
                                      "rooms": [by_room[i].to_json() for i in room_ids],
                                      "links": [{"from": a, "to": b, "via": v} for a, b, v in links]})
    write("archetypes/index.json", {"schema": 1, "archetypes": list(ARCHETYPES.keys())})
    for aid, a in ARCHETYPES.items():
        d = {"schema": 1, "id": aid}
        d.update({k: v for k, v in a.items() if k != "lineage"})
        d["lineage"] = [{"archetype": x, "advance_chance": c} for x, c in a["lineage"]]
        write(f"archetypes/{aid}.json", d)
    print("rooms", len(rooms), "ok")


main()
