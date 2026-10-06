class_name PathService
extends RefCounted

var map: MapModel
var grid := AStarGrid2D.new()
var requests: int = 0

func _init(model: MapModel) -> void:
	map = model
	grid.region = Rect2i(Vector2i.ZERO, map.config.size)
	grid.cell_size = Vector2.ONE
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	grid.update()
	for cell in map.blocked:
		grid.set_point_solid(cell, true)

func set_blocked(cell: Vector2i, solid: bool) -> void:
	if not map.contains(cell):
		return
	if solid:
		map.blocked[cell] = true
	else:
		map.blocked.erase(cell)
	grid.set_point_solid(cell, solid)

func path(start: Vector2, destination: Vector2) -> PackedVector2Array:
	requests += 1
	var from := map.cell_of(start)
	var to := map.cell_of(destination)
	if not map.passable(from) or not map.contains(to):
		return PackedVector2Array()
	if not map.passable(to):
		to = nearest_open(to)
	var cells := grid.get_id_path(from, to, true)
	var result := PackedVector2Array()
	for cell in cells:
		result.append(Vector2(cell) + Vector2(0.5, 0.5))
	return result

func nearest_open(target: Vector2i) -> Vector2i:
	for radius in range(maxi(map.config.size.x, map.config.size.y)):
		for y in range(-radius, radius + 1):
			for x in range(-radius, radius + 1):
				if maxi(absi(x), absi(y)) != radius:
					continue
				var candidate := target + Vector2i(x, y)
				if map.passable(candidate):
					return candidate
	return target

func can_traverse(from: Vector2, to: Vector2) -> bool:
	var steps := maxi(1, ceili(from.distance_to(to) / 0.1))
	var previous := map.cell_of(from)
	for i in range(steps + 1):
		var cell := map.cell_of(from.lerp(to, float(i) / steps))
		if not map.passable(cell):
			return false
		if cell.x != previous.x and cell.y != previous.y:
			if not map.passable(Vector2i(previous.x, cell.y)) or not map.passable(Vector2i(cell.x, previous.y)):
				return false
		previous = cell
	return true
