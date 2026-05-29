extends Node



signal queue_ui_updated(queue: Array[PieceSpawnConfig], start_index: int)
signal turn_incremented(turn_count: int, stage_turns_remaining: int)
signal invert_state_entered(is_gravity_inverted: bool)
signal invert_state_exited()
signal hold_piece_updated(piece_config: PieceSpawnConfig)
signal gravity_mode_set(mode: GravityController.GravityMode)


signal piece_placed(piece: Piece)
signal piece_lost(piece: Piece)
signal turn_ended()
# signal turn_started()
signal stage_ended(stage: DifficultyStageConfig, placed_pieces: Array[Piece])
# signal stage_started(stage: DifficultyStageConfig)

var game: Game
var hud: HUD

var turns_survived: int
