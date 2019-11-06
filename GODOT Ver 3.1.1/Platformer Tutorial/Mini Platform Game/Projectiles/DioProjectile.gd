extends Area2D

export (int) var damage = 30
export (int) var speed = 150
var velocity = Vector2()

var dont_free = ["Fireball", "Fireball2", "Fireball3", "[BOSS] DIO", "DioProjectile"]

# Projectile Direction: (-1) is left, (1) is right
var direction = 1          

func _ready():
	pass 
	
func set_projectile_direction(dir):
	direction = dir

func _physics_process(delta):
	velocity.x = speed * delta * direction
	translate(velocity)
	$AnimatedSprite.play("shoot")

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_DioProjectile_body_entered(body):
	if ("Player" in body.name):
		body.damagePlayer(damage)
	if (body.name != dont_free[0] and body.name != dont_free[1] and body.name != dont_free[2] and body.name != dont_free[3] and body.name != dont_free[4]):
		queue_free()

func _on_DioProjectile_area_entered(area):
	if (area.name == dont_free[0] or area.name == dont_free[1] or area.name == dont_free[2]):
		area.queue_free()
