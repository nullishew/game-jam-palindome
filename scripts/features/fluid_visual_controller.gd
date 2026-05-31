class_name FluidVisualController
extends Node


@export var bottom_fluid_visual: FluidVisual
@export var top_fluid_visual: FluidVisual


func set_target_minimum_height(y: float, is_gravity_inverted: bool):
	var bottom_y: float = (
		-300.0
		if is_gravity_inverted
		else y
	)
	var top_y: float = (
		y
		if is_gravity_inverted
		else -300.0
	)
	# var bottom_y: float = y
	# var top_y: float = y
	bottom_fluid_visual.set_target_minimum_height(bottom_y)
	top_fluid_visual.set_target_minimum_height(top_y)


func update_minimum_height(delta: float):
	bottom_fluid_visual.update_minimum_height(delta)
	top_fluid_visual.update_minimum_height(delta)


func is_settled(is_gravity_inverted: bool):
	return (
		top_fluid_visual.is_settled()
		if is_gravity_inverted
		else bottom_fluid_visual.is_settled()
	)
