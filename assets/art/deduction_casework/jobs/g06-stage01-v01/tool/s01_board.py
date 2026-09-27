"""VISUAL 2 task board: one arrangement shared by the world object, the CCTV frame
and the close-up so the three never disagree (13B-1 "보드 배열 ... 컷마다 바꾸지 않는다").

16 unique magnets = 4 shapes x 4 colours.  The answer key puts shape
(r + c) % 4 and colour (c + 2r) % 4 in cell (r, c); each cell carries the raised
(tactile) outline of its key shape.  Mira's magnets sit on the right outlines
(shapes all match) but she swapped colours among cells of the same shape, so by
colour/position they are almost all wrong: 15 of 16 wrong, cell (2, 1) right by
chance.
"""

SHAPES = ["circle", "triangle", "square", "star"]          # at-icons names
COLORS = ["magnet_red", "magnet_blue", "magnet_yellow", "magnet_green"]


def key_cell(r, c):
    return (c + r) % 4, (c + 2 * r) % 4


def mira_cell(r, c):
    """Colour Mira put in (r, c): the key colour of another cell with the same raised
    outline.  Rows are rotated one step for every shape; for the star the rotation
    skips row 2, so cell (2, 1) keeps its own colour (the one chance match)."""
    s, _ = key_cell(r, c)
    if SHAPES[s] == "star":
        src = {0: 1, 1: 3, 2: 2, 3: 0}[r]
    else:
        src = (r + 1) % 4
    cc = (s - src) % 4
    return s, key_cell(src, cc)[1]


def cells():
    """[(r, c, shape_icon, key_color, mira_color)]"""
    out = []
    for r in range(4):
        for c in range(4):
            s, kc = key_cell(r, c)
            _, mc = mira_cell(r, c)
            out.append((r, c, SHAPES[s], COLORS[kc], COLORS[mc]))
    return out


def check():
    cs = cells()
    assert len({(s, k) for _, _, s, k, _ in cs}) == 16
    assert len({(s, m) for _, _, s, _, m in cs}) == 16, "Mira uses each magnet once"
    wrong = sum(1 for _, _, _, k, m in cs if k != m)
    assert wrong == 15, wrong
    return wrong


check()
