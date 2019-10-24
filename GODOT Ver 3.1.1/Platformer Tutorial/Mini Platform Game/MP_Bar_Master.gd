extends Sprite

onready var mp_bar = $MP_Bar

export (Color) var healthy_color = Color.green
export (Color) var caution_color = Color.yellow
export (Color) var danger_color = Color.red 

export (float, 0, 1, 0.05) var caution_threshold = 0.66
export (float, 0, 1, 0.05) var danger_threshold = 0.33

func changeValue(mp, maxMP):
	mp_bar.value = mp*100/maxMP # to avoid integer division resulting to zero
	assignColor(mp, maxMP)

func assignColor(mp, maxMP):
	if (mp < maxMP * danger_threshold):
		mp_bar.tint_progress = danger_color
	elif (mp < maxMP * caution_threshold):
		mp_bar.tint_progress = caution_color
	else:
		mp_bar.tint_progress = healthy_color
	
func _ready():
	pass 
