## Iterates through difficulty stages over turns.
##
## Calling `next()` returns the current stage and advances internal iterator state by one turn.
##
## Stage flags always describe the stage returned by the most recent call to `next()`.
##
## After all configured stages are exhausted, the iterator repeats the final stage on all
## subsequent calls to `next()` while continuing to track stage flags.
class_name DifficultyStageIterator


## True if the most recently returned stage was the final turn of its stage.
var is_stage_end: bool:
	get: return _was_last_turn_stage_end

## True if the most recently returned stage was the first turn of its stage.
var is_stage_start: bool:
	get: return _was_last_turn_stage_start


var _config: DifficultyConfig
var _stage_index: int
var _stage_turn_index: int
var _was_last_turn_stage_end: bool = false
var _was_last_turn_stage_start: bool = false


func _init(config: DifficultyConfig, stage_index: int = 0, turn_index: int = 0) -> void:
	_config = config
	_stage_index = stage_index
	_stage_turn_index = turn_index


## Returns the current stage and advances iterator state.
func next() -> DifficultyStageConfig:
	if _config.stages.is_empty(): return null
	var stage = _config.stages[_stage_index]
	_was_last_turn_stage_end = _stage_turn_index == stage.duration_turns - 1
	_was_last_turn_stage_start = _stage_turn_index == 0
	_advance()
	return stage


## Returns a copy of the iterator preserving both traversal state and last-returned stage metadata.
func duplicate() -> DifficultyStageIterator:
	var copy := DifficultyStageIterator.new(_config, _stage_index, _stage_turn_index)
	copy._was_last_turn_stage_end = _was_last_turn_stage_end
	copy._was_last_turn_stage_start = _was_last_turn_stage_start
	return copy


## Advances the internal iterator by one turn.
##
## handles:
## - turn progression within the current stage
## - transitions between stages when duration is exceeded
## - looping behavior of the final stage once all stages are exhausted
func _advance():
	_stage_turn_index += 1
	while _stage_index < _config.stages.size():
		var stage = _config.stages[_stage_index]
		if _stage_turn_index < stage.duration_turns: break
		_stage_turn_index = 0
		# remain in final stage once reached
		if _stage_index < _config.stages.size() - 1:
			_stage_index += 1
