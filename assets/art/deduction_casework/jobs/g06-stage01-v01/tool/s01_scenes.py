"""Stage 01 scene layouts: recipes/scene_s01_<region>.json.

items      = objects only (compose_preview.py draws these on the background)
characters = where the game puts each person sprite (NOT drawn in the preview:
             "캐릭터를 배경 위에 합친 이미지를 만들지 않는다")
exits      = polygon (background px) of each transition hotspot
hotspots   = which placed asset stands for each content hotspot id
"""

from __future__ import annotations

import json

from g06kit import person as P
from g06kit.iso import Iso
from s01_bg import LAB
from s01_common import PPM, REC

IO = Iso(LAB["origin"], LAB["k"], PPM)


def _mirror_offset(canvas_w, pivot, pt):
    """Offset from the (mirrored) sprite pivot to a point of the unmirrored drawing."""
    return (canvas_w - pt[0]) - (canvas_w - pivot[0]), pt[1] - pivot[1]


def _hands_mira():
    H = 1.64 * PPM
    g = (150, 392)
    j = P.pose_sit_floor(g, H, "3q", lean_back=14)
    P.arm(j, H, "n", "labcoat", "skin_light", 6.0, width=0.05)
    return _mirror_offset(420, g, j["hand_n"])


def _hands_grell():
    H = 1.77 * PPM
    g = (230, 520)
    j = P.pose_kneel(g, H, "3q")
    P.arm(j, H, "n", "shirt_white", "skin_mid", 6.0, width=0.05, hand=0.055)
    P.arm(j, H, "f", "shirt_white", "skin_mid", 2.0, width=0.05, hand=0.055)
    a = _mirror_offset(440, g, j["hand_n"])
    b = _mirror_offset(440, g, j["hand_f"])
    return ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)


def _r(p):
    return [round(p[0], 1), round(p[1], 1)]


def lab():
    mira = IO.p(2.4, 1.9)
    grell = IO.p(2.55, 3.05)
    ed = IO.p(0.45, 4.95)
    hx, hy = _hands_mira()
    gx, gy = _hands_grell()
    items = [
        {"asset": "obj_s01_stim_desk", "at": _r(IO.p(0.95, 0.35)), "id": "stim_desk"},
        {"asset": "obj_s01_printer_two_sheets", "at": _r(IO.p(1.78, 0.29)), "id": "printer", "interactive": True},
        {"asset": "obj_s01_task_board", "at": _r(IO.p(0.0, 3.6, 1.475)), "id": "task_board", "interactive": True,
         "layer": "floor"},
        {"asset": "obj_s01_wall_clock", "frame": "t0213", "at": _r(IO.p(0.0, 2.75, 2.15)), "id": "clock",
         "layer": "floor"},
        {"asset": "obj_s01_lab_bench", "at": _r(IO.p(1.65, 2.25)), "id": "bench", "interactive": True},
        {"asset": "obj_s01_bloody_gauze", "at": _r(IO.p(2.75, 2.35)), "id": "gauze", "interactive": True},
        {"asset": "obj_s01_first_aid_open", "at": _r((grell[0] + gx - 10, grell[1] - 12)), "id": "first_aid",
         "sort_y": grell[1] - 30},
        {"asset": "obj_s01_disinfect_floor", "at": _r((mira[0] - 150, mira[1] - 18)), "id": "disinfectant"},
        {"asset": "obj_s01_lens_case_broken", "at": _r((mira[0] + hx, mira[1] + hy)), "id": "lens_case",
         "interactive": True, "sort_y": mira[1] + 1},
    ]
    chars = [{"asset": "chr_s01_mira_seated_injured", "at": _r(mira)},
             {"asset": "chr_s01_grell_tending", "at": _r(grell)},
             {"asset": "chr_s01_ed_door", "at": _r(ed)}]
    exits = {"trans_lab_to_booth": [IO.p(1.75, 0, 2.1), IO.p(3.6, 0, 2.1), IO.p(3.6, 0, 1.0), IO.p(1.75, 0, 1.0)],
             "trans_lab_to_locker": [IO.p(0, 1.6, 2.1), IO.p(0, 2.5, 2.1), IO.p(0, 2.5, 0), IO.p(0, 1.6, 0)],
             "trans_lab_to_corridor": [IO.p(0, 4.5, 2.15), IO.p(0, 5.4, 2.15), IO.p(0, 5.4, 0), IO.p(0, 4.5, 0)]}
    hot = {"hotspot_lab_bench": "chr_s01_mira_seated_injured", "hotspot_lab_lens_case": "obj_s01_lens_case_broken",
           "hotspot_lab_stim_calibration": "obj_s01_printer_two_sheets#sheet_calibration",
           "hotspot_lab_stim_behavior": "obj_s01_printer_two_sheets#sheet_behavior",
           "hotspot_lab_task_board": "obj_s01_task_board", "hotspot_lab_grell_gauze": "chr_s01_grell_tending + "
           "obj_s01_bloody_gauze"}
    return "scene_s01_lab", "bg_s01_lab", items, chars, exits, hot


