class_name UnitStats
extends Resource

@export var type_id: StringName
@export var display_name: String
@export var speed: float
## Personal-space radius in design pixels at zoom 1, measured on screen (isometric view),
## so spacing matches what the player sees. Two units keep footprint_a + footprint_b apart.
@export var footprint_radius: float
@export var army: bool = true
@export var color: Color = Color.WHITE
@export var vehicle: bool = false
