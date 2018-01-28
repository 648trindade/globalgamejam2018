extends Sprite

func _ready():
    set_process_input(true)

func _input(event):
    for key in ["yellow", "blue", "green", "red"]:
        if event.is_action_pressed(key):
            get_tree().change_scene("res://scenes/Start.tscn")