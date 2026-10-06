class_name MapModel
extends RefCounted

var config: MissionConfig
var blocked: Dictionary = {}

func _init(mission: MissionConfig) -> void:
	config = mission
	for y in range(config.size.y):
		for x in range(config.size.x):
			var cell := Vector2i(x, y)
			var center := Vector2(cell) + Vector2(0.5, 0.5)
			if (center - config.central_pass).abs().x <= config.central_pass_radius and (center - config.central_pass).abs().y <= config.central_pass_radius:
				continue
			if (center - config.east_cut).abs().x <= config.east_cut_radius and (center - config.east_cut).abs().y <= config.east_cut_radius:
				continue
			for i in range(config.ridge.size() - 1):
				var nearest := Geometry2D.get_closest_point_to_segment(center, config.ridge[i], config.ridge[i + 1])
				if center.distance_to(nearest) <= config.ridge_half_width:
					blocked[cell] = true
					break

func contains(cell: Vector2i) -> bool:
	return Rect2i(Vector2i.ZERO, config.size).has_point(cell)

func passable(cell: Vector2i) -> bool:
	return contains(cell) and not blocked.has(cell)

func cell_of(position: Vector2) -> Vector2i:
	return Vector2i(position.floor())

func is_ore(cell: Vector2i) -> bool:
	for center in config.ore_centers:
		if (Vector2(cell) + Vector2(0.5, 0.5)).distance_to(center) <= config.ore_radius:
			return true
	return false
