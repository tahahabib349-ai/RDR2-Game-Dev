extends SceneTree
## No bare assertions: every failed check is counted and exits nonzero.

var passed: int = 0
var failed: int = 0
var events: Array[Dictionary] = []
var settings: GestureConfig = preload("res://data/gestures.tres")
var mission: MissionConfig = preload("res://data/missions/mission_zero.tres")

func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + label)

func fresh() -> GestureRecognizer:
	events.clear()
	var recognizer := GestureRecognizer.new(settings)
	recognizer.intent.connect(func(event: Dictionary) -> void: events.append(event))
	return recognizer

func count_kind(kind: StringName) -> int:
	var count := 0
	for event in events:
		if event.kind == kind:
			count += 1
	return count

func test_gestures() -> void:
	print("SUITE: timestamp-driven gestures")
	var r := fresh()
	r.down(0, Vector2(100, 100), 0)
	check(count_kind(&"tap") == 0, "orders wait for finger up")
	r.motion(0, Vector2(110, 100), 0.05)
	r.up(0, Vector2(110, 100), 0.1)
	check(count_kind(&"tap") == 1 and count_kind(&"pan") == 0, "10 px wiggle is a tap")
	r = fresh()
	r.down(0, Vector2(100, 100), 0)
	r.motion(0, Vector2(130, 100), 0.05)
	check(count_kind(&"pan") == 1 and events[-1].delta == Vector2(30, 0), "30 px movement pans including slop")
	r.motion(0, Vector2(100, 100), 0.1)
	r.up(0, Vector2(100, 100), 0.11)
	check(count_kind(&"tap") == 0, "drag returning to start never becomes a tap")
	check(count_kind(&"pan_end") == 1 and Vector2(events.filter(func(e): return e.kind == &"pan_end")[-1].velocity).length() > 0, "quick flick retains inertia velocity")
	r = fresh()
	r.down(0, Vector2.ZERO, 0)
	r.motion(0, Vector2(30, 0), 0.1)
	r.up(0, Vector2(30, 0), 1)
	check(events.filter(func(e): return e.kind == &"pan_end")[-1].velocity == Vector2.ZERO, "pause before release suppresses stale inertia")
	r = fresh()
	r.down(0, Vector2(100, 100), 0)
	r.advance(0.399)
	check(r.mode == &"tap" and count_kind(&"hold_progress") > 0, "hold ring progresses before 0.4 seconds")
	r.advance(0.4)
	check(r.mode == &"box", "one-finger hold enters box at 0.4 seconds")
	r.motion(0, Vector2(350, 300), 0.45)
	r.up(0, Vector2(350, 300), 0.5)
	check(count_kind(&"box_select") == 1 and count_kind(&"tap") == 0 and count_kind(&"pan") == 0, "held one-finger drag selects without pan/order")
	r = fresh()
	r.down(0, Vector2(100, 100), 0)
	r.motion(0, Vector2(119, 100), 0.2)
	r.advance(0.4)
	check(r.mode == &"box", "19 px hold jitter stays within 20 px slop")
	r.up(0, Vector2(119, 100), 0.5)
	check(count_kind(&"box_select") == 0 and count_kind(&"tap") == 0, "hold lifted without dragging changes nothing")
	r = fresh()
	r.down(0, Vector2.ZERO, 0)
	r.motion(0, Vector2(21, 0), 0.39)
	r.advance(0.5)
	check(r.mode == &"pan" and count_kind(&"box_preview") == 0, "moving beyond slop before hold completion pans")
	r.up(0, Vector2(21, 0), 0.6)
	r = fresh()
	r.down(0, Vector2(100, 100), 0)
	r.advance(0.4)
	r.motion(0, Vector2(350, 300), 0.45)
	r.down(1, Vector2(500, 400), 0.5)
	r.motion(1, Vector2(550, 450), 0.55)
	r.advance(2)
	r.up(0, Vector2(350, 300), 2.1)
	r.motion(1, Vector2(600, 500), 2.2)
	r.up(1, Vector2(600, 500), 2.3)
	check(count_kind(&"box_select") == 0 and count_kind(&"pinch") == 1 and count_kind(&"tap") == 0, "second finger cancels an active box; remaining finger cannot select/order")
	r = fresh()
	r.down(0, Vector2.ZERO, 0)
	r.down(1, Vector2(100, 100), 0.01)
	r.advance(2)
	check(r.mode == &"pinch" and count_kind(&"box_preview") == 0, "stationary two fingers never become selection")
	r.motion(0, Vector2(30, 0), 2.1)
	r.motion(1, Vector2(130, 100), 2.2)
	check(count_kind(&"pinch") == 2, "two-finger translation emits camera intents")
	r.down(2, Vector2(200, 200), 2.3)
	r.up(0, Vector2(30, 0), 2.4)
	r.up(1, Vector2(130, 100), 2.5)
	r.up(2, Vector2(200, 200), 2.6)
	check(count_kind(&"box_select") == 0 and r.mode == &"idle", "third finger cancels and drains the sequence")
	r = fresh()
	r.down(0, Vector2(100, 100), 0)
	r.up(0, Vector2(100, 100), 0.05)
	r.down(0, Vector2(130, 100), 0.15)
	r.up(0, Vector2(130, 100), 0.2)
	check(count_kind(&"tap") == 1 and count_kind(&"double_tap") == 1, "single immediate, second upgrades to double within 40 px/0.30 s")
	r.down(0, Vector2(200, 100), 0.3)
	r.up(0, Vector2(200, 100), 0.35)
	check(count_kind(&"tap") == 2, "third tap starts a fresh sequence")
	r = fresh()
	r.down(0, Vector2.ZERO, 0)
	r.up(0, Vector2.ZERO, 0.01)
	r.down(0, Vector2(41, 0), 0.1)
	r.up(0, Vector2(41, 0), 0.11)
	check(count_kind(&"double_tap") == 0, "distant taps are not double taps")
	r.down(0, Vector2(41, 0), 0.5)
	r.up(0, Vector2(41, 0), 0.51)
	check(count_kind(&"double_tap") == 0, "expired taps are not double taps")
	r = fresh()
	r.down(0, Vector2.ZERO, 0, true)
	r.motion(0, Vector2(300, 300), 0.1)
	r.up(0, Vector2(300, 300), 0.2)
	check(count_kind(&"pan") == 0 and count_kind(&"tap") == 0, "UI-origin drag never reaches battlefield")
	r.down(0, Vector2.ZERO, 0.3)
	r.up(0, Vector2.ZERO, 0.4, true)
	check(count_kind(&"tap") == 0, "OS-cancelled touch never issues an order")
	r.down(0, Vector2.ZERO, 0.5)
	r.reset()
	r.up(0, Vector2.ZERO, 0.6)
	check(count_kind(&"tap") == 0 and r.fingers.is_empty(), "focus loss/reset clears active touches")

