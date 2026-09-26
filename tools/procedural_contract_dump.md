# `tools/procedural_contract_dump.gd`

Owner **W9**. Paths owned: this file and `tools/procedural_contract_dump.gd`. Nothing else.

## Why this file exists

Three Kit plans quote the frozen API of `core/procedural`. One of them invented
functions that do not exist — `Procedural.seed_for`, `rect_sdf`, `raster`,
`texture`, `spring`, `deform_field`, `squish_rig` — and then, instead of
correcting the plan against the contract, it planned to *route around* the
mismatch with an adapter. A named adapter is a way of saying "I know this name
is wrong and I am going to keep using it anyway."

That failure has to become impossible to repeat silently. A human-readable
`CONTRACT.md` cannot do it: the human is the one who was wrong, and the human
does not re-read the contract. So the machine reads the engine and the machine
reads the plans, and the machine disagrees out loud with a file and line number.

This tool is that machine. It never reads a contract markdown file to decide
whether a symbol exists. It reads `core/procedural/**` and `core/worldstate/**`.

## How to run it

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'

# both modes, default plan list
& $GodotExe --headless --path C:\projects\TINProject --script res://tools/procedural_contract_dump.gd
"exit: $LASTEXITCODE"

# MODE 1 only: print the authoritative API table to copy into a plan
& $GodotExe --headless --path C:\projects\TINProject --script res://tools/procedural_contract_dump.gd --dump

# MODE 2 only: skip the API table, just validate the plans
& $GodotExe --headless --path C:\projects\TINProject --script res://tools/procedural_contract_dump.gd --scan

# scan an extra file (repeatable) — used to prove the detector on a scratch copy
& $GodotExe --headless --path C:\projects\TINProject --script res://tools/procedural_contract_dump.gd `
  --scan --plan=C:\Users\Sherum\AppData\Local\Temp\opencode\w9_scratch_probe.md
