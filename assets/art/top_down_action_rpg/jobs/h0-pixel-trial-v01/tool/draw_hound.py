# -*- coding: utf-8 -*-
"""적 Ash Hound 도트 (candidate).

모듈 데이터(enemy_ash_hound.json): body_class composite, scale_class human, motion_signature ash_lunge,
role custodian/pursuit, institution_return_registry. 여기서 고른 모양(작성자 설계):
재로 뭉친 마른 사냥개, 옆구리의 불씨 균열과 불씨 눈, 반환 등록소의 청동 목줄·표찰.

캔버스 64x48 도트 -> x4 = 256x192 원본 -> 화면 128x96. 왼쪽을 보고 몸을 낮춘 추적 자세 1장.
피벗 = 원본 (128, 184) = 도트 (32, 46).
"""
from __future__ import annotations

import sys

from pixkit import C, M, Sprite, contact_shadow, inspect, save

W, H = 64, 48


def hound() -> Sprite:
    s = Sprite(W, H)
    far = {"base": M["ash_far"]["base"], "shadow": M["ash_far"]["shadow"], "light": M["ash_far"]["light"],
           "line": M["ash_far"]["line"]}
    # 먼 쪽 다리 (카메라에서 멀어 2도트 위, 어둡게)
    s.paint(s.shape().poly([(23, 29), (27, 29), (26, 36), (25, 41), (22, 41), (23, 36)]), far, shade=((1, 0),), light=None)
    s.paint(s.shape().rect((20, 41, 25, 42)), far, shade=((0, 1),), light=None, line=True)
    s.paint(s.shape().poly([(44, 26), (48, 26), (50, 32), (48, 36), (48, 41), (46, 41), (46, 36), (46, 32)]), far,
            shade=((1, 0),), light=None)
    s.paint(s.shape().rect((44, 41, 49, 42)), far, shade=((0, 1),), light=None, line=True)
    # 꼬리: 낮게 끌리는 재 뭉치
    tail = s.shape().poly([(49, 19), (55, 18), (60, 20), (63, 24), (62, 27), (58, 25), (54, 25), (51, 24)])
    s.paint(tail, "ash", shade=((0, 1), (1, 1)), light=((0, -1),), line=True)
    # 몸통: 깊은 가슴, 들어간 배, 높은 엉덩이
    body = s.shape().poly([(22, 15), (30, 14), (38, 16), (45, 17), (50, 19), (53, 23), (52, 28), (48, 31), (43, 28),
                           (37, 27), (31, 31), (26, 34), (21, 32), (18, 27), (18, 19)])
    body.poly([(33, 15), (35, 12), (37, 16)]).poly([(40, 16), (42, 14), (44, 17)])
    body.poly([(27, 33), (29, 36), (31, 31)]).poly([(22, 32), (23, 35), (25, 33)])
    s.paint(body, "ash", shade=((0, 1), (0, 2), (1, 0)), light=((0, -1), (0, -2), (-1, 0)))
    # 눌린 재 판이 겹친 몸(composite): 옆구리 이음선
    s.px([(33, 19), (33, 20), (32, 21), (32, 22), (39, 19), (39, 20), (40, 21)], M["ash"]["shadow"])
    # 가까운 뒷다리: 굵은 허벅지, 뒤로 꺾인 뒷발목
    hind = s.shape().poly([(42, 21), (51, 22), (54, 28), (50, 33), (51, 38), (50, 43), (47, 43), (48, 38), (46, 33), (43, 28)])
    s.paint(hind, "ash", shade=((1, 0), (0, 1)), light=((-1, 0), (0, -1)), line=True)
    s.paint(s.shape().rect((45, 43, 51, 44)).rect((46, 45, 51, 45)), "ash", shade=((0, 1), (1, 0)), light=((0, -1),),
            line=True)
    # 가까운 앞다리
    fore = s.shape().poly([(20, 29), (25, 29), (24, 36), (23, 43), (20, 43), (21, 36)])
    s.paint(fore, "ash", shade=((1, 0),), light=((-1, 0),), line=True)
    s.paint(s.shape().rect((17, 43, 23, 44)).rect((17, 45, 22, 45)), "ash", shade=((0, 1), (1, 0)), light=((0, -1),),
            line=True)
    # 목 (갈기)
    neck = s.shape().poly([(16, 14), (23, 12), (29, 16), (28, 24), (21, 28), (15, 22)])
    neck.poly([(23, 12), (25, 9), (27, 14)]).poly([(18, 25), (18, 29), (22, 27)])
    s.paint(neck, "ash", shade=((1, 0), (0, 1)), light=((0, -1), (-1, -1)))
    s.px([(22, 17), (24, 19), (21, 21), (25, 22)], M["ash"]["shadow"])
    # 먼 귀 -> 머리 -> 가까운 귀 (뒤로 눕힌 귀 = 추적 중)
    s.paint(s.shape().poly([(18, 12), (25, 7), (23, 14)]), far, shade=((1, 0),), light=None, line=True)
    head = s.shape().poly([(2, 20), (8, 15), (12, 12), (18, 11), (22, 14), (23, 18), (19, 22), (14, 24), (8, 25),
                           (3, 24), (1, 22)])
    s.paint(head, "ash", shade=((0, 1), (1, 0)), light=((0, -1), (-1, -1)), line=True)
    s.paint(s.shape().poly([(15, 12), (22, 6), (20, 13)]), "ash", shade=((1, 0),), light=((0, -1),), line=True)
    s.px([(19, 9), (18, 10)], M["ash"]["shadow"])
    # 청동 목줄과 반환 등록소 표찰
    collar = s.shape().poly([(20, 16), (23, 15), (26, 24), (23, 25)])
    s.paint(collar, "bronze", shade=((1, 0),), light=((-1, 0),), line=True)
    s.paint(s.shape().rect((22, 26, 24, 28)), "bronze", shade=((1, 0), (0, 1)), light=((-1, -1),), line=True)
    # 입 (안쪽에 불씨), 코
    s.fill(s.shape().line([(3, 23), (12, 23)]), M["ash"]["line"])
    s.px([(10, 23), (11, 23)], M["ember"]["base"])
    s.px([(1, 21), (2, 21), (1, 22)], C["ink"])
    # 불씨 눈
    s.px([(11, 16), (12, 16)], M["ember"]["light"])
    s.px([(13, 16)], M["ember"]["base"])
    # 옆구리·허벅지의 불씨 균열 (가운데 밝게)
    for path in ([(28, 20), (30, 22), (30, 25), (32, 27)], [(36, 21), (37, 24)], [(46, 25), (48, 28), (47, 31)]):
        s.fill(s.shape().line(path), M["ember"]["base"])
    s.px([(30, 23), (30, 24), (48, 28), (36, 22)], M["ember"]["light"])
    s.outline()
    # 꼬리 끝에서 흩날리는 재 알갱이 (윤곽선 없이)
    s.px([(62, 18), (60, 16), (63, 21)], M["ash"]["light"])
    s.px([(58, 15)], M["ash_far"]["light"])
    return s


def shadow():
    return contact_shadow(W, H, (10, 40, 55, 47))


def main(args):
    spr = hound()
    made = [save(spr.img, "enemy_ash_hound_stand_left", sub="enemy"),
            save(shadow(), "enemy_ash_hound_shadow", sub="enemy")]
    print(inspect([spr.img], "check_ash_hound", zoom=8))
    for pair in made:
        print(pair[1])


if __name__ == "__main__":
    main(sys.argv[1:])
