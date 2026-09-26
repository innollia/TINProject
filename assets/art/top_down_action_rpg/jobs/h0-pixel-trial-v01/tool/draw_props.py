# -*- coding: utf-8 -*-
"""H0 사물 4개 도트 (candidate).

모듈 데이터와의 대응
- 배급 카운터  = prop_h0_ration_counter, 층 prop, 초기 상태 ps_open (art_key prop_h0_counter_open)
- 추 지도      = prop_h0_counterweight_map, 층 floor, 초기 상태 ps_matched (art_key prop_h0_map_matched)
- 도착 신고 게이트 = gate_g0_arrival_declaration (모듈에서는 사물 파일이 없고 H0 출구 5개 전부의 gate_id)
- 빈 반환 서식 = item_blank_return_form (모듈에서는 필드 사물이 아니라 소지품, icon_key item_blank_return_form)

60도 시점: 윗면은 깊이 x0.866, 앞면은 높이 x0.5로 줄어 보인다. 빛은 왼쪽 위.
"""
from __future__ import annotations

import sys

from pixkit import C, M, Sprite, contact_shadow, inspect, save


def faces(mat):
    """윗면/앞면 색 묶음 (윗면이 가장 밝고, 앞면은 재질의 side 색)."""
    m = M[mat]
    top = {"base": m.get("light", m["base"]), "shadow": m["base"], "light": m.get("light", m["base"]),
           "line": m.get("line", C["ink"])}
    front = {"base": m.get("side", m["base"]), "shadow": m.get("side_shadow", m.get("shadow", m["base"])),
             "light": m["base"], "line": m.get("line", C["ink"])}
    return top, front


def block(s, x0, x1, top_y, front_y, bottom_y, mat):
    top, front = faces(mat)
    s.paint(s.shape().rect((x0, front_y, x1, bottom_y)), front, shade=((1, 0), (0, 1)), light=((-1, 0),), line=True)
    s.paint(s.shape().rect((x0, top_y, x1, front_y - 1)), top, shade=((1, 0),), light=((0, -1), (-1, 0)), line=True)
    # 윗면 앞 모서리 하이라이트
    s.fill(s.shape().line([(x0 + 1, front_y - 1), (x1 - 1, front_y - 1)]), M[mat].get("light", M[mat]["base"]))


def tin(s, x, y):
    """배급 통조림 하나 (윗면 타원 + 몸통). (x, y) = 윗면 왼쪽 위."""
    s.paint(s.shape().rect((x, y + 2, x + 5, y + 6)), "bronze", shade=((1, 0), (2, 0)), light=((-1, 0),), line=True)
    s.paint(s.shape().ell((x, y, x + 5, y + 3)), "bronze", shade=None, light=None, colors={"base": M["bronze"]["light"]},
            line=True)
    s.px([(x + 1, y + 4)], M["paper"]["base"])


