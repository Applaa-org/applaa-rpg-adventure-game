extends Node

func _ready():
	# Load the start screen
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")