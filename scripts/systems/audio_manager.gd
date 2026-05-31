extends Node


const SOUNDTRACK: AudioStream = preload("res://resources/audio/palindome_jam_soundtrack.wav")
const THUD_SOUND: AudioStream = preload("res://resources/audio/thud.wav")
const TRANSITION_SOUND: AudioStream = preload("res://resources/audio/transition.wav")
const TOWEL_DISPENSER_SOUND: AudioStream = preload("res://resources/audio/towel_dispenser.wav")


enum AudioBus {
	BGM,
	SFX,
}


const AUDIO_BUS_STRINGS: Dictionary[AudioBus, String] = {
	AudioBus.BGM: "BGM",
	AudioBus.SFX: "SFX",
}


func _ready() -> void:
	play_sound(SOUNDTRACK, AudioBus.BGM)


func play_sound(stream: AudioStream, bus: AudioBus):
	var player := AudioStreamPlayer.new()
	add_child(player)

	player.stream = stream
	player.bus = AUDIO_BUS_STRINGS[bus]
	player.finished.connect(player.queue_free)
	player.play()
