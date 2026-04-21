class_name Piece
extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze = true
	GameManager.game.hold(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func hold(pos: Vector2):
	global_position = pos
	freeze = true

func release():
	freeze = false