# -*- coding: utf-8 -*-
"""H0 The Undersign Exchange 첫 구역 배경 도트 (candidate).

640x360 도트 -> x4 nearest = 2560x1440 원본 (화면 1280x720에서 1도트 = 2px).
배치는 모듈 코드를 따른다 (화면 좌표를 2로 나눈 값):
- top_down_vector_layer.gd WORLD_ORIGIN (640,418) -> 가운데 (320,209)
- topology 'ring_shelf_well' 해시값: 고리 2개(반지름 67.5/103.5 -> 34/52), 선반 막대 5줄, 우물 (690,394) r24 -> (345,197) r12,
  가운데 원 r30 -> r15
- field_controller.gd _anchor_position + _world_mapping: 사물·출구 자리
  위 줄 y=125: 추 지도 x70, 배급 카운터 x237, NPC(Ilyra Senn) x403, 출구 e01 x570
  아래 줄 y=292: 출구 e02 x70, e03 x237, e04 x403, e05 x570
60도 시점: 바닥 원은 세로 x0.866 타원, 높이는 x0.5.
배경에 굽지 않은 것: 사물, 인물, 그림자(각 스프라이트가 따로 가진다).
"""
from __future__ import annotations

import random
import sys

from PIL import Image, ImageDraw, ImageFilter

from pixkit import C, M, Shape, Sprite, inspect, save

W, H = 640, 360
CENTER = (320, 209)
RINGS = (34, 52)
WELL = (345, 199, 12)  # 모듈 (345,197) 에서 가운데와의 세로 거리만 x0.866
CENTER_R = 15
BARS = [(156, 294), (182, 285), (209, 276), (235, 294), (262, 285)]  # (y, x_start) -> x_end 383
BAR_END = 383
TOP_ROW, BOTTOM_ROW = 125, 292
COLS = (70, 237, 403, 570)
WALL_TOP, WALL_BOTTOM = 26, 58
FY = 0.866


def ellipse_box(cx, cy, r, fy=FY):
    ry = round(r * fy)
    return (cx - r, cy - ry, cx + r, cy + ry)


def path_field():
    """사람이 많이 다닌 길의 세기(0..255): 가운데 <-> 게이트/카운터/아래 출구."""
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    cx, cy = CENTER
    for tx, ty in ((570, 118), (237, 130), (237, 292), (403, 292), (70, 292), (70, 125)):
        d.line([(cx, cy), (tx, ty)], fill=255, width=18)
    return mask.filter(ImageFilter.GaussianBlur(8)).load()


