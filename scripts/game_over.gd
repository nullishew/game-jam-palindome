extends CanvasLayer

@export var turn_count_label: Label
@export var menu_btn: Button
@export var replay_btn: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_btn.pressed.connect(SceneManager.open_start_menu)
	replay_btn.pressed.connect(SceneManager.start_game)
	turn_count_label.text = str(GameManager.turns_survived) + " turns"
