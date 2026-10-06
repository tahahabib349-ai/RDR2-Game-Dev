class_name UnitMovement
extends Node2D
## Continuous movement along terrain-only AStar routes with local avoidance.
## Spacing is measured in on-screen (isometric) design pixels, so it matches the
## art: the isometric view squashes the vertical axis, so a circle on the logical
## grid would be twice too wide on screen.
## Smoothness rules (no vibrating):
## - a blocked unit keeps sidestepping to the same side for a while (no flip-flop),
## - headings blend toward the route instead of snapping,
## - an idle unit yields once and waits for traffic to clear before walking back,
## - a unit wedged in a crowd close to its goal stops there instead of pushing.

const PX_PER_CELL_MAX := 48.0 # longest on-screen length of one logical cell is ~45 px

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
var velocity := Vector2.ZERO
var avoid_side: int = 0
var avoid_left: float = 0.0
var settling: bool = false
var settle_target: Vector2
var clear_time: float = 0.0
var yield_dir := Vector2.ZERO
## A polite move (walking back after yielding) never makes others yield and gives up when blocked.
var polite: bool = false

func configure(id: int, data: UnitStats, start: Vector2, iso: IsoProjection) -> void:
	entity_id = id
	stats = data
	logical_position = start
	previous_position = start
	projection = iso
	position = projection.to_iso(start)

func set_route(points: PackedVector2Array, is_polite: bool = false) -> void:
	route = points
	polite = is_polite
	settling = false
	yield_dir = Vector2.ZERO
	stuck_time = 0.0
	if not route.is_empty():
		goal = route[-1]

## On-screen distance (design px at zoom 1) between two logical points.
func screen_gap(a: Vector2, b: Vector2) -> float:
	return projection.to_iso(a - b).length()

func tick(delta: float, paths: PathService, neighbors: Array[UnitMovement], mission: MissionConfig) -> void:
	previous_position = logical_position
	var near := nearby(neighbors, delta)
	if route.is_empty():
		idle_tick(delta, paths, near, mission)
		return
	if not paths.map.passable(paths.map.cell_of(route[0])):
		set_route(paths.path(logical_position, goal))
		return
	advance_waypoints(paths, near, mission)
	if route.is_empty():
		finish()
		return
	var target := route[0]
	var desired := (target - logical_position).normalized()
	var step := minf(stats.speed * delta, logical_position.distance_to(target))
	var heading := velocity.normalized()
	var forward := desired
	if heading != Vector2.ZERO and heading.dot(desired) > 0.0:
		# Turn gradually toward the route instead of snapping each tick.
		forward = (heading * 0.35 + desired * 0.65).normalized()
	var side := avoid_side if avoid_side != 0 else 1
	# Order matters for smoothness: the route first, then (while avoiding) keep the
	# current heading, then a shallow sidestep (overtaking), then slow down behind
	# traffic, and only then turn sharply.
	var candidates: Array[Vector2] = []
	var scales: Array[float] = []
	var sides: Array[int] = []
	candidates.append_array([forward, desired])
	scales.append_array([1.0, 1.0])
	sides.append_array([0, 0])
	if avoid_side != 0 and heading != Vector2.ZERO and heading.dot(desired) > 0.1:
		# Mid-avoidance: carry on the way we were going (does not extend the avoidance).
		candidates.append(heading); scales.append(1.0); sides.append(0)
	candidates.append_array([desired.rotated(side * PI / 6), forward, desired.rotated(side * PI / 3), desired.rotated(side * PI / 2)])
	scales.append_array([1.0, 0.5, 1.0, 1.0])
	sides.append_array([side, 0, side, side])
	for angle in [PI / 6, PI / 3, PI / 2]:
		candidates.append(desired.rotated(-side * angle)); scales.append(1.0); sides.append(-side)
	var moved := false
	for i in candidates.size():
		var direction := candidates[i]
		var length := step * scales[i]
		if not clear_step(logical_position + direction * length, paths, near):
			continue
		# Never swing more than halfway in one tick when the in-between path is clear.
		if heading != Vector2.ZERO and heading.dot(direction) < 0.9 and heading.dot(direction) > -0.2:
			var blended := (heading + direction).normalized()
			if clear_step(logical_position + blended * length, paths, near):
				direction = blended
		logical_position += direction * length
		velocity = direction * stats.speed
		if sides[i] != 0:
			avoid_side = sides[i]
			avoid_left = mission.avoid_side_hold
		moved = true
		break
	avoid_left -= delta
	if avoid_left <= 0.0:
		avoid_side = 0
	if moved and logical_position.distance_to(previous_position) >= mission.arrival_distance * 0.5:
		stuck_time = 0.0
		return
	stuck_time += delta
	if polite and stuck_time >= mission.polite_give_up_seconds:
		route = PackedVector2Array() # Blocked on the way back: this spot will do.
		finish()
	elif stuck_time >= mission.crowd_arrive_seconds and screen_gap(goal, logical_position) <= mission.arrive_crowd_px \
			and goal_crowded(near):
		# The goal area is crowded: stop here rather than shoving in place.
		route = PackedVector2Array()
		finish()
	elif stuck_time >= mission.stuck_seconds:
		set_route(paths.path(logical_position, goal))

