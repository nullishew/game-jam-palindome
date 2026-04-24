class_name Transition
extends CanvasLayer

signal in_finished()
signal out_finished()


@export var anim_player: AnimationPlayer


func _ready() -> void:
	anim_player.play("transition")
	# await anim_player.animation_finished
	# in_finished.emit()
	# anim_player.play("out")
	# await anim_player.animation_finished
	# out_finished.emit()


func _on_in_finished():
	in_finished.emit()


func _on_out_finished():
	out_finished.emit()