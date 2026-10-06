class_name GameSession
extends Node2D

const UNIT_SCENE := preload("res://scenes/units/unit.tscn")
var mission: MissionConfig = preload("res://data/missions/mission_zero.tres")
var gestures: GestureConfig = preload("res://data/gestures.tres")
var projection: IsoProjection
var map: MapModel
var paths: PathService
var selection: SelectionController
var commands: CommandController
var units: Array[UnitMovement] = []
var marker_position: Vector2
var marker_left: float = 0.0
var tick_count: int = 0
@onready var terrain: TerrainView = $Terrain
@onready var camera: BattlefieldCamera = $Camera
@onready var hud: PhaseOneHUD = $HUDLayer/HUD
@onready var input_layer: BattlefieldInput = $InputLayer

func _ready() -> void:
	projection = IsoProjection.new(Vector2(mission.tile_size))
	map = MapModel.new(mission)
	paths = PathService.new(map)
	selection = SelectionController.new(gestures)
	commands = CommandController.new(paths, mission)
	terrain.build(map, projection)
	camera.configure(projection, mission, gestures)
	hud.configure(gestures)
	input_layer.configure(gestures, hud.hits_ui, hud.action_at)
	input_layer.intent.connect(consume)
	hud.action.connect(consume)
	selection.changed.connect(func() -> void: hud.show_selection(selection.selected))
	for i in range(mission.spawn_types.size()):
		var unit: UnitMovement = UNIT_SCENE.instantiate()
		var stats: UnitStats = load("res://data/units/%s.tres" % mission.spawn_types[i])
		unit.configure(i + 1, stats, mission.spawn_positions[i], projection)
		$Units.add_child(unit)
		units.append(unit)
	selection.units = units
	queue_redraw()

func unit_screen(unit: UnitMovement) -> Vector2:
	return camera.world_to_screen(unit.position)

func consume(event: Dictionary) -> void:
	camera.consume(event)
	match event.kind:
		&"tap", &"double_tap":
			if not selection.tap(event.point, event.kind == &"double_tap", unit_screen, get_viewport_rect()):
				var destination := projection.to_logical(camera.screen_to_world(event.point))
				if commands.issue_move(selection.selected, destination, units) > 0:
					marker_position = projection.to_iso(destination)
					marker_left = gestures.marker_seconds
		&"hold_progress":
			hud.show_hold(event.point, event.progress)
		&"hold_end":
			hud.hide_hold()
		&"box_preview":
			hud.show_box(event.rect)
			selection.box(event.rect, unit_screen, true)
		&"box_select":
			selection.box(event.rect, unit_screen, false)
			hud.hide_box()
		&"cancel":
			hud.hide_hold()
			selection.clear_preview()
			hud.hide_box()
		&"deselect":
			selection.replace([])
			selection.clear_preview()
			hud.hide_box()
		&"all_army":
			selection.all_army()
		&"zoom_in", &"zoom_out":
			var center := get_viewport_rect().size * 0.5
			camera.consume({"kind": &"pinch", "point": center, "previous_point": center,
				"factor": gestures.wheel_zoom_factor if event.kind == &"zoom_in" else 1.0 / gestures.wheel_zoom_factor})

func _physics_process(delta: float) -> void:
	simulate_tick(delta)

func simulate_tick(delta: float) -> void:
	tick_count += 1
	for unit in units:
		unit.previous_position = unit.logical_position
	for unit in units:
		unit.tick(delta, paths, units, mission)

func _process(delta: float) -> void:
	marker_left = maxf(0, marker_left - delta)
	for unit in units:
		unit.render(Engine.get_physics_interpolation_fraction(), delta, mission.visual_smoothing_seconds)
	queue_redraw()

func _draw() -> void:
	if projection == null:
		return
	var landmarks := {"Player basin": mission.player_start, "Enemy base site": mission.enemy_base,
		"Central Pass": mission.central_pass, "East Cut": mission.east_cut}
	for label in landmarks:
		draw_string(ThemeDB.fallback_font, projection.to_iso(landmarks[label]) + Vector2(0, -55), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.8, 0.85, 0.9))
	if marker_left > 0:
		var phase := 1.0 - marker_left / gestures.marker_seconds
		draw_arc(marker_position, 15 + phase * 20, 0, TAU, 40, Color(0.3, 1, 0.5, 1 - phase), 3)
		for unit in selection.selected:
			draw_line(unit.position, marker_position, Color(0.3, 1, 0.5, 0.3 * (1 - phase)), 1)
