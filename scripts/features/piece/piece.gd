class_name Piece
extends RigidBody2D


@export var impact_sprite_time: float = 0.5
@export var sprite: Sprite2D
@export var override_sprite_scale_hitbox: Node2D
@export var collision_shape: Node2D
@export var idle_texture: Texture2D
@export var impact_texture: Texture2D
@export var moving_texture: Texture2D

@export var possible_spawn_scale_multipliers: Array[float] = [1, 1.25, 1.5]


var piece_spawn_config: PieceSpawnConfig:
	get: return _spawn_config

var is_player_piece: bool = false
var is_in_hold: bool = false


var _impact_timer: float = 0
var _prev_velocity: Vector2

var _spawn_config: PieceSpawnConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_player_piece:
		select_piece()
	if impact_texture:
		contact_monitor = true
		max_contacts_reported = 1
	scale_piece(possible_spawn_scale_multipliers.pick_random())


func _process(delta: float) -> void:
	if _impact_timer > 0:
		_impact_timer -= delta
		if impact_texture:
			sprite.texture = impact_texture
	else:
		if linear_velocity.length() > 5 or abs(angular_velocity) > 5:
			if moving_texture:
				sprite.texture = moving_texture
		else:
			if idle_texture:
				sprite.texture = idle_texture


func _physics_process(_delta: float) -> void:
	var speed_before := _prev_velocity.length()
	var speed_after := linear_velocity.length()
	var impact_strength := speed_before - speed_after
	if impact_strength > 50:
		var volume_db := remap(impact_strength, 50.0, 100.0, -20.0, 0.0)
		AudioManager.play_sound(
			AudioManager.THUD_AUDIO,
			AudioManager.AudioBus.SFX,
			clamp(volume_db, -20.0, 0.0)
		)
		_impact_timer = impact_sprite_time
	_prev_velocity = linear_velocity
	

func initialize(spawn_config: PieceSpawnConfig):
	_spawn_config = spawn_config


func is_settled(linear_velocity_threshold: float = 7, angular_velocity_threshold: float = 5) -> bool:
	if linear_velocity.length_squared() > linear_velocity_threshold * linear_velocity_threshold: return false
	if abs(angular_velocity) > angular_velocity_threshold: return false
	return true


func scale_piece(s: float):
	if override_sprite_scale_hitbox:
		override_sprite_scale_hitbox.scale *= s
	else:
		sprite.scale *= s
	collision_shape.scale *= s
	mass *= s * s


func select_piece():
	freeze = true


func release():
	freeze = false


var _prev_collision_mask
var _prev_collision_layer

func enter_hold():
	hide()
	freeze = true
	sleeping = true
	_prev_collision_layer = collision_layer
	_prev_collision_mask = collision_mask
	collision_layer = 0
	collision_mask = 0
	is_in_hold = true

func exit_hold(pos: Vector2):
	freeze = true
	sleeping = true
	global_position = pos
	collision_layer = _prev_collision_layer
	collision_mask = _prev_collision_mask
	await get_tree().physics_frame
	is_in_hold = false
	show.call_deferred()
	

func despawn():
	GameManager.game.piece_manager.unregister_piece(self)
	GameManager.piece_lost.emit(self)
	AudioManager.play_sound(AudioManager.TOWEL_DISPENSER_AUDIO, AudioManager.AudioBus.SFX)
	queue_free.call_deferred()
	