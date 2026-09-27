"""Stage 02 close-ups: documents, the three family photographs (sepia), and the
visual comparisons (shoe soles / sill clay / footprints, safe gap / cover width)."""

from __future__ import annotations

from g06kit import F, box, ell, icon, limb, quad, recipe, rect
from g06kit import person as P
from g06kit.front import LC, LCS, LX, band, drop, frame_lines, scribble, sheet, text_rows
from g06kit.outfits import figure
from s02_chars import EVA, HELEN, LUCA, OSWALD, PETER
from s02_common import PAL, PAL_SEPIA, asset


def _r(asset_id, f, size, note, seed, palette=PAL):
    return recipe(asset_id, f, size, (size[0] / 2, size[1] / 2), palette, style="prop", seed=seed, note=note,
                  pivot_meaning="image centre")


# ------------------------------------------------------------------ A
@asset("cu_s02_attendance")
def cu_attendance():
    W, H = 1100, 760
    f = [drop([rect(70, 80, 1060, 720)]), F("cover", [rect(40, 50, 1060, 710)], "leather_black", 0.9, line=LC)]
    f += [F("page_l", [quad([(70, 70), (548, 80), (548, 690), (70, 690)])], "paper_cream", 1.0, line=LCS),
          F("page_r", [quad([(552, 80), (1030, 70), (1030, 690), (552, 690)])], "paper_cream", 1.1, line=LCS),
          F("black_edge", [rect(70, 70, 1030, 84)], "mourning_black", 1.2, kind="flat", opacity=0.8),
          F("columns", [rect(250, 120, 252, 660), rect(760, 120, 762, 660)], "ink_line", 1.3, kind="flat", opacity=0.35),
          F("ruling", [rect(100, 150 + i * 44, 520, 152 + i * 44) for i in range(11)] +
            [rect(580, 150 + i * 44, 1000, 152 + i * 44) for i in range(11)], "ink_line", 1.3, kind="flat", opacity=0.18)]
    for i in range(7):
        f.append(scribble(270, 140 + i * 44, 200 - (i % 3) * 30, name=f"n{i}", mat="ink_blue"))
    for i in range(3):
        f.append(scribble(780, 140 + i * 44, 180, name=f"g{i}", mat="ink_blue"))
    f.append(F("invite_box", [rect(580, 560, 1000, 640)], "paper_cream", 1.4, kind="flat", color="#b9ad90", line=LX))
    f.append(scribble(600, 600, 140, name="invite_count", mat="ink_line"))
    return _r("cu_s02_attendance", f, (W, H), "A1 dinner attendance book: family, lawyer, butler rows with names; three "
              "outside mourners; one 'outside guest' dinner invitation box (words = game text).", 501)


def _photo(asset_id, people, note, seed, bg_kind="studio"):
    """Old photograph (sepia palette): white border, people drawn inside the print."""
    W, H = 900, 700
    x0, y0, x1, y1 = 60, 60, 840, 640
    f = [drop([rect(x0 + 14, y0 + 16, x1 + 14, y1 + 16)]), F("print", [rect(x0, y0, x1, y1)], "paper_white", 0.9,
                                                             line=LCS),
         F("image", [rect(x0 + 34, y0 + 34, x1 - 34, y1 - 90)], "wall_green", 1.0, kind="flat", color="#6e6a5e")]
    if bg_kind == "studio":
        f.append(F("backdrop", [icon("cloud", 450, 250, 700, 380)], "paper_cream", 1.05, kind="flat", opacity=0.3,
                   clip_to="image"))
    elif bg_kind == "church":
        f.append(F("arch", [icon("doorway", 450, 300, 360, 420)], "stone_wall", 1.05, kind="flat", opacity=0.5,
                   clip_to="image"))
    else:
        f.append(F("mantel", [rect(x0 + 34, 330, x1 - 34, 360)], "wood_red", 1.05, kind="flat", clip_to="image"))
    for k, (spec, h_m, x, mirror) in enumerate(people):
        Hh = h_m * 230
        g = (x, y1 - 90 + 40)
        j = P.pose_stand(g, Hh, "3q" if not mirror else "3q")
        pf = figure(j, Hh, "3q", spec)
        for fm in pf:
            fm["name"] = f"p{k}_" + fm["name"]
            fm["z"] = fm.get("z", 0) + 2 + k * 0.001
            if fm.get("clip_to"):
                fm["clip_to"] = f"p{k}_" + fm["clip_to"]
        f += pf
    f.append(F("image_clip_edge", [rect(x0 + 34, y1 - 90, x1 - 34, y1 - 34)], "paper_white", 20.0, kind="flat"))
    f.append(F("frame_mask_l", [rect(0, 0, x0 + 34, H)], "paper_white", 20.0, kind="flat", opacity=0.0))
    f.append(F("scratches", [box(300, 200, 2, 120, rot=20), box(600, 380, 2, 90, rot=-10)], "paper_white", 21.0,
               kind="flat", opacity=0.6))
    f.append(F("corner_mounts", [icon("triangle", x0 + 20, y0 + 20, 50, 50, rot=180), icon("triangle", x1 - 20, y0 + 20, 50, 50,
                                                                                        rot=270)], "mourning_black", 22.0,
               kind="flat", opacity=0.85))
    return recipe(asset_id, f, (W, H), (450, 350), PAL_SEPIA, style="sprite", seed=seed, pivot_meaning="image centre",
                  note=note + " Sepia print; the people are part of the photograph (a picture object, not a sprite on a "
                              "background).")


