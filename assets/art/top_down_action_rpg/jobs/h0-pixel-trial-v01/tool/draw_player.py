# -*- coding: utf-8 -*-
"""플레이어 도트 (candidate).

캔버스 48x48 도트 -> x4 nearest = 192x192 원본 -> 1280x720 화면에서 96px.
피벗(발 기준점) = 원본 (96, 184) = 도트 (24, 46) 아래 가운데.
빛은 왼쪽 위. 바깥 윤곽선은 팔레트 ink.
"""
from __future__ import annotations

import sys

from pixkit import C, M, Sprite, contact_shadow, inspect, save

W = H = 48


def down(bob=0, lfoot=0, rfoot=0, larm=0, rarm=0) -> Sprite:
    """카메라 쪽(아래)을 보는 모습.

    bob: 몸 전체 위아래(-1 = 1도트 위로). lfoot/rfoot: 화면 왼쪽/오른쪽 발의 앞뒤(+ = 앞으로 = 화면 아래).
    larm/rarm: 손 위치(+ = 앞으로 나와 아래로).
    """
    s = Sprite(W, H)
    b = bob
    # 다리와 부츠 (코트 뒤)
    for x0, foot in ((18, lfoot), (26, rfoot)):
        leg = s.shape().rect((x0, 36 + b, x0 + 3, 42 + foot))
        s.paint(leg, "trouser", shade=((1, 0),), light=None)
        boot = s.shape().rect((x0 - 1, 42 + foot, x0 + 4, 44 + foot)).rect((x0, 45 + foot, x0 + 3, 45 + foot))
        s.paint(boot, "leather", shade=((1, 0), (0, 1)), light=((0, -1),), line=True)
    # 코트 몸통
    coat = s.shape().poly([(16, 21 + b), (31, 21 + b), (33, 29 + b), (34, 37 + b), (30, 38 + b),
                           (17, 38 + b), (13, 37 + b), (14, 29 + b)])
    s.paint(coat, "coat", shade=((1, 0), (2, 0), (0, 1)), light=((-1, 0),), line=True)
    # 어깨 윗면(60도 시점에서 보이는 위쪽 면)
    top = s.shape().rect((0, 0, W, 22 + b))
    s.paint(coat.copy().clip(top), "coat_top", shade=((1, 0),), light=((-1, 0), (0, -1)))
    # 코트 앞자락 트임
    s.fill(s.shape().rect((23, 32 + b, 24, 38 + b)), M["coat_dark"]["base"])
    s.fill(s.shape().rect((25, 32 + b, 25, 38 + b)), M["coat_dark"]["shadow"])
    # 허리띠와 청동 버클
    s.paint(s.shape().rect((15, 30 + b, 32, 31 + b)), "leather", shade=((0, 1),), light=None)
    s.fill(s.shape().rect((23, 30 + b, 24, 31 + b)), M["bronze"]["light"])
    s.fill(s.shape().rect((24, 31 + b, 24, 31 + b)), M["bronze"]["base"])
    # 가방끈(화면 오른쪽 어깨 -> 화면 왼쪽 엉덩이)과 가방
    s.fill(s.shape().line([(29, 22 + b), (19, 30 + b)]), M["leather"]["shadow"])
    bag = s.shape().rect((14, 31 + b, 20, 36 + b))
    s.paint(bag, "leather", shade=((1, 0), (0, 1)), light=((0, -1),), line=True)
    s.fill(s.shape().rect((14, 31 + b, 20, 32 + b)), M["leather"]["light"])
    s.px([(17, 33 + b)], M["bronze"]["light"])
    # 팔 (코트 소매) + 손
    for side, arm in ((0, larm), (1, rarm)):
        if side == 0:
            sleeve = s.shape().poly([(14, 22 + b), (17, 22 + b), (16, 32 + b + arm), (12, 32 + b + arm)])
            hand = s.shape().ell((12, 32 + b + arm, 15, 35 + b + arm))
            s.paint(sleeve, "coat", shade=((1, 0),), light=((-1, 0),), line=True)
            s.paint(hand, "skin", shade=((1, 0), (0, 1)), light=None, line=M["skin"]["line"])
        else:
            sleeve = s.shape().poly([(33, 22 + b), (30, 22 + b), (31, 32 + b + arm), (35, 32 + b + arm)])
            hand = s.shape().ell((32, 32 + b + arm, 35, 35 + b + arm))
            s.paint(sleeve, "coat", shade=((1, 0), (2, 0)), light=None, line=True)
            s.paint(hand, "skin", shade=((1, 0), (0, 1), (-1, 0)), light=None, line=M["skin"]["line"])
    # 목도리 (흐린 종이색 천)
    scarf = s.shape().ell((16, 19 + b, 31, 24 + b))
    s.paint(scarf, "scarf", shade=((0, 1), (1, 0)), light=((0, -1),), line=True)
    s.px([(19, 22 + b), (20, 23 + b), (26, 22 + b), (27, 21 + b)], M["scarf"]["shadow"])
    # 얼굴
    face = s.shape().ell((16, 6 + b, 31, 21 + b)).cut(scarf)
    s.paint(face, "skin", shade=((1, 0),), light=None)
    # 머리카락: 정수리 + 옆머리 - 앞머리 아래 얼굴 창
    hair = s.shape().ell((14, 2 + b, 33, 17 + b)).rect((14, 9 + b, 16, 19 + b)).rect((31, 9 + b, 33, 19 + b))
    window = s.shape().poly([(17, 12 + b), (18, 10 + b), (20, 12 + b), (22, 10 + b), (23, 12 + b), (24, 12 + b),
                             (25, 10 + b), (27, 12 + b), (29, 10 + b), (30, 12 + b), (30, 24 + b), (17, 24 + b)])
    hair.cut(window)
    s.paint(hair, "hair", shade=((1, 0), (0, 1)), light=((-1, -1), (0, -1)))
    s.drop(hair, face, M["skin"]["shadow"], dy=1)
    # 머리 윗면 윤기 (왼쪽 위 빛)
    s.px([(18, 5 + b), (19, 4 + b), (20, 4 + b), (21, 4 + b), (19, 6 + b), (22, 5 + b)], M["hair"]["light"])
    # 눈과 입
    for ex in (19, 27):
        s.fill(s.shape().rect((ex, 13 + b, ex + 1, 15 + b)), C["eye"])
        s.px([(ex, 13 + b)], M["hair"]["light"])
    s.px([(23, 18 + b), (24, 18 + b)], M["skin"]["shadow"])
    s.outline()
    return s


