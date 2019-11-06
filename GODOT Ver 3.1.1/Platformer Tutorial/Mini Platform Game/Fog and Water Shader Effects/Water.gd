extends Area2D

export(int) var collisionDamage = 0

func _physics_process(delta):
	if (collisionDamage > 0):
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if (body.name == "Player"):
				body.damagePlayer(collisionDamage)