extends Area2D
onready var viewport = get_viewport().size
#onready var attractors = get_tree().get_nodes_in_group("Baby_Makers")
onready var attractors = get_tree().get_nodes_in_group("Mouse")
onready var repulsors = get_tree().get_nodes_in_group("Player_Boids")
onready var predators = get_tree().get_nodes_in_group("Predators")
onready var value_controller = get_parent().get_node("PredatorHUD/VBoxContainer")
onready var PredatorScene = load("res://Scenes/Predator.tscn")
var mass = 1
var velocity = Vector2()
var acceleration = Vector2(0,0)
export var max_speed = 500
var attraction_force = 0
var player_repulsion_force = 0
var predator_repulsion_force = 0
var constraint = 200
var max_predators = 10
var can_spawn

#forces
var wind = Vector2()
const G = 0.4

func _ready():
	randomize()
	#mass = rand_range(1,4)
	velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() 
	position = Vector2(rand_range(0,viewport.x), rand_range(0,viewport.y))
	mass = value_controller.get_node("Mass/HSlider").value
	attraction_force  = value_controller.get_node("Attraction_Force/HSlider").value
	player_repulsion_force = value_controller.get_node("Player_Repulsion_Force/HSlider").value
	predator_repulsion_force = value_controller.get_node("Predator_Repulsion_Force/HSlider").value
	constraint = value_controller.get_node("Constraint/HSlider").value
	#boid_creature.move_speed = value_controller.get_node("MoveSlider/HSlider").value
	


func _physics_process(delta):
	#print(position)
	attractors = get_tree().get_nodes_in_group("Baby_Makers")
	repulsors = get_tree().get_nodes_in_group("Player_Boids")
	predators = get_tree().get_nodes_in_group("Predators")
	#applyforce(wind)
	#print (attractors.size(), ", ", repulsors.size())
	#var mod_attraction_force = attracted_to(attractors)
	#var mod_repulsion_force = repulsed_by(repulsors,player_repulsion_force)
	#var mod_predator_repulsion = repulsed_by(predators,predator_repulsion_force)
	repulsed_by(predators,predator_repulsion_force)	
	repulsed_by(repulsors,player_repulsion_force)
	attracted_to(attractors)
	#applyforce(mod_attraction_force)
	#applyforce(mod_repulsion_force)
	#applyforce(mod_predator_repulsion)
	
	
	
	velocity += acceleration
	velocity = velocity.clamped(max_speed)
	acceleration *= 0
	
	
	rotation = velocity.angle()
	
	translate(velocity * delta)
	
	#position.x = wrapf(position.x, -0, get_viewport().size.x + 0)
	#position.y = wrapf(position.y, -0, get_viewport().size.y + 0)
	
	
func attracted_to(array_of_attractors):
	if array_of_attractors.empty():
		return Vector2()
	for attractor in array_of_attractors:
		var force = attractor.position - position
		var distance = force.length()
		distance = clamp(distance, 1, constraint)
		force = force.normalized()
		var strength = (attraction_force*mass)/(distance*distance)
		force *= strength
		applyforce(force)

func repulsed_by(array_of_repulsors,which_force):
	if array_of_repulsors.empty():
		return Vector2()
	for repulsor in array_of_repulsors:
		var force = position - repulsor.position
		var distance = force.length()
		distance = clamp(distance, 1,constraint)
		force = force.normalized()
		var strength = (which_force*mass) /  distance
		force *= strength
		applyforce(force)

func applyforce(force):
	var f = force
	f /= mass
	acceleration += f;
	

func create_predator():
	var new_pred = PredatorScene.instance()
	new_pred.position = position
	new_pred.velocity = velocity.rotated(PI/2)
	get_parent().call_deferred("add_child",new_pred)
	pass

		
func _on_Attraction_Force_value_changed(value):
	var preds =  get_tree().get_nodes_in_group("Predators")
	
	for predator in preds:
		predator.attraction_force = value
	pass

func _on_Player_Repulsion_Force_value_changed(value):
	var preds =  get_tree().get_nodes_in_group("Predators")
	for predator in preds:
		predator.player_repulsion_force = value
	pass # Replace with function body.


func _on_Predator_Repulsion_Force_value_changed(value):
	var preds =  get_tree().get_nodes_in_group("Predators")
	for predator in preds:
		predator.predator_repulsion_force = value
	pass # Replace with function body.


func _on_Mass_value_changed(value):
	var preds =  get_tree().get_nodes_in_group("Predators")
	for predator in preds:
		predator.mass = value


func _on_Constraint_value_changed(value):
	var preds =  get_tree().get_nodes_in_group("Predators")
	for predator in preds:
		predator.mass = value


func _on_Predator2_area_entered(area):
	#print(predators.size())
	if not can_spawn:
		return
	elif area.is_in_group("Baby_Makers") and predators.size()<= max_predators:
		can_spawn = false
		create_predator()
		#print("new predator")
		$Timer.start()
	pass # Replace with function body.



func _on_PredSpawnTimer_timeout():
	can_spawn = true

	pass # Replace with function body.


func _on_LifeTime_timeout():
	queue_free()
	pass # Replace with function body.
