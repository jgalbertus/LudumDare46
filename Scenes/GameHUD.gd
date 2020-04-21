extends Label
onready var start_time = OS.get_ticks_msec()
export var group_name = "Generic"
onready var Root = get_tree().get_root().get_node("GameEnvironment")
onready var Game_Hud = Root.get_node("./GAME_HUD")
onready var Game_Over = Root.get_node("./GameOver")
var gameover = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var score = 0
var counting_text = String(0)
	
	
# Called when the node enters the scene tree for the first time.
func _process(delta):

	
	if not gameover:
		int((OS.get_ticks_msec() - start_time) * .001)
		Game_Over.visible = false
		Game_Hud.visible = true
		counting_text = String(get_tree().get_nodes_in_group(group_name).size())
	elif gameover:
		Game_Over.visible = true
		Game_Hud.visible = false
		
	if group_name == "Score":
		
		text = String(score)
		pass
	elif group_name == "Finale":
		text = "Final Message"
		if get_tree().get_nodes_in_group("Player_Boids").size() == 0:
			gameover = true
			text = "You didn't eat enough, all of your flock died"
		elif get_tree().get_nodes_in_group("Baby_Makers").size() == 0:
			gameover = true
			text = "You and the preditors ate too much, all the food died."
		elif get_tree().get_nodes_in_group("Predators").size() == 0:
			gameover = true
			text = "You didn't let the predators feed enough and they all died."
		pass
	else:
		text = counting_text



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().reload_current_scene()
	pass # Replace with function body.
