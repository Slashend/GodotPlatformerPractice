extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0,-1)

const IDLE_TIME = 30
const DASH_TIME = 80
const SMALL_BLAST_TIME = 30
const SMALL_BLAST_COOLDOWN_TIME = 50
const ZA_WARUDO_COOLDOWN_TIME = 400

var velocity = Vector2()
var direction = 1

var is_dead = false
var maxHealth = 5

var actionTimer = 0
var chosenAction
var chosenActionNum
var isCurrentlyZaWarudo = false

const SMALLBLAST = preload("res://Projectiles/DioProjectile.tscn")

export(int) var health = 5
export(int) var speed = 30
export(int) var damage = 15

func _ready():
	maxHealth = self.health
	chosenAction = "Idle"
	chosenActionNum = 0
	
func takeDamage(value):
	health -= value
	
	if (health <= 0):
		dead()
	else:
		$Sounds/BulletHit.play()
	
func dead():
	is_dead = true
	$HP_Bar.visible = false
	
	$CollisionShape2D.call_deferred("set_disabled", true)
	velocity = Vector2(0,0)
	isCurrentlyZaWarudo = false
	get_parent().get_parent().find_node("Player").find_node("ZaWarudoOverlay").modulate = Color(0.2,0.2,0.2,0)
	
	$AnimatedSprite.play("Dead")
	$Sounds/WRRRYYYY.play()
	$AnimatedSprite.apply_scale(Vector2(1,0.5))
	$AnimatedSprite.translate(Vector2(0,20))
	$DisappearTimer.start()
	
func _on_DisappearTimer_timeout():
	get_parent().get_parent().find_node("WorldComplete").go_to_next_world()
	queue_free()
	
func _physics_process(delta):
	
	if (is_dead == false):
		# ----------------------------------------- Update Sprites -----------------------------------------
		velocity.y += GRAVITY
		if (direction == 1):
			$AnimatedSprite.flip_h = false
		elif (direction == -1):
			$AnimatedSprite.flip_h = true
			
		$HP_Bar.value = health*100/maxHealth
		
		# ----------------------------------------- Randomize Action -----------------------------------------
		if (actionTimer == 0):
			chosenAction = null
			randomize()
			chosenActionNum = rand_range(0,100)
			
			if (chosenActionNum >= 0 and chosenActionNum < 40):
				chosenAction = "Idle"
				actionTimer = IDLE_TIME
			elif (chosenActionNum >= 40 and chosenActionNum < 45):
				chosenAction = "Idle"
				actionTimer = IDLE_TIME
				direction *= -1
				
			elif (chosenActionNum >= 45 and chosenActionNum < 80):
				chosenAction = "Dash"
				actionTimer = DASH_TIME
			elif (chosenActionNum >= 80 and chosenActionNum < 85):
				chosenAction = "Dash"
				actionTimer = DASH_TIME
				direction *= -1
				
			elif (chosenActionNum >= 85 and chosenActionNum < 95):
				chosenAction = "SmallBlast"
				actionTimer = SMALL_BLAST_TIME
			elif (chosenActionNum >= 95 and chosenActionNum < 99):
				chosenAction = "ZaWarudo"
				actionTimer = ZA_WARUDO_COOLDOWN_TIME
			else:
				chosenAction = "Idle"
				actionTimer = IDLE_TIME

		if (chosenAction == "Idle" and actionTimer > 0):
			$AnimatedSprite.play("Idle")
			velocity.x = 0
			actionTimer -= 1
			
		elif (chosenAction == "Dash" and actionTimer > 0):
			$AnimatedSprite.play("Dash")
			velocity.x = speed * direction
			actionTimer -= 1
			
		elif (chosenAction == "SmallBlast" and actionTimer > 0):
			$AnimatedSprite.play("SmallBlast")
			
			var SmallBlast = SMALLBLAST.instance()
			SmallBlast.set_projectile_direction((sign($LeftProjectilePos.position.x)))
			get_parent().get_parent().add_child(SmallBlast)
			SmallBlast.global_position = $LeftProjectilePos.global_position
			
			var SmallBlast2 = SMALLBLAST.instance()
			SmallBlast2.set_projectile_direction((sign($RightProjectilePos.position.x)))
			get_parent().get_parent().add_child(SmallBlast2)
			SmallBlast2.global_position = $RightProjectilePos.global_position
				
			velocity.x = 0
			chosenAction = "Idle"
			actionTimer = SMALL_BLAST_COOLDOWN_TIME
			$Sounds/HitotsuChansu.play()
			
		elif (chosenAction == "ZaWarudo" and actionTimer > 0):
			$Sounds/ZaWarudo.play()
			velocity.x = 0
			chosenAction = "ZaWarudoDash"
			actionTimer = ZA_WARUDO_COOLDOWN_TIME
			isCurrentlyZaWarudo = true
			get_parent().get_parent().find_node("Player").find_node("ZaWarudoOverlay").modulate = Color(0.2,0.2,0.2,0.50)
			
		elif (chosenAction == "ZaWarudoDash" and actionTimer > 0):
			$AnimatedSprite.play("ZaWarudoDash")
			velocity.x = speed * 3 * direction
			actionTimer -= 1
			if (actionTimer == 0):
				isCurrentlyZaWarudo = false
				get_parent().get_parent().find_node("Player").find_node("ZaWarudoOverlay").modulate = Color(0.2,0.2,0.2,0)

		velocity = move_and_slide(velocity, FLOOR)
	
	if (is_on_wall()):
		direction *= -1
		$GroundRaycast.position.x *= -1
	
	if ($GroundRaycast.is_colliding() == false):
		direction *= -1
		$GroundRaycast.position.x *= -1
		
	if (get_slide_count() > 0):
		for i in range (get_slide_count()):
			if ("Player" in get_slide_collision(i).collider.name):
				if (get_slide_collision(i).collider.IFrames <= 0):
					get_slide_collision(i).collider.damagePlayer(damage)
					$Sounds/Noroi.play()