KID = {"skin": "skin_light", "trousers": "suit_brown", "top": "shirt_white", "shoes": "shoe_brown",
       "hair": ("short", "hair_chestnut", {}), "brows": "hair_chestnut", "eye_size": 1.2}
GIRL = {"skin": "skin_light", "dress": "dress_navy", "top": "dress_navy", "legs": "stocking_dark", "shoes": "shoe_black",
        "hair": ("bob", "hair_chestnut", {"length": 0.5}), "brows": "hair_chestnut", "eye_size": 1.2, "dress_hem": 0.3}
YOUNG_OSWALD = dict(OSWALD, hair=("short", "hair_greybrown", {}), brows="hair_greybrown", age=0)
BRIDE = dict(EVA, dress="blouse_cream", top="blouse_cream", jacket=None, dress_hem=0.46)
FAM_HELEN = dict(HELEN, dress="dress_navy", top="dress_navy")


@asset("cu_s02_photo_young")
def photo_young():
    return _photo("cu_s02_photo_young", [(YOUNG_OSWALD, 1.73, 450, False), (GIRL, 1.15, 290, False), (KID, 1.05, 610, False)],
                  "A2-1: young Oswald with his small daughter (Helen) and son (Luca).", 502)


@asset("cu_s02_photo_wedding")
def photo_wedding():
    return _photo("cu_s02_photo_wedding", [(LUCA, 1.78, 380, False), (BRIDE, 1.66, 540, False)],
                  "A2-2 / VISUAL 2: Luca's wedding - the bride is Eva (same chignon and face; the silver ledger clip at "
                  "her waist already).", 503, bg_kind="church")


@asset("cu_s02_photo_family")
def photo_family():
    return _photo("cu_s02_photo_family", [(OSWALD, 1.73, 300, False), (FAM_HELEN, 1.7, 430, False), (LUCA, 1.78, 560, False),
                                          (EVA, 1.66, 690, False)],
                  "A2-3 / VISUAL 2: family group - Oswald, Helen (penlight), Luca, Eva (ledger clip). No Silla, no Yona.",
                  504, bg_kind="home")


