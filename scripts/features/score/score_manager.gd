class_name ScoreManager
extends Node


@export var config: ScoreConfig


var score: int:
	get: return _score


var _score: int = 0
var _score_multiplier: float = 1


func _ready() -> void:
	GameManager.piece_lost.connect(_on_piece_lost)
	GameManager.piece_placed.connect(_on_piece_placed)
	GameManager.turn_ended.connect(_on_turn_ended)
	GameManager.stage_ended.connect(_on_stage_ended)


func _on_piece_lost(piece: Piece):
	if piece.piece_spawn_config in config.piece_loss_penalty:
		_add_base_score(-config.piece_loss_penalty[piece.piece_spawn_config])


func _on_piece_placed(piece: Piece):
	if piece.piece_spawn_config in config.piece_place_bonus:
		_add_base_score(config.piece_place_bonus[piece.piece_spawn_config])


func _on_turn_ended():
	_add_base_score(config.turn_end_bonus)


func _on_stage_ended(stage: DifficultyStageConfig, placed_pieces: Array[Piece]):
	_add_base_score(config.stage_end_turn_bonus * stage.duration_turns)
	for piece in placed_pieces:
		if piece.piece_spawn_config in config.stage_end_piece_bonus:
			_add_base_score(config.stage_end_piece_bonus[piece.piece_spawn_config])
	_score_multiplier += config.stage_end_score_multiplier_increase


func _add_base_score(base_score: int):
	_score += int(base_score * _score_multiplier)
	print("Score now: " + str(score))
