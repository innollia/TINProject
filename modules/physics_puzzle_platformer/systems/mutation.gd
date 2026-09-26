extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const MaterialTable = preload("res://modules/physics_puzzle_platformer/domain/material_table.gd")

const OPS: Array[String] = ["gravity_scale", "material_swap", "prop_size", "prop_offset", "wind", "hazard_shift"]


static func apply(spec: RefCounted, mutations: Array) -> Dictionary:
	var copy: RefCounted = spec.duplicate_spec()
	var applied: Array[Dictionary] = []
	for item: Variant in mutations:
		if not item is Dictionary:
			continue
		var op: String = String((item as Dictionary).get("op", ""))
		var arg: Variant = (item as Dictionary).get("arg", 0)
		if not OPS.has(op) or not (spec.mutable as Array).has(op) or not (arg is int or arg is float) or not is_finite(float(arg)):
			continue
		if _apply_one(copy, op, arg):
			applied.append({"op": op, "arg": arg})
	return {"spec": copy, "applied": applied}


static func _apply_one(copy: RefCounted, op: String, arg: Variant) -> bool:
	match op:
		"gravity_scale":
			if float(arg) <= 0.0:
				return false
			copy.gravity_mul = copy.gravity_mul * float(arg)
			return true
		"material_swap":
			if copy.shuffled.is_empty():
				return false
			var target: RefCounted = copy.bodies[copy.shuffled[0]]
			target.material = MaterialTable.swap_target(target.material, int(arg))
			return true
		"prop_size":
			if float(arg) <= 0.0:
				return false
			var changed: bool = false
			for body: RefCounted in copy.bodies:
				if not BodyKind.is_mutation_prop(body.kind):
					continue
				body.mass_override = body.mass()
				body.size = body.size * float(arg)
				var scaled: PackedVector2Array = PackedVector2Array()
				for point: Vector2 in body.points:
					scaled.append(point * float(arg))
				body.points = scaled
				changed = true
			return changed
		"prop_offset":
			var moved: bool = false
			var low: float = copy.bounds.position.x
			var high: float = copy.bounds.end.x
			for body: RefCounted in copy.bodies:
				if not BodyKind.is_mutation_prop(body.kind):
					continue
				var x: float = body.pos.x + float(arg)
				if x > high:
					x = high - (x - high)
				if x < low:
					x = low + (low - x)
				body.pos = Vector2(clampf(x, low, high), body.pos.y)
				moved = true
			return moved
		"wind":
			if copy.kinematics.is_empty():
				return false
			copy.wind_x = copy.wind_x + float(arg)
			return true
		"hazard_shift":
			var count: int = copy.mutable_hazards.size()
			if count < 2:
				return false
			var positions: Array[Vector2] = []
			for index: int in copy.mutable_hazards:
				positions.append(copy.bodies[index].pos)
			var step: int = 1 if int(arg) == 0 else count - 1
			for slot: int in count:
				copy.bodies[copy.mutable_hazards[slot]].pos = positions[(slot + step) % count]
			return true
	return false
