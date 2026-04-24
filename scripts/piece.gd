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

var is_player_piece: bool = false


var _was_in_contact: bool = false
var _impact_timer: float = 0
var _prev_vel_y: float = 0
var _was_impact: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_player_piece:
		select_piece()
		GameManager.game.hold(self)
	if impact_texture:
		contact_monitor = true
		max_contacts_reported = 1
	scale_piece(possible_spawn_scale_multipliers.pick_random())


func scale_piece(s: float):
	if override_sprite_scale_hitbox:
		override_sprite_scale_hitbox.scale *= s
	else:
		sprite.scale *= s
	collision_shape.scale *= s
	mass *= s * s


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _impact_timer > 0:
		if not _was_impact:
			AudioManager.play_sound(AudioManager.THUD_SOUND, AudioManager.AudioBus.SFX)
		_was_impact = true
		_impact_timer -= delta
		if impact_texture:
			sprite.texture = impact_texture
	else:
		_was_impact = false
		if linear_velocity.length() > 5 or abs(angular_velocity) > 5:
			if moving_texture:
				sprite.texture = moving_texture
		else:
			if idle_texture:
				sprite.texture = idle_texture

func _integrate_forces(state: PhysicsDirectBodyState2D):
	# detect things falling onto it but not random things elsewhere propagating impulses
	var max_y_impulse := 0.0
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider is Piece:
			var impulse: Vector2 = state.get_contact_impulse(i)
			max_y_impulse = max(max_y_impulse, abs(impulse.y))
			# check that the other body is above this body
			# for direct falling from above edge case where impulse isnt enough
			if GameManager.game.is_gravity_inverted:
				if collider.global_position.y > global_position.y:
					_impact_timer = impact_sprite_time
			else:
				if collider.global_position.y < global_position.y:
					_impact_timer = impact_sprite_time
	if max_y_impulse > 10:
			_impact_timer = impact_sprite_time

	# detect falling onto things
	var vel_along_g: float = abs(linear_velocity.y)
	if _prev_vel_y > 20 and vel_along_g < 2:
		_impact_timer = impact_sprite_time
	_prev_vel_y = vel_along_g
	var in_contact := state.get_contact_count() > 0
	if not _was_in_contact and in_contact and _prev_vel_y > 30:
		_impact_timer = impact_sprite_time
	_was_in_contact = in_contact


func select_piece():
	freeze = true


func release():
	freeze = false


var _prev_collision_mask
var _prev_collision_layer

func hold_piece_hide():
	hide()
	freeze = true
	sleeping = true
	_prev_collision_layer = collision_layer
	_prev_collision_mask = collision_mask
	collision_layer = 0
	collision_mask = 0

func unhold_piece_show(pos: Vector2):
	freeze = true
	sleeping = true
	global_position = pos
	collision_layer = _prev_collision_layer
	collision_mask = _prev_collision_mask
	await get_tree().physics_frame
	call_deferred("show")
	
