extends Node

const BattleUnits = preload("res://BattleUnits.tres")

export(Array, PackedScene) var enemies = []

onready var battleActionButtons = $UI/BattleActionButtons
onready var animationPlayer = $AnimationPlayer
onready var nextRoomButton = $UI/CenterContainer/NextRoomButton
onready var enemyPosition = $EnemyPosition

onready var background_music = $BGMs/ReguarBGM
onready var boss_background_music = $BGMs/BossBGM
onready var boss_entrance_sfx = $BGMs/DIOEntrance

onready var textboxPanelContent = $UI/TextboxPanel/TextContent

func _ready():
	randomize()
	self.background_music.play()
	var enemy = BattleUnits.Enemy
	if (enemy != null):
		enemy.connect("died", self, "_on_Enemy_died")
	start_player_turn()

func start_enemy_turn():
	battleActionButtons.hide()
	var enemy = BattleUnits.Enemy
	if(enemy != null and not enemy.is_queued_for_deletion()):
		enemy.attack()
		yield(enemy, "end_turn")
	start_player_turn()
	
func start_player_turn():
	battleActionButtons.show()
	var playerStats = BattleUnits.PlayerStats
	playerStats.ap = playerStats.max_ap
	yield(playerStats, "end_turn") 
	start_enemy_turn()
	
func create_new_enemy():
	enemies.shuffle()
	var Enemy = enemies.front()
	var enemy = Enemy.instance()
	print("KONO " + enemy.name + " DA!")
	
	var background_music_stop_timestamp = background_music.get_playback_position()
	background_music.stop()
	
	if(enemy.name == "DIO"):
		boss_entrance_sfx.play()
		boss_background_music.play()
	else:
		background_music.play()
		background_music.seek(background_music_stop_timestamp)
		
	enemyPosition.add_child(enemy)
	enemy.connect("died", self, "_on_Enemy_died")
	
func _on_Enemy_died():
	nextRoomButton.show()
	battleActionButtons.hide()

func _on_NextRoomButton_pressed():
	nextRoomButton.hide()
	animationPlayer.play("FadeToNewRoom")
	yield(animationPlayer,"animation_finished")
	var playerStats = BattleUnits.PlayerStats
	playerStats.ap = playerStats.max_ap
	battleActionButtons.show()
	create_new_enemy()

func _on_HealActionButton_healAnimation():
	battleActionButtons.hide()
	textboxPanelContent.text = ""
	animationPlayer.play("HealGlow")
	yield(animationPlayer,"animation_finished")
	battleActionButtons.show()