def booth():
    dy = 1330
    top = dy - 280 + 40 + 12   # desk top face
    items = [{"asset": "obj_s01_booth_desk", "at": [1290, dy], "id": "desk"},
             {"asset": "obj_s01_cctv_monitor", "at": [1040, top + 2], "id": "cctv_monitor", "interactive": True},
             {"asset": "obj_s01_eye_card", "at": [1160, top], "id": "eye_card", "interactive": True},
             {"asset": "obj_s01_recorder", "at": [1270, top + 2], "id": "recorder", "interactive": True},
             {"asset": "obj_s01_log_sheet", "at": [1392, top], "id": "log_sheet", "interactive": True},
             {"asset": "obj_s01_pager", "at": [1462, top + 2], "id": "pager", "interactive": True},
             {"asset": "obj_s01_eeg_printout", "at": [1540, top - 2], "id": "eeg"},
             {"asset": "obj_s01_booth_chair", "at": [1250, 1400], "id": "chair"},
             {"asset": "obj_s01_eeg_rack", "at": [2140, 1300], "id": "eeg_rack"}]
    exits = {"trans_booth_to_lab": [(110, 330), (400, 330), (400, 1156), (110, 1156)]}
    hot = {"hotspot_booth_eye_card": "obj_s01_eye_card", "hotspot_booth_recorder": "obj_s01_recorder",
           "hotspot_booth_log_sheet": "obj_s01_log_sheet", "hotspot_booth_grell_pager": "obj_s01_pager",
           "VISUAL 1 (no hotspot)": "obj_s01_cctv_monitor screen <- scene_s01_cctv_frame"}
    return "scene_s01_booth", "bg_s01_booth", items, [], exits, hot


def locker():
    slot_x = (1200.0 + 1406.67) / 2
    items = [{"asset": "obj_s01_locker_mira", "frame": "open", "at": [round(slot_x, 1), 1000], "id": "locker",
              "layer": "floor", "interactive": True},
             {"asset": "obj_s01_labcoat_hung", "at": [round(slot_x, 1), 352], "id": "labcoat", "layer": "floor",
              "interactive": True},
             {"asset": "obj_s01_notebook_shelf", "at": [round(slot_x, 1), 312], "id": "notebook", "layer": "floor",
              "interactive": True},
             {"asset": "obj_s01_roster_sheet", "at": [1905, 380], "id": "roster", "layer": "floor", "interactive": True},
             {"asset": "obj_s01_prep_table", "at": [1180, 1330], "id": "table"},
             {"asset": "obj_s01_elephant_model", "at": [960, 1110], "id": "elephant", "sort_y": 1331},
             {"asset": "obj_s01_name_cards", "at": [1110, 1104], "id": "name_cards", "interactive": True, "sort_y": 1331},
             {"asset": "obj_s01_lens_storage", "at": [1240, 1098], "id": "lens_storage", "sort_y": 1331},
             {"asset": "obj_s01_repair_card", "at": [1330, 1102], "id": "repair_card", "interactive": True,
              "sort_y": 1332},
             {"asset": "obj_s01_sketchbook", "at": [1452, 1106], "id": "sketchbook", "interactive": True,
              "sort_y": 1332}]
    exits = {"trans_locker_to_lab": [(150, 300), (440, 300), (440, 1020), (150, 1020)]}
    hot = {"hotspot_locker_cabinet": "obj_s01_locker_mira (closed|open)", "hotspot_locker_coat": "obj_s01_labcoat_hung",
           "hotspot_locker_notebook": "obj_s01_notebook_shelf", "hotspot_locker_sketchbook": "obj_s01_sketchbook",
           "hotspot_locker_repair_card": "obj_s01_repair_card", "hotspot_locker_name_cards": "obj_s01_name_cards",
           "hotspot_locker_roster": "obj_s01_roster_sheet"}
    return "scene_s01_locker", "bg_s01_locker", items, [], exits, hot


def corridor():
    items = [{"asset": "obj_s01_sink", "at": [760, 1088], "id": "sink"},
             {"asset": "obj_s01_disinfect_tool", "at": [690, 800], "id": "disinfect_tool", "interactive": True,
              "sort_y": 1089},
             {"asset": "obj_s01_guard_board", "at": [1360, 430], "id": "guard_board", "layer": "floor",
              "interactive": True},
             {"asset": "obj_s01_copier", "at": [2260, 1250], "id": "copier", "interactive": True}]
    exits = {"trans_corridor_to_lab": [(180, 300), (500, 300), (500, 1080), (180, 1080)]}
    hot = {"hotspot_corridor_instruments": "obj_s01_disinfect_tool", "hotspot_corridor_copier": "obj_s01_copier",
           "hotspot_corridor_guard_log": "obj_s01_guard_board"}
    return "scene_s01_corridor", "bg_s01_corridor", items, [], exits, hot


def cctv():
    return ("scene_s01_cctv_frame", "cu_s01_cctv_view", [], [{"asset": "chr_s01_mira_cctv_0134", "at": [468, 900]}],
            {}, {"VISUAL 1": "cu_s01_cctv_view + chr_s01_mira_cctv_0134 (shown in obj_s01_cctv_monitor)"})


def write_all():
    out = []
    for fn in (lab, booth, locker, corridor, cctv):
        name, bg, items, chars, exits, hot = fn()
        region = name.replace("scene_s01_", "")
        scene = {"status": "candidate",
                 "note": "Stage 01 layout. items = objects drawn by compose_preview.py; characters = placements for "
                         "the game only (never composited in review images); exits = transition hotspot polygons.",
                 "background": f"output/{bg}/{bg}.png", "scale": 0.5,
                 "items": items, "characters": chars,
                 "exits": {k: [_r(p) for p in v] for k, v in exits.items()},
                 "hotspots": hot,
                 "out": f"preview/scene_s01_{region}_bg_objects_1280x720.png"}
        (REC / f"{name}.json").write_text(json.dumps(scene, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        out.append(name)
    return out


if __name__ == "__main__":
    print(write_all())
