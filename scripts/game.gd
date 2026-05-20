class_name Game
extends Node2D



@export var piece_manager: PieceManager

# @export var piece_queue_component: PieceQueueComponent
# @export var piece_spawn_controller: PieceSpawnController

@export var camera_controller: CameraController
@export var platform_controller: PlatformController
# @export var placement_preview_controller: PlacementPreviewController

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

# var _placed_pieces: Array[Piece] = []

# var _hold_piece_config: PieceSpawnConfig = null
# var _hold_piece: Piece = null
# var _curr_piece: Piece
# var _curr_piece_pos: Vector2 = Vector2.ZERO
# var _curr_piece_config: PieceSpawnConfig = null

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
	# _hold_piece_config = null
	# _hold_piece = null
	# _curr_piece_config = null
	# _curr_piece = null
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
			platform_controller.resize_platform_distance(piece_manager.placed_pieces, _is_gravity_inverted)
			_turn_count += 1
			GameManager.turn_incremented.emit(_turn_count)
			# if !_curr_piece:
			# 	call_deferred("spawn_piece")
			piece_manager.call_deferred("try_spawn_piece", _is_gravity_inverted)
		GameState.PLACE:
			_place_timer = min_place_time
			piece_manager.reset_settle_timer()
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


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu_toggle"):
		if _state == GameState.PAUSE:
			unpause()
		else:
			pause()
	piece_manager.update_piece_placement_preview(_state == GameState.HOLD, _is_gravity_inverted, get_world_2d())

func _physics_process(delta: float) -> void:
	platform_controller.update_platform_distance(delta)
	camera_controller.call_deferred("update_camera", delta)

	match _state:
		GameState.HOLD:
			if Input.is_action_just_pressed("hold_piece"):
				piece_manager.swap_current_hold_piece(_is_gravity_inverted)
			else:
				if piece_manager.has_current_piece():
					piece_manager.update_current_piece_position(delta, is_gravity_inverted, _mouse_moved, get_global_mouse_position().x)
					if Input.is_action_just_pressed("drop_piece"):
						piece_manager.release_current_piece()
						_set_state(GameState.PLACE)
		GameState.PLACE:
			_place_timer -= delta
			if _place_timer <= 0 && piece_manager.are_pieces_settled(delta, min_settle_time):
				if _turn_count % invert_turn_count == 0:
					_set_state(GameState.INVERT)
				else:
					_set_state(GameState.HOLD)
		GameState.INVERT:
			_place_timer -= delta
			if _place_timer <= 0 && piece_manager.are_pieces_settled(delta, min_settle_time):
				_set_state(GameState.HOLD)
	
	_mouse_moved = false


func invert():
	_is_gravity_inverted = not _is_gravity_inverted
	PhysicsServer2D.area_set_param(
		get_viewport().get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		[Vector2.DOWN, Vector2.UP][int(_is_gravity_inverted)]
	)
	piece_manager.wake_all_pieces()


func lose():
	_set_state(GameState.LOSE)
