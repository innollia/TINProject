# 뭉탱이 상태 스토어 — 사용 설명

Owner **W7**. Public signatures are frozen in `CONTRACT.md`; that file is the
authority a Kit plan must quote, not this one. The design is
`DESIGN_DECISION.md` and it is not edited from here.

> **세 Kit의 저장은 원본이 아니다. 원본은 여기 있고, Kit는 뷰만 갖는다.**

Three Kits run in `ModuleHost` one at a time and cannot see each other. Without
a single owner each Kit would write its own save and the project would be three
games. This folder is the owner. It holds exactly three axes — `body`,
`creature`, `place` — and the axis list is not extended.

| File | Class | Role |
|---|---|---|
| `world_state.gd` | `WorldState` | the owner. arbitrates, serialises, restores. |
| `axis_body.gd` | `AxisBody` | the player's body. observable facts only. |
| `axis_creature.gd` | `AxisCreature` | one individual, fixed by a global id. |
| `axis_place.gd` | `AxisPlace` | authored terrain. immutable at runtime. |
| `world_state_view.gd` | `WorldStateView` | the read-only handle a module receives. |

Nothing here is a `Node`. Nothing here touches the scene tree, `Input`,
`InputMap`, `get_tree()`, `/root`, an autoload or a service locator. Nothing
here imports from `modules/`. Arbitration happens in this folder precisely so
it still works when the owning Kit is not loaded.

## How a module obtains a view

The store hands the view through `ModuleContext.arrival`, by reference, under
`WorldState.ARRIVAL_KEY`. A module reads it and nothing else:

```gdscript
func enter(context: ModuleContext) -> void:
	super(context)
	view = WorldStateView.from_arrival(context.arrival)
	if view == null:
		return                      # the store is not in this session. handle it, do not invent
```

`ModuleDirector` deep-copies `arrival`, and a deep copy leaves `Object` values
alone, so the view survives the copy intact. `from_arrival` returns `null` when
there is no view, and the module handles absence or halts. It does not build a
replacement.

The view is refreshed by the store on every accepted write and cursor move, so a
module does not poll and does not re-read. It holds a snapshot and no reference
back to the store, which is why there is nothing for a module to corrupt.

## How a module reads

Every `get_*` returns `null` for an absent field. That is the entire
no-invented-default rule in one sentence. `has_*` tells absence from emptiness.

```gdscript
var body: AxisBody = view.get_body()
if body == null:
	return
if body.has_scale():
	var scale: float = float(body.get_scale())     # one of six rungs. never a continuous float
for part: String in body.get_missing() as Array[String]:
	...                                            # one lost arm, three genres, three readings
var gardener: AxisCreature = view.get_creature("fix.gardener")
if gardener != null and gardener.remembers({"kind": "carried_a_lantern"}):
	...                                            # a remembered event, not a favour score
```

The store never interprets a fact. Whether one arm can lift a crate is a
`sideview_ecosystem` rule; whether it changes buoyancy is a
`descent_exploration` rule. Both read the same `missing` array and neither
edits it.

For the one question three Kits ask about the same place, use the composed
judgement:

```gdscript
var verdict: Dictionary = view.body_satisfies("place.tea_stair")
# { ok, reason, detail, satisfied, unmet }
# unmet: ["scale_absent"] when the body has no scale. never ["scale_below_min"] from a made-up 0
```

## How a module requests a mutation

A module cannot write. It asks, and the store decides. The store is not in
`arrival`, so the module needs it injected as a separate call; that is the app
layer's business, and the ordering rule is the same one that owns
`request_mutation` in the first place — the module never reaches for a service.

```gdscript
var result: Dictionary = store.request_mutation(WorldState.AXIS_BODY, patch, context.module_id)
if not result["ok"]:
	push_warning("world state refused %s: %s" % [result["reason"], result["detail"]])
	return
```

The patch is a per-field assignment, not a merge. A field you do not mention
keeps its value **and its absence**. A refused request changes nothing at all:
the store stages a copy, validates, and either swaps it in or drops it.

```gdscript
# one arm gone, recorded as an observable fact
{"missing": ["left_arm"]}

# a wound, as four facts and not as a health bar
{"wounds": [{"part": "face", "kind": "scar", "severity": 2, "permanent": true}]}

# a value in the body scale it was measured in
{"facts": {"carry_load": 200}}
```

A patch is rejected if the key is a derived summary. `health`, `hp`,
`health_fraction`, `condition`, `wound_count` and the rest of `DERIVED_KEYS`
are refused on any axis. Store the fact, not the summary.

