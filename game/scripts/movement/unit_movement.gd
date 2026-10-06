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
var settling: bool = false
var settle_target: Vector2

func configure(id: int, data: UnitStats, start: Vector2, iso: IsoProjection) -> void:
	entity_id = id
	stats = data
	logical_position = start
	previous_position = start
	projection = iso
	position = projection.to_iso(start)

func set_route(points: PackedVector2Array) -> void:
	route = points
	settling = false
	stuck_time = 0.0
	if not route.is_empty():
		goal = route[-1]

func tick(delta: float, paths: PathService, neighbors: Array[UnitMovement], mission: MissionConfig) -> void:
	previous_position = logical_position
	if route.is_empty():
		yield_to_traffic(delta, paths, neighbors)
		return
	if not paths.map.passable(paths.map.cell_of(route[0])):
		set_route(paths.path(logical_position, goal))
		return
	while not route.is_empty() and (logical_position.distance_to(route[0]) <= mission.arrival_distance or (route.size() > 1 and logical_position.distance_to(route[0]) <= stats.spacing_radius and paths.can_traverse(logical_position, route[1]))):
		route.remove_at(0)
	# A terrain waypoint inside an idle friend's footprint is not a resting
	# destination. Look ahead past it rather than orbiting its occupied center.
	while route.size() > 1 and occupied_waypoint(route[0], neighbors) and paths.can_traverse(logical_position, route[1]):
		route.remove_at(0)
	if route.is_empty():
		return
	var target := route[0]
	var direction := (target - logical_position).normalized()
	var step := minf(stats.speed * delta, logical_position.distance_to(target))
	var proposed := logical_position + direction * step
	if clear_step(proposed, paths, neighbors):
		logical_position = proposed
	else:
		# Local sidesteps keep AStar terrain-only. Deterministic handedness keeps
		# adjacent movers from repeatedly choosing opposite sides of each other.
		for angle in [PI / 6, -PI / 6, PI / 3, -PI / 3, PI / 2, -PI / 2]:
			proposed = logical_position + direction.rotated(angle) * step
			if clear_step(proposed, paths, neighbors):
				logical_position = proposed
				break
	if logical_position.distance_to(previous_position) < mission.arrival_distance:
		stuck_time += delta
		if stuck_time >= mission.stuck_seconds:
			set_route(paths.path(logical_position, goal))
	else:
		stuck_time = 0.0

func occupied_waypoint(point: Vector2, neighbors: Array[UnitMovement]) -> bool:
	for other in neighbors:
		if other != self and other.route.is_empty() and point.distance_to(other.logical_position) < stats.spacing_radius + other.stats.spacing_radius:
			return true
	return false

func clear_step(to: Vector2, paths: PathService, neighbors: Array[UnitMovement]) -> bool:
	if not paths.can_traverse(logical_position, to):
		return false
	for other in neighbors:
		if other == self:
			continue
		var closest := Geometry2D.get_closest_point_to_segment(other.logical_position, logical_position, to)
		var spacing := stats.spacing_radius + other.stats.spacing_radius
		# Check the entire swept segment, not just its end: fast units cannot
		# tunnel through idle units even with a long simulation step.
		if closest.distance_to(other.logical_position) < spacing - 0.00001:
			return false
		var relative_start := previous_position - other.previous_position
		var relative_end := to - other.logical_position
		if Geometry2D.get_closest_point_to_segment(Vector2.ZERO, relative_start, relative_end).length() < spacing - 0.00001:
			return false
	return true

func yield_to_traffic(delta: float, paths: PathService, neighbors: Array[UnitMovement]) -> void:
	for other in neighbors:
		if other == self or other.route.is_empty():
			continue
		var travel := (other.route[0] - other.logical_position).normalized()
		if travel == Vector2.ZERO:
			continue
		var combined := stats.spacing_radius + other.stats.spacing_radius
		var lookahead := combined + other.stats.speed * 0.5
		var end := other.logical_position + travel * lookahead
		var nearest := Geometry2D.get_closest_point_to_segment(logical_position, other.logical_position, end)
		if logical_position.distance_to(nearest) >= combined + 0.1:
			continue
		var side := travel.orthogonal()
		if (logical_position - nearest).dot(side) < 0.0:
			side = -side
		for direction in [side, -side, (logical_position - other.logical_position).normalized()]:
			var proposed: Vector2 = logical_position + direction * stats.speed * delta
			if clear_step(proposed, paths, neighbors):
				if not settling:
					settle_target = logical_position
					settling = true
				logical_position = proposed
				return
		return # Wait out nearby traffic before returning to the resting spot.
	if settling:
		var proposed := logical_position.move_toward(settle_target, stats.speed * delta)
		if clear_step(proposed, paths, neighbors):
			logical_position = proposed
		if logical_position.is_equal_approx(settle_target) or occupied_waypoint(settle_target, neighbors):
			# If a friend has come to rest in the old spot, keep the new spot.
			settling = false

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
