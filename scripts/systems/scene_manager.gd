extends Node

const GAME_SCENE = preload("res://scenes/game.tscn")
const TRANSITION_SCENE = preload("res://scenes/transition.tscn")

const START_MENU_SCENE = preload("res://scenes/menus/menu.tscn")
const GAME_OVER_MENU_SCENE = preload("res://scenes/menus/game_over.tscn")
const PAUSE_MENU_SCENE = preload("res://scenes/menus/pause_menu.tscn")
const SETTINGS_MENU_SCENE = preload("res://scenes/menus/settings_menu.tscn")
const CONTROLS_MENU_SCENE = preload("res://scenes/menus/controls_menu.tscn")

var _game_over_overlay: OverlayMenu
var _pause_menu_overlay: OverlayMenu
var _settings_menu_overlay: OverlayMenu
var _controls_menu_overlay: OverlayMenu
var _transition: Transition

var _is_changing: bool = false

func _ready() -> void:
	_transition = _cache_scene(TRANSITION_SCENE)
	_pause_menu_overlay = _cache_scene(PAUSE_MENU_SCENE)
	_settings_menu_overlay = _cache_scene(SETTINGS_MENU_SCENE)
	_controls_menu_overlay = _cache_scene(CONTROLS_MENU_SCENE)
	_game_over_overlay = _cache_scene(GAME_OVER_MENU_SCENE)
	_warmup_packed_scene(GAME_SCENE)


func _cache_scene(packed_scene: PackedScene) -> Node:
	var instance := packed_scene.instantiate()
	get_tree().root.add_child.call_deferred(instance)
	return instance


# warm up scene to remove stutter when first loading heavy scenes like the game scene
func _warmup_packed_scene(packed_scene: PackedScene):
	var instance = packed_scene.instantiate()
	instance.hide()
	get_tree().root.add_child.call_deferred(instance)
	await get_tree().process_frame
	instance.queue_free()


func change_scene(packed_scene: PackedScene):
	if _is_changing: return
	_is_changing = true
	await get_tree().process_frame
	_transition.transition()
	await _transition.in_finished
	_game_over_overlay.hide()
	_pause_menu_overlay.hide()
	_settings_menu_overlay.hide()
	_controls_menu_overlay.hide()
	await get_tree().process_frame
	_transition.resume()
	get_tree().change_scene_to_packed.call_deferred(packed_scene)
	_is_changing = false
	

func start_game():
	change_scene(GAME_SCENE)


func open_start_menu():
	change_scene(START_MENU_SCENE)


func open_game_over_menu():
	_game_over_overlay.open()


func open_pause_menu():
	_pause_menu_overlay.open()


func close_pause_menu():
	_pause_menu_overlay.close()


func open_settings_menu():
	_settings_menu_overlay.open()


func open_controls_menu():
	_controls_menu_overlay.open()