def ration_counter() -> Sprite:
    W, H = 96, 80
    s = Sprite(W, H)
    # 뒤 창틀: 기둥 2개 + 청동 상인방
    block(s, 14, 21, 7, 10, 40, "stone_dark")
    block(s, 74, 81, 7, 10, 40, "stone_dark")
    s.paint(s.shape().rect((22, 30, 73, 40)), faces("stone")[1], shade=((0, 1),), light=None, line=True)
    # 창 안쪽 (열린 상태): 어두운 방, 선반, 배급 꾸러미
    s.fill(s.shape().rect((22, 14, 73, 29)), C["well_void"])
    s.fill(s.shape().rect((22, 14, 73, 15)), M["void"]["base"])
    for sy in (21, 28):
        s.fill(s.shape().rect((22, sy, 73, sy)), M["stone_dark"]["side_shadow"])
    for bx0, by, mat in ((25, 17, "paper"), (31, 18, "bronze"), (36, 17, "leather"), (47, 18, "paper"),
                         (54, 17, "bronze"), (61, 18, "paper"), (27, 24, "leather"), (40, 24, "paper"),
                         (58, 25, "bronze"), (66, 24, "leather")):
        s.paint(s.shape().rect((bx0, by, bx0 + 4, by + 3)), mat, shade=((1, 0),), light=((0, -1),),
                colors={"base": M[mat]["shadow"], "light": M[mat]["base"], "shadow": M["void"]["base"]})
    # 말아 올린 청동 셔터
    shutter = s.shape().rect((22, 10, 73, 14))
    s.paint(shutter, "bronze", shade=((0, 1),), light=((0, -1),), line=True)
    s.fill(s.shape().line([(23, 12), (72, 12)]), M["bronze"]["shadow"])
    # 상인방
    block(s, 11, 84, 3, 5, 9, "bronze_block")
    s.fill(s.shape().rect((42, 6, 53, 8)), M["paper"]["base"])
    s.fill(s.shape().line([(44, 7), (51, 7)]), M["paper_mark"]["base"])
    # 왼쪽 기둥의 빛바랜 공고문
    s.paint(s.shape().rect((15, 17, 20, 25)), "paper", shade=((1, 0), (0, 1)), light=None, line=True)
    s.px([(16, 19), (17, 19), (18, 19), (16, 21), (17, 21), (16, 23), (18, 23)], M["paper_mark"]["base"])
    # 카운터 본체: 돌 상판 + 앞면
    block(s, 6, 89, 41, 57, 75, "stone")
    s.fill(s.shape().rect((7, 56, 88, 57)), M["bronze"]["base"])
    s.fill(s.shape().line([(7, 56), (88, 56)]), M["bronze"]["light"])
    # 앞면의 배급 칸 3개 (가운데는 배급 투입구)
    for px0 in (12, 38, 64):
        s.paint(s.shape().rect((px0, 61, px0 + 19, 72)), faces("stone")[1], shade=((-1, 0), (0, -1)), light=((1, 0), (0, 1)),
                colors={"base": M["stone"]["side_shadow"], "shadow": M["stone_dark"]["side_shadow"],
                        "light": M["stone"]["side"]})
        s.fill(s.shape().rect((px0 + 8, 66, px0 + 11, 67)), M["bronze"]["light"])
    s.fill(s.shape().rect((42, 63, 53, 65)), C["well_void"])
    # 받침
    s.paint(s.shape().rect((4, 76, 91, 78)), faces("stone_dark")[1], shade=((0, 1), (1, 0)), light=((0, -1),), line=True)
    # 상판 위: 배급 통 더미, 전표, 장부
    tin(s, 12, 44)
    tin(s, 18, 46)
    tin(s, 15, 40)
    s.paint(s.shape().rect((40, 46, 50, 51)), "paper", shade=((1, 0), (0, 1)), light=None, line=True)
    s.paint(s.shape().rect((43, 44, 53, 49)), "paper", shade=((1, 0), (0, 1)), light=((0, -1),), line=True)
    s.px([(45, 46), (46, 46), (47, 46), (48, 46), (45, 47), (46, 47)], M["paper_mark"]["base"])
    s.paint(s.shape().rect((66, 45, 80, 52)), "leather", shade=((1, 0), (0, 1)), light=((0, -1),), line=True)
    s.fill(s.shape().rect((67, 50, 79, 51)), M["paper"]["shadow"])
    s.fill(s.shape().line([(73, 45), (73, 52)]), M["leather"]["shadow"])
    s.outline()
    return s