@asset("cu_s02_yona_bag_open")
def cu_yona_bag():
    W, H = 1100, 700
    f = [drop([rect(120, 200, 1000, 640)]),
         F("bag", [rect(100, 180, 1000, 620)], "leather_black", 1.0, line=LC),
         F("inside", [rect(140, 200, 960, 420)], "@void_room", 1.1, kind="flat"),
         F("flap_open", [quad([(100, 180), (1000, 180), (940, 60), (160, 60)])], "leather_black", 0.9, color="#342d30", line=LC),
         F("card", [quad([(200, 150), (430, 140), (440, 330), (210, 340)])], "paper_white", 2.0, line=LCS),
         F("card_border", [quad([(200, 150), (430, 140), (432, 160), (202, 170)])], "mourning_black", 2.1, kind="flat"),
         F("cover", [rect(470, 110, 820, 400)], "card_olive", 2.0, color="#4a4a36", line=LCS),
         F("cover_label", [rect(520, 160, 770, 230)], "paper_ivory", 2.1, kind="flat", line=LX),
         F("key", [icon("key", 900, 300, 60, 150, rot=30)], "brass", 2.2, line=LCS),
         F("scissors", [icon("scissors", 300, 470, 120, 80, rot=-20)], "steel", 2.3, line=LCS)]
    f.append(scribble(230, 250, 180, name="card_hand", mat="ink_blue"))
    return _r("cu_s02_yona_bag_open", f, (W, H), "A3 contents: funeral card (black edge), the EMPTY preservation cover "
              "(label area), an old staff key, small nursing scissors.", 505)


@asset("cu_s02_funeral_card")
def cu_funeral_card():
    W, H = 900, 620
    f = sheet(50, 50, 850, 570, mat="paper_white") + [frame_lines(70, 70, 830, 550, 16, mat="mourning_black")]
    f += [F("cross", [icon("plus", 450, 140, 50, 60)], "mourning_black", 3.0, kind="flat")]
    for i in range(4):
        f.append(scribble(160, 250 + i * 60, 560 - i * 60, name=f"l{i}", mat="ink_blue"))
    f.append(scribble(560, 480, 160, name="sign", mat="ink_blue"))
    return _r("cu_s02_funeral_card", f, (W, H), "A3-1 funeral card with a black border, handwritten lines and Yona's "
              "signature (text = game text).", 506)


def _cover(f, x0, y0, w, h, thick):
    f += [F("cover_front", [rect(x0, y0, x0 + w, y0 + h)], "card_olive", 1.0, color="#4a4a36", line=LC),
          F("cover_spine", [rect(x0 + w, y0 + 10, x0 + w + thick, y0 + h - 10)], "card_olive", 1.1, color="#3a3a2a", line=LCS),
          F("cover_label", [rect(x0 + 60, y0 + 80, x0 + w - 60, y0 + 190)], "paper_ivory", 1.2, kind="flat", line=LX),
          F("string", [rect(x0 + w - 6, y0 + h * 0.45, x0 + w + thick + 30, y0 + h * 0.45 + 8)], "paper_cream", 1.3,
            kind="flat", color="#9c8f72"),
          F("string_press", [rect(x0 + w, y0 + h * 0.3, x0 + w + thick, y0 + h * 0.3 + 5),
                             rect(x0 + w, y0 + h * 0.6, x0 + w + thick, y0 + h * 0.6 + 5)], "@ink", 1.4, kind="flat",
            opacity=0.5)]
    return f


@asset("cu_s02_preservation_cover")
def cu_cover():
    W, H = 900, 760
    f = [drop([rect(160, 90, 720, 700)])]
    f = _cover(f, 150, 70, 520, 620, 70)
    f.append(F("ruler_tick", [rect(670 + i * 14, 710, 672 + i * 14, 730) for i in range(6)], "ink_line", 2.0, kind="flat",
               opacity=0.6))
    return _r("cu_s02_preservation_cover", f, (W, H), "A3-2 / hinge B: empty preservation cover ('Morrow Sanatorium / "
              "Case 44' label = game text). Its spine thickness (70 px) and the two string pressings match the gap in "
              "cu_s02_safe_gap.", 507)


