extends Area2D
onready var viewport = get_viewport().size

const MAX_SPEED = 50;

onready var attracted_to = get_tree().get_nodes_in_group("Baby_Makers")
onready var averse_to = get_tree().get_nodes_in_group("Player_Flock")

export var move_speed = 200
var perception_radius  = 50 * scale.x
var velocity = Vector2()
var acceleration = Vector2()
export var steer_force = 50.0
export var alignment_force = 0.6
export var cohesion_force = 0.6
export var separation_force = 10.0
export var avoidance_force = 300.0
export var attraction_force = 2;

func _ready():
	randomize()
	velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * move_speed

func _process(delta):
	velocity += acceleration * delta
	velocity = velocity.clamped(move_speed)
	rotation = velocity.angle()
	
	translate(velocity * delta)
	
	position.x = wrapf(position.x, -32, get_viewport().size.x + 32)
	position.y = wrapf(position.y, -32, get_viewport().size.y + 32)

func steer(var target):
	var steer = target - velocity
	steer = steer.normalized() * steer_force
	return steer

