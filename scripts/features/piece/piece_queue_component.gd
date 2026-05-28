class_name PieceQueueComponent
extends Node


var _piece_generator: PieceGenerator
var _queue: Array[PieceSpawnConfig] = []
var _curr_piece_index: int = 0


func _ready() -> void:
	_queue.clear()
	_curr_piece_index = 0


func initialize(it: DifficultyStageIterator):
	_piece_generator = PieceGenerator.new(it)


func pop_front() -> PieceSpawnConfig:
	var piece := _get_piece(_curr_piece_index)
	_curr_piece_index += 1
	return piece


func peek(n: int) -> Array[PieceSpawnConfig]:
	var arr: Array[PieceSpawnConfig] = []
	for i in range(n):
		arr.append(_get_piece(_curr_piece_index + i))
	return arr


func _get_piece(i: int) -> PieceSpawnConfig:
	while _queue.size() <= i:
		_queue.append(_piece_generator.next())
	return _queue[i]


class PieceGenerator:
	var _it: DifficultyStageIterator
	var _current_cycle: Array[PieceSpawnConfig] = []
	var _cycle_index: int = 0


	func _init(it: DifficultyStageIterator) -> void:
		_it = it.duplicate()


	func next() -> PieceSpawnConfig:
		var stage := _it.next()

		if _it.is_stage_start or _cycle_index >= _current_cycle.size():
			_generate_new_cycle(stage)

		var piece = _current_cycle[_cycle_index]
		_cycle_index += 1
		return piece


	func _generate_new_cycle(stage: DifficultyStageConfig):
		var arr := stage.piece_queue_config.piece_spawn_configs.duplicate()
		arr.shuffle()
		var cycle_size = mini(arr.size(), _it.remaining_stage_turns)
		# var cycle_size = arr.size()
		_current_cycle = arr.slice(0, cycle_size)
		_cycle_index = 0
