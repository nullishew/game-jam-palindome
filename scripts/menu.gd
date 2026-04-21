extends CanvasLayer

@export var start_btn: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_btn.pressed.connect(SceneManager.start_game)
