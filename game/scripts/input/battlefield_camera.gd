class_name BattlefieldCamera
extends Camera2D

var projection: IsoProjection
var mission: MissionConfig
var config: GestureConfig
var velocity := Vector2.ZERO
var inertia_left: float = 0.0

func configure(iso: IsoProjection, map_config: MissionConfig, gestures: GestureConfig) -> void:
	projection = iso
	mission = map_config
	config = gestures
	zoom = Vector2.ONE * config.initial_zoom
	position = projection.to_iso(mission.player_start)
	clamp_view()

func view_size() -> Vector2:
	return get_viewport_rect().size

func screen_to_world(point: Vector2) -> Vector2:
	return position + (point - view_size() * 0.5) / zoom.x

func world_to_screen(point: Vector2) -> Vector2:
	return (point - position) * zoom.x + view_size() * 0.5

func minimum_zoom() -> float:
	var bounds := projection.map_bounds(mission.size)
	var usable := (view_size() - Vector2.ONE * config.camera_border_margin * 2).max(Vector2.ONE)
	return maxf(config.min_zoom, maxf(usable.x / bounds.size.x, usable.y / bounds.size.y))

func clamp_view() -> void:
	zoom = Vector2.ONE * clampf(zoom.x, minimum_zoom(), maxf(config.max_zoom, minimum_zoom()))
	# Clamp against the projected map bounds, not an inset logical diamond. The
	# latter permanently hides walkable strips and all four tips of the map.
	# A small design-pixel border leaves edge units clear of the screen boundary.
	var bounds := projection.map_bounds(mission.size).grow(config.camera_border_margin / zoom.x)
	var half_view := view_size() * 0.5 / zoom.x
	position.x = clampf(position.x, bounds.position.x + half_view.x, bounds.end.x - half_view.x)
	position.y = clampf(position.y, bounds.position.y + half_view.y, bounds.end.y - half_view.y)
	force_update_scroll()

func consume(event: Dictionary) -> void:
	match event.kind:
		&"gesture_start", &"cancel":
			velocity = Vector2.ZERO
			inertia_left = 0.0
		&"pan":
			position -= Vector2(event.delta) / zoom.x
			clamp_view()
		&"pan_end":
			velocity = -Vector2(event.velocity) / zoom.x
			inertia_left = config.inertia_seconds
		&"pinch":
			velocity = Vector2.ZERO
			inertia_left = 0.0
			var anchor := screen_to_world(event.previous_point)
			zoom = Vector2.ONE * clampf(zoom.x * float(event.factor), minimum_zoom(), maxf(config.max_zoom, minimum_zoom()))
			position = anchor - (Vector2(event.point) - view_size() * 0.5) / zoom.x
			clamp_view()

func _process(delta: float) -> void:
	if config == null:
		return
	if inertia_left > 0.0:
		var step := minf(delta, inertia_left)
		position += velocity * step * (inertia_left / maxf(config.inertia_seconds, 0.001))
		inertia_left -= step
	clamp_view()
