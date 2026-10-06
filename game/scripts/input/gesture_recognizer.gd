class_name GestureRecognizer
extends RefCounted
## Timestamp-driven input intents; a two-finger sequence never selects or orders.

signal intent(event: Dictionary)
var config: GestureConfig
var fingers: Dictionary = {}
var starts: Dictionary = {}
var mode: StringName = &"idle"
var hold_started: float
var previous_center: Vector2
var previous_distance: float
var last_box: Rect2
var box_dragged: bool = false
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
	if on_ui or fingers.size() > 2 or mode == &"cancelled":
		cancel()
		return
	if fingers.size() == 1:
		mode = &"box" if mouse_box else &"tap"
		hold_started = time
		box_dragged = false
		last_motion_time = time
		pan_velocity = Vector2.ZERO
		intent.emit({"kind": &"gesture_start"})
		if mouse_box:
			last_tap_time = -INF
			last_box = Rect2(point, Vector2.ZERO)
			intent.emit({"kind": &"box_preview", "rect": last_box})
		else:
			emit_hold(0.0)
	else:
		# Remove any one-finger hold/box preview before camera-only input.
		intent.emit({"kind": &"cancel"})
		mode = &"pinch"
		last_tap_time = -INF
		previous_center = pair_center()
		previous_distance = pair_distance()
		intent.emit({"kind": &"gesture_start"})

func motion(id: int, point: Vector2, time: float) -> void:
	if not fingers.has(id):
		return
	var previous: Vector2 = fingers[id]
	# Movement beyond hold slop cancels before advancing the timer. A late event
	# must not turn a drag that crossed the threshold into an accidental box.
	if mode == &"tap" and point.distance_to(starts[id]) > config.box_hold_slop:
		mode = &"pan"
		last_tap_time = -INF
		intent.emit({"kind": &"hold_end"})
		previous = starts[id]
	advance(time)
	fingers[id] = point
	if mode == &"pan":
		var delta := point - previous
		pan_velocity = delta / maxf(time - last_motion_time, 0.001)
		last_motion_time = time
		intent.emit({"kind": &"pan", "delta": delta})
	elif mode == &"box":
		box_dragged = box_dragged or point.distance_to(starts[id]) > config.box_hold_slop
		last_box = Rect2(starts[id], point - starts[id]).abs()
		intent.emit({"kind": &"box_preview", "rect": last_box})
	elif mode == &"pinch":
		emit_pinch()

func up(id: int, point: Vector2, time: float, cancelled: bool = false) -> void:
	if not fingers.has(id):
		return
	if cancelled:
		cancel()
	elif point != fingers[id]:
		motion(id, point, time)
	else:
		advance(time)
	if mode == &"tap":
		var double := time - last_tap_time <= config.double_tap_seconds and point.distance_to(last_tap_position) <= config.double_tap_distance
		intent.emit({"kind": &"tap" if not double else &"double_tap", "point": point})
		last_tap_time = -INF if double else time
		last_tap_position = point
	elif mode == &"pan":
		if time - last_motion_time > config.inertia_seconds:
			pan_velocity = Vector2.ZERO
		intent.emit({"kind": &"pan_end", "velocity": pan_velocity})
	elif mode == &"box":
		if box_dragged:
			intent.emit({"kind": &"box_select", "rect": last_box})
		else:
			intent.emit({"kind": &"cancel"})
	elif mode == &"pinch":
		mode = &"cancelled"
	intent.emit({"kind": &"hold_end"})
	fingers.erase(id)
	starts.erase(id)
	if fingers.is_empty():
		if mode == &"cancelled":
			intent.emit({"kind": &"cancel"})
		mode = &"idle"

func advance(time: float) -> void:
	if mode != &"tap":
		return
	var progress := clampf((time - hold_started) / config.box_hold_seconds, 0.0, 1.0)
	emit_hold(progress)
	if progress >= 1.0:
		mode = &"box"
		last_tap_time = -INF
		last_box = Rect2(starts.values()[0], Vector2.ZERO)
		intent.emit({"kind": &"box_preview", "rect": last_box})

func emit_hold(progress: float) -> void:
	intent.emit({"kind": &"hold_progress", "point": starts.values()[0], "progress": progress})

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
