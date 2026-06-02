class_name FluidVisual
extends Sprite2D


@export var fluid_body_sprite: Sprite2D
@export var visual_area: Area2D
@export var visual_area_collision_shape: CollisionShape2D

@export var is_inverted: bool = false

var is_active: bool = true


var _target_y: float


func _ready() -> void:
	_target_y = position.y
	visual_area.body_entered.connect(
		func(body: Node2D):
			if not is_active: return
			if body is Piece:
				AudioManager.play_sound(AudioManager.SPLASH_AUDIO, AudioManager.AudioBus.SFX)
	)


func set_target_minimum_height(y: float):
	_target_y = (
		y
		if is_inverted
		else -y
	)
	var body_height: float = max(y, 0)
	fluid_body_sprite.region_rect.size.y = max(y, body_height)
	fluid_body_sprite.offset.y = 0.5 * max(y, body_height)
	var area_height = fluid_body_sprite.region_rect.size.y + 512
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(3840, area_height)
	visual_area_collision_shape.shape = rect_shape
	visual_area.position.y = 0.5 * area_height


func update_minimum_height(delta: float):
	var t := 1.0 - exp(-delta * 2.0)
	position.y = lerp(position.y, _target_y, t)


func is_settled() -> bool:
	return abs(position.y - _target_y) < 10
