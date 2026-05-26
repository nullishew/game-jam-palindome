class_name PieceQueueComponent
extends Node


var _difficulty_config: DifficultyConfig

var _queue: Array[PieceSpawnConfig] = []
var _curr_piece_index: int = 0

var _generated_turns: int = 0
var _stage_index: int = 0
var _stage_turn_remaining: int = 0


func _ready() -> void:
	_queue.clear()
	_curr_piece_index = 0


func set_difficulty(config: DifficultyConfig):
	_difficulty_config = config

	_stage_index = 0
	_generated_turns = 0

	if config.stages.size() > 0:
		_stage_turn_remaining = config.stages[0].duration_turns


func pop_front() -> PieceSpawnConfig:
	_generate_until(_curr_piece_index + 1)
	var config = _queue[_curr_piece_index]
	_curr_piece_index += 1
	return config


func peek(n: int) -> Array[PieceSpawnConfig]:
	_generate_until(_curr_piece_index + n + 1)
	var arr: Array[PieceSpawnConfig] = []
	for i in range(n):
		var j = _curr_piece_index + i
		arr.append(_queue[j])
	return arr

var _current_cycle: Array[PieceSpawnConfig] = []
var _cycle_index: int = 0

func _generate_until(n: int):

	while _queue.size() < n:

		if _cycle_index >= _current_cycle.size():
			_generate_new_cycle()

		var piece = _current_cycle[_cycle_index]

		_queue.append(piece)

		_cycle_index += 1
		_generated_turns += 1
		_stage_turn_remaining -= 1

		if _stage_turn_remaining <= 0:
			_advance_stage()
func _generate_new_cycle():

	var stage = _difficulty_config.stages[_stage_index]

	_current_cycle = stage.piece_queue_config.piece_spawn_configs.duplicate()

	_current_cycle.shuffle()

	_cycle_index = 0

func _advance_stage():
	if _stage_index + 1 >= _difficulty_config.stages.size():
		return
	_stage_index += 1
	var stage = _difficulty_config.stages[_stage_index]
	_stage_turn_remaining = stage.duration_turns

