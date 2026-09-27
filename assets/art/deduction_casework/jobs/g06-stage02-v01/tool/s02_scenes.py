"""Stage 02 scene layouts (items = objects, characters = game placements only, exits)."""

from __future__ import annotations

from g06kit.iso import Iso
from g06kit.stage import write_scene
from s02_bg import FOYER, STUDY
from s02_common import PPM, S

IOF = Iso(FOYER["origin"], FOYER["k"], PPM)
IOS = Iso(STUDY["origin"], STUDY["k"], PPM)


def _r(p):
    return [round(p[0], 1), round(p[1], 1)]


def foyer():
    fd, dd = FOYER["front_door"], FOYER["dining_door"]
    items = [{"asset": "obj_s02_umbrella_stand", "at": _r(IOF.p(1.9, 0.3)), "id": "umbrellas"},
             {"asset": "obj_s02_coat_rack", "at": _r(IOF.p(3.9, 0.35)), "id": "coats"},
             {"asset": "obj_s02_shoe_row", "at": _r(IOF.p(2.9, 1.1)), "id": "shoes", "interactive": True},
             {"asset": "obj_s02_bench_foyer", "at": _r(IOF.p(0.62, 1.65)), "id": "bench"},
             {"asset": "obj_s02_yona_bag", "at": _r(IOF.p(0.62, 1.95, 0.46)), "id": "yona_bag", "interactive": True,
              "sort_y": IOF.p(0.62, 1.65)[1] + 1},
             {"asset": "obj_s02_photo_table", "at": _r(IOF.p(0.52, 2.95)), "id": "photos", "interactive": True},
             {"asset": "obj_s02_wreath", "at": _r(IOF.p(0.9, 4.95)), "id": "wreath"},
             {"asset": "obj_s02_lectern_book", "at": _r(IOF.p(1.7, 3.2)), "id": "attendance", "interactive": True}]
    exits = {"trans_foyer_to_dining": [IOF.p(0, dd[0], 2.4), IOF.p(0, dd[1], 2.4), IOF.p(0, dd[1], 0), IOF.p(0, dd[0], 0)]}
    hot = {"hotspot_foyer_attendance": "obj_s02_lectern_book -> cu_s02_attendance",
           "hotspot_foyer_photos": "obj_s02_photo_table -> cu_s02_photo_young / _wedding / _family",
           "hotspot_foyer_yona_bag": "obj_s02_yona_bag -> cu_s02_yona_bag_open, cu_s02_funeral_card, "
                                     "cu_s02_preservation_cover",
           "hotspot_foyer_shoes": "obj_s02_shoe_row -> cu_s02_shoe_soles"}
    return write_scene(S, "scene_s02_foyer", "bg_s02_foyer", items, [], exits, hot)


def dining():
    items = [{"asset": "obj_s02_chair_family", "at": [720, 1040], "id": "chair_helen"},
             {"asset": "obj_s02_chair_family", "at": [1280, 1040], "id": "chair_luca"},
             {"asset": "obj_s02_chair_family", "at": [1840, 1040], "id": "chair_eva"},
             {"asset": "obj_s02_dining_table", "at": [1280, 1180], "id": "table"},
             {"asset": "obj_s02_setting_guest", "at": [1840, 940], "id": "guest_setting", "interactive": True,
              "sort_y": 1181},
             {"asset": "obj_s02_teacup", "at": [800, 952], "id": "silla_cup", "interactive": True, "sort_y": 1181},
             {"asset": "obj_s02_seat_plan", "at": [1080, 905], "id": "seat_plan", "interactive": True, "sort_y": 1181},
             {"asset": "obj_s02_chair_silla", "at": [720, 1330], "id": "chair_silla"},
             {"asset": "obj_s02_chair_peter", "at": [1280, 1330], "id": "chair_peter"},
             {"asset": "obj_s02_chair_guest", "at": [2010, 1390], "id": "chair_guest", "interactive": True}]
    chars = [{"asset": "chr_s02_helen_stand", "at": [300, 1330]},
             {"asset": "chr_s02_eva_stand", "at": [520, 1370]},
             {"asset": "chr_s02_luca_stand", "at": [2330, 1360]}]
    exits = {"trans_dining_to_foyer": [(90, 330), (330, 330), (330, 1000), (90, 1000)],
             "trans_dining_to_study": [(2250, 330), (2490, 330), (2490, 1000), (2250, 1000)],
             "trans_dining_to_service": [(1600, 380), (1760, 380), (1760, 1000), (1600, 1000)]}
    hot = {"hotspot_dining_guest_seat": "obj_s02_setting_guest + obj_s02_chair_guest -> cu_s02_guest_setting",
           "hotspot_dining_visual_seats": "the six chairs (obj_s02_chair_family x3, _silla, _peter, _guest)",
           "hotspot_dining_seat_plan": "obj_s02_seat_plan -> cu_s02_seat_plan",
           "hotspot_dining_silla_cup": "obj_s02_teacup -> cu_s02_teacup",
           "hotspot_dining_ruca_pocket": "chr_s02_luca_stand (right sleeve) -> cu_s02_pill_bottle, "
                                         "cu_s02_pharmacy_receipt, cu_s02_luca_notebook"}
    return write_scene(S, "scene_s02_dining", "bg_s02_dining", items, chars, exits, hot)