def counterweight_map() -> Sprite:
    """바닥에 박힌 추 지도(바닥 층). 고리 선반 도면 위에 추와 카드가 제자리(ps_matched)."""
    W, H = 80, 52
    s = Sprite(W, H)
    top, front = faces("stone_dark")
    # 바닥에 박힌 판: 앞 두께 1도트 + 청동 테 + 판
    s.paint(s.shape().rect((3, 44, 76, 44)), faces("bronze_block")[1], shade=None, light=None, line=True)
    s.paint(s.shape().rect((3, 3, 76, 43)), faces("bronze_block")[0], shade=((1, 0),), light=((0, -1), (-1, 0)), line=True)
    s.paint(s.shape().rect((6, 6, 73, 41)), top, shade=((-1, 0), (0, -1)), light=((1, 0), (0, 1)),
            colors={"base": M["stone_dark"]["base"], "shadow": M["stone_dark"]["shadow"], "light": M["stone_dark"]["light"]})
    cx, cy = 39, 23
    groove = M["stone_dark"]["shadow"]
    lip = M["stone_dark"]["light"]
    # 고리 선반 3줄 (새긴 홈 + 아래쪽 밝은 턱)
    for rx, ry in ((29, 15), (20, 10), (11, 6)):
        ring = s.shape().ell((cx - rx, cy - ry, cx + rx, cy + ry)).cut(s.shape().ell((cx - rx + 1, cy - ry + 1, cx + rx - 1, cy + ry - 1)))
        s.fill(ring.shifted(0, 1), lip)
        s.fill(ring, groove)
    # 다섯 출구로 가는 선
    exits = [(cx + 29, cy - 5), (cx - 29, cy + 5), (cx - 12, cy + 15), (cx + 12, cy + 15), (cx + 26, cy + 8)]
    for ex, ey in exits:
        s.fill(s.shape().line([(cx, cy), (ex, ey)]), groove)
    # 가운데 빈 왕관 우물
    s.fill(s.shape().ell((cx - 4, cy - 3, cx + 4, cy + 3)), M["well_inner"]["base"])
    s.fill(s.shape().ell((cx - 3, cy - 2, cx + 3, cy + 2)), C["well_void"])
    # 출구 자리의 카드 (모두 제자리)
    for ex, ey in exits:
        card = s.shape().rect((ex - 2, ey - 1, ex + 2, ey + 1))
        s.paint(card, "paper", shade=((1, 0), (0, 1)), light=None, line=M["paper"]["line"])
        s.px([(ex - 1, ey), (ex, ey)], M["paper_mark"]["base"])
    # 고리 위의 청동 추 (작은 원통)
    for wx, wy in ((cx - 20, cy - 3), (cx + 16, cy - 7), (cx + 8, cy + 9), (cx - 9, cy - 8)):
        s.paint(s.shape().rect((wx, wy, wx + 3, wy + 3)), "bronze", shade=((1, 0),), light=((-1, 0),), line=True)
        s.fill(s.shape().rect((wx, wy - 1, wx + 3, wy)), M["bronze"]["light"])
    s.outline()
    return s


