class_name Game
extends Node2D

@export var turns_to_win: int = 15

@export var piece_scenes: Array[PackedScene]

@export var cam: Camera2D
@export var min_place_time: float = 1
@export var world_container: Node2D
@export var piece_container: Node2D
@export var normal_spawnpoint: Node2D
@export var inverted_spawnpoint: Node2D
@export var top_platform: Node2D
@export var bottom_platform: Node2D


var _unused_pieces: Array[PackedScene]
var _placed_pieces: Array[Piece] = []
var _held_piece: Piece

var _place_timer: float = 0
var _is_gravity_inverted: bool = false

var _state: GameState
var _turn_count: int = 0


enum GameState {
	HOLD,
	PLACE,
	INVERT,
	WIN,
	LOSE,
}

func _ready() -> void:
	cam.make_current() # just to not break physics from the one frame delay breh
	GameManager.game = self
	_is_gravity_inverted = false
	PhysicsServer2D.area_set_param(
		get_viewport().get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		[Vector2.DOWN, Vector2.UP][int(_is_gravity_inverted)]
	)
	_set_state(GameState.HOLD)

func _set_state(state: GameState):
	if state != null:
		_exit_state(_state)
	_enter_state(state)

func _enter_state(state: GameState):
	match state:
		GameState.HOLD:
			if _turn_count >= turns_to_win:
				_set_state(GameState.WIN)
				return
			_turn_count += 1
			resize_platforms()
			if !_held_piece:
				call_deferred("spawn_piece")
		GameState.PLACE:
			_place_timer = min_place_time
		GameState.INVERT:
			_place_timer = min_place_time
			invert()
		GameState.WIN:
			GameManager.is_win = true
			SceneManager.open_game_over_menu()
			# print("you win")
		GameState.LOSE:
			GameManager.is_win = false
			SceneManager.open_game_over_menu()
			# print("you lose")
			pass
	_state = state

func _exit_state(state: GameState):
	match state:
		pass

func _physics_process(delta: float) -> void:
	call_deferred("update_camera", delta)
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
			if _place_timer <= 0 && are_pieces_settled():
				if _turn_count % 3 == 0:
					_set_state(GameState.INVERT)
				else:
					_set_state(GameState.HOLD)
		GameState.INVERT:
			_place_timer -= delta
			if _place_timer <= 0 && are_pieces_settled():
				_set_state(GameState.HOLD)

func spawn_piece():
	if !_unused_pieces or _unused_pieces.size() == 0:
		_unused_pieces = piece_scenes.duplicate()
	var piece_scene: PackedScene = _unused_pieces.pop_at(randi_range(0, _unused_pieces.size() - 1))
	var piece: Piece = piece_scene.instantiate()
	piece.freeze = true
	var spawnpoint: Vector2 = [normal_spawnpoint.global_position, inverted_spawnpoint.global_position][int(_is_gravity_inverted)]
	var offset: Vector2 = Vector2(randf_range(-0.5, 0.5), 0)
	piece.global_position = spawnpoint + offset
	piece.global_rotation = randi_range(0, 3) * PI / 2
	offset = Vector2.ZERO
	piece_container.add_child(piece)

func hold(piece: Piece):
	if _held_piece: return
	_held_piece = piece

func release(piece: Piece):
	if !_held_piece: return
	_held_piece = null
	piece.release()
	_placed_pieces.append(piece)


func resize_platforms():
	var top_p: Vector2 = Vector2(-INF, -INF)
	var bottom_p: Vector2 = Vector2(INF, INF)
	for piece in _placed_pieces:
		top_p = top_p.max(piece.global_position)
		bottom_p = bottom_p.min(piece.global_position)
	var min_piece_distance_to_platform: float = 400
	if _is_gravity_inverted:
		var dist = bottom_platform.global_position.y - top_p.y
		if dist < min_piece_distance_to_platform:
			bottom_platform.global_position.y = top_p.y + min_piece_distance_to_platform
	else:
		var dist = bottom_p.y - top_platform.global_position.y
		if dist < min_piece_distance_to_platform:
			top_platform.global_position.y = bottom_p.y - min_piece_distance_to_platform

var _target_cam_zoom: Vector2
var _target_cam_pos: Vector2

func update_camera(delta: float):
	var top_y = top_platform.global_position.y
	var bottom_y = bottom_platform.global_position.y

	var center_y = (top_y + bottom_y) / 2.0
	# cam.global_position.y = center_y

	var padding = 50.0
	var height = abs(top_y - bottom_y) + padding
	var viewport_height = get_viewport_rect().size.y
	var zoom = viewport_height / height 
	# cam.zoom = Vector2(zoom, zoom)

	_target_cam_zoom = Vector2(zoom, zoom)
	_target_cam_pos = Vector2(0, center_y)

	var t := 1.0 - exp(-delta * 4.0)
	cam.zoom = cam.zoom.lerp(_target_cam_zoom, t)
	cam.global_position = cam.global_position.lerp(_target_cam_pos, t)




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

func are_pieces_settled() -> bool:
	for piece in _placed_pieces:
		if !piece.sleeping:
			return false
	return true

func lose():
	_set_state(GameState.LOSE)
