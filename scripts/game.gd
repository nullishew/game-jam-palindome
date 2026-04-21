class_name Game
extends Node2D

@export var piece_scene: PackedScene
@export var piece_container: Node2D
@export var hold_pos: Vector2 = Vector2(0, -100)
@export var place_time: float = 1
@export var world_container: Node2D
var _held_piece: Piece

var _placed_pieces: Array[Piece] = []

var _place_timer: float = 0
var _is_inverted: bool = false

var _state: GameState


enum GameState {
	HOLD,
	PLACE,
	INVERT,
	WIN,
	LOSE,
}

func _ready() -> void:
	GameManager.game = self
	_set_state(GameState.HOLD)

func _set_state(state: GameState):
	_exit_state(_state)
	_enter_state(state)

func _enter_state(state: GameState):
	match state:
		GameState.HOLD:
			if !_held_piece:
				spawn_piece()
		GameState.PLACE:
			_place_timer = place_time
	_state = state

func _exit_state(state: GameState):
	match state:
		pass

func _physics_process(delta: float) -> void:
	match _state:
		GameState.HOLD:
			if _held_piece:
				_held_piece.position.x += Input.get_axis("ui_left", "ui_right") * 5
				_held_piece.position.x = clamp(_held_piece.position.x, -500, 500)
				if Input.is_action_just_pressed("ui_accept"):
					release(_held_piece)
					_set_state(GameState.PLACE)
		GameState.PLACE:
			_place_timer -= delta
			if _place_timer <= 0:
				_set_state(GameState.HOLD)
			
		GameState.INVERT:
			pass
		GameState.WIN:
			pass
		GameState.LOSE:
			pass

	if Input.is_action_just_pressed("test"):
		call_deferred("invert")

func spawn_piece():
	var piece: Piece = piece_scene.instantiate()
	piece_container.add_child(piece)

func hold(piece: Piece):
	if _held_piece: return
	_held_piece = piece
	piece.hold(hold_pos)

func release(piece: Piece):
	if !_held_piece: return
	_held_piece = null
	piece.release()
	_placed_pieces.append(piece)


func invert():
	_is_inverted = not _is_inverted
	PhysicsServer2D.area_set_param(
		get_viewport().get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		[Vector2.DOWN, Vector2.UP][int(_is_inverted)]
	)
	for piece in _placed_pieces:
		piece.sleeping = false
		piece.linear_velocity = Vector2.ZERO
		piece.angular_velocity = 0