## What the refusal reasons mean

The full table with the module's response for each is in `CONTRACT.md`. The
three that change how you write code:

- `requester_not_owner` — you are not the owning Kit. Not a timing problem. Do
  not retry, do not route around it. It is a design error, and the design
  matrix in `DESIGN_DECISION.md` §6 already says who may write what.
- `axis_absent` — the axis has no record yet. Absence is not `0` and not `{}`.
  Handle it or halt.
- `axis_read_only` — `place` is authored. Any write to it is refused before the
  request is even inspected, from every Kit, forever.

`creature_archetype_fixed` is worth calling out because it is a Kit-facing
design rule rather than a data error: an individual's species is set by its
creator and does not change. A new individual gets a new id.

## The body has two kinds of field, and scale is a six-rung ladder

A body field is exactly one of three, and the table is closed
(`AxisBody.FIELD_CLASSES`, readable per field through `field_class()`):

| class | what it is | fields | comes back? |
|---|---|---|---|
| `permanent_fact` | something that already happened. a lost part, a scar | `missing`, `wounds` | **no** |
| `mutable_capability` | what this body can do right now | `scale` | **yes** |
| `unclassified` | a number the Kit measured in its own grammar | `facts` | the store does not judge |

The two real classes are never mixed. A permanent fact is never treated like
equipment and a capability is never treated as progress. `scale` is reversible,
which is why the world constitution's "a body change is not one-way" invariant
stands with no exemption — but reversible is not a licence: the ladder decides what
may be stored.

```gdscript
body.field_class(&"scale")["value"]      # mutable_capability
body.field_class(&"missing")["value"]    # permanent_fact
body.field_class(&"resource")["ok"]      # false, key_unknown. "I do not know"
                                          # is never returned as a class
```

A recorded permanent fact cannot be un-recorded. Clearing the field, or replacing
it with a list that no longer holds a recorded entry, is refused with
`body_fact_is_permanent`; adding another fact is still accepted, and a field that
holds no fact may still be written empty, because absence and emptiness are
different. A wound's identity is `part` + `kind`, so re-measuring its `severity`
is the same fact measured again, not a new one and not a refusal.

`scale` is one rung of a closed ladder, and never a continuous float:

```
speck 0.05 · hand 0.12 · doll 0.28 · common 0.65 · tall 1.50 · colossal 3.60
```

`1.0` is not a rung and is refused with its own reason, because a normal size
would be a belief this world does not have. Any other number is refused rather
than snapped to the nearest rung. Continuous floats are banned for the same reason
the ban exists in the first place: a number on screen reads as a size, a
threshold stops being a threshold, and every Kit grows its own arithmetic.

```gdscript
store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.9}, OWNER)["reason"]
# scale_not_rung        nothing is stored. the nearest rung is not a fallback
store.request_mutation(WorldState.AXIS_BODY, {"scale": 1.0}, OWNER)["reason"]
# scale_rung_forbidden  "there is no normal size on this ladder"
```

A closed set of legal values is not a normalisation. The store still does not
touch a value that is already stored; it only refuses values it never accepted.
The rule is scoped: `1.0` is banned as the top-level body scale and nowhere else. A
wound `severity` of `1.0`, a number inside `facts`, and a `requires_body`
threshold of `1.0` are four different questions.

Reversible still means stored. `scale` lives in the `body` axis, a save restores
it, and a body with no scale has no scale: `has_scale()` is false, `get_scale()`
is `null`, no key appears in `to_dictionary()`, and a place that asks for one is
unmet with `scale_absent`. No rung is a default.

`check_mutation()` answers the same question `apply()` does and commits nothing,
which is how a Kit asks before it asks:

```gdscript
if not body.check_mutation(patch)["ok"]:
	return                                  # the reason is already filled in
var result: Dictionary = store.request_mutation(WorldState.AXIS_BODY, patch, OWNER)
```

## No normalisation, ever

A body whose stored value is 200 and which takes 1 damage stores 199. Nothing is
clamped, converted, averaged or moved between units. What was never written is
still not written after a save, a load or a hand-over. The body scale is the one
field with a closed set of legal values, and a refusal there still touches
nothing — see the ladder section above. A Kit's own measurements in `facts` stay
continuous floats, and `199.7` there is still `199.7` in a grammar that normally
speaks 1 to 3.

