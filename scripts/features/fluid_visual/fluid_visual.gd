class_name FluidVisual
extends Sprite2D


@export var fluid_body_sprite: Sprite2D

@export var is_inverted: bool = false


var _target_y: float


func _ready() -> void:
	_target_y = position.y


func set_target_minimum_height(y: float):
	_target_y = (
		y
		if is_inverted
		else -y
	)
	var body_height: float = max(y, 0)
	fluid_body_sprite.region_rect.size.y = max(y, body_height)
	fluid_body_sprite.offset.y = 0.5 * max(y, body_height)


func update_minimum_height(delta: float):
	var t := 1.0 - exp(-delta * 2.0)
	position.y = lerp(position.y, _target_y, t)


func is_settled() -> bool:
	return abs(position.y - _target_y) < 10
