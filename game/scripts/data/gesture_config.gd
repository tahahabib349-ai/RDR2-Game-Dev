class_name GestureConfig
extends Resource

@export var tap_slop: float = 20.0
@export var box_hold_seconds: float = 0.4
@export var box_hold_slop: float = 20.0
## The hold ring only appears after this long, so quick taps never flash a ring.
@export var hold_ring_delay: float = 0.1
@export var double_tap_seconds: float = 0.30
@export var double_tap_distance: float = 40.0
@export var tap_radius: float = 40.0
@export var inertia_seconds: float = 0.3
@export var min_zoom: float = 1.0
@export var max_zoom: float = 2.5
@export var camera_border_margin: float = 48.0
@export var initial_zoom: float = 1.5
@export var wheel_zoom_factor: float = 1.12
@export var minimum_pinch_distance: float = 1.0
@export var marker_seconds: float = 1.0
@export var button_size: float = 80.0
@export var ui_gap: float = 12.0
