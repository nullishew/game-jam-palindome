class_name DifficultyStageIterator


var _config: DifficultyConfig
var _stage_index: int
var _turn_index: int


func _init(config: DifficultyConfig, stage_index: int = 0, turn_index: int = 0) -> void:
	_config = config
	_stage_index = stage_index
	_turn_index = turn_index


func next() -> DifficultyStageConfig:
	if _config.stages.is_empty(): return null
	if _stage_index >= _config.stages.size(): return _config.stages.back()
	var stage = _config.stages[_stage_index]
	_advance()
	return stage


func duplicate() -> DifficultyStageIterator:
	return DifficultyStageIterator.new(_config, _stage_index, _turn_index)


func _advance():
	_turn_index += 1
	while _stage_index < _config.stages.size():
		var stage = _config.stages[_stage_index]
		if _turn_index < stage.duration_turns: break
		_stage_index += 1
		_turn_index = 0

