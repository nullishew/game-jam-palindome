class_name ScoreConfig
extends Resource


@export var piece_place_bonus: Dictionary[PieceSpawnConfig, int]
@export var piece_loss_penalty: Dictionary[PieceSpawnConfig, int]
@export var turn_end_bonus: int = 100
@export var stage_end_turn_bonus: int = 100
@export var stage_start_piece_bonus: Dictionary[PieceSpawnConfig, int]
@export var stage_end_score_multiplier_increase: float = 0.25
