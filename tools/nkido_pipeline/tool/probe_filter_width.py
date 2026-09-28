"""Isolate why some nkido filters collapse the stereo field.

H1  the filter keeps one state for L and R, so a mono input can only ever come
    out identical
H2  the engine deduplicates structurally identical chains
H3  it only happens when the cutoff moves at audio rate
H4  it is specific to some filter types

Each case is a one-line patch rendered to WAV and measured. The decisive one is
`stereo_then_lp`: the channels are already different before the filter runs, so
if the output comes back identical the filter is what lost the difference.
"""

import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
PIPELINE = os.path.dirname(ROOT)
NKIDO = r"C:\projects\_tools\nkido\build-clang\bin\nkido.exe"
WORK = os.path.join(PIPELINE, "build", "probe")
ANALYZER = os.path.join(ROOT, "analyze_audio.py")
TARGETS = os.path.join(PIPELINE, "analysis_targets.json")

TWO_SEEDS_RAW = "out(noise(0, 0, 101) * 0.3, noise(0, 0, 977) * 0.3)"

CASES = [
    ("01_two_seeds_raw", TWO_SEEDS_RAW, "control: two seeds, no filter"),
    ("02_hp_static", "out(noise(0,0,101)*0.3 |> hp(@,1800), noise(0,0,977)*0.3 |> hp(@,1800))", "H4: hp, fixed cutoff"),
    ("03_lp_static", "out(noise(0,0,101)*0.3 |> lp(@,800), noise(0,0,977)*0.3 |> lp(@,800))", "H4: lp, fixed cutoff"),
    ("04_bp_static", "out(noise(0,0,101)*0.3 |> bp(@,620,3.2), noise(0,0,977)*0.3 |> bp(@,620,3.2))", "H4: bp, fixed cutoff"),
    ("05_lp_audiorate", "c1 = sine(0.125)*200 + 800\nc2 = c1\nout(noise(0,0,101)*0.3 |> lp(@,c1), noise(0,0,977)*0.3 |> lp(@,c2))", "H3: lp, cutoff moved by an LFO"),
    ("06_hp_audiorate", "c1 = sine(0.125)*200 + 1800\nc2 = c1\nout(noise(0,0,101)*0.3 |> hp(@,c1), noise(0,0,977)*0.3 |> hp(@,c2))", "H3: hp, cutoff moved by an LFO"),
    ("07_moog", "out(noise(0,0,101)*0.3 |> moog(@,800,2.0), noise(0,0,977)*0.3 |> moog(@,800,2.0))", "H4: moog ladder"),
    ("08_phaser", "out(noise(0,0,101)*0.3 |> phaser(@,0.125,0.6,1200,6000,0.4,4,0.0,0.4,0.6), noise(0,0,977)*0.3 |> phaser(@,0.125,0.6,1200,6000,0.4,4,0.5,0.4,0.6))", "H4: phaser, and the two lfo_phases differ"),
    ("09_lp_then_hp", "out(noise(0,0,101)*0.3 |> lp(@,800) |> hp(@,120), noise(0,0,977)*0.3 |> lp(@,800) |> hp(@,120))", "H4: two chained filters"),
    ("10_stereo_then_lp", "a = noise(0,0,101)*0.3\nb = noise(0,0,977)*0.3\nout(a |> lp(@,800), b |> lp(@,800))", "same as 03, written as bindings"),
    ("11_stereo_in_first", "wide = stereo(noise(0,0,101)*0.3, noise(0,0,977)*0.3)\nout(wide |> lp(@,800))", "DECISIVE: already stereo, then one lp"),
    ("12_stereo_in_raw", "out(stereo(noise(0,0,101)*0.3, noise(0,0,977)*0.3))", "control for 11, no filter"),
    ("13_lp_diff_cutoff", "out(noise(0,0,101)*0.3 |> lp(@,400), noise(0,0,977)*0.3 |> lp(@,1600))", "H1: two different cutoffs, same state?"),
    ("14_lp_diff_q", "out(noise(0,0,101)*0.3 |> lp(@,800,1.0), noise(0,0,977)*0.3 |> lp(@,800,4.0))", "H1: same cutoff, different q"),
    ("15_sine_in_stereo", "out(stereo(noise(0,0,101)*0.3, sine(440)*0.3) |> lp(@,800))", "DECISIVE 2: maximally different inputs, one lp"),
    ("16_lp_no_width", "out(lp(noise(0,0,101)*0.3, 800))", "single mono chain, sanity"),
    ("17_two_args_diff", "out(noise(0,0,101)*0.3 |> lp(@,800), sine(440)*0.3 |> lp(@,800))", "routing? two args, maximally different, each lp"),
    ("18_two_args_no_lp", "out(noise(0,0,101)*0.3, sine(440)*0.3)", "control for 17, no filter"),
    ("19_stereo_of_two_lp", "out(stereo(noise(0,0,101)*0.3 |> lp(@,400), noise(0,0,977)*0.3 |> lp(@,1600)))", "DECISIVE 3: two lp instances, ONE out arg"),
    ("20_lp_of_stereo_of_two_lp", "out(stereo(noise(0,0,101)*0.3 |> lp(@,400), noise(0,0,977)*0.3 |> lp(@,1600)) |> lp(@,3000))", "DECISIVE 4: as 19, then one more lp"),
    ("21_stereo_of_raw_then_lp", "out(stereo(noise(0,0,101)*0.3, noise(0,0,977)*0.3) |> lp(@,400) |> lp(@,1600))", "DECISIVE 5: wide, then TWO lp instances, one out arg"),
]


def main():
    os.makedirs(WORK, exist_ok=True)
    written = []
    for name, body, note in CASES:
        patch = os.path.join(WORK, name + ".akk")
        with open(patch, "w", encoding="utf-8") as handle:
            handle.write("// %s\nbpm = 60\n%s\n" % (note, body))
        written.append((name, note, patch))

    for name, _note, patch in written:
        out = os.path.join(WORK, name + ".wav")
        if os.path.exists(out):
            os.remove(out)
        result = subprocess.run(
            [NKIDO, "render", patch, "-o", out, "--seconds", "4", "--rate", "48000",
             "--bpm", "60", "--no-default-bank"],
            capture_output=True, text=True,
        )
        if result.returncode != 0 or not os.path.exists(out):
            print("RENDER FAILED %s: %s" % (name, (result.stdout + result.stderr).strip()[:200]))
            return 1

    report = os.path.join(WORK, "report.json")
    subprocess.run(
        [sys.executable, ANALYZER, "-", *[os.path.join(WORK, n + ".wav") for n, _, _ in written],
         "--json-out", report, "--quiet"],
        capture_output=True, text=True,
    )
    with open(report, "r", encoding="utf-8") as handle:
        data = json.load(handle)
    by_name = {os.path.basename(entry["path"]).replace(".wav", ""): entry for entry in data["stems"]}

    print("%-20s %8s %8s  %s" % ("case", "corr", "width", "note"))
    for name, note, _patch in written:
        entry = by_name.get(name)
        if not entry:
            print("%-20s %8s %8s  %s" % (name, "-", "-", note))
            continue
        print("%-20s %8.3f %8.1f  %s" % (name, entry["channel_correlation"], entry["stereo_width_db"], note))
    return 0


if __name__ == "__main__":
    sys.exit(main())