def up(bob=0) -> Sprite:
    """뒤(화면 위)를 보는 모습. 가방은 캐릭터 오른쪽 엉덩이 = 뒤에서 보면 화면 오른쪽."""
    s = Sprite(W, H)
    b = bob
    for x0 in (18, 26):
        s.paint(s.shape().rect((x0, 36 + b, x0 + 3, 42)), "trouser", shade=((1, 0),), light=None)
        s.paint(s.shape().rect((x0 - 1, 42, x0 + 4, 45)), "leather", shade=((1, 0), (0, 1)), light=((0, -1),), line=True)
    coat = s.shape().poly([(16, 21 + b), (31, 21 + b), (33, 29 + b), (34, 37 + b), (30, 38 + b),
                           (17, 38 + b), (13, 37 + b), (14, 29 + b)])
    s.paint(coat, "coat", shade=((1, 0), (2, 0), (0, 1)), light=((-1, 0),), line=True)
    s.paint(coat.copy().clip(s.shape().rect((0, 0, W, 22 + b))), "coat_top", shade=((1, 0),), light=((-1, 0), (0, -1)))
    # 등 솔기와 뒤트임
    s.fill(s.shape().line([(24, 25 + b), (24, 32 + b)]), M["coat"]["shadow"])
    s.fill(s.shape().rect((23, 33 + b, 24, 38 + b)), M["coat_dark"]["base"])
    s.fill(s.shape().rect((25, 33 + b, 25, 38 + b)), M["coat_dark"]["shadow"])
    s.paint(s.shape().rect((15, 30 + b, 32, 31 + b)), "leather", shade=((0, 1),), light=None)
    s.fill(s.shape().line([(18, 22 + b), (28, 30 + b)]), M["leather"]["shadow"])
    bag = s.shape().rect((27, 31 + b, 33, 36 + b))
    s.paint(bag, "leather", shade=((1, 0), (0, 1)), light=((0, -1),), line=True)
    s.fill(s.shape().rect((27, 31 + b, 33, 32 + b)), M["leather"]["light"])
    for side in (0, 1):
        if side == 0:
            sleeve = s.shape().poly([(14, 22 + b), (17, 22 + b), (16, 32 + b), (12, 32 + b)])
            s.paint(sleeve, "coat", shade=((1, 0),), light=((-1, 0),), line=True)
            s.paint(s.shape().ell((12, 32 + b, 15, 35 + b)), "skin", shade=((1, 0), (0, 1)), light=None, line=M["skin"]["line"])
        else:
            sleeve = s.shape().poly([(33, 22 + b), (30, 22 + b), (31, 32 + b), (35, 32 + b)])
            s.paint(sleeve, "coat", shade=((1, 0), (2, 0)), light=None, line=True)
            s.paint(s.shape().ell((32, 32 + b, 35, 35 + b)), "skin", shade=((1, 0), (0, 1), (-1, 0)), light=None, line=M["skin"]["line"])
    scarf = s.shape().ell((16, 19 + b, 31, 24 + b))
    s.paint(scarf, "scarf", shade=((0, 1), (1, 0)), light=((0, -1),), line=True)
    # 목 뒤 매듭에서 늘어진 목도리 끝 두 가닥
    tails = s.shape().rect((21, 23 + b, 23, 29 + b)).rect((24, 23 + b, 25, 27 + b))
    s.paint(tails, "scarf", shade=((1, 0), (0, 1)), light=((-1, 0),), line=True)
    hair = s.shape().ell((14, 2 + b, 33, 17 + b)).rect((14, 9 + b, 16, 19 + b)).rect((31, 9 + b, 33, 19 + b))
    hair.poly([(16, 12 + b), (31, 12 + b), (31, 19 + b), (29, 21 + b), (27, 19 + b), (25, 21 + b), (23, 19 + b),
               (21, 21 + b), (19, 19 + b), (17, 21 + b), (16, 19 + b)])
    s.paint(hair, "hair", shade=((1, 0), (0, 1)), light=((-1, -1), (0, -1)))
    s.px([(18, 5 + b), (19, 4 + b), (20, 4 + b), (21, 4 + b), (19, 6 + b), (22, 5 + b)], M["hair"]["light"])
    # 머리 결: 정수리에서 내려오는 짙은 가닥 두 줄
    s.px([(20, 9 + b), (20, 10 + b), (21, 11 + b), (21, 12 + b), (27, 8 + b), (27, 9 + b), (26, 10 + b), (26, 11 + b)],
         M["hair"]["shadow"])
    s.outline()
    return s


