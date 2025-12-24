extends Control

@onready var character_name_input = $Panel/MarginContainer/VBoxContainer/CharacterNameInput
@onready var class_buttons = $Panel/MarginContainer/VBoxContainer/ClassSelection/ClassButtons
@onready var warrior_button = $Panel/MarginContainer/VBoxContainer/ClassSelection/ClassButtons/WarriorButton
@onready var mage_button = $Panel/MarginContainer/VBoxContainer/ClassSelection/ClassButtons/MageButton
@onready var rogue_button = $Panel/MarginContainer/VBoxContainer/ClassSelection/ClassButtons/RogueButton
@onready var class_info = $Panel/MarginContainer/VBoxContainer/ClassInfo
@onready var create_button = $Panel/MarginContainer/VBoxContainer/CreateButton
@onready var back_button = $Panel/MarginContainer/VBoxContainer/BackButton
@onready var status_label = $Panel/MarginContainer/VBoxContainer/StatusLabel

var selected_class: String = "warrior"

func _ready():
	warrior_button.pressed.connect(_on_class_selected.bind("warrior"))
	mage_button.pressed.connect(_on_class_selected.bind("mage"))
	rogue_button.pressed.connect(_on_class_selected.bind("rogue"))
	create_button.pressed.connect(_on_create_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	_on_class_selected("warrior")

func _on_class_selected(class_name: String):
	selected_class = class_name
	
	# Update button states
	warrior_button.disabled = (class_name == "warrior")
	mage_button.disabled = (class_name == "mage")
	rogue_button.disabled = (class_name == "rogue")
	
	# Update class info
	match class_name:
		"warrior":
			class_info.text = "Warrior\nHigh HP, Strong melee attacks\nHealth: 120 | Mana: 30\nStrength: 15 | Agility: 8"
		"mage":
			class_info.text = "Mage\nHigh mana, Powerful spells\nHealth: 80 | Mana: 100\nIntelligence: 15 | Agility: 8"
		"rogue":
			class_info.text = "Rogue\nBalanced, Fast attacks\nHealth: 90 | Mana: 50\nAgility: 15 | Strength: 10"

func _on_create_pressed():
	var char_name = character_name_input.text.strip_edges()
	if char_name.is_empty():
		status_label.text = "Please enter a character name"
		return
	
	status_label.text = "Creating character..."
	
	var result = await Global.create_character(Global.player_name, char_name, selected_class)
	if result.success:
		status_label.text = "Character created! Loading game..."
		
		# Add starting skill
		var skill_name = ""
		var skill_desc = ""
		match selected_class:
			"warrior":
				skill_name = "Power Strike"
				skill_desc = "A powerful melee attack dealing 2x damage"
			"mage":
				skill_name = "Fireball"
				skill_desc = "Launch a fireball dealing magical damage"
			"rogue":
				skill_name = "Backstab"
				skill_desc = "A quick strike with bonus damage"
		
		await Global.add_skill(skill_name, "attack", 10, skill_desc)
		
		# Add starting items
		await Global.add_item("Rusty Sword", "weapon", 1, {"damage": 5})
		await Global.add_item("Cloth Armor", "armor", 1, {"defense": 3})
		await Global.add_item("Health Potion", "potion", 3, {"heal": 30})
		
		# Add starting quest
		await Global.start_quest("Goblin Hunt", "Defeat 5 goblins terrorizing the village", "main", 5)
		
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	else:
		status_label.text = "Failed to create: " + str(result.get("error", "Unknown error"))

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()