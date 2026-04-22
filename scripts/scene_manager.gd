extends Node

var game_scene = preload("res://scenes/game.tscn")
var menu_scene = preload("res://scenes/menu.tscn")
var game_over_scene = preload("res://scenes/game_over.tscn")
var transition_scene = preload("res://scenes/transition.tscn")

var _overlay: CanvasLayer

var _is_changing: bool = false

func change_scene(packed_scene: PackedScene):
	_is_changing = true
	var transition: Transition = transition_scene.instantiate()
	transition.in_finished.connect(
		func():
			if _overlay:
				_overlay.queue_free()
				_overlay = null
			get_tree().call_deferred("change_scene_to_packed", packed_scene)
			)
	transition.out_finished.connect(func(): transition.call_deferred("queue_free"))
	get_tree().root.add_child(transition)
	

func start_game():
	change_scene(game_scene)

func open_start_menu():
	change_scene(menu_scene)

func open_game_over_menu():
	if _overlay: return
	_overlay = game_over_scene.instantiate()
	get_tree().root.add_child(_overlay)
