class_name UnitMovement
extends Node2D

var entity_id: int
var stats: UnitStats
var logical_position: Vector2
var previous_position: Vector2
var projection: IsoProjection
var route := PackedVector2Array()
var selected: bool = false
var previewed: bool = false
var stuck_time: float = 0.0
var goal: Vector2

func configure(id: int, data: UnitStats, start: Vector2, iso: IsoProjection) -> void:
	entity_id = id
	stats = data
	logical_position = start
	previous_position = start
	projection = iso
	position = projection.to_iso(start)

func set_route(points: PackedVector2Array) -> void:
	route = points
	stuck_time = 0.0
	if not route.is_empty():
		goal = route[-1]

func tick(delta: float, paths: PathService, neighbors: Array[UnitMovement], mission: MissionConfig) -> void:
	previous_position = logical_position
	if route.is_empty():
		return
	if not paths.map.passable(paths.map.cell_of(route[0])):
		set_route(paths.path(logical_position, goal))
		return
	var original_route := route.duplicate()
	var budget := stats.speed * delta
	var proposed := logical_position
	while not route.is_empty() and budget > 0.0:
		var distance := proposed.distance_to(route[0])
		if distance <= mission.arrival_distance:
			route.remove_at(0)
			continue
		var travel := minf(distance, budget)
		proposed = proposed.move_toward(route[0], travel)
		budget -= travel
		if travel >= distance:
			route.remove_at(0)
	var separation := Vector2.ZERO
	for other in neighbors:
		if other == self:
			continue
		var offset := proposed - other.logical_position
		var desired := stats.spacing_radius + other.stats.spacing_radius
		if offset.length() < desired:
			var direction := offset.normalized()
			if offset.length_squared() < 0.0001:
				direction = Vector2.RIGHT if entity_id > other.entity_id else Vector2.LEFT
			# Larger units receive more right of way; no moving A* obstacles.
			var share := other.stats.spacing_radius / (stats.spacing_radius + other.stats.spacing_radius)
			separation += direction * (desired - offset.length()) * share
	var separated := proposed + separation.limit_length(stats.speed * delta) * mission.separation_strength * delta
	if paths.can_traverse(logical_position, separated):
		logical_position = separated
	elif paths.can_traverse(logical_position, proposed):
		logical_position = proposed
	else:
		route = original_route
	if logical_position.distance_to(previous_position) < mission.arrival_distance and not route.is_empty():
		stuck_time += delta
		if stuck_time >= mission.stuck_seconds:
			set_route(paths.path(logical_position, goal))
	else:
		stuck_time = 0.0

func render(alpha: float) -> void:
	position = projection.to_iso(previous_position.lerp(logical_position, alpha))
	z_index = int(position.y)
	queue_redraw()

func _draw() -> void:
	if stats == null:
		return
	if selected or previewed:
		draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 32, Color(0.35, 1.0, 0.6) if selected else Color(1, 0.9, 0.3), 2.0)
	draw_circle(Vector2(3, 3), 12.0, Color(0, 0, 0, 0.25))
	if stats.vehicle:
		draw_colored_polygon(PackedVector2Array([Vector2(-17, -8), Vector2(0, -18), Vector2(17, -8), Vector2(0, 2)]), stats.color)
	else:
		draw_circle(Vector2(0, -9), 9.0, stats.color)
	draw_string(ThemeDB.fallback_font, Vector2(-20, -24), stats.display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