func advance_waypoints(paths: PathService, near: Array[UnitMovement], mission: MissionConfig) -> void:
	while not route.is_empty():
		if logical_position.distance_to(route[0]) <= mission.arrival_distance:
			route.remove_at(0)
			continue
		# Head for the farthest waypoint in a straight clear line ("string pulling").
		# AStar routes run through the same cell centres for everyone; without this,
		# a group funnels onto one line of points and wedges itself in narrow passes.
		if route.size() > 1 and logical_position.distance_to(route[1]) <= mission.path_lookahead_cells \
				and paths.can_traverse(logical_position, route[1]):
			route.remove_at(0)
			continue
		if route.size() > 1 and paths.can_traverse(logical_position, route[1]) and (
				screen_gap(route[0], logical_position) <= stats.footprint_radius or occupied(route[0], near)):
			# Close enough, or the waypoint sits inside an idle friend: look ahead.
			route.remove_at(0)
			continue
		break

## True when an idle unit is standing on our goal spot (not merely next to it).
func goal_crowded(near: Array[UnitMovement]) -> bool:
	return occupied(goal, near)

func finish() -> void:
	velocity = Vector2.ZERO
	polite = false
	avoid_side = 0
	stuck_time = 0.0
	settling = false
	yield_dir = Vector2.ZERO
	clear_time = 0.0

## Units close enough to matter this tick (cheap pre-filter for the checks below).
func nearby(neighbors: Array[UnitMovement], delta: float) -> Array[UnitMovement]:
	var result: Array[UnitMovement] = []
	var reach := stats.footprint_radius + 48.0 + stats.speed * delta * PX_PER_CELL_MAX * 2.0
	for other in neighbors:
		if other != self and screen_gap(other.logical_position, logical_position) < reach + other.stats.footprint_radius + other.stats.speed * 2.0:
			result.append(other)
	return result

func occupied(point: Vector2, near: Array[UnitMovement]) -> bool:
	for other in near:
		if other.route.is_empty() and screen_gap(point, other.logical_position) < stats.footprint_radius + other.stats.footprint_radius:
			return true
	return false

func clear_step(to: Vector2, paths: PathService, near: Array[UnitMovement]) -> bool:
	if not paths.can_traverse(logical_position, to):
		return false
	var a := projection.to_iso(logical_position)
	var b := projection.to_iso(to)
	for other in near:
		var spacing := stats.footprint_radius + other.stats.footprint_radius
		var o := projection.to_iso(other.logical_position)
		var now := a.distance_to(o)
		if now < spacing:
			# Already too close: only moves that open the gap are allowed.
			if b.distance_to(o) <= now:
				return false
			continue
		# Check the whole swept segment so fast units cannot tunnel through.
		if Geometry2D.get_closest_point_to_segment(o, a, b).distance_to(o) < spacing - 0.001:
			return false
		# The other unit may already have moved this tick: check relative motion too.
		var relative_start := projection.to_iso(previous_position - other.previous_position)
		if relative_start.length() >= spacing:
			var relative_end := b - o
			if Geometry2D.get_closest_point_to_segment(Vector2.ZERO, relative_start, relative_end).length() < spacing - 0.001:
				return false
	return true

