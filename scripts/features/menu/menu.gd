extends CanvasLayer


@export var controls_menu_button: Button
@export var settings_menu_button: Button
@export var start_game_button: Button


func _ready() -> void:
	controls_menu_button.pressed.connect(SceneManager.open_controls_menu)
	settings_menu_button.pressed.connect(SceneManager.open_settings_menu)
	start_game_button.pressed.connect(SceneManager.start_game)
