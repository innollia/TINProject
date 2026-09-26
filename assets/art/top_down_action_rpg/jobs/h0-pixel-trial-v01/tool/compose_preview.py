# -*- coding: utf-8 -*-
"""1280x720 게임 화면 미리보기 합성 (검수용, candidate).

도트 해상도(640x360)에서 x1 그림을 겹친 뒤 x2 nearest로 1280x720을 만든다.
배치는 모듈 코드 좌표(화면 좌표 / 2)를 따른다 - draw_background.py 머리말 참고.
- 추 지도(바닥 층): 판 가운데 = (70,125)
- 배급 카운터: 발 기준점 = (237,125)
- 도착 신고 게이트: 출구 e01(재 계단, H0 entry edge) 자리 (570,125)
- NPC Ilyra Senn 자리 (403,125): 대상 목록에 없어 비워 둠 (뒤 벽에 반환 창구 승강기)
- 플레이어: vector layer가 늘 그리는 가운데 (320,209)
- Ash Hound, 빈 반환 서식: 모듈에서 H0 필드에 없다(적은 R1 소속, 서식은 소지품) -> 오른쪽 아래 작은 칸에 따로
"""
from __future__ import annotations

import os
import sys

from PIL import Image

from pixkit import C, M, OUT, PREVIEW, Shape, Sprite, inspect

X1 = os.path.join(OUT, "x1")


def load(sub, name):
    return Image.open(os.path.join(X1, sub, name + ".png")).convert("RGBA")


def put(canvas, img, ground, pivot):
    canvas.alpha_composite(img, (ground[0] - pivot[0], ground[1] - pivot[1]))


def build(player_frame="player_stand_down"):
    bg = load("background", "bg_h0_undersign_exchange_arrival")
    cv = bg.copy()
    # 바닥 층 먼저
    put(cv, load("prop", "prop_h0_counterweight_map_matched"), (70, 125), (40, 26))
    # 그림자 -> 물체 (발 기준점 y 순서)
    put(cv, load("prop", "prop_h0_ration_counter_open_shadow"), (237, 125), (48, 78))
    put(cv, load("prop", "prop_h0_ration_counter_open"), (237, 125), (48, 78))
    put(cv, load("prop", "gate_g0_arrival_declaration_closed_shadow"), (570, 125), (44, 85))
    put(cv, load("prop", "gate_g0_arrival_declaration_closed"), (570, 125), (44, 85))
    put(cv, load("player", "player_shadow"), (320, 209), (24, 46))
    put(cv, load("player", player_frame), (320, 209), (24, 46))
    # 필드 밖 대상 칸 (오른쪽 아래)
    x0, y0, x1, y1 = 530, 304, 636, 356
    panel = Sprite(cv.width, cv.height)
    panel.fill(Shape(cv.width, cv.height).rect((x0, y0, x1, y1)), C["floor_shadow"])
    panel.fill(Shape(cv.width, cv.height).rect((x0 + 1, y0 + 1, x1 - 1, y0 + 1)), C["floor_light"])
    panel.fill(Shape(cv.width, cv.height).rect((x0 + 72, y0 + 4, x0 + 72, y1 - 4)), C["floor_joint"])
    panel.outline(M["bronze"]["base"])
    Sprite.outline(panel, C["ink"])
    cv.alpha_composite(panel.img)
    put(cv, load("enemy", "enemy_ash_hound_shadow"), (x0 + 36, y1 - 3), (32, 46))
    put(cv, load("enemy", "enemy_ash_hound_stand_left"), (x0 + 36, y1 - 3), (32, 46))
    put(cv, load("item", "item_blank_return_form"), (x0 + 89, y0 + 38), (12, 22))
    return cv


def main(args):
    cv = build()
    big = cv.resize((1280, 720), Image.NEAREST)
    os.makedirs(PREVIEW, exist_ok=True)
    path = os.path.join(PREVIEW, "h0_screen_preview_1280x720.png")
    big.convert("RGB").save(path)
    print(path)
    # 검수용 부분 확대 (스크래치)
    print(inspect([cv.crop((150, 30, 400, 250))], "check_preview_zoom_left", zoom=3, pad=0))
    print(inspect([cv.crop((400, 30, 640, 360))], "check_preview_zoom_right", zoom=3, pad=0))


if __name__ == "__main__":
    main(sys.argv[1:])
