extends Node2D

const PathSprite = preload("res://gameobjects/resources/link_path2.tres")
const PathSpriteShader = preload("res://gameobjects/resources/link_path_shader.tres")
var points

class Direction:
    const UP = 0
    const LEFT = 1
    const RIGHT = 2
    const DOWN = 3

func generate(_points, direction, grid):
    points = _points
    var color
    match direction:
        Direction.UP: color = Color(0.8509803921568627, 0.6823529411764706, 0.13725490196078433) #amarelo
        Direction.RIGHT: color = Color(0.8509803921568627, 0.3137254901960784, 0.13725490196078433) #vermelho
        Direction.DOWN: color = Color(0.054901960784313725, 0.38823529411764707, 0.054901960784313725) #verde
        Direction.LEFT: color = Color(0.054901960784313725, 0.3137254901960784, 0.38823529411764707) #azul
    get_node("Sprites").material = PathSpriteShader.duplicate()
    get_node("Sprites").material.set_shader_param("path_color", color)

    for i in range(1, points.size()):
        var sprite = Sprite.new()
        get_node("Sprites").add_child(sprite)
        sprite.texture = PathSprite
        sprite.use_parent_material = true
        sprite.position = (points[i] - points[0]) * Vector2(64,-64)
        sprite.z_index = 1
        
        if points[i].y != points[i-1].y:
            sprite.rotation_degrees = 90
            if points[i].y > points[i-1].y: 
                sprite.position.y += 32
            elif points[i].y < points[i-1].y:
                sprite.position.y -= 32
        if points[i].x > points[i-1].x:
            sprite.position.x -= 32
        elif points[i].x < points[i-1].x:
            sprite.position.x += 32