@asset("cu_s02_safe_gap")
def cu_safe_gap():
    W, H = 1200, 760
    f = [F("safe_inner", [rect(40, 40, 1160, 720)], "metal_dark", 1.0, color="#1f2024", line=LC)]
    x = 120
    for i in range(12):
        if i == 7:
            gx = x
            x += 70
            continue
        f.append(F(f"folder{i}", [rect(x, 150 + (i % 3) * 14, x + 50, 690)], "paper_cream", 1.1 + i * 0.01,
                   color="#7e7056" if i % 2 else "#8c7c5c", line=LCS))
        x += 50 + 10
    f += [F("dust_line", [rect(100, 136, 1100, 150)], "@worn", 2.0, kind="flat", opacity=0.7),
          F("gap", [rect(gx, 136, gx + 70, 700)], "@void_room", 2.1, kind="flat", opacity=0.9),
          F("gap_marks", [rect(gx - 3, 300, gx + 5, 306), rect(gx + 65, 300, gx + 73, 306), rect(gx - 3, 480, gx + 5, 486),
                          rect(gx + 65, 480, gx + 73, 486)], "@ink", 2.2, kind="flat", opacity=0.8),
          F("shelf", [rect(60, 690, 1140, 720)], "metal_grey", 2.3, kind="flat", line=LCS)]
    return _r("cu_s02_safe_gap", f, (W, H), "C3 / VISUAL 4: inside the wall safe - one folder-width gap (70 px, same as "
              "the preservation cover's spine) where the dust line breaks, with string pressings on both sides.", 508)


@asset("cu_s02_shoe_soles")
def cu_shoe_soles():
    W, H = 1280, 620
    f = []
    for i in range(6):
        x = 120 + i * 205
        f.append(drop([ell(x + 8, 330, 150, 440)], 0.3, 8))
        f.append(F(f"sole{i}", [ell(x, 300, 140, 420)], "rubber", 1.0 + i * 0.01, line=LCS))
        if i == 3:   # Yona: deep narrow V grooves + grey clay
            f.append(F("v_grooves", [icon("triangle", x, 180 + k * 44, 70, 24, rot=180) for k in range(8)], "@ink", 1.2,
                       kind="flat", opacity=0.75))
            f.append(F("clay_caked", [icon("metaballs", x - 10, 430, 110, 90), icon("cloud", x + 20, 250, 80, 60)], "clay_grey",
                       1.3, kind="flat"))
        else:
            pat = {0: "grid_fine", 1: "list_unordered", 2: "grid_coarse", 4: "list_unordered", 5: "grid_fine"}[i]
            f.append(F(f"tread{i}", [icon(pat, x, 280, 90, 200)], "@ink", 1.2 + i * 0.01, kind="flat", opacity=0.35))
    return _r("cu_s02_shoe_soles", f, (W, H), "VISUAL 3: the six pairs' soles side by side (one sole each); only the 4th "
              "has the narrow V-groove tread and caked grey clay (compare cu_s02_window_soil, cu_s02_footprints).", 509)


# ------------------------------------------------------------------ B
@asset("cu_s02_seat_plan")
def cu_seat_plan():
    W, H = 900, 620
    f = sheet(50, 50, 850, 570)
    f += [F("table", [rect(250, 220, 650, 400)], "paper_ivory", 3.0, kind="flat", color="#c2b797", line=LCS),
          F("seats", [ell(320 + i * 130, 180, 70, 70) for i in range(3)] + [ell(320 + i * 130, 440, 70, 70) for i in range(3)],
            "paper_ivory", 3.1, kind="flat", color="#d0c6a8", line=LCS),
          F("guest_seat", [ell(580, 440, 70, 70)], "ink_red", 3.2, kind="flat", opacity=0.25)]
    for i in range(6):
        x, y = 320 + (i % 3) * 130, 180 if i < 3 else 440
        f.append(scribble(x - 40, y + 60 if i >= 3 else y - 60, 80, name=f"s{i}", mat="ink_line", seg=16, h=8))
    return _r("cu_s02_seat_plan", f, (W, H), "B1 seating card: six seats around the table, one labelled 'outside guest' "
              "(labels = game text).", 510)


