extends KinematicBody2D

# ----------------------------------------- MOVEMENT and HP CONSTANTS -----------------------------------------
const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_DASH_SPEED = 250
const MAX_RUN_SPEED = 150
const JUMP_HEIGHT = -550
const STARTING_HEALTH = 100
const STARTING_MP = 100
const STARTING_SCORE = 0

# ----------------------------------------- MEGABUSTER CONSTANTS -----------------------------------------
const FIREBALL = preload("res://Projectiles/Fireball.tscn")
const FIREBALL2 = preload("res://Projectiles/Fireball2.tscn")
const FIREBALL3 = preload("res://Projectiles/Fireball3.tscn")
const CHARGESHOT_THRESHOLD_1 = 25
const CHARGESHOT_THRESHOLD_2 = 100 
const FULLCHARGE_SHOT_COST = 40 
const HALFCHARGE_SHOT_COST = 35
const REGULAR_SHOT_COST = 30

# ----------------------------------------- OTHER VARIABLES -----------------------------------------
var state  # running, jumping, etc.
var busterDelay = 0
var chargingTime = 0
var motion = Vector2()
var isDead = false
var health = STARTING_HEALTH
var mp = STARTING_MP
var IFrames = 0
var score = 0

"""
============================================ SET INITIAL HEALTH ============================================
"""

func _ready():
	health = GlobalSingleton.tempPlayerHealth
	mp = GlobalSingleton.tempPlayerMP
	score = GlobalSingleton.tempPlayerScore
	$UI/HP_Bar_Master.changeValueHeal(health,STARTING_HEALTH,false)
	$UI/MP_Bar_Master.changeValue(mp,STARTING_MP)

"""
============================================ PLAYER DAMAGED FUNCTIONS ============================================
"""

func damagePlayer(damageTaken):
	if (isDead == false):
		health -= damageTaken
		$UI/HP_Bar_Master.changeValueDamage(health,STARTING_HEALTH,true)
		
		if (health <= 0):
			killPlayer()
		else:
			$Sprite.play("Damaged")
			$AileSFX/Damaged.play()
			IFrames = 25

func healPlayer(damageHealed):
	
	if (health + damageHealed < STARTING_HEALTH):
		health += damageHealed
	else:
		health = STARTING_HEALTH
		
	$UI/HP_Bar_Master.changeValueHeal(health,STARTING_HEALTH,true)
	$AileSFX/Heal.play()

func killPlayer():
	isDead = true
	$AileSFX/Scream.play()
	$AileSFX/DeathSFX.play()
	motion = Vector2(0,0)
	$Sprite.play("Dead")
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Timer.start()

func _on_Timer_timeout():
	GlobalSingleton.tempPlayerHealth = STARTING_HEALTH
	GlobalSingleton.tempPlayerScore = STARTING_SCORE
	get_tree().change_scene("res://UI Elements/StartMenu.tscn")

"""
============================================ PHYSICS PROCESSES FUNCTION ============================================
"""

