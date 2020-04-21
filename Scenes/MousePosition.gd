extends Node2D

var mass = 1
var speed = 200
var velocity = Vector2()
var acceleration = Vector2()

func _ready():
	position=Vector2(500,500)
	pass

func _physics_process(delta):
	var direction = Vector2()
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	applyforce(direction)

	velocity += acceleration
	velocity = velocity.clamped(2*speed)
	acceleration *= 0

	rotation = velocity.angle()
	
	translate(velocity * delta)
	
	position.x = wrapf(position.x, -32, get_viewport().size.x + 32)
	position.y = wrapf(position.y, -32, get_viewport().size.y + 32)
	
func applyforce(force):
	var f = force*speed
	f /= mass
	acceleration += f;
