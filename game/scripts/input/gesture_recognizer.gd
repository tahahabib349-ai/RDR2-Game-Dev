class_name GestureRecognizer
extends RefCounted
## Pure, timestamp-driven recognizer. Coordinates are viewport/design pixels.
## A gesture's mode is locked until ALL participating fingers lift.

signal intent(event: Dictionary)
var config: GestureConfig
var fingers: Dictionary = {}
var starts: Dictionary = {}
var mode: StringName = &"idle"
var pair_started: float = 0.0
var previous_center: Vector2
var previous_distance: float = 0.0
var last_box: Rect2
var last_tap_time: float = -INF
var last_tap_position: Vector2
var last_motion_time: float = 0.0
var pan_velocity: Vector2

func _init(settings: GestureConfig) -> void:
	config = settings

func down(id: int, point: Vector2, time: float, on_ui: bool = false, mouse_box: bool = false) -> void:
	advance(time)
	fingers[id] = point
	starts[id] = point
	if on_ui or fingers.size() > 2 or mode == &"cancelled" or mode == &"finishing":
		cancel()
		return
	if fingers.size() == 1:
		mode = &"mouse_box" if mouse_box else &"tap"
		last_motion_time = time
		pan_velocity = Vector2.ZERO
		intent.emit({"kind": &"gesture_start"})
		if mouse_box:
			last_tap_time = -INF
			last_box = Rect2(point, Vector2.ZERO)
			intent.emit({"kind": &"box_preview", "rect": last_box})
	elif fingers.size() == 2:
		mode = &"pair_wait"
		last_tap_time = -INF
		pair_started = time
		for key in fingers:
			starts[key] = fingers[key]
		previous_center = pair_center()
		previous_distance = pair_distance()
		intent.emit({"kind": &"gesture_start"})

func motion(id: int, point: Vector2, time: float) -> void:
	if not fingers.has(id):
		return
	advance(time)
	var previous: Vector2 = fingers[id]
	fingers[id] = point
	if mode == &"tap" and point.distance_to(starts[id]) > config.tap_slop:
		mode = &"pan"
		last_tap_time = -INF
		# Include accumulated slop so the map follows the whole drag.
		previous = starts[id]
	if mode == &"pan":
		var delta := point - previous
		pan_velocity = delta / maxf(time - last_motion_time, 0.001)
		last_motion_time = time
		intent.emit({"kind": &"pan", "delta": delta})
	elif mode == &"mouse_box":
		last_box = Rect2(starts[id], point - starts[id]).abs()
		intent.emit({"kind": &"box_preview", "rect": last_box})
	elif mode == &"pair_wait":
		for key in fingers:
			if Vector2(fingers[key]).distance_to(starts[key]) > config.box_hold_slop:
				mode = &"pinch"
				break
		if mode == &"pinch":
			emit_pinch()
	elif mode == &"pinch":
		emit_pinch()
	elif mode == &"box":
		emit_box_preview()

func up(id: int, point: Vector2, time: float, cancelled: bool = false) -> void:
	if not fingers.has(id):
		return
	if cancelled:
		cancel()
	else:
		if point != fingers[id]:
			motion(id, point, time)
		else:
			advance(time)
	if mode == &"tap":
		var double := time - last_tap_time <= config.double_tap_seconds and point.distance_to(last_tap_position) <= config.double_tap_distance
		intent.emit({"kind": &"double_tap" if double else &"tap", "point": point})
		last_tap_time = -INF if double else time
		last_tap_position = point
	elif mode == &"pan":
		# A pause before release must not resurrect an old flick velocity.
		if time - last_motion_time > config.inertia_seconds:
			pan_velocity = Vector2.ZERO
		intent.emit({"kind": &"pan_end", "velocity": pan_velocity})
	elif mode == &"mouse_box":
		intent.emit({"kind": &"box_select", "rect": last_box})
	elif mode == &"box":
		# Freeze at the first lift; commit only when both fingers have lifted.
		mode = &"finishing"
	elif mode == &"pinch" or mode == &"pair_wait":
		mode = &"cancelled"
	fingers.erase(id)
	starts.erase(id)
	if fingers.is_empty():
		if mode == &"finishing":
			intent.emit({"kind": &"box_select", "rect": last_box})
		elif mode == &"cancelled":
			intent.emit({"kind": &"cancel"})
		mode = &"idle"

func advance(time: float) -> void:
	if mode == &"pair_wait" and time - pair_started >= config.box_hold_seconds:
		mode = &"box"
		emit_box_preview()

func cancel() -> void:
	mode = &"cancelled"
	last_tap_time = -INF
	intent.emit({"kind": &"cancel"})

func reset() -> void:
	cancel()
	fingers.clear()
	starts.clear()
	mode = &"idle"

func pair_center() -> Vector2:
	var points := fingers.values()
	return (Vector2(points[0]) + Vector2(points[1])) * 0.5

func pair_distance() -> float:
	var points := fingers.values()
	return Vector2(points[0]).distance_to(points[1])

func emit_pinch() -> void:
	var center := pair_center()
	var distance := pair_distance()
	intent.emit({"kind": &"pinch", "point": center, "previous_point": previous_center,
		"factor": maxf(distance, config.minimum_pinch_distance) / maxf(previous_distance, config.minimum_pinch_distance)})
	previous_center = center
	previous_distance = distance

func emit_box_preview() -> void:
	var points := fingers.values()
	last_box = Rect2(points[0], Vector2(points[1]) - Vector2(points[0])).abs()
	intent.emit({"kind": &"box_preview", "rect": last_box})
