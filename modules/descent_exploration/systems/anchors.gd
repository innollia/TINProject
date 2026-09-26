class_name AnchorBook
extends RefCounted


static func check(state: DescentState, runtime: StratumRuntime) -> Dictionary:
	var result: Dictionary = {"anchor": "", "facts": [] as Array[String], "sites": [] as Array[String]}
	var box: Rect2 = state.body_box()
	for anchor: Dictionary in runtime.anchors:
		if bool(anchor["entered"]):
			continue
		var side: float = float(anchor["radius"])
		var area := Rect2((anchor["position"] as Vector2) - Vector2(side, side) * 0.5, Vector2(side, side))
		if not box.intersects(area):
			continue
		anchor["entered"] = true
		var key: String = StratumRuntime.anchor_key(runtime.id, String(anchor["id"]))
		if state.anchors_taken.has(key):
			continue
		state.anchors_taken.append(key)
		state.checkpoint = state.make_checkpoint(String(anchor["id"]), anchor["position"] as Vector2)
		if String(result["anchor"]).is_empty():
			result["anchor"] = String(anchor["id"])
	for site: Dictionary in runtime.sites:
		var site_id: String = String(site["id"])
		if state.sites_done.has(site_id):
			continue
		if DescentCollision.distance_to_point(box, site["position"] as Vector2) > float(site["radius"]):
			continue
		state.sites_done.append(site_id)
		(result["sites"] as Array[String]).append(site_id)
		var fact: String = String(site["grants_fact"])
		if not fact.is_empty() and state.add_fact(fact):
			(result["facts"] as Array[String]).append(fact)
	return result
