"""Why does putting a signal through stereo() make it 27 dB louder?

notes_with_rests peaked at -27.8 dBFS. notes_wide, the same notes wrapped in
stereo() and a filter, peaked at -0.9 and hit the master soft clip. That is not
a two-channel level change, it is more than a hundredfold.

This measures the level of each construction on its own so the answer is a
number rather than an inference.
"""

import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import analyze_audio  # noqa: E402

NKIDO = r"C:\projects\_tools\nkido\build-clang\bin\nkido.exe"
WORK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "probe", "level")

CASES = {
    "a_mono_out": 'bpm = 120\nmel = n"[a4 ~ c5 ~ e5 ~ bb5 ~]"\nout(mel |> tri(@.freq) * adsr(@.gate, 0.012, 0.12, 0.5, 0.2) * 0.04)',
    "b_stereo_same": 'bpm = 120\nmel = n"[a4 ~ c5 ~ e5 ~ bb5 ~]"\nout(stereo(mel |> tri(@.freq) * adsr(@.gate, 0.012, 0.12, 0.5, 0.2) * 0.04, mel |> tri(@.freq) * adsr(@.gate, 0.012, 0.12, 0.5, 0.2) * 0.04))',
    "c_stereo_then_filter": 'bpm = 120\nmel = n"[a4 ~ c5 ~ e5 ~ bb5 ~]"\nout(stereo(mel |> tri(@.freq) * adsr(@.gate, 0.012, 0.12, 0.5, 0.2) * 0.04, mel |> tri(@.freq) * adsr(@.gate, 0.012, 0.12, 0.5, 0.2) * 0.04) |> lp(@, 2200, 1.1))',
    "d_plain_sine_out": 'bpm = 120\nout(tri(220) * 0.04)',
    "e_plain_sine_stereo": 'bpm = 120\nout(stereo(tri(220) * 0.04, tri(220) * 0.04))',
    "f_plain_sine_stereo_half": 'bpm = 120\nout(stereo(tri(220) * 0.02, tri(220) * 0.02))',
    "g_plain_sine_stereo_filtered": 'bpm = 120\nout(stereo(tri(220) * 0.02, tri(220) * 0.02) |> lp(@, 900, 1.1))',
    "h_plain_sine_stereo_filtered_quarter": 'bpm = 120\nout(stereo(tri(220) * 0.01, tri(220) * 0.01) |> lp(@, 900, 1.1))',
    "i_noise_out": 'bpm = 120\nout(noise() * 0.04 |> lp(@, 900, 1.1))',
    "j_noise_stereo_filtered": 'bpm = 120\nout(stereo(noise() * 0.04, noise() * 0.04) |> lp(@, 900, 1.1))',
}


def main():
    os.makedirs(WORK, exist_ok=True)
    print("%-32s %8s %8s %8s" % ("case", "peak", "rms", "LUFS"))
    for name, body in sorted(CASES.items()):
        patch = os.path.join(WORK, name + ".akk")
        wav = os.path.join(WORK, name + ".wav")
        with open(patch, "w", encoding="utf-8") as handle:
            handle.write("// level probe\n" + body + "\n")
        result = subprocess.run(
            [NKIDO, "render", patch, "-o", wav, "--seconds", "8", "--rate", "48000",
             "--bpm", "120", "--no-default-bank"],
            capture_output=True, text=True,
        )
        if result.returncode != 0 or not os.path.exists(wav):
            print("%-32s RENDER FAILED" % name)
            continue
        m = analyze_audio.measure(wav)
        print("%-32s %8.1f %8.1f %8.1f" % (name, m["peak_dbfs"], m["rms_dbfs"], m["integrated_lufs"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