@asset("cu_s02_guest_setting")
def cu_guest_setting():
    W, H = 1100, 700
    f = [F("cloth", [rect(40, 200, 1060, 680)], "tablecloth", 0.9, line=LC),
         F("plate", [ell(450, 460, 460, 180)], "paper_white", 1.0, line=LCS),
         F("bowl", [ell(450, 440, 300, 120)], "paper_white", 1.1, color="#b4ae9f", line=LCS),
         F("soup_skin", [ell(450, 436, 240, 88)], "@soup_skin", 1.2, kind="flat"),
         F("skin_wrinkles", [icon("wave", 420, 430, 160, 20), icon("wave", 470, 450, 120, 16)], "@soup", 1.3, kind="flat",
           opacity=0.6),
         F("glass", [rect(820, 170, 900, 420), ell(860, 430, 110, 34)], "glass_clear", 1.4, line=LCS, opacity=0.85),
         F("wine", [rect(828, 190, 892, 410)], "@wine", 1.5, kind="flat"),
         F("napkin", [icon("triangle", 170, 440, 180, 140)], "paper_white", 1.6, line=LCS),
         F("chair_top", [rect(40, 20, 1060, 150)], "wood_dark", 0.5, line=LC),
         F("wet_coat", [quad([(200, 0), (900, 0), (960, 190), (140, 190)])], "mourning_black", 0.6, line=LC),
         F("drops", [icon("droplet", 300 + i * 120, 160 + (i % 2) * 20, 22, 36) for i in range(5)], "@rain", 0.7, kind="flat",
           opacity=0.6)]
    return _r("cu_s02_guest_setting", f, (W, H), "B2 / hinge A close-up: soup skin, full wine glass, never-unfolded "
              "napkin, the rain-wet coat hanging on the pushed-back chair.", 511)


@asset("cu_s02_teacup")
def cu_teacup():
    W, H = 900, 640
    f = [drop([ell(450, 470, 700, 190)]),
         F("saucer", [ell(450, 460, 680, 180)], "paper_white", 1.0, line=LC),
         F("saucer_ring", [ell(450, 450, 400, 100)], "paper_white", 1.05, color="#b4ae9f", kind="flat"),
         F("powder", [icon("sponge", 190, 470, 120, 50), icon("metaballs", 230, 500, 70, 30)], "@powder", 1.1, kind="flat"),
         F("cup", [rect(290, 170, 610, 430), ell(450, 430, 320, 90)], "paper_white", 1.2, line=LC),
         F("cup_rim", [ell(450, 170, 320, 90)], "paper_white", 1.3, color="#c9c3b4", line=LCS),
         F("tea", [ell(450, 176, 270, 66)], "@soup", 1.4, kind="flat"),
         F("sediment", [ell(450, 184, 120, 20)], "@powder", 1.45, kind="flat", opacity=0.6),
         F("handle", [icon("ring", 660, 290, 110, 150)], "paper_white", 1.1, line=LC),
         F("print", [icon("fingerprint", 690, 280, 50, 60, rot=20)], "@joint_dark", 1.5, kind="flat", opacity=0.45)]
    return _r("cu_s02_teacup", f, (W, H), "B3 / hinge C: Silla's teacup - sediment in the tea, one person's print on the "
              "handle, white powder on the outer rim of the saucer (same look as the powder in cu_s02_pill_bottle).", 512)


@asset("cu_s02_pill_bottle")
def cu_pill_bottle():
    W, H = 700, 760
    f = [drop([rect(230, 180, 480, 700)]),
         F("bottle", [rect(220, 170, 480, 690), ell(350, 690, 260, 60)], "glass", 1.0, color="#5a3a22", line=LC, opacity=0.9),
         F("cap", [rect(250, 90, 450, 180)], "plastic_black", 1.1, line=LC),
         F("label_scraped", [rect(240, 300, 460, 520)], "paper_ivory", 1.2, kind="flat", line=LX),
         F("scrape", [icon("cloud", 350, 400, 200, 160)], "glass", 1.3, kind="flat", color="#5a3a22", opacity=0.8,
           clip_to="label_scraped"),
         F("powder", [icon("sponge", 350, 650, 140, 40)], "@powder", 1.4, kind="flat")]
    return _r("cu_s02_pill_bottle", f, (W, H), "B4-1: Luca's empty prescription bottle, label scraped off, a little white "
              "powder left at the bottom.", 513)


