extends OverlayMenu


@export var turn_count_label: Label
@export var score_label: Label
@export var menu_btn: Button
@export var replay_btn: Button


func _ready() -> void:
	super._ready()
	menu_btn.pressed.connect(SceneManager.open_start_menu)
	replay_btn.pressed.connect(SceneManager.start_game)
	GameManager.game_ended.connect(
		func(game_result: GameResult):
			turn_count_label.text = str(game_result.turn_count)
			score_label.text = str(game_result.score)
	)
