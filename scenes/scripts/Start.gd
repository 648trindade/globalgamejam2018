extends Node2D

func _ready():
    set_process_input(true)

func _input(event):
    if event.is_action_pressed("start"):
        get_tree().change_scene("res://scenes/Tutorial.tscn")