extends Node2D

const Router = preload("res://gameobjects/Router.tscn")
const Path = preload("res://gameobjects/Path.tscn")
const GRID_OFFSET = 1
const CREATION_AREA = 8
var grid_position = Vector2(0,0)
onready var grid = get_node("/root/Game/Grid")
onready var paths = get_node("Paths")
onready var objective = get_node("/root/Game/Grid/Objective/Sprite/VisibilityNotifier2D")
var ready = false
var astar

class Complexity:
    const SIMPLE = 0
    const MEDIUM = 1
    const HARD = 2

class Direction:
    const UP = 0
    const LEFT = 1
    const RIGHT = 2
    const DOWN = 3

func _enter_tree():
    if ready and get_parent().get_name() == "Grid":
        create_forks(4)

func _ready():
    randomize()
    grid.register_vertex(grid_position, self)
    if get_parent().get_name() == "Grid":
        create_forks(4)
    ready = true

func create_forks(num_forks):
    astar = AStar.new()
    for i in range(-CREATION_AREA, CREATION_AREA+1):
        for j in range(-CREATION_AREA, CREATION_AREA+1):
            var id = astar_id(Vector2(i,j))
            var pos = grid_position + Vector2(i,j)
            astar.add_point(id, Vector3(pos.x, pos.y, 0), 1)
    for i in range(-CREATION_AREA, CREATION_AREA+1):
        for j in range(-CREATION_AREA, CREATION_AREA+1):
            var id = astar_id(Vector2(i,j))
            if astar.has_point(id-1):
                astar.connect_points(id, id-1, false)
            if astar.has_point(id+1):
                astar.connect_points(id, id+1, false)
            if astar.has_point(id+(CREATION_AREA*2+1)): 
                astar.connect_points(id, id+(CREATION_AREA*2+1), false)
            if astar.has_point(id-(CREATION_AREA*2+1)):
                astar.connect_points(id, id-(CREATION_AREA*2+1), false)
    astar.set_point_weight_scale(astar_id(grid_position), 1000)
    
    var complexity = Complexity.SIMPLE
    
    if objective.is_on_screen():
        num_forks -= 1
        astar.set_point_weight_scale(astar_id(objective.get_node("../..").grid_position), 1000)

    for i in num_forks:
        var fork = create_fork(i)
        get_node("Forks").add_child(fork)
        astar.set_point_weight_scale(astar_id(fork.grid_position), 1000)
    
    for fork in get_node("Forks").get_children():
        var i = int(fork.get_name().substr(5,1))
        var path_points = calc_path(fork.grid_position, complexity, i)
        astar.set_point_weight_scale(astar_id(fork.grid_position), 1000)
        var path = Path.instance()
        path.generate(path_points, i, grid)
        paths.add_child(path)
        path.set_name("Path_" + str(i))

    if objective.is_on_screen():
        print("r",objective.get_node("../..").grid_position)
        var path_points = calc_path(objective.get_node("../..").grid_position, complexity, num_forks)
        var path = Path.instance()
        path.generate(path_points, num_forks, grid)
        paths.add_child(path)
        path.set_name("Path_" + str(num_forks))

    astar.clear()

func create_fork(fork_num):
    var new_router = Router.instance()
    new_router.grid_position = random_pos()
    new_router.position = grid.get_position_relative(new_router.grid_position)
    new_router.set_name("fork_" + str(fork_num))
    return new_router

func astar_id(pos):
    return (CREATION_AREA*2 + 1) * (pos.x+CREATION_AREA) + (pos.y+CREATION_AREA) + 1

func calc_path(pos_to, complexity, fork_dir):
    var pos_from = grid_position
    var path = [pos_from]
    var steps = []

    match fork_dir:
        Direction.UP:   path.append(pos_from + Vector2(0,1))  #top
        Direction.RIGHT: path.append(pos_from + Vector2(1,0))  #right
        Direction.LEFT:  path.append(pos_from + Vector2(-1,0)) #left
        Direction.DOWN:  path.append(pos_from + Vector2(0,-1)) #bottom
    grid.register_vertex(path[-1], self)

    match complexity:
        Complexity.SIMPLE: pass
        Complexity.MEDIUM:
            for step in ((randi()%2) + 1):
                steps.append(random_pos())
                astar.set_point_weight_scale(astar_id(Vector2(steps[-1])), 30)
        Complexity.HARD:
            for step in ((randi()%2) + 3):
                steps.append(random_pos())
                astar.set_point_weight_scale(astar_id(Vector2(steps[-1])), 30)

    steps.append(pos_to)

    for step in steps:
        path += direct_path(path[-1], step)

    return path

func random_pos():
    var start_pos = grid_position
    var pos_valid = false
    var new_pos = Vector2(0,0)
    while not pos_valid:
        new_pos.x = (randi() % CREATION_AREA + GRID_OFFSET) * (-1 if randi()%2 else 1) + start_pos.x
        new_pos.y = (randi() % CREATION_AREA + GRID_OFFSET) * (-1 if randi()%2 else 1) + start_pos.y
        pos_valid = astar.get_point_weight_scale(astar_id(new_pos)) != 1000
    return new_pos

func direct_path(from, to):
    var astar_path = astar.get_point_path(astar_id(from), astar_id(to))
    var path = []
    for point in astar_path:
        path.append(Vector2(point.x, point.y) + grid_position)
        astar.set_point_weight_scale(astar_id(Vector2(point.x, point.y)), 15)
    path.remove(0)
    return path

func change_router(router_id):
    if objective.is_on_screen() and (not get_node("Forks").has_node("fork_" + str(router_id))):
        get_tree().change_scene("res://scenes/Win.tscn")
    
    else:
        var target = get_node("Forks/fork_" + str(router_id))
        set_name("old_Router")
        target.set_name("Router")
        get_node("Forks").remove_child(target)
        
        get_node("/root/Game/Virus").position = Vector2(0,0)
        target.grid_position = Vector2(0,0)
        target.position = Vector2(0,0)
        grid.position = Vector2(0,0)
        
        get_parent().add_child(target)
        queue_free()

func has_route(direction):
    return has_node("Paths/Path_" + str(direction))

func get_route(direction):
    return get_node("Paths/Path_" + str(direction)).points