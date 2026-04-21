extends CanvasLayer

@export var win_label: Label
@export var lose_label: Label
@export var menu_btn: Button
@export var replay_btn: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_btn.pressed.connect(SceneManager.open_start_menu)
	replay_btn.pressed.connect(SceneManager.start_game)
	if GameManager.is_win:
		lose_label.visible = false
		win_label.visible = true
	else:
		lose_label.visible = true
		win_label.visible = false