func test_paths() -> void:
	print("SUITE: grid, isometric projection, pathfinding")
	var map := MapModel.new(mission)
	var paths := PathService.new(map)
	var iso := IsoProjection.new(Vector2(mission.tile_size))
	check(map.config.size == Vector2i(108, 108), "Mission Zero is 108x108")
	check(not map.blocked.is_empty(), "rocky ridge blocks cells")
	check(iso.to_logical(iso.to_iso(Vector2(12.25, 58.75))).is_equal_approx(Vector2(12.25, 58.75)), "projection round trip preserves continuous logical positions")
	check(iso.to_iso(Vector2(1, 0)) == Vector2(32, 16) and iso.to_iso(Vector2(0, 1)) == Vector2(-32, 16), "64x32 isometric basis")
	for center in [mission.central_pass, mission.east_cut]:
		var open := true
		for y in range(-2, 3):
			for x in range(-2, 3):
				open = open and map.passable(Vector2i(center) + Vector2i(x, y))
		check(open, "pass has at least a 5-cell open core at " + str(center))
	var route := paths.path(mission.player_start, mission.enemy_base)
	check(route.size() > 2 and route[-1] == mission.enemy_base.floor() + Vector2(0.5, 0.5), "route reaches enemy-base site from player basin")
	var valid := true
	for i in range(route.size()):
		valid = valid and map.passable(map.cell_of(route[i]))
		if i > 0:
			valid = valid and paths.can_traverse(route[i - 1], route[i])
	check(valid, "mission route stays passable and does not cut blocked corners")
	check(paths.path(Vector2(-1, 0), Vector2(10, 10)).is_empty(), "out-of-bounds start rejected")
	check(paths.path(mission.player_start, Vector2(mission.size)).is_empty(), "out-of-bounds destination rejected")
	var sealed: MissionConfig = mission.duplicate()
	sealed.central_pass_radius = -1
	sealed.east_cut_radius = -1
	var sealed_paths := PathService.new(MapModel.new(sealed))
	var closed_route := sealed_paths.grid.get_id_path(Vector2i(mission.player_start), Vector2i(mission.enemy_base), false)
	check(closed_route.is_empty(), "blocking both passes leaves no base-to-base route")
	var blocked_cell: Vector2i = map.blocked.keys()[0]
	var fallback := paths.path(mission.player_start, Vector2(blocked_cell))
	check(not fallback.is_empty() and map.passable(map.cell_of(fallback[-1])), "blocked destination resolves to passable reachable cell")
	check(paths.path(Vector2(blocked_cell), mission.player_start).is_empty(), "blocked start rejected without AStar error")
	var small := MissionConfig.new()
	small.size = Vector2i(8, 8)
	var isolated := PathService.new(MapModel.new(small))
	isolated.set_blocked(Vector2i(1, 0), true)
	isolated.set_blocked(Vector2i(0, 1), true)
	check(not isolated.can_traverse(Vector2(0.5, 0.5), Vector2(1.5, 1.5)), "diagonal cannot squeeze between touching obstacles")
	var partial := isolated.path(Vector2(0.5, 0.5), Vector2(7.5, 7.5))
	check(partial.size() == 1 and partial[0] == Vector2(0.5, 0.5), "unreachable destination returns honest partial route")
	isolated.set_blocked(Vector2i(1, 0), false)
	isolated.set_blocked(Vector2i(0, 1), false)
	check(isolated.path(Vector2(0.5, 0.5), Vector2(7.5, 7.5)).size() == 8, "unblocking updates the shared AStar grid")
	var detour := PathService.new(MapModel.new(small))
	for y in range(6):
		detour.set_blocked(Vector2i(3, y), true)
	var around := detour.path(Vector2(1.5, 1.5), Vector2(6.5, 1.5))
	check(around.size() > 6 and around[-1] == Vector2(6.5, 1.5), "path detours around a wall")
	var cell: Vector2i = detour.map.cell_of(around[2])
	detour.set_blocked(cell, true)
	var changed := detour.path(Vector2(1.5, 1.5), Vector2(6.5, 1.5))
	check(not changed.has(Vector2(cell) + Vector2(0.5, 0.5)), "new path avoids newly blocked terrain")

