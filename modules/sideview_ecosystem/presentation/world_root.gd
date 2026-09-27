class_name EcoWorldRoot
extends Node2D

## §5.1, §8.4. 월드 좌표계. 현재 룸 인스턴스, backdrop, player_view, creature_view
## 들을 소유하고 director 의 상태를 매 프레임 화면에 옮긴다. rung_cut 0.9초.

var backdrop: EcoBackdropRoot
var player_view: EcoPlayerView
var trail: EcoTrailRenderer
var _creature_views: Dictionary = {}
var _current_room_id: String = ""


func _ready() -> void:
	backdrop = EcoBackdropRoot.new()
	add_child(backdrop)
	trail = EcoTrailRenderer.new()
	add_child(trail)
	player_view = EcoPlayerView.new()
	add_child(player_view)


func sync(director: EcoStepDirector) -> void:
	if director == null or director.world == null:
		return
	var world: EcoWorldState = director.world
	var room: EcoRoomSpec = director.room
	if room != null and room.id != _current_room_id:
		_current_room_id = room.id
		var region: EcoRegionSpec = director.index.region_of(room.id) if director.index != null else null
		var region_index: int = region.index if region != null else 0
		backdrop.setup(director.world_seed, region_index, float(room.tiles_w) * EcoBodyRung.TILE, float(room.tiles_h) * EcoBodyRung.TILE)
		player_view.setup(director.world_seed)

	var band_value: float = director.table.band_value(world.current_band) if director.table != null else 1.0
	var rung: EcoBodyRung = director.table.by_name(world.body_rung) if director.table != null else null
	if rung != null and band_value > 0.0 and room != null:
		var derived: Dictionary = rung.derive(band_value, room.target_body_px)
		player_view.set_scale_factor(float(derived.get("h_px", 96.0)) / 96.0)
	player_view.global_position = world.position_px
	player_view.set_facing(world.facing)
	player_view.step(1.0 / 60.0)

	_sync_creatures(director)


func _sync_creatures(director: EcoStepDirector) -> void:
	var alive_ids: Dictionary = {}
	for creature_id: Variant in director.world.creatures:
		var data: Dictionary = director.world.creatures[creature_id]
		if not bool(data.get("alive", true)):
			continue
		alive_ids[creature_id] = true
		var view: EcoCreatureView = _creature_views.get(creature_id, null)
		if view == null:
			view = EcoCreatureView.new()
			add_child(view)
			view.setup(StringName(String(data.get("archetype_id", "skitter"))), director.world_seed, int(data.get("id", 0)))
			_creature_views[creature_id] = view
		var pos: Variant = data.get("pos_px", [0.0, 0.0])
		view.global_position = Vector2(float(pos[0]), float(pos[1])) if pos is Array else Vector2.ZERO
		view.step(1.0 / 60.0)
	for creature_id: Variant in _creature_views.keys():
		if not alive_ids.has(creature_id):
			var view: EcoCreatureView = _creature_views[creature_id]
			view.queue_free()
			_creature_views.erase(creature_id)


func pulse_landing(strength: float) -> void:
	backdrop.pulse(strength)


func set_view_offset(offset: Vector2) -> void:
	backdrop.set_view_offset(offset)
