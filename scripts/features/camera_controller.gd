class_name CameraController
extends Camera2D


@export var top_platform: Node2D
@export var bottom_platform: Node2D
@export var padding_y: float = 100

var _target_cam_zoom: Vector2
var _target_cam_pos: Vector2


func update_camera(delta: float):
	var top_y = top_platform.global_position.y
	var bottom_y = bottom_platform.global_position.y

	var center_y = (top_y + bottom_y) / 2.0
	_target_cam_pos = Vector2(0, center_y)

	var height = abs(top_y - bottom_y) + padding_y
	var viewport_height = get_viewport_rect().size.y
	var zoom_scale = viewport_height / height 
	_target_cam_zoom = Vector2(zoom_scale, zoom_scale)

	var t := 1.0 - exp(-delta * 4.0)
	zoom = zoom.lerp(_target_cam_zoom, t)
	global_position = global_position.lerp(_target_cam_pos, t)