func touch(layer: BattlefieldInput, id: int, point: Vector2, pressed: bool, time: float) -> void:
	var event := InputEventScreenTouch.new()
	event.index = id
	event.position = point
	event.pressed = pressed
	layer.feed(event, time)

func drag(layer: BattlefieldInput, id: int, point: Vector2, time: float) -> void:
	var event := InputEventScreenDrag.new()
	event.index = id
	event.position = point
	layer.feed(event, time)

func mouse(layer: BattlefieldInput, point: Vector2, pressed: bool, time: float, shift: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = pressed
	event.shift_pressed = shift
	layer.feed(event, time)

func test_scene() -> void:
	print("SUITE: actual scene, input adapter, selection, movement, camera and HUD")
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	var session: GameSession = scene.get_node("MissionZero")
	session.set_physics_process(false)
	session.set_process(false)
	var layer := session.input_layer
	layer.set_process(false)
	session.camera.set_process(false)
	check(settings.min_zoom == 1.0 and settings.box_hold_seconds == 0.4 and settings.box_hold_slop == 20.0, "playtest gesture thresholds live in the Resource")
	check(session.hud.buttons[0].text == "X" and ThemeDB.fallback_font.has_char("X".unicode_at(0)), "deselect uses a glyph present in the exported fallback font")
	check(session.units.size() == 7, "playable scene spawns seven labelled placeholder units")
	check(session.terrain.get_used_cells().size() == mission.size.x * mission.size.y, "TileMapLayer renders every mission cell")
	var alignment := true
	for cell in [Vector2i.ZERO, Vector2i(mission.player_start), Vector2i(mission.enemy_base), mission.size - Vector2i.ONE]:
		alignment = alignment and (session.terrain.position + session.terrain.map_to_local(cell)).is_equal_approx(session.projection.to_iso(Vector2(cell) + Vector2(0.5, 0.5)))
	check(alignment, "TileMap diamonds align with authoritative logical cells")
	var ranger := session.units[1]
	var hit := session.unit_screen(ranger)
	# Move other candidates away only for this picker test; keep its tiny sprite.
	var original_units := session.selection.units
	session.selection.units = [ranger]
	session.camera.zoom = Vector2.ONE * 0.8
	session.camera.clamp_view()
	hit = session.unit_screen(ranger)
	check(session.selection.pick(hit + Vector2(35, 0), session.unit_screen) == ranger, "35 px tap selects a tiny unit at low zoom")
	check(session.selection.pick(hit + Vector2(41, 0), session.unit_screen) == null, "tap outside 40 px radius is ground")
	session.selection.units = original_units
	session.camera.configure(session.projection, mission, settings)
	hit = session.unit_screen(ranger)
	touch(layer, 0, hit, true, 0)
	touch(layer, 0, hit, false, 0.05)
	check(session.selection.selected == [ranger], "raw touch selects immediately on finger up")
	touch(layer, 0, hit, true, 0.1)
	touch(layer, 0, hit, false, 0.15)
	check(session.selection.selected.size() == 3, "raw double tap selects visible Rangers of the same type")
	var hidden := session.units[3]
	var saved_position := hidden.position
	hidden.position = Vector2(100000, 100000)
	session.selection.tap(hit, true, session.unit_screen, session.get_viewport_rect())
	check(session.selection.selected.size() == 2, "double-tap excludes off-screen units")
	hidden.position = saved_position
	session.consume({"kind": &"all_army"})
	check(session.selection.selected.size() == 5, "All Army excludes Gatherer and Pioneer Rig")
	var empty_before := session.selection.selected.duplicate()
	session.selection.box(Rect2(-100, -100, 10, 10), session.unit_screen, false)
	check(session.selection.selected == empty_before, "empty box preserves selection")
	var rect := Rect2(hit - Vector2(20, 20), Vector2(40, 40))
	session.consume({"kind": &"box_preview", "rect": rect})
	check(ranger.previewed and session.hud.box_visible, "box preview highlights units and draws in screen space")
	session.consume({"kind": &"box_select", "rect": rect})
	check(session.selection.selected.has(ranger) and not ranger.previewed and not session.hud.box_visible, "box commit selects units and clears preview")
	session.consume({"kind": &"all_army"})
	var routes_before: Array = []
	for unit in session.units:
		routes_before.append(unit.route.duplicate())
	# Touch begins on an actual HUD button, then is dragged over the map.
	var button_point := session.hud.buttons[0].get_global_rect().get_center()
	touch(layer, 0, button_point, true, 1)
	drag(layer, 0, Vector2(600, 300), 1.1)
	touch(layer, 0, Vector2(600, 300), false, 1.2)
	var untouched := true
	for i in range(session.units.size()):
		untouched = untouched and session.units[i].route == routes_before[i]
	check(untouched, "raw UI-origin drag issues no movement")
	var camera_before := session.camera.position
	touch(layer, 0, Vector2(600, 300), true, 2)
	drag(layer, 0, Vector2(570, 300), 2.05)
	touch(layer, 0, Vector2(570, 300), false, 2.1)
	check(not session.camera.position.is_equal_approx(camera_before), "raw touch pan moves camera")
	check(session.marker_left == 0, "pan with units selected issues no move marker")
	layer.recognizer.reset()
	var zoom_before := session.camera.zoom.x
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.position = Vector2(640, 360)
	wheel.pressed = true
	layer.feed(wheel, 3)
	check(session.camera.zoom.x > zoom_before, "desktop wheel emits the same pinch intent")
	mouse(layer, hit - Vector2(60, 50), true, 4, true)
	var motion := InputEventMouseMotion.new()
	motion.position = hit + Vector2(100, 100)
	layer.feed(motion, 4.05)
	check(session.hud.box_visible, "Shift-left-drag previews a selection box")
	mouse(layer, motion.position, false, 4.1)
	check(not session.hud.box_visible, "Shift-left release commits selection")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	layer.feed(escape, 5)
	check(session.selection.selected.is_empty(), "Escape emits deselect through input layer")
	mouse(layer, session.unit_screen(ranger), true, 5.5)
	mouse(layer, session.unit_screen(ranger), false, 5.55)
	check(session.selection.selected == [ranger], "desktop left click uses same tap selection")
	mouse(layer, hit - Vector2(60, 60), true, 5.7)
	layer.recognizer.advance(6.11)
	var held_motion := InputEventMouseMotion.new()
	held_motion.position = hit + Vector2(60, 60)
	layer.feed(held_motion, 6.15)
	check(session.hud.box_visible, "desktop left-button hold then drag previews a box")
	mouse(layer, held_motion.position, false, 6.2)
	check(not session.hud.box_visible and session.selection.selected.has(ranger), "desktop held drag commits without a move")
	var safe := PhaseOneHUD.fit_safe_area(Rect2(120, 0, 2280, 1020), Vector2(2560, 1080), Vector2(1706.6667, 720))
	check(safe.position.is_equal_approx(Vector2(80, 0)) and is_equal_approx(safe.end.y, 680), "phone notch and home strip convert to design coordinates")
	check(PhaseOneHUD.fit_safe_area(Rect2(), Vector2(1280, 720), Vector2(1280, 720)) == Rect2(0, 0, 1280, 720), "empty desktop safe area falls back to viewport")
	var buttons_fit := true
	for button in session.hud.buttons:
		buttons_fit = buttons_fit and button.size.x >= 80 and button.size.y >= 80 and session.hud.safe_rect().encloses(button.get_global_rect())
	check(buttons_fit, "all buttons are at least 80x80 and inside safe area")
	# Anchor-preserving zoom away from map edges.
	session.camera.position = session.projection.to_iso(Vector2(mission.size) * 0.5)
	session.camera.zoom = Vector2.ONE * 1.5
	session.camera.clamp_view()
	var anchor := Vector2(500, 300)
	var anchor_world := session.camera.screen_to_world(anchor)
	session.camera.consume({"kind": &"pinch", "previous_point": anchor, "point": anchor, "factor": 1.2})
	check(session.camera.screen_to_world(anchor).is_equal_approx(anchor_world), "pinch keeps world point under finger midpoint")
	var bounded := true
	for location in [Vector2(-100, -100), Vector2(100, 100), Vector2(0, mission.size.y), Vector2(mission.size.x, 0)]:
		session.camera.position = session.projection.to_iso(location)
		session.camera.zoom = Vector2.ONE * 0.1
		session.camera.clamp_view()
		var limits := session.projection.map_bounds(mission.size).grow(settings.camera_border_margin / session.camera.zoom.x + 0.001)
		for point in [Vector2.ZERO, Vector2(session.camera.view_size().x, 0), session.camera.view_size(), Vector2(0, session.camera.view_size().y)]:
			bounded = bounded and limits.has_point(session.camera.screen_to_world(point))
	check(bounded, "camera overscroll stays within the configured dark border")
	check_cell_coverage(session, "default 1280x720 map coverage")
	# Real move order from raw tap, distinct group slots, continuous movement.
	session.camera.configure(session.projection, mission, settings)
	session.consume({"kind": &"all_army"})
	session.camera.position = session.projection.to_iso(mission.player_start + Vector2(6, -1))
	session.camera.clamp_view()
	var ground := session.camera.world_to_screen(session.projection.to_iso(mission.player_start + Vector2(16.5, -3.5)))
	check(not session.hud.hits_ui(ground), "integration move target is battlefield, not UI")
	touch(layer, 0, ground, true, 7)
	touch(layer, 0, ground, false, 7.1)
	check(session.marker_left > 0, "raw ground tap issues move and one-second marker")
	var destinations: Dictionary = {}
	for unit in session.selection.selected:
		if not unit.route.is_empty():
			destinations[unit.goal] = true
	check(destinations.size() == 5, "group move allocates five distinct reachable destinations")
	var requests_before := session.paths.requests
	var movement_valid := true
	var group_spacing := INF
	for tick in range(600):
		session.simulate_tick(0.05)
		group_spacing = minf(group_spacing, minimum_spacing(session.units))
		for unit in session.units:
			movement_valid = movement_valid and session.map.passable(session.map.cell_of(unit.logical_position))
	check(group_spacing >= 0.999, "actual army move keeps full spacing around idle Rig and Gatherer")
	check(movement_valid, "30 seconds of group movement never enters blocked terrain")
	var arrived := true
	for unit in session.selection.selected:
		arrived = arrived and unit.route.is_empty() and unit.logical_position.distance_to(unit.goal) < 0.2
	check(arrived, "mixed-speed army arrives around marker without jamming")
	check(session.paths.requests == requests_before, "normal movement does not recompute paths every tick")
	# A changed map invalidates a route, but does not force per-tick re-pathing.
	var lone := session.units[0]
	lone.set_route(session.paths.path(lone.logical_position, mission.player_start + Vector2(13.5, 8.5)))
	var obstacle := session.map.cell_of(lone.route[2])
	session.paths.set_blocked(obstacle, true)
	var replan_before := session.paths.requests
	for tick in range(250):
		session.simulate_tick(0.05)
	check(session.paths.requests > replan_before and lone.route.is_empty() and lone.logical_position.distance_to(lone.goal) < 0.2, "unit re-paths when terrain changes and still reaches its destination")
	session.paths.set_blocked(obstacle, false)
	# Long mission crossing exercises continuous movement around the rocky ridge.
	check(session.commands.issue_move(session.selection.selected, mission.enemy_base) == 5, "long cross-map group order accepted")
	movement_valid = true
	group_spacing = INF
	for tick in range(1400):
		session.simulate_tick(0.05)
		group_spacing = minf(group_spacing, minimum_spacing(session.units))
		for unit in session.selection.selected:
			movement_valid = movement_valid and session.paths.can_traverse(unit.previous_position, unit.logical_position)
	arrived = true
	for unit in session.selection.selected:
		arrived = arrived and unit.route.is_empty() and unit.logical_position.distance_to(unit.goal) < 0.2
	check(group_spacing >= 0.999, "army never stacks while crossing the ridge passes")
	check(movement_valid and arrived, "army crosses ridge and arrives at enemy site using valid continuous paths")
	scene.free()

func step_units(units: Array[UnitMovement], paths: PathService, config: MissionConfig) -> void:
	for unit in units:
		unit.previous_position = unit.logical_position
	for unit in units:
		unit.tick(0.05, paths, units, config)

func minimum_spacing(units: Array[UnitMovement]) -> float:
	var ratio := INF
	for i in range(units.size()):
		for j in range(i + 1, units.size()):
			var a := units[i]
			var b := units[j]
			# Minimum over the whole render interpolation interval, not endpoints only.
			var relative := Geometry2D.get_closest_point_to_segment(Vector2.ZERO,
				a.previous_position - b.previous_position, a.logical_position - b.logical_position)
			ratio = minf(ratio, relative.length() / (a.stats.spacing_radius + b.stats.spacing_radius))
	return ratio

func test_unit_spacing() -> void:
	print("SUITE: swept unit spacing, idle yielding and group arrivals")
	var config := MissionConfig.new()
	config.size = Vector2i(48, 48)
	var paths := PathService.new(MapModel.new(config))
	var iso := IsoProjection.new(Vector2(mission.tile_size))
	var units: Array[UnitMovement] = []
	for i in range(4):
		var unit := UnitMovement.new()
		unit.configure(i + 1, load("res://data/units/jackal.tres" if i == 0 else "res://data/units/ranger.tres"),
			Vector2(10.5, 20.5) if i == 0 else Vector2(14.5 + 4 * i, 20.5), iso)
		units.append(unit)
	var idle_positions := PackedVector2Array()
	for unit in units:
		idle_positions.append(unit.logical_position)
	units[0].set_route(paths.path(units[0].logical_position, Vector2(35.5, 20.5)))
	var minimum := INF
	var yielded := false
	for tick in range(800):
		step_units(units, paths, config)
		minimum = minf(minimum, minimum_spacing(units))
		for i in range(1, units.size()):
			yielded = yielded or units[i].logical_position.distance_to(idle_positions[i]) > 0.1
	print("Idle lane minimum combined-spacing ratio: ", minimum)
	check(minimum >= 0.8, "unit driven through idle Rangers stays above 80% combined spacing including interpolation")
	check(minimum >= 0.999, "swept separation preserves full spacing instead of tolerating visible overlap")
	check(units[0].route.is_empty() and units[0].logical_position.distance_to(units[0].goal) < 0.05, "unit still arrives after passing idle traffic")
	check(yielded, "idle friendly units visibly step aside for passing traffic")
	var settled := true
	for i in range(1, units.size()):
		settled = settled and not units[i].settling and units[i].logical_position.distance_to(idle_positions[i]) < 0.05
	check(settled, "idle units settle back after traffic clears")
	units[0].set_route(paths.path(units[0].logical_position, idle_positions[3]))
	minimum = INF
	for tick in range(400):
		step_units(units, paths, config)
		minimum = minf(minimum, minimum_spacing(units))
	check(units[0].route.is_empty() and units[0].logical_position.distance_to(units[0].goal) < 0.05 and minimum >= 0.999, "move into an occupied idle spot arrives without overlap")
	check(not units[3].settling and units[3].route.is_empty(), "idle friend settles in its new spot when the old one stays occupied")
	for unit in units:
		unit.free()
	units.clear()
	for i in range(8):
		var unit := UnitMovement.new()
		unit.configure(i + 1, load("res://data/units/jackal.tres" if i % 3 == 0 else "res://data/units/ranger.tres"), Vector2(8.5 + (i % 4) * 3, 10.5 + (i / 4) * 4), iso)
		units.append(unit)
	var artwork_fits := true
	for unit in units:
		# Worst compressed isometric axis: sqrt(2) * half-tile-height.
		# Bounds include the offset body and shadow, not selection/text overlays.
		artwork_fits = artwork_fits and unit.stats.spacing_radius * sqrt(2.0) * mission.tile_size.y / 2 >= (28.0 if unit.stats.vehicle else 18.0)
	check(artwork_fits, "spacing radii conservatively enclose the drawn placeholder bodies and shadows")
	var commands := CommandController.new(paths, config)
	check(commands.issue_move(units, Vector2(35.5, 30.5)) == units.size(), "mixed group accepts distinct spaced destinations")
	minimum = INF
	for tick in range(1200):
		step_units(units, paths, config)
		minimum = minf(minimum, minimum_spacing(units))
	var arrived := true
	for unit in units:
		arrived = arrived and unit.route.is_empty() and unit.logical_position.distance_to(unit.goal) < 0.05
	print("Group minimum combined-spacing ratio: ", minimum)
	check(minimum >= 0.999, "group move never stacks units, including render interpolation")
	check(arrived, "mixed-speed group reaches all assigned destinations without jamming")
	for unit in units:
		unit.free()

func _initialize() -> void:
	# An independent watchdog also catches script errors that interrupt a test.
	create_timer(45).timeout.connect(func() -> void:
		push_error("Test runner timed out before completing")
		quit(1))
	call_deferred("run")

func run() -> void:
	test_gestures()
	test_paths()
	test_unit_spacing()
	test_scene()
	await test_native_ui()
	if "--force-failure" in OS.get_cmdline_user_args():
		check(false, "intentional runner exit-code validation")
	print("Results: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)

func test_native_ui() -> void:
	print("SUITE: native touch-to-GUI routing and project settings")
	check(ProjectSettings.get_setting("display/window/handheld/orientation") == DisplayServer.SCREEN_SENSOR_LANDSCAPE, "both landscape directions allowed; portrait disabled")
	check(ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items" and ProjectSettings.get_setting("display/window/stretch/aspect") == "expand", "canvas_items / expand configured")
	check(ProjectSettings.get_setting("physics/common/physics_ticks_per_second") == 20, "gameplay simulation fixed at 20 Hz")
	var version := Engine.get_version_info()
	var exact := "%d.%d.%d.%s.%s.%s" % [version.major, version.minor, version.patch, version.status, version.build, String(version.hash).left(9)]
	check(exact == FileAccess.get_file_as_string("res://GODOT_VERSION").strip_edges(), "running engine matches exact stable version pin")
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	var session: GameSession = scene.get_node("MissionZero")
	await process_frame
	var native_touch := InputEventScreenTouch.new()
	native_touch.index = 0
	native_touch.position = session.hud.buttons[1].get_global_rect().get_center()
	native_touch.pressed = true
	root.push_input(native_touch, true)
	await process_frame
	native_touch = native_touch.duplicate()
	native_touch.pressed = false
	root.push_input(native_touch, true)
	await process_frame
	check(session.selection.selected.size() == 5, "native viewport touch events activate All Army GUI button")
	check(session.marker_left == 0, "GUI-emulated mouse events do not duplicate battlefield orders")
	native_touch = native_touch.duplicate()
	native_touch.position = session.hud.buttons[0].get_global_rect().get_center()
	native_touch.pressed = true
	root.push_input(native_touch, true)
	await process_frame
	native_touch = native_touch.duplicate()
	native_touch.pressed = false
	root.push_input(native_touch, true)
	await process_frame
	check(session.selection.selected.is_empty(), "native viewport touch events activate Deselect GUI button")
	# Test raw two-finger routing through the live input adapter, not only the pure recognizer.
	session.input_layer.set_process(false)
	session.camera.set_process(false)
	var layer := session.input_layer
	layer.recognizer.reset()
	var zoom_before := session.camera.zoom.x
	touch(layer, 0, Vector2(550, 300), true, 10)
	touch(layer, 1, Vector2(700, 400), true, 10.01)
	drag(layer, 1, Vector2(770, 430), 10.05)
	touch(layer, 0, Vector2(550, 300), false, 10.1)
	touch(layer, 1, Vector2(770, 430), false, 10.11)
	check(session.camera.zoom.x > zoom_before and session.marker_left == 0, "raw two-finger pinch zooms without stray move orders")
	var ranger := session.units[1]
	session.camera.zoom = Vector2.ONE * settings.max_zoom
	session.camera.position = session.projection.to_iso(ranger.logical_position)
	session.camera.clamp_view()
	var point := session.unit_screen(ranger)
	touch(layer, 0, point - Vector2(60, 60), true, 11)
	layer.recognizer.advance(11.2)
	check(session.hud.hold_visible and session.hud.hold_progress > 0, "raw hold draws progress ring")
	layer.recognizer.advance(11.41)
	drag(layer, 0, point + Vector2(60, 60), 11.45)
	check(session.hud.box_visible and ranger.previewed, "raw one-finger hold and drag previews a box")
	touch(layer, 0, point + Vector2(60, 60), false, 11.5)
	check(session.selection.selected.has(ranger) and session.marker_left == 0 and not session.hud.hold_visible, "raw held drag commits selection without move orders")
	# A UI touch dragging back to its origin is still cancelled.
	session.consume({"kind": &"deselect"})
	var button_point := session.hud.buttons[1].get_global_rect().get_center()
	touch(layer, 0, button_point, true, 12)
	drag(layer, 0, button_point + Vector2(100, 0), 12.1)
	drag(layer, 0, button_point, 12.2)
	touch(layer, 0, button_point, false, 12.3)
	check(session.selection.selected.is_empty(), "UI drag returning onto a button does not activate it")
	# A wide phone viewport exercises live camera limits and HUD layout.
	var wide := SubViewport.new()
	wide.size = Vector2i(1600, 720)
	root.add_child(wide)
	var wide_scene: Node = load("res://scenes/main.tscn").instantiate()
	wide.add_child(wide_scene)
	var wide_session: GameSession = wide_scene.get_node("MissionZero")
	wide_session.camera.zoom = Vector2.ONE * 0.1
	wide_session.camera.position = wide_session.projection.to_iso(Vector2(0, mission.size.y))
	wide_session.camera.clamp_view()
	var bounds := wide_session.projection.map_bounds(mission.size).grow(settings.camera_border_margin / wide_session.camera.zoom.x + 0.001)
	var bounded := true
	for corner in [Vector2.ZERO, Vector2(1600, 0), Vector2(1600, 720), Vector2(0, 720)]:
		bounded = bounded and bounds.has_point(wide_session.camera.screen_to_world(corner))
	check(bounded and wide_session.camera.view_size() == Vector2(1600, 720), "20:9 camera respects bounded dark border")
	check_cell_coverage(wide_session, "20:9 default-zoom map coverage")
	var hud_fit := true
	for button in wide_session.hud.buttons:
		hud_fit = hud_fit and wide_session.hud.safe_rect().encloses(button.get_global_rect())
	check(hud_fit, "wide-phone HUD keeps buttons within viewport")
	wide.free()
	scene.free()

func check_cell_coverage(session: GameSession, label: String) -> void:
	var missed := 0
	var viewed := 0
	session.camera.zoom = Vector2.ONE * settings.initial_zoom
	for y in range(mission.size.y):
		for x in range(mission.size.x):
			var cell := Vector2i(x, y)
			if not session.map.passable(cell):
				continue
			var rendered := session.projection.to_iso(Vector2(cell) + Vector2(0.5, 0.5))
			session.camera.position = rendered
			session.camera.clamp_view()
			if session.get_viewport_rect().has_point(session.camera.world_to_screen(rendered)):
				viewed += 1
			else:
				missed += 1
	print("Coverage: %s — %d viewed, %d missed" % [label, viewed, missed])
	check(viewed > 0 and missed == 0, label + ": every passable cell can be brought on screen")
	for corner in [Vector2(0.5, 0.5), Vector2(mission.size.x - 0.5, 0.5), Vector2(0.5, mission.size.y - 0.5), Vector2(mission.size) - Vector2(0.5, 0.5)]:
		session.camera.position = session.projection.to_iso(corner)
		session.camera.clamp_view()
		check(session.get_viewport_rect().has_point(session.camera.world_to_screen(session.projection.to_iso(corner))), label + ": corner " + str(corner))
