"""Stage 01 (세인트 오린 대학) recipe writer for g06-stage01-v01.

    py -3 -B make_s01.py            # (re)write every recipe + the stage palettes
    py -3 -B make_s01.py mira bg_   # only recipes whose asset id contains one of the words

Scale (g06 author design, JOB.md): 320 source px per metre (vertical) in every
background, object and character of this stage; source = 2x the 1280x720 screen.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g06kit import write  # noqa: E402
import s01_common as C  # noqa: E402
import s01_bg  # noqa: E402,F401
import s01_chars  # noqa: E402,F401
import s01_objs  # noqa: E402,F401
import s01_cu  # noqa: E402,F401


def main(argv) -> int:
    C.palettes()
    wanted = argv[1:]
    n = 0
    for name, fn in C.REGISTRY.items():
        if wanted and not any(w in name for w in wanted):
            continue
        write(C.REC, fn())
        n += 1
    print(f"wrote {n} recipes + {C.PAL}, {C.PAL_CCTV}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
