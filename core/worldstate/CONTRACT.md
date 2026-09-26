# Frozen public API — `core/worldstate`

Owner **W7**. Signatures below are frozen. Change only with W0 approval.
The design this implements is `DESIGN_DECISION.md`; where a plan document and
this file disagree, **this file is the authority**. A Kit plan that needs a
different signature must quote this file by name in its plan and request the
change, not edit the plan around it.

Every result dictionary has the same three keys. `ok` is the verdict, `reason`
is a `StringName` from the vocabulary below, `detail` is a human sentence and is
never required to be stable. Some calls add `value`, some add `satisfied` /
`unmet`. There is no call that returns a bare boolean.

```gdscript
# ── WorldState (world_state.gd) — the single owner, all RefCounted ─────────
const STORE_VERSION: int = 1
const AXIS_BODY: StringName = &"body"
const AXIS_CREATURE: StringName = &"creature"
const AXIS_PLACE: StringName = &"place"
const AXES: Array[StringName]                      # exactly three, never four
const WRITABLE_AXES: Array[StringName]             # body, creature. not place.
const ARRIVAL_KEY: StringName = &"world_state_view"   # key inside ModuleContext.arrival
func declare_owner(axis: StringName, requester_id: StringName) -> Dictionary
func get_owner(axis: StringName) -> String
func request_mutation(axis: StringName, patch: Variant, requester: StringName) -> Dictionary
func body_satisfies(place_id: String) -> Dictionary
func focus_place(place_id: String) -> Dictionary           # store cursor, not an axis write
func get_focus_place_id() -> String
func issue_view() -> WorldStateView
func make_arrival() -> Dictionary                          # {ARRIVAL_KEY: view}
func to_dictionary() -> Dictionary                         # versioned, JSON-safe
func to_json() -> String
func load_snapshot(data: Variant) -> Dictionary            # atomic, honest failure
func load_json(text: String) -> Dictionary

# request_mutation verdict order is fixed, so a refusal is reproducible:
#   1 axis_unknown              axis is not body/creature/place
#   2 axis_read_only            axis == place. unconditional, checked before anything else
#   3 axis_owner_undeclared     no owner declared for this axis yet
#   4 requester_not_owner       requester id != declared owner id
#   5 patch_not_dictionary      patch is not a Dictionary
#   6 patch_empty               patch has no keys
#   7 axis rule                 key_unknown / derived_value_forbidden / value_* / wound_malformed /
#                               scale_rung_forbidden / scale_not_rung / body_fact_is_permanent /
#                               creature_id_invalid / creature_archetype_fixed / creature_unknown /
#                               memory_is_event_list / memory_entry_empty
# Within a body patch the order inside step 7 is fixed per key, so a refusal is
# reproducible: derived_value_forbidden, then key_unknown, then the field's own value
# rule, then — for a permanent-fact field only — body_fact_is_permanent. The value
# rule is checked before the permanence rule, so a patch that is wrong in both ways
# names the value first.
# A patch is a per-field assignment, not a merge. A field the patch does not
# mention is left exactly as it was, including its absence.

# ── AxisBody (axis_body.gd) — observable facts only ──────────────────────
const FIELD_MISSING: StringName = &"missing"      # Array[String]
const FIELD_WOUNDS: StringName = &"wounds"        # Array[Dictionary]
const FIELD_SCALE: StringName = &"scale"          # number, one rung of SCALE_RUNGS
const FIELD_FACTS: StringName = &"facts"          # Dictionary, open
const FIELDS: Array[StringName]                   # missing, wounds, scale, facts
const WOUND_FIELDS: Array[StringName]             # part, kind, severity, permanent (exact)
const REQ_SCALE_MIN: StringName = &"scale_min"
const REQ_SCALE_MAX: StringName = &"scale_max"
const REQ_HAS_ALL_PARTS: StringName = &"has_all_parts"
const REQ_HAS_WOUND: StringName = &"has_wound"
const REQ_HAS_NO_WOUND: StringName = &"has_no_wound"
const REQUIREMENT_KEYS: Array[StringName]
const NOT_CAPABILITY_KEYS: Array[StringName]      # permission-flavoured names, refused
const THRESHOLD_SUFFIXES: Array[String]           # _min/_max/… stripped before the same check
const DERIVED_KEYS: Array[StringName]             # summary names, refused everywhere
func has_field(key: StringName) -> bool
func has_scale() -> bool
func get_scale() -> Variant                       # null when absent
func get_missing() -> Variant                     # null when absent, else a copy
func get_wounds() -> Variant                      # null when absent, else a copy
func get_facts() -> Variant                       # null when absent, else a copy
func has_fact(key: StringName) -> bool
func get_fact(key: StringName) -> Variant
func has_missing_part(part: String) -> bool
func has_wound(part: String, kind: String, permanent: Variant = null) -> bool
func field_class(key: StringName) -> Dictionary
func satisfies(requirement: Variant) -> Dictionary
static func validate_requirement(requirement: Variant) -> Dictionary
static func is_json_safe(value: Variant, depth: int = 0) -> bool
func check_mutation(patch: Variant) -> Dictionary   # same verdict as apply, commits nothing
func apply(patch: Variant) -> Dictionary           # validates, then commits, or changes nothing
func copy() -> AxisBody
func to_dictionary() -> Dictionary

# ── two classes of body field (added 2026-09-26, additive) ───────────────
# A body field is exactly one of these, and the table is closed:
const CLASS_PERMANENT_FACT: StringName = &"permanent_fact"        # progression. never cleared
const CLASS_MUTABLE_CAPABILITY: StringName = &"mutable_capability" # capability. reversible
const CLASS_UNCLASSED: StringName = &"unclassified"               # facts. not the store's to judge
const FIELD_CLASSES: Dictionary  # String key -> one of the three. missing/wounds = permanent_fact,
                                 # scale = mutable_capability, facts = unclassified
const SCALE_RUNGS: Array[float]  # 0.05, 0.12, 0.28, 0.65, 1.5, 3.6. closed, six, no rung name
const SCALE_RUNG_FORBIDDEN: Array[float]  # 1.0. the ladder has no normal size
func field_class(key: StringName) -> Dictionary
#   -> { ok, reason, detail, value }. value is the class StringName for a field of
#      this axis. A key that is not a body field is refused with key_unknown and
#      carries no value, so "I do not know" is never returned as a class.

# `scale` is a rung or it is refused. There is no coercion in either direction:
#   scale_not_rung        a finite number that is not one of the six. Not snapped to
#                         the nearest, not clamped, not rounded. Nothing is stored.
#   scale_rung_forbidden  1.0, as a float or an int. Its own reason, because "there is
#                         no normal size here" is a different statement from "that is
#                         not on the ladder".
# The ban is on the top-level body `scale` field only. A wound `severity` of 1.0, a
# `missing` entry, a number inside `facts`, and a `requires_body` threshold of 1.0 are
# four different questions and none of them is this one. The same rule applies on
# restore: a snapshot whose body scale is off the ladder fails with the same reason and
# overwrites nothing.
#
# A permanent fact is append-only in the sense that nothing already recorded may stop
# being recorded. Clearing it, or replacing the field with a list that no longer holds
# a recorded entry, is refused with body_fact_is_permanent. Recording a fact is still
# accepted, and a field that holds no recorded fact may be written empty — absence and
# emptiness stay different facts. A wound's identity is part + kind; severity and
# permanent are attributes of a re-measurable fact, so re-measuring one is not a new
# fact and is not refused.
#
# `check_mutation(patch)` runs the whole verdict and commits nothing, and returns the
# same `reason` `apply` would return for the same patch. It never carries `value`, so
# there is nothing to commit by accident. `apply` is unchanged in behaviour: it stages a
# copy, validates, and either swaps it in or drops it.
#
# Reversibility does not weaken absence. A body with no scale has no scale: `has_scale`
# is false, `get_scale` is null, no key appears in `to_dictionary`, and a place that
# asks for one is unmet with "scale_absent". No rung is a default and none is guessed.

# Every get_* returns null for an absent field. Use has_field / has_scale /
# has_fact to tell "absent" from "nothing there". This is the whole of the
# no-invented-default rule, and it is why satisfies() exists: absence becomes a
# named unmet requirement instead of a fabricated 0 or 1.
# unmet strings: "scale_absent" "scale_below_min" "scale_above_max"
#                "part_missing:<part>" "wounds_absent" "wound_missing" "wound_present"

# ── AxisCreature (axis_creature.gd) — an individual, never a score ────────
const FIELD_ID: StringName = &"id"                # required, globally unique, never rewritten
const FIELD_ARCHETYPE: StringName = &"archetype"  # set by the creator, fixed at birth
const FIELD_STAGE: StringName = &"stage"          # int
const FIELD_STATE: StringName = &"state"          # authored value
const FIELD_TRAITS: StringName = &"traits"        # Dictionary
const FIELD_MEMORY: StringName = &"memory"        # Array[Dictionary] of events
const FIELD_DEN: StringName = &"den"              # place id, opaque to the store
const FIELDS: Array[StringName]
func get_id() -> String
func get_archetype() -> Variant
func get_stage() -> Variant
func get_state() -> Variant
func get_traits() -> Variant
func get_memory() -> Variant
func get_den() -> Variant
func remembers(match: Dictionary) -> bool         # subset test, never a count
func apply(data: Variant) -> Dictionary           # requires id; also the patch path
func copy() -> AxisCreature
func to_dictionary() -> Dictionary

# memory holds what happened, not how much. There is no method here that sums,
# counts, totals or scores it, and a test asserts that over the method list.
# Appending is the kit's job: send the whole list back.
#   patch["memory"] = (creature.get_memory() as Array) + [{"kind": "withered"}]
# `den` is an authored id. The store does not resolve it. Stale content id
# policy belongs to the Kit plan, per docs/CODE_STYLE.md 저장.

# ── AxisPlace (axis_place.gd) — authored, immutable at runtime ────────────
const FIELD_REGION_ID: StringName = &"region_id"
const FIELD_TAGS: StringName = &"tags"
const FIELD_REQUIRES_BODY: StringName = &"requires_body"
const FIELDS: Array[StringName]
static func create(p_id: String, data: Variant) -> Dictionary     # authoring/load only, -> value
func get_id() -> String
func get_region_id() -> String
func get_tags() -> Array[String]
func has_tag(tag: String) -> bool
func get_requires_body() -> Dictionary
func requires_nothing() -> bool
func copy() -> AxisPlace
func to_dictionary() -> Dictionary

# There is no mutating method on this class and none will be added. create() is
# the authoring and restore path. A place record has no "absent" state because
# it is authored content, not an observed fact: id, region_id, tags and
# requires_body are always present. requires_body takes capability keys only.
# A permission-flavoured key is refused with requires_body_not_capability.

# ── WorldStateView (world_state_view.gd) — what a module actually gets ────
static func from_arrival(arrival: Dictionary) -> WorldStateView     # null when absent
func get_store_version() -> int
func has_body() -> bool
func get_body() -> AxisBody                                          # null when absent
func get_creature_ids() -> Array[String]
func has_creature(id: String) -> bool
func get_creature(id: String) -> AxisCreature                        # null when absent
func get_place_ids() -> Array[String]
func has_place(id: String) -> bool
func get_place(id: String) -> AxisPlace                              # null when absent
func get_focus_place_id() -> String
func body_satisfies(place_id: String) -> Dictionary
func to_dictionary() -> Dictionary

# That list is the entire public surface of the view. A test compares it against
# the list, so adding a method here is a contract change, not an implementation
# detail. The view holds no reference to WorldState and the store never reads
# from a view, so there is no path back to the origin even by reflection. Every
# get_* builds a fresh instance; mutating what you were handed changes nothing.
```

