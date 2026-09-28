"""Check the rhythm and layering constructs the music compiler will emit.

Everything here is something compile_music.py plans to generate, so a failure
now is a failure the compiler would hit later. Run it before writing the
compiler, not after.
"""

import os
import subprocess
import sys

NKIDO = r"C:\projects\_tools\nkido\build-clang\bin\nkido.exe"
WORK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "probe", "rhythm")

CASES = {
    "bracket_pattern": 'bpm = 60\nhit = n"[a1 a1]"\nout(hit |> tri(@.freq) * adsr(@.gate, 0.001, 0.12, 0.0, 0.0) * 0.4)',
    "euclid": 'bpm = 60\nhats = n"hh*8".euclid(5, 8)\nout(hats * ar(trigger(1)) * 0.1)',
    "mtof_melody": 'bpm = 60\nnotes = [0, 3, 7, 10]\ntone = notes |> map(@, (i) -> mtof(45 + i))\nout(tone |> sum(@) * 0.05)',
    "sah_pitch": 'bpm = 60\npick = mtof(48 + sah(noise() * 12, trigger(2)))\nout(sine(pick) * ar(trigger(2), 0.01, 0.2) * 0.1)',
    "harmonics": 'bpm = 60\nstack = harmonics(110, 4) |> map(@, (x) -> saw(x) / (x / 110))\nout(stack |> sum(@) * 0.05)',
    "saturate": 'bpm = 60\nout(saw(110) * 0.2 |> saturate(@, 3.0))',
    "kick_envelope": 'bpm = 60\npitch = 110 - 70 * ar(trigger(1), 0.001, 0.06)\nout(sine(pitch) * ar(trigger(1), 0.001, 0.18) * 0.5)',
    "snare_noise": 'bpm = 60\nbody = noise() * ar(trigger(2), 0.001, 0.12) * 0.2\nout(body |> hp(@, 1200, 0.7))',
    "wide_bass": 'bpm = 60\nfield = stereo(tri(55) * 0.18, tri(55.3) * 0.18)\nout(field |> lp(@, 320, 1.2))',
    "wide_melody": 'bpm = 60\nmotif = [0, 3, 7, 10]\nleft_notes = motif |> map(@, (i) -> mtof(69 + i))\nright_notes = motif |> map(@, (i) -> mtof(69 + i))\nwide = stereo(left_notes |> sum(@) * 0.03, right_notes |> sum(@) * 0.03)\nout(wide |> lp(@, 2400, 1.1))',
    "chord_literal": 'bpm = 60\nout(c"a2 c3 e3" |> tri(@.freq) * adsr(@.gate, 0.2, 0.3, 0.7, 0.4) * 0.1)',
    "per_voice_pan": 'bpm = 60\nfield = stereo(saw(110) * 0.15, saw(110) * 0.15)\nout(field |> lp(@, 900, 1.2) |> reverb(@, 0.85, 0.55, 0.3, 0.4))',
}


def main():
    os.makedirs(WORK, exist_ok=True)
    failed = 0
    for name, body in sorted(CASES.items()):
        patch = os.path.join(WORK, name + ".akk")
        wav = os.path.join(WORK, name + ".wav")
        with open(patch, "w", encoding="utf-8") as handle:
            handle.write("// construct probe\n" + body + "\n")
        result = subprocess.run(
            [NKIDO, "render", patch, "-o", wav, "--seconds", "8", "--rate", "48000",
             "--bpm", "60", "--no-default-bank"],
            capture_output=True, text=True,
        )
        if result.returncode == 0 and os.path.exists(wav):
            print("  PASS  %s" % name)
        else:
            failed += 1
            message = (result.stdout + result.stderr).replace("\x1b[31m", "").replace("\x1b[1m", "")
            first = [line for line in message.splitlines() if "E" in line and "error" in line]
            print("  FAIL  %s : %s" % (name, first[0].strip() if first else message.strip()[:160]))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
