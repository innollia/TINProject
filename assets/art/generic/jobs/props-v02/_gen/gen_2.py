"""Batch 2: nether star, coral, end crystal, echo shard, ceramic shard, anvil, trial key, breeze rod."""

from common import MB_BIG, MB_MID, MB_SML, base, form, write_all

R = []

# --------------------------------------------------------- it_nether_star
r = base("it_nether_star", 109, "Loot nether star: a dark spiky star with an inner star facet and a "
                               "small set core.")
r["forms"] = [
    form("star", "nether_star", 0,
         [{"icon": "star", "at": [64, 64], "size": [100, 100], "rot": 0}]),
    form("facet", "nether_star", 1,
         [{"icon": "star", "at": [64, 64], "size": [60, 60], "rot": 36}],
         color="#9a8759"),
    form("core", "nether_star", 2,
         [{"icon": "hexagon", "at": [64, 64], "size": [20, 20], "rot": 0}],
         color="#6d5f42"),
    form("spark", "nether_star", 3,
         [{"icon": "stars", "crop": [9, 0, 16, 8], "at": [101, 25], "size": [22, 22]}],
         kind="flat", opacity=0.55),
]
R.append(r)

# --------------------------------------------------------------- it_coral
r = base("it_coral", 110, "Loot coral (narrowed 'sea loot' to coral): three knobbly branching "
                         "coral arms on a dark rock base.")
r["forms"] = [
    form("base", "stone_dark", 0,
         [{"icon": "metaballs", "crop": MB_BIG, "at": [64, 98], "size": [76, 68]}]),
    form("arm_l1", "coral", 1,
         [{"icon": "metaballs", "crop": MB_BIG, "at": [46, 70], "size": [48, 44]}]),
    form("arm_l2", "coral", 2,
         [{"icon": "metaballs", "crop": MB_MID, "at": [36, 46], "size": [32, 34]}]),
    form("arm_l3", "coral", 3,
         [{"icon": "metaballs", "crop": MB_SML, "at": [30, 28], "size": [22, 20]}]),
    form("arm_r1", "coral", 1,
         [{"icon": "metaballs", "crop": MB_BIG, "at": [86, 74], "size": [44, 40]}]),
    form("arm_r2", "coral", 2,
         [{"icon": "metaballs", "crop": MB_MID, "at": [94, 52], "size": [28, 30]}]),
    form("arm_r3", "coral", 3,
         [{"icon": "metaballs", "crop": MB_SML, "at": [100, 36], "size": [19, 18]}]),
    form("arm_c1", "coral", 1,
         [{"icon": "metaballs", "crop": MB_BIG, "at": [65, 62], "size": [52, 48]}]),
    form("arm_c2", "coral", 2,
         [{"icon": "metaballs", "crop": MB_MID, "at": [63, 36], "size": [36, 38]}]),
    form("arm_c3", "coral", 3,
         [{"icon": "metaballs", "crop": MB_SML, "at": [62, 20], "size": [24, 22]}]),
]
R.append(r)

# --------------------------------------------------------- it_end_crystal
r = base("it_end_crystal", 111, "Loot end crystal (narrowed 'end dimension loot' to a crystal): a tall "
                                "faceted crystal with two smaller shards, all using the shared "
                                "pyramid facet split.")
r["forms"] = [
    form("shard_l", "crystal", 0,
         [{"icon": "pyramid", "at": [32, 90], "size": [44, 58], "rot": -20}]),
    form("shard_r", "crystal", 0,
         [{"icon": "pyramid", "at": [96, 92], "size": [42, 54], "rot": 20}]),
    form("main", "crystal", 1,
         [{"icon": "pyramid", "at": [64, 58], "size": [80, 96]}]),
    form("glint", "crystal", 2,
         [{"icon": "diamond_shape", "at": [92, 24], "size": [20, 20], "rot": 0}],
         kind="flat", color="#e6dcee", opacity=0.75),
]
R.append(r)

# --------------------------------------------------------- it_echo_shard
r = base("it_echo_shard", 112, "Loot echo shard (narrowed 'echo fragments' to a shard): a cluster of "
                              "flat faceted shards, same pyramid facet split as the crystals.")
