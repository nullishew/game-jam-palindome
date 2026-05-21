class_name PieceQueueComponent
extends Node


@export var piece_configs: Array[PieceSpawnConfig]


var _queue: Array[PieceSpawnConfig] = []
var _curr_piece_index: int = 0


func _ready() -> void:
	_queue.clear()
	_curr_piece_index = 0


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


func _generate_until(n: int):
	while _queue.size() < n:
		var next_cycle: Array[PieceSpawnConfig] = piece_configs.duplicate()
		next_cycle.shuffle()
		_queue.append_array(next_cycle)
	print("size: " + str(_queue.size()) + " to meet demand: " + str(n))
