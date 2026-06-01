class_name PieceManager
extends Node


enum SpawnMode {
	TOP,
	BOTTOM,
}


const SPAWN_MODE_BY_GRAVITY_MODE: Dictionary[GravityController.GravityMode, SpawnMode] = {
	GravityController.GravityMode.NORMAL: SpawnMode.TOP,
	GravityController.GravityMode.INVERTED: SpawnMode.BOTTOM,
}


@export var piece_queue_component: PieceQueueComponent
@export var piece_spawn_controller: PieceSpawnController

@export var piece_container: Node2D

@export var top_spawn_point: Node2D
@export var bottom_spawn_point: Node2D


var placed_pieces: Array[Piece]:
	get: return _placed_pieces.duplicate()
var spawn_global_position: Vector2:
	get: return _spawn_points_by_mode[_spawn_mode].global_position
var last_released_piece: Piece:
	get: return _last_released_piece

var _spawn_mode: SpawnMode = SpawnMode.TOP
var _spawn_points_by_mode: Dictionary[SpawnMode, Node2D]

var _placed_pieces: Array[Piece] = []

var _hold_piece_config: PieceSpawnConfig = null
var _hold_piece: Piece = null

var _curr_piece: Piece
var _curr_piece_pos: Vector2 = Vector2.ZERO
var _curr_piece_config: PieceSpawnConfig = null

var _last_released_piece: Piece = null

var _settle_timer: float = 0.0


func _init() -> void:
	GameManager.gravity_mode_set.connect(_on_gravity_mode_set)
	GameManager.piece_placed.connect(
		func(piece): 
			_placed_pieces.append(piece)
	)
	GameManager.piece_lost.connect(
		func(piece):
			if _last_released_piece == piece:
				_last_released_piece = null
	)


func _on_gravity_mode_set(mode: GravityController.GravityMode):
	set_spawn_mode(SPAWN_MODE_BY_GRAVITY_MODE[mode])
	wake_all_pieces()


func _ready() -> void:
	_spawn_points_by_mode = {
		SpawnMode.BOTTOM: bottom_spawn_point,
		SpawnMode.TOP: top_spawn_point,
	}

	_hold_piece_config = null
	_hold_piece = null
	_curr_piece_config = null
	_curr_piece = null


func initialize(it: DifficultyStageIterator):
	piece_queue_component.initialize(it)


func set_spawn_mode(mode: SpawnMode):
	_spawn_mode = mode


func release_current_piece():
	if !_curr_piece: return
	var piece = _curr_piece
	_curr_piece = null
	_curr_piece_config = null
	piece.release()
	_last_released_piece = piece


func has_current_piece() -> bool:
	return _curr_piece != null


func update_current_piece_position(delta: float, mouse_moved: bool, mouse_x: float):
	_curr_piece.position.y = spawn_global_position.y
	if mouse_moved:
		_curr_piece.position.x = mouse_x
	else:
		_curr_piece.position.x += Input.get_axis("move_piece_left", "move_piece_right") * 200 * delta
	_curr_piece.position.x = clamp(_curr_piece.position.x, -200, 200)
	_curr_piece_pos = _curr_piece.global_position


func swap_current_hold_piece():
	var temp_config: PieceSpawnConfig = _hold_piece_config
	var temp_piece: Piece = _hold_piece
	_hold_piece_config = _curr_piece_config
	_hold_piece = _curr_piece
	GameManager.hold_piece_updated.emit(_hold_piece_config)
	_curr_piece.enter_hold()
	if temp_config:
		_curr_piece_config = temp_config
		temp_piece.exit_hold(_curr_piece_pos)
		_curr_piece = temp_piece
	else:
		_curr_piece = null
		spawn_piece.call_deferred(_curr_piece_pos)


func wake_all_pieces():
	for piece in _placed_pieces:
		piece.sleeping = false
		piece.linear_velocity = Vector2.ZERO
		piece.angular_velocity = 0


func spawn_piece(custom_spawn_point: Vector2 = Vector2.ZERO):
	var config = piece_queue_component.pop_front()
	var spawn_point: Vector2 = custom_spawn_point if custom_spawn_point != Vector2.ZERO else spawn_global_position
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
	if _last_released_piece and not _last_released_piece.is_settled(): return false
	for piece in _placed_pieces:
		if not piece.is_settled():
			return false
	return true


func unregister_piece(piece: Piece):
	_placed_pieces.erase(piece)

@export var placement_preview_controller: PlacementPreviewController


func update_piece_placement_preview(is_player_turn: bool, world: World2D, active_platform_y: float):
	if _curr_piece and is_player_turn:
		placement_preview_controller.update_preview(
			Vector2(_curr_piece.global_position.x, spawn_global_position.y),
			Vector2(_curr_piece.global_position.x, active_platform_y),
			world,
			_curr_piece
		)
		placement_preview_controller.show_preview()
	else:
		placement_preview_controller.hide_preview()
