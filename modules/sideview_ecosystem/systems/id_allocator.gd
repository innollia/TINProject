class_name EcoIdAllocator
extends RefCounted

const BASE: int = 100000
const REGION_STRIDE: int = 10000
const ROOM_STRIDE: int = 100
const SLOT_STRIDE: int = 10
const TETHER_OFFSET: int = 90


static func den_id(region_index: int, room_index: int, slot_index: int, lineage_stage: int) -> int:
	return BASE + region_index * REGION_STRIDE + room_index * ROOM_STRIDE + slot_index * SLOT_STRIDE + lineage_stage


static func tether_id(region_index: int, room_index: int, tether_index: int) -> int:
	return BASE + region_index * REGION_STRIDE + room_index * ROOM_STRIDE + TETHER_OFFSET + tether_index
