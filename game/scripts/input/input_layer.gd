class_name BattlefieldInput
extends Node
## Only this adapter reads raw events; every consumer receives intents.

signal intent(event: Dictionary)
var recognizer: GestureRecognizer
var config: GestureConfig
var ui_hit_test: Callable
var ui_action_at: Callable
var ui_touches: Dictionary = {}

func configure(settings: GestureConfig, hit_test: Callable, action_at: Callable = Callable()) -> void:
	config = settings
	ui_hit_test = hit_test
	ui_action_at = action_at
	recognizer = GestureRecognizer.new(config)
	recognizer.intent.connect(func(event: Dictionary) -> void: intent.emit(event))

func _process(_delta: float) -> void:
	if recognizer != null:
		recognizer.advance(now())

func now() -> float:
	return Time.get_ticks_usec() / 1000000.0

func _input(event: InputEvent) -> void:
	if recognizer != null:
		feed(event, now())

func feed(event: InputEvent, time: float) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var on_ui: bool = ui_hit_test.call(event.position)
			if on_ui and ui_action_at.is_valid():
				ui_touches[event.index] = {"start": event.position, "kind": ui_action_at.call(event.position), "cancelled": false}
			recognizer.down(event.index, event.position, time, on_ui)
			if recognizer.fingers.size() > 1:
				for id in ui_touches:
					ui_touches[id].cancelled = true
		else:
			recognizer.up(event.index, event.position, time, event.canceled)
			if ui_touches.has(event.index):
				var touch: Dictionary = ui_touches[event.index]
				if not event.canceled and not touch.cancelled and touch.kind != &"" and Vector2(touch.start).distance_to(event.position) <= config.tap_slop and ui_action_at.call(event.position) == touch.kind:
					intent.emit({"kind": touch.kind})
				ui_touches.erase(event.index)
	elif event is InputEventScreenDrag:
		if ui_touches.has(event.index) and Vector2(ui_touches[event.index].start).distance_to(event.position) > config.tap_slop:
			ui_touches[event.index].cancelled = true
		recognizer.motion(event.index, event.position, time)
	elif event is InputEventMouseButton and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				recognizer.down(-1, event.position, time, ui_hit_test.call(event.position), event.shift_pressed)
			else:
				recognizer.up(-1, event.position, time)
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and not ui_hit_test.call(event.position):
			var factor := config.wheel_zoom_factor if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / config.wheel_zoom_factor
			intent.emit({"kind": &"pinch", "point": event.position, "previous_point": event.position, "factor": factor})
	elif event is InputEventMouseMotion and event.device != InputEvent.DEVICE_ID_EMULATION:
		recognizer.motion(-1, event.position, time)
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		recognizer.reset()
		ui_touches.clear()
		intent.emit({"kind": &"deselect"})

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and recognizer != null:
		recognizer.reset()
		ui_touches.clear()
