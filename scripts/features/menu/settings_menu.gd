extends OverlayMenu


@export var sfx_slider: HSlider
@export var soundtrack_slider: HSlider


func _ready() -> void:
	super._ready()
	set_vol(AudioManager.AudioBus.SFX, sfx_slider.value / 100.0)
	set_vol(AudioManager.AudioBus.SOUNDTRACK, soundtrack_slider.value / 100.0)
	sfx_slider.value_changed.connect(func(val): set_vol(AudioManager.AudioBus.SFX, val / 100.0))
	soundtrack_slider.value_changed.connect(func(val): set_vol(AudioManager.AudioBus.SOUNDTRACK, val / 100.0))


func set_vol(bus: AudioManager.AudioBus, val: float):
	AudioServer.set_bus_volume_db(bus, linear_to_db(val) + 10)
