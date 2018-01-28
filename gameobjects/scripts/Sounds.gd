extends Node

const sounds = {
    "explosion": preload("res://sounds/arpegio - corruption.wav"),
    #"damage":    preload("res://sounds/"),
    "step":      preload("res://sounds/noise.wav"),
}
onready var streams = [get_node("Stream1"), get_node("Stream2")]

func _ready():
    var virus = get_node("/root/Game/Virus")
    virus.connect("step", self, "play", ["step"])
    get_node("/root/Game").connect("explosion_begins", self, "play", ["explosion", 1])

func play(sound, stream_num=0):
    streams[stream_num].stream = sounds[sound]
    streams[stream_num].play()