@asset("cu_s02_pharmacy_receipt")
def cu_receipt():
    W, H = 520, 960
    f = sheet(110, 40, 410, 920, mat="paper_white")
    f += [F("tear", [icon("triangle", 130 + i * 30, 920, 30, 20) for i in range(10)], "paper_white", 2.0, kind="flat"),
          text_rows(140, 380, 90, 3, 30), text_rows(140, 380, 260, 8, 36, name="items"),
          F("total_line", [rect(140, 600, 380, 604)], "ink_line", 3.0, kind="flat", opacity=0.6),
          text_rows(260, 380, 630, 2, 36, name="total"), F("stamp", [ell(300, 780, 120, 120)], "ink_blue", 3.1, kind="flat",
                                                           opacity=0.3, line=LCS)]
    return _r("cu_s02_pharmacy_receipt", f, (W, H), "B4-2: narrow pharmacy receipt with the same-day date and a pickup "
              "stamp (text = game text).", 514)


@asset("cu_s02_luca_notebook")
def cu_luca_notebook():
    W, H = 760, 900
    f = [drop([rect(120, 80, 680, 860)]), F("cover", [rect(100, 60, 660, 840)], "leather_brown", 0.9, line=LC),
         F("page", [rect(130, 80, 640, 820)], "paper_ivory", 1.0, line=LCS),
         F("ruling", [rect(160, 160 + i * 50, 610, 162 + i * 50) for i in range(12)], "ink_blue", 1.1, kind="flat",
           opacity=0.15)]
    for i, w in enumerate((300, 120, 380)):
        f.append(scribble(170, 250 + i * 50, w, name=f"l{i}", mat="ink_line"))
    f.append(F("time_ring", [icon("ring", 250, 300, 150, 60)], "ink_red", 2.0, kind="flat", opacity=0.6))
    return _r("cu_s02_luca_notebook", f, (W, H), "B4-3: Luca's pocket notebook - lawyer / 21:30 (circled) / father's "
              "papers (words = game text).", 515)


# ------------------------------------------------------------------ C
@asset("cu_s02_will")
def cu_will():
    W, H = 800, 1040
    f = sheet(70, 40, 730, 1000, mat="paper_white")
    f += [band(110, 80, 690, 130, color="#3e2a22"), text_rows(120, 680, 180, 14, 40),
          F("sign_line", [rect(420, 860, 680, 863)], "ink_line", 3.0, kind="flat", opacity=0.6),
          F("seal_blank", [ell(220, 870, 110, 110)], "paper_white", 3.1, kind="flat", color="#c9c3b4", line=LCS)]
    return _r("cu_s02_will", f, (W, H), "C2: the new will - printed clauses (game text), the signature line EMPTY and no "
              "seal (an unrevised document on this night).", 516)


@asset("cu_s02_window_soil")
def cu_window_soil():
    W, H = 1100, 600
    f = [F("sill", [rect(40, 200, 1060, 420)], "wood_dark", 0.9, line=LC, textured=True),
         F("sill_edge", [rect(40, 420, 1060, 470)], "wood_dark", 1.0, color="#30251a", line=LC),
         F("clay", [icon("cloud", 540, 300, 700, 170), icon("metaballs", 360, 320, 240, 90)], "clay_grey", 1.1, line=LCS),
         F("v_groove_print", [icon("triangle", 600, 300, 150, 60, rot=180), icon("triangle", 600, 262, 110, 40, rot=180)],
           "mud", 1.2, kind="flat", opacity=0.85),
         F("wet", [icon("droplet", 780, 320, 60, 30, rot=90), icon("droplet", 300, 280, 40, 20, rot=90)], "@rain", 1.3,
           kind="flat", opacity=0.35)]
    return _r("cu_s02_window_soil", f, (W, H), "C4 / VISUAL 3: grey wet clay on the study sill with one narrow V-groove "
              "print (no caption that it matches anything).", 517)