def floor(s: Sprite, rnd: random.Random):
    """돌바닥: 돌 한 장 단위로 색을 정한다(점 잡음 없이). 닳은 길 위의 돌은 밝은 worn 색."""
    ip = s.img.load()
    base, joint, lite, worn, dark = C["floor"], C["floor_joint"], C["floor_light"], C["worn"], C["floor_shadow"]
    wear = path_field()
    y = WALL_BOTTOM + 1
    while y < H:
        rh = 14
        x = -rnd.randint(0, 30)
        while x < W:
            sw = rnd.randint(22, 40)
            mx, my = min(W - 1, max(0, x + sw // 2)), min(H - 1, y + rh // 2)
            roll = rnd.random()
            col = base
            if wear[mx, my] / 255 > 0.35 + roll * 0.5:
                col = worn
            elif roll > 0.955:
                col = M["inlay"]["base"]
            for yy in range(y, min(H, y + rh)):
                for xx in range(max(0, x), min(W, x + sw)):
                    ip[xx, yy] = col
            # 몇 장에만 잔금 하나
            if rnd.random() < 0.18:
                kx, ky = x + rnd.randint(4, max(5, sw - 6)), y + rnd.randint(3, rh - 4)
                for k in range(rnd.randint(2, 4)):
                    if 0 <= kx + k < W and ky + k // 2 < H:
                        ip[kx + k, ky + k // 2] = joint
            # 이음매(왼쪽·위) + 빛 받는 모서리
            for yy in range(y, min(H, y + rh)):
                if 0 <= x < W:
                    ip[x, yy] = joint
                if 0 <= x + 1 < W and yy > y and col != worn:
                    ip[x + 1, yy] = lite
            x += sw
        for xx in range(W):
            ip[xx, y] = joint
        y += rh


def terrace_and_wall(s: Sprite, rnd: random.Random):
    st = M["stone"]
    sd = M["stone_dark"]
    # 위층(반환 창구 층) 바닥
    s.fill(Shape(W, H).rect((0, 0, W, WALL_TOP)), C["floor_shadow"])
    for x in range(0, W, 28):
        s.fill(Shape(W, H).line([(x, 19), (x, WALL_TOP)]), C["floor_joint"])
    s.fill(Shape(W, H).line([(0, 22), (W, 22)]), C["floor_joint"])
    # 위층 뒤편 기록 선반 (칸마다 종이 뭉치)
    for x0 in range(4, W, 44):
        cab = Shape(W, H).rect((x0, 0, x0 + 39, 17))
        s.paint(cab, {"base": sd["side"], "shadow": sd["side_shadow"], "light": sd["base"], "line": sd["line"]},
                shade=((1, 0), (0, 1)), light=((-1, 0),), line=True)
        for cy0 in (1, 9):
            for cx0 in range(x0 + 2, x0 + 36, 7):
                s.fill(Shape(W, H).rect((cx0, cy0, cx0 + 5, cy0 + 6)), C["well_void"])
                if rnd.random() < 0.75:
                    ph = rnd.randint(2, 4)
                    s.fill(Shape(W, H).rect((cx0, cy0 + 6 - ph, cx0 + 5, cy0 + 6)), M["paper"]["shadow"])
                    s.fill(Shape(W, H).rect((cx0, cy0 + 6 - ph, cx0 + 5, cy0 + 6 - ph)), M["paper"]["base"])
        s.fill(Shape(W, H).rect((x0, 18, x0 + 39, 18)), C["shadow_contact"])
    # 난간 (청동) + 벽 윗돌
    for x in range(8, W, 24):
        s.paint(Shape(W, H).rect((x, 20, x + 1, 25)), "bronze", shade=((1, 0),), light=None, line=True)
    s.fill(Shape(W, H).rect((0, 20, W, 20)), M["bronze"]["light"])
    s.fill(Shape(W, H).rect((0, 21, W, 21)), M["bronze"]["shadow"])
    s.fill(Shape(W, H).rect((0, WALL_TOP, W, WALL_TOP + 2)), st["light"])
    s.fill(Shape(W, H).rect((0, WALL_TOP + 3, W, WALL_TOP + 3)), st["base"])
    # 옹벽 앞면 (마름돌 쌓기)
    s.fill(Shape(W, H).rect((0, WALL_TOP + 4, W, WALL_BOTTOM)), st["side"])
    ip = s.img.load()
    for i, y0 in enumerate(range(WALL_TOP + 4, WALL_BOTTOM, 9)):
        off = 0 if i % 2 == 0 else 13
        for x in range(W):
            ip[x, y0] = st["side_shadow"]
        for x in range(-off, W, 26):
            for yy in range(y0, min(WALL_BOTTOM, y0 + 9)):
                if 0 <= x < W:
                    ip[x, yy] = st["side_shadow"]
                if 0 <= x + 1 < W and yy > y0:
                    ip[x + 1, yy] = st["base"]
    s.fill(Shape(W, H).rect((0, WALL_BOTTOM - 3, W, WALL_BOTTOM)), sd["side_shadow"])
    # 벽 공고문 (글자 없음)
    for nx in (30, 128, 166, 300, 336, 478, 612):
        ny = WALL_TOP + 8 + rnd.randint(0, 6)
        s.paint(Shape(W, H).rect((nx, ny, nx + 7, ny + 9)), "paper", shade=((1, 0), (0, 1)), light=None, line=True)
        for ly in range(ny + 2, ny + 8, 2):
            s.fill(Shape(W, H).line([(nx + 1, ly), (nx + rnd.randint(3, 6), ly)]), M["paper_mark"]["base"])
    # 반환 창구로 올라가는 추 승강기 (NPC 자리 뒤 벽)
    lx0, lx1 = 382, 426
    s.fill(Shape(W, H).rect((lx0, WALL_TOP, lx1, WALL_BOTTOM)), C["well_void"])
    s.fill(Shape(W, H).rect((lx0, WALL_TOP, lx1, WALL_TOP + 2)), M["void"]["base"])
    cage = Shape(W, H).rect((lx0 + 3, WALL_TOP + 6, lx1 - 3, WALL_BOTTOM))
    s.paint(cage, "bronze", shade=((1, 0),), light=((-1, 0),), line=True)
    s.fill(Shape(W, H).rect((lx0 + 5, WALL_TOP + 8, lx1 - 5, WALL_BOTTOM - 3)), M["well_inner"]["base"])
    for bx in range(lx0 + 8, lx1 - 4, 5):
        s.fill(Shape(W, H).rect((bx, WALL_TOP + 8, bx, WALL_BOTTOM - 3)), M["bronze"]["shadow"])
    s.fill(Shape(W, H).rect((lx0 + 5, WALL_BOTTOM - 2, lx1 - 5, WALL_BOTTOM)), M["bronze"]["light"])
    for cy in range(WALL_TOP, WALL_TOP + 6):
        s.px([(lx0 + 12, cy), (lx1 - 12, cy)], M["bronze"]["shadow"] if cy % 2 else M["bronze"]["light"])
    # 옆에 매달린 평형추
    s.fill(Shape(W, H).rect((lx1 + 1, WALL_TOP, lx1 + 8, WALL_BOTTOM)), C["well_void"])
    for cy in range(WALL_TOP, WALL_TOP + 14):
        s.px([(lx1 + 4, cy)], M["bronze"]["shadow"] if cy % 2 else M["bronze"]["light"])
    s.paint(Shape(W, H).rect((lx1 + 2, WALL_TOP + 14, lx1 + 7, WALL_TOP + 22)), "bronze_block",
            shade=((1, 0), (0, 1)), light=((-1, 0), (0, -1)), line=True)
    # 벽 밑 때 (바닥에 드리운 접촉 그늘)
    for y in range(WALL_BOTTOM + 1, WALL_BOTTOM + 5):
        for x in range(W):
            if rnd.random() < (WALL_BOTTOM + 5 - y) / 5:
                ip[x, y] = C["grime"] if y < WALL_BOTTOM + 3 else C["floor_shadow"]


def raised_band(s: Sprite, outer: Shape, inner: Shape, height: int, top: dict, face: dict, cut=None):
    """낮은 돌턱: 윗면(띠) + 카메라 쪽으로 보이는 옆면(바깥 앞쪽, 안쪽 먼 쪽)."""
    band = outer.copy().cut(inner)
    if cut is not None:
        band.cut(cut)
    sweep = Shape(W, H)
    for k in range(1, height + 1):
        sweep.add(band.shifted(0, k))
    sweep.cut(band)
    first = band.shifted(0, 1).cut(band)
    if cut is not None:
        sweep.cut(cut)
        first.cut(cut)
    s.fill(sweep, face["shadow"])
    s.fill(first, face["base"])
    s.paint(band, top, shade=((0, 1),), light=((0, -1),))
    return band


def rings_and_well(s: Sprite):
    cx, cy = CENTER
    wr = M["well_rim"]
    top = {"base": wr["base"], "shadow": wr["shadow"], "light": wr["light"]}
    face = {"base": wr["side"], "shadow": wr["side_shadow"]}
    wx, wy, r = WELL
    well_zone = Shape(W, H).ell(ellipse_box(wx, wy, r + 3))
    # 고리 선반 2줄 (낮은 돌 턱, 높이 2도트) - 우물 자리는 끊긴다
    for rr in RINGS:
        raised_band(s, Shape(W, H).ell(ellipse_box(cx, cy, rr)), Shape(W, H).ell(ellipse_box(cx, cy, rr - 3)), 2, top, face,
                    cut=well_zone)
    # 선반 막대 5줄 (바닥에 박힌 줄눈 띠) - 고리·우물·가운데 원은 비켜 간다
    avoid = Shape(W, H)
    for rr in RINGS:
        avoid.add(Shape(W, H).ell(ellipse_box(cx, cy, rr + 1)).cut(Shape(W, H).ell(ellipse_box(cx, cy, rr - 4))))
    avoid.add(well_zone).add(Shape(W, H).ell(ellipse_box(cx, cy, CENTER_R + 2)))
    for by, bx0 in BARS:
        by = round(cy + (by - cy) * FY)
        strip = Shape(W, H).rect((bx0, by, BAR_END, by)).cut(avoid)
        s.fill(strip, M["inlay"]["base"])
        s.fill(strip.shifted(0, 1).cut(avoid), C["floor_light"])
        s.fill(Shape(W, H).rect((BAR_END, by - 1, BAR_END + 1, by + 1)).cut(avoid), M["bronze"]["base"])
    # 가운데 원: 도착자가 서는 청동 표시
    ring = Shape(W, H).ell(ellipse_box(cx, cy, CENTER_R)).cut(Shape(W, H).ell(ellipse_box(cx, cy, CENTER_R - 1)))
    s.fill(ring.shifted(0, 1), M["bronze"]["shadow"])
    s.fill(ring, M["bronze"]["light"])
    # 빈 왕관 우물: 구멍(안쪽 벽 -> 어둠) 먼저, 그 위에 돌테(높이 3)
    outer = Shape(W, H).ell(ellipse_box(wx, wy, r + 2))
    inner = Shape(W, H).ell(ellipse_box(wx, wy, r - 1))
    s.fill(inner, M["well_inner"]["base"])
    s.fill(inner.copy().clip(Shape(W, H).ell(ellipse_box(wx, wy + 4, r - 2))), C["shadow_contact"])
    s.fill(inner.copy().clip(Shape(W, H).ell(ellipse_box(wx, wy + 6, r - 3))), C["well_void"])
    raised_band(s, outer, inner, 3, top, face)
    s.px([(wx - 6, wy - 7), (wx - 3, wy - 8), (wx + 4, wy - 8)], M["well_rim"]["shadow"])


def ash_stair(s: Sprite, cx: int, rnd: random.Random):
    """출구 e01 재 계단(R1로 내려감): 게이트 바로 뒤에서 벽 밑 굴로 내려가는 계단.

    멀어질수록 깊어지므로 가까운 단(아래)이 밝고 먼 단(위, 벽 쪽)이 어둡다.
    """
    x0, x1 = cx - 24, cx + 23
    st, sd = M["stone"], M["stone_dark"]
    # 벽의 굴 입구 (아치)
    arch = Shape(W, H).rect((x0 + 2, WALL_TOP + 14, x1 - 2, WALL_BOTTOM)).ell((x0 + 2, WALL_TOP + 5, x1 - 2, WALL_TOP + 24))
    rim = Shape(W, H).rect((x0, WALL_TOP + 12, x1, WALL_BOTTOM)).ell((x0, WALL_TOP + 3, x1, WALL_TOP + 26)).cut(arch)
    s.paint(rim, "stone", shade=((1, 0),), light=((-1, 0), (0, -1)),
            colors={"base": st["base"], "light": st["light"], "shadow": st["side_shadow"]})
    s.fill(arch, C["well_void"])
    # 계단 단: 가까운 쪽부터 (밝음 -> 어둠)
    tones = [st["light"], st["base"], st["side"], st["side_shadow"], sd["side"], sd["side_shadow"], M["well_inner"]["base"],
             C["shadow_contact"]]
    y = 121
    for n, col in enumerate(tones):
        top = max(WALL_BOTTOM + 1, y - 7)
        s.fill(Shape(W, H).rect((x0 + 1, top, x1 - 1, y)), col)
        # 단 코(가장자리) 한 줄은 조금 밝게, 바로 위 줄은 그늘
        nose = tones[max(0, n - 1)] if n else C["floor_light"]
        s.fill(Shape(W, H).rect((x0 + 1, y, x1 - 1, y)), nose)
        y = top - 1
        if y <= WALL_BOTTOM:
            break
    s.fill(Shape(W, H).rect((x0 + 1, WALL_BOTTOM + 1, x1 - 1, WALL_BOTTOM + 2)), C["well_void"])
    # 양옆 돌 난간턱
    for ex in (x0, x1):
        s.fill(Shape(W, H).rect((ex, WALL_BOTTOM + 1, ex, 121)), C["ink"])
    s.fill(Shape(W, H).rect((x0 - 2, WALL_BOTTOM + 1, x0 - 1, 121)), st["light"])
    s.fill(Shape(W, H).rect((x1 + 1, WALL_BOTTOM + 1, x1 + 2, 121)), st["side_shadow"])
    # 계단에 쌓인 재
    for _ in range(9):
        ax, ay = rnd.randint(x0 + 3, x1 - 5), rnd.randint(WALL_BOTTOM + 6, 118)
        s.fill(Shape(W, H).rect((ax, ay, ax + rnd.randint(1, 3), ay)), M["ash"]["light"])
    # 계단에서 가운데로 이어지는 재 발자국
    tx, ty = CENTER
    for k in range(1, 9):
        fx = round(cx + (tx - cx) * k / 11) + (2 if k % 2 else -2)
        fy = round(128 + (ty - 128) * k / 11)
        s.fill(Shape(W, H).rect((fx, fy, fx + 2, fy + 1)), M["ash"]["light"] if k < 5 else M["ash_far"]["light"])


def stairwell(s: Sprite, cx: int, cy: int, rnd: random.Random, ash: bool = False):
    """출구(passage): 바닥에 뚫린 내려가는 계단 입구, 청동 문턱."""
    x0, x1, y0, y1 = cx - 22, cx + 21, cy - 11, cy + 10
    st, sd = M["stone"], M["stone_dark"]
    bands = [(st["light"], 2), (st["side"], 2), (st["base"], 2), (st["side_shadow"], 2), (sd["base"], 2),
             (sd["side_shadow"], 2), (M["well_inner"]["base"], 2), (C["well_void"], 2)]
    y = y0 + 1
    for col, hgt in bands:
        s.fill(Shape(W, H).rect((x0 + 1, y, x1 - 1, min(y1 - 1, y + hgt - 1))), col)
        y += hgt
    if y <= y1 - 1:
        s.fill(Shape(W, H).rect((x0 + 1, y, x1 - 1, y1 - 1)), M["void"]["base"])
    # 양옆 벽의 그늘
    s.fill(Shape(W, H).rect((x0 + 1, y0 + 1, x0 + 2, y1 - 1)), C["shadow_contact"])
    s.fill(Shape(W, H).rect((x1 - 2, y0 + 1, x1 - 1, y1 - 1)), M["well_inner"]["base"])
    # 청동 문턱(먼 쪽)과 돌 테두리
    s.fill(Shape(W, H).rect((x0, y0 - 2, x1, y0)), M["bronze"]["base"])
    s.fill(Shape(W, H).rect((x0, y0 - 2, x1, y0 - 2)), M["bronze"]["light"])
    s.fill(Shape(W, H).rect((x0, y0 + 1, x0, y1)), C["ink"])
    s.fill(Shape(W, H).rect((x1, y0 + 1, x1, y1)), C["ink"])
    s.fill(Shape(W, H).rect((x0, y1, x1, y1)), st["light"])
    s.fill(Shape(W, H).rect((x0, y1 + 1, x1, y1 + 1)), C["floor_shadow"])
    if ash:
        # 재 계단에서 올라온 재: 작은 덩어리 + 가운데 쪽으로 이어지는 발자국
        for _ in range(16):
            ax = int(rnd.gauss(cx, 16))
            ay = int(rnd.gauss(cy + 8, 7))
            rw, rh = rnd.randint(2, 4), rnd.randint(1, 2)
            s.fill(Shape(W, H).ell((ax - rw, ay - rh, ax + rw, ay + rh)).cut(Shape(W, H).rect((x0, y0 - 2, x1, y1))),
                   M["ash"]["light"] if rnd.random() < 0.5 else M["ash_far"]["light"])
        tx, ty = CENTER
        for k in range(1, 9):
            fx = round(cx + (tx - cx) * k / 11) + (2 if k % 2 else -2)
            fy = round(cy + 14 + (ty - cy - 14) * k / 11)
            s.fill(Shape(W, H).rect((fx, fy, fx + 2, fy + 1)), M["ash"]["light"] if k < 5 else M["ash_far"]["light"])


def scraps(s: Sprite, rnd: random.Random):
    ip = s.img.load()
    for _ in range(14):
        x, y = int(rnd.gauss(237, 40)), int(rnd.gauss(150, 14))
        if WALL_BOTTOM + 4 < y < H - 2 and 0 < x < W - 3:
            for dx in range(rnd.randint(2, 3)):
                ip[x + dx, y] = M["paper"]["base"]
            ip[x, y + 1] = M["paper"]["shadow"]
    # 바닥 청동 배수판 몇 개
    for dx, dy in ((150, 210), (490, 215), (320, 330)):
        s.fill(Shape(W, H).rect((dx - 5, dy - 2, dx + 5, dy + 2)), M["bronze"]["shadow"])
        for k in range(dx - 4, dx + 5, 2):
            s.px([(k, dy - 1), (k, dy), (k, dy + 1)], M["bronze"]["base"])


def build() -> Sprite:
    rnd = random.Random(20260926)
    s = Sprite(W, H)
    s.fill(Shape(W, H).rect((0, 0, W, H)), C["floor"])
    floor(s, rnd)
    terrace_and_wall(s, rnd)
    rings_and_well(s)
    # 출구 5개: e01(재 계단, 게이트 뒤 벽 밑 굴) + 아래 줄 4개
    ash_stair(s, COLS[3], rnd)
    for x in COLS:
        stairwell(s, x, BOTTOM_ROW, rnd)
    scraps(s, rnd)
    return s


def main(args):
    s = build()
    p1, p4 = save(s.img, "bg_h0_undersign_exchange_arrival", sub="background")
    print(inspect([s.img], "check_bg_h0", zoom=2, pad=0))
    print(p4)


if __name__ == "__main__":
    main(sys.argv[1:])
