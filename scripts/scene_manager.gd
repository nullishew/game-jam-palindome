extends Node

var game_scene = preload("res://scenes/game.tscn")
var menu_scene = preload("res://scenes/menu.tscn")
var game_over_scene = preload("res://scenes/game_over.tscn")
var transition_scene = preload("res://scenes/transition.tscn")

var _overlay: CanvasLayer
var _transition: Transition

var _is_changing: bool = false

func _ready() -> void:
	_transition = transition_scene.instantiate()
	get_tree().root.call_deferred("add_child", _transition)

	# force cache / preload game scene runtime assets to remove stutter on first game start
	await get_tree().process_frame
	var inst = game_scene.instantiate()
	inst.visible = false
	get_tree().root.add_child(inst)
	await get_tree().process_frame
	inst.queue_free()


func change_scene(packed_scene: PackedScene):
	if _is_changing: return
	_is_changing = true
	await get_tree().process_frame
	_transition.transition()
	await _transition.in_finished
	if _overlay:
		_overlay.queue_free()
		_overlay = null
	await get_tree().process_frame
	_transition.resume()
	get_tree().call_deferred("change_scene_to_packed", packed_scene)
	_is_changing = false
	

func start_game():
	change_scene(game_scene)

func open_start_menu():
	change_scene(menu_scene)

func open_game_over_menu():
	if _overlay: return
	_overlay = game_over_scene.instantiate()
	get_tree().root.add_child(_overlay)