func _physics_process(delta):
	
	if (isDead == false):
		"""
		----------------------------------------- GRAVITY AND COUNTERS -----------------------------------------
		"""
		motion.y += GRAVITY
		var friction = false
		if (busterDelay > 0):
			busterDelay -= 1
		if (IFrames > 0):
			IFrames -= 1
		if (mp < STARTING_MP):
			mp += 1
			$UI/MP_Bar_Master.changeValue(mp,STARTING_MP)

		"""
		----------------------------------------- USER INPUT AND MOVEMENT -----------------------------------------
		"""
		# MOVE RIGHT
		if (Input.is_action_pressed("ui_right")):
			motion.x = min(motion.x + ACCELERATION, MAX_RUN_SPEED)
			$Sprite.flip_h = false
			if(busterDelay <= 0):
				$Sprite.play("Run")
			state = "RUNNING"
			# If megabuster position is at the left, swap position back to right
			if (sign($MegabusterPosition.position.x) == -1):
				$MegabusterPosition.position.x *= -1
			
		# MOVE LEFT
		elif (Input.is_action_pressed("ui_left")):
			motion.x = max(motion.x - ACCELERATION, -MAX_RUN_SPEED)
			$Sprite.flip_h = true
			if(busterDelay <= 0):
				$Sprite.play("Run")
			state = "RUNNING"
			# If megabuster position is at the right, swap position back to left
			if (sign($MegabusterPosition.position.x) == 1):
				$MegabusterPosition.position.x *= -1
		
		# IDLE ON GROUND
		else:
			if(busterDelay <= 0 and IFrames <= 0):
				$Sprite.play("Idle")
			state = "GROUNDED"
			friction = true
			
		# JUMP
		if (is_on_floor()):
			if (Input.is_action_just_pressed("ui_up")):
				$AileSFX/Jump.play()
				motion.y = JUMP_HEIGHT
				
			if (friction == true):
				motion.x = lerp(motion.x, 0, 0.2)
		# JUMP AND FALL 
		else:
			if (motion.y < 0):
				if(busterDelay <= 0 and IFrames <= 0):
					$Sprite.play("Jump")
				state = "JUMPING"
			else:
				if(busterDelay <= 0 and IFrames <= 0):
					$Sprite.play("Fall")
				state = "FALLING"
				
			if (friction == true):
				motion.x = lerp(motion.x, 0, 0.05)
	
	
		"""
		----------------------------------------- CHARGE MEGABUSTER -----------------------------------------
		"""
		if (Input.is_action_pressed("ui_focus_next")):
			
			# CHARGING animation
			chargingTime += 1
			if (chargingTime > CHARGESHOT_THRESHOLD_1 and chargingTime <= CHARGESHOT_THRESHOLD_2):
				$ChargeshotSprite.play("Level2")
			elif (chargingTime > CHARGESHOT_THRESHOLD_2):
				$ChargeshotSprite.play("Level3")
			else:
				$ChargeshotSprite.play("Level1")
			
			# PLAYER animation change
			if (state == "GROUNDED"):
				$Sprite.play("BusterGround")
				busterDelay = 15
			elif (state == "RUNNING"):
				var temp = $Sprite.frame
				$Sprite.play("BusterRun")
				$Sprite.frame = temp
				busterDelay = 15
			elif (state == "JUMPING" or state == "FALLING"):
				$Sprite.play("BusterAir")
				busterDelay = 10
			if (chargingTime > 0 and !$BusterAudio/chargeAudio.is_playing() and !$BusterAudio/regBusterShot.is_playing()):
				$BusterAudio/chargeAudio.play()
	
	
		"""
		----------------------------------------- FIRE MEGABUSTER -----------------------------------------
		"""
		if (Input.is_action_just_released("ui_focus_next")):
			
			if (chargingTime > CHARGESHOT_THRESHOLD_1 and chargingTime <= CHARGESHOT_THRESHOLD_2):
				if (mp >= HALFCHARGE_SHOT_COST):
					$AileSFX/chargeShotVoice2.play()
					$BusterAudio/weakChargeShot.play()
					var fireball = FIREBALL2.instance()
					fireball.set_fireball_direction((sign($MegabusterPosition.position.x)))
					get_parent().add_child(fireball)
					fireball.global_position = $MegabusterPosition.global_position
					mp -= HALFCHARGE_SHOT_COST
				
			elif (chargingTime > CHARGESHOT_THRESHOLD_2):
				if (mp >= FULLCHARGE_SHOT_COST):
					$AileSFX/chargeShotVoice1.play()
					$BusterAudio/strongChargeShot.play()
					var fireball = FIREBALL3.instance()
					fireball.set_fireball_direction((sign($MegabusterPosition.position.x)))
					get_parent().add_child(fireball)
					fireball.global_position = $MegabusterPosition.global_position
					mp -= FULLCHARGE_SHOT_COST

			else:
				if (mp >= REGULAR_SHOT_COST):
					$BusterAudio/regBusterShot.play()
					var fireball = FIREBALL.instance()
					fireball.set_fireball_direction((sign($MegabusterPosition.position.x)))
					get_parent().add_child(fireball)
					fireball.global_position = $MegabusterPosition.global_position
					mp -= REGULAR_SHOT_COST
					
			
			# Reset animation
			$UI/MP_Bar_Master.changeValue(mp,STARTING_MP)
			$BusterAudio/chargeAudio.stop()
			$ChargeshotSprite.play("Level1")
			chargingTime = 0
	
	
	
		"""	
		----------------------------------------- ACTUALLY MOVE PLAYER -----------------------------------------
		"""
		motion = move_and_slide(motion,UP)
		
		if (get_slide_count() > 0 and IFrames <= 0):
			for i in range (get_slide_count()):
				if ("[ENEMY]" in get_slide_collision(i).collider.name):
					damagePlayer(get_slide_collision(i).collider.damage)
				if ("[BOSS]" in get_slide_collision(i).collider.name):
					damagePlayer(get_slide_collision(i).collider.damage)


