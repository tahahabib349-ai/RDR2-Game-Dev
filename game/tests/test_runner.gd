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
	check(count_kind(&"pan_end") == 1 and Vector2(events[-1].velocity).length() > 0, "quick flick retains inertia velocity")
	r = fresh()
	r.down(0, Vector2.ZERO, 0)
	r.motion(0, Vector2(30, 0), 0.1)
	r.up(0, Vector2(30, 0), 1)
	check(events[-1].velocity == Vector2.ZERO, "pause before release suppresses stale inertia")
	r = fresh()
	r.down(0, Vector2(100, 100), 0)
	r.down(1, Vector2(200, 200), 0.01)
	r.advance(0.20)
	check(count_kind(&"box_preview") == 0, "hold measured from second finger, not first")
	r.advance(0.211)
	check(count_kind(&"box_preview") == 1, "still fingers enter box after 0.2 seconds")
	r.motion(1, Vector2(350, 300), 0.25)
	check(count_kind(&"pinch") == 0, "box stays locked while fingers spread")
	r.up(0, Vector2(100, 100), 0.3)
	check(count_kind(&"box_select") == 0, "box waits for both lifts")
	r.motion(1, Vector2(600, 500), 0.31)
	r.up(1, Vector2(600, 500), 0.32)
	check(count_kind(&"box_select") == 1 and events[-1].rect == Rect2(100, 100, 250, 200), "first lift freezes box; second commits it")
	check(count_kind(&"tap") == 0, "second finger cancels pending tap")
	r = fresh()
	r.down(0, Vector2(100, 100), 0)
	r.down(1, Vector2(200, 200), 0.01)
	r.motion(1, Vector2(260, 260), 0.05)
	check(count_kind(&"pinch") == 1 and float(events[-1].factor) > 1, "immediate spread produces zoom")
	r.advance(1)
	r.up(1, Vector2(260, 260), 1.01)
	r.motion(0, Vector2(350, 300), 1.02)
	r.up(0, Vector2(350, 300), 1.1)
	check(count_kind(&"box_preview") == 0 and count_kind(&"tap") == 0 and count_kind(&"pan") == 0, "pinch never becomes box, pan, or tap on remaining finger")
	r = fresh()
	r.down(0, Vector2.ZERO, 0)
	r.down(1, Vector2(100, 100), 0.01)
	r.motion(0, Vector2(10, 0), 0.05)
	r.motion(1, Vector2(110, 100), 0.06)
	r.advance(0.211)
	check(r.mode == &"box", "sub-15 px per-finger hold jitter still boxes")
	r = fresh()
	r.down(0, Vector2.ZERO, 0)
	r.down(1, Vector2(100, 100), 0.01)
	r.up(0, Vector2.ZERO, 0.1)
	r.up(1, Vector2(100, 100), 0.11)
	check(count_kind(&"tap") == 0 and count_kind(&"box_select") == 0, "short two-finger contact gives no order")
	r = fresh()
	r.down(0, Vector2.ZERO, 0)
	r.down(1, Vector2(100, 100), 0.01)
	r.advance(0.25)
	r.down(2, Vector2(200, 200), 0.3)
	r.up(0, Vector2.ZERO, 0.31)
	r.up(1, Vector2(100, 100), 0.32)
	r.up(2, Vector2(200, 200), 0.33)
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
	check(map.config.size == Vector2i(72, 72), "Mission Zero is 72x72")
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
	check(route.size() > 2 and route[-1] == Vector2(60.5, 14.5), "route reaches enemy-base site from player basin")
	var valid := true
	for i in range(route.size()):
		valid = valid and map.passable(map.cell_of(route[i]))
		if i > 0:
			valid = valid and paths.can_traverse(route[i - 1], route[i])
	check(valid, "mission route stays passable and does not cut blocked corners")
	check(paths.path(Vector2(-1, 0), Vector2(10, 10)).is_empty(), "out-of-bounds start rejected")
	check(paths.path(Vector2(12, 58), Vector2(72, 72)).is_empty(), "out-of-bounds destination rejected")
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
	check(session.units.size() == 7, "playable scene spawns seven labelled placeholder units")
	check(session.terrain.get_used_cells().size() == 72 * 72, "TileMapLayer renders all 5184 cells")
	var alignment := true
	for cell in [Vector2i.ZERO, Vector2i(12, 58), Vector2i(60, 14), Vector2i(71, 71)]:
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
	var safe := PhaseOneHUD.fit_safe_area(Rect2(120, 0, 2280, 1020), Vector2(2560, 1080), Vector2(1706.6667, 720))
	check(safe.position.is_equal_approx(Vector2(80, 0)) and is_equal_approx(safe.end.y, 680), "phone notch and home strip convert to design coordinates")
	check(PhaseOneHUD.fit_safe_area(Rect2(), Vector2(1280, 720), Vector2(1280, 720)) == Rect2(0, 0, 1280, 720), "empty desktop safe area falls back to viewport")
	var buttons_fit := true
	for button in session.hud.buttons:
		buttons_fit = buttons_fit and button.size.x >= 80 and button.size.y >= 80 and session.hud.safe_rect().encloses(button.get_global_rect())
	check(buttons_fit, "all buttons are at least 80x80 and inside safe area")
	# Anchor-preserving zoom away from map edges.
	session.camera.position = session.projection.to_iso(Vector2(36, 36))
	session.camera.zoom = Vector2.ONE * 1.5
	session.camera.clamp_view()
	var anchor := Vector2(500, 300)
	var anchor_world := session.camera.screen_to_world(anchor)
	session.camera.consume({"kind": &"pinch", "previous_point": anchor, "point": anchor, "factor": 1.2})
	check(session.camera.screen_to_world(anchor).is_equal_approx(anchor_world), "pinch keeps world point under finger midpoint")
	var within := true
	for location in [Vector2(-100, -100), Vector2(100, 100), Vector2(0, 72), Vector2(72, 0)]:
		session.camera.position = session.projection.to_iso(location)
		session.camera.zoom = Vector2.ONE * 0.1
		session.camera.clamp_view()
		for point in [Vector2.ZERO, Vector2(session.camera.view_size().x, 0), session.camera.view_size(), Vector2(0, session.camera.view_size().y)]:
			var logical := session.projection.to_logical(session.camera.screen_to_world(point))
			within = within and logical.x >= -0.001 and logical.y >= -0.001 and logical.x <= 72.001 and logical.y <= 72.001
	check(within, "camera corners remain inside diamond at every map edge and minimum zoom")
	# Real move order from raw tap, distinct group slots, continuous movement.
	session.camera.configure(session.projection, mission, settings)
	session.consume({"kind": &"all_army"})
	var ground := session.camera.world_to_screen(session.projection.to_iso(Vector2(23.5, 54.5)))
	check(not session.hud.hits_ui(ground), "integration move target is battlefield, not UI")
	touch(layer, 0, ground, true, 6)
	touch(layer, 0, ground, false, 6.1)
	check(session.marker_left > 0, "raw ground tap issues move and one-second marker")
	var destinations: Dictionary = {}
	for unit in session.selection.selected:
		if not unit.route.is_empty():
			destinations[unit.goal] = true
	check(destinations.size() == 5, "group move allocates five distinct reachable destinations")
	var requests_before := session.paths.requests
	var movement_valid := true
	for tick in range(600):
		session.simulate_tick(0.05)
		for unit in session.units:
			movement_valid = movement_valid and session.map.passable(session.map.cell_of(unit.logical_position))
	check(movement_valid, "30 seconds of group movement never enters blocked terrain")
	var arrived := true
	for unit in session.selection.selected:
		arrived = arrived and unit.route.is_empty() and unit.logical_position.distance_to(unit.goal) < 0.2
	check(arrived, "mixed-speed army arrives around marker without jamming")
	check(session.paths.requests == requests_before, "normal movement does not recompute paths every tick")
	# A changed map invalidates a route, but does not force per-tick re-pathing.
	var lone := session.units[0]
	lone.set_route(session.paths.path(lone.logical_position, Vector2(25.5, 60.5)))
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
	for tick in range(1400):
		session.simulate_tick(0.05)
		for unit in session.selection.selected:
			movement_valid = movement_valid and session.paths.can_traverse(unit.previous_position, unit.logical_position)
	arrived = true
	for unit in session.selection.selected:
		arrived = arrived and unit.route.is_empty() and unit.logical_position.distance_to(unit.goal) < 0.2
	check(movement_valid and arrived, "army crosses ridge and arrives at enemy site using valid continuous paths")
	scene.free()

