extends CanvasLayer

@onready var health_label = $Panel/MarginContainer/VBoxContainer/StatsContainer/HealthLabel
@onready var mana_label = $Panel/MarginContainer/VBoxContainer/StatsContainer/ManaLabel
@onready var level_label = $Panel/MarginContainer/VBoxContainer/StatsContainer/LevelLabel
@onready var exp_label = $Panel/MarginContainer/VBoxContainer/StatsContainer/ExpLabel
@onready var gold_label = $Panel/MarginContainer/VBoxContainer/StatsContainer/GoldLabel
@onready var achievement_popup = $AchievementPopup

func _ready():
	update_display()
	achievement_popup.visible = false

func update_display():
	health_label.text = "HP: %d/%d" % [Global.health, Global.max_health]
	mana_label.text = "MP: %d/%d" % [Global.mana, Global.max_mana]
	level_label.text = "Level: %d" % Global.level
	
	var exp_needed = 100 * Global.level * Global.level
	exp_label.text = "EXP: %d/%d" % [Global.experience, exp_needed]
	gold_label.text = "Gold: %d" % Global.gold

func show_achievement(achievement_name: String):
	achievement_popup.get_node("Label").text = "Achievement Unlocked!\n" + achievement_name
	achievement_popup.visible = true
	await get_tree().create_timer(3.0).timeout
	achievement_popup.visible = false