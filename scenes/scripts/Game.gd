extends Node2D

var timer_state = "counting"
onready var timer_label = get_node("HUD/Timer_label")
onready var timer = get_node("HUD/Timer")
var explosion_sprite
var explosion_collision
var Explosion = load("res://gameobjects/Explosion.tscn")
var accum_time = 3
var time_max = accum_time
signal explosion_begins

func _ready():
    timer.connect("timeout", self, "timer_out")
    get_node("Virus").connect("new_router", self, "start_count")
    timer.start()
    set_process(true)

func _process(delta):
    if timer_state == "counting":
        accum_time -= delta
        if accum_time > 0:
            timer_label.text = str(accum_time).substr(0,4)

func timer_out():
    if timer_state == "counting":
        emit_signal("explosion_begins")
        timer_state = "exploding"
        time_max -= 0.3
        time_max = 1 if time_max < 1 else time_max
        timer_label.text = "!"
        # instance explosion
        var explosion = Explosion.instance()
        get_node("Grid").add_child(explosion)
        explosion.connect("body_entered", get_node("Virus"), "enter_explosion")
        explosion.connect("body_exited", get_node("Virus"), "exit_explosion")
        explosion_sprite = explosion.get_node("AnimatedSprite")
        explosion_collision = explosion.get_node("CollisionShape2D")
        explosion_sprite.connect("animation_finished", self, "timer_out")
        explosion_sprite.play()
    elif timer_state == "exploding":
        free_explosion()
        timer_state = "waiting"
        timer_label.text = ""

func start_count(foo):
    if has_node("Grid/Explosion"):
        free_explosion()
    accum_time = time_max
    timer_state = "counting"
    timer.wait_time = accum_time
    timer.start()

func free_explosion():
    explosion_sprite.stop()
    explosion_sprite.visible = false
    var explosion = get_node("Grid/Explosion")
    explosion.disconnect("body_entered", get_node("Virus"), "contact_explosion")
    explosion.disconnect("body_exited", get_node("Virus"), "contact_explosion")
    explosion.set_name("Explosion_old")
    explosion.queue_free()