## Refusal vocabulary

Every refusal names itself. `ok` is the only success value. These are frozen
`StringName` constants on `WorldState`; the axis classes return the same
strings, and a test pins the mapping.

| reason | meaning | the module should |
|---|---|---|
| `ok` | accepted or the check passed | continue |
| `axis_unknown` | the axis is not `body`, `creature` or `place` | fix the call. there is no fourth axis |
| `axis_read_only` | `place` is authored and immutable at runtime | stop. do not retry, do not work around |
| `axis_absent` | the axis has no record yet | handle absence or halt. never substitute a default |
| `axis_owner_undeclared` | nobody has claimed this axis yet | the app must `declare_owner` at boot |
| `owner_already_declared` | this axis is already claimed by a different id, or a snapshot disagrees with the session | a real inconsistency. do not overwrite |
| `requester_not_owner` | only the owning Kit writes this axis | do not retry. this is a design error, not a timing error |
| `place_unknown` | no such place id | fix the id or accept that the scene is absent |
| `patch_not_dictionary` | the patch is not a Dictionary | fix the payload |
| `patch_empty` | the patch has no keys | do not send no-op writes |
| `key_unknown` | the key is not a field of that axis | fix the payload |
| `value_not_json_safe` | Node, Resource, Callable, Vector, NaN, Inf or a non-String key | fix the payload. a save payload holds none of these |
| `value_type_invalid` | the value has the wrong type for that field | fix the payload |
| `value_not_finite` | NaN or Inf | fix the payload |
| `derived_value_forbidden` | a summary field. `health`, `hp`, `health_fraction`, `condition`, `wound_count` … | store the observable fact instead. §2.1 |
| `wound_malformed` | a wound is not exactly `{ part, kind, severity, permanent }` with those types | fix the payload |
| `scale_not_rung` | a finite body scale that is not one of the six rungs | write a rung, or leave the field out. nothing is snapped to the nearest |
| `scale_rung_forbidden` | `1.0` as the top-level body scale, float or int | there is no normal size on this ladder. pick a rung. `1.0` inside a wound, a fact or a threshold is a different matter |
| `body_fact_is_permanent` | the request would un-record a fact that is already in `missing` or `wounds` | add facts, do not remove them. this axis does not come back. a mutable capability is the thing you may change back |
| `requires_body_key_unknown` | the capability key is not one of the five | fix the authored place |
| `requires_body_not_capability` | a permission, reputation, level or price key | use a capability condition. §2.3 |
| `creature_id_invalid` | the patch carries no usable `id` | fix the payload |
| `creature_archetype_fixed` | an individual cannot change species after birth | fix the payload |
| `creature_unknown` | the id names no individual and the patch cannot create one | creation needs `archetype`; otherwise fix the id |
| `memory_is_event_list` | a memory value is not an Array of event Dictionaries | send events, not a number |
| `memory_entry_empty` | an event carries no fact at all | send a real event |
| `snapshot_malformed` | the envelope is not a Dictionary, or a nested record is malformed | honest failure. nothing was overwritten |
| `snapshot_version_unsupported` | `ax` is missing or is not `STORE_VERSION` | honest failure. no migration exists yet |
| `owners_malformed` | the `owners` table names an axis that is not `body` or `creature` | fix the payload |

