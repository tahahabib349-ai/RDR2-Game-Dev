class_name GroupSlots
extends RefCounted

static func candidates(center: Vector2, count: int, spacing: float) -> PackedVector2Array:
	var result := PackedVector2Array([center])
	var radius := 1
	while result.size() < count:
		for y in range(-radius, radius + 1):
			for x in range(-radius, radius + 1):
				if maxi(absi(x), absi(y)) == radius:
					result.append(center + Vector2(x, y) * spacing)
		radius += 1
	return result
