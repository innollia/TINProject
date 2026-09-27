"""Colour roles, ported from core/procedural/palette/.

Same rule as the engine: a part names a role, never an RGB.  The only literal
colours in this project live in a spec's "palette" block or in a .png, both of
which are data, not code.
"""

from __future__ import annotations

import colorsys
import re

ROLE_KEY_LIGHT = "key_light"
ROLE_SHADE = "shade"
ROLE_RIM = "rim"
ROLE_BODY = "body"
ROLE_BODY_DARK = "body_dark"
ROLE_BELLY = "belly"
ROLE_ACCENT = "accent"
ROLE_INK = "ink"
ROLE_GROUND = "ground"
ROLE_SKY_NEAR = "sky_near"
ROLE_SKY_FAR = "sky_far"
ROLE_FOG = "fog"
ROLE_DANGER = "danger"
# Additions this bake tool needs on top of the frozen engine role list.
ROLE_SCLERA = "sclera"
ROLE_PUPIL = "pupil"
ROLE_BLOOM = "bloom"

ROLES = (
    ROLE_KEY_LIGHT, ROLE_SHADE, ROLE_RIM, ROLE_BODY, ROLE_BODY_DARK, ROLE_BELLY,
    ROLE_ACCENT, ROLE_INK, ROLE_GROUND, ROLE_SKY_NEAR, ROLE_SKY_FAR, ROLE_FOG,
    ROLE_DANGER, ROLE_SCLERA, ROLE_PUPIL, ROLE_BLOOM,
)

SCHEME_OFFSETS = {
    "analogous": (-0.09, 0.50, 0.09, 0.18),
    "complementary": (0.0, 0.50, -0.06, 0.55),
    "split_complementary": (0.0, 0.416, 0.584, 0.08),
    "triadic": (0.0, 0.333, 0.666, 0.05),
    "tetradic": (0.0, 0.25, 0.50, 0.75),
}


def hsv(hue: float, sat: float, val: float, alpha: float = 1.0) -> tuple:
    r, g, b = colorsys.hsv_to_rgb(hue % 1.0, min(max(sat, 0.0), 1.0), min(max(val, 0.0), 1.0))
    return (r, g, b, alpha)


def parse_color(value) -> tuple:
    """'#rrggbb', '#rrggbbaa', 'rrggbb', [r,g,b], [r,g,b,a] -> (r,g,b,a) 0..1."""
    if isinstance(value, (list, tuple)):
        parts = [float(v) for v in value]
        if len(parts) == 3:
            parts.append(1.0)
        if len(parts) < 4:
            raise ValueError(f"colour needs 3 or 4 channels, got {value!r}")
        if max(parts[:3]) > 1.0:
            parts = [p / 255.0 for p in parts]
        return (parts[0], parts[1], parts[2], min(max(parts[3], 0.0), 1.0))
    text = str(value).strip().lstrip("#")
    if not re.fullmatch(r"[0-9a-fA-F]{6}|[0-9a-fA-F]{8}", text):
        raise ValueError(f"not a hex colour: {value!r}")
    r, g, b = (int(text[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    a = int(text[6:8], 16) / 255.0 if len(text) == 8 else 1.0
    return (r, g, b, a)


def to_hex(color) -> str:
    r, g, b, a = color
    body = "%02x%02x%02x" % tuple(int(round(min(max(c, 0.0), 1.0) * 255)) for c in (r, g, b))
    return "#" + (body if a >= 0.999 else body + "%02x" % int(round(a * 255)))


class Palette:
    def __init__(self, roles: dict):
        self.roles = {k: parse_color(v) for k, v in roles.items() if k in ROLES}
        missing = [r for r in (ROLE_BODY, ROLE_SHADE, ROLE_INK) if r not in self.roles]
        if missing:
            raise ValueError("palette is missing roles: " + ", ".join(missing))

    def get(self, role: str) -> tuple:
        if role not in self.roles:
            raise KeyError(f"palette has no role {role!r}; it has {sorted(self.roles)}")
        return self.roles[role]

    def has(self, role: str) -> bool:
        return role in self.roles

    def mix(self, from_role: str, to_role: str, weight: float) -> tuple:
        a, b = self.get(from_role), self.get(to_role)
        t = min(max(weight, 0.0), 1.0)
        return tuple(a[i] + (b[i] - a[i]) * t for i in range(4))

    def shift(self, role: str, value_scale: float, sat_scale: float = 1.0) -> tuple:
        r, g, b, a = self.get(role)
        hh, ss, vv = colorsys.rgb_to_hsv(r, g, b)
        return hsv(hh, ss * sat_scale, vv * value_scale, a)

    def to_dict(self) -> dict:
        return {k: to_hex(v) for k, v in self.roles.items()}


def from_spec(spec: dict, seed: int = 0, variant: int = 0) -> Palette:
    """A spec's "palette" block wins.  Otherwise derive one from the seed, the
    same way ProceduralPaletteScheme does (scheme, base_hue, sat, contrast)."""
    if spec:
        roles = {k: v for k, v in spec.items() if k in ROLES}
        if roles:
            return Palette(roles)
    scheme_names = sorted(SCHEME_OFFSETS)
    scheme = scheme_names[(seed + variant) % len(scheme_names)]
    base_hue = ((seed * 0.61803398875) + variant * 0.3333) % 1.0
    sat = 0.35 + ((seed * 7919 % 1000) / 1000.0) * 0.43
    contrast = 0.78 + ((seed * 104729 % 1000) / 1000.0) * 0.54
    return derive(scheme, base_hue, sat, contrast)


def derive(scheme: str = "analogous", base_hue: float = 0.55,
           saturation: float = 0.6, contrast: float = 1.0) -> Palette:
    """The ProceduralPaletteScheme recipe, with the same hue offsets."""
    off_body, off_comp, off_acc, off_near = SCHEME_OFFSETS.get(scheme, SCHEME_OFFSETS["analogous"])
    bh = base_hue
    s, c = saturation, contrast
    roles = {
        ROLE_BODY:      hsv(bh + off_body, s, 0.60 * c),
        ROLE_BODY_DARK: hsv(bh + off_body, s * 1.06, 0.33 * c),
        ROLE_BELLY:     hsv(bh + off_body + 0.03, s * 0.78, 0.84 * c),
        ROLE_KEY_LIGHT: hsv(bh + off_comp, s * 0.62, 0.95 * c),
        ROLE_SHADE:     hsv(bh + off_body, s * 1.12, 0.16 * c),
        ROLE_RIM:       hsv(bh + off_acc, s * 1.15, 1.00),
        ROLE_ACCENT:    hsv(bh + off_acc, s * 1.20, 0.78 * c),
        ROLE_INK:       hsv(bh + off_body, s * 0.45, 0.07 * c),
        ROLE_GROUND:    hsv(bh + off_comp, s * 0.55, 0.24 * c),
        ROLE_SKY_NEAR:  hsv(bh + off_near, s * 0.48, 0.48 * c),
        ROLE_SKY_FAR:   hsv(bh + off_near + 0.06, s * 0.40, 0.78 * c),
        ROLE_FOG:       hsv(bh + off_near + 0.02, s * 0.18, 0.90 * c),
        ROLE_DANGER:    hsv(0.02, s * 1.30, 0.72 * c),
    }
    return Palette(roles)
