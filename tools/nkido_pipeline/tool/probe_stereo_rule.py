"""Does "filter mono, widen after" remove the +22 dB?

probe_level.py established that a signal already flagged stereo comes out of a
filter about 22 dB louder than the same signal on the mono path, and saturates
the master soft clip at -0.9 dBFS. `stereo()` itself is level-neutral.

If the rule is right, the fix is to never let a filter see a stereo-flagged
signal: build the wide field from independent mono chains *after* the filter.
This measures that against the broken form, and against a plain mono reference,
so the answer is a number.

It also checks the width actually survives, because a level fix that flattens
the field is not a fix.
"""

import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import analyze_audio  # noqa: E402

NKIDO = r"C:\projects\_tools\nkido\build-clang\bin\nkido.exe"
WORK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "probe", "rule")

# level A: input 0.05, so a filter that behaves should not reach the clip
CASES = {
    "mono_reference": (
        'bpm = 120\nbody = noise() * 0.05 |> lp(@, 900, 1.1) |> hp(@, 200)\nout(body)',
        "the mono path, for reference",
    ),
    "broken_wide_then_filter": (
        'bpm = 120\nfield = stereo(noise(0,0,101) * 0.05, noise(0,0,977) * 0.05)\n'
        'out(field |> lp(@, 900, 1.1) |> hp(@, 200))',
        "current recipe: wide first, then filter",
    ),
    "rule_mono_then_filter_then_widen": (
        'bpm = 120\n'
        'left_body = noise(0,0,101) * 0.05 |> lp(@, 900, 1.1) |> hp(@, 200)\n'
        'right_body = noise(0,0,977) * 0.05 |> lp(@, 900, 1.1) |> hp(@, 200)\n'
        'out(stereo(left_body, right_body))',
        "candidate rule: filter each mono chain, widen once at the end",
    ),
    "rule_two_chains_one_out": (
        'bpm = 120\n'
        'left_body = noise(0,0,101) * 0.05 |> lp(@, 900, 1.1) |> hp(@, 200)\n'
        'right_body = noise(0,0,977) * 0.05 |> lp(@, 900, 1.1) |> hp(@, 200)\n'
        'field = stereo(left_body, right_body)\n'
        'out(field)',
        "same, written as a binding",
    ),
    "rule_with_reverb": (
        'bpm = 120\n'
        'left_body = noise(0,0,101) * 0.05 |> lp(@, 900, 1.1) |> hp(@, 200) |> freeverb(@, 0.9, 0.55, 0.3, 0.4)\n'
        'right_body = noise(0,0,977) * 0.05 |> lp(@, 900, 1.1) |> hp(@, 200) |> freeverb(@, 0.9, 0.55, 0.3, 0.4)\n'
        'out(stereo(left_body, right_body))',
        "rule plus the reverb the beds actually use",
    ),
    "rule_with_two_lfo_filters": (
        'bpm = 120\n'
        'sweep = sine(0.125) * 200 + 800\n'
        'left_body = noise(0,0,101) * 0.05 |> lp(@, sweep, 1.1) |> hp(@, 200)\n'
        'right_body = noise(0,0,977) * 0.05 |> lp(@, sweep, 1.1) |> hp(@, 200)\n'
        'out(stereo(left_body, right_body))',
        "rule with an audio-rate cutoff, as the wind bed uses",
    ),
}


def main():
    os.makedirs(WORK, exist_ok=True)
    print("%-34s %7s %7s %7s %7s" % ("case", "peak", "rms", "corr", "LUFS"))
    for name, (body, note) in sorted(CASES.items()):
        patch = os.path.join(WORK, name + ".akk")
        wav = os.path.join(WORK, name + ".wav")
        with open(patch, "w", encoding="utf-8") as handle:
            handle.write("// stereo rule probe\n// %s\n%s\n" % (note, body))
        result = subprocess.run(
            [NKIDO, "render", patch, "-o", wav, "--seconds", "8", "--rate", "48000",
             "--bpm", "120", "--no-default-bank"],
            capture_output=True, text=True,
        )
        if result.returncode != 0 or not os.path.exists(wav):
            print("%-34s RENDER FAILED" % name)
            continue
        m = analyze_audio.measure(wav)
        print("%-34s %7.1f %7.1f %7.2f %7.1f" % (
            name, m["peak_dbfs"], m["rms_dbfs"], m["channel_correlation"], m["integrated_lufs"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
