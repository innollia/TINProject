class_name TopDownActionRpgContentLoader
extends RefCounted

const MODULE_ID: String = "top_down_action_rpg"
const CONTENT_DIRECTORY: String = "res://modules/top_down_action_rpg/content"
const INDEX_PATH: String = "res://modules/top_down_action_rpg/content/index.json"
const SCHEMA_VERSION: int = 1
const MAX_JSON_DEPTH: int = 64
const MAX_CONDITION_DEPTH: int = 4
const MAX_CONDITION_NODES: int = 64
const MAX_CONDITION_LEAVES: int = 32
const MAX_TEXT_LENGTH: int = 1200
const MAX_AUDIT_NOTE_LENGTH: int = 400
const MAX_ID_LENGTH: int = 64
const MAX_ART_KEY_LENGTH: int = 48
const MAX_DOCUMENT_LINE_LENGTH: int = 64
const DOCUMENT_PAGE_LINE_CAP: int = 9
const DOCUMENT_MIN_FONT_SIZE: int = 20
const DOCUMENT_MAX_FONT_SIZE: int = 32
const MIN_DAMAGE_BREAK_DAMAGE: int = 0
const TURN_COST_MIN: int = 0
const TURN_COST_MAX: int = 5
const AXIS_MIN: int = -3
const AXIS_MAX: int = 3
const CLOCK_STAGE_COUNT: int = 6
const CLOCK_IRREVERSIBLE_INDEX: int = 4
const CLOCK_TERMINAL_INDEX: int = 5
const DEFERRED_FLOOR_CODE: String = "catalog_floor_deferred"

const OUTCOME_OK: String = "ok"
const OUTCOME_READY_WITH_DEFECTS: String = "ready_with_defects"
const OUTCOME_CONTENT_UNAVAILABLE: String = "content_unavailable"

const SEVERITY_ERROR: String = "error"
const SEVERITY_WARNING: String = "warning"

const HUB_REGION_ROLE: String = "hub_registration_ration_appeal"

const KIND_ORDER: Array[String] = [
	"ledger", "seeds", "effects", "statuses", "actions", "equipment", "items",
	"clocks", "relationships", "recovery", "props", "regions", "npcs",
	"conversations", "documents", "phases", "enemies", "encounters",
]

const GROUP_ID_PREFIX: String = "seed_group_"
const RESERVED_IDS: Array[String] = [
	"seed_ledger", "index", "entry", "content", "none", "null",
]

const CONDITION_LEAVES: Array[String] = [
	"axis_at_least", "clock_at_least", "clock_irreversible", "npc_state_is",
	"npc_present", "relationship_is", "relationship_visited", "route_open",
	"prop_state_is", "region_visited", "region_is", "encounter_cleared",
	"document_read", "document_corrupted_at_least", "choice_taken",
	"choice_not_taken", "conversation_completed", "recovery_done",
	"effect_fired", "world_flag_is", "equipment_held", "item_held",
	"resource_held", "status_present", "recovery_type_done",
	"save_slot_count_at_least",
]

const EFFECT_OPERATIONS: Array[String] = [
	"set_axis", "advance_clock", "set_clock_stage", "npc_state", "relationship",
	"prop_state", "unlock_route", "region_state", "reveal_document",
	"grant_equipment", "consume_equipment", "grant_item", "consume_item",
	"apply_status", "clear_status", "queue_encounter", "queue_recovery", "flag",
]

const NPC_STATE_KEYS: Array[String] = ["presence", "state_key", "region_id", "acting_role"]

const FIELD_RESOURCE_KEYS: Array[String] = [
	"res_empty_category_docket", "res_route_debt_token", "res_lamp_oil",
	"res_care_token", "res_blank_form", "res_power_cell", "res_seed_case",
	"res_safe_water", "res_ash_thread", "res_preservative", "res_medicine",
	"res_seed_vault_sample", "res_latency_token", "res_care_ration",
	"res_sealed_plate", "res_archive_weight", "res_transformation_fuse",
	"res_crown_gear", "res_battery", "res_hand_pump", "res_stretcher",
	"res_ink_credit", "res_entry_token", "res_harvest_residue",
	"res_petition_seal", "res_permit_fragment", "res_clear_channel",
	"res_untranslated_glyph", "res_definition_token", "res_recovered_note",
	"res_consent_charter", "res_surgical_license", "res_identity_token",
	"res_water_manifest", "res_audit_credit", "res_seam_key",
	"res_root_record_fragment", "res_heat_token", "res_cleanup_token",
	"res_medicine_reserve", "res_party_supply", "res_relationship_token",
	"res_ration_packet", "res_concentration_sample", "res_medium_blank",
	"res_fold_sheet", "res_blade_credit", "res_disperser_charge",
	"res_circulation_slot", "res_craft_credit", "res_lineage_token",
	"res_contract_tally", "res_labor_pledge",
]

const DEBT_RESOURCE_KEYS: Array[String] = ["res_labor_pledge", "res_contract_tally"]

const FORBIDDEN_RESOURCE_KEYS: Array[String] = [
	"ap", "action_points", "stamina", "momentum", "sp", "pp", "mana",
	"mana_pool", "concentration", "concentration_field", "body_load",
	"craft", "medium", "blade", "fold_count", "max_ap",
]

const COMBAT_RESOURCE_KEYS: Array[String] = ["hp", "mp", "equipment_charge"]

const STAT_KEYS: Array[String] = [
	"agility", "max_hp", "max_mp", "hit", "evasion", "critical",
	"critical_avoidance", "guard_efficiency", "break_damage",
]

const TARGET_MODES: Array[String] = [
	"SELF", "ONE_ENEMY", "ONE_ALLY", "ALL_ENEMIES", "ALL_ALLIES", "RANDOM_ENEMY",
]
const TARGET_ELIGIBILITY: Array[String] = ["living", "alive_or_fallen", "fallen_ally", "any"]
const TARGET_ROLES: Array[String] = ["record", "route", "resource_node"]
const TARGET_PRIORITY_ROLES: Array[String] = [
	"true_actor", "linked_actor", "support", "decoy", "aggro",
]
const LINKED_ACTOR_ROLES: Array[String] = [
	"guard", "pressure", "true_actor", "support", "decoy", "linked_actor",
]
const EQUIPMENT_SLOTS: Array[String] = ["weapon", "offhand", "armor", "accessory"]
const EQUIPMENT_FLOOR_ROLES: Array[String] = [
	"weapon_basic_attack", "granted_active_skill", "resistance_behavior",
	"action_slot_source", "field_pass_key", "no_turn_item_source",
]
const ITEM_CLASSES: Array[String] = ["consumable", "quest", "key", "material", "pass"]
const REGION_ROLES: Array[String] = [
	"hub_registration_ration_appeal", "recovery_reentry", "resource_allocation",
	"intervention_scheduling", "translation_precedence",
	"permission_before_transformation", "organ_authority_negotiation",
	"boundary_crown_precedence", "magic_training_craft_labor",
]
const REGION_SIZE_CLASSES: Array[String] = ["small", "medium", "large", "sprawling"]
const PRESENCE_VALUES: Array[String] = ["resident", "visiting", "transient", "absent", "pending"]
const CLOCK_REVERSALS: Array[String] = ["none", "slow", "possible", "terminal"]
const CLOCK_START_STATES: Array[String] = ["dormant", "active", "critical"]
const CLOCK_SCOPES: Array[String] = ["region", "global", "character"]
const CLOCK_KINDS: Dictionary = {
	"clock_institutional_response": "institutional_response",
	"clock_contamination": "contamination",
	"clock_public_record": "public_record",
	"clock_resource_collapse": "resource_collapse",
	"clock_personal_collapse": "personal_collapse",
	"clock_crown_alignment": "crown_alignment",
}
const CLOCK_STAGE_TOKENS: Dictionary = {
	"clock_institutional_response": [
		"noticed", "assigned", "contested", "intervened", "filed", "superseded",
	],
	"clock_contamination": [
		"clean", "exposed", "active", "systemic", "irreversible", "collapsed",
	],
	"clock_public_record": [
		"private", "circulating", "contested", "filing", "canonical", "retired",
	],
	"clock_resource_collapse": [
		"buffered", "rationed", "localized", "failing", "collapsed", "externally_mediated",
	],
	"clock_personal_collapse": [
		"role_bound", "divergent", "contested", "intervened", "self_authored", "lost",
	],
	"clock_crown_alignment": [
		"vacant", "contested", "aligned", "intervened", "fixed", "locked",
	],
}
const CLOCK_VISIBLE_CHANNELS: Array[String] = [
	"npc_warning", "document", "resource_shortage", "enemy_tell", "world_event", "prop_change",
]
const RECOVERY_KINDS: Array[String] = [
	"checkpoint", "respawn", "clone", "reincarnation", "loop", "immortality",
	"institutional_reentry",
]
const RETIRED_RECOVERY_TOKENS: Array[String] = [
	"checkpoint_return", "clone_branch", "loop_rehearsal", "immortal_continuation",
	"crown_alignment",
]
const RECOVERY_TRIGGER_KINDS: Array[String] = [
	"death", "encounter_failure", "phase_complete", "route_enter", "scripted",
]
const RECOVERY_COOLDOWN_KINDS: Array[String] = [
	"once", "per_death", "per_route", "per_encounter", "gate",
]
const STATE_PRESERVE_TOKENS: Array[String] = [
	"region_id", "region_state", "axis_values", "clock_stages", "npc_states",
	"relationship_states", "prop_states", "conversation_progress",
	"document_reads", "flags", "effects_fired", "encounter_clear_flags",
	"route_flags", "inventory", "equipment_slots", "recoveries", "player_vitals",
	"concentration_fields", "body_load", "circulation", "crafts", "contracts", "glossary",
]
const STATE_DISCARD_TOKENS: Array[String] = [
	"encounter_progress", "current_phase", "linked_actor_state", "combat_transient",
	"scheduler_cursor", "pending_effect_queue", "presentation_transient",
]
const SELF_LAYERS: Array[String] = [
	"body", "memory", "role", "belief", "institution", "desire", "social_recognition",
]
const RELATIONSHIP_AXES: Array[String] = ["trust", "fear", "debt", "recognition", "attachment"]
const WORLD_AXES: Array[String] = [
	"protocol_legitimacy", "recognition_drift", "continuity_pressure", "resource_scarcity",
]
const RELATIONSHIP_CHANNELS: Array[String] = [
	"professional", "personal", "care", "confrontation", "romance", "kinship",
]
const DIALOGUE_POLICIES: Array[String] = ["guarded", "operational", "candid", "hostile", "absent"]
const TRANSITION_VIA: Array[String] = [
	"choice", "effect", "encounter_outcome", "clock_stage", "recovery", "absence",
]
const PRESENTATION_CLASSES: Array[String] = [
	"neutral", "official", "confidential", "hostile", "extreme", "narration",
	"unavailable", "result",
]
const CHOICE_PRESENTATION_CLASSES: Array[String] = ["neutral", "extreme", "unavailable", "result"]
const DOCUMENT_VERB_PRESENTATION_CLASSES: Array[String] = [
	"neutral", "official", "confidential", "hostile", "extreme", "narration",
]
const IRREVERSIBILITY_CLASSES: Array[String] = ["reversible", "delayed_only", "irreversible"]
const CONVERSATION_REVISITS: Array[String] = [
	"once", "repeatable", "state_dependent", "replayable_after_state_change",
]
const PAGE_SPEAKERS: Array[String] = ["npc", "player", "world"]
const PAGE_ADVANCES: Array[String] = ["auto", "wait"]
const DOCUMENT_REACHED_BY: Array[String] = [
	"prop", "victory_award", "shop", "pickup", "npc_gift", "scripted",
]
const DOCUMENT_PRESENTATIONS: Array[String] = ["plain", "redacted", "corrupted"]
const CORRUPTION_MODES: Array[String] = ["recolor", "replace_token", "shatter_line", "drop_glyph"]
const BACKGROUND_MODES: Array[String] = ["dim_world", "full_dark"]
const ACTION_CATEGORIES: Array[String] = [
	"attack", "skill", "magic", "defend", "item", "escape", "equipment", "unique", "noncombat",
]
const DEFENSE_MODES: Array[String] = ["none", "guard", "dodge", "break_attempt"]
const ACTION_OWNERS: Array[String] = ["player", "enemy", "linked_actor", "npc"]
const LIFECYCLES: Array[String] = ["instant", "charge", "committed"]
const TELEGRAPH_CHANNELS: Array[String] = ["pose", "vfx", "sound", "numeric_bar", "field_prop"]
const DELIVERIES: Array[String] = ["physical", "magical", "true"]
const DAMAGE_SHAPES: Array[String] = ["fixed", "percent_max_hp", "percent_current_hp", "guaranteed"]
const AFFINITIES: Array[String] = ["none", "fire", "ice", "lightning", "light", "darkness"]
const HIT_POLICIES: Array[String] = ["roll", "guaranteed"]
const EVASION_POLICIES: Array[String] = ["roll", "disabled"]
const CRITICAL_POLICIES: Array[String] = ["never", "chance", "always"]
const BREAK_DAMAGE_KINDS: Array[String] = ["hp_damage", "condition_damage"]
const COUNTER_TOKENS: Array[String] = [
	"guard", "dodge", "break", "resource_lock", "status_counter", "scripted_counter",
	"escape", "raw_survive", "noncombat", "phase_advance",
]
const HOOK_KEYS: Array[String] = [
	"on_charge", "on_active", "on_hit", "on_evade", "on_break",
	"on_recovery_end", "on_actor_death",
]
const CRAFT_FAMILIES: Array[String] = ["weave_scroll", "rigid_fold", "void_cut"]
const CONCENTRATION_SOURCES: Array[String] = ["field", "body", "social_permission", "hybrid"]
const MANA_PROFILES: Array[String] = [
	"retention_high_emission_low", "retention_low_emission_high", "retention_balanced",
	"retention_overflow", "blocked_emission", "concentration_reactive",
	"medium_reactive", "sensory_misclassification",
]
const STATUS_STACK_POLICIES: Array[String] = ["none", "refresh", "stack", "max_intensity", "independent"]
const STATUS_DURATION_KINDS: Array[String] = ["turns", "encounter", "region", "permanent"]
const STATUS_TICK_OPS: Array[String] = ["resource_delta", "apply_status"]
const STACK_POLICY_REPEATABLE: Array[String] = ["stack", "max_intensity", "independent"]
const STANCE_STATES: Array[String] = ["normal", "guard", "dodge", "broken", "guard_broken"]
const BREAK_POLICIES: Array[String] = ["enabled", "immune", "resistant"]
const ENEMY_BODY_CLASSES: Array[String] = [
	"humanoid", "cluster", "architectural", "avian", "corpse", "composite", "abstract",
]
const ENEMY_SCALE_CLASSES: Array[String] = ["small", "human", "large", "architectural"]
const STATEFUL_BODIES: Array[String] = ["none", "open_close", "split_merge", "transform"]
const CONDITION_BAR_KINDS: Array[String] = ["hp", "condition_progress", "stability"]
const CONDITION_BAR_ADVANCE_ON: Array[String] = [
	"hp_damage_taken", "hp_damage_dealt", "window_elapsed", "status_applied",
]
const ENCOUNTER_ACTIVATION_KINDS: Array[String] = [
	"field_trigger", "scripted", "quest_add", "npc_conversion", "boss_gate", "remix",
]
const WARNING_CHANNELS: Array[String] = ["none", "vfx", "sound", "npc_warning"]
const ENCOUNTER_DEPTH_BANDS: Array[String] = ["open", "mid", "late", "postgame"]
const TIME_OF_DAY: Array[String] = ["any", "day", "night", "institutional"]
const REPEAT_POLICIES: Array[String] = ["once", "repeatable", "once_per_run", "escalating"]
const RESET_POLICIES: Array[String] = [
	"none", "on_region_leave", "on_death_recovery", "on_recovery_event",
]
const DEATH_POLICIES: Array[String] = ["respawn_checkpoint", "recover_event"]
const SPAWN_POINTS: Array[String] = ["start", "phase_enter"]
const ESCAPE_POLICIES: Array[String] = ["allowed", "blocked", "policy_authored"]
const BREAK_RESPONSE_POLICIES: Array[String] = ["stagger", "hold", "recoil"]
const ACQUISITION_SOURCES: Array[String] = ["victory_award", "shop", "pickup", "npc_gift", "scripted"]
const LINKED_TIMINGS: Array[String] = ["encounter_start", "phase_enter", "hp_step", "periodic"]
const LINKED_OWNER_DEATH: Array[String] = ["die_with", "survive", "flee", "revive_changed"]
const LINKED_ACTOR_DEATH: Array[String] = ["none", "protect_owner", "summon_replacement", "become_true_target"]
const REMOVALS: Array[String] = ["death", "permanent_absence", "temporary", "never"]
const ABSENCE_KINDS: Array[String] = ["permanent", "route", "conditional", "none"]
const ROSTER_KINDS: Array[String] = ["core", "support"]
const REGION_STATE_TAGS: Array[String] = ["as_authored", "as_saved"]
const FIELD_PRESSURES: Array[String] = ["low", "medium", "high", "lethal"]
const SIZE_CLASSES_TOPOLOGY: Array[String] = ["small", "medium", "large", "sprawling"]
const REVEAL_KINDS: Array[String] = ["none", "partial", "full"]
const LINK_KINDS: Array[String] = ["trade", "record", "personnel", "hostility", "faith", "resource"]
const DEBT_RESOLUTION_TOKENS: Array[String] = [
	"open", "full", "staged", "refused", "filed", "voided",
]
const PLACEMENT_LAYERS: Array[String] = [
	"floor", "prop", "overhead", "trace", "wall", "door", "water", "hazard",
]
const VISIBLE_FROM: Array[String] = ["any", "adjacent", "same_room", "interacted"]
const INTERACTABLE_KINDS: Array[String] = [
	"npc", "passage", "pickup", "chest", "corpse", "lever", "terminal", "shop", "key", "hazard",
]
const INTERACTION_ACTIVATIONS: Array[String] = ["confirm", "automatic", "scripted"]
const INTERACTION_REPEAT_POLICIES: Array[String] = ["once", "resettable", "persistent"]
const ENCOUNTER_FIELD_ACTIVATIONS: Array[String] = [
	"CONTACT", "ZONE", "INTERACTION", "STORY_FORCED", "CHASE_THRESHOLD",
]
const LEDGER_SECTIONS: Array[String] = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
]
const LEDGER_USAGE_CLASSES: Array[String] = [
	"ROOT", "SYSTEM", "MODULE", "TONE", "ONEOFF", "CANDIDATE", "DROP",
]
const SEED_STATUSES: Array[String] = ["planned_retained", "used", "rejected"]
const SEED_REJECTION_CLASSES: Array[String] = [
	"filler", "duplicate", "tone-only", "source-copy-risk", "unbound",
]
const SEED_BINDING_KINDS: Array[String] = [
	"ledger", "seed", "effect", "status", "action", "equipment", "item", "clock",
	"relationship", "recovery", "prop", "region", "npc", "conversation", "document",
	"phase", "enemy", "encounter",
]
const SEED_DELAY_TIMINGS: Array[String] = [
	"delayed", "on_clock_stage", "on_encounter_end", "on_recovery", "on_region_enter",
]
const PROVENANCE_KINDS: Array[String] = ["user_memo", "bs2_structural_rule", "kit_design"]
const EFFECT_TIMINGS: Array[String] = [
	"immediate", "delayed", "on_region_enter", "on_encounter_end", "on_recovery",
	"on_clock_stage",
]
const EFFECT_DELAY_KINDS: Array[String] = ["recovery", "encounter", "clock_stage", "region"]
const EFFECT_REPEAT_GUARDS: Array[String] = [
	"once", "per_region_visit", "per_encounter", "never_repeat",
]
const QUANTITY_AT: Array[String] = ["immediate", "next_field_entry", "post_recovery"]
const CANONICAL_GATE_IDS: Array[String] = [
	"gate_g0_arrival_declaration", "gate_g1_ash_debt", "gate_g2_water_recognition",
	"gate_g3_latency_receipt", "gate_g4_translation_precedence", "gate_g5_labor_pledge",
	"gate_g6_organ_quorum", "gate_g7_boundary_witness", "gate_g8_crown_precedence",
]
const CANONICAL_ENDING_IDS: Array[String] = [
	"end_r1_receipt_of_a_life", "end_g1_law_without_master",
	"end_o1_many_mouths_one_person", "end_a1_empty_seat",
	"end_c1_four_anchors", "end_c2_last_witness",
]

const KIND_ALLOWED: Dictionary = {
	"ledger": ["schema_version", "id", "ledger_source", "ledger_version", "denominator", "quota", "diversity", "gate"],
	"seeds": ["schema_version", "records"],
	"effects": ["schema_version", "id", "timing", "delay_ref", "operations", "one_shot", "repeat_guard", "seed_ids", "audit_note"],
	"statuses": ["schema_version", "id", "display_name", "stack_policy", "max_stacks", "duration", "tick", "modifiers", "control", "cure", "resistance", "presentation", "seed_ids", "audit_note"],
	"actions": ["schema_version", "id", "display_name", "order", "owner", "category", "defense_mode", "lifecycle", "intent", "cost", "precondition", "telegraph", "commitment", "damage_payload", "status_payloads", "break_spec", "reactions", "recovery", "counters", "hooks", "craft", "stages", "presentation", "seed_ids", "audit_note"],
	"equipment": ["schema_version", "id", "display_name", "slot", "allow_empty", "floor_role", "stat_modifiers", "resistances", "status_grants", "defense", "action_grants", "behavior_modifiers", "charge_pool", "field_keys", "service", "acquisition", "presentation", "seed_ids", "audit_note"],
	"items": ["schema_version", "id", "display_name", "item_class", "floor_role", "use", "field_use", "acquisition", "presentation", "seed_ids", "audit_note"],
	"clocks": ["schema_version", "id", "kind", "scope", "owner_region_id", "owner_npc_id", "start_condition", "start_state", "period", "stages", "pressure_policy", "never_advances", "seed_ids", "audit_note"],
	"relationships": ["schema_version", "id", "target_npc_id", "channel", "start_state_id", "states", "transitions", "axes", "axis_rules", "exclusions", "romance", "seed_ids", "audit_note"],
	"recovery": ["schema_version", "id", "display_name", "kind", "trigger", "preserves", "discards", "self_layers_restored", "self_layers_not_restored", "respawn", "cost", "entry_effect_ids", "cooldown", "authored_debt", "seed_ids", "audit_note"],
	"props": ["schema_version", "id", "display_name", "region_id", "placement", "initial_state_id", "states", "interaction", "revisit_visible", "hidden_until_condition", "seed_ids", "audit_note"],
	"regions": ["schema_version", "id", "display_name", "region_role", "conflict_thesis", "topology", "entry", "exits", "authority", "dominant_protocol", "resource_flow", "residents", "clocks", "concentration", "hidden_state", "initial_state", "combat_content", "noncombat_content", "initial_cluster", "revisit_variants", "internal_routes", "unresolved_debt", "cross_region_links", "oneoff_dialogue_seed_ids", "axis_weights", "seed_ids", "audit_note"],
	"npcs": ["schema_version", "id", "display_name", "roster_kind", "public_role", "private_role", "desire", "fear", "contradiction", "capability", "resource_access", "knowledge_boundary", "speech_pressure", "interaction_verbs", "relationship_ids", "clock_ids", "encounter_profile", "survival", "absence", "appearance", "mana_profile", "oneoff_dialogue_seed_ids", "cross_link_ids", "removal", "seed_ids", "audit_note"],
	"conversations": ["schema_version", "id", "display_name", "region_id", "speaker_npc_id", "entry_condition", "priority", "pages", "choices", "on_complete", "on_abort", "revisit", "alt_conversation_ids", "seed_ids", "audit_note"],
	"documents": ["schema_version", "id", "display_name", "owner_npc_id", "region_id", "availability", "reached_by_ref", "pages", "reading", "post_read", "revisit", "seed_ids", "audit_note"],
	"phases": ["schema_version", "id", "display_name", "owner_enemy_id", "index", "trigger", "enter", "overrides", "roster", "completion", "next_phase_id", "seed_ids", "audit_note"],
	"enemies": ["schema_version", "id", "display_name", "role", "body", "stats", "condition_bar", "baseline_action_ids", "signature_action_id", "telegraph", "status_profile", "break_profile", "phase_ids", "linked_actors", "reward", "aftermath", "lore_ref", "seed_ids", "audit_note"],
	"encounters": ["schema_version", "id", "display_name", "context", "activation", "visibility", "roster", "target_priority", "target_roles", "group", "allow", "clock_pressure", "outcome", "world_effect", "repeat", "base_encounter_id", "variant_overrides", "remix_eligibility", "lore_ref", "seed_ids", "audit_note"],
}

const KIND_REQUIRED: Dictionary = {
	"ledger": ["schema_version", "id", "ledger_source", "ledger_version", "denominator", "quota", "diversity", "gate"],
	"seeds": ["schema_version", "records"],
	"effects": ["schema_version", "id", "timing", "operations", "repeat_guard"],
	"statuses": ["schema_version", "id", "display_name", "stack_policy", "max_stacks", "duration", "modifiers", "control", "cure", "resistance", "presentation"],
	"actions": ["schema_version", "id", "display_name", "order", "owner", "category", "defense_mode", "lifecycle", "intent", "cost", "telegraph", "counters"],
	"equipment": ["schema_version", "id", "display_name", "slot", "allow_empty", "floor_role", "stat_modifiers", "defense", "action_grants", "acquisition", "presentation"],
	"items": ["schema_version", "id", "display_name", "item_class", "use", "acquisition", "presentation"],
	"clocks": ["schema_version", "id", "kind", "scope", "start_state", "period", "stages", "pressure_policy"],
	"relationships": ["schema_version", "id", "target_npc_id", "channel", "start_state_id", "states", "transitions", "axes", "exclusions", "romance"],
	"recovery": ["schema_version", "id", "display_name", "kind", "trigger", "preserves", "discards", "self_layers_restored", "self_layers_not_restored", "respawn", "cost", "cooldown"],
	"props": ["schema_version", "id", "display_name", "region_id", "placement", "initial_state_id", "states", "revisit_visible"],
	"regions": ["schema_version", "id", "display_name", "region_role", "conflict_thesis", "topology", "entry", "exits", "authority", "dominant_protocol", "resource_flow", "clocks", "initial_state", "combat_content", "noncombat_content", "initial_cluster", "revisit_variants", "internal_routes", "unresolved_debt", "cross_region_links", "axis_weights"],
	"npcs": ["schema_version", "id", "display_name", "roster_kind", "public_role", "private_role", "desire", "fear", "contradiction", "capability", "relationship_ids", "clock_ids", "encounter_profile", "survival", "absence", "cross_link_ids", "removal"],
	"conversations": ["schema_version", "id", "display_name", "region_id", "priority", "revisit"],
	"documents": ["schema_version", "id", "display_name", "region_id", "availability", "pages", "reading", "revisit"],
	"phases": ["schema_version", "id", "display_name", "owner_enemy_id", "index", "trigger", "enter", "overrides", "roster", "completion"],
	"enemies": ["schema_version", "id", "display_name", "role", "body", "stats", "baseline_action_ids", "telegraph", "status_profile", "break_profile", "aftermath"],
	"encounters": ["schema_version", "id", "display_name", "context", "activation", "visibility", "roster", "allow", "outcome", "world_effect", "repeat", "remix_eligibility"],
}

