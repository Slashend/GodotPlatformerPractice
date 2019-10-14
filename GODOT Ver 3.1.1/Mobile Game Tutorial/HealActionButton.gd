extends "res://ActionButton.gd"

signal healAnimation

func _on_pressed():
	var playerStats = BattleUnits.PlayerStats
	if (playerStats != null):
		if (playerStats.mp >= 8):
			# emit_signal("healAnimation")
			playerStats.hp += 5
			playerStats.mp -= 8
			playerStats.ap -= 1
	
