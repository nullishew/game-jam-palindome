class_name PieceSpawnController
extends Node


@export var piece_container: Node2D


func spawn_piece(config: PieceSpawnConfig, spawn_point: Vector2) -> Piece:
	var piece_scene: PackedScene = config.packed_scene
	var piece: Piece = piece_scene.instantiate()
	piece.is_player_piece = true
	piece.freeze = true
	var offset: Vector2 = Vector2(randf_range(-0.5, 0.5), 0)
	piece.global_position = spawn_point + offset
	piece.global_rotation = randi_range(0, 3) * PI / 2
	offset = Vector2.ZERO
	piece_container.add_child(piece)
	return piece