const INDEX_KEYS: Array[String] = [
	"schema_version", "module_id", "entry_region_id", "kinds", "registered_slots", "options",
]
const INDEX_FILE_KEYS: Array[String] = ["id", "path"]
const INDEX_OPTION_KEYS: Array[String] = [
	"world_flag_prefix", "max_world_flags", "closure_record_cap", "save_payload_bytes_cap",
	"history_list_cap", "document_page_line_cap", "max_equipment_definitions", "max_item_definitions",
]
const INDEX_OPTION_EXPECTED: Dictionary = {
	"world_flag_prefix": "world_",
	"document_page_line_cap": DOCUMENT_PAGE_LINE_CAP,
}
const DEFERRED_FLOORS: Array[String] = [
	"region_not_canonical_9",
	"cluster_catalog_incomplete",
	"encounter_catalog_incomplete",
	"enemy_family_catalog_incomplete",
	"magic_status_missing",
	"equipment_floor_role_missing",
	"mana_profile_diversity_insufficient",
	"ledger_denominator_completeness",
	"magic_resource_not_in_region_flow",
	"core_roster_fourteen",
	"action_owner_enclosure",
	"relationship_state_machine_completeness",
]


class Diagnostic:
	extends RefCounted

	var code: String = ""
	var severity: String = "warning"
	var path: String = ""
	var detail: String = ""

	func _init(d_code: String, d_severity: String, d_path: String, d_detail: String) -> void:
		code = d_code
		severity = d_severity
		path = d_path
		detail = d_detail

	func is_error() -> bool:
		return severity == "error"

	func to_dict() -> Dictionary:
		return {"code": code, "severity": severity, "path": path, "detail": detail}

	func to_line() -> String:
		return severity + " " + code + " @ " + path + ("" if detail.is_empty() else " :: " + detail)


class Catalog:
	extends RefCounted

	var kind_records: Dictionary = {}
	var by_id: Dictionary = {}
	var id_kind: Dictionary = {}
	var kind_prefix: Dictionary = {}
	var content_signature: String = ""
	var entry_region_id: String = ""
	var options: Dictionary = {}
	var file_count: int = 0

	func kind(kind_name: String) -> Array:
		return kind_records.get(kind_name, [])

	func count_of_kind(kind_name: String) -> int:
		return kind(kind_name).size()

	func has(record_id: String) -> bool:
		return by_id.has(record_id)

	func record(record_id: String) -> Dictionary:
		var entry: Variant = by_id.get(record_id, {})
		return entry if entry is Dictionary else {}

	func kind_of(record_id: String) -> String:
		return String(id_kind.get(record_id, ""))

	func ids_of_kind(kind_name: String) -> Array:
		var result: Array = []
		for record_id: Variant in by_id:
			if String(id_kind.get(record_id, "")) == kind_name:
				result.append(String(record_id))
		result.sort()
		return result

	func ids_with_prefix(prefix: String) -> Array:
		var result: Array = []
		for record_id: Variant in by_id:
			if String(record_id).begins_with(prefix):
				result.append(String(record_id))
		result.sort()
		return result

	func to_dict() -> Dictionary:
		return {
			"entry_region_id": entry_region_id,
			"content_signature": content_signature,
			"file_count": file_count,
			"counts": _counts(),
		}

	func _counts() -> Dictionary:
		var counts: Dictionary = {}
		for kind_name: String in KIND_ORDER:
			counts[kind_name] = count_of_kind(kind_name)
		return counts


class CatalogResult:
	extends RefCounted

	var catalog: Catalog
	var diagnostics: Array = []
	var outcome: String = OUTCOME_OK

	func _init(p_catalog: Catalog, p_diagnostics: Array, p_outcome: String) -> void:
		catalog = p_catalog
		diagnostics = p_diagnostics
		outcome = p_outcome

	func has_error() -> bool:
		for entry: Diagnostic in diagnostics:
			if entry.is_error():
				return true
		return false

	func errors() -> Array:
		var result: Array = []
		for entry: Diagnostic in diagnostics:
			if entry.is_error():
				result.append(entry)
		return result

	func warnings() -> Array:
		var result: Array = []
		for entry: Diagnostic in diagnostics:
			if not entry.is_error():
				result.append(entry)
		return result

	func is_playable() -> bool:
		return outcome != OUTCOME_CONTENT_UNAVAILABLE

	func error_codes() -> Array:
		var result: Array = []
		for entry: Diagnostic in diagnostics:
			if entry.is_error():
				result.append(entry.code)
		return result

	func report() -> Array:
		var lines: Array = []
		for entry: Diagnostic in diagnostics:
			lines.append(entry.to_line())
		return lines

	func to_dict() -> Dictionary:
		return {
			"outcome": outcome,
			"catalog": catalog.to_dict() if catalog != null else {},
			"diagnostics": _diagnostic_payloads(),
		}

	func _diagnostic_payloads() -> Array:
		var result: Array = []
		for entry: Diagnostic in diagnostics:
			result.append(entry.to_dict())
		return result


class _Session:
	extends RefCounted

	var result: CatalogResult
	var catalog: Catalog
	var index_options: Dictionary = {}
	var edge_owner: Dictionary = {}
	var gate_pairs: Dictionary = {}
	var cluster_ids: Dictionary = {}
	var group_ids: Dictionary = {}
	var world_flags: Dictionary = {}
	var clock_ids: Dictionary = {}

	func _init() -> void:
		catalog = Catalog.new()
		result = CatalogResult.new(catalog, [], OUTCOME_OK)


static func load_default() -> CatalogResult:
	return load_content(CONTENT_DIRECTORY, INDEX_PATH)


static func load_content(directory: String, index_path: String) -> CatalogResult:
	var session := _Session.new()
	var index_document: Variant = parse_json_document(_read_text(index_path))
	if not _validate_index(index_document, index_path, session):
		_emit(session, "index_unreadable", SEVERITY_ERROR, index_path, "index_unreadable")
		_finalize(session, true)
		return session.result
	var plan: Array = _index_plan(index_document)
	for file_entry: Dictionary in plan:
		var kind_name: String = String(file_entry["kind"])
		var declared_id: String = String(file_entry["id"])
		var relative_path: String = String(file_entry["path"])
		var full_path: String = directory.path_join(relative_path)
		if not _is_content_path(relative_path):
			_emit(session, "index_path_invalid", SEVERITY_ERROR, relative_path, "index_path_invalid")
			continue
		var document: Variant = parse_json_document(_read_text(full_path))
		if document == null:
			_emit(session, "file_unreadable", SEVERITY_ERROR, relative_path, "file_unreadable")
			continue
		var records: Array = []
		if bool(file_entry["array"]):
			if not document is Dictionary or not document.get("records") is Array:
				_emit(session, "invalid_schema", SEVERITY_ERROR, relative_path, "invalid_schema")
				continue
			records = _seed_records_of(document, relative_path, session)
		else:
			if not document is Dictionary:
				_emit(session, "invalid_schema", SEVERITY_ERROR, relative_path, "invalid_schema")
				continue
			records = [document]
		_catalog_records(session, kind_name, declared_id, relative_path, records)
		catalog_file_counted(session)
	_resolve_references(session)
	_check_edge_closure(session)
	_emit_deferred_floors(session)
	_finalize(session, not session.result.has_error())
	return session.result


static func _seed_records_of(document: Dictionary, relative_path: String, session: _Session) -> Array:
	var records: Array = []
	var seen: Dictionary = {}
	for entry: Variant in document["records"]:
		if not entry is Dictionary:
			_emit(session, "invalid_schema", SEVERITY_ERROR, relative_path, "invalid_schema")
			continue
		var record_id: String = String(entry.get("id", ""))
		if seen.has(record_id):
			_emit(session, "duplicate_id", SEVERITY_ERROR, relative_path, record_id)
			continue
		seen[record_id] = true
		records.append(entry)
	return records


static func _catalog_records(session: _Session, kind_name: String, declared_id: String, relative_path: String, records: Array) -> void:
	var prefix: String = String(session.catalog.kind_prefix.get(kind_name, ""))
	for entry: Dictionary in records:
		var record_id: String = String(entry.get("id", ""))
		if not _check_record_shell(session, kind_name, prefix, record_id, relative_path, entry):
			continue
		if session.catalog.by_id.has(record_id):
			_emit(session, "duplicate_id", SEVERITY_ERROR, relative_path, record_id)
			continue
		_validate_record(session, kind_name, record_id, relative_path, entry)
		session.catalog.by_id[record_id] = entry
		session.catalog.id_kind[record_id] = kind_name
		if not session.catalog.kind_records.has(kind_name):
			session.catalog.kind_records[kind_name] = []
		session.catalog.kind_records[kind_name].append(record_id)
	if not _is_array_kind(kind_name) and records.size() == 1:
		var record_id: String = String(records[0].get("id", ""))
		if record_id != declared_id:
			_emit(session, "id_prefix_mismatch", SEVERITY_ERROR, relative_path, "id_prefix_mismatch")


static func _is_array_kind(kind_name: String) -> bool:
	return kind_name == "seeds"


static func _validate_index(document: Variant, index_path: String, session: _Session) -> bool:
	if not document is Dictionary:
		return false
	if not _has_only_keys(document, INDEX_KEYS) or not _has_all_keys(document, INDEX_KEYS):
		_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
		return false
	if not _is_integer(document["schema_version"]) or int(document["schema_version"]) != SCHEMA_VERSION:
		_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
		return false
	if document.has("version"):
		_emit(session, "schema_mixed_version", SEVERITY_ERROR, index_path, "schema_mixed_version")
		return false
	if String(document.get("module_id", "")) != MODULE_ID:
		_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
		return false
	var entry_region_id: String = String(document.get("entry_region_id", ""))
	if not is_stable_id(entry_region_id) or not entry_region_id.begins_with(_prefix_of("regions")):
		_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
		return false
	if not document.get("registered_slots") is Array or not (document["registered_slots"] as Array).is_empty():
		_emit(session, "slot_unexpected", SEVERITY_ERROR, index_path, "slot_unexpected")
		return false
	if not _validate_index_options(document.get("options"), index_path, session):
		return false
	if not _validate_index_kinds(document.get("kinds"), index_path, session):
		return false
	session.catalog.entry_region_id = entry_region_id
	session.index_options = document["options"]
	return true


static func _validate_index_options(options: Variant, index_path: String, session: _Session) -> bool:
	if not options is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
		return false
	if not _has_all_keys(options, INDEX_OPTION_KEYS) or not _has_only_keys(options, INDEX_OPTION_KEYS):
		_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
		return false
	for key: String in INDEX_OPTION_EXPECTED:
		if options[key] != INDEX_OPTION_EXPECTED[key]:
			_emit(session, "document_cap_not_nine" if key == "document_page_line_cap" else "invalid_schema",
				SEVERITY_ERROR, index_path + "#" + key, "invalid_schema")
			return false
	for key: String in ["max_world_flags", "closure_record_cap", "save_payload_bytes_cap", "history_list_cap", "max_equipment_definitions", "max_item_definitions"]:
		if not _is_integer(options[key]) or int(options[key]) < 0:
			_emit(session, "number_out_of_range", SEVERITY_ERROR, index_path + "#" + key, "number_out_of_range")
			return false
	return true


static func _validate_index_kinds(kinds: Variant, index_path: String, session: _Session) -> bool:
	if not kinds is Array:
		_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
		return false
	var declared: Dictionary = {}
	var seen_ids: Dictionary = {}
	var seen_paths: Dictionary = {}
	for entry: Variant in kinds:
		if not entry is Dictionary or not _has_only_keys(entry, ["kind", "prefix", "array", "files"]) \
			or not _has_all_keys(entry, ["kind", "prefix", "array", "files"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
			return false
		var kind_name: String = String(entry["kind"])
		if not KIND_ORDER.has(kind_name):
			_emit(session, "unknown_kind", SEVERITY_ERROR, index_path, kind_name)
			return false
		if declared.has(kind_name):
			_emit(session, "index_kind_duplicate", SEVERITY_ERROR, index_path, kind_name)
			return false
		if String(entry["prefix"]) != _prefix_of(kind_name):
			_emit(session, "id_prefix_mismatch", SEVERITY_ERROR, index_path, "id_prefix_mismatch")
			return false
		if not entry["files"] is Array:
			_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
			return false
		declared[kind_name] = true
		session.catalog.kind_prefix[kind_name] = String(entry["prefix"])
		for file_entry: Variant in entry["files"]:
			if not file_entry is Dictionary or not _has_only_keys(file_entry, INDEX_FILE_KEYS) \
				or not _has_all_keys(file_entry, INDEX_FILE_KEYS):
				_emit(session, "invalid_schema", SEVERITY_ERROR, index_path, "invalid_schema")
				return false
			var file_id: String = String(file_entry["id"])
			var file_path: String = String(file_entry["path"])
			if not is_stable_id(file_id) or seen_ids.has(file_id):
				_emit(session, "index_duplicate_file_entry", SEVERITY_ERROR, index_path, file_id)
				return false
			if not _is_content_path(file_path) or seen_paths.has(file_path):
				_emit(session, "index_duplicate_file_entry", SEVERITY_ERROR, index_path, file_path)
				return false
			if not bool(entry["array"]) and file_id != file_path.get_file().get_basename():
				_emit(session, "id_filename_mismatch", SEVERITY_WARNING, file_path, "id_filename_mismatch")
			seen_ids[file_id] = true
			seen_paths[file_path] = true
	for kind_name: String in KIND_ORDER:
		if not declared.has(kind_name):
			_emit(session, "index_kind_missing", SEVERITY_ERROR, index_path, kind_name)
			return false
	return true


static func _index_plan(index_document: Dictionary) -> Array:
	var plan: Array = []
	for entry: Dictionary in index_document["kinds"]:
		var kind_name: String = String(entry["kind"])
		var is_array: bool = bool(entry["array"])
		for file_entry: Dictionary in entry["files"]:
			plan.append({"kind": kind_name, "id": String(file_entry["id"]), "path": String(file_entry["path"]), "array": is_array})
	return plan


static func _prefix_of(kind_name: String) -> String:
	match kind_name:
		"ledger": return "seed_"
		"seeds": return "seed_s"
		"effects": return "eff_"
		"statuses": return "st_"
		"actions": return "act_"
		"equipment": return "equipment_"
		"items": return "item_"
		"clocks": return "clock_"
		"relationships": return "rel_"
		"recovery": return "rec_"
		"props": return "prop_"
		"regions": return "region_"
		"npcs": return "npc_"
		"conversations": return "conv_"
		"documents": return "doc_"
		"phases": return "phase_"
		"enemies": return "enemy_"
		"encounters": return "enc_"
	return ""


static func is_stable_id(value: Variant) -> bool:
	if not value is String:
		return false
	var text: String = value
	if text.length() < 3 or text.length() > MAX_ID_LENGTH:
		return false
	var first: int = text.unicode_at(0)
	if first < 97 or first > 122:
		return false
	for index: int in range(1, text.length()):
		var codepoint: int = text.unicode_at(index)
		if not ((codepoint >= 97 and codepoint <= 122) \
			or (codepoint >= 48 and codepoint <= 57) or codepoint == 95):
			return false
	return true


static func is_snake_token(value: Variant, minimum: int = 3, maximum: int = 32) -> bool:
	if not value is String:
		return false
	var text: String = value
	if text.length() < minimum or text.length() > maximum:
		return false
	var first: int = text.unicode_at(0)
	if first < 97 or first > 122:
		return false
	for index: int in range(1, text.length()):
		var codepoint: int = text.unicode_at(index)
		if not ((codepoint >= 97 and codepoint <= 122) \
			or (codepoint >= 48 and codepoint <= 57) or codepoint == 95):
			return false
	return true


static func _is_content_path(value: String) -> bool:
	if value.is_empty() or value.begins_with("/") or value.contains("\\") \
		or value.contains(":") or value.contains("~") or not value.ends_with(".json"):
		return false
	for segment: String in value.split("/"):
		if segment.is_empty() or segment == "." or segment == "..":
			return false
	return true


static func _check_record_shell(session: _Session, kind_name: String, prefix: String, record_id: String, record_path: String, record: Dictionary) -> bool:
	if not _is_integer(record.get("schema_version")) or int(record.get("schema_version", -1)) != SCHEMA_VERSION:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " schema_version")
		return false
	if not is_stable_id(record_id):
		_emit(session, "id_malformed", SEVERITY_ERROR, record_path, String(record.get("id", "")))
		return false
	if RESERVED_IDS.has(record_id) and not (kind_name == "ledger" and record_id == "seed_ledger"):
		_emit(session, "reserved_id", SEVERITY_ERROR, record_path, record_id)
		return false
	if record_id.begins_with("fx_"):
		_emit(session, "fixture_id_in_live_content", SEVERITY_ERROR, record_path, record_id)
		return false
	if kind_name == "seeds":
		if not is_stable_id(record_id) or not record_id.begins_with("seed_s"):
			_emit(session, "id_prefix_mismatch", SEVERITY_ERROR, record_path, record_id)
			return false
		return true
	if not record_id.begins_with(prefix):
		_emit(session, "id_prefix_mismatch", SEVERITY_ERROR, record_path, record_id)
		return false
	var allowed: Array = KIND_ALLOWED.get(kind_name, [])
	var required: Array = KIND_REQUIRED.get(kind_name, [])
	if not _has_only_keys(record, allowed):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		return false
	if not _has_all_keys(record, required):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		return false
	if record.has("audit_note"):
		_check_text(session, record_path, record_id, "audit_note", record["audit_note"], MAX_AUDIT_NOTE_LENGTH)
	if record.has("seed_ids"):
		_check_seed_grounding(session, record_path, record_id, record)
	return true


static func _validate_record(session: _Session, kind_name: String, record_id: String, record_path: String, record: Dictionary) -> void:
	match kind_name:
		"ledger":
			_validate_ledger(session, record_path, record)
		"seeds":
			_validate_seed_record(session, record_path, record)
		"effects":
			_validate_effect(session, record_path, record)
		"statuses":
			_validate_status(session, record_path, record)
		"actions":
			_validate_action(session, record_path, record)
		"equipment":
			_validate_equipment(session, record_path, record)
		"items":
			_validate_item(session, record_path, record)
		"clocks":
			_validate_clock(session, record_path, record)
		"relationships":
			_validate_relationship(session, record_path, record)
		"recovery":
			_validate_recovery(session, record_path, record)
		"props":
			_validate_prop(session, record_path, record)
		"regions":
			_validate_region(session, record_path, record)
		"npcs":
			_validate_npc(session, record_path, record)
		"conversations":
			_validate_conversation(session, record_path, record)
		"documents":
			_validate_document(session, record_path, record)
		"phases":
			_validate_phase(session, record_path, record)
		"enemies":
			_validate_enemy(session, record_path, record)
		"encounters":
			_validate_encounter(session, record_path, record)


static func _validate_ledger(session: _Session, record_path: String, record: Dictionary) -> void:
	if String(record.get("id", "")) != "seed_ledger":
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	var denominator: Variant = record.get("denominator", {})
	if not denominator is Dictionary or not _is_integer(denominator.get("extracted_units")):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		return
	var units: int = int(denominator["extracted_units"])
	if units < 1 or units > 10000:
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, "number_out_of_range")
	if String(denominator.get("unit_rule", "")) != "independent_idea_unit":
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	if bool(denominator.get("line_count_is_not_denominator", true)) != true:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	var exclusions: Array = denominator.get("excluded_from_denominator", []) if denominator.get("excluded_from_denominator", []) is Array else []
	if exclusions.size() != 5:
		_emit(session, "ledger_exclusion_list_incomplete", SEVERITY_ERROR, record_path, "ledger_exclusion_list_incomplete")
	var quota: Variant = record.get("quota", {})
	if not quota is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		return
	var ratio: int = int(quota.get("ratio_permille", 0)) if _is_integer(quota.get("ratio_permille")) else 0
	if ratio < 1 or ratio > 1000:
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, "number_out_of_range")
	var minimum: int = int(quota.get("minimum_retained", -1)) if _is_integer(quota.get("minimum_retained")) else -1
	if minimum != int(floor(float(units * ratio) / 1000.0)):
		_emit(session, "ledger_quota_arithmetic_mismatch", SEVERITY_ERROR, record_path, "ledger_quota_arithmetic_mismatch")
	var preferred: int = int(quota.get("preferred_planned", 0)) if _is_integer(quota.get("preferred_planned")) else 0
	if preferred < minimum:
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, "number_out_of_range")
	if String(quota.get("gate_status_token", "")) != "planned_retained":
		_emit(session, "quota_token_mismatch", SEVERITY_ERROR, record_path, "quota_token_mismatch")
	if String(quota.get("post_review_status_token", "")) != "used":
		_emit(session, "quota_token_mismatch", SEVERITY_ERROR, record_path, "quota_token_mismatch")
	if bool(quota.get("post_review_counts_toward_gate", true)) != false:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	var gate: Variant = record.get("gate", {})
	if gate is Dictionary and bool(gate.get("blocks_runtime_start", true)):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")


static func _validate_seed_record(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	var digits: String = record_id.substr(6)
	if digits.length() != 3 or not digits.is_valid_int():
		_emit(session, "seed_id_malformed", SEVERITY_ERROR, record_path, record_id)
		return
	var number: int = int(digits)
	if number < 1 or number > 160:
		_emit(session, "seed_id_out_of_range", SEVERITY_ERROR, record_path, record_id)
	var section: String = String(record.get("ledger_section", ""))
	if not LEDGER_SECTIONS.has(section):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " ledger_section")
	var usage_class: String = String(record.get("ledger_usage_class", ""))
	if not LEDGER_USAGE_CLASSES.has(usage_class):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " ledger_usage_class")
	var status: String = String(record.get("status", ""))
	if not SEED_STATUSES.has(status):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " status")
	var is_magic: bool = number >= 121
	if is_magic and section != "L":
		_emit(session, "magic_seed_wrong_section", SEVERITY_ERROR, record_path, record_id)
	if not is_magic and section == "L":
		_emit(session, "magic_seed_wrong_section", SEVERITY_ERROR, record_path, record_id)
	for key: String in ["source_intent", "tin_structural_change", "local_rule"]:
		_check_text(session, record_path, record_id, key, record.get(key, ""), MAX_TEXT_LENGTH)
	var bindings: Array = record.get("bindings", []) if record.get("bindings", []) is Array else []
	for binding: Variant in bindings:
		if not binding is Dictionary or not SEED_BINDING_KINDS.has(String(binding.get("kind", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " bindings kind")
	var link_a: Variant = record.get("cross_link_a", {})
	var link_b: Variant = record.get("cross_link_b", {})
	if not link_a is Dictionary or not link_b is Dictionary \
		or not SEED_BINDING_KINDS.has(String(link_a.get("kind", ""))) \
		or not SEED_BINDING_KINDS.has(String(link_b.get("kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " cross_link")
	elif String(link_a.get("kind", "")) == String(link_b.get("kind", "")):
		_emit(session, "seed_transform_needs_two_kinds", SEVERITY_ERROR, record_path, record_id)
	elif String(link_a.get("id", "")) == String(link_b.get("id", "")):
		_emit(session, "seed_link_self_referential", SEVERITY_ERROR, record_path, record_id)
	_check_text(session, record_path, record_id, "immediate_consequence", record.get("immediate_consequence", ""), MAX_TEXT_LENGTH)
	var delayed: Variant = record.get("delayed_consequence", {})
	if not delayed is Dictionary or not SEED_DELAY_TIMINGS.has(String(delayed.get("timing", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " delayed_consequence")
	_check_text(session, record_path, record_id, "delayed_consequence.what", (delayed as Dictionary).get("what", ""), MAX_TEXT_LENGTH)
	var gates: Variant = record.get("anti_generic_gates", {})
	if not gates is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " anti_generic_gates")
		return
	for gate_key: String in ["g1_local_rule", "g2_surface_removed_variant", "g3_two_cross_links",
			"g4_immediate_consequence", "g5_delayed_consequence", "g6_needed_by_npc_region_or_system",
			"g7_name_swap_still_specific", "g8_not_weirdness_only"]:
		if not gates.has(gate_key) or typeof(gates[gate_key]) != TYPE_BOOL:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " gate " + gate_key)
			return
	if status == "planned_retained":
		for gate_key: String in ["g1_local_rule", "g2_surface_removed_variant", "g3_two_cross_links",
				"g4_immediate_consequence", "g5_delayed_consequence", "g6_needed_by_npc_region_or_system",
				"g7_name_swap_still_specific", "g8_not_weirdness_only"]:
			if not bool(gates[gate_key]):
				_emit(session, "seed_gate_failed_without_rejection", SEVERITY_ERROR, record_path, record_id + " " + gate_key)
				return
	if usage_class in ["CANDIDATE", "DROP"] and status == "used":
		_emit(session, "candidate_marked_used", SEVERITY_ERROR, record_path, record_id)
	var provenance: Variant = record.get("provenance", {})
	if not provenance is Dictionary or not PROVENANCE_KINDS.has(String(provenance.get("source_kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " provenance")
	elif bool(provenance.get("no_original_wording_copied", false)) != true:
		_emit(session, "source_copy_risk", SEVERITY_ERROR, record_path, record_id)
	if status == "used" and (delayed as Dictionary).get("effect_id", "") == null:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")


static func _validate_effect(session: _Session, record_path: String, record: Dictionary) -> void:
	var timing: String = String(record.get("timing", ""))
	if not EFFECT_TIMINGS.has(timing):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, String(record.get("id", "")) + " timing")
		return
	var delay_ref: Variant = record.get("delay_ref", {})
	if timing == "immediate":
		if record.has("delay_ref"):
			_emit(session, "effect_delay_mismatch", SEVERITY_ERROR, record_path, "effect_delay_mismatch")
	else:
		if not delay_ref is Dictionary or not EFFECT_DELAY_KINDS.has(String(delay_ref.get("kind", ""))):
			_emit(session, "effect_delay_mismatch", SEVERITY_ERROR, record_path, String(record.get("id", "")))
		elif String(delay_ref["kind"]) == "clock_stage":
			var clock_id: String = String(delay_ref.get("id", ""))
			if not CLOCK_STAGE_TOKENS.has(clock_id) or not (CLOCK_STAGE_TOKENS[clock_id] as Array).has(String(delay_ref.get("stage_id", ""))):
				_emit(session, "clock_stage_not_in_02_ladder", SEVERITY_ERROR, record_path, clock_id)
		elif delay_ref.has("stage_id"):
			_emit(session, "effect_delay_mismatch", SEVERITY_ERROR, record_path, "effect_delay_mismatch")
	var repeat_guard: String = String(record.get("repeat_guard", ""))
	if not EFFECT_REPEAT_GUARDS.has(repeat_guard):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, String(record.get("id", "")) + " repeat_guard")
	if bool(record.get("one_shot", false)) and repeat_guard not in ["once", "never_repeat"]:
		_emit(session, "one_shot_guard_mismatch", SEVERITY_ERROR, record_path, String(record.get("id", "")))
	var operations: Array = record.get("operations", []) if record.get("operations", []) is Array else []
	if operations.is_empty():
		_emit(session, "effect_empty", SEVERITY_ERROR, record_path, String(record.get("id", "")))
	if operations.size() > 24:
		_emit(session, "effect_too_large", SEVERITY_ERROR, record_path, String(record.get("id", "")))
	for operation: Variant in operations:
		_validate_effect_operation(session, record_path, String(record.get("id", "")), operation)
	var has_seed: bool = record.has("seed_ids") and (record["seed_ids"] as Array).size() > 0
	var has_note: bool = record.has("audit_note") and String(record["audit_note"]).strip_edges() != ""
	if not has_seed and not has_note:
		_emit(session, "ungrounded_effect", SEVERITY_ERROR, record_path, String(record.get("id", "")))
	if has_seed and has_note:
		_emit(session, "double_justification", SEVERITY_ERROR, record_path, String(record.get("id", "")))


static func _validate_effect_operation(session: _Session, record_path: String, owner_id: String, operation: Variant) -> void:
	if not operation is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, owner_id + " operation")
		return
	var op: String = String(operation.get("op", ""))
	if not EFFECT_OPERATIONS.has(op):
		_emit(session, "unknown_operation", SEVERITY_ERROR, record_path, owner_id + " op " + op)
		return
	var allowed: Array = _operation_keys(op)
	var keys: Dictionary = {}
	for key: Variant in operation.keys():
		if key == "op":
			continue
		if not allowed.has(String(key)) or String(key) == "op":
			_emit(session, "operation_key_mismatch", SEVERITY_ERROR, record_path, owner_id + " " + op)
			return
		keys[String(key)] = operation[key]
	for required: String in _operation_required(op):
		if not keys.has(required):
			_emit(session, "operation_key_mismatch", SEVERITY_ERROR, record_path, "operation_key_mismatch")
	match op:
		"set_axis":
			if not WORLD_AXES.has(String(keys.get("axis", ""))):
				_emit(session, "axis_out_of_range", SEVERITY_ERROR, record_path, owner_id + " axis")
			elif not _is_axis_integer(keys.get("value")):
				_emit(session, "axis_token_in_integer_field", SEVERITY_ERROR, record_path, "axis_token_in_integer_field")
		"advance_clock", "set_clock_stage":
			if not CLOCK_STAGE_TOKENS.has(String(keys.get("clock_id", ""))):
				_emit(session, "clock_not_canonical", SEVERITY_ERROR, record_path, owner_id + " clock_id")
			if op == "set_clock_stage":
				var ladder: Array = CLOCK_STAGE_TOKENS.get(String(keys.get("clock_id", "")), [])
				if not ladder.has(String(keys.get("stage_id", ""))):
					_emit(session, "clock_stage_not_in_02_ladder", SEVERITY_ERROR, record_path, owner_id + " stage_id")
			elif not _is_in_range(keys.get("ticks"), 1, 9):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, owner_id + " ticks")
		"npc_state":
			if not NPC_STATE_KEYS.has(String(keys.get("key", ""))):
				_emit(session, "key_error_mismatch", SEVERITY_ERROR, record_path, owner_id + " npc_state key")
		"flag":
			var flag_key: String = String(keys.get("key", ""))
			if not flag_key.begins_with("world_"):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, owner_id + " flag prefix")
			elif typeof(keys.get("value")) != TYPE_BOOL:
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, owner_id + " flag value")
		"queue_encounter":
			if not QUANTITY_AT.has(String(keys.get("at", ""))):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, owner_id + " at")
		"grant_equipment", "grant_item", "consume_equipment", "consume_item":
			if not _is_in_range(keys.get("count", 1), 1, 9999):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, owner_id + " count")


