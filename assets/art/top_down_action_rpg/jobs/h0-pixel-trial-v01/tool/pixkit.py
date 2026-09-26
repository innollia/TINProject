# -*- coding: utf-8 -*-
"""h0-pixel-trial-v01 공용 도트 도구 (candidate).

규칙
- 모든 그림은 작은 해상도(x1, 도트 1칸 = 1px)로 그린다.
- 원본 파일은 정수배(SCALE=4) nearest 확대만 한다. 1도트 = 원본 4px = 1280x720 화면 2px.
- 색은 palette_h0_snapshot.json(아이콘 작업 palette_h0.json의 읽기 전용 사본)에서만 가져온다.
"""
from __future__ import annotations

import json
import os

from PIL import Image, ImageChops, ImageDraw

TOOL = os.path.dirname(os.path.abspath(__file__))
JOB = os.path.dirname(TOOL)
OUT = os.path.join(JOB, "output")
OUT_X1 = os.path.join(OUT, "x1")
PREVIEW = os.path.join(JOB, "preview")
SCRATCH = os.environ.get("KIROCREW_SCRATCH") or os.path.join(os.environ.get("TEMP", "."), "h0-pixel-trial")
SCALE = 4


def hx(value: str, alpha: int = 255) -> tuple:
    v = value.lstrip("#")
    return (int(v[0:2], 16), int(v[2:4], 16), int(v[4:6], 16), alpha)


with open(os.path.join(TOOL, "palette_h0_snapshot.json"), encoding="utf-8") as _fh:
    PALETTE = json.load(_fh)

C = {k: hx(v) for k, v in PALETTE["colors"].items()}
M = {name: {k: hx(v) for k, v in mat.items() if isinstance(v, str)} for name, mat in PALETTE["materials"].items()}
INK = C["ink"]
CLEAR = (0, 0, 0, 0)
N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))


class Shape:
    """L 모드(0/255) 마스크에 계단형(안티에일리어싱 없는) 도형을 그린다."""

    def __init__(self, w: int, h: int):
        self.w, self.h = w, h
        self.m = Image.new("L", (w, h), 0)
        self.d = ImageDraw.Draw(self.m)

    def ell(self, box, on=True):
        self.d.ellipse(box, fill=255 if on else 0)
        return self

    def rect(self, box, on=True):
        self.d.rectangle(box, fill=255 if on else 0)
        return self

    def poly(self, pts, on=True):
        self.d.polygon(pts, fill=255 if on else 0)
        return self

    def line(self, pts, on=True, width=1):
        self.d.line(pts, fill=255 if on else 0, width=width)
        return self

    def px(self, pts, on=True):
        for p in pts:
            self.d.point(p, fill=255 if on else 0)
        return self

    def clip(self, other):
        o = other.m if isinstance(other, Shape) else other
        self.m = ImageChops.multiply(self.m, o)
        self.d = ImageDraw.Draw(self.m)
        return self

    def cut(self, other):
        o = other.m if isinstance(other, Shape) else other
        self.m = ImageChops.subtract(self.m, o)
        self.d = ImageDraw.Draw(self.m)
        return self

    def add(self, other):
        o = other.m if isinstance(other, Shape) else other
        self.m = ImageChops.lighter(self.m, o)
        self.d = ImageDraw.Draw(self.m)
        return self

    def copy(self):
        s = Shape(self.w, self.h)
        s.m = self.m.copy()
        s.d = ImageDraw.Draw(s.m)
        return s

    def shifted(self, dx, dy):
        s = Shape(self.w, self.h)
        s.m = ImageChops.offset(self.m, dx, dy)
        # offset은 감싸기(wrap)이므로 넘어간 줄을 지운다
        if dx > 0:
            s.d.rectangle((0, 0, dx - 1, self.h), fill=0)
        elif dx < 0:
            s.d.rectangle((self.w + dx, 0, self.w, self.h), fill=0)
        if dy > 0:
            s.d.rectangle((0, 0, self.w, dy - 1), fill=0)
        elif dy < 0:
            s.d.rectangle((0, self.h + dy, self.w, self.h), fill=0)
        return s


def _mask(obj):
    return obj.m if isinstance(obj, Shape) else obj


