class_name CommandController
extends RefCounted

var paths: PathService
var mission: MissionConfig
var projection: IsoProjection

func _init(service: PathService, config: MissionConfig) -> void:
	paths = service
	mission = config
	projection = IsoProjection.new(Vector2(mission.tile_size))

## `standing` (optional) lists every unit on the map; idle ones outside the order keep
## their spots, so new destinations are never placed on top of them.
func issue_move(units: Array[UnitMovement], destination: Vector2, standing: Array[UnitMovement] = []) -> int:
	if not paths.map.contains(paths.map.cell_of(destination)):
		return 0
	# Closest units take the central slots, so later arrivals fill the outside
	# ring instead of pushing through units that are already standing still.
	var ordered := units.duplicate()
	ordered.sort_custom(func(a: UnitMovement, b: UnitMovement) -> bool:
		return a.logical_position.distance_squared_to(destination) < b.logical_position.distance_squared_to(destination))
	var reserved: Array[Dictionary] = []
	for other in standing:
		if not units.has(other) and other.route.is_empty():
			reserved.append({"point": other.logical_position, "radius": other.stats.footprint_radius})
	var accepted := 0
	var candidates := GroupSlots.candidates(destination, maxi(25, units.size() * 16), mission.slot_spacing)
	for unit in ordered:
		for slot in candidates:
			if not paths.map.contains(paths.map.cell_of(slot)) or not fits(slot, unit, reserved):
				continue
			var route := paths.path(unit.logical_position, slot)
			if route.is_empty():
				continue
			if paths.map.passable(paths.map.cell_of(slot)) and paths.can_traverse(route[-2] if route.size() > 1 else unit.logical_position, slot):
				route[route.size() - 1] = slot # End on the slot itself, not the cell centre.
			if not fits(route[-1], unit, reserved):
				continue
			reserved.append({"point": route[-1], "radius": unit.stats.footprint_radius})
			unit.set_route(route)
			accepted += 1
			break
	return accepted

## Slots keep on-screen spacing (design px), matching UnitMovement's spacing rule.
func fits(point: Vector2, unit: UnitMovement, reserved: Array[Dictionary]) -> bool:
	for entry in reserved:
		if projection.to_iso(point - entry.point).length() < unit.stats.footprint_radius + entry.radius + 4.0:
			return false
	return true
