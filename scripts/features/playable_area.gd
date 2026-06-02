class_name PlayableArea
extends Area2D


@export var collision_shape: CollisionShape2D
@export var padding: Vector2 = Vector2(0, 250)

func _ready() -> void:
	body_exited.connect(_on_body_exited)


func update_bounds(pos: Vector2, size: Vector2):
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = size + padding
	collision_shape.shape = rect_shape
	global_position = pos


func _on_body_exited(body: Node2D):
	if SceneManager.is_changing_scene: return
	if not SceneManager.is_game_scene_active: return
	if body is Piece:
		if not body.is_in_hold:
			body.despawn()
