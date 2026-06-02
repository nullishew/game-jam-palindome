extends Node


const BGM_AUDIO: AudioStream = preload("res://resources/audio/palindome_jam_soundtrack.wav")
const BUBBLE_AUDIO: AudioStream = preload("res://resources/audio/bubbles.wav")
const SPLASH_AUDIO: AudioStream = preload("res://resources/audio/splash.wav")
const THUD_AUDIO: AudioStream = preload("res://resources/audio/thud.wav")
const TOWEL_DISPENSER_AUDIO: AudioStream = preload("res://resources/audio/towel_dispenser.wav")
const TRANSITION_AUDIO: AudioStream = preload("res://resources/audio/transition.wav")


enum AudioBus {
	BGM,
	SFX,
}


const AUDIO_BUS_STRINGS: Dictionary[AudioBus, String] = {
	AudioBus.BGM: "BGM",
	AudioBus.SFX: "SFX",
}


func _ready() -> void:
	play_sound(BGM_AUDIO, AudioBus.BGM)


func play_sound(stream: AudioStream, bus: AudioBus, volume_db: float = 0.0):
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = AUDIO_BUS_STRINGS[bus]
	player.volume_db = volume_db
	player.finished.connect(player.queue_free)

	add_child(player)
	player.play()