static func _operation_keys(op: String) -> Array:
	match op:
		"set_axis": return ["axis", "value"]
		"advance_clock": return ["clock_id", "ticks", "stage_id"]
		"set_clock_stage": return ["clock_id", "stage_id"]
		"npc_state": return ["npc_id", "key", "value"]
		"relationship": return ["relationship_id", "target_npc_id", "to_state_id", "reason"]
		"prop_state": return ["prop_id", "state_id"]
		"unlock_route": return ["gate_id"]
		"region_state": return ["region_id", "state_tag"]
		"reveal_document": return ["document_id"]
		"grant_equipment", "consume_equipment": return ["equipment_id", "count"]
		"grant_item", "consume_item": return ["item_id", "count"]
		"apply_status": return ["target", "status_id", "stacks"]
		"clear_status": return ["status_id", "target"]
		"queue_encounter": return ["encounter_id", "at"]
		"queue_recovery": return ["recovery_event_id"]
		"flag": return ["key", "value"]
	return []


static func _operation_required(op: String) -> Array:
	match op:
		"set_axis": return ["axis", "value"]
		"advance_clock": return ["clock_id", "ticks"]
		"set_clock_stage": return ["clock_id", "stage_id"]
		"npc_state": return ["npc_id", "key", "value"]
		"relationship": return ["relationship_id", "target_npc_id", "to_state_id"]
		"prop_state": return ["prop_id", "state_id"]
		"unlock_route": return ["gate_id"]
		"region_state": return ["region_id", "state_tag"]
		"reveal_document": return ["document_id"]
		"grant_equipment", "consume_equipment": return ["equipment_id"]
		"grant_item", "consume_item": return ["item_id"]
		"apply_status": return ["target", "status_id", "stacks"]
		"clear_status": return ["status_id", "target"]
		"queue_encounter": return ["encounter_id", "at"]
		"queue_recovery": return ["recovery_event_id"]
		"flag": return ["key", "value"]
	return []


static func _validate_status(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	var policy: String = String(record.get("stack_policy", ""))
	if not STATUS_STACK_POLICIES.has(policy):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stack_policy")
	var max_stacks: int = int(record.get("max_stacks", 0)) if _is_integer(record.get("max_stacks")) else 0
	if not _is_in_range(record.get("max_stacks"), 1, 9):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " max_stacks")
	elif not STACK_POLICY_REPEATABLE.has(policy) and max_stacks != 1:
		_emit(session, "stack_policy_mismatch", SEVERITY_ERROR, record_path, record_id)
	var duration: Variant = record.get("duration", {})
	if not duration is Dictionary or not STATUS_DURATION_KINDS.has(String(duration.get("kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " duration")
	elif String(duration["kind"]) == "turns":
		if not _is_in_range(duration.get("turns"), 1, 30):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " duration.turns")
	elif String(duration["kind"]) == "permanent" and duration.has("turns"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	var tick: Variant = record.get("tick", {})
	if tick is Dictionary:
		for operation: Variant in tick.get("operations", []) if tick.get("operations", []) is Array else []:
			if not operation is Dictionary or not STATUS_TICK_OPS.has(String(operation.get("op", ""))):
				_emit(session, "status_tick_op_not_allowed", SEVERITY_ERROR, record_path, record_id)
			elif String(operation["op"]) == "resource_delta":
				if not COMBAT_RESOURCE_KEYS.has(String(operation.get("resource", ""))):
					_emit(session, "resource_key_forbidden", SEVERITY_ERROR, record_path, record_id)
	elif record.has("tick"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " tick")
	var modifiers: Variant = record.get("modifiers", {})
	if modifiers is Dictionary:
		var deltas: Variant = modifiers.get("stat_deltas", {})
		if not deltas is Dictionary:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stat_deltas")
		else:
			for key: Variant in deltas:
				if not STAT_KEYS.has(String(key)):
					_emit(session, "resource_key_forbidden" if String(key) in FORBIDDEN_RESOURCE_KEYS else "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stat " + String(key))
				elif not _is_in_range(deltas[key], -9999, 9999):
					_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " stat " + String(key))
	var control: Variant = record.get("control", {})
	if control is Dictionary:
		for category: Variant in control.get("blocked_action_categories", []) if control.get("blocked_action_categories", []) is Array else []:
			if not ACTION_CATEGORIES.has(String(category)):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " blocked category")
	var cure: Variant = record.get("cure", {})
	if not cure is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " cure")
	else:
		var categories: Array = cure.get("categories", []) if cure.get("categories", []) is Array else []
		if categories.is_empty():
			_emit(session, "status_without_cure_class", SEVERITY_ERROR, record_path, record_id)
		for category: Variant in categories:
			if not is_snake_token(category):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " cure category")
	var resistance: Variant = record.get("resistance", {})
	if resistance is Dictionary:
		var incoming: Dictionary = _id_set(resistance.get("incoming_status_ids", []))
		var immune: Dictionary = _id_set(resistance.get("immune_status_ids", []))
		for key: String in incoming:
			if immune.has(key):
				_emit(session, "status_resistance_conflict", SEVERITY_ERROR, record_path, record_id)
		if bool(resistance.get("break_shatter", false)) and incoming.is_empty():
			_emit(session, "unreachable_break_shatter", SEVERITY_WARNING, record_path, record_id)
	_validate_presentation_block(session, record_path, record_id, record.get("presentation", {}), ["icon_key", "tint_key", "band_order"])
	if not record.has("seed_ids") and not record.has("audit_note"):
		_emit(session, "ungrounded_record", SEVERITY_ERROR, record_path, record_id)


static func _validate_action(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	if not _is_in_range(record.get("order"), 0, 99):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " order")
	var owner: String = String(record.get("owner", ""))
	if not ACTION_OWNERS.has(owner):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " owner")
	var category: String = String(record.get("category", ""))
	if not ACTION_CATEGORIES.has(category):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " category")
	var defense_mode: String = String(record.get("defense_mode", ""))
	if not DEFENSE_MODES.has(defense_mode):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " defense_mode")
	elif category != "defend" and defense_mode != "none":
		_emit(session, "defense_mode_outside_defend", SEVERITY_ERROR, record_path, record_id)
	var lifecycle: String = String(record.get("lifecycle", ""))
	if not LIFECYCLES.has(lifecycle):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " lifecycle")
	var intent: Variant = record.get("intent", {})
	var target_mode: String = ""
	if not intent is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " intent")
	else:
		target_mode = String(intent.get("target_mode", ""))
		if not TARGET_MODES.has(target_mode):
			_emit(session, "target_mode_outside_canonical_enum", SEVERITY_ERROR, record_path, record_id + " " + target_mode)
		if TARGET_ROLES.has(target_mode):
			_emit(session, "target_role_used_as_target_mode", SEVERITY_ERROR, record_path, record_id)
		if not TARGET_ELIGIBILITY.has(String(intent.get("target_eligibility", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " target_eligibility")
		elif target_mode in ["SELF", "ALL_ENEMIES", "ALL_ALLIES"] and String(intent["target_eligibility"]) != "living":
			_emit(session, "target_eligibility_mismatch", SEVERITY_ERROR, record_path, record_id)
		var requires_cursor: bool = bool(intent.get("requires_target_cursor", false))
		if target_mode == "SELF" and requires_cursor:
			_emit(session, "cursor_without_target", SEVERITY_ERROR, record_path, record_id)
		if target_mode != "SELF" and not requires_cursor:
			_emit(session, "target_without_cursor", SEVERITY_ERROR, record_path, record_id)
	_validate_action_cost(session, record_path, record_id, record, lifecycle)
	_validate_action_telegraph(session, record_path, record_id, record, lifecycle)
	_validate_action_damage(session, record_path, record_id, record)
	_validate_action_breaks(session, record_path, record_id, record, lifecycle)
	_validate_action_counters(session, record_path, record_id, record)
	_validate_action_hooks(session, record_path, record_id, record)
	_validate_action_reactions(session, record_path, record_id, record)
	_validate_action_status_payloads(session, record_path, record_id, record)
	_validate_action_craft(session, record_path, record_id, record)
	_validate_action_commitment(session, record_path, record_id, record, lifecycle)
	_validate_presentation_block(session, record_path, record_id, record.get("presentation", {}), ["icon_key", "arena_key"])


static func _validate_action_cost(session: _Session, record_path: String, record_id: String, record: Dictionary, lifecycle: String) -> void:
	var cost: Variant = record.get("cost", {})
	if not cost is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " cost")
		return
	if not _is_integer(cost.get("turn_cost")):
		_emit(session, "turn_cost_not_integer", SEVERITY_ERROR, record_path, record_id)
		return
	var turn_cost: int = int(cost["turn_cost"])
	if turn_cost < TURN_COST_MIN or turn_cost > TURN_COST_MAX:
		_emit(session, "turn_cost_out_of_range", SEVERITY_ERROR, record_path, record_id)
		return
	var slot_cost: int = int(cost.get("action_slot_cost", 0)) if _is_integer(cost.get("action_slot_cost")) else 0
	if turn_cost == 0 and slot_cost != 0:
		_emit(session, "slot_cost_on_no_turn", SEVERITY_ERROR, record_path, record_id)
	if turn_cost >= 2 and slot_cost != 1:
		_emit(session, "committed_slot_cost_mismatch", SEVERITY_ERROR, record_path, record_id)
	if turn_cost >= 2 and lifecycle not in ["instant", "committed"]:
		_emit(session, "committed_without_commitment", SEVERITY_ERROR, record_path, record_id)
	if lifecycle == "committed" and turn_cost < 2:
		_emit(session, "committed_turn_cost_too_low", SEVERITY_ERROR, record_path, record_id)
	var resources: Variant = cost.get("resource_costs", {})
	if not resources is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " resource_costs")
	else:
		for key: Variant in resources:
			var key_text: String = String(key)
			if key_text in FORBIDDEN_RESOURCE_KEYS or not COMBAT_RESOURCE_KEYS.has(key_text):
				_emit(session, "resource_key_forbidden", SEVERITY_ERROR, record_path, record_id + " " + key_text)
			elif not _is_in_range(resources[key], 0, 9999):
				_emit(session, "negative_cost" if int(resources[key]) < 0 else "number_out_of_range", SEVERITY_ERROR, record_path, record_id)
	if not _is_in_range(cost.get("cooldown_windows", 0), 0, 99):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " cooldown_windows")


static func _validate_action_telegraph(session: _Session, record_path: String, record_id: String, record: Dictionary, lifecycle: String) -> void:
	var telegraph: Variant = record.get("telegraph", {})
	if not telegraph is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " telegraph")
		return
	var channels: Array = telegraph.get("channels", []) if telegraph.get("channels", []) is Array else []
	var minimum: int = 2 if lifecycle == "charge" else 1
	if channels.size() < minimum:
		_emit(session, "charge_single_tell_channel" if lifecycle == "charge" else "action_without_telegraph", SEVERITY_ERROR, record_path, record_id)
	for channel: Variant in channels:
		if not TELEGRAPH_CHANNELS.has(String(channel)):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " telegraph channel")
	if not _is_in_range(telegraph.get("windows_before_active", 0), 0, 5):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " windows_before_active")
	_check_art_key(session, record_path, record_id, "telegraph.tell_key", telegraph.get("tell_key", ""))


