class_name GravityController
extends Node


enum GravityMode {
	NORMAL,
	INVERTED,
}


const GRAVITY_DIR_BY_MODE: Dictionary[GravityMode, Vector2] = {
	GravityMode.NORMAL: Vector2.DOWN,
	GravityMode.INVERTED: Vector2.UP,
}

const OPPOSITE_GRAVITY_MODE: Dictionary[GravityMode, GravityMode] = {
	GravityMode.NORMAL: GravityMode.INVERTED,
	GravityMode.INVERTED: GravityMode.NORMAL,
}


var is_gravity_inverted: bool:
	get: return _gravity_mode == GravityMode.INVERTED

var _gravity_mode: GravityMode = GravityMode.NORMAL


func reset():
	_set_gravity_inversion(GravityMode.NORMAL)


func invert_gravity():
	_set_gravity_inversion(OPPOSITE_GRAVITY_MODE[_gravity_mode])


func _set_gravity_inversion(mode: GravityMode):
	_gravity_mode = mode
	PhysicsServer2D.area_set_param(
		get_viewport().get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		GRAVITY_DIR_BY_MODE[mode]
	)
	GameManager.gravity_mode_set.emit(mode)
