class_name IsoProjection
extends RefCounted

var tile_size: Vector2

func _init(size: Vector2 = Vector2(64, 32)) -> void:
	tile_size = size

func to_iso(logical: Vector2) -> Vector2:
	return Vector2((logical.x - logical.y) * tile_size.x * 0.5,
		(logical.x + logical.y) * tile_size.y * 0.5)

func to_logical(rendered: Vector2) -> Vector2:
	return Vector2(rendered.x / tile_size.x + rendered.y / tile_size.y,
		rendered.y / tile_size.y - rendered.x / tile_size.x)

func viewport_margin(view_size: Vector2, zoom_level: float) -> float:
	return (view_size.x / tile_size.x + view_size.y / tile_size.y) * 0.5 / zoom_level

func map_bounds(size: Vector2i) -> Rect2:
	var corners := PackedVector2Array([to_iso(Vector2.ZERO), to_iso(Vector2(size.x, 0)),
		to_iso(Vector2(0, size.y)), to_iso(Vector2(size))])
	var bounds := Rect2(corners[0], Vector2.ZERO)
	for corner in corners:
		bounds = bounds.expand(corner)
	return bounds
