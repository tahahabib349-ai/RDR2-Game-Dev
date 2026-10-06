class_name PhaseOneHUD
extends Control

signal action(event: Dictionary)
var config: GestureConfig
var blockers: Array[Control] = []
var selection_label: Label
var title: Label
var box_rect: Rect2
var box_visible: bool = false
var selected_count: int = 0
var buttons: Array[Button] = []

func configure(settings: GestureConfig) -> void:
	config = settings
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title = Label.new()
	title.text = "PHASE 1 GREYBOX · Breakpoint Valley\nTap: select/move · Drag: pan · Hold two fingers: box · Pinch: zoom"
	title.add_theme_font_size_override("font_size", 18)
	title.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(title)
	blockers.append(title)
	selection_label = Label.new()
	selection_label.text = "No units selected"
	selection_label.add_theme_font_size_override("font_size", 18)
	selection_label.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(selection_label)
	blockers.append(selection_label)
	add_button("✕", &"deselect")
	add_button("All Army", &"all_army")
	add_button("−", &"zoom_out")
	add_button("+", &"zoom_in")
	get_viewport().size_changed.connect(layout)
	layout()

func add_button(text: String, kind: StringName) -> void:
	var button := Button.new()
	button.text = text
	button.set_meta("intent_kind", kind)
	button.add_theme_font_size_override("font_size", 20)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void: action.emit({"kind": kind}))
	add_child(button)
	buttons.append(button)
	blockers.append(button)

static func fit_safe_area(safe_pixels: Rect2, window_pixels: Vector2, viewport_size: Vector2) -> Rect2:
	if window_pixels.x <= 0 or window_pixels.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	var clipped := safe_pixels.intersection(Rect2(Vector2.ZERO, window_pixels))
	if clipped.size.x <= 0 or clipped.size.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	var scale := viewport_size / window_pixels
	return Rect2(clipped.position * scale, clipped.size * scale)

func safe_rect() -> Rect2:
	var viewport_size := get_viewport_rect().size
	if OS.has_feature("android") or OS.has_feature("ios"):
		var safe := Rect2(DisplayServer.get_display_safe_area())
		safe.position -= Vector2(DisplayServer.window_get_position())
		return fit_safe_area(safe, Vector2(DisplayServer.window_get_size()), viewport_size)
	return Rect2(Vector2.ZERO, viewport_size)

func layout() -> void:
	var safe := safe_rect().grow(-config.ui_gap)
	title.position = safe.position
	title.size = Vector2(safe.size.x, 48)
	selection_label.position = Vector2(safe.position.x, safe.end.y - config.button_size - 30)
	selection_label.size = Vector2(400, 28)
	for i in range(buttons.size()):
		buttons[i].position = Vector2(safe.position.x + i * (config.button_size + config.ui_gap), safe.end.y - config.button_size)
		buttons[i].size = Vector2.ONE * config.button_size

func hits_ui(point: Vector2) -> bool:
	if not safe_rect().has_point(point):
		return true
	for control in blockers:
		if control.get_global_rect().has_point(point):
			return true
	return false

func show_selection(units: Array[UnitMovement]) -> void:
	selected_count = units.size()
	selection_label.text = "%d selected" % units.size() if not units.is_empty() else "No units selected"
	if units.size() == 1:
		selection_label.text += " · " + units[0].stats.display_name

func show_box(rect: Rect2) -> void:
	box_rect = rect
	box_visible = true
	queue_redraw()

func hide_box() -> void:
	box_visible = false
	queue_redraw()

func _draw() -> void:
	if box_visible:
		draw_rect(box_rect, Color(0.3, 0.9, 0.7, 0.12))
		draw_rect(box_rect, Color(0.3, 0.9, 0.7), false, 2)

func action_at(point: Vector2) -> StringName:
	for button in buttons:
		if button.get_global_rect().has_point(point):
			return button.get_meta("intent_kind")
	return &""