func idle_tick(delta: float, paths: PathService, near: Array[UnitMovement], mission: MissionConfig) -> void:
	for other in near:
		if other.route.is_empty() or other.polite:
			continue
		var travel := other.route[0] - other.logical_position
		if travel.length() < 0.0001:
			continue
		travel = travel.normalized()
		var combined := stats.footprint_radius + other.stats.footprint_radius
		var end := other.logical_position + travel * (other.stats.speed * 0.6 + 0.5)
		var nearest := Geometry2D.get_closest_point_to_segment(logical_position, other.logical_position, end)
		if screen_gap(logical_position, nearest) >= combined + 4.0:
			continue
		# A mover is heading through this spot: step aside, always to the same side.
		clear_time = 0.0
		if not settling:
			settling = true
			settle_target = logical_position
		if yield_dir == Vector2.ZERO:
			yield_dir = travel.orthogonal()
			var offset := logical_position - nearest
			if offset.dot(yield_dir) < 0.0 or (offset.length() < 0.001 and entity_id % 2 == 0):
				yield_dir = -yield_dir
		for direction in [yield_dir, (yield_dir + travel).normalized(), -yield_dir]:
			var proposed: Vector2 = logical_position + direction * stats.speed * delta
			if clear_step(proposed, paths, near):
				logical_position = proposed
				velocity = direction * stats.speed
				if direction == -yield_dir:
					yield_dir = -yield_dir
				return
		return # Boxed in: hold still rather than wiggle.
	yield_dir = Vector2.ZERO
	velocity = Vector2.ZERO
	if not settling:
		return
	for other in near:
		if not other.route.is_empty() and screen_gap(other.logical_position, logical_position) < mission.settle_clear_px:
			clear_time = 0.0 # Traffic still around: walking back now would block it again.
			return
	clear_time += delta
	if clear_time < mission.settle_delay:
		return # Wait for traffic to pass before walking back.
	if occupied(settle_target, near) or screen_gap(settle_target, logical_position) < mission.settle_min_px:
		settling = false # Someone rests in the old spot, or we're close enough: keep this one.
		return
	# Walk back as an ordinary move, so it steers around anything in between.
	var back := paths.path(logical_position, settle_target)
	settling = false
	if back.is_empty():
		return
	if paths.map.passable(paths.map.cell_of(settle_target)):
		back[back.size() - 1] = settle_target
	set_route(back, true)

## Draw position follows the simulation with a tiny lag (`smoothing` seconds) so any
## small step-to-step direction change reads as a curve, never as a twitch.
## Selection/tap picking uses this drawn position, so it matches what is seen.
func render(alpha: float, delta: float = 0.0, smoothing: float = 0.0) -> void:
	var simulated := projection.to_iso(previous_position.lerp(logical_position, alpha))
	if smoothing <= 0.0 or delta <= 0.0 or position.distance_to(simulated) > 64.0:
		position = simulated # Snap on spawn/teleport or when smoothing is off.
	else:
		position = position.lerp(simulated, 1.0 - exp(-delta / smoothing))
	z_index = int(position.y)
	queue_redraw()

func _draw() -> void:
	if stats == null:
		return
	if selected or previewed:
		# Flat ring on the ground, sized to the unit, so rings in a tight group don't pile up.
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
		draw_arc(Vector2.ZERO, stats.footprint_radius + 3.0, 0.0, TAU, 32, Color(0.35, 1.0, 0.6) if selected else Color(1, 0.9, 0.3), 3.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(Vector2(3, 3), 12.0, Color(0, 0, 0, 0.25))
	if stats.vehicle:
		draw_colored_polygon(PackedVector2Array([Vector2(-17, -8), Vector2(0, -18), Vector2(17, -8), Vector2(0, 2)]), stats.color)
	else:
		draw_circle(Vector2(0, -9), 9.0, stats.color)
	draw_string(ThemeDB.fallback_font, Vector2(-20, -24), stats.display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
