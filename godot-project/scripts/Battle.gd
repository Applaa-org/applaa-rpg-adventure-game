extends Control

@onready var enemy_sprite = $BattleArea/EnemySprite
@onready var player_sprite = $BattleArea/PlayerSprite
@onready var enemy_hp_label = $BattleArea/EnemyHP
@onready var battle_log = $ActionArea/BattleLog
@onready var attack_button = $ActionArea/ActionButtons/AttackButton
@onready var skill_button = $ActionArea/ActionButtons/SkillButton
@onready var item_button = $ActionArea/ActionButtons/ItemButton
@onready var flee_button = $ActionArea/ActionButtons/FleeButton

var enemy_name: String = "Goblin"
var enemy_health: int = 40
var enemy_max_health: int = 40
var enemy_damage: int = 8
var enemy_exp: int = 25
var enemy_gold: int = 10

var player_turn: bool = true

func _ready():
	# Load enemy data
	enemy_name = Global.get("current_enemy", "Goblin")
	load_enemy_data()
	
	# Connect buttons
	attack_button.pressed.connect(_on_attack_pressed)
	skill_button.pressed.connect(_on_skill_pressed)
	item_button.pressed.connect(_on_item_pressed)
	flee_button.pressed.connect(_on_flee_pressed)
	
	# Update display
	update_display()
	add_log("Battle started against " + enemy_name + "!")

func load_enemy_data():
	match enemy_name:
		"Goblin":
			enemy_health = 40
			enemy_max_health = 40
			enemy_damage = 8
			enemy_exp = 25```gdscript
			enemy_gold = 10
		"Orc Warrior":
			enemy_health = 80
			enemy_max_health = 80
			enemy_damage = 15
			enemy_exp = 50
			enemy_gold = 25
		"Dark Mage":
			enemy_health = 60
			enemy_max_health = 60
			enemy_damage = 20
			enemy_exp = 75
			enemy_gold = 40
		"Dragon":
			enemy_health = 200
			enemy_max_health = 200
			enemy_damage = 35
			enemy_exp = 500
			enemy_gold = 200

func update_display():
	enemy_hp_label.text = "%s HP: %d/%d" % [enemy_name, enemy_health, enemy_max_health]

func add_log(text: String):
	battle_log.text += text + "\n"
	# Auto-scroll to bottom
	await get_tree().process_frame
	battle_log.scroll_vertical = int(battle_log.get_v_scroll_bar().max_value)

func _on_attack_pressed():
	if not player_turn:
		return
	
	player_turn = false
	disable_buttons()
	
	var damage = Global.strength + randi_range(5, 15)
	enemy_health -= damage
	add_log("You deal " + str(damage) + " damage!")
	
	update_display()
	
	await get_tree().create_timer(0.5).timeout
	
	if enemy_health <= 0:
		win_battle()
	else:
		enemy_turn()

func _on_skill_pressed():
	if not player_turn or Global.skills.size() == 0:
		return
	
	var skill = Global.skills[0]
	var mana_cost = skill.get("mana_cost", 10)
	
	if not Global.use_mana(mana_cost):
		add_log("Not enough mana!")
		return
	
	player_turn = false
	disable_buttons()
	
	var damage = Global.intelligence * 2 + randi_range(10, 20)
	enemy_health -= damage
	add_log("You use " + skill.skill_name + " for " + str(damage) + " damage!")
	
	update_display()
	
	await get_tree().create_timer(0.5).timeout
	
	if enemy_health <= 0:
		win_battle()
	else:
		enemy_turn()

func _on_item_pressed():
	if not player_turn:
		return
	
	# Find health potion
	var potion_found = false
	for item in Global.inventory:
		if item.item_name == "Health Potion" and item.quantity > 0:
			potion_found = true
			Global.heal(30)
			add_log("You used a Health Potion! Restored 30 HP!")
			
			# Update item quantity (simplified - should call API)
			item.quantity -= 1
			if item.quantity <= 0:
				await Global.remove_item(item.id)
			
			player_turn = false
			disable_buttons()
			
			await get_tree().create_timer(0.5).timeout
			enemy_turn()
			break
	
	if not potion_found:
		add_log("No health potions available!")

func _on_flee_pressed():
	if not player_turn:
		return
	
	var flee_chance = randi_range(1, 100)
	if flee_chance > 50:
		add_log("You successfully fled from battle!")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	else:
		add_log("Failed to flee!")
		player_turn = false
		disable_buttons()
		await get_tree().create_timer(0.5).timeout
		enemy_turn()

func enemy_turn():
	await get_tree().create_timer(1.0).timeout
	
	var damage = enemy_damage + randi_range(-3, 5)
	Global.take_damage(damage)
	add_log(enemy_name + " deals " + str(damage) + " damage!")
	
	await get_tree().create_timer(0.5).timeout
	
	if Global.health <= 0:
		lose_battle()
	else:
		player_turn = true
		enable_buttons()

func win_battle():
	add_log("Victory! You defeated " + enemy_name + "!")
	add_log("Gained " + str(enemy_exp) + " EXP and " + str(enemy_gold) + " gold!")
	
	Global.add_experience(enemy_exp)
	Global.add_gold(enemy_gold)
	Global.battles_won += 1
	Global.total_enemies_defeated += 1
	
	# Update quest progress
	if Global.active_quests.size() > 0:
		var quest = Global.active_quests[0]
		if quest.quest_name == "Goblin Hunt" and enemy_name == "Goblin":
			var new_progress = quest.progress + 1
			await Global.update_quest_progress(quest.id, new_progress)
	
	# Check achievements
	if Global.battles_won == 1:
		await Global.unlock_achievement("First Blood", "Win your first battle")
	
	if enemy_name == "Dragon":
		await Global.unlock_achievement("Dragon Slayer", "Defeat the legendary dragon")
	
	# Log battle
	await Global.log_battle(enemy_name, "victory", enemy_exp, enemy_gold, [])
	
	# Save progress
	await Global.save_character()
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func lose_battle():
	add_log("You have been defeated!")
	
	# Log battle
	await Global.log_battle(enemy_name, "defeat", 0, 0, [])
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")

func disable_buttons():
	attack_button.disabled = true
	skill_button.disabled = true
	item_button.disabled = true
	flee_button.disabled = true

func enable_buttons():
	attack_button.disabled = false
	skill_button.disabled = false
	item_button.disabled = false
	flee_button.disabled = false