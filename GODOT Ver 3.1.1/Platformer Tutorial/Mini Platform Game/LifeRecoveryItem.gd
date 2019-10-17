extends Area2D

export(int) var healthRecovered = 25

export(Vector2) var size = Vector2(1,1)

func _ready():
	$AnimatedSprite.play("default")
	
func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if (body.name == "Player"):
			body.healPlayer(healthRecovered)
			queue_free()
