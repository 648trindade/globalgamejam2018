extends Node2D

onready var grid = get_node("/root/Game/Grid")
var grid_position = Vector2(50,0)

func _ready():
    get_node("../../Virus").connect("new_router", self, "change_origin")
    var origin = Vector2(0,0)
    set_new_position()
    correct_position(origin)
    set_process(true)

func _process(delta):
    pass

func set_new_position():
    var angle = randi()%360
    grid_position = grid_position.rotated(angle)
    grid_position.x = int(grid_position.x)
    grid_position.y = int(grid_position.y)

func correct_position(shift):
    grid_position -= shift
    position = grid.get_position_relative(grid_position)

func calc_distance(origin):
    return origin.distance_to(grid_position)

func calc_angle(origin):
    return grid_position.angle_to_point(origin)

func change_origin(fork):
    var pos = get_node("../Router").get_route(fork).back()
    correct_position(pos)