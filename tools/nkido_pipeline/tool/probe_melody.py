"""Verify the exact constructs compile_music.py will emit, before it emits them.

The first draft of the melody builder reached for `clock()`, and the drum recipe
reached for a sample name. Both are wrong here: the sample bank is off for
licensing, so a pattern of `sh` renders nothing, and gating by `clock()` is not
how a note gets its time.

Two grammar rules turned up while writing this, and the compiler has to honour
both:

  * `@.field` is only legal inside a pipe expression. `wide * adsr(@.gate, ...)`
    is E003. The enveloped signal has to be bound first, then panned.
  * `chord` and `voicing` are both predefined names. E150 on rebinding.
"""

import os
import subprocess
import sys

NKIDO = r"C:\projects\_tools\nkido\build-clang\bin\nkido.exe"
WORK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "probe", "melody")

CASES = {
    "notes_with_rests": '''bpm = 60
mel = n"[a4 ~ c5 ~ e5 ~ bb5 ~]"
out(mel |> tri(@.freq) * adsr(@.gate, 0.012, 0.12, 0.5, 0.2) * 0.04)''',

    "notes_wide": '''bpm = 60
mel = n"[a4 ~ c5 ~ e5 ~ bb5 ~]"
left_note = mel |> tri(@.freq) * adsr(@.gate, 0.012, 0.12, 0.5, 0.2) * 0.04
right_note = mel |> tri(@.freq * 1.003) * adsr(@.gate, 0.012, 0.12, 0.5, 0.2) * 0.04
out(stereo(left_note, right_note) |> lp(@, 2200, 1.1))''',

    "euclid_bare": '''bpm = 60
hits = euclid(5, 8)
out(noise() * hits * ar(trigger(1)) * 0.06 |> hp(@, 6000, 0.7))''',

    "two_grids": '''bpm = 60
fine = euclid(7, 8)
fat = euclid(2, 8, 4)
body = noise() * (fine * 0.05 + fat * 0.09) * ar(trigger(1)) |> hp(@, 3000, 0.7)
out(stereo(body, body))''',

    "hpad_named": '''bpm = 60
hpad = c"a2 c3 e3 bb3"
out(hpad |> saw(@.freq) * adsr(@.gate, 0.5, 0.4, 0.8, 0.4) * 0.05 |> lp(@, 900, 1.3))''',

    "hpad_wide": '''bpm = 60
hpad = c"a2 c3 e3 bb3"
sweep = sine(0.0625) * 300 + 750
left_pad = hpad |> saw(@.freq) * adsr(@.gate, 0.5, 0.4, 0.8, 0.4) * 0.05
right_pad = hpad |> saw(@.freq * 1.001) * adsr(@.gate, 0.5, 0.4, 0.8, 0.4) * 0.05
out(stereo(left_pad, right_pad) |> lp(@, sweep, 1.3) |> freeverb(@, 0.88, 0.55, 0.3, 0.4))''',

    "bass_wide": '''bpm = 60
fig = n"[a1 ~ a1 ~]"
left_fig = fig |> tri(@.freq) * adsr(@.gate, 0.02, 0.1, 0.7, 0.2) * 0.16
right_fig = fig |> tri(@.freq * 1.004) * adsr(@.gate, 0.02, 0.1, 0.7, 0.2) * 0.16
out(stereo(left_fig, right_fig) |> lp(@, 320, 1.2))''',

    "drums_sparse": '''bpm = 120
kick_pitch = 112 - 74 * ar(trigger(2), 0.001, 0.06)
left_kick = sine(kick_pitch) * ar(trigger(2), 0.001, 0.20) * 0.5
right_kick = sine(kick_pitch * 1.004) * ar(trigger(2), 0.001, 0.20) * 0.5
hats = noise() * euclid(7, 8) * ar(trigger(1)) * 0.05 |> hp(@, 6000, 0.7)
left_kit = left_kick + hats
right_kit = right_kick + hats
out(stereo(left_kit, right_kit))''',

    "held_note": '''bpm = 60
out(tri(110) * ar(1, 0.4, 0.4) * 0.12 |> lp(@, 400, 1.2))''',
}


def main():
    os.makedirs(WORK, exist_ok=True)
    failed = 0
    for name, body in sorted(CASES.items()):
        patch = os.path.join(WORK, name + ".akk")
        wav = os.path.join(WORK, name + ".wav")
        with open(patch, "w", encoding="utf-8") as handle:
            handle.write("// melody construct probe\n" + body + "\n")
        result = subprocess.run(
            [NKIDO, "render", patch, "-o", wav, "--seconds", "8", "--rate", "48000",
             "--bpm", "120", "--no-default-bank"],
            capture_output=True, text=True,
        )
        if result.returncode == 0 and os.path.exists(wav):
            print("  PASS  %-18s %d bytes" % (name, os.path.getsize(wav)))
        else:
            failed += 1
            message = (result.stdout + result.stderr).replace("\x1b[31m", "").replace("\x1b[1m", "")
            first = [line for line in message.splitlines() if "error" in line]
            print("  FAIL  %-18s %s" % (name, first[0].strip() if first else message.strip()[:140]))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