```

No scene tree node, no `.tscn`, no autoload, no `Input.`, no `InputMap`, no
`/root`, no service locator. It `extends SceneTree` only so that `quit(code)`
exists for the exit code; it creates nothing and touches no node.

**Exit code is non-zero when at least one `FAIL` line is printed.** Do not
translate a zero exit code into "the plans are correct" without reading the
summary line, and do not translate a non-zero code into "the engine is broken" —
read the file and line, then go look at that line.

## MODE 1 — introspection (the authoritative dump)

Walks the real global class registry
(`ProjectSettings.get_global_class_list()`) *and* the real script files
(`DirAccess` recursion + `FileAccess`), unions the two, and parses each file for
its `enum`, `const`, public `var`, `func` and inner `class` declarations.
Prints, per class, every method with its argument names, argument types,
default presence, `static` flag, return type, and the legal arity window
`[min, max]`. `min` is the required count, `max` is the total count.

If a class's script fails to load, the header says `[LOAD FAILED]`, so a
half-compiled class can never be silently reported as an API.

This mode also emits `INFO DOC_DRIFT` lines comparing the `CONTRACT.md` tables
against the code, in both directions: a name the doc lists that the engine does
not have, and a class the engine has that no doc table lists. These are
informational and never affect the exit code — the docs are somebody else's
file to fix, and the tool is not allowed to touch them.

## MODE 2 — plan validation

Scans these documents for `Procedural*` and `WorldState*` symbols:

- `plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md`
- `plans/kits/07_PHYSICS_PUZZLE_PLATFORMER_KIT.md`
- `plans/kits/08_DESCENT_EXPLORATION_KIT.md`

Each symbol lands in exactly one bucket.

| bucket | meaning | exit code |
|---|---|---|
| `OK` | exists, and arity/argument types match the engine | — |
| `MISSING` | the name exists nowhere in `core/procedural` or `core/worldstate`. It is an invention. | **non-zero** |
| `SHAPE_MISMATCH` | it exists, but the plan states a different arity or a different argument type | **non-zero** |
| `OK_NEGATED` | it does not exist, but the plan's own line marks it as not existing / forbidden / an exception. Reported, never silent, never fatal. | — |
| `OK_OPEN_QUESTION` | it does not exist, but the plan lists it in its own Open Questions section as a future addition | — |

Every finding prints as one line:

```
FAIL MISSING 07_PHYSICS_PUZZLE_PLATFORMER_KIT.md:1936 `Procedural.texture` does not exist
```

### The exception rule, stated honestly

The narrow rule is: a name is acceptable only if the plan itself marks it as a
future addition in its own open-questions section. The tool implements that.

It also implements one bucket the narrow rule does not name, because without it
the tool would cry wolf forever and be ignored: **`OK_NEGATED`**. A line that
says "this function does not exist", "using it is a contract violation", or "the
only exception is X" is a plan *correctly prohibiting* a name. Failing a plan for
prohibishing an invention inverts the tool's whole purpose. So a missing name on
a line that carries a negation marker is reported as `OK_NEGATED` and counted
separately in the summary. It is never hidden — the line is printed every run.

`OK_NEGATED` downgrades failures only. A name that genuinely exists is `OK`
regardless of negation wording.

### What counts as a symbol claim, and what does not

Plans state APIs as adjacent backtick code spans: `` `ProceduralCanvas.blur / posterize / copy_from / shift` ``.
Detecting the anonymous members in that list is where a naive scanner produces
pages of nonsense, so a bare name is only treated as an API claim when **its own
backtick list-run also names a `Procedural*`/`WorldState*` class**. Concretely
these do *not* become claims:

- `1.0 /s`, `(1.6 /s)`, `string / number / bool / array` — no class in the run
- `` `/root` `` — the slash opens a path, it is not a separator
- `` `phase_speed 12.0`는 `ProceduralBackdropDynamics`의 … `` — Korean prose
  separates the spans, so it is a sentence, not a list
- `get_tree().get_nodes_in_group("module")` on a line with no core class

Explicit `Class.member` and `Class(...)` claims are gated only on the line naming
a real class, because the class token already anchors them.

A slash continuation is validated against **any** core class rather than the one
just named, because a row like `` `ProceduralBodyPart` / `ProceduralCreatureBuilder` / `ProceduralSquishRig` ``
then lists `bounds compose_canvas outline compose`, and those belong to different
classes. An explicit `Class.member` is always checked against that class only.

### Type comparison is deliberately lenient

`int`/`float` and `String`/`StringName` are treated as compatible, and an
untyped plan argument is never a mismatch. A plan that writes
`Procedural.make_palette(world_seed, region_index)` is naming arguments
positionally; failing it for omitting default markers would be noise.

## Proving the detector still works

A tool that reports zero failures looks identical to a broken tool. Before
trusting a clean run, plant a fake and confirm it is caught:

1. Copy a plan to a scratch path.
2. Append a table containing `Procedural.totally_fake_fn`, `ProceduralNotAClass`,
   `ProceduralSdf.circle / ellipse / fabricated_shape`,
   `Procedural.derive_seed(a, b, c, d)` and `ProceduralSdf.box(p, center, half_size: int)`.
3. Run with `--plan=<scratch path>`.
4. Expect `MISSING` for the first three and `SHAPE_MISMATCH` for the last two,
   each with the right line number, and `FAIL=` in the summary to be larger by
   five than the same run without the probe. The correct row
   (`Procedural.make_canvas(width: int, height: int)`) must land in `OK=` and add
   no failure — a detector that flags the true line is useless too.
5. Delete the scratch file.

Keep single backticks in the probe. A doubled `` `` `` is not a code span in
this tool's parser and will make a correct claim look unchecked.

## What this tool must never do

- Edit `core/**`, `plans/**`, `docs/**`, `modules/**`, `app/**`, or
  `tools/nkido_pipeline/**`. It reports inventions; it does not repair plans.
  Repairing a plan is the plan owner's decision, with W0.
- Read `CONTRACT.md` to decide whether a symbol exists. The markdown is the
  thing under test.
- Exit zero while a `FAIL` line was printed.