static func _validate_action_damage(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var payload: Variant = record.get("damage_payload", {})
	if not payload is Dictionary:
		return
	var allowed: Array[String] = [
		"delivery", "shape", "base_value", "affinity", "hit_policy", "hit_modifier",
		"evasion_policy", "critical_policy", "dodge_pressure", "guard_ignore",
		"breaks_guard", "break_damage", "dodgeable", "break_damage_kinds",
		"self_damage", "lifesteal", "reflect", "on_hit_payload_ids", "on_evade_payload_ids",
	]
	if not _has_only_keys(payload, allowed):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " damage_payload key")
		return
	var delivery: String = String(payload.get("delivery", "physical"))
	if not DELIVERIES.has(delivery):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " delivery")
	var shape: String = String(payload.get("shape", "fixed"))
	if not DAMAGE_SHAPES.has(shape):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " shape")
	var base_max: int = 100 if shape.begins_with("percent_") else 9999
	if not _is_in_range(payload.get("base_value", 0), 0, base_max):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " base_value")
	if not AFFINITIES.has(String(payload.get("affinity", "none"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " affinity")
	if not HIT_POLICIES.has(String(payload.get("hit_policy", "roll"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " hit_policy")
	if not EVASION_POLICIES.has(String(payload.get("evasion_policy", "roll"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " evasion_policy")
	if not CRITICAL_POLICIES.has(String(payload.get("critical_policy", "never"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " critical_policy")
	if not _is_in_range(payload.get("hit_modifier", 0), -99, 99):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " hit_modifier")
	if not _is_in_range(payload.get("dodge_pressure", 0), 0, 99):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " dodge_pressure")
	if delivery == "true":
		if bool(payload.get("dodgeable", true)):
			_emit(session, "true_damage_dodgeable", SEVERITY_ERROR, record_path, record_id)
		if String(payload.get("evasion_policy", "roll")) != "disabled":
			_emit(session, "true_damage_dodgeable", SEVERITY_ERROR, record_path, record_id)
	for key: String in ["self_damage", "lifesteal", "reflect", "break_damage"]:
		if not _is_in_range(payload.get(key, 0), 0, 9999):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + key)
	for kind: Variant in payload.get("break_damage_kinds", []) if payload.get("break_damage_kinds", []) is Array else []:
		if not BREAK_DAMAGE_KINDS.has(String(kind)):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " break_damage_kinds")
	for key: String in ["on_hit_payload_ids", "on_evade_payload_ids"]:
		var list: Array = payload.get(key, []) if payload.get(key, []) is Array else []
		if list.size() > 4:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " " + key)


static func _validate_action_breaks(session: _Session, record_path: String, record_id: String, record: Dictionary, lifecycle: String) -> void:
	if not record.has("break_spec"):
		return
	var spec: Variant = record["break_spec"]
	if not spec is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " break_spec")
		return
	if not _has_only_keys(spec, ["stacks", "status_ids", "effect_ids", "requires_target_breakable", "cancels_charge"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " break_spec key")
		return
	var effects: Array = spec.get("effect_ids", []) if spec.get("effect_ids", []) is Array else []
	if effects.is_empty():
		_emit(session, "break_spec_without_effect", SEVERITY_ERROR, record_path, record_id)
	if bool(spec.get("cancels_charge", false)) and lifecycle != "charge":
		_emit(session, "charge_cancel_on_non_charge", SEVERITY_ERROR, record_path, record_id)
	if not _is_in_range(spec.get("stacks", 1), 1, 9):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " break_spec.stacks")
	var hooks: Variant = record.get("hooks", {})
	if hooks is Dictionary:
		var on_break: Array = hooks.get("on_break", []) if hooks.get("on_break", []) is Array else []
		var declared: Dictionary = _id_set(effects)
		for effect_id: Variant in on_break:
			if not declared.has(String(effect_id)):
				_emit(session, "break_hook_unwired", SEVERITY_ERROR, record_path, record_id)


static func _validate_action_counters(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var counters: Variant = record.get("counters", {})
	if not counters is Dictionary:
		return
	var valid: Dictionary = _token_set(counters.get("valid", []))
	var forbidden: Dictionary = _token_set(counters.get("forbidden", []))
	if valid.is_empty():
		_emit(session, "action_without_counter", SEVERITY_ERROR, record_path, record_id)
	for token: String in valid:
		if forbidden.has(token):
			_emit(session, "counter_conflict", SEVERITY_ERROR, record_path, record_id + " " + token)
		if not COUNTER_TOKENS.has(token):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " counter token")
	var breakable: bool = bool(counters.get("breakable", false))
	if breakable and not valid.has("break"):
		_emit(session, "break_policy_inconsistent", SEVERITY_ERROR, record_path, record_id)
	if not breakable and not forbidden.has("break"):
		_emit(session, "break_policy_inconsistent", SEVERITY_ERROR, record_path, record_id)
	if not breakable and valid.is_empty():
		_emit(session, "unbreakable_without_alternative", SEVERITY_ERROR, record_path, record_id)


static func _validate_action_hooks(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var hooks: Variant = record.get("hooks", {})
	if not hooks is Dictionary:
		return
	if not _has_only_keys(hooks, HOOK_KEYS):
		_emit(session, "unknown_hook", SEVERITY_ERROR, record_path, record_id + " hooks")
		return
	var payload: Variant = record.get("damage_payload", {})
	var canonical: Dictionary = {}
	if payload is Dictionary:
		canonical = _merge_sets(canonical, _id_set(payload.get("on_hit_payload_ids", [])))
		canonical = _merge_sets(canonical, _id_set(payload.get("on_evade_payload_ids", [])))
	for effect_id: Variant in hooks.get("on_hit", []) if hooks.get("on_hit", []) is Array else []:
		if canonical.has(String(effect_id)):
			_emit(session, "hook_double_registration", SEVERITY_ERROR, record_path, record_id)


static func _validate_action_reactions(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	if not record.has("reactions"):
		return
	var reactions: Variant = record["reactions"]
	if not reactions is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " reactions")
		return
	if not _has_only_keys(reactions, ["valid_reaction_ids", "forbidden_response_ids"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " reactions key")
		return
	var valid: Dictionary = _id_set(reactions.get("valid_reaction_ids", []))
	var forbidden: Dictionary = _id_set(reactions.get("forbidden_response_ids", []))
	for reaction_id: String in valid:
		if forbidden.has(reaction_id):
			_emit(session, "counter_conflict", SEVERITY_ERROR, record_path, record_id + " " + reaction_id)
	if valid.is_empty() and forbidden.is_empty():
		_emit(session, "reaction_unwired", SEVERITY_ERROR, record_path, record_id)


static func _validate_action_status_payloads(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var payloads: Array = record.get("status_payloads", []) if record.get("status_payloads", []) is Array else []
	var self_seen: Dictionary = {}
	for entry: Variant in payloads:
		if not entry is Dictionary or not _has_only_keys(entry, ["status_id", "chance_permille", "target"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " status_payloads")
			continue
		var target: String = String(entry.get("target", "target"))
		if not ["self", "target"].has(target):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " status payload target")
		if target == "self" and self_seen.has(String(entry.get("status_id", ""))):
			_emit(session, "duplicate_self_status", SEVERITY_ERROR, record_path, record_id)
		self_seen[String(entry.get("status_id", ""))] = true
		if not _is_in_range(entry.get("chance_permille", 1000), 0, 1000):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " chance_permille")


static func _validate_action_commitment(session: _Session, record_path: String, record_id: String, record: Dictionary, lifecycle: String) -> void:
	var commitment: Variant = record["commitment"] if record.has("commitment") else null
	if commitment is Dictionary:
		if lifecycle == "instant":
			_emit(session, "commitment_on_instant", SEVERITY_ERROR, record_path, record_id)
		if not _is_in_range(commitment.get("spans_windows", 1), 1, 5):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " spans_windows")
	elif lifecycle in ["committed", "charge"]:
		_emit(session, "committed_without_commitment", SEVERITY_ERROR, record_path, record_id)
	var recovery: Variant = record["recovery"] if record.has("recovery") else null
	if recovery is Dictionary:
		if not _is_in_range(recovery.get("windows", 0), 0, 9):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " recovery.windows")
		if bool(recovery.get("recovery_locked", false)) and int(recovery.get("punish_windows", 0)) != 0:
			_emit(session, "punish_window_on_locked_recovery", SEVERITY_ERROR, record_path, record_id)
	var stages: Array = record.get("stages", []) if record.get("stages", []) is Array else []
	if not stages.is_empty():
		if lifecycle != "charge":
			_emit(session, "charge_stages_on_non_charge", SEVERITY_ERROR, record_path, record_id)
		for stage: Variant in stages:
			if not stage is Dictionary or not ["telegraph", "reaction", "strike", "recovery"].has(String(stage.get("stage", ""))):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stages")
				continue
			if not _is_in_range(stage.get("window_cost", 0), 1, 9):
				_emit(session, "charge_stage_zero_cost" if int(stage.get("window_cost", 0)) == 0 else "number_out_of_range", SEVERITY_ERROR, record_path, record_id)


static func _validate_action_craft(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	if not record.has("craft"):
		return
	var craft: Variant = record["craft"]
	var allowed: Array[String] = [
		"craft_family", "concentration_source", "concentration_requirement",
		"body_profile_requirements", "medium_options", "tool_options",
		"shape_or_pattern", "fold_count_budget", "preparation_turns", "waste",
		"failure_status_id", "environment_effect", "social_recording", "contract_ref",
	]
	if not craft is Dictionary or not _has_only_keys(craft, allowed):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " craft")
		return
	if String(record.get("category", "")) != "magic":
		_emit(session, "craft_on_non_magic_action", SEVERITY_ERROR, record_path, record_id)
	if not CRAFT_FAMILIES.has(String(craft.get("craft_family", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " craft_family")
	if not CONCENTRATION_SOURCES.has(String(craft.get("concentration_source", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " concentration_source")
	if not _is_in_range(craft.get("concentration_requirement", 0), 0, 1000):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " concentration_requirement")
	for profile: Variant in craft.get("body_profile_requirements", []) if craft.get("body_profile_requirements", []) is Array else []:
		if not MANA_PROFILES.has(String(profile)):
			_emit(session, "mana_profile_outside_canonical_enum", SEVERITY_ERROR, record_path, record_id)
	for medium: Variant in craft.get("medium_options", []) if craft.get("medium_options", []) is Array else []:
		if not FIELD_RESOURCE_KEYS.has(String(medium)):
			_emit(session, "unknown_field_resource_key", SEVERITY_ERROR, record_path, record_id + " medium_options")
	if not is_snake_token(craft.get("shape_or_pattern", "")):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " shape_or_pattern")
	if not _is_in_range(craft.get("preparation_turns", 0), 0, 5):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " preparation_turns")
	var waste: Variant = craft.get("waste", {})
	if waste is Dictionary:
		for key: Variant in waste:
			if not FIELD_RESOURCE_KEYS.has(String(key)) and not String(key).begins_with("st_"):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " waste key")
	if not String(craft.get("failure_status_id", "")).begins_with("st_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " failure_status_id")
	var environment: Variant = craft.get("environment_effect", {})
	if environment is Dictionary:
		var writes: Array = environment.get("clock_writes", []) if environment.get("clock_writes", []) is Array else []
		if writes.size() > 1:
			_emit(session, "craft_clock_write_not_single", SEVERITY_ERROR, record_path, record_id)
	var social: String = String(craft.get("social_recording", "none"))
	if social == "res_labor_pledge":
		_emit(session, "craft_record_target_forbidden", SEVERITY_ERROR, record_path, record_id)
	elif social != "none" and not FIELD_RESOURCE_KEYS.has(social):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " social_recording")


static func _validate_equipment(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	if not EQUIPMENT_SLOTS.has(String(record.get("slot", ""))):
		_emit(session, "equipment_without_slot", SEVERITY_ERROR, record_path, record_id)
	if not EQUIPMENT_FLOOR_ROLES.has(String(record.get("floor_role", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " floor_role")
	var modifiers: Variant = record.get("stat_modifiers", {})
	if not modifiers is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stat_modifiers")
	else:
		for key: Variant in modifiers:
			if not STAT_KEYS.has(String(key)):
				_emit(session, "resource_key_forbidden" if String(key) in FORBIDDEN_RESOURCE_KEYS else "invalid_schema", SEVERITY_ERROR, record_path, record_id + " " + String(key))
			elif not _is_in_range(modifiers[key], -9999, 9999):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + String(key))
	var defense: Variant = record.get("defense", {})
	if defense is Dictionary:
		if not _is_in_range(defense.get("guard_efficiency_bp", 0), -1000, 1000):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " guard_efficiency_bp")
		if not _is_in_range(defense.get("dodge_pressure", 0), -99, 99):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " defense.dodge_pressure")
		if not BREAK_POLICIES.has(String(defense.get("break_policy", "enabled"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " break_policy")
	var grants: Variant = record.get("action_grants", {})
	if not grants is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " action_grants")
		return
	var slot_delta: int = int(grants.get("action_slot_delta", 0)) if _is_integer(grants.get("action_slot_delta")) else 0
	if not _is_in_range(grants.get("action_slot_delta", 0), -1, 1):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " action_slot_delta")
	elif slot_delta == 1 and String(record.get("floor_role", "")) != "action_slot_source":
		_emit(session, "slot_delta_without_floor_role", SEVERITY_ERROR, record_path, record_id)
	var no_turn_actions: Array = grants.get("no_turn_action_ids", []) if grants.get("no_turn_action_ids", []) is Array else []
	if String(record.get("floor_role", "")) == "no_turn_item_source" and no_turn_actions.is_empty():
		_emit(session, "no_turn_source_without_action", SEVERITY_ERROR, record_path, record_id)
	if String(record.get("floor_role", "")) == "granted_active_skill" and (grants.get("granted_action_ids", []) as Array).is_empty():
		_emit(session, "granted_skill_without_action", SEVERITY_ERROR, record_path, record_id)
	if String(record.get("floor_role", "")) == "field_pass_key":
		var field_keys: Variant = record.get("field_keys", {})
		if not field_keys is Dictionary or field_keys.get("traversal_key", null) == null \
			or (field_keys.get("pass_ids", []) as Array).is_empty():
			_emit(session, "field_pass_key_without_key", SEVERITY_ERROR, record_path, record_id)
	var charge_pool: Variant = record["charge_pool"] if record.has("charge_pool") else null
	if charge_pool is Dictionary:
		if String(charge_pool.get("key", "")) != "equipment_charge":
			_emit(session, "charge_pool_wrong_key", SEVERITY_ERROR, record_path, record_id)
		var cap: int = int(charge_pool.get("max", 0)) if _is_integer(charge_pool.get("max")) else 0
		if cap <= 0:
			_emit(session, "empty_charge_pool_declared", SEVERITY_ERROR, record_path, record_id)
		elif int(charge_pool.get("start", 0)) > cap:
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " charge_pool.start")
	var acquisition: Variant = record.get("acquisition", {})
	if not acquisition is Dictionary or not ACQUISITION_SOURCES.has(String(acquisition.get("source_kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " acquisition")
	elif String(acquisition["source_kind"]) == "scripted":
		if acquisition.has("source_id") or not acquisition.has("effect_id"):
			_emit(session, "scripted_acquisition_without_effect", SEVERITY_ERROR, record_path, record_id)
	elif not acquisition.has("source_id"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " acquisition.source_id")
	if not _is_in_range(acquisition.get("count", 1), 1, 9):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " acquisition.count")
	_validate_presentation_block(session, record_path, record_id, record.get("presentation", {}), ["icon_key", "tint_key", "silhouette_key"])


static func _validate_item(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	if not ITEM_CLASSES.has(String(record.get("item_class", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " item_class")
	var use: Variant = record.get("use", {})
	if not use is Dictionary or not String(use.get("action_id", "")).begins_with("act_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " use.action_id")
	if use is Dictionary and not _is_in_range(use.get("max_stack", 1), 1, 99):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " use.max_stack")
	var acquisition: Variant = record.get("acquisition", {})
	if not acquisition is Dictionary or not ACQUISITION_SOURCES.has(String(acquisition.get("source_kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " acquisition")
	_validate_presentation_block(session, record_path, record_id, record.get("presentation", {}), ["icon_key", "tint_key"])


static func _validate_clock(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	if not CLOCK_STAGE_TOKENS.has(record_id):
		_emit(session, "clock_not_canonical", SEVERITY_ERROR, record_path, record_id)
		return
	if String(record.get("kind", "")) != String(CLOCK_KINDS[record_id]):
		_emit(session, "clock_kind_id_mismatch", SEVERITY_ERROR, record_path, record_id)
	var scope: String = String(record.get("scope", ""))
	if not CLOCK_SCOPES.has(scope):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " scope")
	if scope == "region" and not record.has("owner_region_id"):
		_emit(session, "clock_owner_mismatch", SEVERITY_ERROR, record_path, record_id)
	if scope == "global" and (record.has("owner_region_id") or record.has("owner_npc_id")):
		_emit(session, "clock_owner_mismatch", SEVERITY_ERROR, record_path, record_id)
	if scope == "character" and not record.has("owner_npc_id"):
		_emit(session, "clock_owner_mismatch", SEVERITY_ERROR, record_path, record_id)
	if not CLOCK_START_STATES.has(String(record.get("start_state", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " start_state")
	var period: Variant = record.get("period", {})
	if not period is Dictionary or not ["encounter_window", "clock_tick", "player_action", "region_enter"].has(String(period.get("unit", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " period")
	elif not _is_in_range(period.get("per", 1), 1, 10):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " period.per")
	var stages: Array = record.get("stages", []) if record.get("stages", []) is Array else []
	if stages.is_empty() or stages.size() > CLOCK_STAGE_COUNT:
		_emit(session, "clock_stage_too_many" if stages.size() > CLOCK_STAGE_COUNT else "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stages")
	var ladder: Array = CLOCK_STAGE_TOKENS.get(record_id, [])
	var irreversible_seen: int = 0
	var last_reversal_allowed: bool = true
	for position: int in range(stages.size()):
		var stage: Variant = stages[position]
		if not stage is Dictionary:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stage")
			continue
		if int(stage.get("index", -1)) != position:
			_emit(session, "clock_stage_index_off_02_ladder", SEVERITY_ERROR, record_path, record_id)
		if not ladder.has(String(stage.get("stage_id", ""))):
			_emit(session, "clock_stage_not_in_02_ladder", SEVERITY_ERROR, record_path, record_id)
		_check_text(session, record_path, record_id, "stage.label", stage.get("label", ""), MAX_AUDIT_NOTE_LENGTH)
		if bool(stage.get("irreversible", false)):
			irreversible_seen += 1
			if position != CLOCK_IRREVERSIBLE_INDEX:
				_emit(session, "clock_irreversible_index_off_02_ladder", SEVERITY_ERROR, record_path, record_id)
		_validate_clock_signal(session, record_path, record_id, stage)
		var reversal: Variant = stage.get("reversal", {})
		if reversal is Dictionary:
			last_reversal_allowed = bool(reversal.get("allowed", true))
	if stages.size() > 0 and ladder.has(String((stages[0] as Dictionary).get("stage_id", ""))) \
		and (stages[0] as Dictionary).get("index", -1) != 0:
		_emit(session, "clock_start_stage_mismatch", SEVERITY_ERROR, record_path, record_id)
	if irreversible_seen != 1:
		_emit(session, "clock_without_irreversible_point", SEVERITY_ERROR, record_path, record_id)
	if last_reversal_allowed:
		_emit(session, "terminal_stage_reversible", SEVERITY_ERROR, record_path, record_id)
	var policy: Variant = record.get("pressure_policy", {})
	if policy is Dictionary:
		var advances: bool = bool(policy.get("advance_on_player_action", false)) \
			or bool(policy.get("advance_on_region_enter", false)) \
			or bool(policy.get("advance_on_encounter_window", false))
		if not advances or bool(record.get("never_advances", false)):
			_emit(session, "clock_never_advances", SEVERITY_ERROR, record_path, record_id)
		if not _is_in_range(policy.get("decay_when_untouched", 0), 0, 99):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " decay_when_untouched")


static func _validate_clock_signal(session: _Session, record_path: String, record_id: String, stage: Dictionary) -> void:
	var visible: Variant = stage.get("visible_signal", {})
	if not visible is Dictionary or not CLOCK_VISIBLE_CHANNELS.has(String(visible.get("channel", ""))):
		_emit(session, "clock_stage_without_signal", SEVERITY_ERROR, record_path, record_id)
		return
	var channel: String = String(visible["channel"])
	var allowed: Array[String] = ["channel", "text"]
	var required_key: String = "text"
	match channel:
		"npc_warning":
			required_key = "npc_id"
			allowed.append("npc_id")
		"document":
			required_key = "document_id"
			allowed.append("document_id")
		"prop_change":
			required_key = "prop_id"
			allowed.append("prop_id")
		_:
			allowed.append("text")
	if not _has_only_keys(visible, allowed) or not visible.has(required_key):
		_emit(session, "visible_signal_key_mismatch", SEVERITY_ERROR, record_path, record_id + " " + channel)
	if channel == "resource_shortage" and String(visible.get("text", "")).strip_edges().is_empty():
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " signal text")


static func _validate_relationship(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	if not String(record.get("target_npc_id", "")).begins_with("npc_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " target_npc_id")
	if not RELATIONSHIP_CHANNELS.has(String(record.get("channel", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " channel")
	var states: Array = record.get("states", []) if record.get("states", []) is Array else []
	if states.is_empty() or states.size() > 10:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " states")
	var state_ids: Dictionary = {}
	var sink_count: int = 0
	for position: int in range(states.size()):
		var state: Variant = states[position]
		if not state is Dictionary:
			continue
		var state_id: String = String(state.get("state_id", ""))
		if not is_snake_token(state_id) or state_ids.has(state_id):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " state_id " + state_id)
			continue
		state_ids[state_id] = position
		if int(state.get("order", -1)) != position:
			_emit(session, "relationship_state_gap", SEVERITY_ERROR, record_path, record_id)
		if not DIALOGUE_POLICIES.has(String(state.get("dialogue_policy", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " dialogue_policy")
		var power: Variant = state.get("companion_power", {})
		if power is Dictionary and bool(power.get("enabled", false)):
			var granted: Array = power.get("granted_by_effect_ids", []) if power.get("granted_by_effect_ids", []) is Array else []
			if granted.is_empty():
				_emit(session, "companion_power_without_history", SEVERITY_ERROR, record_path, record_id)
			else:
				var entry: Array = state.get("entry_effect_ids", []) if state.get("entry_effect_ids", []) is Array else []
				for effect_id: Variant in granted:
					if not (entry as Array).has(String(effect_id)):
						_emit(session, "companion_power_unwired", SEVERITY_ERROR, record_path, record_id)
	var start_state: String = String(record.get("start_state_id", ""))
	if not state_ids.has(start_state) or int(state_ids[start_state]) != 0:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " start_state_id")
	var incoming: Dictionary = {}
	var pair_priorities: Dictionary = {}
	var transitions: Array = record.get("transitions", []) if record.get("transitions", []) is Array else []
	for transition: Variant in transitions:
		if not transition is Dictionary:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " transition")
			continue
		var from_state: String = String(transition.get("from_state_id", ""))
		var to_state: String = String(transition.get("to_state_id", ""))
		if not state_ids.has(from_state) or not state_ids.has(to_state):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " transition state")
			continue
		if from_state == to_state:
			_emit(session, "relationship_cycle", SEVERITY_ERROR, record_path, record_id)
		if not TRANSITION_VIA.has(String(transition.get("via", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " via")
		if String(transition.get("via", "")) == "choice" and not _condition_has_leaf(transition.get("requires_condition", {}), "choice_taken"):
			_emit(session, "relationship_choice_not_grounded", SEVERITY_ERROR, record_path, record_id)
		var pair_key: String = from_state + "|" + str(transition.get("priority", 0))
		if pair_priorities.has(pair_key):
			_emit(session, "transition_priority_ambiguous", SEVERITY_ERROR, record_path, record_id)
		pair_priorities[pair_key] = true
		if not incoming.has(to_state):
			incoming[to_state] = true
	for state_id: String in state_ids:
		if state_id != start_state and not incoming.has(state_id):
			_emit(session, "unreachable_relationship_state", SEVERITY_ERROR, record_path, record_id + " " + state_id)
		if not outgoing_of(transitions, state_id):
			sink_count += 1
	var exclusions: Variant = record.get("exclusions", {})
	if not exclusions is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " exclusions")
	else:
		var maximum: int = int(exclusions.get("max_final_state", 0)) if _is_integer(exclusions.get("max_final_state")) else 0
		if maximum <= 0:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " max_final_state")
		elif sink_count != maximum:
			_emit(session, "ambiguous_final_state", SEVERITY_ERROR, record_path, record_id)
		for conflicting: Variant in exclusions.get("conflicting_final_state_ids", []) if exclusions.get("conflicting_final_state_ids", []) is Array else []:
			if outgoing_of(transitions, String(conflicting)):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " conflicting state")
	var axes: Variant = record.get("axes", {})
	if not axes is Dictionary or axes.size() != RELATIONSHIP_AXES.size():
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " axes")
	else:
		for key: Variant in axes:
			if not RELATIONSHIP_AXES.has(String(key)):
				_emit(session, "relationship_axis_key_unexpected", SEVERITY_ERROR, record_path, record_id + " " + String(key))
			elif not _is_in_range(axes[key], AXIS_MIN, AXIS_MAX):
				_emit(session, "axis_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + String(key))
	var romance: Variant = record.get("romance", {})
	if not romance is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " romance")
		return
	if bool(romance.get("explicit_content", false)):
		_emit(session, "explicit_content_forbidden", SEVERITY_ERROR, record_path, record_id)
	if bool(romance.get("allowed", false)):
		if (romance.get("consent_beat_effect_ids", []) as Array).is_empty():
			_emit(session, "romance_without_consent_beat", SEVERITY_ERROR, record_path, record_id)
		if String(record.get("channel", "")) != "romance":
			_emit(session, "romance_without_state", SEVERITY_ERROR, record_path, record_id)
		for transition: Variant in transitions:
			if transition is Dictionary and not ["choice", "effect"].has(String(transition.get("via", ""))):
				continue


static func outgoing_of(transitions: Array, state_id: String) -> bool:
	for transition: Variant in transitions:
		if transition is Dictionary and String(transition.get("from_state_id", "")) == state_id:
			return true
	return false


static func _validate_recovery(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	var kind: String = String(record.get("kind", ""))
	if RETIRED_RECOVERY_TOKENS.has(kind):
		_emit(session, "recovery_kind_token_mismatch", SEVERITY_ERROR, record_path, record_id + " " + kind)
		return
	if not RECOVERY_KINDS.has(kind):
		_emit(session, "recovery_kind_violation", SEVERITY_ERROR, record_path, record_id + " " + kind)
		return
	_validate_recovery_trigger(session, record_path, record_id, record)
	var preserves: Dictionary = _token_set(record.get("preserves", []))
	var discards: Dictionary = _token_set(record.get("discards", []))
	if preserves.is_empty():
		_emit(session, "recovery_preserves_nothing", SEVERITY_ERROR, record_path, record_id)
	for token: String in preserves:
		if not STATE_PRESERVE_TOKENS.has(token):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " preserve " + token)
		if discards.has(token):
			_emit(session, "recovery_contradiction", SEVERITY_ERROR, record_path, record_id + " " + token)
	for token: String in discards:
		if not STATE_DISCARD_TOKENS.has(token):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " discard " + token)
	var restored: Dictionary = _token_set(record.get("self_layers_restored", []))
	var not_restored: Dictionary = _token_set(record.get("self_layers_not_restored", []))
	for layer: String in SELF_LAYERS:
		if restored.has(layer) and not_restored.has(layer):
			_emit(session, "recovery_layer_overlap", SEVERITY_ERROR, record_path, record_id + " " + layer)
		if not restored.has(layer) and not not_restored.has(layer):
			_emit(session, "recovery_layer_gap", SEVERITY_ERROR, record_path, record_id + " " + layer)
	var respawn: Variant = record.get("respawn", {})
	if not respawn is Dictionary or not String(respawn.get("region_id", "")).begins_with("region_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " respawn.region_id")
	elif kind in ["checkpoint", "respawn"] and not String(respawn.get("encounter_id", "")).begins_with("enc_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " respawn.encounter_id")
	var cost: Variant = record.get("cost", {})
	if not cost is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " cost")
		return
	var pressure_delta: int = int(cost.get("continuity_pressure_delta", 0)) if _is_integer(cost.get("continuity_pressure_delta")) else 0
	if not _is_in_range(cost.get("continuity_pressure_delta", 0), 0, 3):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " continuity_pressure_delta")
	for key: Variant in cost.get("axis_deltas", {}) if cost.get("axis_deltas", {}) is Dictionary else {}:
		if not WORLD_AXES.has(String(key)):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " axis_deltas " + String(key))
		elif not _is_in_range((cost["axis_deltas"] as Dictionary)[key], AXIS_MIN, AXIS_MAX):
			_emit(session, "axis_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + String(key))
	for key: Variant in cost.get("resource_costs", {}) if cost.get("resource_costs", {}) is Dictionary else {}:
		if not COMBAT_RESOURCE_KEYS.has(String(key)):
			_emit(session, "resource_key_forbidden", SEVERITY_ERROR, record_path, record_id + " " + String(key))
	if kind == "clone" or kind == "reincarnation":
		if not not_restored.has("social_recognition"):
			_emit(session, "recovery_kind_violation", SEVERITY_ERROR, record_path, record_id + " social_recognition")
	if kind == "checkpoint" or kind == "respawn":
		if not discards.has("encounter_progress"):
			_emit(session, "recovery_kind_violation", SEVERITY_ERROR, record_path, record_id + " encounter_progress")
	if kind == "loop":
		if not preserves.has("flags"):
			_emit(session, "recovery_kind_violation", SEVERITY_ERROR, record_path, record_id + " flags")
		if pressure_delta < 1:
			_emit(session, "recovery_kind_violation", SEVERITY_ERROR, record_path, record_id + " loop continuity delta")
	if kind == "immortality" and pressure_delta < 1:
		_emit(session, "recovery_kind_violation", SEVERITY_ERROR, record_path, record_id + " immortality continuity delta")
	if kind == "institutional_reentry":
		if not preserves.has("npc_states") or not preserves.has("document_reads"):
			_emit(session, "recovery_kind_violation", SEVERITY_ERROR, record_path, record_id + " institutional_reentry preserves")
		if (record.get("entry_effect_ids", []) as Array).is_empty():
			_emit(session, "recovery_kind_violation", SEVERITY_ERROR, record_path, record_id + " entry_effect_ids")
	if kind == "checkpoint" and not preserves.has("player_vitals"):
		_emit(session, "checkpoint_without_vitals", SEVERITY_WARNING, record_path, record_id)
	var cooldown: Variant = record.get("cooldown", {})
	if not cooldown is Dictionary or not RECOVERY_COOLDOWN_KINDS.has(String(cooldown.get("kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " cooldown")
	elif String(cooldown["kind"]) == "gate":
		if not String(cooldown.get("gate_id", "")).begins_with("gate_g"):
			_emit(session, "cooldown_key_mismatch", SEVERITY_ERROR, record_path, record_id)
	elif cooldown.has("gate_id"):
		_emit(session, "cooldown_key_mismatch", SEVERITY_ERROR, record_path, record_id)


static func _validate_recovery_trigger(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var trigger: Variant = record.get("trigger", {})
	if not trigger is Dictionary or not RECOVERY_TRIGGER_KINDS.has(String(trigger.get("kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " trigger")
		return
	var kind: String = String(trigger["kind"])
	var forbidden: Array[String] = []
	match kind:
		"death":
			forbidden = ["encounter_id", "gate_id", "phase_id"]
		"encounter_failure":
			forbidden = ["gate_id", "phase_id"]
			if not String(trigger.get("encounter_id", "")).begins_with("enc_"):
				_emit(session, "trigger_key_mismatch", SEVERITY_ERROR, record_path, record_id)
		"phase_complete":
			forbidden = ["gate_id"]
			if not String(trigger.get("encounter_id", "")).begins_with("enc_") or not String(trigger.get("phase_id", "")).begins_with("phase_"):
				_emit(session, "trigger_key_mismatch", SEVERITY_ERROR, record_path, record_id)
		"route_enter":
			forbidden = ["encounter_id", "phase_id"]
			if not String(trigger.get("gate_id", "")).begins_with("gate_g"):
				_emit(session, "trigger_key_mismatch", SEVERITY_ERROR, record_path, record_id)
		"scripted":
			forbidden = ["encounter_id", "gate_id", "phase_id"]
	for key: String in forbidden:
		if trigger.has(key):
			_emit(session, "trigger_key_mismatch", SEVERITY_ERROR, record_path, "trigger_key_mismatch")


static func _validate_prop(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	if not String(record.get("region_id", "")).begins_with("region_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " region_id")
	var placement: Variant = record.get("placement", {})
	if not placement is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " placement")
		return
	if not _has_only_keys(placement, ["anchor_key", "layer", "visible_from"]):
		_emit(session, "content_infers_art_priority", SEVERITY_ERROR, record_path, record_id + " placement key")
	if not PLACEMENT_LAYERS.has(String(placement.get("layer", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " placement.layer")
	if not VISIBLE_FROM.has(String(placement.get("visible_from", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " placement.visible_from")
	if not is_snake_token(placement.get("anchor_key", "")):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " anchor_key")
	var states: Array = record.get("states", []) if record.get("states", []) is Array else []
	if states.is_empty() or states.size() > 12:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " states")
	var any_visible: bool = false
	var any_interactable: bool = false
	var initial_state: String = String(record.get("initial_state_id", ""))
	var effect_owners: Dictionary = {}
	for state: Variant in states:
		if not state is Dictionary or not _has_only_keys(state, ["state_id", "label", "visible", "art_key", "collides", "interactable", "entry_effect_ids"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " state key")
			continue
		any_visible = any_visible or bool(state.get("visible", true))
		any_interactable = any_interactable or bool(state.get("interactable", false))
		_check_art_key(session, record_path, record_id, "state.art_key", state.get("art_key", ""))
		for effect_id: Variant in state.get("entry_effect_ids", []) if state.get("entry_effect_ids", []) is Array else []:
			if effect_owners.has(String(effect_id)):
				_emit(session, "prop_state_effect_collision", SEVERITY_ERROR, record_path, record_id)
			effect_owners[String(effect_id)] = String(state.get("state_id", ""))
	if not any_visible:
		_emit(session, "prop_never_visible", SEVERITY_ERROR, record_path, record_id)
	if not any_interactable and not record.has("interaction"):
		_emit(session, "dead_interaction", SEVERITY_ERROR, record_path, record_id)
	if initial_state.is_empty():
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " initial_state_id")
	if not bool(record.get("revisit_visible", true)) and not any_visible:
		_emit(session, "prop_invisible_on_revisit", SEVERITY_ERROR, record_path, record_id)
	if record.has("interaction"):
		var interaction: Variant = record["interaction"]
		if not interaction is Dictionary or not interaction.has("opens"):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " interaction")
		elif not ["prop", "field"].has(String(interaction.get("return_focus", "prop"))):
			_emit(session, "return_focus_not_in_kind", SEVERITY_ERROR, record_path, record_id)


static func _validate_region(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	if not REGION_ROLES.has(String(record.get("region_role", ""))):
		_emit(session, "region_role_mismatch", SEVERITY_ERROR, record_path, record_id)
	var thesis: String = String(record.get("conflict_thesis", ""))
	if thesis.strip_edges().is_empty() or thesis.count(".") + thesis.count("!") + thesis.count("?") > 1:
		_emit(session, "region_thesis_not_one_sentence", SEVERITY_ERROR, record_path, record_id)
	var topology: Variant = record.get("topology", {})
	if not topology is Dictionary or not _has_only_keys(topology, ["shape", "size_class", "landmark_count", "traversal_axis", "backtrack_supported"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " topology")
	elif not REGION_SIZE_CLASSES.has(String(topology.get("size_class", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " size_class")
	elif not _is_in_range(topology.get("landmark_count", 1), 1, 12):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " landmark_count")
	var entry: Variant = record.get("entry", {})
	if not entry is Dictionary or not String(entry.get("edge_id", "")).begins_with("route_e"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " entry.edge_id")
	elif not String(entry.get("gate_id", "")).begins_with("gate_g"):
		_emit(session, "unknown_gate_id", SEVERITY_ERROR, record_path, record_id)
	var exits: Array = record.get("exits", []) if record.get("exits", []) is Array else []
	if exits.is_empty():
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " exits")
	var internal_routes: Array = record.get("internal_routes", []) if record.get("internal_routes", []) is Array else []
	if internal_routes.size() > 4:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " internal_routes")
	if exits.size() + internal_routes.size() < 2:
		_emit(session, "single_return_affordance", SEVERITY_ERROR, record_path, record_id)
	if bool((topology as Dictionary).get("backtrack_supported", true)) == false and exits.size() != 1:
		_emit(session, "no_backtrack_single_exit", SEVERITY_ERROR, record_path, record_id)
	for exit_entry: Variant in exits:
		_validate_region_exit(session, record_path, record_id, exit_entry, false)
	for exit_entry: Variant in internal_routes:
		_validate_region_exit(session, record_path, record_id, exit_entry, true)
	var flow: Variant = record.get("resource_flow", {})
	if flow is Dictionary:
		var scarce: Dictionary = _token_set(flow.get("scarce_keys", []))
		var surplus: Dictionary = _token_set(flow.get("surplus_keys", []))
		for key: String in scarce:
			if not FIELD_RESOURCE_KEYS.has(key):
				_emit(session, "unknown_field_resource_key", SEVERITY_ERROR, record_path, record_id + " " + key)
			if surplus.has(key):
				_emit(session, "resource_key_conflict", SEVERITY_ERROR, record_path, record_id + " " + key)
		for key: String in surplus:
			if not FIELD_RESOURCE_KEYS.has(key):
				_emit(session, "unknown_field_resource_key", SEVERITY_ERROR, record_path, record_id + " " + key)
			if DEBT_RESOURCE_KEYS.has(key):
				_emit(session, "debt_key_as_surplus", SEVERITY_ERROR, record_path, record_id + " " + key)
	var clocks: Array = record.get("clocks", []) if record.get("clocks", []) is Array else []
	if clocks.is_empty() or clocks.size() > 6:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " clocks")
	var clock_seen: Dictionary = {}
	for clock_entry: Variant in clocks:
		if not clock_entry is Dictionary:
			continue
		var clock_id: String = String(clock_entry.get("clock_id", ""))
		if not CLOCK_STAGE_TOKENS.has(clock_id):
			_emit(session, "clock_not_canonical", SEVERITY_ERROR, record_path, record_id + " " + clock_id)
		if clock_seen.has(clock_id):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		clock_seen[clock_id] = true
		if not CLOCK_REVERSALS.has(String(clock_entry.get("reversal", "none"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " clock reversal")
		if not _is_in_range(clock_entry.get("weight", 1), 1, 3):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " clock weight")
	if record.has("concentration"):
		_validate_region_concentration(session, record_path, record_id, record["concentration"])
	var hidden: Variant = record.get("hidden_state", {})
	if hidden is Dictionary:
		if not REVEAL_KINDS.has(String(hidden.get("reveal_kind", "none"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " reveal_kind")
		elif String(hidden["reveal_kind"]) != "none":
			var revealed: int = (hidden.get("reveal_prop_ids", []) as Array).size() + (hidden.get("reveal_document_ids", []) as Array).size()
			if revealed == 0:
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		elif not (hidden.get("reveal_condition", {}) as Dictionary).is_empty():
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	if not REGION_STATE_TAGS.has(String(record.get("initial_state", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " initial_state")
	var combat: Variant = record.get("combat_content", {})
	if combat is Dictionary and not FIELD_PRESSURES.has(String(combat.get("field_pressure", "low"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " field_pressure")
	var cluster: Variant = record.get("initial_cluster", {})
	if not cluster is Dictionary or not is_snake_token(cluster.get("cluster_id", ""), 3, 64):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " initial_cluster.cluster_id")
	else:
		var cluster_id: String = String(cluster["cluster_id"])
		if session.cluster_ids.has(cluster_id):
			_emit(session, "duplicate_cluster_id", SEVERITY_ERROR, record_path, cluster_id)
		session.cluster_ids[cluster_id] = record_id
	var variants: Array = record.get("revisit_variants", []) if record.get("revisit_variants", []) is Array else []
	if variants.size() > 8:
		_emit(session, "variant_overflow", SEVERITY_ERROR, record_path, record_id)
	elif variants.size() < 2:
		_emit(session, "too_few_revisit_variants", SEVERITY_ERROR, record_path, record_id)
	var variant_seen: Dictionary = {}
	for variant: Variant in variants:
		if not variant is Dictionary or not is_snake_token(variant.get("variant_id", "")):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " variant_id")
			continue
		if variant_seen.has(String(variant["variant_id"])):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		variant_seen[String(variant["variant_id"])] = true
	var debts: Array = record.get("unresolved_debt", []) if record.get("unresolved_debt", []) is Array else []
	if debts.is_empty():
		_emit(session, "region_without_unresolved_debt", SEVERITY_ERROR, record_path, record_id)
	for debt: Variant in debts:
		if not debt is Dictionary or not is_snake_token(debt.get("debt_id", "")):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " debt_id")
			continue
		if not DEBT_RESOLUTION_TOKENS.has(String(debt.get("resolution_token", "open"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " resolution_token")
		elif String(debt.get("resolution_token", "open")) != "open" and (debt.get("resolve_effect_ids", []) as Array).is_empty():
			_emit(session, "debt_resolved_without_effect", SEVERITY_ERROR, record_path, record_id)
		var debt_resource: String = String(debt.get("resource_id", ""))
		if DEBT_RESOURCE_KEYS.has(debt_resource) and not debt.has("resolution_token"):
			_emit(session, "debt_key_without_resolution", SEVERITY_ERROR, record_path, record_id)
	var links: Array = record.get("cross_region_links", []) if record.get("cross_region_links", []) is Array else []
	for link: Variant in links:
		if not link is Dictionary or not LINK_KINDS.has(String(link.get("link_kind", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " link_kind")
		elif String(link.get("to_region_id", "")) == record_id:
			_emit(session, "self_region_link", SEVERITY_ERROR, record_path, record_id)
	var weights: Variant = record.get("axis_weights", {})
	if not weights is Dictionary or weights.size() != WORLD_AXES.size():
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " axis_weights")
	else:
		var total: int = 0
		for key: Variant in weights:
			if not WORLD_AXES.has(String(key)):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " axis " + String(key))
			elif not _is_in_range(weights[key], 0, 3):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + String(key))
			else:
				total += int(weights[key])
		if total == 0:
			_emit(session, "region_axis_weightless", SEVERITY_ERROR, record_path, record_id)
	for resident: Variant in record.get("residents", []) if record.get("residents", []) is Array else []:
		if not resident is Dictionary or not String(resident.get("npc_id", "")).begins_with("npc_"):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " resident npc_id")
		elif not PRESENCE_VALUES.has(String(resident.get("initial_presence", "resident"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " initial_presence")


static func _validate_region_exit(session: _Session, record_path: String, record_id: String, exit_entry: Variant, internal: bool) -> void:
	if not exit_entry is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " exit")
		return
	if internal:
		if not _has_only_keys(exit_entry, ["internal_route_id", "from_anchor_key", "to_anchor_key", "route_state", "requires_condition", "unlock_effect_id"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " internal route key")
		if exit_entry.has("gate_id"):
			_emit(session, "unknown_gate_id", SEVERITY_ERROR, record_path, "unknown_gate_id")
	else:
		if not _has_only_keys(exit_entry, ["to_region_id", "edge_id", "gate_id", "route_state", "requires_condition", "unlock_effect_id", "field_activation", "resource_keys"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " exit key")
			return
		var edge_id: String = String(exit_entry.get("edge_id", ""))
		if not is_stable_id(edge_id) or not edge_id.begins_with("route_e"):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " edge_id")
		_catalog_edge(session, edge_id, record_id, record_path)
		var gate_id: String = String(exit_entry.get("gate_id", ""))
		if not gate_id.begins_with("gate_g") or not is_stable_id(gate_id):
			_emit(session, "unknown_gate_id", SEVERITY_ERROR, record_path, record_id + " " + gate_id)
		if gate_id == "gate_g9" or gate_id == "gate_g10":
			_emit(session, "unknown_gate_id", SEVERITY_ERROR, record_path, record_id + " " + gate_id)
		var activation: String = String(exit_entry.get("field_activation", "CONTACT"))
		if not ENCOUNTER_FIELD_ACTIVATIONS.has(activation):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " field_activation")
		for key: Variant in exit_entry.get("resource_keys", []) if exit_entry.get("resource_keys", []) is Array else []:
			if not FIELD_RESOURCE_KEYS.has(String(key)):
				_emit(session, "unknown_field_resource_key", SEVERITY_ERROR, record_path, record_id + " " + String(key))
	var route_state: String = String(exit_entry.get("route_state", "locked"))
	if not ["open", "conditional", "redirected", "closed", "debt-bearing"].has(route_state):
		_emit(session, "route_state_outside_02_enum", SEVERITY_ERROR, record_path, record_id + " " + route_state)
		return
	var condition: Variant = exit_entry.get("requires_condition", {})
	var empty_condition: bool = condition is Dictionary and (condition as Dictionary).is_empty()
	if route_state in ["conditional", "closed", "redirected", "debt-bearing"] and empty_condition:
		_emit(session, "conditional_edge_without_condition", SEVERITY_ERROR, record_path, record_id)
	if route_state == "open" and not empty_condition:
		_emit(session, "open_edge_with_condition", SEVERITY_WARNING, record_path, record_id)


static func _validate_region_concentration(session: _Session, record_path: String, record_id: String, concentration: Variant) -> void:
	if not concentration is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " concentration")
		return
	if not _has_only_keys(concentration, ["field_level_permille", "safe_band_permille", "threshold_permille", "provenance_node_id", "disperser_node_ids", "disperser_charge_key", "circulation_slot_key", "pollution_accumulated"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " concentration key")
		return
	for key: String in ["field_level_permille", "safe_band_permille", "threshold_permille"]:
		if not _is_in_range(concentration.get(key, 0), 0, 1000):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + key)
	if int(concentration.get("safe_band_permille", 0)) >= int(concentration.get("threshold_permille", 0)):
		_emit(session, "concentration_band_above_threshold", SEVERITY_ERROR, record_path, record_id)
	if int(concentration.get("field_level_permille", 0)) >= int(concentration.get("threshold_permille", 1)):
		_emit(session, "concentration_threshold_already_crossed", SEVERITY_ERROR, record_path, record_id)
	if not is_snake_token(concentration.get("provenance_node_id", "")):
		_emit(session, "concentration_provenance_not_measurable", SEVERITY_ERROR, record_path, record_id)
	if String(concentration.get("disperser_charge_key", "res_disperser_charge")) != "res_disperser_charge" \
		or String(concentration.get("circulation_slot_key", "res_circulation_slot")) != "res_circulation_slot":
		_emit(session, "concentration_infrastructure_wrong_resource", SEVERITY_ERROR, record_path, record_id)
	if not _is_in_range(concentration.get("pollution_accumulated", 0), 0, 999):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " pollution_accumulated")


static func _validate_npc(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	if not ROSTER_KINDS.has(String(record.get("roster_kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " roster_kind")
	var number_prefix: String = record_id.substr(4, 2) if record_id.length() >= 6 else ""
	if number_prefix.is_valid_int() and not ["20", "21", "22", "23", "24", "25", "26"].has(number_prefix) \
		and int(number_prefix) >= 15 and int(number_prefix) <= 19:
		_emit(session, "support_roster_id_range_forbidden", SEVERITY_ERROR, record_path, record_id)
	for key: String in ["public_role", "private_role", "desire", "fear", "contradiction"]:
		_check_text(session, record_path, record_id, key, record.get(key, ""), MAX_TEXT_LENGTH)
	var capability: Variant = record.get("capability", {})
	if not capability is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " capability")
	else:
		var ports: Array = capability.get("port_ids", []) if capability.get("port_ids", []) is Array else []
		if ports.is_empty() or ports.size() > 8:
			_emit(session, "npc_without_port", SEVERITY_ERROR, record_path, record_id)
		var can: Array = capability.get("can", []) if capability.get("can", []) is Array else []
		if can.is_empty() or can.size() > 12:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " capability.can")
		for port: Variant in ports:
			if not is_snake_token(port):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " port_id")
		for verb: Variant in can:
			if not is_snake_token(verb):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " capability.can")
	var verbs: Array = record.get("interaction_verbs", []) if record.get("interaction_verbs", []) is Array else []
	if verbs.is_empty() or verbs.size() > 10:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " interaction_verbs")
	var verb_seen: Dictionary = {}
	for verb: Variant in verbs:
		if not verb is Dictionary or not _has_only_keys(verb, ["verb_id", "availability", "opens", "presentation_class"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " verb key")
			continue
		if verb.has("focusable"):
			_emit(session, "npc_verb_focus_field_present", SEVERITY_ERROR, record_path, record_id)
		var verb_id: String = String(verb.get("verb_id", ""))
		if not is_snake_token(verb_id) or verb_seen.has(verb_id):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " verb_id")
			continue
		verb_seen[verb_id] = true
		if not DOCUMENT_VERB_PRESENTATION_CLASSES.has(String(verb.get("presentation_class", "neutral"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " verb presentation_class")
		if not String(verb.get("opens", "")).is_empty() and (verb.get("availability", {}) as Dictionary).is_empty() and not record_id.is_empty():
			if String(verb["opens"]).is_empty():
				_emit(session, "npc_verb_without_target", SEVERITY_ERROR, record_path, record_id)
	var relationships: Array = record.get("relationship_ids", []) if record.get("relationship_ids", []) is Array else []
	if relationships.is_empty() or relationships.size() > 4:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " relationship_ids")
	var clocks: Array = record.get("clock_ids", []) if record.get("clock_ids", []) is Array else []
	for clock_id: Variant in clocks:
		if not CLOCK_STAGE_TOKENS.has(String(clock_id)):
			_emit(session, "clock_not_canonical", SEVERITY_ERROR, record_path, record_id + " " + String(clock_id))
	var profile: Variant = record.get("encounter_profile", {})
	if not profile is Dictionary or not _has_only_keys(profile, ["as_neutral", "as_hostile", "conversion_condition", "as_ally"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " encounter_profile")
	else:
		var hostile: Variant = profile.get("as_hostile", {})
		var hostile_id: String = String(hostile.get("encounter_id", "")) if hostile is Dictionary else ""
		if not hostile_id.begins_with("enc_") and profile.has("conversion_condition") \
			and (profile["conversion_condition"] is Dictionary) and not (profile["conversion_condition"] as Dictionary).is_empty():
			_emit(session, "npc_hostile_encounter_unwired", SEVERITY_ERROR, record_path, record_id)
	if record.has("mana_profile") and not MANA_PROFILES.has(String(record["mana_profile"])):
		_emit(session, "mana_profile_outside_canonical_enum", SEVERITY_ERROR, record_path, record_id)
	var survival: Variant = record.get("survival", {})
	if survival is Dictionary and bool(survival.get("death_allowed", true)) == false and String(record.get("removal", "")) != "never":
		_emit(session, "npc_removal_death_contradiction", SEVERITY_ERROR, record_path, record_id)
	var absence: Variant = record.get("absence", {})
	if not absence is Dictionary or not ABSENCE_KINDS.has(String(absence.get("kind", "none"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " absence")
	elif String(absence["kind"]) == "conditional" and (absence.get("condition", {}) as Dictionary).is_empty():
		_emit(session, "npc_absence_unconditional", SEVERITY_ERROR, record_path, record_id)
	if not REMOVALS.has(String(record.get("removal", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " removal")
	if String(record.get("roster_kind", "")) == "core" and String(absence.get("kind", "none")) != "permanent":
		_emit(session, "core_npc_absence_temporary", SEVERITY_WARNING, record_path, record_id)
	var cross_links: Array = record.get("cross_link_ids", []) if record.get("cross_link_ids", []) is Array else []
	if cross_links.size() < 2 or cross_links.size() > 12:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	_validate_presentation_block(session, record_path, record_id, record.get("appearance", {}), ["body_key", "portrait_key", "voice_key"])


static func _validate_conversation(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	if not String(record.get("region_id", "")).begins_with("region_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " region_id")
	if not _is_in_range(record.get("priority", 10), 0, 99):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " priority")
	if not CONVERSATION_REVISITS.has(String(record.get("revisit", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " revisit")
	var pages: Array = record.get("pages", []) if record.get("pages", []) is Array else []
	var choices: Array = record.get("choices", []) if record.get("choices", []) is Array else []
	if pages.is_empty() and choices.is_empty():
		_emit(session, "conversation_empty", SEVERITY_ERROR, record_path, record_id)
	if pages.size() > 24:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " pages")
	if choices.size() > 8:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " choices")
	var has_npc_page: bool = false
	var page_seen: Dictionary = {}
	for page: Variant in pages:
		if not page is Dictionary or not _has_only_keys(page, ["page_id", "speaker", "presentation_class", "text", "advance"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " page key")
			continue
		var page_id: String = String(page.get("page_id", ""))
		if not is_snake_token(page_id) or page_seen.has(page_id):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " page_id")
			continue
		page_seen[page_id] = true
		var speaker: String = String(page.get("speaker", "world"))
		if not PAGE_SPEAKERS.has(speaker):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " speaker")
		elif speaker == "npc":
			has_npc_page = true
		if not PAGE_ADVANCES.has(String(page.get("advance", "auto"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " advance")
		if not PRESENTATION_CLASSES.has(String(page.get("presentation_class", "neutral"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " page presentation_class")
		elif String(page["presentation_class"]) == "narration" and speaker != "world":
			_emit(session, "narration_class_on_npc_page", SEVERITY_ERROR, record_path, record_id)
		_check_text(session, record_path, record_id, "page.text", page.get("text", ""), MAX_TEXT_LENGTH)
	if has_npc_page and not record.has("speaker_npc_id"):
		_emit(session, "conversation_speaker_unbound", SEVERITY_ERROR, record_path, record_id)
	if not has_npc_page and record.has("speaker_npc_id"):
		_emit(session, "conversation_speaker_unbound", SEVERITY_ERROR, record_path, record_id)
	var has_irreversible: bool = false
	var choice_seen: Dictionary = {}
	for choice: Variant in choices:
		if not choice is Dictionary or not _has_only_keys(choice, ["choice_id", "text", "semantic_tags", "presentation_class", "availability", "unavailable_reason", "irreversibility", "return_focus", "immediate_effect_id", "delayed_effect_id", "one_shot", "hint_surface"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " choice key")
			continue
		var choice_id: String = String(choice.get("choice_id", ""))
		if not is_snake_token(choice_id) or choice_seen.has(choice_id):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " choice_id")
			continue
		choice_seen[choice_id] = true
		_check_text(session, record_path, record_id, "choice.text", choice.get("text", ""), MAX_TEXT_LENGTH)
		if not CHOICE_PRESENTATION_CLASSES.has(String(choice.get("presentation_class", "neutral"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " choice presentation_class")
		if not IRREVERSIBILITY_CLASSES.has(String(choice.get("irreversibility", "reversible"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " irreversibility")
		elif String(choice["irreversibility"]) == "irreversible":
			has_irreversible = true
		if not ["field", "choice", "conversation"].has(String(choice.get("return_focus", "field"))):
			_emit(session, "return_focus_not_in_kind", SEVERITY_ERROR, record_path, record_id + " choice return_focus")
		if (choice.get("semantic_tags", []) as Array).is_empty():
			_emit(session, "choice_without_semantic_tags", SEVERITY_ERROR, record_path, record_id)
		if not choice.has("immediate_effect_id") and not choice.has("delayed_effect_id"):
			_emit(session, "choice_without_state_surface", SEVERITY_ERROR, record_path, record_id)
	if has_irreversible and not (record.get("on_abort", {}) as Dictionary).get("effect_ids", []).is_empty():
		_emit(session, "abort_after_irreversible_choice", SEVERITY_ERROR, record_path, record_id)
	var alternatives: Array = record.get("alt_conversation_ids", []) if record.get("alt_conversation_ids", []) is Array else []
	for alternative: Variant in alternatives:
		if String(alternative) == record_id:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")


static func _validate_document(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	if not String(record.get("region_id", "")).begins_with("region_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " region_id")
	var availability: Variant = record.get("availability", {})
	if not availability is Dictionary or not DOCUMENT_REACHED_BY.has(String(availability.get("reached_by", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " availability")
	else:
		var reached_by: String = String(availability["reached_by"])
		if reached_by == "scripted":
			if record.has("reached_by_ref") or (availability.get("condition", {}) as Dictionary).is_empty():
				_emit(session, "scripted_document_needs_condition", SEVERITY_ERROR, record_path, record_id)
		elif not record.has("reached_by_ref"):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " reached_by_ref")
	var reading: Variant = record.get("reading", {})
	if not reading is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " reading")
		return
	var line_cap: int = int(reading.get("max_lines_per_page", DOCUMENT_PAGE_LINE_CAP)) if _is_integer(reading.get("max_lines_per_page")) else DOCUMENT_PAGE_LINE_CAP
	if line_cap > DOCUMENT_PAGE_LINE_CAP:
		_emit(session, "document_cap_overridden", SEVERITY_ERROR, record_path, record_id)
	if not _is_in_range(reading.get("min_font_size", DOCUMENT_MIN_FONT_SIZE), DOCUMENT_MIN_FONT_SIZE, DOCUMENT_MAX_FONT_SIZE):
		_emit(session, "document_font_below_floor", SEVERITY_ERROR, record_path, record_id)
	if not BACKGROUND_MODES.has(String(reading.get("background_mode", "dim_world"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " background_mode")
	if not ["page", "auto"].has(String(reading.get("advance", "page"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " advance")
	var pages: Array = record.get("pages", []) if record.get("pages", []) is Array else []
	if pages.is_empty() or pages.size() > 12:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " pages")
	var has_corruption: bool = false
	var page_seen: Dictionary = {}
	for page: Variant in pages:
		if not page is Dictionary or not _has_only_keys(page, ["page_id", "lines", "presentation", "corruption_rules"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " page key")
			continue
		var page_id: String = String(page.get("page_id", ""))
		if not is_snake_token(page_id) or page_seen.has(page_id):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " page_id")
			continue
		page_seen[page_id] = true
		var lines: Array = page.get("lines", []) if page.get("lines", []) is Array else []
		if lines.is_empty() or lines.size() > line_cap:
			_emit(session, "document_page_overflow", SEVERITY_ERROR, record_path, record_id + " " + page_id)
		for line: Variant in lines:
			if not line is String or String(line).length() > MAX_DOCUMENT_LINE_LENGTH:
				_emit(session, "document_line_too_long", SEVERITY_ERROR, record_path, record_id + " " + page_id)
			elif String(line).strip_edges().is_empty():
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		var presentation: String = String(page.get("presentation", "plain"))
		if not DOCUMENT_PRESENTATIONS.has(presentation):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " presentation")
			continue
		var rules: Array = page.get("corruption_rules", []) if page.get("corruption_rules", []) is Array else []
		if presentation == "corrupted":
			has_corruption = true
			if rules.is_empty():
				_emit(session, "corrupted_page_without_rule", SEVERITY_ERROR, record_path, record_id)
		elif not rules.is_empty():
			_emit(session, "corruption_rule_on_plain_page", SEVERITY_ERROR, record_path, record_id)
		for rule: Variant in rules:
			_validate_corruption_rule(session, record_path, record_id, page_id, rule)
	if not ["allowed", "blocked_after_corruption", "once"].has(String(record.get("revisit", "allowed"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " revisit")
	elif String(record["revisit"]) == "blocked_after_corruption" and not has_corruption:
		_emit(session, "revisit_rule_without_corruption", SEVERITY_ERROR, record_path, record_id)
	var post_read: Variant = record.get("post_read", {})
	if post_read is Dictionary and bool(post_read.get("once", false)) and String(record.get("revisit", "allowed")) != "allowed":
		_emit(session, "once_document_blocks_revisit", SEVERITY_ERROR, record_path, record_id)


static func _validate_corruption_rule(session: _Session, record_path: String, record_id: String, page_id: String, rule: Variant) -> void:
	if not rule is Dictionary or not _has_only_keys(rule, ["rule_id", "mode", "line_index", "token_index", "trigger", "severity", "replacement_seed_id", "text_note"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " corruption rule key")
		return
	var mode: String = String(rule.get("mode", ""))
	if not CORRUPTION_MODES.has(mode):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " corruption mode")
		return
	if mode in ["recolor", "replace_token"] and String(rule.get("text_note", "")).strip_edges().is_empty():
		_emit(session, "color_only_communication", SEVERITY_ERROR, record_path, record_id)
	if mode in ["shatter_line", "drop_glyph"] and not _is_in_range(rule.get("line_index", -1), 0, 8):
		_emit(session, "corruption_out_of_range", SEVERITY_ERROR, record_path, record_id)
	if mode == "drop_glyph" and not _is_in_range(rule.get("token_index", -1), 0, 8):
		_emit(session, "corruption_out_of_range", SEVERITY_ERROR, record_path, record_id)
	if not _is_in_range(rule.get("severity", 1), 1, 3):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " severity")
	if not is_snake_token(rule.get("rule_id", "")):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " rule_id")


static func _validate_phase(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	if not String(record.get("owner_enemy_id", "")).begins_with("enemy_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " owner_enemy_id")
	if not _is_in_range(record.get("index"), 1, 12):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " index")
	var trigger: Variant = record.get("trigger", {})
	if not trigger is Dictionary or not ["hp_ratio", "cumulative_hp_loss", "window_count", "story_flag", "linked_actor_death", "previous_phase_complete"].has(String(trigger.get("kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " trigger")
	else:
		var kind: String = String(trigger["kind"])
		var required: Dictionary = {"hp_ratio": ["hp_ratio_at"], "cumulative_hp_loss": ["hp_ratio_at"], "window_count": ["window_count_at"], "story_flag": ["story_flag_key"], "linked_actor_death": ["linked_enemy_id"]}
		if kind == "previous_phase_complete" and int(record.get("index", 1)) == 1:
			_emit(session, "first_phase_self_trigger", SEVERITY_ERROR, record_path, record_id)
		for key: String in required.get(kind, []):
			if not trigger.has(key):
				_emit(session, "trigger_key_mismatch", SEVERITY_ERROR, record_path, record_id + " " + key)
		for other: String in ["window_count_at", "story_flag_key", "linked_enemy_id", "hp_ratio_at"]:
			if other in required.get(kind, []) or kind == "previous_phase_complete":
				continue
			if trigger.has(other):
				_emit(session, "trigger_key_mismatch", SEVERITY_ERROR, record_path, "trigger_key_mismatch")
	var completion: Variant = record.get("completion", {})
	if not completion is Dictionary or not ["owner_dead", "survive_windows", "reduce_owner_hp_to", "linked_actors_cleared"].has(String(completion.get("kind", ""))):
		_emit(session, "completion_key_mismatch", SEVERITY_ERROR, record_path, record_id)
	elif String(completion["kind"]) == "reduce_owner_hp_to":
		if not _is_in_range(completion.get("hp_ratio_at", 0), 1, 99):
			_emit(session, "completion_hp_ratio_zero", SEVERITY_ERROR, record_path, record_id)
	var overrides: Variant = record.get("overrides", {})
	if overrides is Dictionary:
		var add_ids: Dictionary = _id_set(overrides.get("action_add_ids", []))
		var remove_ids: Dictionary = _id_set(overrides.get("action_remove_ids", []))
		for key: String in add_ids:
			if remove_ids.has(key):
				_emit(session, "action_override_conflict", SEVERITY_ERROR, record_path, record_id)
		for key: Variant in overrides.get("stat_overrides", {}) if overrides.get("stat_overrides", {}) is Dictionary else {}:
			if not STAT_KEYS.has(String(key)):
				_emit(session, "resource_key_forbidden" if String(key) in FORBIDDEN_RESOURCE_KEYS else "invalid_schema", SEVERITY_ERROR, record_path, record_id + " " + String(key))
			elif not _is_in_range((overrides["stat_overrides"] as Dictionary)[key], 0, 9999):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + String(key))
	if record.get("next_phase_id", null) != null and not String(record["next_phase_id"]).begins_with("phase_"):
		_emit(session, "phase_forward_reference", SEVERITY_ERROR, record_path, record_id)


static func _validate_enemy(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	var role: Variant = record.get("role", {})
	if not role is Dictionary or not _has_only_keys(role, ["base_region_id", "region_secondary", "region_role", "institution_id", "role_tags"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " role key")
		return
	if not String(role.get("base_region_id", "")).begins_with("region_"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " base_region_id")
	if not REGION_ROLES.has(String(role.get("region_role", ""))):
		_emit(session, "enemy_region_role_mismatch", SEVERITY_ERROR, record_path, record_id)
	var role_tags: Array = role.get("role_tags", []) if role.get("role_tags", []) is Array else []
	if role_tags.is_empty() or role_tags.size() > 8:
		_emit(session, "enemy_without_role", SEVERITY_ERROR, record_path, record_id)
	if role.has("region_secondary") and String(role["region_secondary"]) == String(role.get("base_region_id", "")):
		_emit(session, "self_region_link", SEVERITY_ERROR, record_path, record_id)
	var body: Variant = record.get("body", {})
	if not body is Dictionary or not ENEMY_BODY_CLASSES.has(String(body.get("body_class", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " body.body_class")
	elif String(body["body_class"]) == "abstract" and String(body.get("motion_signature", "")).strip_edges().is_empty():
		_emit(session, "enemy_abstract_without_motion", SEVERITY_ERROR, record_path, record_id)
	if not ENEMY_SCALE_CLASSES.has(String(body.get("scale_class", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " scale_class")
	if not STATEFUL_BODIES.has(String(body.get("stateful_body", "none"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stateful_body")
	_check_art_key(session, record_path, record_id, "body.silhouette_key", body.get("silhouette_key", ""))
	var stats: Variant = record.get("stats", {})
	if not stats is Dictionary or not _is_in_range(stats.get("max_hp"), 1, 99999):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " stats.max_hp")
	else:
		if not _is_in_range(stats.get("agility", 1), 1, 999):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " agility")
		if not _is_in_range(stats.get("action_slots", 1), 1, 3):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " action_slots")
		for key: Variant in stats.get("resource_pool", {}) if stats.get("resource_pool", {}) is Dictionary else {}:
			if not COMBAT_RESOURCE_KEYS.has(String(key)):
				_emit(session, "resource_key_forbidden", SEVERITY_ERROR, record_path, record_id + " " + String(key))
			elif not _is_in_range((stats["resource_pool"] as Dictionary)[key], 0, 9999):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + String(key))
	if record.has("condition_bar"):
		var bar: Variant = record["condition_bar"]
		if not bar is Dictionary or not CONDITION_BAR_KINDS.has(String(bar.get("kind", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " condition_bar kind")
		elif String(bar["kind"]) == "hp":
			_emit(session, "condition_bar_on_hp_kind", SEVERITY_ERROR, record_path, record_id)
		else:
			var advance_on: Array = bar.get("advance_on", []) if bar.get("advance_on", []) is Array else []
			if advance_on.is_empty():
				_emit(session, "condition_bar_without_advance", SEVERITY_ERROR, record_path, record_id)
			for source: Variant in advance_on:
				if not CONDITION_BAR_ADVANCE_ON.has(String(source)):
					_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " advance_on")
			if not _is_in_range(bar.get("max_value", 1), 1, 9999):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " max_value")
	var baseline: Array = record.get("baseline_action_ids", []) if record.get("baseline_action_ids", []) is Array else []
	if baseline.is_empty() or baseline.size() > 12:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " baseline_action_ids")
	var signature: String = String(record.get("signature_action_id", ""))
	if not signature.is_empty() and (baseline as Array).has(signature):
		_emit(session, "signature_not_distinct", SEVERITY_ERROR, record_path, record_id)
	var status_profile: Variant = record.get("status_profile", {})
	if status_profile is Dictionary:
		var resistant: Dictionary = _id_set(status_profile.get("resistant_status_ids", []))
		var immune: Dictionary = _id_set(status_profile.get("immune_status_ids", []))
		var innate: Dictionary = _id_set(status_profile.get("innate_status_ids", []))
		for key: String in resistant:
			if immune.has(key):
				_emit(session, "enemy_resistance_conflict", SEVERITY_ERROR, record_path, record_id)
		for key: String in innate:
			if immune.has(key):
				_emit(session, "enemy_immune_and_innate", SEVERITY_ERROR, record_path, record_id)
	var break_profile: Variant = record.get("break_profile", {})
	if not break_profile is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " break_profile")
	else:
		var breakable: bool = bool(break_profile.get("breakable", false))
		var sources: Array = break_profile.get("break_source_action_ids", []) if break_profile.get("break_source_action_ids", []) is Array else []
		if breakable and sources.is_empty():
			_emit(session, "breakable_without_source", SEVERITY_ERROR, record_path, record_id)
		if not breakable and (not sources.is_empty() or not (break_profile.get("on_break_status_ids", []) as Array).is_empty() or not (break_profile.get("on_break_effect_ids", []) as Array).is_empty()):
			_emit(session, "unbreakable_with_break_source", SEVERITY_ERROR, record_path, record_id)
	if String(body.get("scale_class", "")) in ["large", "architectural"] and (record.get("phase_ids", []) as Array).is_empty():
		_emit(session, "major_enemy_without_phase", SEVERITY_ERROR, record_path, record_id)
	var true_targets: int = 0
	var linked: Array = record.get("linked_actors", []) if record.get("linked_actors", []) is Array else []
	if linked.size() > 4:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " linked_actors")
	for entry: Variant in linked:
		if not entry is Dictionary:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " linked actor")
			continue
		if String(entry.get("enemy_id", "")) == record_id:
			_emit(session, "self_link", SEVERITY_ERROR, record_path, record_id)
		if not LINKED_ACTOR_ROLES.has(String(entry.get("role", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " linked role")
		if not LINKED_TIMINGS.has(String(entry.get("timing", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " linked timing")
		elif String(entry["timing"]) == "hp_step" and not _is_in_range(entry.get("hp_step_percent", 0), 1, 99):
			_emit(session, "linked_actor_timing_mismatch", SEVERITY_ERROR, record_path, record_id)
		elif String(entry["timing"]) != "hp_step" and entry.has("hp_step_percent"):
			_emit(session, "linked_actor_timing_mismatch", SEVERITY_ERROR, record_path, record_id)
		if not LINKED_OWNER_DEATH.has(String(entry.get("on_owner_death", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " on_owner_death")
		if not LINKED_ACTOR_DEATH.has(String(entry.get("on_actor_death", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " on_actor_death")
		var is_true: bool = bool(entry.get("is_true_target", false))
		if is_true:
			true_targets += 1
		if (String(entry.get("role", "")) == "true_actor") != is_true:
			_emit(session, "linked_actor_true_target_mismatch", SEVERITY_ERROR, record_path, record_id)
		if not _is_in_range(entry.get("max_count", 1), 1, 12):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " max_count")
	if true_targets > 1:
		_emit(session, "multiple_true_actors", SEVERITY_ERROR, record_path, record_id)
	if (record.get("aftermath", {}) as Dictionary).get("effect_ids", []).is_empty():
		_emit(session, "enemy_without_aftermath", SEVERITY_ERROR, record_path, record_id)
	if record.has("lore_ref") and not (record.get("seed_ids", []) as Array).has(String(record["lore_ref"])):
		_emit(session, "lore_ref_not_in_seed_ids", SEVERITY_ERROR, record_path, record_id)
	var telegraph: Variant = record.get("telegraph", {})
	if telegraph is Dictionary:
		var channels: Array = telegraph.get("channels", []) if telegraph.get("channels", []) is Array else []
		if channels.is_empty():
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " telegraph channels")
		for channel: Variant in channels:
			if not TELEGRAPH_CHANNELS.has(String(channel)):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " telegraph channel")
		_check_art_key(session, record_path, record_id, "telegraph.signature_tell_key", telegraph.get("signature_tell_key", ""))
	var reward: Variant = record.get("reward", {})
	if reward is Dictionary and reward.has("access_key"):
		var access_key: String = String(reward["access_key"])
		if not access_key.begins_with("gate_g") and not access_key.begins_with("equipment_"):
			_emit(session, "unknown_access_key", SEVERITY_ERROR, record_path, record_id)
	for key: String in ["equipment_ids", "item_ids"]:
		var list: Array = reward.get(key, []) if reward is Dictionary and reward.get(key, []) is Array else []
		if list.size() > 4:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " reward." + key)


static func _validate_encounter(session: _Session, record_path: String, record: Dictionary) -> void:
	var record_id: String = String(record.get("id", ""))
	_check_text(session, record_path, record_id, "display_name", record.get("display_name", ""), MAX_AUDIT_NOTE_LENGTH)
	var context: Variant = record.get("context", {})
	if not context is Dictionary or not _has_only_keys(context, ["region_id", "region_secondary", "region_role", "depth_band", "story_stage", "time_of_day"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " context key")
	elif not ENCOUNTER_DEPTH_BANDS.has(String(context.get("story_stage", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " story_stage")
	else:
		if not _is_in_range(context.get("depth_band", 0), 0, 20):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " depth_band")
		if not TIME_OF_DAY.has(String(context.get("time_of_day", "any"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " time_of_day")
		if context.has("region_secondary") and String(context["region_secondary"]) == String(context.get("region_id", "")):
			_emit(session, "self_region_link", SEVERITY_ERROR, record_path, record_id)
	_validate_encounter_activation(session, record_path, record_id, record)
	_validate_encounter_roster(session, record_path, record_id, record)
	_validate_encounter_region_legality(session, record_path, record_id, record)
	_validate_encounter_outcome(session, record_path, record_id, record)
	_validate_encounter_repeat(session, record_path, record_id, record)
	var pressure: Array = record.get("clock_pressure", []) if record.get("clock_pressure", []) is Array else []
	if pressure.size() > 6:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " clock_pressure")
	var per_clock: Dictionary = {}
	for entry: Variant in pressure:
		if not entry is Dictionary:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " clock_pressure")
			continue
		var clock_id: String = String(entry.get("clock_id", ""))
		if not CLOCK_STAGE_TOKENS.has(clock_id):
			_emit(session, "clock_not_canonical", SEVERITY_ERROR, record_path, record_id + " " + clock_id)
		for key: String in ["ticks_on_start", "ticks_per_window", "ticks_on_end"]:
			if not _is_in_range(entry.get(key, 0), 0, 9):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " " + key)
		if int(entry.get("ticks_on_start", 0)) == 0 and int(entry.get("ticks_per_window", 0)) == 0 and int(entry.get("ticks_on_end", 0)) == 0:
			_emit(session, "clock_pressure_null_entry", SEVERITY_ERROR, record_path, record_id)
		per_clock[clock_id] = int(per_clock.get(clock_id, 0)) + int(entry.get("ticks_per_window", 0))
	for clock_id: String in per_clock:
		if int(per_clock[clock_id]) > 3:
			_emit(session, "clock_pressure_overload", SEVERITY_ERROR, record_path, record_id + " " + clock_id)
	var allow: Variant = record.get("allow", {})
	if allow is Dictionary:
		for key: String in ["parley_encounter_id", "noncombat_encounter_id"]:
			if allow.has(key) and String(allow[key]) == record_id:
				_emit(session, "encounter_self_reference", SEVERITY_ERROR, record_path, record_id)
	if record.has("base_encounter_id") and record["base_encounter_id"] != null:
		if (record.get("variant_overrides", {}) as Dictionary).is_empty():
			_emit(session, "remix_without_override", SEVERITY_ERROR, record_path, record_id)
		if String(record["base_encounter_id"]) == record_id:
			_emit(session, "remix_self_base", SEVERITY_ERROR, record_path, record_id)
	elif not (record.get("variant_overrides", {}) as Dictionary).is_empty():
		_emit(session, "override_without_base", SEVERITY_ERROR, record_path, record_id)
	if record.has("group") and record["group"] != null:
		var group: Variant = record["group"]
		if not group is Dictionary or not group.has("group_id") or not group.has("anchor_enemy_id"):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " group")
		else:
			var group_id: String = String(group["group_id"])
			if session.group_ids.has(group_id):
				_emit(session, "duplicate_group_id", SEVERITY_ERROR, record_path, group_id)
			session.group_ids[group_id] = record_id
			var anchors: Array = record.get("roster", []) if record.get("roster", []) is Array else []
			var found: bool = false
			for anchor: Variant in anchors:
				if anchor is Dictionary and String(anchor.get("enemy_id", "")) == String(group["anchor_enemy_id"]):
					found = true
			if not found:
				_emit(session, "group_anchor_not_in_roster", SEVERITY_ERROR, record_path, record_id)
	elif record.has("group_id") or record.has("anchor_enemy_id"):
		_emit(session, "group_field_on_null", SEVERITY_ERROR, record_path, record_id)
	var world_effect: Variant = record.get("world_effect", {})
	if world_effect is Dictionary and not (world_effect.get("unlock_gate_ids", []) as Array).is_empty():
		for gate_id: Variant in world_effect["unlock_gate_ids"]:
			if not String(gate_id).begins_with("gate_g"):
				_emit(session, "unknown_gate_id", SEVERITY_ERROR, record_path, record_id)
	if record.has("lore_ref") and not (record.get("seed_ids", []) as Array).has(String(record["lore_ref"])):
		_emit(session, "lore_ref_not_in_seed_ids", SEVERITY_ERROR, record_path, record_id)


static func _validate_encounter_activation(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var activation: Variant = record.get("activation", {})
	if not activation is Dictionary or not ENCOUNTER_ACTIVATION_KINDS.has(String(activation.get("kind", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " activation")
		return
	var kind: String = String(activation["kind"])
	var required: Dictionary = {
		"field_trigger": "prop_id", "quest_add": "prop_id", "npc_conversion": "npc_id",
		"boss_gate": "gate_id", "remix": "base_encounter_id",
	}
	var forbidden: Array[String] = []
	match kind:
		"field_trigger", "quest_add":
			forbidden = ["gate_id", "npc_id", "base_encounter_id"]
		"npc_conversion":
			forbidden = ["prop_id", "gate_id", "base_encounter_id"]
		"boss_gate":
			forbidden = ["prop_id", "npc_id", "base_encounter_id"]
		"remix":
			forbidden = ["prop_id", "gate_id", "npc_id"]
		"scripted":
			forbidden = ["prop_id", "gate_id", "npc_id", "base_encounter_id"]
	if required.has(kind) and not activation.has(String(required[kind])):
		_emit(session, "activation_key_mismatch", SEVERITY_ERROR, record_path, record_id + " " + kind)
	for key: String in forbidden:
		if activation.has(key):
			_emit(session, "activation_key_mismatch", SEVERITY_ERROR, record_path, "activation_key_mismatch")
	var warning: Variant = activation.get("warning", {})
	if warning is Dictionary:
		if not WARNING_CHANNELS.has(String(warning.get("channel", "none"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " warning channel")
		elif String(warning["channel"]) != "none" and not _is_in_range(warning.get("windows_before", 0), 0, 3):
			_emit(session, "warning_without_timing", SEVERITY_ERROR, record_path, record_id)
	if not activation.get("eligibility", {}) is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " eligibility")


static func _validate_encounter_region_legality(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	# `05` §2 assigns every family a base region, and `06` §5 lists
	# `enemy_region_mismatch` as a hard error. An encounter may only field an enemy
	# whose authored base/secondary region reaches the encounter's own region set.
	var context: Dictionary = record.get("context", {}) if record.get("context", {}) is Dictionary else {}
	var allowed: Array[String] = []
	for key: String in ["region_id", "region_secondary"]:
		var region_id: String = String(context.get(key, ""))
		if region_id.begins_with("region_") and not allowed.has(region_id):
			allowed.append(region_id)
	for entry: Variant in record.get("roster", []) if record.get("roster", []) is Array else []:
		if not entry is Dictionary:
			continue
		var enemy_id: String = String((entry as Dictionary).get("enemy_id", ""))
		if not enemy_id.begins_with("enemy_"):
			continue
		var enemy: Dictionary = session.catalog.record(enemy_id)
		if enemy.is_empty():
			continue
		var enemy_role: Dictionary = enemy.get("role", {}) if enemy.get("role", {}) is Dictionary else {}
		var reach: Array[String] = []
		for key: String in ["base_region_id", "region_secondary"]:
			var region_id: String = String(enemy_role.get(key, ""))
			if region_id.begins_with("region_") and not reach.has(region_id):
				reach.append(region_id)
		var shared: bool = false
		for region_id: String in reach:
			if allowed.has(region_id):
				shared = true
				break
		if not shared:
			_emit(session, "enemy_region_mismatch", SEVERITY_ERROR, record_path, record_id + " " + enemy_id + " " + ",".join(reach))


static func _validate_encounter_roster(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var roster: Array = record.get("roster", []) if record.get("roster", []) is Array else []
	if roster.is_empty() or roster.size() > 12:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " roster")
	var entry_seen: Dictionary = {}
	var priority_seen: Dictionary = {}
	for entry: Variant in roster:
		if not entry is Dictionary or not _has_only_keys(entry, ["entry_id", "enemy_id", "count", "count_variant", "loadout_ids", "target_priority", "spawn_at"]):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " roster entry key")
			continue
		var entry_id: String = String(entry.get("entry_id", ""))
		if not is_snake_token(entry_id) or entry_seen.has(entry_id):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " entry_id")
			continue
		entry_seen[entry_id] = true
		if not String(entry.get("enemy_id", "")).begins_with("enemy_"):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " enemy_id")
		if not SPAWN_POINTS.has(String(entry.get("spawn_at", "start"))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " spawn_at")
		var count: int = int(entry.get("count", 1)) if _is_integer(entry.get("count")) else 0
		var variant_count: int = int(entry.get("count_variant", 0)) if _is_integer(entry.get("count_variant")) else 0
		if not _is_in_range(entry.get("count", 1), 1, 12) or not _is_in_range(entry.get("count_variant", 0), 0, 8):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " roster count")
		elif count + variant_count > 12:
			_emit(session, "roster_cap_exceeded", SEVERITY_ERROR, record_path, record_id)
		if not _is_in_range(entry.get("target_priority", 1), 1, 99):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " target_priority")
		elif priority_seen.has(int(entry["target_priority"])):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
		else:
			priority_seen[int(entry["target_priority"])] = true
		for loadout: Variant in entry.get("loadout_ids", []) if entry.get("loadout_ids", []) is Array else []:
			if not String(loadout).begins_with("equipment_"):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " loadout_id")
	for priority: Variant in record.get("target_priority", []) if record.get("target_priority", []) is Array else []:
		if not priority is Dictionary or not TARGET_PRIORITY_ROLES.has(String(priority.get("role", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " target_priority role")
			continue
		if not _is_in_range(priority.get("priority", 1), 1, 99):
			_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " target priority")
		if (priority.get("only_when", {}) as Dictionary).is_empty():
			pass
	for role_entry: Variant in record.get("target_roles", []) if record.get("target_roles", []) is Array else []:
		if not role_entry is Dictionary or not TARGET_ROLES.has(String(role_entry.get("role", ""))):
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " target_roles")
			continue
		var role_name: String = String(role_entry["role"])
		var surface: String = String(role_entry.get("surface_id", ""))
		if role_name == "record" and not bool(role_entry.get("descendants_only", false)):
			_emit(session, "target_role_not_descendant_only", SEVERITY_ERROR, record_path, record_id)
		if role_name == "record" and not (surface.begins_with("doc_") or surface.begins_with("prop_")):
			_emit(session, "target_role_surface_mismatch", SEVERITY_ERROR, record_path, record_id)
		if role_name == "route" and not surface.begins_with("gate_g"):
			_emit(session, "target_role_surface_mismatch", SEVERITY_ERROR, record_path, record_id)
		if role_name == "resource_node" and not (surface.begins_with("prop_") or surface.begins_with("res_")):
			_emit(session, "target_role_surface_mismatch", SEVERITY_ERROR, record_path, record_id)


static func _validate_encounter_outcome(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var outcome: Variant = record.get("outcome", {})
	if not outcome is Dictionary or not _has_only_keys(outcome, ["on_victory", "on_escape", "on_failure", "on_parley"]):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " outcome key")
		return
	var victory: Variant = outcome.get("on_victory", {})
	if not victory is Dictionary or (victory.get("effect_ids", []) as Array).is_empty():
		_emit(session, "encounter_without_world_effect", SEVERITY_ERROR, record_path, record_id)
	var failure: Variant = outcome.get("on_failure", {})
	if not failure is Dictionary or not DEATH_POLICIES.has(String(failure.get("death_policy", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " death_policy")
	elif String(failure["death_policy"]) == "recover_event":
		if not String(failure.get("recovery_event_id", "")).begins_with("rec_"):
			_emit(session, "death_policy_recovery_mismatch", SEVERITY_ERROR, record_path, record_id)
	elif failure.has("recovery_event_id"):
		_emit(session, "death_policy_recovery_mismatch", SEVERITY_ERROR, record_path, record_id)
	var allow: Variant = record.get("allow", {})
	if allow is Dictionary and allow.has("parley_encounter_id") \
		and (outcome.get("on_parley", {}) as Dictionary).get("effect_ids", []).is_empty():
		_emit(session, "parley_without_consequence", SEVERITY_ERROR, record_path, record_id)
	var world_effect: Variant = record.get("world_effect", {})
	if world_effect is Dictionary and world_effect.is_empty() and not (victory as Dictionary).get("effect_ids", []).is_empty():
		_emit(session, "encounter_without_world_change", SEVERITY_WARNING, record_path, record_id)


static func _validate_encounter_repeat(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	var repeat: Variant = record.get("repeat", {})
	if not repeat is Dictionary or not REPEAT_POLICIES.has(String(repeat.get("policy", ""))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " repeat")
		return
	var policy: String = String(repeat["policy"])
	if not RESET_POLICIES.has(String(repeat.get("reset_policy", "none"))):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " reset_policy")
	if not _is_in_range(repeat.get("cooldown_windows", 0), 0, 99):
		_emit(session, "number_out_of_range", SEVERITY_ERROR, record_path, record_id + " repeat.cooldown_windows")
	var scaling: Variant = repeat.get("depth_scaling", {})
	if not scaling is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " depth_scaling")
		return
	var max_bands: int = int(scaling.get("max_bands", 0)) if _is_integer(scaling.get("max_bands")) else 0
	var per_band: Variant = scaling.get("per_band", {})
	if not per_band is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " per_band")
		return
	if max_bands == 0 and not per_band.is_empty():
		_emit(session, "depth_scaling_without_bands", SEVERITY_ERROR, record_path, record_id)
	if max_bands > 0 and per_band.is_empty():
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	if policy == "once" and (String(repeat.get("reset_policy", "none")) != "none" or max_bands != 0):
		_emit(session, "repeat_policy_mismatch", SEVERITY_ERROR, record_path, record_id)
	if policy == "once_per_run" and max_bands != 0:
		_emit(session, "repeat_policy_mismatch", SEVERITY_ERROR, record_path, record_id)
	if policy == "repeatable" and String(repeat.get("reset_policy", "none")) == "none":
		_emit(session, "repeatable_without_reset", SEVERITY_ERROR, record_path, record_id)
	if policy == "escalating" and max_bands < 1:
		_emit(session, "repeat_policy_mismatch", SEVERITY_ERROR, record_path, record_id)
	var remix: Variant = record.get("remix_eligibility", {})
	if remix is Dictionary:
		if not remix.get("condition", {}) is Dictionary:
			_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " remix condition")
		if (remix.get("condition", {}) as Dictionary).is_empty() and not bool(remix.get("requires_postgame", false)):
			_emit(session, "remix_always_on", SEVERITY_WARNING, record_path, record_id)


static func _resolve_references(session: _Session) -> void:
	var catalog: Catalog = session.catalog
	for record_id: String in catalog.ids_of_kind("regions"):
		_resolve_region_references(session, catalog.record(record_id), record_id)
	for record_id: String in catalog.ids_of_kind("npcs"):
		_resolve_npc_references(session, catalog.record(record_id), record_id)
	for record_id: String in catalog.ids_of_kind("conversations"):
		_resolve_conversation_references(session, catalog.record(record_id), record_id)
	for record_id: String in catalog.ids_of_kind("documents"):
		_resolve_document_references(session, catalog.record(record_id), record_id)
	for record_id: String in catalog.ids_of_kind("enemies"):
		_resolve_enemy_references(session, catalog.record(record_id), record_id)
	for record_id: String in catalog.ids_of_kind("encounters"):
		_resolve_encounter_references(session, catalog.record(record_id), record_id)
	for record_id: String in catalog.ids_of_kind("actions"):
		_resolve_action_references(session, catalog.record(record_id), record_id)
	for record_id: String in catalog.ids_of_kind("items") + catalog.ids_of_kind("equipment"):
		_resolve_grant_references(session, catalog.record(record_id), record_id)
	var entry_region: Dictionary = catalog.record(catalog.entry_region_id)
	if entry_region.is_empty():
		_emit(session, "entry_region_not_hub", SEVERITY_ERROR, "index.json", catalog.entry_region_id)
	elif String(entry_region.get("region_role", "")) != HUB_REGION_ROLE:
		_emit(session, "entry_region_not_hub", SEVERITY_ERROR, catalog.entry_region_id, "entry_region_not_hub")
	_resolve_seed_bindings(session, catalog)
	var signature_parts: Array = []
	for record_id: String in catalog.ids_of_kind("regions") + catalog.ids_of_kind("npcs") + catalog.ids_of_kind("enemies") \
		+ catalog.ids_of_kind("encounters") + catalog.ids_of_kind("actions"):
		signature_parts.append(record_id)
	var signature_source: String = "\n".join(PackedStringArray(signature_parts))
	catalog.content_signature = signature_source.sha256_text().left(16)


static func _resolve_region_references(session: _Session, record: Dictionary, record_id: String) -> void:
	var catalog: Catalog = session.catalog
	_require_kind(session, "region", String((record.get("entry", {}) as Dictionary).get("from_region_id", "")), record_id, "entry.from_region_id", true)
	_require_kind(session, "gate", String((record.get("entry", {}) as Dictionary).get("gate_id", "")), record_id, "entry.gate_id", true)
	_catalog_edge(session, String((record.get("entry", {}) as Dictionary).get("edge_id", "")), record_id, "entry.edge_id")
	for exit_entry: Variant in record.get("exits", []) if record.get("exits", []) is Array else []:
		if not exit_entry is Dictionary:
			continue
		_require_kind(session, "region", String(exit_entry.get("to_region_id", "")), record_id, "exits.to_region_id", false)
		_catalog_edge(session, String(exit_entry.get("edge_id", "")), record_id, "exits.edge_id")
		_require_kind(session, "gate", String(exit_entry.get("gate_id", "")), record_id, "exits.gate_id", true)
		_require_kind(session, "effect", String(exit_entry.get("unlock_effect_id", "")), record_id, "exits.unlock_effect_id", true)
	for clock_entry: Variant in record.get("clocks", []) if record.get("clocks", []) is Array else []:
		if clock_entry is Dictionary:
			_require_kind(session, "clocks", String(clock_entry.get("clock_id", "")), record_id, "clocks.clock_id", false)
	for resident: Variant in record.get("residents", []) if record.get("residents", []) is Array else []:
		if resident is Dictionary:
			_require_kind(session, "npcs", String(resident.get("npc_id", "")), record_id, "residents.npc_id", false)
	var cluster: Variant = record.get("initial_cluster", {})
	if cluster is Dictionary:
		_require_kind(session, "conversation", String(cluster.get("starting_conversation_id", "")), record_id, "starting_conversation_id", true)
		for npc_id: Variant in cluster.get("npc_ids", []) if cluster.get("npc_ids", []) is Array else []:
			_require_kind(session, "npcs", String(npc_id), record_id, "cluster.npc_ids", false)
	var combat: Variant = record.get("combat_content", {})
	if combat is Dictionary:
		for encounter_id: Variant in combat.get("encounter_ids", []) if combat.get("encounter_ids", []) is Array else []:
			_require_kind(session, "encounters", String(encounter_id), record_id, "combat_content.encounter_ids", false)
	var noncombat: Variant = record.get("noncombat_content", {})
	if noncombat is Dictionary:
		for prop_id: Variant in noncombat.get("interactable_prop_ids", []) if noncombat.get("interactable_prop_ids", []) is Array else []:
			_require_kind(session, "props", String(prop_id), record_id, "noncombat_content.interactable_prop_ids", false)
	var hidden: Variant = record.get("hidden_state", {})
	if hidden is Dictionary:
		for prop_id: Variant in hidden.get("reveal_prop_ids", []) if hidden.get("reveal_prop_ids", []) is Array else []:
			_require_kind(session, "props", String(prop_id), record_id, "hidden_state.reveal_prop_ids", false)
		for doc_id: Variant in hidden.get("reveal_document_ids", []) if hidden.get("reveal_document_ids", []) is Array else []:
			_require_kind(session, "documents", String(doc_id), record_id, "hidden_state.reveal_document_ids", false)
	for variant: Variant in record.get("revisit_variants", []) if record.get("revisit_variants", []) is Array else []:
		if variant is Dictionary:
			_require_kind(session, "conversation", String(variant.get("conversation_id", "")), record_id, "revisit.conversation_id", true)
			for prop_id: Variant in variant.get("prop_state_ids", []) if variant.get("prop_state_ids", []) is Array else []:
				_require_prop_of_region(session, catalog, String(prop_id), record_id, record_id)
	for debt: Variant in record.get("unresolved_debt", []) if record.get("unresolved_debt", []) is Array else []:
		if debt is Dictionary:
			for effect_id: Variant in debt.get("resolve_effect_ids", []) if debt.get("resolve_effect_ids", []) is Array else []:
				_require_kind(session, "effects", String(effect_id), record_id, "debt.resolve_effect_ids", false)
	for link: Variant in record.get("cross_region_links", []) if record.get("cross_region_links", []) is Array else []:
		if link is Dictionary:
			_require_kind(session, "region", String(link.get("to_region_id", "")), record_id, "cross_region_links", false)
	for seed_id: Variant in record.get("seed_ids", []) if record.get("seed_ids", []) is Array else []:
		_require_kind(session, "seeds", String(seed_id), record_id, "seed_ids", false)


static func _resolve_prop_of_region(session: _Session, catalog: Catalog, prop_id: String, region_id: String, record_id: String) -> void:
	if prop_id.is_empty():
		return
	var prop_record: Dictionary = catalog.record(prop_id)
	if prop_record.is_empty():
		_emit(session, "unknown_reference", SEVERITY_ERROR, record_id, prop_id)
	elif String(prop_record.get("region_id", "")) != region_id:
		_emit(session, "revisit_prop_foreign", SEVERITY_ERROR, record_id, prop_id)


static func _resolve_npc_references(session: _Session, record: Dictionary, record_id: String) -> void:
	for rel_id: Variant in record.get("relationship_ids", []) if record.get("relationship_ids", []) is Array else []:
		_require_kind(session, "relationships", String(rel_id), record_id, "relationship_ids", false)
	for clock_id: Variant in record.get("clock_ids", []) if record.get("clock_ids", []) is Array else []:
		_require_kind(session, "clocks", String(clock_id), record_id, "clock_ids", false)
	for verb: Variant in record.get("interaction_verbs", []) if record.get("interaction_verbs", []) is Array else []:
		if verb is Dictionary:
			_require_openable(session, String(verb.get("opens", "")), record_id, "interaction_verbs.opens")
	var profile: Variant = record.get("encounter_profile", {})
	if profile is Dictionary:
		var hostile: Variant = profile.get("as_hostile", {})
		if hostile is Dictionary:
			_require_kind(session, "encounters", String(hostile.get("encounter_id", "")), record_id, "as_hostile.encounter_id", true)
		var ally: Variant = profile.get("as_ally", {})
		if ally is Dictionary:
			_require_kind(session, "effects", String(ally.get("effect_id", "")), record_id, "as_ally.effect_id", true)
	for effect_id: Variant in record.get("survival", {}).get("on_death_effect_ids", []) if record.get("survival", {}) is Dictionary and (record["survival"].get("on_death_effect_ids", []) is Array) else []:
		_require_kind(session, "effects", String(effect_id), record_id, "on_death_effect_ids", false)
	var access: Variant = record.get("resource_access", {})
	if access is Dictionary:
		for granted: Variant in access.get("grants", []) if access.get("grants", []) is Array else []:
			_require_kind(session, "equipment", String(granted), record_id, "resource_access.grants", false)
		for denied: Variant in access.get("denies", []) if access.get("denies", []) is Array else []:
			_require_kind(session, "gate", String(denied), record_id, "resource_access.denies", false)
	for link: Variant in record.get("cross_link_ids", []) if record.get("cross_link_ids", []) is Array else []:
		_require_known(session, String(link), record_id, "cross_link_ids")
	for seed_id: Variant in record.get("seed_ids", []) if record.get("seed_ids", []) is Array else []:
		_require_kind(session, "seeds", String(seed_id), record_id, "seed_ids", false)


static func _resolve_conversation_references(session: _Session, record: Dictionary, record_id: String) -> void:
	_require_kind(session, "regions", String(record.get("region_id", "")), record_id, "region_id", false)
	if record.has("speaker_npc_id"):
		_require_kind(session, "npcs", String(record["speaker_npc_id"]), record_id, "speaker_npc_id", false)
	for choice: Variant in record.get("choices", []) if record.get("choices", []) is Array else []:
		if not choice is Dictionary:
			continue
		for key: String in ["immediate_effect_id", "delayed_effect_id"]:
			_require_kind(session, "effects", String(choice.get(key, "")), record_id, "choice." + key, true)
	for bucket: String in ["on_complete", "on_abort"]:
		var block: Variant = record.get(bucket, {})
		if block is Dictionary:
			for effect_id: Variant in block.get("effect_ids", []) if block.get("effect_ids", []) is Array else []:
				_require_kind(session, "effects", String(effect_id), record_id, bucket, false)
	for alternative: Variant in record.get("alt_conversation_ids", []) if record.get("alt_conversation_ids", []) is Array else []:
		_require_kind(session, "conversations", String(alternative), record_id, "alt_conversation_ids", false)
	_require_condition_references(session, record.get("entry_condition", {}), record_id, "entry_condition")


static func _resolve_document_references(session: _Session, record: Dictionary, record_id: String) -> void:
	_require_kind(session, "regions", String(record.get("region_id", "")), record_id, "region_id", false)
	if record.has("owner_npc_id"):
		_require_kind(session, "npcs", String(record["owner_npc_id"]), record_id, "owner_npc_id", true)
	var reached_by: String = String((record.get("availability", {}) as Dictionary).get("reached_by", ""))
	if record.has("reached_by_ref") and reached_by != "scripted":
		_require_kind(session, "props" if reached_by == "prop" else "item_or_equipment", String(record["reached_by_ref"]), record_id, "reached_by_ref", false)
	for page: Variant in record.get("pages", []) if record.get("pages", []) is Array else []:
		if page is Dictionary:
			for rule: Variant in page.get("corruption_rules", []) if page.get("corruption_rules", []) is Array else []:
				if rule is Dictionary:
					_require_condition_references(session, rule.get("trigger", {}), record_id, "corruption.trigger")
					if rule.has("replacement_seed_id"):
						_require_kind(session, "seeds", String(rule["replacement_seed_id"]), record_id, "replacement_seed_id", false)
	var post_read: Variant = record.get("post_read", {})
	if post_read is Dictionary:
		for effect_id: Variant in post_read.get("effect_ids", []) if post_read.get("effect_ids", []) is Array else []:
			_require_kind(session, "effects", String(effect_id), record_id, "post_read.effect_ids", false)
	_require_condition_references(session, (record.get("availability", {}) as Dictionary).get("condition", {}), record_id, "availability.condition")


static func _resolve_enemy_references(session: _Session, record: Dictionary, record_id: String) -> void:
	var role: Variant = record.get("role", {})
	if role is Dictionary:
		_require_kind(session, "regions", String(role.get("base_region_id", "")), record_id, "base_region_id", false)
		if role.has("region_secondary"):
			_require_kind(session, "regions", String(role["region_secondary"]), record_id, "region_secondary", false)
	for action_id: Variant in record.get("baseline_action_ids", []) if record.get("baseline_action_ids", []) is Array else []:
		_require_kind(session, "actions", String(action_id), record_id, "baseline_action_ids", false)
	if record.has("signature_action_id"):
		_require_kind(session, "actions", String(record["signature_action_id"]), record_id, "signature_action_id", false)
	for phase_id: Variant in record.get("phase_ids", []) if record.get("phase_ids", []) is Array else []:
		_require_kind(session, "phases", String(phase_id), record_id, "phase_ids", false)
	for entry: Variant in record.get("linked_actors", []) if record.get("linked_actors", []) is Array else []:
		if entry is Dictionary:
			_require_kind(session, "enemies", String(entry.get("enemy_id", "")), record_id, "linked_actors.enemy_id", false)
	var status_profile: Variant = record.get("status_profile", {})
	if status_profile is Dictionary:
		for key: String in ["innate_status_ids", "resistant_status_ids", "immune_status_ids"]:
			for status_id: Variant in status_profile.get(key, []) if status_profile.get(key, []) is Array else []:
				_require_kind(session, "statuses", String(status_id), record_id, key, false)
	var break_profile: Variant = record.get("break_profile", {})
	if break_profile is Dictionary:
		for action_id: Variant in break_profile.get("break_source_action_ids", []) if break_profile.get("break_source_action_ids", []) is Array else []:
			_require_kind(session, "actions", String(action_id), record_id, "break_source_action_ids", false)
	var reward: Variant = record.get("reward", {})
	if reward is Dictionary:
		for key: String in ["equipment_ids", "item_ids"]:
			for target: Variant in reward.get(key, []) if reward.get(key, []) is Array else []:
				_require_kind(session, "equipment" if key == "equipment_ids" else "items", String(target), record_id, "reward." + key, false)
	for effect_id: Variant in (record.get("aftermath", {}) as Dictionary).get("effect_ids", []) if record.get("aftermath", {}) is Dictionary and ((record["aftermath"].get("effect_ids", []) is Array)) else []:
		_require_kind(session, "effects", String(effect_id), record_id, "aftermath.effect_ids", false)


static func _resolve_encounter_references(session: _Session, record: Dictionary, record_id: String) -> void:
	var context: Variant = record.get("context", {})
	if context is Dictionary:
		_require_kind(session, "regions", String(context.get("region_id", "")), record_id, "context.region_id", false)
		if context.has("region_secondary"):
			_require_kind(session, "regions", String(context["region_secondary"]), record_id, "context.region_secondary", false)
	var activation: Variant = record.get("activation", {})
	if activation is Dictionary:
		_require_condition_references(session, activation.get("eligibility", {}), record_id, "activation.eligibility")
		if activation.has("base_encounter_id"):
			_require_kind(session, "encounters", String(activation["base_encounter_id"]), record_id, "base_encounter_id", false)
	for entry: Variant in record.get("roster", []) if record.get("roster", []) is Array else []:
		if entry is Dictionary:
			_require_kind(session, "enemies", String(entry.get("enemy_id", "")), record_id, "roster.enemy_id", false)
			for loadout: Variant in entry.get("loadout_ids", []) if entry.get("loadout_ids", []) is Array else []:
				_require_kind(session, "equipment", String(loadout), record_id, "roster.loadout_ids", false)
	for bucket: String in ["on_victory", "on_escape", "on_failure", "on_parley"]:
		var block: Variant = (record.get("outcome", {}) as Dictionary).get(bucket, {})
		if block is Dictionary:
			for effect_id: Variant in block.get("effect_ids", []) if block.get("effect_ids", []) is Array else []:
				_require_kind(session, "effects", String(effect_id), record_id, "outcome." + bucket, false)
	var failure: Variant = (record.get("outcome", {}) as Dictionary).get("on_failure", {})
	if failure is Dictionary and failure.has("recovery_event_id"):
		_require_kind(session, "recovery", String(failure["recovery_event_id"]), record_id, "recovery_event_id", false)
	for gate_id: Variant in (record.get("world_effect", {}) as Dictionary).get("unlock_gate_ids", []) if record.get("world_effect", {}) is Dictionary and ((record["world_effect"].get("unlock_gate_ids", []) is Array)) else []:
		_require_kind(session, "gate", String(gate_id), record_id, "world_effect.unlock_gate_ids", false)
	for source: Variant in record.get("target_priority", []) if record.get("target_priority", []) is Array else []:
		if source is Dictionary:
			_require_kind(session, "enemies", String(source.get("enemy_id", "")), record_id, "target_priority.enemy_id", false)
			_require_condition_references(session, source.get("only_when", {}), record_id, "only_when")


static func _resolve_action_references(session: _Session, record: Dictionary, record_id: String) -> void:
	var precondition: Variant = record.get("precondition", {})
	if precondition is Dictionary:
		_require_condition_references(session, precondition.get("condition", {}), record_id, "precondition.condition")
		for status_id: Variant in precondition.get("blocker_status_ids", []) if precondition.get("blocker_status_ids", []) is Array else []:
			_require_kind(session, "statuses", String(status_id), record_id, "blocker_status_ids", false)
		for phase_id: Variant in precondition.get("required_phase_ids", []) if precondition.get("required_phase_ids", []) is Array else []:
			_require_kind(session, "phases", String(phase_id), record_id, "required_phase_ids", false)
	for payload: Variant in record.get("status_payloads", []) if record.get("status_payloads", []) is Array else []:
		if payload is Dictionary:
			_require_kind(session, "statuses", String(payload.get("status_id", "")), record_id, "status_payloads.status_id", false)
	var spec: Variant = record.get("break_spec", {})
	if spec is Dictionary:
		for effect_id: Variant in spec.get("effect_ids", []) if spec.get("effect_ids", []) is Array else []:
			_require_kind(session, "effects", String(effect_id), record_id, "break_spec.effect_ids", false)
		for status_id: Variant in spec.get("status_ids", []) if spec.get("status_ids", []) is Array else []:
			_require_kind(session, "statuses", String(status_id), record_id, "break_spec.status_ids", false)
	var damage: Variant = record.get("damage_payload", {})
	if damage is Dictionary:
		for key: String in ["on_hit_payload_ids", "on_evade_payload_ids"]:
			for effect_id: Variant in damage.get(key, []) if damage.get(key, []) is Array else []:
				_require_kind(session, "effects", String(effect_id), record_id, "damage." + key, false)
	var hooks: Variant = record.get("hooks", {})
	if hooks is Dictionary:
		for key: String in HOOK_KEYS:
			for effect_id: Variant in hooks.get(key, []) if hooks.get(key, []) is Array else []:
				_require_kind(session, "effects", String(effect_id), record_id, "hooks." + key, false)
	var reactions: Variant = record.get("reactions", {})
	if reactions is Dictionary:
		for key: String in ["valid_reaction_ids", "forbidden_response_ids"]:
			for target: Variant in reactions.get(key, []) if reactions.get(key, []) is Array else []:
				_require_kind(session, "actions", String(target), record_id, "reactions." + key, false)
	if record.has("craft"):
		var craft: Variant = record["craft"]
		if craft is Dictionary:
			_require_kind(session, "statuses", String(craft.get("failure_status_id", "")), record_id, "failure_status_id", false)
			var environment: Variant = craft.get("environment_effect", {})
			if environment is Dictionary:
				for write: Variant in environment.get("clock_writes", []) if environment.get("clock_writes", []) is Array else []:
					if write is Dictionary:
						_require_kind(session, "clocks", String(write.get("clock_id", "")), record_id, "craft.clock_id", false)
		for seed_id: Variant in record.get("seed_ids", []) if record.get("seed_ids", []) is Array else []:
			_require_kind(session, "seeds", String(seed_id), record_id, "seed_ids", false)


static func _resolve_grant_references(session: _Session, record: Dictionary, record_id: String) -> void:
	if record.has("use"):
		var use: Variant = record["use"]
		if use is Dictionary:
			_require_kind(session, "actions", String(use.get("action_id", "")), record_id, "use.action_id", false)
	var grants: Variant = record.get("action_grants", {})
	if grants is Dictionary:
		for key: String in ["basic_attack_action_id", "granted_action_ids", "no_turn_action_ids"]:
			if key == "basic_attack_action_id":
				if grants.has(key):
					_require_kind(session, "actions", String(grants[key]), record_id, key, false)
			else:
				for action_id: Variant in grants.get(key, []) if grants.get(key, []) is Array else []:
					_require_kind(session, "actions", String(action_id), record_id, key, false)
	var field_keys: Variant = record.get("field_keys", {})
	if field_keys is Dictionary and field_keys.get("traversal_key", null) != null:
		var traversal: String = String(field_keys["traversal_key"])
		if not FIELD_RESOURCE_KEYS.has(traversal):
			_emit(session, "unknown_field_resource_key", SEVERITY_ERROR, record_id, traversal)
		elif DEBT_RESOURCE_KEYS.has(traversal):
			_emit(session, "debt_key_used_as_traversal", SEVERITY_ERROR, record_id, traversal)
	var acquisition: Variant = record.get("acquisition", {})
	if acquisition is Dictionary:
		var source_kind: String = String(acquisition.get("source_kind", ""))
		var expected: Dictionary = {"victory_award": "enemies", "shop": "props", "pickup": "props", "npc_gift": "npcs"}
		if expected.has(source_kind):
			_require_kind(session, String(expected[source_kind]), String(acquisition.get("source_id", "")), record_id, "acquisition.source_id", false)
		elif source_kind == "scripted" and acquisition.has("effect_id"):
			_require_kind(session, "effects", String(acquisition["effect_id"]), record_id, "acquisition.effect_id", false)
	var status_grants: Variant = record.get("status_grants", {})
	if status_grants is Dictionary:
		for key: String in ["resistant_status_ids", "immune_status_ids"]:
			for status_id: Variant in status_grants.get(key, []) if status_grants.get(key, []) is Array else []:
				_require_kind(session, "statuses", String(status_id), record_id, key, false)


static func _resolve_seed_bindings(session: _Session, catalog: Catalog) -> void:
	for record_id: String in catalog.ids_of_kind("seeds"):
		var record: Dictionary = catalog.record(record_id)
		for key: String in ["cross_link_a", "cross_link_b"]:
			var link: Variant = record.get(key, {})
			if link is Dictionary:
				_require_known(session, String(link.get("id", "")), record_id, key)
		for binding: Variant in record.get("bindings", []) if record.get("bindings", []) is Array else []:
			if binding is Dictionary:
				_require_known(session, String(binding.get("id", "")), record_id, "bindings")
		var delayed: Variant = record.get("delayed_consequence", {})
		if delayed is Dictionary and delayed.has("effect_id"):
			_require_kind(session, "effects", String(delayed["effect_id"]), record_id, "delayed_consequence.effect_id", false)
		for flag_key: Variant in _world_flag_keys_of(record):
			if not session.world_flags.has(flag_key):
				session.world_flags[flag_key] = record_id


static func _world_flag_keys_of(_record: Dictionary) -> Array:
	return []


static func _require_kind(session: _Session, kind_name: String, target_id: String, record_id: String, field_path: String, optional: bool) -> void:
	if target_id.is_empty():
		if not optional:
			_emit(session, "unknown_reference", SEVERITY_ERROR, record_id, field_path + " missing")
		return
	if kind_name == "gate":
		if not gate_is_declared(session.catalog, target_id):
			_emit(session, "unknown_gate_id", SEVERITY_ERROR, record_id, field_path + " -> " + target_id)
		return
	var resolved: String = _resolve_kind_alias(kind_name, target_id)
	var actual_kind: String = session.catalog.kind_of(resolved)
	if actual_kind.is_empty():
		_emit(session, "unknown_reference", SEVERITY_ERROR, record_id, field_path + " -> " + resolved)
		return
	if not _kind_matches(kind_name, actual_kind):
		_emit(session, "unknown_reference", SEVERITY_ERROR, record_id, field_path + " -> " + resolved + " expected " + kind_name)


static func _require_openable(session: _Session, target_id: String, record_id: String, field_path: String) -> void:
	if target_id.is_empty():
		_emit(session, "npc_verb_without_target", SEVERITY_ERROR, record_id, field_path)
		return
	var actual_kind: String = session.catalog.kind_of(target_id)
	if not ["conversations", "documents", "encounters"].has(actual_kind):
		_emit(session, "unknown_reference", SEVERITY_ERROR, record_id, field_path + " -> " + target_id)


static func _require_known(session: _Session, target_id: String, record_id: String, field_path: String) -> void:
	if target_id.is_empty() or not session.catalog.has(target_id):
		_emit(session, "unknown_reference", SEVERITY_ERROR, record_id, field_path + " -> " + target_id)


static func _resolve_kind_alias(kind_name: String, target_id: String) -> String:
	match kind_name:
		"effect":
			return target_id if target_id.begins_with("eff_") else "eff_" + target_id
		"item_or_equipment":
			return target_id
		"gate":
			return target_id
		"clocks":
			return target_id
	return target_id


static func _kind_matches(expected: String, actual: String) -> bool:
	match expected:
		"region", "regions":
			return actual == "regions"
		"npc", "npcs":
			return actual == "npcs"
		"clock", "clocks":
			return actual == "clocks"
		"effect", "effects":
			return actual == "effects"
		"status", "statuses":
			return actual == "statuses"
		"action", "actions":
			return actual == "actions"
		"equipment":
			return actual == "equipment"
		"item", "items":
			return actual == "items"
		"seed", "seeds":
			return actual == "seeds"
		"conversation", "conversations":
			return actual == "conversations"
		"document", "documents":
			return actual == "documents"
		"enemy", "enemies":
			return actual == "enemies"
		"encounter", "encounters":
			return actual == "encounters"
		"phase", "phases":
			return actual == "phases"
		"prop", "props":
			return actual == "props"
		"recovery":
			return actual == "recovery"
		"relationship", "relationships":
			return actual == "relationships"
		"item_or_equipment":
			return actual == "items" or actual == "equipment"
	return false


static func gate_is_declared(catalog: Catalog, gate_id: String) -> bool:
	if catalog == null or not is_stable_id(gate_id) or not gate_id.begins_with("gate_g"):
		return false
	if gate_id == "gate_g9" or gate_id == "gate_g10":
		return false
	for region_id: String in catalog.ids_of_kind("regions"):
		var region: Dictionary = catalog.record(region_id)
		for exit_entry: Variant in region.get("exits", []) if region.get("exits", []) is Array else []:
			if exit_entry is Dictionary and String(exit_entry.get("gate_id", "")) == gate_id:
				return true
	return false


static func _catalog_edge(session: _Session, edge_id: String, record_id: String, record_path: String) -> void:
	if edge_id.is_empty() or not is_stable_id(edge_id) or not edge_id.begins_with("route_e"):
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_id, record_path)
		return
	var declarers: Array = session.edge_owner.get(edge_id, []) if session.edge_owner.get(edge_id, []) is Array else []
	if not declarers.has(record_id):
		declarers.append(record_id)
	session.edge_owner[edge_id] = declarers


static func _check_edge_closure(session: _Session) -> void:
	var catalog: Catalog = session.catalog
	var pairs: Dictionary = {}
	var gates: Dictionary = {}
	for region_id: String in catalog.ids_of_kind("regions"):
		var region: Dictionary = catalog.record(region_id)
		var entry: Dictionary = region.get("entry", {}) if region.get("entry", {}) is Dictionary else {}
		_register_pair(pairs, String(entry.get("edge_id", "")), String(entry.get("from_region_id", "")), region_id)
		_register_gate(gates, String(entry.get("gate_id", "")), String(entry.get("from_region_id", "")), region_id)
		for exit_entry: Variant in region.get("exits", []) if region.get("exits", []) is Array else []:
			if not exit_entry is Dictionary:
				continue
			var target: String = String(exit_entry.get("to_region_id", ""))
			_register_pair(pairs, String(exit_entry.get("edge_id", "")), region_id, target)
			_register_gate(gates, String(exit_entry.get("gate_id", "")), region_id, target)
	for edge_id: String in pairs:
		var forward: Array = pairs[edge_id]
		for pair: Variant in forward:
			if not pair is Array:
				continue
			var target: String = String(pair[1])
			if not catalog.has(target):
				_emit(session, "edge_counterpart_not_in_catalog", SEVERITY_WARNING, String(edge_id), "counterpart " + target)
				continue
			var reverse_found: bool = false
			for other_edge: String in pairs:
				for other_pair: Variant in pairs[other_edge]:
					if other_pair is Array and String(other_pair[0]) == target and String(other_pair[1]) == String(pair[0]):
						reverse_found = true
			if not reverse_found:
				_emit(session, "edge_not_bidirectional", SEVERITY_ERROR, String(edge_id), String(pair[0]) + " -> " + target)
	for gate_id: String in gates:
		if CANONICAL_GATE_IDS.has(gate_id):
			continue
		var gate_pairs: Array = gates[gate_id]
		if gate_pairs.size() > 2:
			_emit(session, "gate_id_collision", SEVERITY_ERROR, String(gate_id), "gate reused across distinct route pairs")


static func _register_pair(pairs: Dictionary, edge_id: String, from_region: String, to_region: String) -> void:
	if edge_id.is_empty() or from_region.is_empty() or to_region.is_empty() or from_region == to_region:
		return
	var entries: Array = pairs.get(edge_id, []) if pairs.get(edge_id, []) is Array else []
	var pair: Array = [from_region, to_region]
	if not entries.has(pair):
		entries.append(pair)
	pairs[edge_id] = entries


static func _register_gate(gates: Dictionary, gate_id: String, from_region: String, to_region: String) -> void:
	if gate_id.is_empty() or from_region.is_empty() or to_region.is_empty():
		return
	var entries: Array = gates.get(gate_id, []) if gates.get(gate_id, []) is Array else []
	var pair: Array = [from_region, to_region]
	if not entries.has(pair):
		entries.append(pair)
	gates[gate_id] = entries


static func _require_prop_of_region(session: _Session, catalog: Catalog, prop_id: String, region_id: String, record_id: String) -> void:
	if prop_id.is_empty():
		return
	var prop_record: Dictionary = catalog.record(prop_id)
	if prop_record.is_empty():
		_emit(session, "unknown_reference", SEVERITY_ERROR, record_id, prop_id)
	elif String(prop_record.get("region_id", "")) != region_id:
		_emit(session, "revisit_prop_foreign", SEVERITY_ERROR, record_id, prop_id)


static func _require_condition_references(session: _Session, condition: Variant, record_id: String, field_path: String) -> void:
	if not condition is Dictionary:
		return
	for key: String in condition:
		var value: Variant = condition[key]
		match key:
			"all_of", "any_of":
				if value is Array:
					for child: Variant in value:
						_require_condition_references(session, child, record_id, field_path)
			"not":
				_require_condition_references(session, value, record_id, field_path)
			_:
				_require_condition_leaf(session, value, key, record_id, field_path)


static func _require_condition_leaf(session: _Session, value: Variant, leaf: String, record_id: String, field_path: String) -> void:
	if not value is Dictionary:
		return
	match leaf:
		"axis_at_least":
			if not WORLD_AXES.has(String(value.get("axis", ""))):
				_emit(session, "axis_out_of_range", SEVERITY_ERROR, record_id, field_path + " axis")
			elif not _is_axis_integer(value.get("value")):
				_emit(session, "axis_token_in_integer_field", SEVERITY_ERROR, record_id, field_path + " value")
		"clock_at_least", "clock_irreversible":
			_require_kind(session, "clocks", String(value.get("clock_id", "")), record_id, field_path, false)
			if leaf == "clock_at_least" and not _is_in_range(value.get("stage_index", 0), 0, CLOCK_TERMINAL_INDEX):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_id, field_path + " stage_index")
		"npc_state_is", "npc_present":
			_require_kind(session, "npcs", String(value.get("npc_id", "")), record_id, field_path, false)
			if leaf == "npc_state_is" and not NPC_STATE_KEYS.has(String(value.get("key", ""))):
				_emit(session, "key_error_mismatch", SEVERITY_ERROR, record_id, field_path + " key")
		"relationship_is", "relationship_visited":
			_require_kind(session, "relationships", String(value.get("relationship_id", "")), record_id, field_path, false)
			_require_kind(session, "npcs", String(value.get("target_npc_id", "")), record_id, field_path, false)
		"route_open":
			_require_kind(session, "gate", String(value.get("gate_id", "")), record_id, field_path, false)
		"prop_state_is":
			_require_kind(session, "props", String(value.get("prop_id", "")), record_id, field_path, false)
		"region_visited", "region_is":
			_require_kind(session, "regions", String(value.get("region_id", "")), record_id, field_path, false)
		"encounter_cleared":
			_require_kind(session, "encounters", String(value.get("encounter_id", "")), record_id, field_path, false)
		"document_read", "document_corrupted_at_least":
			_require_kind(session, "documents", String(value.get("document_id", "")), record_id, field_path, false)
		"choice_taken", "choice_not_taken":
			_require_kind(session, "conversations", String(value.get("conversation_id", "")), record_id, field_path, false)
		"conversation_completed":
			_require_kind(session, "conversations", String(value.get("conversation_id", "")), record_id, field_path, false)
		"recovery_done", "recovery_type_done":
			_require_kind(session, "recovery", String(value.get("recovery_event_id", "")), record_id, field_path, false)
		"effect_fired":
			_require_kind(session, "effects", String(value.get("effect_id", "")), record_id, field_path, false)
		"world_flag_is":
			if not String(value.get("key", "")).begins_with("world_"):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_id, field_path + " flag key")
		"equipment_held":
			_require_kind(session, "equipment", String(value.get("equipment_id", "")), record_id, field_path, false)
		"item_held":
			_require_kind(session, "items", String(value.get("item_id", "")), record_id, field_path, false)
		"resource_held":
			if not FIELD_RESOURCE_KEYS.has(String(value.get("resource_key", ""))):
				_emit(session, "unknown_field_resource_key", SEVERITY_ERROR, record_id, field_path + " resource_key")
		"status_present":
			_require_kind(session, "statuses", String(value.get("status_id", "")), record_id, field_path, false)
		"save_slot_count_at_least":
			if not _is_in_range(value.get("count", 0), 1, 99):
				_emit(session, "number_out_of_range", SEVERITY_ERROR, record_id, field_path + " count")


static func _emit_deferred_floors(session: _Session) -> void:
	var catalog: Catalog = session.catalog
	var clock_usage: Dictionary = {}
	for region_id: String in catalog.ids_of_kind("regions"):
		var record: Dictionary = catalog.record(region_id)
		for entry: Variant in record.get("clocks", []) if record.get("clocks", []) is Array else []:
			if entry is Dictionary:
				clock_usage[String(entry.get("clock_id", ""))] = true
	for clock_id: String in CLOCK_STAGE_TOKENS.keys():
		if not clock_usage.has(clock_id):
			_emit(session, "orphan_clock", SEVERITY_ERROR, clock_id, "orphan_clock")
	var distinct_kinds: Dictionary = {}
	for clock_id: String in catalog.ids_of_kind("clocks"):
		distinct_kinds[String(catalog.record(clock_id).get("kind", ""))] = true
	if distinct_kinds.size() < 3:
		_emit(session, "clock_diversity_insufficient", SEVERITY_ERROR, "clocks", "clock_diversity_insufficient")
	var mana_profiles: Dictionary = {}
	for npc_id: String in catalog.ids_of_kind("npcs"):
		var record: Dictionary = catalog.record(npc_id)
		if record.has("mana_profile"):
			mana_profiles[String(record["mana_profile"])] = true
	if mana_profiles.size() < 4:
		_emit(session, "mana_profile_diversity_insufficient", SEVERITY_ERROR, "npcs", "mana_profile_diversity_insufficient")
	var floor_roles: Dictionary = {}
	for equipment_id: String in catalog.ids_of_kind("equipment"):
		floor_roles[String(catalog.record(equipment_id).get("floor_role", ""))] = true
	for floor_role: String in EQUIPMENT_FLOOR_ROLES:
		if not floor_roles.has(floor_role):
			_emit(session, "equipment_floor_role_missing", SEVERITY_WARNING, "equipment", floor_role)
	var seeded: int = catalog.count_of_kind("seeds")
	for deferred_code: String in DEFERRED_FLOORS:
		_emit(session, DEFERRED_FLOOR_CODE, SEVERITY_WARNING, "catalog", deferred_code)
	if seeded == 0:
		_emit(session, "ledger_incomplete", SEVERITY_ERROR, "seeds", "ledger_incomplete")


static func _finalize(session: _Session, valid: bool) -> void:
	var diagnostics: Array = session.result.diagnostics
	if not valid:
		session.result.outcome = OUTCOME_CONTENT_UNAVAILABLE
	elif diagnostics.is_empty():
		session.result.outcome = OUTCOME_OK
	else:
		session.result.outcome = OUTCOME_READY_WITH_DEFECTS
	var has_error: bool = false
	for entry: Diagnostic in diagnostics:
		if entry.is_error():
			has_error = true
			break
	if has_error and session.result.outcome == OUTCOME_OK:
		session.result.outcome = OUTCOME_READY_WITH_DEFECTS


static func _emit(session: _Session, code: String, severity: String, path: String, detail: String) -> void:
	session.result.diagnostics.append(Diagnostic.new(code, severity, path, detail))


static func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


static func parse_json_document(text: String) -> Variant:
	if text.is_empty():
		return null
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return null
	return parser.data if is_json_safe(parser.data) else null


static func is_json_safe(value: Variant, depth: int = 0) -> bool:
	if depth > MAX_JSON_DEPTH:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_ARRAY:
			for element: Variant in value:
				if not is_json_safe(element, depth + 1):
					return false
			return true
		TYPE_DICTIONARY:
			for key: Variant in value:
				if not key is String or not is_json_safe(value[key], depth + 1):
					return false
			return true
	return false


static func _is_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))


static func _is_axis_integer(value: Variant) -> bool:
	return _is_integer(value) and int(value) >= AXIS_MIN and int(value) <= AXIS_MAX


static func _is_in_range(value: Variant, minimum: int, maximum: int) -> bool:
	return _is_integer(value) and int(value) >= minimum and int(value) <= maximum


static func _has_only_keys(value: Dictionary, allowed: Array) -> bool:
	for key: Variant in value.keys():
		if not key is String or not allowed.has(String(key)):
			return false
	return true


static func _has_all_keys(value: Dictionary, required: Array) -> bool:
	for key: Variant in required:
		if not value.has(String(key)):
			return false
	return true


static func _check_text(session: _Session, record_path: String, record_id: String, field_path: String, value: Variant, maximum: int) -> void:
	if not value is String or String(value).strip_edges().is_empty():
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, "invalid_schema")
	elif String(value).length() > maximum:
		_emit(session, "string_too_long", SEVERITY_ERROR, record_path, record_id + " " + field_path)


static func _check_art_key(session: _Session, record_path: String, record_id: String, field_path: String, value: Variant) -> void:
	if value is String and not String(value).is_empty() and String(value).length() > MAX_ART_KEY_LENGTH:
		_emit(session, "string_too_long", SEVERITY_ERROR, record_path, record_id + " " + field_path)


static func _check_seed_grounding(session: _Session, record_path: String, record_id: String, record: Dictionary) -> void:
	if record.has("seed_ids"):
		for seed_id: Variant in record["seed_ids"]:
			if not String(seed_id).begins_with("seed_s"):
				_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " seed_id")
	elif not record.has("audit_note") and record.get("kind", "") != "" and not record.has("lore_ref"):
		_emit(session, "ungrounded_record", SEVERITY_ERROR, record_path, record_id)


static func _condition_has_leaf(condition: Variant, leaf: String) -> bool:
	if not condition is Dictionary:
		return false
	if condition.has(leaf):
		return true
	for key: String in ["all_of", "any_of"]:
		for child: Variant in condition.get(key, []) if condition.get(key, []) is Array else []:
			if _condition_has_leaf(child, leaf):
				return true
	if condition.has("not"):
		return _condition_has_leaf(condition["not"], leaf)
	return false


static func _validate_presentation_block(session: _Session, record_path: String, record_id: String, block: Variant, allowed: Array[String]) -> void:
	if block == null or (block is Dictionary and (block as Dictionary).is_empty()):
		return
	if not block is Dictionary:
		_emit(session, "invalid_schema", SEVERITY_ERROR, record_path, record_id + " presentation")
		return
	if not _has_only_keys(block, allowed):
		_emit(session, "content_holds_presentation_value", SEVERITY_ERROR, record_path, record_id + " presentation key")


static func _id_set(values: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not values is Array:
		return result
	for value: Variant in values:
		result[String(value)] = true
	return result


static func _token_set(values: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not values is Array:
		return result
	for value: Variant in values:
		result[String(value)] = true
	return result


static func _merge_sets(base: Dictionary, other: Dictionary) -> Dictionary:
	for key: String in other:
		base[key] = true
	return base


static func actions_for_owner(catalog: Catalog, owner_action_ids: Array) -> Array:
	var result: Array = []
	for action_id: Variant in owner_action_ids:
		var record: Dictionary = catalog.record(String(action_id))
		if not record.is_empty():
			result.append(record)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _action_sort_key(a) < _action_sort_key(b)
	)
	return result


static func _action_sort_key(record: Dictionary) -> String:
	return String(record.get("category", "zz")) + "|" + str(int(record.get("order", 0))).pad_zeros(3) + "|" + String(record.get("id", ""))


static func available_actions(catalog: Catalog, actor: Object) -> Array:
	var result: Array = []
	for record_id: String in catalog.ids_of_kind("actions"):
		var record: Dictionary = catalog.record(record_id)
		if String(record.get("owner", "")) != "player" and String(record.get("owner", "")) != String(actor.get("side")):
			continue
		result.append(record)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _action_sort_key(a) < _action_sort_key(b)
	)
	return result


static func evaluate_condition(condition: Variant, state: TopDownActionRpgGameState, catalog: Catalog, depth: int = 0) -> bool:
	if depth > MAX_CONDITION_DEPTH:
		return false
	if not condition is Dictionary:
		return false
	var leaves: int = 0
	if condition.has("all_of"):
		leaves += (condition["all_of"] as Array).size() if condition["all_of"] is Array else 1
		if not condition["all_of"] is Array:
			return false
		for child: Variant in condition["all_of"]:
			if not evaluate_condition(child, state, catalog, depth + 1):
				return false
		return true
	if condition.has("any_of"):
		if not condition["any_of"] is Array or (condition["any_of"] as Array).is_empty():
			return false
		for child: Variant in condition["any_of"]:
			leaves += 1
			if evaluate_condition(child, state, catalog, depth + 1):
				return true
		return false
	if condition.has("not"):
		return not evaluate_condition(condition["not"], state, catalog, depth + 1)
	if condition.is_empty():
		return true
	if leaves > MAX_CONDITION_LEAVES:
		return false
	for leaf: String in CONDITION_LEAVES:
		if condition.has(leaf):
			return _evaluate_leaf(condition[leaf], leaf, state, catalog)
	return false


static func _evaluate_leaf(leaf: Variant, name: String, state: TopDownActionRpgGameState, catalog: Catalog) -> bool:
	if not leaf is Dictionary or state == null:
		return false
	match name:
		"axis_at_least":
			return state.axis_value(String(leaf.get("axis", ""))) >= int(leaf.get("value", 0))
		"clock_at_least":
			return state.clock_stage(state.region_id(), String(leaf.get("clock_id", ""))) >= int(leaf.get("stage_index", 0))
		"clock_irreversible":
			return state.clock_is_irreversible(state.region_id(), String(leaf.get("clock_id", "")))
		"npc_state_is":
			return String(state.npc_state(String(leaf.get("npc_id", ""))).get(String(leaf.get("key", "")), "")) == String(leaf.get("value", ""))
		"npc_present":
			return String(state.npc_state(String(leaf.get("npc_id", ""))).get("presence", "")) == String(leaf.get("presence", ""))
		"relationship_is":
			return state.relationship_state(String(leaf.get("relationship_id", ""))) == String(leaf.get("state_id", ""))
		"relationship_visited":
			var record: Dictionary = state.npc_state(String(leaf.get("target_npc_id", "")))
			var relationships: Dictionary = state.world.get("relationships", {})
			var rel_record: Variant = relationships.get(String(leaf.get("relationship_id", "")), {})
			if not rel_record is Dictionary:
				return false
			return (rel_record.get("visited_state_ids", []) as Array).has(String(leaf.get("state_id", "")))
		"route_open":
			var edge_id: String = _edge_of_gate(catalog, String(leaf.get("gate_id", "")))
			return not edge_id.is_empty() and state.route_state(edge_id) == "open"
		"prop_state_is":
			return state.prop_state(String(leaf.get("prop_id", ""))) == String(leaf.get("state_id", ""))
		"region_visited":
			var regions: Dictionary = state.world.get("regions", {})
			var region_record: Variant = regions.get(String(leaf.get("region_id", "")), {})
			return region_record is Dictionary and int(region_record.get("visit_count", 0)) >= maxi(1, int(leaf.get("min_visits", 1)))
		"region_is":
			return state.region_id() == String(leaf.get("region_id", ""))
		"encounter_cleared":
			var encounters: Dictionary = state.world.get("encounters", {})
			var encounter_record: Variant = encounters.get(String(leaf.get("encounter_id", "")), {})
			return encounter_record is Dictionary and int(encounter_record.get("clear_count", 0)) >= maxi(1, int(leaf.get("min_count", 1)))
		"document_read":
			return state.document_read_count(String(leaf.get("document_id", ""))) >= maxi(1, int(leaf.get("min_count", 1)))
		"document_corrupted_at_least":
			return state.document_read_count(String(leaf.get("document_id", ""))) >= 1
		"choice_taken":
			return state.choice_taken(String(leaf.get("conversation_id", "")), String(leaf.get("choice_id", "")))
		"choice_not_taken":
			return not state.choice_taken(String(leaf.get("conversation_id", "")), String(leaf.get("choice_id", "")))
		"conversation_completed":
			return bool(state.conversation_state(String(leaf.get("conversation_id", ""))).get("completed", false))
		"recovery_done":
			return _recovery_count(state, String(leaf.get("recovery_event_id", ""))) >= maxi(1, int(leaf.get("min_count", 1)))
		"effect_fired":
			return state.effect_has_fired(String(leaf.get("effect_id", "")))
		"world_flag_is":
			return state.flag_is(String(leaf.get("key", ""))) == bool(leaf.get("value", true))
		"equipment_held":
			return int(state.progression.get("equipment", {}).get(String(leaf.get("equipment_id", "")), 0)) >= maxi(1, int(leaf.get("min_count", 1)))
		"item_held":
			return state.item_count(String(leaf.get("item_id", ""))) >= maxi(1, int(leaf.get("min_count", 1)))
		"resource_held":
			return state.resource_amount(String(leaf.get("resource_key", ""))) >= maxi(1, int(leaf.get("min_count", 1)))
		"status_present":
			return int(leaf.get("stacks_at_least", 1)) >= 1
		"recovery_type_done":
			return _recovery_count(state, String(leaf.get("recovery_event_id", ""))) >= 1
		"save_slot_count_at_least":
			return maxi(1, int(leaf.get("count", 1))) >= 1
	return false


static func _recovery_count(state: TopDownActionRpgGameState, recovery_id: String) -> int:
	var history: Array = state.recovery.get("history", []) if state.recovery.get("history", []) is Array else []
	var count: int = 0
	for entry: Variant in history:
		if entry is Dictionary and String(entry.get("recovery_event_id", "")) == recovery_id:
			count += 1
	return count


static func _edge_of_gate(catalog: Catalog, gate_id: String) -> String:
	if catalog == null:
		return ""
	for region_id: String in catalog.ids_of_kind("regions"):
		var region: Dictionary = catalog.record(region_id)
		for exit_entry: Variant in region.get("exits", []) if region.get("exits", []) is Array else []:
			if exit_entry is Dictionary and String(exit_entry.get("gate_id", "")) == gate_id:
				return String(exit_entry.get("edge_id", ""))
	return ""


static func apply_effect(effect: Dictionary, state: TopDownActionRpgGameState, catalog: Catalog) -> Array:
	var applied: Array = []
	if effect.is_empty() or state == null or catalog == null:
		return applied
	var effect_id: String = String(effect.get("id", ""))
	if bool(effect.get("one_shot", false)) and state.effect_has_fired(effect_id):
		return applied
	var guard: String = String(effect.get("repeat_guard", "once"))
	if guard == "never_repeat" and state.effect_has_fired(effect_id):
		return applied
	var snapshot: Variant = state.to_dict()
	var operations: Array = effect.get("operations", []) if effect.get("operations", []) is Array else []
	for operation: Variant in operations:
		if not operation is Dictionary:
			state.from_dict(snapshot)
			return applied
		var failure: String = _apply_operation(state, catalog, operation)
		if not failure.is_empty():
			state.from_dict(snapshot)
			applied.append({"op": String(operation.get("op", "")), "result": failure})
			return applied
		applied.append({"op": String(operation.get("op", "")), "result": "applied"})
	state.mark_effect_fired(effect_id)
	state.append_commit_log({"effect_id": effect_id, "timing": String(effect.get("timing", "immediate")), "source_region_id": state.region_id()})
	return applied


static func _apply_operation(state: TopDownActionRpgGameState, catalog: Catalog, operation: Dictionary) -> String:
	match String(operation.get("op", "")):
		"set_axis":
			if not state.set_axis_value(String(operation.get("axis", "")), int(operation.get("value", 0)), String(operation.get("op", ""))):
				return "axis_out_of_range"
		"advance_clock":
			if state.advance_clock(state.region_id(), String(operation.get("clock_id", "")), int(operation.get("ticks", 1)), operation.get("op", "")) < 0:
				return "clock_not_canonical"
		"set_clock_stage":
			if state.set_clock_stage(state.region_id(), String(operation.get("clock_id", "")), TopDownActionRpgGameState.clock_stage_of_token(String(operation.get("clock_id", "")), String(operation.get("stage_id", ""))), operation.get("op", "")) < 0:
				return "clock_not_canonical"
		"npc_state":
			if not state.set_npc_state(String(operation.get("npc_id", "")), String(operation.get("key", "")), operation.get("value")):
				return "key_error_mismatch"
		"relationship":
			if not state.set_relationship_state(String(operation.get("relationship_id", "")), String(operation.get("to_state_id", ""))):
				return "effect_transition_rejected"
		"prop_state":
			if not state.set_prop_state(String(operation.get("prop_id", "")), String(operation.get("state_id", ""))):
				return "effect_transition_rejected"
		"unlock_route":
			var edge_id: String = _edge_of_gate(catalog, String(operation.get("gate_id", "")))
			if edge_id.is_empty():
				return "unknown_gate_id"
			if not state.set_route_state(edge_id, "open", String(operation.get("gate_id", ""))):
				return "route_state_outside_02_enum"
		"region_state":
			var regions: Dictionary = state.world.get("regions", {})
			var region_record: Dictionary = regions.get(String(operation.get("region_id", "")), {}) if regions.get(String(operation.get("region_id", "")), {}) is Dictionary else {}
			if region_record.is_empty():
				return "effect_transition_rejected"
			region_record["state_tag"] = String(operation.get("state_tag", ""))
			regions[String(operation["region_id"])] = region_record
			state.world["regions"] = regions
		"reveal_document":
			if catalog.record(String(operation.get("document_id", ""))).is_empty():
				return "unknown_reference"
			state.mark_document_read(String(operation.get("document_id", "")))
		"grant_equipment":
			if not state.grant_equipment(String(operation.get("equipment_id", "")), int(operation.get("count", 1))):
				return "effect_partial_failure"
		"consume_equipment":
			var owned: Dictionary = state.progression.get("equipment", {})
			if int(owned.get(String(operation.get("equipment_id", "")), 0)) < int(operation.get("count", 1)):
				return "effect_partial_failure"
			owned[String(operation["equipment_id"])] = int(owned[String(operation["equipment_id"])]) - int(operation.get("count", 1))
			state.progression["equipment"] = owned
		"grant_item":
			if not state.grant_item(String(operation.get("item_id", "")), int(operation.get("count", 1))):
				return "effect_partial_failure"
		"consume_item":
			if not state.consume_item(String(operation.get("item_id", "")), int(operation.get("count", 1))):
				return "effect_partial_failure"
		"apply_status":
			_apply_world_status(state, catalog, operation)
		"clear_status":
			_clear_world_status(state, String(operation.get("status_id", "")))
		"queue_encounter":
			_queue_encounter(state, String(operation.get("encounter_id", "")), String(operation.get("at", "immediate")))
		"queue_recovery":
			state.recovery["pending_outcome_id"] = String(operation.get("recovery_event_id", ""))
		"flag":
			if not state.set_flag(String(operation.get("key", "")), bool(operation.get("value", true))):
				return "invalid_schema"
		_:
			return "unknown_operation"
	return ""


static func _apply_world_status(state: TopDownActionRpgGameState, catalog: Catalog, operation: Dictionary) -> void:
	var status_id: String = String(operation.get("status_id", ""))
	var definition: Dictionary = catalog.record(status_id)
	if definition.is_empty():
		return
	var body: Dictionary = state.player.get("body", {}) if state.player.get("body", {}) is Dictionary else {}
	var statuses: Array = body.get("statuses", []) if body.get("statuses", []) is Array else []
	statuses.append({
		"status_id": status_id,
		"stacks": int(operation.get("stacks", 1)),
		"source": String(operation.get("target", "self")),
	})
	body["statuses"] = statuses
	state.player["body"] = body


static func _clear_world_status(state: TopDownActionRpgGameState, status_id: String) -> void:
	var body: Dictionary = state.player.get("body", {}) if state.player.get("body", {}) is Dictionary else {}
	var statuses: Array = body.get("statuses", []) if body.get("statuses", []) is Array else []
	body["statuses"] = statuses.filter(func(entry: Variant) -> bool:
		return not (entry is Dictionary and String(entry.get("status_id", "")) == status_id)
	)
	state.player["body"] = body


static func _queue_encounter(state: TopDownActionRpgGameState, encounter_id: String, at: String) -> void:
	if at == "immediate":
		state.combat["active_encounter_id"] = encounter_id
		state.set_mode("encounter_prepare")
		return
	var queued: Array = state.transaction.get("queued_encounters", []) if state.transaction.get("queued_encounters", []) is Array else []
	queued.append({"encounter_id": encounter_id, "at": at})
	state.transaction["queued_encounters"] = queued
	if at == "post_recovery":
		state.recovery["pending_outcome_id"] = encounter_id


static func take_queued_encounter(state: TopDownActionRpgGameState, at: String) -> String:
	var queued: Array = state.transaction.get("queued_encounters", []) if state.transaction.get("queued_encounters", []) is Array else []
	var kept: Array = []
	var found: String = ""
	for entry: Variant in queued:
		if entry is Dictionary and found.is_empty() and String(entry.get("at", "")) == at:
			found = String(entry.get("encounter_id", ""))
		else:
			kept.append(entry)
	state.transaction["queued_encounters"] = kept
	return found







static func catalog_file_counted(session: _Session) -> void:
	session.catalog.file_count += 1
