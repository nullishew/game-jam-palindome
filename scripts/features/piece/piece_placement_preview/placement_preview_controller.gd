class_name PlacementPreviewController
extends Node

@export var line: Line2D


func update_preview(from: Vector2, to: Vector2, world: World2D, piece: Piece):
	var points = PackedVector2Array()
	var raycast_to := _raycast(from, to, world, piece)
	points.append(line.to_local(from))
	points.append(line.to_local(raycast_to))
	line.points = points


func show_preview():
	line.visible = true


func hide_preview():
	line.visible = false


func _raycast(from: Vector2, to: Vector2, world: World2D, piece: Piece) -> Vector2:
	var space = world.direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [piece]
	var result = space.intersect_ray(query)
	return result.position if result else to
