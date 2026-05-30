class_name OverlayMenu
extends CanvasLayer


@export var animation_player: AnimationPlayer
@export var close_button: Button


func _ready() -> void:
	hide()
	if close_button:
		close_button.pressed.connect(func(): close())


func open():
	if visible: return
	get_viewport().gui_release_focus()
	show()
	animation_player.play("in")


func close():
	if not visible: return
	get_viewport().gui_release_focus()
	animation_player.play("out")
	await animation_player.animation_finished
	hide()
