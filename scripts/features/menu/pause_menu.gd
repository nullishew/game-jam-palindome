class_name PauseMenu
extends OverlayMenu


@export var controls_menu_button: Button
@export var menu_button: Button
@export var resume_button: Button
@export var settings_menu_button: Button


func _ready() -> void:
	super._ready()
	controls_menu_button.pressed.connect(SceneManager.open_controls_menu)
	menu_button.pressed.connect(func(): SceneManager.open_start_menu())
	resume_button.pressed.connect(func(): GameManager.game.unpause())
	settings_menu_button.pressed.connect(SceneManager.open_settings_menu)


func set_vol(bus: AudioManager.AudioBus, val: float):
	AudioServer.set_bus_volume_db(bus, linear_to_db(val) + 10)
