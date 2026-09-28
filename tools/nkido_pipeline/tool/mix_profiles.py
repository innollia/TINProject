"""Render one WAV per ambience profile, so a mix can be judged as one file.

The person listening cannot audition three stems at once, and asking them to is
asking for a judgement they cannot make. So the mix is produced here instead:
every profile is summed exactly the way DescentAmbience sums it at runtime and
written to a single file. Listening to a profile then costs the same as
listening to a stem.

The sum is not a rough guide. It is the same arithmetic the game does:

  * gain is the stem's base volume_db plus the profile's linear gain, so this is
    the level the player will actually hear
  * stems shorter than the mix are tiled to fill it, which is what the looping
    AudioStreamPlayers do
  * the output is loop-folded at the same length, so a profile that clicks is a
    real defect and not an artefact of the preview

It also measures the mix, which a stem cannot. LUFS on a stem only says how
loud it was rendered; LUFS on a mix is the number that matters, and the per-stem
contribution in dB says whether one layer is masking the others. Those are the
parts of mix judgement that do not need ears.

Exit code 0 when every profile fits its targets, 1 otherwise.
"""

import argparse
import json
import math
import os
import sys
import wave

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import analyze_audio  # noqa: E402
import loopify  # noqa: E402

RATE = 48000


def read_stem(path):
    with wave.open(path, "rb") as handle:
        channels = handle.getnchannels()
        width = handle.getsampwidth()
        if width != 2:
            raise SystemExit("mix_profiles: %s is %d-bit, expected 16-bit" % (path, width * 8))
        frames = handle.getnframes()
        data = np.frombuffer(handle.readframes(frames), dtype="<i2")
    data = data.astype(np.float64) / 32768.0
    if channels > 1:
        data = data.reshape(-1, channels)
    else:
        data = data.reshape(-1, 1)
    return data


def to_stereo(data):
    if data.shape[1] == 1:
        return np.repeat(data, 2, axis=1)
    return data


def write_wav(path, data):
    clipped = int(np.sum(np.abs(data) >= 0.999969))
    limited = np.clip(data, -0.999969, 0.999969)
    scaled = (limited * 32767.0).astype("<i2")
    with wave.open(path, "wb") as handle:
        handle.setnchannels(2)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        handle.writeframes(scaled.tobytes())
    return clipped


def db_to_linear(db):
    return 10.0 ** (db / 20.0)


def build_profile(manifest, project_root, profile_name, profile, out_dir, targets, fade_seconds):
    audible = []
    for stem in manifest["stems"]:
        gain = float(profile["gains"].get(stem["id"], 0.0))
        if gain <= 0.0:
            continue
        path = os.path.join(project_root, stem["file"].replace("res://", "").replace("/", os.sep))
        if not os.path.exists(path):
            raise SystemExit("mix_profiles: stem file missing: %s" % path)
        audible.append({
            "id": stem["id"],
            "path": path,
            "role": stem.get("role", ""),
            "gain_db": float(stem["volume_db"]) + analyze_audio.linear_to_db(gain),
        })

    if not audible:
        return None

    # The mix is as long as the longest layer in it. That is the shortest length
    # at which the layering decision is actually visible, and it is the length
    # the runtime will settle on once the longest stem has looped once. The
    # extra fade length is the overhang the loop fold needs, exactly as the stem
    # build renders loop + fade and folds the overhang back over the head.
    mix_frames = max(loopify_frame_count(entry["path"]) for entry in audible)
    fade_frames = int(round(fade_seconds * RATE))
    longest = mix_frames + fade_frames
    mixed = np.zeros((longest, 2))
    contributions = []

    for index, entry in enumerate(audible):
        data = to_stereo(read_stem(entry["path"]))
        needed = longest - data.shape[0]
        if needed > 0:
            repeats = int(math.ceil(needed / max(1, data.shape[0]))) + 1
            data = np.tile(data, (repeats, 1))
        data = data[:longest] * db_to_linear(entry["gain_db"])
        mixed = mixed + data
        # Raw energy per layer. The share is worked out below against the
        # finished mix; measuring against a running total makes the number
        # depend on the order the layers happen to be listed in, which is
        # exactly the bug this replaced.
        audible[index]["energy"] = float(np.sum(data * data))

    final_energy = float(np.sum(mixed * mixed))
    for entry in audible:
        share = 10.0 * math.log10(entry["energy"] / final_energy) if final_energy > 1e-12 and entry["energy"] > 0 else -120.0
        contributions.append((entry["id"], entry["role"], entry["gain_db"], share))

    # The bus trim goes on the sum, not on the accumulator. Scaling a zero
    # array is still a zero array, which is exactly what happened the first
    # time this was written.
    mixed = mixed * db_to_linear(float(manifest.get("mix_trim_db", 0.0)))

    name = "%s_mix" % profile_name
    path = os.path.join(out_dir, name + ".wav")
    clipped = write_wav(path, mixed)

    # Fold the loop so the preview is loopable like the real thing.
    raw = os.path.join(out_dir, name + ".raw.wav")
    write_wav(raw, mixed)
    loopify.fold_file(raw, path, mix_frames, fade_frames, quiet=True)
    os.remove(raw)

    measured = analyze_audio.measure(path)
    measured["file"] = name + ".wav"
    measured["path"] = path
    measured["clipped_samples"] = measured["clipped_samples"] + clipped

    limits = dict(targets.get("mix", {}))
    override = targets.get("mix_exempt", {}).get(profile_name)
    if override:
        limits.update(override)
    share_floor = targets.get("mix_layer_share_floor_db")
    advisory = targets.get("mix_layer_share_advisory_db", -18.0)

    problems = []
    loudness = limits.get("integrated_lufs")
    if loudness is not None and not (loudness[0] <= measured["integrated_lufs"] <= loudness[1]):
        problems.append("%s: mix reads %.1f LUFS, outside %.1f..%.1f" % (
            name, measured["integrated_lufs"], loudness[0], loudness[1]))
    ceiling = limits.get("true_peak_max_db")
    if ceiling is not None and measured["true_peak_dbfs"] > ceiling:
        problems.append("%s: mix true peak %.2f dBFS is above %.2f" % (name, measured["true_peak_dbfs"], ceiling))
    if measured["clipped_samples"] > 0:
        problems.append("%s: mix has %d clipped samples" % (name, measured["clipped_samples"]))
    if measured["loop"]["jump_ratio"] > 3.0:
        problems.append("%s: mix loop wrap jump ratio %.2f" % (name, measured["loop"]["jump_ratio"]))
    if share_floor is not None:
        for stem_id, role, gain_db, share in contributions:
            if share < share_floor:
                problems.append("%s: layer '%s' sits %.0f dB under the mix, inaudible" % (
                    name, stem_id, share))

    return {
        "profile": profile_name,
        "path": path,
        "layers": len(audible),
        "seconds": measured["seconds"],
        "integrated_lufs": measured["integrated_lufs"],
        "true_peak_dbfs": measured["true_peak_dbfs"],
        "stereo_width_db": measured["stereo_width_db"],
        "channel_correlation": measured["channel_correlation"],
        "loop_jump": measured["loop"]["jump_ratio"],
        "contributions": contributions,
        "audible": audible,
        "problems": problems,
        "advisories": [("%s: layer '%s' sits %.0f dB under the mix" % (name, stem_id, share))
                       for stem_id, role, gain_db, share in contributions
                       if share_floor <= share < advisory],
    }


