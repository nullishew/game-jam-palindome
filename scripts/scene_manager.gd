extends Node

var game_scene = preload("res://scenes/game.tscn")
var menu_scene = preload("res://scenes/menu.tscn")
var game_over_scene = preload("res://scenes/game_over.tscn")

var overlay: CanvasLayer

func change_scene(packed_scene: PackedScene):
	if overlay:
		overlay.queue_free()
		overlay = null
	get_tree().call_deferred("change_scene_to_packed", packed_scene)
	# get_tree().change_scene_to_packed(packed_scene)

func start_game():
	change_scene(game_scene)

func open_start_menu():
	change_scene(menu_scene)

func open_game_over_menu():
	if overlay: return
	overlay = game_over_scene.instantiate()
	get_tree().root.add_child(overlay)
