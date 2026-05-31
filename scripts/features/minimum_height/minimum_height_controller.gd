class_name MinimumHeightController
extends Node


@export var bottom_minimum_height_area: MinimumHeightArea
@export var top_minimum_height_area: MinimumHeightArea

var minimum_height: float:
	get: return _minimum_height
var _minimum_height: float


func _ready() -> void:
	_minimum_height = max(abs(bottom_minimum_height_area.position.y), abs(top_minimum_height_area.position.y))


func is_minimum_height_reached(is_gravity_inverted: bool) -> bool:
	return get_active_minimum_height_area(is_gravity_inverted).is_activated


func get_active_minimum_height_area(is_gravity_inverted: bool):
	return (
		top_minimum_height_area
		if is_gravity_inverted
		else bottom_minimum_height_area
	)


func increase_minimum_height(height: float, is_gravity_inverted: bool):
	var area = get_active_minimum_height_area(is_gravity_inverted)
	var current_height = abs(area.position.y) + height
	resize_minimum_height(current_height, is_gravity_inverted)
	_minimum_height = current_height


func resize_minimum_height(height: float, is_gravity_inverted: bool):
	var offset = (
		height
		if is_gravity_inverted
		else -height
	)
	get_active_minimum_height_area(is_gravity_inverted).position.y = offset
