class_name PlatformController
extends Node


@export var top_platform: Node2D
@export var bottom_platform: Node2D


var _top_platform_target_pos_y: float
var _bottom_platform_target_pos_y: float


func _ready() -> void:
	_top_platform_target_pos_y = top_platform.global_position.y
	_bottom_platform_target_pos_y = bottom_platform.global_position.y



func update_platform_distance(delta: float):
	var t := 1.0 - exp(-delta * 4.0)
	bottom_platform.global_position.y = lerp(bottom_platform.global_position.y, _bottom_platform_target_pos_y, t)
	top_platform.global_position.y = lerp(top_platform.global_position.y, _top_platform_target_pos_y, t)

func resize_platform_distance(placed_pieces: Array[Piece], is_gravity_inverted: bool):
	var top_p: Vector2 = Vector2(-INF, -INF)
	var bottom_p: Vector2 = Vector2(INF, INF)
	for piece in placed_pieces:
		top_p = top_p.max(piece.global_position)
		bottom_p = bottom_p.min(piece.global_position)
	var min_piece_distance_to_platform: float = 300
	if is_gravity_inverted:
		var dist = bottom_platform.global_position.y - top_p.y
		if dist < min_piece_distance_to_platform:
			_bottom_platform_target_pos_y = top_p.y + min_piece_distance_to_platform
	else:
		var dist = bottom_p.y - top_platform.global_position.y
		if dist < min_piece_distance_to_platform:
			_top_platform_target_pos_y = bottom_p.y - min_piece_distance_to_platform
	