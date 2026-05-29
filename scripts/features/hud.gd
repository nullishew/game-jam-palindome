class_name HUD
extends CanvasLayer

@export var next_piece_uis: Array[TextureRect]
@export var hold_slot_ui: TextureRect

@export var score_label: Label
@export var turn_count_label: Label

@export var invert_count_label: Label
@export var invert_arrow_container: Control
@export var invert_arrow: Control
@export var invert_arrow_border: Control

@export var arrow_color: Color
@export var arrow_border_color: Color
@export var invert_arrow_color: Color
@export var invert_arrow_border_color: Color

@export var pause_button: Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.hud = self
	GameManager.queue_ui_updated.connect(_on_queue_ui_updated)
	GameManager.invert_state_entered.connect(
		func(is_gravity_inverted: bool):
			invert_count_label.self_modulate = Color(1, 1, 1, 0)

			var target_rotation = [0, PI][int(is_gravity_inverted)]
			var tween = create_tween()
			tween.tween_property(invert_arrow_container, "rotation", target_rotation, 0.5)

			invert_arrow.self_modulate = invert_arrow_color
			invert_arrow_border.self_modulate = invert_arrow_border_color

	)
	GameManager.invert_state_exited.connect(
		func():
			invert_count_label.self_modulate = Color(1, 1, 1, 1)

			invert_arrow.self_modulate = arrow_color
			invert_arrow_border.self_modulate = arrow_border_color

	)
	GameManager.turn_started.connect(_on_turn_started)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.hold_piece_updated.connect(
		func(piece_config: PieceSpawnConfig):
			hold_slot_ui.texture = piece_config.ui_texture
	)
	pause_button.pressed.connect(func(): GameManager.game.pause())


func _exit_tree() -> void:
	GameManager.hud = null


func _on_queue_ui_updated(queue: Array[PieceSpawnConfig], start_index: int):
	for i in range(next_piece_uis.size()):
		next_piece_uis[i].texture = queue[start_index + i].ui_texture


func _on_turn_started(turn_count: int, stage_turns_remaining: int):
	invert_count_label.text = str(stage_turns_remaining)
	turn_count_label.text = str(turn_count)


func _on_score_updated(score: int):
	score_label.text = str(score)
