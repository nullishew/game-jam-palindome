class_name Game
extends Node2D

@export var piece_scene: PackedScene
@export var piece_container: Node2D
@export var hold_pos: Vector2 = Vector2(0, -100)
@export var spawn_time: float = 1
var _held_piece: Piece

var _placed_pieces: Array[Piece] = []

var _piece_spawn_timer: float = 0

func _ready() -> void:
	GameManager.game = self

func _physics_process(delta: float) -> void:
	if !_held_piece:
		_piece_spawn_timer -= delta
		if _piece_spawn_timer <= 0:
			spawn_piece()
			_piece_spawn_timer = spawn_time
	if _held_piece:
		_held_piece.global_position.x += Input.get_axis("ui_left", "ui_right")
		_held_piece.global_position.x = clamp(_held_piece.global_position.x, -500, 500)
	if Input.is_action_just_pressed("ui_accept"):
		release(_held_piece)

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
