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
	var reserved: Dictionary = {}
	var accepted := 0
	var candidates := GroupSlots.candidates(destination, maxi(25, units.size() * 9), mission.slot_spacing)
	for unit in units:
		for slot in candidates:
			if not paths.map.contains(paths.map.cell_of(slot)):
				continue
			var route := paths.path(unit.logical_position, slot)
			if route.is_empty():
				continue
			var final_cell := paths.map.cell_of(route[-1])
			if reserved.has(final_cell):
				continue
			reserved[final_cell] = true
			unit.set_route(route)
			accepted += 1
			break
	return accepted