# ------------------------------------------------------------------ D
@asset("cu_s02_key_spec")
def cu_key_spec():
    W, H = 1000, 720
    f = sheet(50, 50, 950, 670)
    f += [band(80, 80, 920, 124, color="#3e2a22"), text_rows(100, 480, 170, 4, 40),
          F("door_drawing", [rect(560, 170, 880, 600)], "paper_ivory", 3.0, kind="flat", color="#c4b99b", line=LCS),
          F("lock_plate", [rect(820, 360, 860, 440)], "ink_line", 3.1, kind="flat", opacity=0.5),
          F("blade_outline", [icon("key_modern" if False else "key", 700, 400, 60, 200, rot=90)], "ink_line", 3.2, kind="flat",
            opacity=0.7),
          F("blade_notches", [rect(640 + i * 30, 386 - (i % 3) * 8, 652 + i * 30, 400) for i in range(5)], "paper_ivory", 3.3,
            kind="flat")]
    f.append(text_rows(100, 480, 380, 5, 40, name="rows_b"))
    return _r("cu_s02_key_spec", f, (W, H), "D2 (+D3 merged, v5.3): old staff-key spec card - key holders list and the "
              "side-door spec drawing with the old key's blade profile (compare with the key in cu_s02_yona_bag_open).",
              518)


@asset("cu_s02_payroll")
def cu_payroll():
    W, H = 1100, 760
    f = [drop([rect(70, 80, 1060, 720)]), F("cover", [rect(40, 50, 1060, 710)], "leather_brown", 0.9, line=LC),
         F("page_l", [quad([(70, 70), (548, 80), (548, 690), (70, 690)])], "paper_cream", 1.0, line=LCS),
         F("page_r", [quad([(552, 80), (1030, 70), (1030, 690), (552, 690)])], "paper_cream", 1.1, line=LCS),
         F("grid", [rect(90, 140 + i * 40, 1010, 142 + i * 40) for i in range(13)] +
           [rect(x, 140, x + 2, 660) for x in (300, 460, 760, 900)], "ink_line", 1.2, kind="flat", opacity=0.3)]
    for i in range(12):
        f.append(scribble(110 if i < 12 else 580, 160 + i * 40, 170, name=f"r{i}", mat="ink_line", h=8, seg=18, opacity=0.5))
    f.append(F("yona_row", [rect(90, 142 + 6 * 40, 1010, 180 + 6 * 40)], "@magnet_yellow", 1.3, kind="flat", opacity=0.15))
    f.append(scribble(920, 160 + 6 * 40, 80, name="key_mark", mat="ink_red"))
    return _r("cu_s02_payroll", f, (W, H), "D3 old payroll ledger: Yona Pale's row (nurse, the sanatorium) with the old "
              "staff-key receipt mark in the remarks column (words = game text).", 519)


# ------------------------------------------------------------------ E
@asset("cu_s02_footprints")
def cu_footprints():
    W, H = 1200, 600
    f = [F("mud", [rect(30, 60, 1170, 560)], "mud", 0.9, textured=True, line=LC),
         F("puddle", [ell(900, 420, 300, 80)], "glass_rain", 1.0, kind="flat", opacity=0.5)]
    for i in range(4):
        x = 180 + i * 260
        y = 250 + (60 if i % 2 else 0)
        f.append(F(f"print{i}", [ell(x, y, 150, 300, rot=80)], "mud", 1.1 + i * 0.01, kind="flat", color="#2c261f"))
        f.append(F(f"grooves{i}", [icon("triangle", x - 60 + k * 30, y, 26, 60, rot=90) for k in range(5)], "clay_grey",
                   1.2 + i * 0.01, kind="flat", opacity=0.7))
    return _r("cu_s02_footprints", f, (W, H), "E1: the cemetery-path prints - every print shows the narrow V-groove "
              "tread (one direction, toward the study window).", 520)


@asset("cu_s02_case44")
def cu_case44():
    W, H = 800, 1040
    f = sheet(70, 40, 730, 1000, mat="paper_cream")
    f += [band(110, 80, 690, 130, color="#4a4a36"), text_rows(120, 680, 180, 16, 42),
          F("wet_stain", [icon("cloud", 500, 700, 420, 300)], "@rain", 3.0, kind="flat", opacity=0.25),
          F("mud", [icon("metaballs", 200, 900, 200, 90)], "mud", 3.1, kind="flat", opacity=0.5)]
    return _r("cu_s02_case44", f, (W, H), "E2: the fallen Case 44 page, rain-wet, mud at the corner (1958 / Patient 44 "
              "text = game text).", 521)