func _initialize() -> void:
	# An independent watchdog also catches script errors that interrupt a test.
	create_timer(45).timeout.connect(func() -> void:
		push_error("Test runner timed out before completing")
		quit(1))
	call_deferred("run")

func run() -> void:
	test_gestures()
	test_paths()
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
	touch(layer, 1, point + Vector2(60, 60), true, 11.01)
	layer.recognizer.advance(11.22)
	check(session.hud.box_visible and ranger.previewed, "raw two-finger hold previews a box around a unit")
	touch(layer, 0, point - Vector2(60, 60), false, 11.3)
	touch(layer, 1, point + Vector2(60, 60), false, 11.31)
	check(session.selection.selected.has(ranger) and session.marker_left == 0, "raw two-finger lifts commit selection without move orders")
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
	wide_session.camera.position = wide_session.projection.to_iso(Vector2(0, 72))
	wide_session.camera.clamp_view()
	var within := true
	for corner in [Vector2.ZERO, Vector2(1600, 0), Vector2(1600, 720), Vector2(0, 720)]:
		var logical := wide_session.projection.to_logical(wide_session.camera.screen_to_world(corner))
		within = within and logical.x >= -0.001 and logical.y >= -0.001 and logical.x <= 72.001 and logical.y <= 72.001
	check(within and wide_session.camera.view_size() == Vector2(1600, 720), "20:9 viewport keeps all four corners inside playable map")
	var hud_fit := true
	for button in wide_session.hud.buttons:
		hud_fit = hud_fit and wide_session.hud.safe_rect().encloses(button.get_global_rect())
	check(hud_fit, "wide-phone HUD keeps buttons within viewport")
	wide.free()
	scene.free()
