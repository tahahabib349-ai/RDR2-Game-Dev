class_name SelectionController
extends RefCounted

signal changed
var units: Array[UnitMovement] = []
var selected: Array[UnitMovement] = []
var config: GestureConfig

func _init(settings: GestureConfig) -> void:
	config = settings

func replace(next: Array[UnitMovement]) -> void:
	for unit in selected:
		unit.selected = false
	selected = next.duplicate()
	for unit in selected:
		unit.selected = true
	changed.emit()

func pick(point: Vector2, screen_of: Callable) -> UnitMovement:
	var closest: UnitMovement = null
	var best := config.tap_radius
	for unit in units:
		var distance: float = point.distance_to(screen_of.call(unit))
		if distance <= best:
			best = distance
			closest = unit
	return closest

func tap(point: Vector2, double: bool, screen_of: Callable, viewport_rect: Rect2) -> bool:
	var unit := pick(point, screen_of)
	if unit == null:
		return false
	var next: Array[UnitMovement] = [unit]
	if double:
		next.clear()
		for candidate in units:
			if candidate.stats.type_id == unit.stats.type_id and viewport_rect.has_point(screen_of.call(candidate)):
				next.append(candidate)
	replace(next)
	return true

func box(rect: Rect2, screen_of: Callable, preview: bool) -> void:
	var next: Array[UnitMovement] = []
	for unit in units:
		var inside: bool = rect.has_point(screen_of.call(unit))
		unit.previewed = inside if preview else false
		if inside:
			next.append(unit)
	if not preview and not next.is_empty():
		replace(next)

func clear_preview() -> void:
	for unit in units:
		unit.previewed = false

func all_army() -> void:
	var next: Array[UnitMovement] = []
	for unit in units:
		if unit.stats.army:
			next.append(unit)
	replace(next)
