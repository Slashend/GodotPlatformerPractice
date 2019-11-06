extends Sprite

signal pulse()

onready var hp_bar_over = $HP_Bar_Green
onready var hp_bar_under = $HP_Bar_Red
onready var updateTween = $UpdateTween
onready var pulseTween =$PulseTween

export (Color) var healthy_color = Color.green
export (Color) var caution_color = Color.yellow
export (Color) var danger_color = Color.red 
export (Color) var pulse_color = Color.darkred
export (bool) var will_pulse = false

export (float, 0, 1, 0.05) var caution_threshold = 0.5
export (float, 0, 1, 0.05) var danger_threshold = 0.2

func changeValueDamage(health, maxHealth, shouldTween):
	hp_bar_over.value = health*100/maxHealth # to avoid integer division resulting to zero
	
	if (shouldTween):
		updateTween.interpolate_property(hp_bar_under, "value", hp_bar_under.value, health*100/maxHealth, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.25)
		updateTween.start()
	elif (!shouldTween):
		hp_bar_under.value = health*100/maxHealth
		
	assignColor(health, maxHealth)
	
func changeValueHeal(health, maxHealth, shouldTween):
	hp_bar_under.value = health*100/maxHealth # to avoid integer division resulting to zero
	
	if (shouldTween):
		updateTween.interpolate_property(hp_bar_over, "value", hp_bar_over.value, health*100/maxHealth, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.25)
		updateTween.start()
	elif (!shouldTween):
		hp_bar_over.value = health*100/maxHealth
		
	assignColor(health, maxHealth)

func assignColor(health, maxHealth):
	if (health <= 0):
		pulseTween.set_active(false)
	# Tween sound if in danger threshold
	if (health < maxHealth * danger_threshold):
		if (will_pulse):
			if (!pulseTween.is_active()):
				pulseTween.interpolate_property(hp_bar_over, "tint_progress", pulse_color, danger_color, 1.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
				pulseTween.interpolate_callback(self, 0.0, "emit_signal", "pulse")
				pulseTween.start()
				$PulseTween/AudioStreamPlayer.play()
		else:
			hp_bar_over.tint_progress = danger_color
	# If not in danger threshold and no sound tweening
	else:
		pulseTween.set_active(false)
		if (health < maxHealth * caution_threshold):
			hp_bar_over.tint_progress = caution_color
		else:
			hp_bar_over.tint_progress = healthy_color
	
func _ready():
	pass 