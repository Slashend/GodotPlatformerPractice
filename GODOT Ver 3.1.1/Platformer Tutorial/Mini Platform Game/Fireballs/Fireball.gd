extends Area2D

export (int) var damage = 0
export (int) var speed = 250
var velocity = Vector2()

# Fireball Direction: (-1) is left, (1) is right
var direction = 1          

func _ready():
	pass 
	
func set_fireball_direction(dir):
	direction = dir
	if (dir == -1):
		$AnimatedSprite.flip_h = true

func _physics_process(delta):
	velocity.x = speed * delta * direction
	translate(velocity)
	$AnimatedSprite.play("shoot")

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Fireball_body_entered(body):
	if ("Enemy" in body.name):
		body.takeDamage(damage)
	if ("DIO" in body.name):
		body.takeDamage(damage)
	if (body.name != "Player"):
		queue_free()

func _on_Fireball_area_entered(area):
	if (area.name == "DioProjectile"):
		queue_free()
