extends "res://Scripts/Weightless.gd"

export(float) var my_thrust = 200
export(float) var my_torque = 2000;

var thrust = Vector2()
var rotation_dir = 0

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("ui_up2"):
		thrust = Vector2(my_thrust,0)
	elif Input.is_action_pressed("ui_down2"):
		thrust = Vector2(-my_thrust,0)
	else: 
		thrust = Vector2()
		
	if Input.is_action_pressed("ui_left2"):
		rotation_dir = -1
	elif Input.is_action_pressed("ui_right2"):
		rotation_dir = 1
	else: 
		rotation_dir = 0

func _integrate_forces(state):
	
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(rotation_dir * my_torque)
	._integrate_forces(state)
