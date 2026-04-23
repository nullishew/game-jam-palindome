class_name HUD
extends CanvasLayer

@export var next_piece_uis: Array[TextureRect]
@export var save_slot_ui: TextureRect

@export var invert_count_label: Label
@export var invert_count_container: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.hud = self
	GameManager.queue_ui_updated.connect(_on_queue_ui_updated)
	GameManager.invert_state_entered.connect(
		func():
			invert_count_container.modulate = Color(1, 0, 0, 0.5)
			invert_count_label.visible = false
	)
	GameManager.invert_state_exited.connect(
		func():
			invert_count_container.modulate = Color(1, 1, 1, 1)
			invert_count_label.visible = true
	)
	GameManager.turn_incremented.connect(_on_turn_incremented)
	GameManager.saved_piece_updated.connect(
		func(piece_config: PieceSpawnConfig):
			save_slot_ui.texture = piece_config.ui_texture
	)


func _exit_tree() -> void:
	GameManager.hud = null

func _on_queue_ui_updated(queue: Array[PieceSpawnConfig], start_index: int):
	for i in range(next_piece_uis.size()):
		next_piece_uis[i].texture = queue[start_index + i].ui_texture

func _on_turn_incremented(turn_count: int):
	invert_count_label.text = str(1 + wrap(-turn_count, 0, GameManager.game.invert_turn_count))