def side(face="left", bob=0) -> Sprite:
    """옆모습. 좌표는 왼쪽 보기 기준으로 쓰고, 오른쪽 보기는 좌표만 뒤집는다(빛 방향은 그대로 왼쪽 위).

    가방은 캐릭터 오른쪽 엉덩이: 왼쪽 보기에서는 먼 쪽이라 가려지고, 오른쪽 보기에서는 가까운 쪽이라 보인다.
    """
    mir = face == "right"
    bag_near = mir
    b = bob

    def X(x):
        return (W - 1 - x) if mir else x

    def bx(x0, y0, x1, y1):
        a, c = X(x0), X(x1)
        return (min(a, c), y0 + b, max(a, c), y1 + b)

    def pts(p):
        return [(X(x), y + b) for x, y in p]

    s = Sprite(W, H)
    far_leg = M["trouser"]
    # 먼 다리: 카메라에서 멀어서 1도트 위, 조금 뒤
    s.paint(s.shape().rect(bx(22, 35, 25, 41 - b)), "trouser", shade=None, light=None,
            colors={"base": far_leg["shadow"]})
    s.paint(s.shape().rect(bx(19, 41 - b, 25, 43 - b)).rect(bx(20, 44 - b, 25, 44 - b)), "leather",
            shade=((0, 1),), light=None, line=True, colors={"base": M["leather"]["shadow"]})
    # 가까운 다리
    s.paint(s.shape().rect(bx(18, 36, 21, 42 - b)), "trouser", shade=((1, 0),), light=None, line=True)
    s.paint(s.shape().rect(bx(16, 42 - b, 22, 44 - b)).rect(bx(17, 45 - b, 22, 45 - b)), "leather",
            shade=((1, 0), (0, 1)), light=((0, -1),), line=True)
    coat = s.shape().poly(pts([(18, 21), (29, 21), (31, 29), (32, 37), (29, 38), (17, 38), (15, 37), (17, 29)]))
    s.paint(coat, "coat", shade=((1, 0), (2, 0), (0, 1)), light=((-1, 0),), line=True)
    s.paint(coat.copy().clip(s.shape().rect((0, 0, W, 22 + b))), "coat_top", shade=((1, 0),), light=((-1, 0), (0, -1)))
    # 앞자락 안감 (앞쪽 가장자리)
    s.fill(s.shape().rect(bx(16, 32, 17, 37)), M["coat_dark"]["base"])
    s.paint(s.shape().rect(bx(16, 30, 31, 31)), "leather", shade=((0, 1),), light=None)
    if bag_near:
        s.fill(s.shape().line(pts([(18, 22), (25, 31)])), M["leather"]["shadow"])
        bag = s.shape().rect(bx(25, 31, 30, 36))
        s.paint(bag, "leather", shade=((1, 0), (0, 1)), light=((0, -1),), line=True)
        s.fill(s.shape().rect(bx(25, 31, 30, 32)), M["leather"]["light"])
        s.px(pts([(27, 33)]), M["bronze"]["light"])
    else:
        s.fill(s.shape().line(pts([(22, 22), (16, 29)])), M["leather"]["shadow"])
        s.fill(s.shape().line(pts([(26, 22), (30, 28)])), M["leather"]["shadow"])
    # 가까운 팔
    sleeve = s.shape().poly(pts([(21, 22), (26, 22), (25, 32), (21, 32)]))
    s.paint(sleeve, "coat", shade=((1, 0),), light=((-1, 0),), line=True)
    s.paint(s.shape().ell(bx(21, 32, 24, 35)), "skin", shade=((1, 0), (0, 1)), light=None, line=M["skin"]["line"])
    scarf = s.shape().ell(bx(16, 19, 30, 24))
    s.paint(scarf, "scarf", shade=((0, 1), (1, 0)), light=((0, -1),), line=True)
    s.paint(s.shape().rect(bx(27, 23, 29, 27)), "scarf", shade=((1, 0), (0, 1)), light=None, line=True)
    face_m = s.shape().ell(bx(13, 7, 27, 21)).px(pts([(12, 15)])).cut(scarf)
    s.paint(face_m, "skin", shade=((1, 0),), light=None)
    hair = s.shape().ell(bx(15, 2, 33, 17)).poly(pts([(24, 9), (32, 9), (32, 18), (30, 20), (24, 20)]))
    window = s.shape().poly(pts([(12, 12), (14, 10), (16, 12), (18, 10), (20, 12), (21, 11), (22, 13), (22, 25), (11, 25)]))
    hair.cut(window)
    s.paint(hair, "hair", shade=((1, 0), (0, 1)), light=((-1, -1), (0, -1)))
    s.drop(hair, face_m, M["skin"]["shadow"], dy=1)
    # 귀 (머리카락 가장자리에 살짝 드러남)
    s.paint(s.shape().rect(bx(22, 14, 23, 16)), "skin", shade=((0, 1),), light=None)
    s.px(pts([(22, 15)]), M["skin"]["shadow"])
    s.px(pts([(19, 5), (20, 4), (21, 4), (22, 4), (20, 6), (23, 5)]), M["hair"]["light"])
    s.fill(s.shape().rect(bx(15, 13, 16, 15)), C["eye"])
    s.px(pts([(15, 13)]), M["hair"]["light"])
    s.px(pts([(14, 18)]), M["skin"]["shadow"])
    s.outline()
    return s


