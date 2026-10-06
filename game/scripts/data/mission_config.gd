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
@export var slot_spacing: float = 0.75
## Seconds a blocked unit keeps sidestepping to the same side before it may switch.
@export var avoid_side_hold: float = 0.6
## Seconds an idle unit waits after traffic clears before walking back to its spot.
@export var settle_delay: float = 0.75
## ...and only once no moving unit is within this many design px.
@export var settle_clear_px: float = 100.0
## A yielded unit only walks back if it was pushed further than this (design px).
@export var settle_min_px: float = 24.0
## A unit walking back gives up after being blocked this long.
@export var polite_give_up_seconds: float = 0.5
## A unit blocked this long within arrive_crowd_px of its goal stops there instead of pushing.
@export var crowd_arrive_seconds: float = 1.0
@export var arrive_crowd_px: float = 64.0
## Drawn units trail their simulated position by about this long (0 = off), hiding micro-twitches.
@export var visual_smoothing_seconds: float = 0.08
@export var stuck_seconds: float = 2.0
## Units aim straight at route points up to this far ahead when the line is clear.
@export var path_lookahead_cells: float = 12.0
@export var arrival_distance: float = 0.03
