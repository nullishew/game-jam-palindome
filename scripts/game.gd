class_name Game
extends Node2D



@export var piece_queue_component: PieceQueueComponent
@export var piece_spawn_controller: PieceSpawnController

@export var camera_controller: CameraController
@export var platform_controller: PlatformController
@export var placement_preview_controller: PlacementPreviewController

@export var min_place_time: float = 1
@export var world_container: Node2D
@export var piece_container: Node2D
@export var normal_spawnpoint: Node2D
@export var inverted_spawnpoint: Node2D
@export var top_platform: Node2D
@export var bottom_platform: Node2D
@export var min_settle_time: float = 0.5


@export var invert_turn_count: int = 4

var is_game_over: bool:
	get: return _state == GameState.LOSE

var _placed_pieces: Array[Piece] = []

var _hold_piece_config: PieceSpawnConfig = null
var _hold_piece: Piece = null
var _curr_piece: Piece
var _curr_piece_pos: Vector2 = Vector2.ZERO
var _curr_piece_config: PieceSpawnConfig = null

var _place_timer: float = 0
var is_gravity_inverted: bool:
	get: return _is_gravity_inverted
var _is_gravity_inverted: bool = false

var _state: GameState
var _turn_count: int = 0


var _mouse_moved: bool = false

enum GameState {
	HOLD,
	PLACE,
	INVERT,
	LOSE,
	PAUSE,
}

func _ready() -> void:
	camera_controller.make_current() # just to not break physics from the one frame delay breh
	GameManager.game = self
	_is_gravity_inverted = false
	PhysicsServer2D.area_set_param(
		get_viewport().get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		[Vector2.DOWN, Vector2.UP][int(_is_gravity_inverted)]
	)
	_hold_piece_config = null
	_hold_piece = null
	_curr_piece_config = null
	_curr_piece = null
	_set_state(GameState.HOLD)

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_moved = true

func _set_state(state: GameState):
	if state != null:
		_exit_state(_state)
	_enter_state(state)

var _prev_state: GameState
func pause():
	_prev_state = _state
	_set_state(GameState.PAUSE)
func unpause():
	_set_state(_prev_state)



func _enter_state(state: GameState):
	match state:
		GameState.PAUSE:
			SceneManager.open_pause_menu()
		GameState.HOLD:
			platform_controller.resize_platform_distance(_placed_pieces, _is_gravity_inverted)
			_turn_count += 1
			GameManager.turn_incremented.emit(_turn_count)
			if !_curr_piece:
				call_deferred("spawn_piece")
		GameState.PLACE:
			_place_timer = min_place_time
			_settle_timer = 0
		GameState.INVERT:
			_place_timer = min_place_time
			invert()
			GameManager.invert_state_entered.emit(_is_gravity_inverted)
		GameState.LOSE:
			GameManager.turns_survived = _turn_count
			SceneManager.open_game_over_menu()
			AudioManager.play_sound(AudioManager.TOWEL_DISPENSER_SOUND, AudioManager.AudioBus.SFX)
	_state = state


func _exit_state(state: GameState):
	match state:
		GameState.INVERT:
			GameManager.invert_state_exited.emit()
		GameState.PAUSE:
			SceneManager.close_pause_menu()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu_toggle"):
		if _state == GameState.PAUSE:
			unpause()
		else:
			pause()
	if _curr_piece and _state == GameState.HOLD:
		placement_preview_controller.update_preview(
			Vector2(
				_curr_piece.global_position.x,
				inverted_spawnpoint.global_position.y if _is_gravity_inverted else normal_spawnpoint.global_position.y
			),
			Vector2(
				_curr_piece.global_position.x,
				top_platform.global_position.y if _is_gravity_inverted else bottom_platform.global_position.y
			),
			get_world_2d(),
			_curr_piece
		)
		placement_preview_controller.show_preview()
	else:
		placement_preview_controller.hide_preview()


func _physics_process(delta: float) -> void:
	platform_controller.update_platform_distance(delta)
	camera_controller.call_deferred("update_camera", delta)

	match _state:
		GameState.HOLD:
			if Input.is_action_just_pressed("hold_piece"):
				var temp_config: PieceSpawnConfig = _hold_piece_config
				_hold_piece_config = _curr_piece_config
				_curr_piece_config = temp_config
				GameManager.hold_piece_updated.emit(_hold_piece_config)
				_curr_piece.hold_piece_hide()
				var temp_piece = _hold_piece
				_hold_piece = _curr_piece
				_curr_piece = null
				if temp_piece:
					temp_piece.unhold_piece_show(_curr_piece_pos)
					_curr_piece = temp_piece
				else:
					call_deferred("spawn_piece", _curr_piece_pos)
					
			else:
				if _curr_piece:
					_curr_piece.position.y = inverted_spawnpoint.global_position.y if _is_gravity_inverted else normal_spawnpoint.global_position.y
					if _mouse_moved:
						_curr_piece.position.x = get_global_mouse_position().x
					else:
						_curr_piece.position.x += Input.get_axis("move_piece_left", "move_piece_right") * 5
					_curr_piece.position.x = clamp(_curr_piece.position.x, -200, 200)
					_curr_piece_pos = _curr_piece.global_position
					if Input.is_action_just_pressed("drop_piece"):
						release(_curr_piece)
						_set_state(GameState.PLACE)
		GameState.PLACE:
			_place_timer -= delta
			if _place_timer <= 0 && are_pieces_settled(delta):
				if _turn_count % invert_turn_count == 0:
					_set_state(GameState.INVERT)
				else:
					_set_state(GameState.HOLD)
		GameState.INVERT:
			_place_timer -= delta
			if _place_timer <= 0 && are_pieces_settled(delta):
				_set_state(GameState.HOLD)
	
	_mouse_moved = false

func spawn_piece(custom_spawn_point: Vector2 = Vector2.ZERO):
	var config = piece_queue_component.pop_front()
	var spawn_point: Vector2 = custom_spawn_point if custom_spawn_point != Vector2.ZERO else [normal_spawnpoint.global_position, inverted_spawnpoint.global_position][int(_is_gravity_inverted)]
	_curr_piece_config = config
	var _curr_piece = piece_spawn_controller.spawn_piece(config, spawn_point)
	GameManager.queue_ui_updated.emit(piece_queue_component.peek(4), 0)




func hold(piece: Piece):
	if _curr_piece: return
	_curr_piece = piece

func release(piece: Piece):
	if !_curr_piece: return
	_curr_piece = null
	_curr_piece_config = null
	piece.release()
	_placed_pieces.append(piece)



func invert():
	_is_gravity_inverted = not _is_gravity_inverted
	PhysicsServer2D.area_set_param(
		get_viewport().get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		[Vector2.DOWN, Vector2.UP][int(_is_gravity_inverted)]
	)
	for piece in _placed_pieces:
		piece.sleeping = false
		piece.linear_velocity = Vector2.ZERO
		piece.angular_velocity = 0

var _settle_timer: float = 0.0
func are_pieces_settled(delta: float) -> bool:
	# for piece in _placed_pieces:
	# 	if !piece.sleeping:
	# 		return false
	# return true
	for piece in _placed_pieces:
		if piece.linear_velocity.length() > 5:
			_settle_timer = 0
			return false
		if abs(piece.angular_velocity) > 3:
			_settle_timer = 0
			return false
	_settle_timer += delta
	return _settle_timer >= min_settle_time

func lose():
	_set_state(GameState.LOSE)
