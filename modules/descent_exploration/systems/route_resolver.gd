class_name RouteResolver
extends RefCounted

const KINDS: Array[String] = ["always", "fact", "clearance", "carrying", "opened"]


static func requirement_met(requirement: Dictionary, state: DescentState) -> bool:
	match String(requirement.get("kind", "")):
		"always":
			return true
		"fact":
			return state.facts.has(String(requirement.get("fact", "")))
		"clearance":
			var needed: Variant = requirement.get("mass")
			if not (needed is int or needed is float):
				return false
			return state.mass >= int(needed)
		"carrying":
			return MatterLoop.first_index_with_verb(state.carried, String(requirement.get("verb", ""))) >= 0
		"opened":
			return state.sites_done.has(String(requirement.get("site_id", "")))
	return false


static func requires_met(requires: Array, state: DescentState) -> bool:
	for requirement: Variant in requires:
		if requirement is Dictionary and requirement_met(requirement as Dictionary, state):
			return true
	return false


static func blocked(route: Dictionary, state: DescentState) -> bool:
	var blocks: Variant = route.get("blocks_verb", [])
	if not blocks is Array:
		return false
	for verb: Variant in blocks as Array:
		for item: MatterItem in state.carried:
			if item.verb == String(verb):
				return true
	return false


static func is_open(route: Dictionary, state: DescentState) -> bool:
	return requires_met(route.get("requires", []) as Array, state) and not blocked(route, state)


static func evaluate(state: DescentState, runtime: StratumRuntime, body: BodyRead = null) -> Array[String]:
	var completed: Array[String] = []
	for route: Dictionary in runtime.routes:
		match String(route["kind"]):
			"descent":
				route["open"] = is_open(route, state)
			"site_route":
				var met: bool = requires_met(route["requires"] as Array, state)
				route["open"] = met
				if met and not state.sites_done.has(String(route["id"])):
					state.sites_done.append(String(route["id"]))
					completed.append(String(route["id"]))
	var mouth: String = EndingResolver.open_mouth(runtime.ending_routes(), state, body)
	for route: Dictionary in runtime.ending_routes():
		route["open"] = route["id"] == mouth
	return completed