def arrival_gate() -> Sprite:
    """도착 신고 게이트 (닫힌 창살). 가운데는 투명: 뒤 배경의 계단 입구가 보인다."""
    W, H = 88, 88
    s = Sprite(W, H)
    # 문턱 돌
    block(s, 3, 84, 77, 80, 85, "stone")
    # 기둥
    block(s, 6, 19, 12, 16, 79, "stone")
    block(s, 68, 81, 12, 16, 79, "stone")
    # 창살 (청동, 닫힘)
    for bx0 in range(22, 66, 6):
        s.paint(s.shape().rect((bx0, 18, bx0 + 1, 76)), "bronze", shade=((1, 0),), light=None, line=True)
        s.fill(s.shape().rect((bx0, 18, bx0 + 1, 19)), M["bronze"]["light"])
    for ry in (30, 58):
        s.paint(s.shape().rect((20, ry, 67, ry + 2)), "bronze", shade=((0, 1),), light=((0, -1),), line=True)
    s.paint(s.shape().rect((20, 73, 67, 76)), "bronze", shade=((0, 1),), light=((0, -1),), line=True)
    # 가운데 신고 자물판 (서식을 끼우는 틀)
    s.paint(s.shape().rect((38, 38, 49, 50)), "bronze", shade=((1, 0), (0, 1)), light=((-1, 0), (0, -1)), line=True)
    s.fill(s.shape().rect((41, 41, 46, 44)), M["paper"]["shadow"])
    s.fill(s.shape().rect((41, 47, 46, 47)), M["bronze"]["line"])
    # 상인방 + 신고 명판
    block(s, 2, 85, 5, 8, 15, "bronze_block")
    s.paint(s.shape().rect((33, 9, 54, 13)), "paper", shade=((1, 0), (0, 1)), light=None, line=True)
    s.fill(s.shape().line([(36, 11), (51, 11)]), M["paper_mark"]["base"])
    # 왼쪽 기둥 공고문 2장
    s.paint(s.shape().rect((8, 28, 15, 38)), "paper", shade=((1, 0), (0, 1)), light=None, line=True)
    s.px([(9, 30), (10, 30), (11, 30), (12, 30), (9, 32), (10, 32), (11, 32), (9, 34), (10, 34), (12, 34)], M["paper_mark"]["base"])
    s.paint(s.shape().rect((10, 41, 15, 46)), "paper", shade=((1, 0), (0, 1)), light=None, line=True)
    # 오른쪽 기둥 신고함 (투입구)
    s.paint(s.shape().rect((70, 38, 79, 48)), "bronze", shade=((1, 0), (0, 1)), light=((-1, 0), (0, -1)), line=True)
    s.fill(s.shape().rect((72, 41, 77, 41)), C["well_void"])
    s.px([(74, 45), (75, 45)], M["bronze"]["light"])
    # 기둥 아래 때
    s.fill(s.shape().rect((7, 74, 18, 76)), C["grime"])
    s.fill(s.shape().rect((69, 74, 80, 76)), C["grime"])
    s.outline()
    return s


def blank_return_form() -> Sprite:
    """빈 반환 서식 (소지품 아이콘). 칸은 비어 있고 도장도 없다."""
    W, H = 24, 24
    s = Sprite(W, H)
    sheet = s.shape().poly([(4, 2), (16, 2), (19, 5), (19, 21), (4, 21)])
    s.paint(sheet, "paper", shade=((1, 0), (0, 1)), light=((-1, 0), (0, -1)))
    s.paint(s.shape().poly([(16, 2), (16, 5), (19, 5)]), "paper", shade=None, light=None,
            colors={"base": M["paper"]["shadow"]}, line=M["paper"]["line"])
    mark = M["paper_mark"]["base"]
    s.fill(s.shape().rect((6, 4, 12, 5)), M["paper"]["line"])
    for ly in (8, 11):
        s.fill(s.shape().line([(6, ly), (17, ly)]), mark)
    s.fill(s.shape().rect((6, 14, 11, 19)), mark)
    s.fill(s.shape().rect((7, 15, 10, 18)), M["paper"]["light"])
    s.fill(s.shape().ell((13, 14, 17, 18)), mark)
    s.fill(s.shape().ell((14, 15, 16, 17)), M["paper"]["base"])
    s.outline()
    return s


def main(args):
    made = []
    items = [("prop_h0_ration_counter_open", ration_counter(), (2, 70, 93, 80)),
             ("prop_h0_counterweight_map_matched", counterweight_map(), None),
             ("gate_g0_arrival_declaration_closed", arrival_gate(), (1, 80, 86, 88)),
             ("item_blank_return_form", blank_return_form(), None)]
    for name, spr, sh in items:
        sub = "item" if name.startswith("item_") else "prop"
        made.append(save(spr.img, name, sub=sub))
        if sh is not None:
            made.append(save(contact_shadow(spr.w, spr.h, sh, alpha=125), name + "_shadow", sub=sub))
    print(inspect([i[1].img for i in items], "check_props", zoom=5))
    for pair in made:
        print(pair[1])


if __name__ == "__main__":
    main(sys.argv[1:])
