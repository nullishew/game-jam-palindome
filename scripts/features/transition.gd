class_name Transition
extends CanvasLayer

signal in_finished()
signal out_finished()


@export var anim_player: AnimationPlayer

func _ready() -> void:
	hide()

func transition():
	show()
	anim_player.play("transition")
	await get_tree().create_timer(0.2).timeout
	AudioManager.play_sound(AudioManager.TRANSITION_AUDIO, AudioManager.AudioBus.SFX)
	await anim_player.animation_finished



func _on_in_finished():
	in_finished.emit()
	pause()


func _on_out_finished():
	out_finished.emit()
	hide()

func pause():
	anim_player.pause()

func resume():
	anim_player.play()
