extends Control

@onready var resume_button = $Panel/MarginContainer/VBoxContainer/ResumeButton
@onready var save_button = $Panel/MarginContainer/VBoxContainer/SaveButton
@onready var main_menu_button = $Panel/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $Panel/MarginContainer/VBoxContainer/QuitButton
@onready var status_label = $Panel/MarginContainer/VBoxContainer/StatusLabel

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_resume_pressed():
	get_parent().toggle_pause()

func _on_save_pressed():
	status_label.text = "Saving..."
	var result = await Global.save_character()
	if result.success:
		status_label.text = "Game saved!"
	else:
		status_label.text = "Save failed!"
	
	await get_tree().create_timer(2.0).timeout
	status_label.text = ""

func _on_main_menu_pressed():
	get_tree().paused = false
	await Global.save_character()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_quit_pressed():
	await Global.save_character()
	get_tree().quit()