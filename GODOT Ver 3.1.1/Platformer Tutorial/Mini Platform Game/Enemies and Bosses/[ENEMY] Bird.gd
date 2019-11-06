extends KinematicBody2D

const GRAVITY = 0
const FLOOR = Vector2(0,-1)
var velocity = Vector2()
var direction = 1

var is_dead = false

export(int) var health = 3
export(int) var speed = 120
export(int) var damage = 10

export(Vector2) var size = Vector2(0.3,0.3)

func _ready():
	scale = size
	pass
	
func takeDamage(value):
	health -= value
	if (health <= 0):
		dead()
	else:
		$Sounds/BulletHit.play()

func dead():
	is_dead = true
	$CollisionShape2D.call_deferred("set_disabled", true)
	velocity = Vector2(0,0)
	$AnimatedSprite.play("Explode")
	$Sounds/KilledScream.play()
	$AnimatedSprite.apply_scale(Vector2(0.15,0.15))
	$DisappearTimer.start()


func _physics_process(delta):
	if (is_dead == false):
		velocity.x = speed * direction
		velocity.y = GRAVITY
		
		if (direction == 1):
			$AnimatedSprite.flip_h = false
		elif (direction == -1):
			$AnimatedSprite.flip_h = true
		
		$AnimatedSprite.play("Fly")
		velocity = move_and_slide(velocity, FLOOR)
	
	if (is_on_wall()):
		direction *= -1
		$FrontRaycast.position.x *= -1
	
	if ($FrontRaycast.is_colliding() == true):
		direction *= -1
		$FrontRaycast.position.x *= -1
		
	if (get_slide_count() > 0):
		for i in range (get_slide_count()):
			if ("Player" in get_slide_collision(i).collider.name):
				if (get_slide_collision(i).collider.IFrames <= 0):
					get_slide_collision(i).collider.damagePlayer(damage)

func _on_DisappearTimer_timeout():
	queue_free()
