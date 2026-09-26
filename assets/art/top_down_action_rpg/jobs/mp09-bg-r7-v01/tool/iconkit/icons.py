"""at-icons source lookup, rasterisation and mask cache.

Every icon in ``addons/at-icons/node2d`` is a 16x16 single-colour SVG, so its
alpha channel *is* the shape.  Each icon is rasterised once to a large
grayscale mask (default 1024 px) and cached on disk outside the project
(``ICONKIT_CACHE`` or ``KIROCREW_SCRATCH`` or the system temp folder).
All later work (cutting, bending, stretching, recolouring, shading) happens on
those masks.  Nothing is ever written next to the source SVGs.

Renderer order: ImageMagick (librsvg delegate, the tool the archived study
used) then the Inkscape CLI.
"""

from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

ICON_UNITS = 16.0
DEFAULT_RES = 1024
INKSCAPE_CANDIDATES = [
    r"C:\Program Files\Inkscape\bin\inkscape.exe",
    r"C:\Program Files (x86)\Inkscape\bin\inkscape.exe",
]


def find_project_root(start: Path) -> Path:
    for candidate in [start, *start.parents]:
        if (candidate / "project.godot").exists():
            return candidate
    raise FileNotFoundError(f"project.godot not found above {start}")


def default_cache_dir() -> Path:
    base = os.environ.get("ICONKIT_CACHE") or os.environ.get("KIROCREW_SCRATCH")
    root = Path(base) if base else Path(tempfile.gettempdir())
    return root if root.name == "iconkit_cache" else root / "iconkit_cache"


class IconLibrary:
    """Loads at-icons SVGs as 8-bit coverage masks of ``res`` x ``res`` pixels."""

    def __init__(self, source_dir: Path, cache_dir: Path | None = None, res: int = DEFAULT_RES):
        self.source_dir = Path(source_dir)
        if not self.source_dir.is_dir():
            raise FileNotFoundError(f"icon source folder missing: {self.source_dir}")
        self.cache_dir = Path(cache_dir) if cache_dir else default_cache_dir()
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.res = int(res)
        self._images: dict[str, Image.Image] = {}
        self._sha: dict[str, str] = {}
        self.used: dict[str, str] = {}  # icons actually drawn: name -> sha256 of the svg
        self.renderer = self._pick_renderer()

    # -- lookup -----------------------------------------------------------------
    def names(self) -> list[str]:
        return sorted(p.stem for p in self.source_dir.glob("*.svg"))

    def svg_path(self, name: str) -> Path:
        path = self.source_dir / f"{name}.svg"
        if not path.exists():
            raise KeyError(f"unknown at-icons name: {name!r}")
        return path

    def sha256(self, name: str) -> str:
        if name not in self._sha:
            self._sha[name] = hashlib.sha256(self.svg_path(name).read_bytes()).hexdigest()
        return self._sha[name]

    def _cache_png(self, name: str) -> Path:
        return self.cache_dir / f"{name}_{self.res}_{self.sha256(name)[:12]}.png"

    # -- rendering ----------------------------------------------------------------
    def _pick_renderer(self) -> str:
        if shutil.which("magick"):
            return "magick"
        for exe in INKSCAPE_CANDIDATES:
            if Path(exe).exists():
                return exe
        if shutil.which("inkscape"):
            return "inkscape"
        raise RuntimeError("No SVG renderer found: install ImageMagick (librsvg) or Inkscape")

    def _render(self, svg: Path, png: Path) -> None:
        if self.renderer == "magick":
            density = self.res * 96 / ICON_UNITS  # librsvg treats the 16 px canvas as 96 dpi
            cmd = ["magick", "-background", "none", "-density", f"{density:g}", str(svg),
                   "-alpha", "extract", str(png)]
        else:
            cmd = [self.renderer, "--export-type=png", f"--export-width={self.res}",
                   "--export-background-opacity=0", f"--export-filename={png}", str(svg)]
        subprocess.run(cmd, check=True, capture_output=True)

    def image(self, name: str, record: bool = True) -> Image.Image:
        """The icon's coverage as a PIL 'L' image (255 = painted)."""
        if record:
            self.used[name] = self.sha256(name)
        if name in self._images:
            return self._images[name]
        png = self._cache_png(name)
        if not png.exists():
            self._render(self.svg_path(name), png)
        img = Image.open(png)
        img = img.getchannel("A") if img.mode in ("RGBA", "LA") else img.convert("L")
        if img.size != (self.res, self.res):
            img = img.resize((self.res, self.res), Image.Resampling.LANCZOS)
        img.load()
        self._images[name] = img
        return img

    def mask(self, name: str) -> np.ndarray:
        return np.asarray(self.image(name), dtype=np.float32) / 255.0

    def forget(self, name: str) -> None:
        self._images.pop(name, None)

    def prefetch(self, names: list[str], workers: int = 2) -> None:
        """Render missing cache files in parallel (renderer calls are subprocesses).

        mp09: default lowered 8 -> 2 because ten production sessions share the host.
        """
        from concurrent.futures import ThreadPoolExecutor

        missing = [n for n in names if not self._cache_png(n).exists()]

        def job(name: str) -> None:
            self._render(self.svg_path(name), self._cache_png(name))

        with ThreadPoolExecutor(max_workers=workers) as pool:
            list(pool.map(job, missing))
