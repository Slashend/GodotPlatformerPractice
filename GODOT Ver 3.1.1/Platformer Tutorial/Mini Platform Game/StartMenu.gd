# StartMenu.gd
extends Control

const CAMPAIGN_BUTTON_DESCRIPTION = "Complete all the levels! \nNot fully implemented yet."
const EXTREME_BUTTON_DESCRIPTION = "Take on an endless horde of enemies! \nNot implemented yet."
const EXIT_BUTTON_DESCRIPTION = "Take a rest from the game. \nWe'll miss you! :("
const DEFAULT_DESCRIPTION = "CONTROLS: \n\n [Arrow Keys] - Move and jump \n [Tab] - Charge or fire the megabuster"

func _ready():
	$MarginContainer/HBoxContainer/Buttons/CampaignButton.grab_focus()
	$MarginContainer/HBoxContainer/VBoxContainer/Description.text = "Campaign button hovered"

func _physics_process(delta):

	if ($MarginContainer/HBoxContainer/Buttons/CampaignButton.is_hovered() == true):
		$MarginContainer/HBoxContainer/Buttons/CampaignButton.grab_focus()
		$MarginContainer/HBoxContainer/VBoxContainer/Description.text = CAMPAIGN_BUTTON_DESCRIPTION
		$MarginContainer/HBoxContainer/Buttons/CampaignButton.modulate = Color(1,1,1,1)
		$MarginContainer/HBoxContainer/Buttons/ExtremeButton.modulate = Color(1,1,1,0.25)
		$MarginContainer/HBoxContainer/Buttons/ExitButton.modulate = Color(1,1,1,0.25)

	elif ($MarginContainer/HBoxContainer/Buttons/ExtremeButton.is_hovered() == true):
		$MarginContainer/HBoxContainer/Buttons/ExtremeButton.grab_focus()
		$MarginContainer/HBoxContainer/VBoxContainer/Description.text = EXTREME_BUTTON_DESCRIPTION
		$MarginContainer/HBoxContainer/Buttons/CampaignButton.modulate = Color(1,1,1,0.25)
		$MarginContainer/HBoxContainer/Buttons/ExtremeButton.modulate = Color(1,1,1,1)
		$MarginContainer/HBoxContainer/Buttons/ExitButton.modulate = Color(1,1,1,0.25)
		
	elif ($MarginContainer/HBoxContainer/Buttons/ExitButton.is_hovered() == true):
		$MarginContainer/HBoxContainer/Buttons/ExitButton.grab_focus()
		$MarginContainer/HBoxContainer/VBoxContainer/Description.text = EXIT_BUTTON_DESCRIPTION
		$MarginContainer/HBoxContainer/Buttons/CampaignButton.modulate = Color(1,1,1,0.25)
		$MarginContainer/HBoxContainer/Buttons/ExtremeButton.modulate = Color(1,1,1,0.25)
		$MarginContainer/HBoxContainer/Buttons/ExitButton.modulate = Color(1,1,1,1)
	
	else:
		$MarginContainer/HBoxContainer/VBoxContainer/Description.text = DEFAULT_DESCRIPTION
		$MarginContainer/HBoxContainer/Buttons/CampaignButton.modulate = Color(1,1,1,0.25)
		$MarginContainer/HBoxContainer/Buttons/ExtremeButton.modulate = Color(1,1,1,0.25)
		$MarginContainer/HBoxContainer/Buttons/ExitButton.modulate = Color(1,1,1,0.25)

func _on_CampaignButton_pressed():
	get_tree().change_scene("res://World.tscn")


func _on_ExtremeButton_pressed():
	pass # Replace with function body.


func _on_ExitButton_pressed():
	get_tree().quit()
