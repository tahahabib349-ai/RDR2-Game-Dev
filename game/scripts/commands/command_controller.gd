class_name CommandController
extends RefCounted

var paths: PathService
var mission: MissionConfig

func _init(service: PathService, config: MissionConfig) -> void:
	paths = service
	mission = config

func issue_move(units: Array[UnitMovement], destination: Vector2) -> int:
	if not paths.map.contains(paths.map.cell_of(destination)):
		return 0
	var reserved: Array[Dictionary] = []
	var accepted := 0
	var candidates := GroupSlots.candidates(destination, maxi(25, units.size() * 9), mission.slot_spacing)
	for unit in units:
		for slot in candidates:
			if not paths.map.contains(paths.map.cell_of(slot)):
				continue
			var route := paths.path(unit.logical_position, slot)
			if route.is_empty():
				continue
			var fits := true
			for entry in reserved:
				fits = fits and route[-1].distance_to(entry.point) >= unit.stats.spacing_radius + entry.radius
			if not fits:
				continue
			reserved.append({"point": route[-1], "radius": unit.stats.spacing_radius})
			unit.set_route(route)
			accepted += 1
			break
	return accepted
