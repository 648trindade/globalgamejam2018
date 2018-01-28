extends KinematicBody2D

onready var grid = get_node("/root/Game/Grid")
var move_speed = 64*8
var route_path = [Vector2(0,0)]
var moving = false
var move_dir = null
var last_dist = 64
var life = 25
var colliding = false
signal new_router
signal damage
signal step
onready var back_shader = get_node("../Background").material

class Direction:
    const UP = 0
    const LEFT = 1
    const RIGHT = 2
    const DOWN = 3

func _ready():
    set_process_input(true)
    set_process(true)
    get_node("/root/Game/Grid/Objective/Sprite/VisibilityNotifier2D").connect("screen_entered", self, "turn_off_target")
    get_node("/root/Game/Grid/Objective/Sprite/VisibilityNotifier2D").connect("screen_exited", self, "turn_on_target")
    back_shader.set_shader_param("center", Vector2(0,0))
    back_shader.set_shader_param("destiny", grid.get_node("Objective").grid_position)


func turn_off_target():
    get_node("Target").visible = false

func turn_on_target():
    get_node("Target").visible = true

func enter_explosion(area):
    colliding = true
    emit_signal("damage")

func exit_explosion(area):
    colliding = false

func _input(event):
    if not moving:
        if event.is_action_pressed("yellow"):
            move_dir = Direction.UP
        elif event.is_action_pressed("green"):
            move_dir = Direction.DOWN
        elif event.is_action_pressed("blue"):
            move_dir = Direction.LEFT
        elif event.is_action_pressed("red"):
            move_dir = Direction.RIGHT
        if move_speed != null:
            try_move(move_dir)

func movement(amount):
    position += amount

func _process(delta):
    if colliding:
        life -= 5 * delta
        get_node("/root/Game/HUD/LifeBar/Fill").frame = int(ceil(life))
        if life <= 0:
            get_tree().change_scene("res://scenes/GameOver.tscn")

    if moving:
        var dest_global_pos = grid.get_position_global(route_path[1])
        var dist = route_path[1] - route_path[0]
        var amount
        var normal = Vector2(
            dist.x / abs(dist.x) if dist.x else 0, 
            dist.y / abs(dist.y) if dist.y else 0
        )
        dist = dest_global_pos.distance_to(position)
        if (dist < 0.5) or (dist > last_dist):
            amount = dest_global_pos - position
            route_path.remove(0)
            dist = 65
            emit_signal("step")
            back_shader.set_shader_param("center", route_path[0])
            back_shader.set_shader_param("destiny", grid.get_node("Objective").grid_position)
        else:
            amount = Vector2(move_speed, move_speed) * normal * delta * Vector2(1, -1)

        last_dist = dist
        movement(amount)
        if route_path.size() == 1:
            moving = false
            emit_signal("new_router", move_dir)
            grid.get_node("Router").change_router(move_dir)
            move_dir = null
            last_dist = 64
            back_shader.set_shader_param("center", Vector2(0,0))
            back_shader.set_shader_param("destiny", grid.get_node("Objective").grid_position)
    
    get_node("Target").position = Vector2(300-32,0).rotated(get_node("../Grid/Objective").position.angle_to_point(position)) * Vector2(1024/600,1)
    var time = str(route_path.front().distance_to(get_node("../Grid/Objective").grid_position))
    get_node("Target/Label").text = time.substr(0,time.find(".")+3)

func try_move(direction):
    if grid.get_node("Router").has_route(direction):
        moving = true
        route_path = grid.get_node("Router").get_route(direction)
    else:
        move_dir = null