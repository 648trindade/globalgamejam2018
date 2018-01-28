extends Node2D

var block = Vector2(64,-64)
var offset = Vector2(0, 0)
var SCREEN_SIZE = Vector2(14,10)
var vertexes = {}
var edges = {}
var accumulated_shift = Vector2(0,0)
# const MiniRouter = preload("res://gameobjects/MiniRouter.tscn")

func _ready():
    # instantiate_vertex()
    # set_process(true)
    set_process_input(true)
    
# func _process(delta):
#     if accumulated_shift.y >= 64:
#         get_node("SpriteGrid").position.y += 64
#         accumulated_shift.y -= 64
#     elif accumulated_shift.y <= -64:
#         get_node("SpriteGrid").position.y -= 64
#         accumulated_shift.y += 64
#     if accumulated_shift.x >= 64:
#         get_node("SpriteGrid").position.x -= 64
#         accumulated_shift.x -= 64
#     elif accumulated_shift.x <= -64:
#         get_node("SpriteGrid").position.x += 64
#         accumulated_shift.x += 64


func get_position_relative(grid_pos):
    return Vector2(grid_pos * block)

func get_position_global(grid_pos):
    return offset + block * grid_pos

# func instantiate_vertex():
#     var grid = get_node("SpriteGrid")
#     for i in range(-(SCREEN_SIZE.x/2) - 5, SCREEN_SIZE.x/2 + 5):
#         for j in range(-(SCREEN_SIZE.y/2) - 5, SCREEN_SIZE.y/2 + 5):
#             var vertex = MiniRouter.instance()
#             grid.add_child(vertex)
#             vertex.position = get_position_global(Vector2(i,j))

func register_vertex(pos, object):
    if not vertexes.has(str(pos.x)):
        vertexes[str(pos.x)] = {}
    vertexes[str(pos.x)][str(pos.y)] = object

func unregister_vertex(pos):
    vertexes[str(pos.x)].erase(str(pos.y))

func is_vertex_empty(pos):
    if vertexes.has(str(pos.x)):
        if vertexes[str(pos.x)].has(str(pos.y)):
            return false
    return true