r["forms"] = [
    form("main", "echo_stone", 0,
         [{"icon": "pyramid", "at": [56, 74], "size": [88, 68], "rot": -16}]),
    form("second", "echo_stone", 0,
         [{"icon": "pyramid", "at": [92, 88], "size": [50, 42], "rot": 24}]),
    form("facet", "echo_stone", 1,
         [{"icon": "pyramid", "at": [54, 76], "size": [34, 26], "rot": -16}],
         color="#4a545e"),
    form("chip", "echo_stone", 2,
         [{"icon": "pyramid", "at": [100, 34], "size": [28, 28], "rot": 34}]),
]
R.append(r)

# ------------------------------------------------------ it_ceramic_shard
r = base("it_ceramic_shard", 113, "Loot ceramic shard: a curved pale sherd from a broken pot.  The "
                                 "glaze band is the same cone piece clipped to the sherd, so the "
                                 "two edges can never drift apart.")
r["forms"] = [
    form("sherd", "ceramic", 0,
         [{"icon": "cone", "crop": [2, 5, 15, 14], "at": [58, 68], "size": [92, 84], "rot": -14}]),
    form("glaze", "ceramic", 1,
         [{"icon": "cone", "crop": [2, 5, 15, 9], "at": [58, 68], "size": [92, 84], "rot": -14}],
         kind="wash", color="#87796a", opacity=0.55, clip_to="sherd"),
    form("small", "ceramic", 2,
         [{"icon": "cone", "crop": [6, 10, 14, 15], "at": [94, 98], "size": [44, 30], "rot": 18}],
         color="#a2937f"),
]
R.append(r)

# ------------------------------------------------------------- it_anvil
r = base("it_anvil", 114, "Loot anvil form: a smith's anvil silhouette built from a horn, face, waist "
                         "and foot, pitted iron.")
r["forms"] = [
    form("foot", "iron", 0,
         [{"icon": "square", "crop": [1, 10, 15, 14], "at": [66, 100], "size": [78, 22]}]),
    form("waist", "iron", 1,
         [{"icon": "square", "crop": [5, 6, 11, 11], "at": [62, 76], "size": [40, 46]}]),
    form("face", "iron", 2,
         [{"icon": "square", "crop": [1, 1, 15, 6], "at": [64, 50], "size": [86, 26]}]),
    form("horn", "iron", 3,
         [{"icon": "cone", "at": [101, 51], "size": [40, 34], "rot": 106}]),
    form("pit", "iron", 4,
         [{"icon": "circle", "at": [50, 50], "size": [11, 11]}],
         kind="flat", color="#1a1a1e", opacity=0.6),
]
R.append(r)

# ---------------------------------------------------------- it_trial_key
r = base("it_trial_key", 115, "Loot trial key: a long key with a set stone in the bow, hanging on a "
                             "bronze ring.")
r["forms"] = [
    form("ring", "bronze", 0,
         [{"icon": "ring", "at": [48, 24], "size": [32, 24], "rot": 20}]),
    form("key", "bronze", 1,
         [{"icon": "key", "at": [68, 72], "size": [96, 96], "rot": -25}]),
    form("stone", "nether_star", 2,
         [{"icon": "diamond_shape", "at": [68, 38], "size": [22, 22], "rot": 0}]),
]
R.append(r)

# --------------------------------------------------------- it_breeze_rod
r = base("it_breeze_rod", 116, "Loot breeze rod: a pale iron rod with collar rings and a capped end.")
r["forms"] = [
    form("shaft", "breeze_rod", 0,
         [{"icon": "square", "crop": [1, 7, 15, 9], "at": [64, 64], "size": [104, 18], "rot": -24}]),
    form("collar_l", "breeze_rod", 1,
         [{"icon": "square", "crop": [5, 4, 11, 12], "at": [42, 83], "size": [16, 27], "rot": -24}],
         color="#7c858a"),
    form("collar_r", "breeze_rod", 1,
         [{"icon": "square", "crop": [5, 4, 11, 12], "at": [84, 47], "size": [15, 25], "rot": -24}],
         color="#7c858a"),
    form("cap", "breeze_rod", 2,
         [{"icon": "cylinder", "crop": [3, 0, 13, 4], "at": [99, 32], "size": [26, 22], "rot": -24}],
         color="#b6bfc4"),
]
R.append(r)

write_all(R)
