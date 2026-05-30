extends Node



signal queue_ui_updated(queue: Array[PieceSpawnConfig], start_index: int)
signal invert_state_entered(is_gravity_inverted: bool)
signal invert_state_exited()
signal hold_piece_updated(piece_config: PieceSpawnConfig)
signal gravity_mode_set(mode: GravityController.GravityMode)


signal piece_placed(piece: Piece)
signal piece_lost(piece: Piece)
signal turn_ended(turn: int)
signal turn_started(turn_count: int, stage_turns_remaining: int)
signal stage_ended(stage: DifficultyStageConfig, placed_pieces: Array[Piece])
# signal stage_started(stage: DifficultyStageConfig)

signal game_ended(game_result: GameResult)

signal score_updated(score: int)

var game: Game
var hud: HUD