# 아래 방향 걷기 4프레임: 왼발 앞 / 지나감(몸 1도트 위) / 오른발 앞 / 지나감
WALK_DOWN = [
    dict(bob=0, lfoot=1, rfoot=-1, larm=-1, rarm=1),
    dict(bob=-1, lfoot=0, rfoot=-2, larm=0, rarm=0),
    dict(bob=0, lfoot=-1, rfoot=1, larm=1, rarm=-1),
    dict(bob=-1, lfoot=-2, rfoot=0, larm=0, rarm=0),
]


def shadow():
    return contact_shadow(W, H, (14, 42, 33, 47))


def build_all():
    frames = {
        "player_stand_down": down(),
        "player_stand_up": up(),
        "player_stand_left": side("left"),
        "player_stand_right": side("right"),
    }
    for n, kw in enumerate(WALK_DOWN):
        frames[f"player_walk_down_{n}"] = down(**kw)
    return frames


def main(args):
    targets = args or ["all"]
    made = []
    if "stand_down" in targets:
        spr = down()
        made.append(save(spr.img, "player_stand_down", sub="player"))
        made.append(save(shadow(), "player_shadow", sub="player"))
        print(inspect([spr.img], "check_player_stand_down", zoom=10))
    if "all" in targets:
        frames = build_all()
        for name, spr in frames.items():
            made.append(save(spr.img, name, sub="player"))
        made.append(save(shadow(), "player_shadow", sub="player"))
        imgs = [f.img for f in frames.values()]
        print(inspect(imgs[:4], "check_player_stands", zoom=8))
        print(inspect(imgs[4:], "check_player_walk_down", zoom=8))
    for pair in made:
        print(pair[1])


if __name__ == "__main__":
    main(sys.argv[1:])
