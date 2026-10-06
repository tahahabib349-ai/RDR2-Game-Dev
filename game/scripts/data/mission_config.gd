class_name MissionConfig
extends Resource

@export var size: Vector2i = Vector2i(108, 108)
@export var tile_size: Vector2i = Vector2i(64, 32)
@export var player_start: Vector2 = Vector2(18, 87)
@export var enemy_base: Vector2 = Vector2(90, 21)
@export var ore_centers: PackedVector2Array
@export var ore_radius: float = 3.0
@export var ridge: PackedVector2Array
@export var ridge_half_width: float = 2.0
@export var central_pass: Vector2 = Vector2(51, 54)
@export var central_pass_radius: float = 3.5
@export var east_cut: Vector2 = Vector2(84.5, 79)
@export var east_cut_radius: float = 3.0
@export var spawn_positions: PackedVector2Array
@export var spawn_types: PackedStringArray
@export var slot_spacing: float = 3.0
@export var separation_strength: float = 3.0
@export var stuck_seconds: float = 2.0
@export var arrival_distance: float = 0.03
