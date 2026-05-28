class_name Game
extends Node2D


@export var piece_manager: PieceManager
@export var gravity_controller: GravityController
@export var camera_controller: CameraController
@export var platform_controller: PlatformController

@export var min_place_time: float = 1
@export var min_settle_time: float = 0.5

@export var invert_turn_count: int = 4
@export var difficulty_config: DifficultyConfig


var is_game_over: bool:
	get: return _state == GameState.LOSE


var _is_mouse_button_input_unhandled: bool = false
var _mouse_moved: bool = false

var _place_timer: float = 0

var _state: GameState
var _prev_state: GameState

var _turn_count: int = 0

var _difficulty_stage_it: DifficultyStageIterator
var _current_difficulty_stage: DifficultyStageConfig


enum GameState {
	PREPARE_TURN,
	AIM,
	SETTLE,
	INVERT,
	LOSE,
	PAUSE,
}


func _ready() -> void:
	camera_controller.make_current() # just to not break physics from the one frame delay breh
	GameManager.game = self
	gravity_controller.reset()
	_is_mouse_button_input_unhandled = false
	set_difficulty(difficulty_config)
	_set_state(GameState.PREPARE_TURN)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu_toggle"):
		if _state == GameState.PAUSE:
			unpause()
		else:
			pause()
	piece_manager.update_piece_placement_preview(
		_state == GameState.AIM,
		get_world_2d(),
		platform_controller.get_active_platform(gravity_controller.is_gravity_inverted).global_position.y
	)


func _physics_process(delta: float) -> void:
	platform_controller.update_platform_distance(delta)
	camera_controller.call_deferred("update_camera", delta)

	match _state:
		GameState.PREPARE_TURN:
			if platform_controller.is_settled(gravity_controller.is_gravity_inverted):
				_set_state(GameState.AIM)
		GameState.AIM:
			if Input.is_action_just_pressed("hold_piece"):
				piece_manager.swap_current_hold_piece()
			else:
				if piece_manager.has_current_piece():
					piece_manager.update_current_piece_position(delta, _mouse_moved, get_global_mouse_position().x)
					if _is_mouse_button_input_unhandled and Input.is_action_just_pressed("drop_piece"):
						piece_manager.release_current_piece()
						_set_state(GameState.SETTLE)
		GameState.SETTLE:
			_place_timer -= delta
			if _place_timer <= 0 && piece_manager.are_pieces_settled(delta, min_settle_time):
				if _difficulty_stage_it.is_stage_end:
					_set_state(GameState.INVERT)
				else:
					_set_state(GameState.PREPARE_TURN)
		GameState.INVERT:
			_place_timer -= delta
			if _place_timer <= 0 && piece_manager.are_pieces_settled(delta, min_settle_time):
				_set_state(GameState.PREPARE_TURN)
	
	_mouse_moved = false
	_is_mouse_button_input_unhandled = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_moved = true
	if event is InputEventMouseButton:
		_is_mouse_button_input_unhandled = true


func _enter_state(state: GameState):
	match state:
		GameState.PREPARE_TURN:
			platform_controller.resize_platform_distance(piece_manager.placed_pieces, gravity_controller.is_gravity_inverted)
			_current_difficulty_stage = _difficulty_stage_it.next()
			GameManager.turn_incremented.emit(_turn_count, _difficulty_stage_it.remaining_stage_turns)
			_turn_count += 1
		GameState.PAUSE:
			SceneManager.open_pause_menu()
		GameState.AIM:
			if not piece_manager.has_current_piece():
				piece_manager.call_deferred("spawn_piece")
		GameState.SETTLE:
			_place_timer = min_place_time
			piece_manager.reset_settle_timer()
		GameState.INVERT:
			_place_timer = min_place_time
			gravity_controller.invert_gravity()
			GameManager.invert_state_entered.emit(gravity_controller.is_gravity_inverted)
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


func _set_state(state: GameState):
	if state != null:
		_exit_state(_state)
	_enter_state(state)


func pause():
	_prev_state = _state
	_set_state(GameState.PAUSE)


func unpause():
	_set_state(_prev_state)


func set_difficulty(config: DifficultyConfig):
	var it = DifficultyStageIterator.new(config)
	_difficulty_stage_it = it
	piece_manager.initialize(it)


func lose():
	_set_state(GameState.LOSE)