def study():
    wx0, wx1, wz0, wz1 = STUDY["window"]
    sd, md = STUDY["side_door"], STUDY["main_door"]
    items = [{"asset": "obj_s02_wall_safe", "at": _r(IOS.p(0, 3.375, 1.3)), "id": "safe", "layer": "floor",
              "interactive": True},
             {"asset": "obj_s02_window_soil", "at": _r(IOS.p((wx0 + wx1) / 2, 0.06, wz0 + 0.01)), "id": "sill_soil",
              "layer": "floor", "interactive": True},
             {"asset": "obj_s02_sofa", "at": _r(IOS.p(2.6, 2.3)), "id": "sofa"},
             {"asset": "obj_s02_desk_will", "at": _r(IOS.p(1.6, 3.9)), "id": "desk", "interactive": True}]
    chars = [{"asset": "chr_s02_silla_slumped", "at": _r(IOS.p(3.05, 2.3))}]
    exits = {"trans_study_to_dining": [IOS.p(0, md[0], 2.35), IOS.p(0, md[1], 2.35), IOS.p(0, md[1], 0), IOS.p(0, md[0], 0)],
             "trans_study_to_service": [IOS.p(sd[0], 0, 2.1), IOS.p(sd[1], 0, 2.1), IOS.p(sd[1], 0, 0), IOS.p(sd[0], 0, 0)],
             "trans_study_to_grave": [IOS.p(wx0, 0, wz1), IOS.p(wx1, 0, wz1), IOS.p(wx1, 0, wz0), IOS.p(wx0, 0, wz0)]}
    hot = {"hotspot_study_record_gap": "obj_s02_wall_safe -> cu_s02_safe_gap",
           "hotspot_study_will": "obj_s02_desk_will -> cu_s02_will",
           "hotspot_study_silla": "chr_s02_silla_slumped",
           "hotspot_study_window_sill": "obj_s02_window_soil -> cu_s02_window_soil"}
    return write_scene(S, "scene_s02_study", "bg_s02_study", items, chars, exits, hot)


def service():
    items = [{"asset": "obj_s02_key_board", "at": [1850, 300], "id": "key_board", "layer": "floor", "interactive": True},
             {"asset": "obj_s02_butler_desk", "at": [1850, 1250], "id": "desk"},
             {"asset": "obj_s02_payroll_ledger", "at": [1690, 986], "id": "payroll", "interactive": True, "sort_y": 1251}]
    chars = [{"asset": "chr_s02_peter_stand", "at": [2330, 1310]}]
    exits = {"trans_service_to_dining": [(60, 360), (300, 360), (300, 1040), (60, 1040)],
             "trans_service_to_study": [(560, 380), (820, 380), (820, 1040), (560, 1040)]}
    hot = {"hotspot_service_peter": "chr_s02_peter_stand",
           "hotspot_service_key_list": "obj_s02_key_board + obj_s02_butler_desk (spec chart) -> cu_s02_key_spec",
           "hotspot_service_payroll": "obj_s02_payroll_ledger -> cu_s02_payroll"}
    return write_scene(S, "scene_s02_service", "bg_s02_service", items, chars, exits, hot)


def grave():
    items = [{"asset": "obj_s02_gravestones", "at": [560, 1130], "id": "stones"},
             {"asset": "obj_s02_footprint_trail", "at": [1060, 1252], "id": "footprints", "layer": "floor",
              "interactive": True},
             {"asset": "obj_s02_case44_page", "at": [1480, 1290], "id": "case44_page", "layer": "floor", "interactive": True}]
    exits = {"trans_grave_to_study": [(1900, 360), (2240, 360), (2240, 820), (1900, 820)],
             "trans_grave_to_dining": [(2340, 560), (2520, 560), (2520, 1220), (2340, 1220)]}
    hot = {"hotspot_grave_footprints": "obj_s02_footprint_trail -> cu_s02_footprints",
           "hotspot_grave_case44": "obj_s02_case44_page -> cu_s02_case44"}
    return write_scene(S, "scene_s02_grave", "bg_s02_grave", items, [], exits, hot)


def write_all():
    return [foyer(), dining(), study(), service(), grave()]
