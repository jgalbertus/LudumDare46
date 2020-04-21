#following code from
#here: https://github.com/jackaperkins/boids/blob/master/Boid.pde
#and here: https://www.youtube.com/watch?v=iGvbb2HlCdQ / https://github.com/Gonkee/Gonkees-Shaders

extends Node2D
class_name MyBoid

onready var detectors = $ObstacleDectors
onready var sensors = $ObstacleSensors
onready var viewport = get_viewport().size
onready var attractors = get_tree().get_nodes_in_group("Attractors")
onready var predators = get_tree().get_nodes_in_group("Avoiders")
onready var my_group_name = get_groups()
onready var boids_creature_array = get_tree().get_nodes_in_group(my_group_name[0])
onready var BoidScene = load("res://Scenes/BoidCreature.tscn")


#var boids_creature_array = []
var can_spawn = false
var can_eat = false
var max_baby_makers = 75
var max_player_boids= 50
var move_speed = 100
var perception_radius  = 50 * scale.x
var velocity = Vector2()
var acceleration = Vector2()
var steer_force = 50.0
var alignment_force = 0.6
var cohesion_force = 1.6
var separation_force = 0.5
var avoidance_force = 3.0
var attraction_force = 0
var mass= 1

func _ready():
	randomize()
	velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * move_speed
	position = Vector2(rand_range(0,viewport.x), rand_range(0,viewport.y))
	#print(attractors.size())
	
func _physics_process(delta):
	attractors = get_tree().get_nodes_in_group("Attractors")
	mass = mass*delta*10
	mass = clamp(mass, 1500,1500000)
	
	boids_creature_array = get_tree().get_nodes_in_group(my_group_name[0])
	var neighbors = get_neighbors(perception_radius)
	var predator_array = get_predators(perception_radius)
	
	acceleration += process_alignments(neighbors) * alignment_force
	acceleration += process_cohesion(neighbors) * cohesion_force
	acceleration += process_separation(neighbors) * separation_force
	
	acceleration += process_cohesion(attractors) * attraction_force
	#acceleration += process_fear(predator_array) * avoidance_force
	
	if is_obstacle_ahead():
		acceleration += process_obstacle_avoidance() * avoidance_force

	
	velocity += acceleration * delta
	velocity = velocity.clamped(move_speed)
	rotation = velocity.angle()
	
	translate(velocity * delta)
	
	position.x = wrapf(position.x, -32, get_viewport().size.x + 32)
	position.y = wrapf(position.y, -32, get_viewport().size.y + 32)





func process_cohesion(neighbors):
	var vector = Vector2()
	if neighbors.empty():
		return vector
	for boid in neighbors:
		vector += boid.position
	vector/=neighbors.size()
	return steer((vector-position).normalized()*move_speed)



func process_alignments(neighbors):
	var vector = Vector2()
	if neighbors.empty():
		return vector
	for boid in neighbors:
		vector += boid.position
	vector /= neighbors.size()
	return steer((vector).normalized() * move_speed)

func process_separation(neighbors):
	var vector = Vector2()
	var close_neighbors = []
	for boid in neighbors:
		if position.distance_to(boid.position) < perception_radius/2:
			close_neighbors.push_back(boid)
	if close_neighbors.empty():
		return vector
	for boid in close_neighbors:
		var difference = position - boid.position
		vector += difference.normalized() / difference.length()
	vector /= close_neighbors.size()
	return steer(vector.normalized()*move_speed)
	
func is_obstacle_ahead():
	for ray in detectors.get_children():
		if ray.is_colliding() and ray.get_collider().is_in_group("Avoiders"):
			#print(ray.get_collider())
			return true
	return false

func process_obstacle_avoidance():
	for ray in sensors.get_children():
		#print(ray.get_collider())
		if not ray.is_colliding():
				#print("Avoiding")
				return steer ( (ray.cast_to.rotated(ray.rotation+rotation)).normalized() * move_speed)
	return Vector2.ZERO

func get_neighbors(view_radius):
	var neighbors = []
	
	for boid in boids_creature_array:
		if position.distance_to(boid.position) <= view_radius and not boid == self:
			neighbors.push_back(boid)
	return neighbors

func get_predators(view_radius):
	var get_predators = []
	
	for predator in predators:
		if position.distance_to(predator.position) <=  view_radius:
			get_predators.push_back(predator)
			#print("danger: ", get_predators.size() )
	return predators


func steer(var target):
	var steer = target - velocity
	steer = steer.normalized() * steer_force
	return steer





func _on_BoidCreature_area_entered(area):

	
	if my_group_name[0] == "Player_Boids":
		if area.is_in_group("Baby_Makers"):
			var playerboids = get_tree().get_nodes_in_group("Player_Boids")
			if playerboids.size() < max_player_boids and can_eat:
				area.queue_free()
				create_boid(area.position, my_group_name[0])
	elif my_group_name[0] == "Baby_Makers":
	
		if area.is_in_group("Baby_Makers"):
			var babymakers = get_tree().get_nodes_in_group("Baby_Makers")
			if (babymakers.size()<max_baby_makers) and can_spawn:
				can_spawn = false;
				$SpawnTimer.start()
				create_boid(area.position, my_group_name[0])

		elif area.is_in_group("Predators"):
			queue_free()
			pass

func create_boid(boid_position, group):
	var new_boid = BoidScene.instance() 
	new_boid.position = boid_position
	new_boid.move_speed = move_speed
	new_boid.steer_force = steer_force
	new_boid.alignment_force = alignment_force
	new_boid.cohesion_force = cohesion_force
	new_boid.separation_force = separation_force
	new_boid.avoidance_force = avoidance_force
	new_boid.attraction_force = attraction_force
	
	get_parent().call_deferred("add_child",new_boid)
	new_boid.add_to_group(group)
	


func _on_SpawnTimer2_timeout():
	can_spawn = true

	pass # Replace with function body.


func _on_EatTimer_timeout():
	can_eat = true
	pass # Replace with function body.
