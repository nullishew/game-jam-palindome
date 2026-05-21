class_name PauseMenu
extends CanvasLayer

@export var resume_button: Button
@export var menu_button: Button
@export var animation_player: AnimationPlayer

@export var sfx_slider: HSlider
@export var soundtrack_slider: HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_button.pressed.connect(func(): SceneManager.open_start_menu())
	resume_button.pressed.connect(func(): GameManager.game.unpause())
	set_vol(AudioManager.AudioBus.SFX, sfx_slider.value / 100.0)
	set_vol(AudioManager.AudioBus.SOUNDTRACK, soundtrack_slider.value / 100.0)
	sfx_slider.value_changed.connect(func(val): set_vol(AudioManager.AudioBus.SFX, val / 100.0))
	soundtrack_slider.value_changed.connect(func(val): set_vol(AudioManager.AudioBus.SOUNDTRACK, val / 100.0))


	

func set_vol(bus: AudioManager.AudioBus, val: float):
	AudioServer.set_bus_volume_db(bus, linear_to_db(val) + 10)

func open():
	visible = true
	animation_player.play("in")

func close():
	animation_player.play("out")
	await animation_player.animation_finished
	visible = false