The store also refuses to compute summaries. `memory` is a list of events the
individual remembers, never a score. `AxisCreature` exposes no method that
counts, sums or totals it, and a test walks the method list to keep it that
way. "This body died three times" is something a creature observes by
remembering three deaths, not something the store keeps track of.

The one representation fix this store performs is wire-type restoration: JSON
has one number type, so a finite float with no fractional part is read back as
an `int`. The value is untouched; only the round trip is made stable.

## place is read-only

`AxisPlace` has no mutating method and none will be added. `create()` is the
authoring and restore path. Runtime writes are refused unconditionally, before
ownership, before the patch type, before anything — so there is no call shape
that reaches the place axis and lands.

`requires_body` is a **capability** condition, never a permission threshold. The
five accepted keys are `scale_min`, `scale_max`, `has_all_parts`, `has_wound`
and `has_no_wound`. A `karma`, `reputation`, `level`, `rank`, `price` or
`deaths` key is refused with `requires_body_not_capability` at authoring time,
so a gate on how much the player has been owed cannot be smuggled in as a
geometry check.

The scene cursor, `WorldState.focus_place()`, is not a place mutation. It is
the store's own position, it is refused for an unknown place, and no module can
reach it because the view has no such method.

## Save ownership

The origin is one save. Each Kit's save is a view of it.

```gdscript
var snapshot: Dictionary = store.to_dictionary()   # versioned, JSON-safe, "ax": 1
var text: String = store.to_json()
var restored: Dictionary = store.load_snapshot(snapshot)
```

Restore is atomic: if one nested record fails, nothing is overwritten and the
call says why. There is no silent overwrite with defaults. The envelope carries
`owners` as a compatibility assertion, not as an override — a snapshot that
disagrees with the session's owner declaration fails with
`owner_already_declared`, which is `DESIGN_DECISION.md` §7's "align the three"
made mechanical.

Determinism is a test, not an intention. Creature and place ids are exported in
sorted order, axis fields in declared order, and the same input JSON restores to
the same bytes.

## Worked hand-over

`place.ruined_garden`, three Kits deep. `sideview_ecosystem` owns `body` and
`creature`, so it is the only one that can write them.

**1 — the app boots.** It declares identity once, by id, not by live object, so
arbitration survives the owning Kit being unloaded.

```gdscript
var store: WorldState = WorldState.new()
store.declare_owner(WorldState.AXIS_BODY, &"sideview_ecosystem")
store.declare_owner(WorldState.AXIS_CREATURE, &"sideview_ecosystem")
# place is deliberately not declared. it has no runtime writer
var arrival: Dictionary = store.make_arrival()
```

**2 — `sideview_ecosystem` runs and the player loses an arm.** It reads the view,
decides the fact itself, and asks the store to store it.

```gdscript
var view: WorldStateView = WorldStateView.from_arrival(context.arrival)
var body: AxisBody = view.get_body()
if body.has_missing_part("left_arm"):
	return                              # already lost. the fact is not re-applied
var result: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {
	"missing": ["left_arm"],
	"wounds": [{"part": "left_arm", "kind": "severed", "severity": 1, "permanent": true}],
}, context.module_id)
if not result["ok"]:
	return                              # refused, with a reason. nothing changed
```

No fraction of a health bar. No `0.5` "damage multiplier". One part, gone, and a
wound that says so.

**3 — the gardener dies in that same scene.** Still the owner's call.

```gdscript
store.request_mutation(WorldState.AXIS_CREATURE, {
	"id": "fix.gardener",
	"state": "dead",
	"memory": (view.get_creature("fix.gardener").get_memory() as Array) + [
		{"kind": "blown_over", "place": "place.ruined_garden"},
	],
}, context.module_id)
```

The kit appends the event to the list it already had and sends the whole list
back. The store does not count anything.

**4 — the module is replaced.** `ModuleHost` empties, the other Kit loads, and
the app hands it the same store a fresh view. Nobody referenced the previous
module and no Kit referenced another Kit.

**5 — `physics_puzzle_platformer` reads the same body.** It does not know an arm
was lost in a side view. It asks what it needs, in its own physics.

```gdscript
var view: WorldStateView = WorldStateView.from_arrival(context.arrival)
var body: AxisBody = view.get_body()
var one_arm_left: bool = (body.get_missing() as Array[String]).size() == 1
var can_carry: bool = one_arm_left and float(body.get_fact(&"carry_load")) < 60.0
```

Sixty kilos is this Kit's number for one arm in this genre. The store does not
hold sixty. It holds `199` when 200 took 1, and `carry_load` as that Kit left it.

