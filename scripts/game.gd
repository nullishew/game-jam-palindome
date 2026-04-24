class_name Game
extends Node2D

@export var line: Line2D

@export var piece_configs: Array[PieceSpawnConfig]

@export var cam: Camera2D
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

var _piece_sequence: Array[PieceSpawnConfig] = []
var _placed_pieces: Array[Piece] = []

var _hold_piece_config: PieceSpawnConfig = null
var _hold_piece: Piece = null
var _curr_piece_index: int = -1
var _curr_piece: Piece
var _curr_piece_pos: Vector2 = Vector2.ZERO

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
	cam.make_current() # just to not break physics from the one frame delay breh
	GameManager.game = self
	_is_gravity_inverted = false
	_piece_sequence.clear()
	_curr_piece_index = -1
	PhysicsServer2D.area_set_param(
		get_viewport().get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		[Vector2.DOWN, Vector2.UP][int(_is_gravity_inverted)]
	)
	_top_platform_target_pos_y = top_platform.global_position.y
	_bottom_platform_target_pos_y = bottom_platform.global_position.y
	_hold_piece_config = null
	_hold_piece = null
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
			resize_platforms()
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
		

func _raycast(from: Vector2, to: Vector2) -> Vector2:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [_curr_piece]
	var result = space.intersect_ray(query)
	return result.position if result else to

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu_toggle"):
		if _state == GameState.PAUSE:
			unpause()
		else:
			pause()
	if _curr_piece and _state == GameState.HOLD:
		var points = PackedVector2Array()
		var from_y := inverted_spawnpoint.global_position.y if _is_gravity_inverted else normal_spawnpoint.global_position.y
		var from: Vector2 = Vector2(_curr_piece.global_position.x, from_y)
		var max_y := top_platform.global_position.y if _is_gravity_inverted else bottom_platform.global_position.y
		var to := _raycast(from, Vector2(_curr_piece.global_position.x, max_y))
		points.append(line.to_local(from))
		points.append(line.to_local(to))
		line.points = points

		line.visible = true
	else:
		line.visible = false

func _physics_process(delta: float) -> void:
	

	update_platform_size(delta)
	call_deferred("update_camera", delta)

	match _state:
		GameState.HOLD:
			if Input.is_action_just_pressed("hold_piece"):
				if _curr_piece:
					var temp_config: PieceSpawnConfig = _hold_piece_config
					_hold_piece_config = _piece_sequence[_curr_piece_index]
					_piece_sequence[_curr_piece_index] = temp_config
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
	_curr_piece_index += 1
	while _piece_sequence.size() < _curr_piece_index + 5:
		var next_cycle: Array[PieceSpawnConfig] = piece_configs.duplicate()
		next_cycle.shuffle()
		_piece_sequence.append_array(next_cycle)
	var piece_scene: PackedScene =_piece_sequence[_curr_piece_index].packed_scene
	var piece: Piece = piece_scene.instantiate()
	piece.is_player_piece = true
	piece.freeze = true
	var spawnpoint: Vector2 = custom_spawn_point if custom_spawn_point != Vector2.ZERO else [normal_spawnpoint.global_position, inverted_spawnpoint.global_position][int(_is_gravity_inverted)]
	var offset: Vector2 = Vector2(randf_range(-0.5, 0.5), 0)
	piece.global_position = spawnpoint + offset
	piece.global_rotation = randi_range(0, 3) * PI / 2
	offset = Vector2.ZERO
	piece_container.add_child(piece)

	GameManager.queue_ui_updated.emit(_piece_sequence, _curr_piece_index + 1)



func hold(piece: Piece):
	if _curr_piece: return
	_curr_piece = piece

func release(piece: Piece):
	if !_curr_piece: return
	_curr_piece = null
	piece.release()
	_placed_pieces.append(piece)

var _top_platform_target_pos_y: float
var _bottom_platform_target_pos_y: float

func update_platform_size(delta: float):
	var t := 1.0 - exp(-delta * 4.0)
	bottom_platform.global_position.y = lerp(bottom_platform.global_position.y, _bottom_platform_target_pos_y, t)
	top_platform.global_position.y = lerp(top_platform.global_position.y, _top_platform_target_pos_y, t)

func resize_platforms():
	var top_p: Vector2 = Vector2(-INF, -INF)
	var bottom_p: Vector2 = Vector2(INF, INF)
	for piece in _placed_pieces:
		top_p = top_p.max(piece.global_position)
		bottom_p = bottom_p.min(piece.global_position)
	var min_piece_distance_to_platform: float = 300
	if _is_gravity_inverted:
		var dist = bottom_platform.global_position.y - top_p.y
		if dist < min_piece_distance_to_platform:
			_bottom_platform_target_pos_y = top_p.y + min_piece_distance_to_platform
	else:
		var dist = bottom_p.y - top_platform.global_position.y
		if dist < min_piece_distance_to_platform:
			_top_platform_target_pos_y = bottom_p.y - min_piece_distance_to_platform
	
	


var _target_cam_zoom: Vector2
var _target_cam_pos: Vector2

func update_camera(delta: float):
	var top_y = top_platform.global_position.y
	var bottom_y = bottom_platform.global_position.y

	var center_y = (top_y + bottom_y) / 2.0
	_target_cam_pos = Vector2(0, center_y)

	var padding = 100
	var height = abs(top_y - bottom_y) + padding
	var viewport_height = cam.get_viewport_rect().size.y
	var zoom = viewport_height / height 
	_target_cam_zoom = Vector2(zoom, zoom)

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