## Two things this store will not do

1. **It will not normalise.** No value is rescaled, clamped, converted, averaged
   or moved between units. A body whose stored value is 200 and which takes 1
   damage stores 199. A measured `199.7` in `facts` stays 199.7 even in a grammar
   that normally uses 1 to 3. A value that was never written is still not written
   after a save, a load or a hand-over. §4.
2. **It will not compute a summary.** No derived field, no health fraction, no
   death count, no trust number. Derived values belong to the Kit that
   interprets the facts, in that Kit's own grammar, at that Kit's own scale.

A closed set of legal values is not a normalisation. `SCALE_RUNGS` says which
numbers the body scale may hold; it does not move a number that is already there,
does not round one, and does not turn a refused value into a stored rung. The
refusal and the no-normalisation rule are the same rule seen from two sides: the
store does not touch the value.

The one type restoration this store does perform is wire-type restoration, and
it is not §4: JSON has a single number type, and Godot's parser hands every number
back as a `float`. So the store does not rely on that inference. A value is stored
with the type its author wrote, and on a text restore the store reads the int/float
distinction back out of the text itself: a number token the writer emitted without a
decimal point comes back an `int`, one it emitted with one stays a `float`. No value
is ever altered, and the text round trip is stable. If the number tokens in the text
and the numbers in the parsed value do not line up one for one, the restore fails
with `snapshot_malformed` instead of guessing.

## What this store cannot police

- **Unit conversion.** A Kit that writes `{"facts": {"length_cm": 180}}` has
  done a unit choice, not a conversion, and the store cannot tell. The rule
  stands as a Kit obligation.
- **A second scale channel.** `scale` is a rung, and `FIELD_CLASSES` says so, but
  `facts` is open, so `{"facts": {"scale": 0.13}}` would be accepted and would be a
  second, unladdered size channel. The store classifies `facts` as `unclassified`
  and does not police its contents beyond the closed `DERIVED_KEYS` list. Whether a
  Kit may put a second scale there is an open question, recorded in
  `DESIGN_DECISION.md` §8, not a rule this file grants.
- **Stale content ids.** `den` and any id a Kit puts inside `traits` or a
  `memory` event are resolved by nobody here. Policy belongs to the Kit plan.
- **Derived values under a name the store does not know.** `DERIVED_KEYS` and
  `NOT_CAPABILITY_KEYS` are closed lists, deliberately. They can be extended
  with W0 approval; a Kit must not route around them by inventing a synonym.
- **A fourth axis.** If a Kit needs one, it solves it inside the Kit first, per
  `DESIGN_DECISION.md` §8. Two real use sites must exist before this folder
  grows.
