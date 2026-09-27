"""Build the review sheets: 8 icons per sheet at 2x on the grey-violet floor colour."""
import subprocess
import sys
import pathlib

JOB = pathlib.Path(__file__).resolve().parents[1]
IDS = [
    "it_bone", "it_string", "it_feather", "it_leather", "it_ink_sac", "it_turtle_scute",
    "it_slime_ball", "it_blaze_powder", "it_nether_star", "it_coral", "it_end_crystal",
    "it_echo_shard", "it_ceramic_shard", "it_anvil", "it_trial_key", "it_breeze_rod",
    "it_heavy_core", "it_resin_lump", "it_dye_recipe_note", "it_glass_bottle", "it_nether_wart",
    "it_redstone_dust", "it_glowstone_dust", "it_gunpowder", "it_dragon_breath", "it_spider_eye",
    "it_sugar", "it_rabbit_foot", "it_glimmer_melon", "it_magma_cream", "it_ghast_tear",
    "it_phantom_membrane",
]
missing = [i for i in IDS if not (JOB / "output" / i / f"{i}.png").exists()]
if missing:
    print("MISSING:", " ".join(missing))

per = int(sys.argv[1]) if len(sys.argv) > 1 else 8
scale = sys.argv[2] if len(sys.argv) > 2 else "2"
for n in range(0, len(IDS), per):
    chunk = [i for i in IDS[n:n + per] if (JOB / "output" / i / f"{i}.png").exists()]
    if not chunk:
        continue
    out = JOB / "preview" / f"p{n // per + 1:02d}.png"
    cmd = [sys.executable, "-B", "tool/review_sheet.py", "--scales", scale, "--bg", "#6a6270",
           "--out", str(out)] + [str(JOB / "output" / i / f"{i}.png") for i in chunk]
    subprocess.run(cmd, cwd=JOB, check=True)
