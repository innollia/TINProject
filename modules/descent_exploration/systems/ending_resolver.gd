class_name EndingResolver
extends RefCounted

const ENDING_IDS: Array[String] = DescentState.ENDING_IDS
const FALLBACK_ENDING: String = "ending.hollow"
const SPECIFICITY: Dictionary = {"always": 0, "clearance": 1, "opened": 2, "fact": 2, "carrying": 3}


static func route_specificity(route: Dictionary, state: DescentState) -> int:
	var best: int = -1
	for requirement: Variant in route.get("requires", []) as Array:
		if not requirement is Dictionary:
			continue
		var entry: Dictionary = requirement
		if not RouteResolver.requirement_met(entry, state):
			continue
		best = maxi(best, int(SPECIFICITY.get(String(entry.get("kind", "")), 0)))
	return best


static func open_mouth(routes: Array[Dictionary], state: DescentState) -> String:
	var chosen: String = ""
	var chosen_rank: int = -1
	for route: Dictionary in routes:
		if RouteResolver.blocked(route, state):
			continue
		var rank: int = route_specificity(route, state)
		if rank > chosen_rank:
			chosen_rank = rank
			chosen = String(route["id"])
	return chosen


static func open_mouths(routes: Array[Dictionary], state: DescentState) -> Array[String]:
	var mouths: Array[String] = []
	var single: String = open_mouth(routes, state)
	if not single.is_empty():
		mouths.append(single)
	return mouths


static func ending_for(route: Dictionary) -> String:
	var next: String = String(route.get("next", ""))
	return next if ENDING_IDS.has(next) else ""


static func fallback_ending(routes: Array[Dictionary]) -> String:
	for route: Dictionary in routes:
		for requirement: Variant in route.get("requires", []) as Array:
			if requirement is Dictionary and String((requirement as Dictionary).get("kind", "")) == "always":
				var ending: String = ending_for(route)
				if not ending.is_empty():
					return ending
	return FALLBACK_ENDING


static func make_result(state: DescentState) -> ModuleResult:
	var result := ModuleResult.new()
	result.module_id = StringName(DescentState.MODULE_ID)
	result.outcome = &"completed"
	result.data = {"ending_id": state.ending_id}
	return result
