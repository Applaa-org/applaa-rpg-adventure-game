extends Control

@onready var player_name_input = $Panel/MarginContainer/VBoxContainer/PlayerNameInput
@onready var character_list = $Panel/MarginContainer/VBoxContainer/CharacterList
@onready var load_button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/LoadButton
@onready var create_button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/CreateButton
@onready var delete_button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/DeleteButton
@onready var close_button = $Panel/MarginContainer/VBoxContainer/CloseButton
@onready var status_label = $Panel/MarginContainer/VBoxContainer/StatusLabel

var characters: Array = []
var selected_character_id: int = -1

func _ready():
	load_button.pressed.connect(_on_load_pressed)
	create_button.pressed.connect(_on_create_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	close_button.pressed.connect(_on_close_pressed)
	character_list.item_selected.connect(_on_character_selected)
	
	status_label.text = "Enter your player name and load/create a character"
	
	# Try to load last player name from local storage
	if FileAccess.file_exists("user://last_player.txt"):
		var file = FileAccess.open("user://last_player.txt", FileAccess.READ)
		player_name_input.text = file.get_line()
		file.close()

func _on_load_pressed():
	var p_name = player_name_input.text.strip_edges()
	if p_name.is_empty():
		status_label.text = "Please enter a player name"
		return
	
	status_label.text = "Loading characters..."
	
	# Save player name
	var file = FileAccess.open("user://last_player.txt", FileAccess.WRITE)
	file.store_line(p_name)
	file.close()
	
	Global.player_name = p_name
	
	var result = await Global.load_characters(p_name)
	if result.success:
		characters = result.data if typeof(result.data) == TYPE_ARRAY else []
		update_character_list()
		if characters.size() > 0:
			status_label.text = "Select a character and click 'Load Character'"
		else:
			status_label.text = "No characters found. Click 'Create New Character'"
	else:
		status_label.text = "Failed to load characters: " + str(result.get("error", "Unknown error"))

func update_character_list():
	character_list.clear()
	for char in characters:
		var display = "%s (%s) - Level %d" % [char.character_name, char.character_class.capitalize(), char.level]
		character_list.add_item(display)

func _on_character_selected(index: int):
	if index >= 0 and index < characters.size():
		selected_character_id = characters[index].id

func _on_create_pressed():
	get_tree().change_scene_to_file("res://scenes/CharacterCreation.tscn")

func _on_delete_pressed():
	if selected_character_id <= 0:
		status_label.text = "Please select a character to delete"
		return
	
	status_label.text = "Deleting character..."
	var result = await Global.delete_character(selected_character_id)
	if result.success:
		status_label.text = "Character deleted!"
		selected_character_id = -1
		_on_load_pressed()  # Refresh list
	else:
		status_label.text = "Failed to delete: " + str(result.get("error", "Unknown error"))

func _on_close_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("ui_accept") and selected_character_id > 0:
		load_selected_character()

func load_selected_character():
	if selected_character_id <= 0:
		status_label.text = "Please select a character"
		return
	
	status_label.text = "Loading character..."
	var result = await Global.load_character(selected_character_id)
	if result.success:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	else:
		status_label.text = "Failed to load character: " + str(result.get("error", "Unknown error"))