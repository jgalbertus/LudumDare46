extends Node2D

onready var BoidCreature = preload("res://Scenes/BoidCreature.tscn")
onready var viewport = get_viewport().get_visible_rect().size
onready var group_array = get_tree().get_nodes_in_group(group_name)
onready var value_controller = get_parent().get_node("BoidHud/VBoxContainer")
#onready var boids_container = $Boids

const MAX_BOIDS = 50

export var number_of_starting_boids = 75
export var group_name = "Generic"

var boids_collection_array = []
var can_spawn = false


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in number_of_starting_boids:
		var randPos = Vector2(rand_range(0,viewport.x),rand_range(0,viewport.y))
		create_boid(randPos)
	pass # Replace with function body.


func _process(delta):
	
	boids_collection_array = get_tree().get_nodes_in_group(group_name)
	#if Input.is_action_just_released("ui_left_mouse"):
	#	create_boid(get_global_mouse_position())
	pass

	
func create_boid(boid_position):
	var boid_creature = BoidCreature.instance()
	boid_creature.position = boid_position
	boid_creature.move_speed = value_controller.get_node("MoveSlider/HSlider").value
	boid_creature.steer_force = value_controller.get_node("TurnSlider/HSlider").value
	boid_creature.alignment_force = value_controller.get_node("AlignSlider/HSlider").value
	boid_creature.cohesion_force = value_controller.get_node("CohesionSlider/HSlider").value
	boid_creature.separation_force = value_controller.get_node("SeparationSlider/HSlider").value
	boid_creature.avoidance_force = value_controller.get_node("Avoidance/HSlider").value
	boid_creature.attraction_force = value_controller.get_node("Attraction/HSlider").value
	
	call_deferred("add_child",boid_creature)
	#_on_Boid_MoveSlider_value_changed(value_controller.get_node("MoveSlider/HSlider").value)
	#boids_collection_array.push_back(boid_creature)
	boid_creature.add_to_group(group_name)
	boids_collection_array = get_tree().get_nodes_in_group(group_name)
	#print(group_name, ": ", get_tree().get_nodes_in_group(group_name).size())
	#print(get_tree().get_nodes_in_group("BoidCreature").size())
	#for boid in get_children():
		#boid.boids_creature_array = boids_collection_array
	#print(boids_collection_array.size())


func _on_Boid_MoveSlider_value_changed(value):
	for boid in boids_collection_array:
		boid.move_speed = value


func _on_Boid_TurnSlider_value_changed(value):
	for boid in boids_collection_array:
		boid.steer_force = value

 
func _on_Boid_AlignSlider_value_changed(value):
	for boid in boids_collection_array:
		boid.alignment_force = value


func _on_Boid_CohesionSlider_value_changed(value):
	for boid in boids_collection_array:
		boid.cohesion_force = value


func _on_Boid_Separation_Slider_value_changed(value):
	for boid in boids_collection_array:
		boid.separation_force = value
		


func _on_Predator_area_entered(area):
	#print(area)
	if area.is_in_group("Baby_Makers"):
		area.queue_free()
		#print(get_tree().get_nodes_in_group("BoidCreature").size())
	pass # Replace with function body.


func _on_Avoidance_value_changed(value):
	for boid in boids_collection_array:
		boid.avoidance_force = value


func _on_Attraction_value_changed(value):
	for boid in boids_collection_array:
		boid.attraction_force = value
	pass # Replace with function body.


func _on_LifeTimer_timeout():
	if get_children().empty():
		return
	get_child(0).queue_free()
	pass # Replace with function body.
