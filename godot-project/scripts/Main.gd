extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var world_map = $WorldMap
@onready var pause_menu = $PauseMenu

var paused: bool = false

func _ready():
	# Connect signals
	Global.stats_updated.connect(_on_stats_updated)
	Global.achievement_unlocked.connect(_on_achievement_unlocked)
	
	# Initialize UI
	ui.update_display()
	
	# Hide pause menu
	pause_menu.visible = false
	
	print("Game loaded! Character: ", Global.character_name, " Level: ", Global.level)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	paused = !paused
	pause_menu.visible = paused
	get_tree().paused = paused

func _on_stats_updated():
	ui.update_display()

func _on_achievement_unlocked(achievement_name: String):
	ui.show_achievement(achievement_name)

func start_battle(enemy_name: String):
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")
	# Pass enemy name through Global
	Global.current_enemy = enemy_name