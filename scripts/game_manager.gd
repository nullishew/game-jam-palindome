extends Node



signal queue_ui_updated(queue: Array[PieceSpawnConfig], start_index: int)
signal turn_incremented(turn_count: int)
signal invert_state_entered()
signal invert_state_exited()
signal saved_piece_updated(piece_config: PieceSpawnConfig)


var game: Game
var hud: HUD

var turns_survived: int
