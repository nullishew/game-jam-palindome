class_name Piece
extends RigidBody2D


@export var impact_sprite_time: float = 0.5
@export var sprite: Sprite2D
@export var idle_texture: Texture2D
@export var impact_texture: Texture2D
@export var moving_texture: Texture2D


var is_player_piece: bool = false


var _was_in_contact: bool = false
var _impact_timer: float = 0
var _prev_vel_y: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_player_piece:
		hold()
		GameManager.game.hold(self)
	if impact_texture:
		contact_monitor = true
		max_contacts_reported = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
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


func hold():
	freeze = true


func release():
	freeze = false
