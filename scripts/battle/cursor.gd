extends Node2D

@onready var sprite: ColorRect = $CursorSprite

var _target_pos: Vector2 = Vector2.ZERO
var _smooth_speed: float = 12.0

func _ready() -> void:
	_update_visual(Vector2i(roundi(position.x / 64), roundi(position.y / 64)))

func _process(delta: float) -> void:
	if sprite:
		sprite.position = Vector2(-16, -16)

func _update_visual(grid_pos: Vector2i) -> void:
	if sprite:
		sprite.size = Vector2(32, 32)
		sprite.color = Color(1, 1, 0.3, 0.7)
		sprite.position = Vector2(-16, -16)

func move_cursor(direction: Vector2) -> void:
	var new_pos := Vector2i(roundi(position.x / 64) + int(direction.x), roundi(position.y / 64) + int(direction.y))
	position = Vector2(new_pos.x * 64, new_pos.y * 64)

func set_grid_pos(pos: Vector2i) -> void:
	position = Vector2(pos.x * 64, pos.y * 64)

func get_grid_pos() -> Vector2i:
	return Vector2i(roundi(position.x / 64), roundi(position.y / 64))