extends Node

var soundtrack: AudioStream = preload("res://assets/palindome_jam_soundtrack.wav")

enum AudioBus {
	SOUNDTRACK,
	SFX,
}

const AUDIO_BUS_STRINGS: Dictionary[AudioBus, String] = {
	AudioBus.SOUNDTRACK: "Soundtrack",
	AudioBus.SFX: "SFX",
}

func _ready() -> void:
	play_sound(soundtrack, AudioBus.SOUNDTRACK)


func play_sound(stream: AudioStream, bus: AudioBus):
	var player := AudioStreamPlayer.new()
	add_child(player)

	player.stream = stream
	player.bus = AUDIO_BUS_STRINGS[bus]
	player.finished.connect(player.queue_free)
	player.play()