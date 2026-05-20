class_name PieceManager
extends Node


@export var piece_queue_component: PieceQueueComponent
@export var piece_spawn_controller: PieceSpawnController

@export var piece_container: Node2D



@export var normal_spawnpoint: Node2D
@export var inverted_spawnpoint: Node2D

var placed_pieces: Array[Piece]:
	get: return _placed_pieces
var _placed_pieces: Array[Piece] = []

var _hold_piece_config: PieceSpawnConfig = null
var _hold_piece: Piece = null

var _curr_piece: Piece
var _curr_piece_pos: Vector2 = Vector2.ZERO
var _curr_piece_config: PieceSpawnConfig = null

var _settle_timer: float = 0.0


func _ready() -> void:
	_hold_piece_config = null
	_hold_piece = null
	_curr_piece_config = null
	_curr_piece = null


func release_current_piece():
	if !_curr_piece: return
	var piece = _curr_piece
	_curr_piece = null
	_curr_piece_config = null
	piece.release()
	_placed_pieces.append(piece)

func has_current_piece() -> bool:
	return _curr_piece != null

func update_current_piece_position(delta: float, is_gravity_inverted: bool, mouse_moved: bool, mouse_x: float):
	_curr_piece.position.y = inverted_spawnpoint.global_position.y if is_gravity_inverted else normal_spawnpoint.global_position.y
	if mouse_moved:
		_curr_piece.position.x = mouse_x
	else:
		_curr_piece.position.x += Input.get_axis("move_piece_left", "move_piece_right") * 5
	_curr_piece.position.x = clamp(_curr_piece.position.x, -200, 200)
	_curr_piece_pos = _curr_piece.global_position


func swap_current_hold_piece(is_gravity_inverted: bool):
	var temp_config: PieceSpawnConfig = _hold_piece_config
	_hold_piece_config = _curr_piece_config
	_curr_piece_config = temp_config
	GameManager.hold_piece_updated.emit(_hold_piece_config)
	_curr_piece.enter_hold()
	var temp_piece = _hold_piece
	_hold_piece = _curr_piece
	_curr_piece = null
	if temp_piece:
		temp_piece.exit_hold(_curr_piece_pos)
		_curr_piece = temp_piece
	else:
		call_deferred("spawn_piece", is_gravity_inverted, _curr_piece_pos)

func wake_all_pieces():
	for piece in _placed_pieces:
		piece.sleeping = false
		piece.linear_velocity = Vector2.ZERO
		piece.angular_velocity = 0

func try_spawn_piece(is_gravity_inverted: bool, custom_spawn_point: Vector2 = Vector2.ZERO):
	if _curr_piece: return
	spawn_piece(is_gravity_inverted, custom_spawn_point)



func spawn_piece(is_gravity_inverted: bool, custom_spawn_point: Vector2 = Vector2.ZERO):
	var config = piece_queue_component.pop_front()
	var spawn_point: Vector2 = custom_spawn_point if custom_spawn_point != Vector2.ZERO else [normal_spawnpoint.global_position, inverted_spawnpoint.global_position][int(is_gravity_inverted)]
	_curr_piece_config = config
	_curr_piece = piece_spawn_controller.spawn_piece(config, spawn_point)
	GameManager.queue_ui_updated.emit(piece_queue_component.peek(4), 0)


func reset_settle_timer():
	_settle_timer = 0

func are_pieces_settled(delta: float, min_settle_time: float) -> bool:
	if _are_pieces_settled():
		_settle_timer += delta
	else:
		reset_settle_timer()
	return _settle_timer >= min_settle_time

func _are_pieces_settled() -> bool:
	# for piece in _placed_pieces:
	# 	if !piece.sleeping:
	# 		return false
	# return true
	for piece in _placed_pieces:
		if piece.linear_velocity.length() > 5:
			return false
		if abs(piece.angular_velocity) > 3:
			return false
	return true

@export var placement_preview_controller: PlacementPreviewController

@export var top_platform: Node2D
@export var bottom_platform: Node2D


func update_piece_placement_preview(is_player_turn: bool, is_gravity_inverted: bool, world: World2D):
	if _curr_piece and is_player_turn:
		placement_preview_controller.update_preview(
			Vector2(
				_curr_piece.global_position.x,
				inverted_spawnpoint.global_position.y if is_gravity_inverted else normal_spawnpoint.global_position.y
			),
			Vector2(
				_curr_piece.global_position.x,
				top_platform.global_position.y if is_gravity_inverted else bottom_platform.global_position.y
			),
			world,
			_curr_piece
		)
		placement_preview_controller.show_preview()
	else:
		placement_preview_controller.hide_preview()