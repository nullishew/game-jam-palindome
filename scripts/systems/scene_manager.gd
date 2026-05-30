extends Node

var game_scene = preload("res://scenes/game.tscn")
var transition_scene = preload("res://scenes/transition.tscn")

var menu_scene = preload("res://scenes/menus/menu.tscn")
var game_over_scene = preload("res://scenes/menus/game_over.tscn")
var pause_menu_scene = preload("res://scenes/menus/pause_menu.tscn")
var settings_menu_scene = preload("res://scenes/menus/settings_menu.tscn")
var controls_menu_scene = preload("res://scenes/menus/controls_menu.tscn")

var _game_over_overlay: CanvasLayer
var _pause_menu_overlay: PauseMenu
var _settings_menu_overlay: CanvasLayer
var _controls_menu_overlay: CanvasLayer
var _transition: Transition

var _is_changing: bool = false

func _ready() -> void:
	_transition = transition_scene.instantiate()
	get_tree().root.call_deferred("add_child", _transition)

	_pause_menu_overlay = pause_menu_scene.instantiate()
	_pause_menu_overlay.visible = false
	get_tree().root.call_deferred("add_child", _pause_menu_overlay)

	_settings_menu_overlay = settings_menu_scene.instantiate()
	_settings_menu_overlay.visible = false
	get_tree().root.call_deferred("add_child", _settings_menu_overlay)

	_controls_menu_overlay = controls_menu_scene.instantiate()
	_controls_menu_overlay.visible = false
	get_tree().root.call_deferred("add_child", _controls_menu_overlay)

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
	if _game_over_overlay:
		_game_over_overlay.queue_free()
		_game_over_overlay = null
	_pause_menu_overlay.visible = false
	_pause_menu_overlay.close()
	await get_tree().process_frame
	_transition.resume()
	get_tree().call_deferred("change_scene_to_packed", packed_scene)
	_is_changing = false
	

func start_game():
	change_scene(game_scene)

func open_start_menu():
	change_scene(menu_scene)

func open_game_over_menu():
	if _game_over_overlay: return
	_game_over_overlay = game_over_scene.instantiate()
	get_tree().root.add_child(_game_over_overlay)


func open_pause_menu():
	_pause_menu_overlay.open()


func close_pause_menu():
	_pause_menu_overlay.close()


func open_settings_menu():
	_settings_menu_overlay.open()


func open_controls_menu():
	_controls_menu_overlay.open()
