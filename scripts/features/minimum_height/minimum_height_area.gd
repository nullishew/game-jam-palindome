class_name MinimumHeightArea
extends Area2D


var is_activated: bool:
	get: return _registered_pieces > 0


var _registered_pieces: int = 0


func _ready() -> void:
	_registered_pieces = 0
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D):
	if body is Piece:
		_registered_pieces += 1


func _on_body_exited(body: Node2D):
	if body is Piece:
		_registered_pieces -= 1