class Sprite:
    def __init__(self, w: int, h: int):
        self.w, self.h = w, h
        self.img = Image.new("RGBA", (w, h), CLEAR)

    def shape(self) -> Shape:
        return Shape(self.w, self.h)

    def paint(self, shape, mat, shade=((1, 0),), light=((-1, -1),), line=None, colors=None, clip=None):
        """마스크를 재질 색으로 칠한다. 빛은 왼쪽 위(팔레트 light 벡터)에서 온다.

        shade/light: (dx, dy) 목록. 그 방향 이웃이 마스크 밖이면 그 칸을 어둡게/밝게 칠한다.
        line: True면 재질 line 색, 색 튜플이면 그 색으로, 이미 칠해진 다른 부위와 닿는 경계를 긋는다.
        """
        mask = _mask(shape)
        if clip is not None:
            mask = ImageChops.multiply(mask, _mask(clip))
        pal = dict(M[mat]) if isinstance(mat, str) else dict(mat)
        if colors:
            pal.update(colors)
        base = pal["base"]
        dark = pal.get("shadow", base)
        lite = pal.get("light", base)
        edge = pal.get("line", INK) if line is True else line
        mp = mask.load()
        before = self.img.getchannel("A").load()
        ip = self.img.load()
        w, h = self.w, self.h

        def inside(x, y):
            return 0 <= x < w and 0 <= y < h and mp[x, y] > 127

        todo = []
        for y in range(h):
            for x in range(w):
                if mp[x, y] <= 127:
                    continue
                col = base
                if light and any(not inside(x + dx, y + dy) for dx, dy in light):
                    col = lite
                if shade and any(not inside(x + dx, y + dy) for dx, dy in shade):
                    col = dark
                if edge is not None:
                    for dx, dy in N4:
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h and not inside(nx, ny) and before[nx, ny] > 0:
                            col = edge
                            break
                todo.append((x, y, col))
        for x, y, col in todo:
            ip[x, y] = col
        return mask

    def fill(self, shape, color, clip=None):
        mask = _mask(shape)
        if clip is not None:
            mask = ImageChops.multiply(mask, _mask(clip))
        layer = Image.new("RGBA", (self.w, self.h), color)
        self.img.paste(layer, (0, 0), mask)

    def px(self, pts, color):
        ip = self.img.load()
        for x, y in pts:
            if 0 <= x < self.w and 0 <= y < self.h:
                ip[x, y] = color

    def recolor(self, shape, mapping: dict):
        """마스크 안에서 특정 색을 다른 색으로 바꾼다(부분 그늘 등)."""
        mp = _mask(shape).load()
        ip = self.img.load()
        for y in range(self.h):
            for x in range(self.w):
                if mp[x, y] > 127 and ip[x, y] in mapping:
                    ip[x, y] = mapping[ip[x, y]]

    def drop(self, under, onto, color, dy=1, dx=0):
        """under 도형 바로 아래(또는 옆) dy칸의 onto 영역에 그늘을 떨군다."""
        u = _wrap(_mask(under), self.w, self.h)
        band = Shape(self.w, self.h)
        for k in range(1, dy + 1):
            band.add(u.shifted(dx, k))
        band.clip(onto).cut(u)
        self.fill(band, color)

    def outline(self, color=INK, corners=False, skip=None):
        a = self.img.getchannel("A").load()
        ip = self.img.load()
        nbs = N4 + (((1, 1), (-1, 1), (1, -1), (-1, -1)) if corners else ())
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if a[x, y] > 0:
                    continue
                for dx, dy in nbs:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < self.w and 0 <= ny < self.h and a[nx, ny] > 0:
                        add.append((x, y))
                        break
        for p in add:
            ip[p] = color

    def mirrored(self):
        s = Sprite(self.w, self.h)
        s.img = self.img.transpose(Image.FLIP_LEFT_RIGHT)
        return s


def _wrap(mask, w, h):
    s = Shape(w, h)
    s.m = mask.copy()
    s.d = ImageDraw.Draw(s.m)
    return s


def save(img: Image.Image, name: str, scale: int = SCALE, folder: str = OUT, sub: str = ""):
    """x1(그린 해상도)와 원본(정수배 nearest 확대)을 함께 저장한다."""
    small_dir = os.path.join(folder, "x1", sub)
    big_dir = os.path.join(folder, sub)
    os.makedirs(small_dir, exist_ok=True)
    os.makedirs(big_dir, exist_ok=True)
    p1 = os.path.join(small_dir, name + ".png")
    p4 = os.path.join(big_dir, name + ".png")
    img.save(p1)
    img.resize((img.width * scale, img.height * scale), Image.NEAREST).save(p4)
    return p1, p4


def contact_shadow(w: int, h: int, box, alpha: int = 110) -> Image.Image:
    """따로 내보내는 발밑 그림자(모양은 도트 타원, 색은 팔레트 shadow_contact)."""
    img = Image.new("RGBA", (w, h), CLEAR)
    m = Shape(w, h).ell(box)
    layer = Image.new("RGBA", (w, h), C["shadow_contact"][:3] + (alpha,))
    img.paste(layer, (0, 0), m.m)
    return img


def inspect(images, name: str, zoom: int = 8, bg=None, pad: int = 2):
    """검수용: x1 그림 여러 장을 확대해 바닥색 위에 나란히 놓고 스크래치에 저장."""
    bg = bg or C["floor"]
    cw = max(i.width for i in images) + pad * 2
    ch = max(i.height for i in images) + pad * 2
    sheet = Image.new("RGBA", (cw * len(images), ch), bg)
    for n, im in enumerate(images):
        sheet.alpha_composite(im, (n * cw + pad + (cw - pad * 2 - im.width) // 2, pad + (ch - pad * 2 - im.height)))
    sheet = sheet.resize((sheet.width * zoom, sheet.height * zoom), Image.NEAREST)
    os.makedirs(SCRATCH, exist_ok=True)
    path = os.path.join(SCRATCH, name + ".png")
    sheet.save(path)
    return path