def propose_balance(manifest, results, share_floor):
    """Raise every layer that is provably inaudible to the floor, and nothing else.

    A layer sitting 40 dB under the mix is not a mixing taste, it is off. The
    ear has nothing to say about it. A layer above the floor is a real
    decision and this leaves it alone.

    The gain is solved in energy: a layer 12 dB below the floor needs its energy
    multiplied by 12 dB, which is its gain multiplied by about 3.98.
    """
    changes = {}
    for result in results:
        proposal = {}
        for stem_id, role, gain_db, share in result["contributions"]:
            if share >= share_floor:
                continue
            current = float(manifest["profiles"][result["profile"]]["gains"][stem_id])
            lift = (share_floor - share) / 2.0  # energy dB -> amplitude gain is half
            proposed = min(1.0, current * (10.0 ** (lift / 20.0)))
            if proposed > current + 0.001:
                proposal[stem_id] = round(proposed, 3)
        if proposal:
            changes[result["profile"]] = proposal
    return changes


_LOOP_CACHE = {}


def loopify_frame_count(path):
    if path not in _LOOP_CACHE:
        with wave.open(path, "rb") as handle:
            _LOOP_CACHE[path] = handle.getnframes()
    return _LOOP_CACHE[path]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--targets", required=True)
    parser.add_argument("--project-root", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--fade-seconds", type=float, default=0.5)
    parser.add_argument("--balance", action="store_true",
                        help="print the gain changes that would lift every inaudible layer to the floor")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    # utf-8-sig: a stray BOM in a machine-input file should not stop the run.
    with open(args.manifest, "r", encoding="utf-8-sig") as handle:
        manifest = json.load(handle)
    with open(args.targets, "r", encoding="utf-8-sig") as handle:
        targets = json.load(handle)

    os.makedirs(args.out, exist_ok=True)
    order = ["surface", "wade", "column", "deep", "cavern", "dread", "silence"]
    names = [n for n in order if n in manifest["profiles"]]
    names += [n for n in sorted(manifest["profiles"]) if n not in names]

    failures = []
    results = []
    advisories = []
    for name in names:
        result = build_profile(manifest, args.project_root, name, manifest["profiles"][name],
                               args.out, targets, args.fade_seconds)
        if result is None:
            continue
        results.append(result)
        failures.extend(result["problems"])
        advisories.extend(result["advisories"])

    if not args.quiet:
        print("  %-14s %6s %8s %9s %7s %7s %6s" % ("profile", "layers", "seconds", "LUFS", "truepk", "width", "loopj"))
        for result in results:
            print("  %-14s %6d %8.1f %9.1f %7.1f %7.1f %6.2f" % (
                result["profile"], result["layers"], result["seconds"],
                result["integrated_lufs"], result["true_peak_dbfs"],
                result["stereo_width_db"], result["loop_jump"]))
        print()
        print("  layer share, dB below the running total (a layer more than 20 dB down is inaudible in the mix):")
        for result in results:
            ranked = sorted(result["contributions"], key=lambda row: -row[3])
            print("  %-9s %s" % (result["profile"], "  ".join(
                "%s%s%+.1f" % (row[0][:9], "*" if row[1] == "music" else "", row[3]) for row in ranked)))

    for problem in failures:
        print("  FAIL " + problem, file=sys.stderr)
    for note in advisories:
        print("  NOTE " + note)

    if args.balance:
        changes = propose_balance(manifest, results, targets.get("mix_layer_share_floor_db", -22.0))
        print()
        if not changes:
            print("  balance: nothing to lift, every layer is already audible")
        for profile, proposal in sorted(changes.items()):
            for stem_id, value in sorted(proposal.items()):
                was = manifest["profiles"][profile]["gains"][stem_id]
                print("  balance: %-8s %-14s %.3f -> %.3f" % (profile, stem_id, was, value))

    report = os.path.join(args.out, "profiles.json")
    with open(report, "w", encoding="utf-8") as handle:
        json.dump({"mixes": results, "failures": failures}, handle, indent=2, default=str)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
