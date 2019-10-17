# WorldComplete.gd
extends Area2D

export(String, FILE, "*.tscn") var next_world

func go_to_next_world():
#	Play congrats message or something
    
	var body = get_parent().find_node("Player")
	Global.goto_scene(next_world,body.health,body.mp,body.score+100,get_tree().get_current_scene())

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if (body.name == "Player"):
			Global.goto_scene(next_world,body.health,body.mp,body.score+100,get_tree().get_current_scene())