**6 — `descent_exploration` reads the same gardener.** A dead individual is a
dead individual. How it is shown — a body, a wreck, an empty patch of nettles —
is that Kit's whole business. The store has already said `state = "dead"` and
has no opinion.

**7 — the assertion from `DESIGN_DECISION.md` §5.**

```gdscript
# body.missing survived two genre changes, and the place still judges it.
var verdict: Dictionary = view.body_satisfies("place.ruined_garden")
assert(verdict["satisfied"])
assert((view.get_body().get_missing() as Array[String]) == ["left_arm"])
assert(view.get_creature("fix.gardener").get_state() == "dead")
```

Three Kits, one body, one dead gardener, one place, no normalisation anywhere.
If that assertion ever needs a rescale to pass, the store is broken.

## Tests

`core/worldstate/tests/` — GUT, `extends GutTest`. Run with the gdir below; the
repository default (`-gdir=res://tests/core`) does not include this folder, so
integration must add it.

```powershell
& 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe' `
  --headless --path C:\projects\TINProject `
  --script addons/gut/gut_cmdln.gd -gdir=res://core/worldstate/tests -gexit
```

| File | Covers |
|---|---|
| `test_world_state.gd` | determinism, JSON round trip, absence preserved, refusals changing nothing, unconditional `place` refusal, no normalisation, the three scenes |
| `test_axes.gd` | per-axis validation, capability-only requirements, absence as `null`, memory as events |
| `test_view.gd` | the view's public surface is exactly the frozen list, it holds no store reference, it hands out copies, it travels through `arrival`, the creature axis exposes no aggregate |
| `test_body_classes.gd` | the six rungs, a between-rungs value refused rather than snapped, `1.0` refused on its own reason, absence staying absence, a permanent fact not clearable, a capability changing back, refusals changing nothing, the class of every field, no normalisation of continuous floats |

## Open questions

1. **A fourth axis.** Not added. If a Kit needs a `resource` axis it solves it
   inside that Kit first. Two real use sites must exist before this folder
   grows, per `DESIGN_DECISION.md` §8.
2. **Save migration.** `ax` is version 1 and `load_snapshot` accepts only 1.
   A v2 needs a migration step, and until someone writes one an old save fails
   honestly with `snapshot_version_unsupported` instead of being half-read.
3. **Extending the blacklists.** `DERIVED_KEYS` and `NOT_CAPABILITY_KEYS` are
   closed on purpose. A Kit that needs a synonym added should say which fact it
   is trying to store; the point is that nobody can route around the ban by
   inventing a word.
4. **Stale content ids.** `den`, and any id a Kit puts in `traits` or a
   `memory` event, are resolved by nobody in this folder. Each Kit plan has to
   state its own policy, as `docs/CODE_STYLE.md` 저장 requires.
5. **The `facts` dictionary is open.** It is where a Kit records an observed
   number in its own scale. Two use sites confirmed it, which is the bar in
   `docs/CODE_STYLE.md` 경계. If a third field of the same kind appears, that is
   the moment to name it. It is `unclassified` on purpose, which leaves one hole:
   `{"facts": {"scale": 0.13}}` would be accepted and would be a second,
   unladdered size channel. Whether the store refuses that or a Kit plan forbids it
   is W0's, and it is recorded in `DESIGN_DECISION.md` §8.
6. **Who calls `focus_place`.** The store owns the cursor and the app moves it
   when a module change or a scripted scene demands it. If a Kit later needs to
   move it, that is a contract change and it goes to W0, not into a Kit.
7. **`AXIS_VERSION` versus per-Kit save versions.** The envelope carries one
   `ax`. `DESIGN_DECISION.md` §7 also says each Kit keeps its own version; the
   reconciliation is the app layer's, over the three Kits' own save records.
   Nothing here stores a Kit's version, because core does not know Kit ids.
8. **Who refuses a scale that is off the ladder.** This folder refuses it, in
   `AxisBody.apply`, so it refuses on save and on restore too.
   `docs/scale_collapse/01_SCALE_ALGEBRA.md` §2.2 and §4 K6 say the opposite —
   that the store keeps `0.13` and keeps `1.0` as they were written, and §7 says
   that document needs nothing from this folder. The rung table is the same in
   both; only the place of the verdict differs. W0 decides, and until then the
   store's verdict is the one implemented here. The consequence is that the scale
   fixtures in the three pre-existing test files are now refused, so those files
   are red until the ladder or the fixtures are changed by whoever owns that
   call. Nothing in this folder was weakened to hide it.
