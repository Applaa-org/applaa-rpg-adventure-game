extends Control

@onready var title_label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var stats_label = $Panel/MarginContainer/VBoxContainer/StatsLabel
@onready var restart_button = $Panel/MarginContainer/VBoxContainer/RestartButton
@onready var main_menu_button = $Panel/MarginContainer/VBoxContainer/MainMenuButton
@onready var close_button = $Panel/MarginContainer/VBoxContainer/CloseButton

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Display stats
	var stats_text = "Quest Completed!\n\n"
	stats_text += "Character: %s\n" % Global.character_name
	stats_text += "Class: %s\n" % Global.character_class.capitalize()
	stats_text += "Final Level: %d\n" % Global.level
	stats_text += "Total Gold: %d\n" % Global.gold
	stats_text += "Battles Won: %d\n" % Global.battles_won
	stats_text += "Enemies Defeated: %d\n" % Global.total_enemies_defeated
	stats_label.text = stats_text
	
	# Save final progress
	await Global.save_character()

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_main_menu_pressed()