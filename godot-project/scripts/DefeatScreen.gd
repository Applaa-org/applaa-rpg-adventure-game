extends Control

@onready var stats_label = $Panel/MarginContainer/VBoxContainer/StatsLabel
@onready var retry_button = $Panel/MarginContainer/VBoxContainer/RetryButton
@onready var main_menu_button = $Panel/MarginContainer/VBoxContainer/MainMenuButton
@onready var close_button = $Panel/MarginContainer/VBoxContainer/CloseButton

func _ready():
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Display stats
	var stats_text = "You were defeated!\n\n"
	stats_text += "Character: %s (Level %d)\n" % [Global.character_name, Global.level]
	stats_text += "Experience: %d\n" % Global.experience
	stats_text += "Gold: %d\n" % Global.gold
	stats_text += "\nDon't give up, hero!"
	stats_label.text = stats_text
	
	# Restore some health for retry
	Global.health = int(Global.max_health * 0.5)
	Global.mana = int(Global.max_mana * 0.5)

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_main_menu_pressed()