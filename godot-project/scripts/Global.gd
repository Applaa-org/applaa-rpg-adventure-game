extends Node

# API Configuration
const API_URL = "https://haix.ai/api"

# Current Character Data
var current_character: Dictionary = {}
var character_id: int = -1
var player_name: String = ""

# Game State
var score: int = 0
var battles_won: int = 0
var total_enemies_defeated: int = 0

# Character Stats (cached from database)
var character_name: String = ""
var character_class: String = ""
var level: int = 1
var experience: int = 0
var health: int = 100
var max_health: int = 100
var mana: int = 50
var max_mana: int = 50
var strength: int = 10
var intelligence: int = 10
var agility: int = 10
var gold: int = 0

# Inventory & Skills (cached)
var inventory: Array = []
var skills: Array = []
var active_quests: Array = []
var achievements: Array = []

# Signals
signal character_loaded
signal character_saved
signal stats_updated
signal inventory_updated
signal quest_updated
signal achievement_unlocked

# ============================================
# API FUNCTIONS - CHARACTER MANAGEMENT
# ============================================

func create_character(p_name: String, char_name: String, char_class: String) -> Dictionary:
	var body = {
		"player_name": p_name,
		"character_name": char_name,
		"character_class": char_class.to_lower()
	}
	
	var result = await _api_request("POST", "/characters", body)
	if result.success:
		load_character_from_dict(result.data)
	return result

func load_characters(p_name: String) -> Dictionary:
	var result = await _api_request("GET", "/characters?player_name=" + p_name)
	return result

func load_character(char_id: int) -> Dictionary:
	var result = await _api_request("GET", "/characters/" + str(char_id))
	if result.success:
		load_character_from_dict(result.data)
		character_id = char_id
		
		# Load related data
		await load_inventory(char_id)
		await load_skills(char_id)
		await load_quests(char_id)
		await load_achievements(char_id)
		
		character_loaded.emit()
	return result

func save_character() -> Dictionary:
	if character_id <= 0:
		return {"success": false, "error": "No character loaded"}
	
	var body = {
		"level": level,
		"experience": experience,
		"health": health,
		"max_health": max_health,
		"mana": mana,
		"max_mana": max_mana,
		"strength": strength,
		"intelligence": intelligence,
		"agility": agility,
		"gold": gold,
		"last_played": Time.get_datetime_string_from_system()
	}
	
	var result = await _api_request("PUT", "/characters/" + str(character_id), body)
	if result.success:
		character_saved.emit()
	return result

func delete_character(char_id: int) -> Dictionary:
	return await _api_request("DELETE", "/characters/" + str(char_id))

# ============================================
# API FUNCTIONS - INVENTORY
# ============================================

func load_inventory(char_id: int) -> Dictionary:
	var result = await _api_request("GET", "/character_inventory?character_id=" + str(char_id))
	if result.success:
		inventory = result.data if typeof(result.data) == TYPE_ARRAY else []
		inventory_updated.emit()
	return result

func add_item(item_name: String, item_type: String, quantity: int = 1, stats: Dictionary = {}) -> Dictionary:
	var body = {
		"character_id": character_id,
		"item_name": item_name,
		"item_type": item_type,
		"quantity": quantity,
		"stats": stats
	}
	
	var result = await _api_request("POST", "/character_inventory", body)
	if result.success:
		await load_inventory(character_id)
	return result

func remove_item(item_id: int) -> Dictionary:
	var result = await _api_request("DELETE", "/character_inventory/" + str(item_id))
	if result.success:
		await load_inventory(character_id)
	return result

func equip_item(item_id: int) -> Dictionary:
	var body = {"equipped": true}
	var result = await _api_request("PUT", "/character_inventory/" + str(item_id), body)
	if result.success:
		await load_inventory(character_id)
	return result

# ============================================
# API FUNCTIONS - SKILLS
# ============================================

func load_skills(char_id: int) -> Dictionary:
	var result = await _api_request("GET", "/character_skills?character_id=" + str(char_id))
	if result.success:
		skills = result.data if typeof(result.data) == TYPE_ARRAY else []
	return result

func add_skill(skill_name: String, skill_type: String, mana_cost: int, description: String) -> Dictionary:
	var body = {
		"character_id": character_id,
		"skill_name": skill_name,
		"skill_type": skill_type,
		"mana_cost": mana_cost,
		"description": description
	}
	
	var result = await _api_request("POST", "/character_skills", body)
	if result.success:
		await load_skills(character_id)
	return result

# ============================================
# API FUNCTIONS - QUESTS
# ============================================

func load_quests(char_id: int) -> Dictionary:
	var result = await _api_request("GET", "/character_quests?character_id=" + str(char_id))
	if result.success:
		active_quests = result.data if typeof(result.data) == TYPE_ARRAY else []
		quest_updated.emit()
	return result

func start_quest(quest_name: String, quest_desc: String, quest_type: String, max_progress: int) -> Dictionary:
	var body = {
		"character_id": character_id,
		"quest_name": quest_name,
		"quest_description": quest_desc,
		"quest_type": quest_type,
		"max_progress": max_progress
	}
	
	var result = await _api_request("POST", "/character_quests", body)
	if result.success:
		await load_quests(character_id)
	return result

func update_quest_progress(quest_id: int, progress: int) -> Dictionary:
	var body = {"progress": progress}
	var result = await _api_request("PUT", "/character_quests/" + str(quest_id), body)
	if result.success:
		await load_quests(character_id)
	return result

func complete_quest(quest_id: int) -> Dictionary:
	var body = {
		"status": "completed",
		"completed_at": Time.get_datetime_string_from_system()
	}
	var result = await _api_request("PUT", "/character_quests/" + str(quest_id), body)
	if result.success:
		await load_quests(character_id)
	return result

# ============================================
# API FUNCTIONS - ACHIEVEMENTS
# ============================================

func load_achievements(char_id: int) -> Dictionary:
	var result = await _api_request("GET", "/character_achievements?character_id=" + str(char_id))
	if result.success:
		achievements = result.data if typeof(result.data) == TYPE_ARRAY else []
	return result

func unlock_achievement(achievement_name: String, achievement_desc: String) -> Dictionary:
	var body = {
		"character_id": character_id,
		"achievement_name": achievement_name,
		"achievement_description": achievement_desc
	}
	
	var result = await _api_request("POST", "/character_achievements", body)
	if result.success:
		await load_achievements(character_id)
		achievement_unlocked.emit(achievement_name)
	return result

# ============================================
# API FUNCTIONS - BATTLE LOGS
# ============================================

func log_battle(enemy_name: String, result: String, exp_gained: int, gold_gained: int, items: Array) -> Dictionary:
	var body = {
		"character_id": character_id,
		"enemy_name": enemy_name,
		"result": result,
		"experience_gained": exp_gained,
		"gold_gained": gold_gained,
		"items_dropped": items
	}
	
	return await _api_request("POST", "/battle_logs", body)

# ============================================
# HELPER FUNCTIONS
# ============================================

func load_character_from_dict(data: Dictionary):
	current_character = data
	character_name = data.get("character_name", "")
	character_class = data.get("character_class", "")
	level = data.get("level", 1)
	experience = data.get("experience", 0)
	health = data.get("health", 100)
	max_health = data.get("max_health", 100)
	mana = data.get("mana", 50)
	max_mana = data.get("max_mana", 50)
	strength = data.get("strength", 10)
	intelligence = data.get("intelligence", 10)
	agility = data.get("agility", 10)
	gold = data.get("gold", 0)
	
	stats_updated.emit()

func add_experience(amount: int):
	experience += amount
	check_level_up()
	stats_updated.emit()

func check_level_up():
	var exp_needed = 100 * level * level
	while experience >= exp_needed:
		level_up()
		exp_needed = 100 * level * level

func level_up():
	level += 1
	max_health += 10
	max_mana += 5
	strength += 2
	intelligence += 2
	agility += 2
	health = max_health
	mana = max_mana
	
	# Check level achievements
	if level == 10:
		await unlock_achievement("Level 10", "Reached level 10")
	
	stats_updated.emit()

func add_gold(amount: int):
	gold += amount
	if gold >= 1000:
		await unlock_achievement("Rich Adventurer", "Accumulated 1000 gold")
	stats_updated.emit()

func take_damage(amount: int):
	health = max(0, health - amount)
	stats_updated.emit()

func heal(amount: int):
	health = min(max_health, health + amount)
	stats_updated.emit()

func use_mana(amount: int) -> bool:
	if mana >= amount:
		mana -= amount
		stats_updated.emit()
		return true
	return false

func restore_mana(amount: int):
	mana = min(max_mana, mana + amount)
	stats_updated.emit()

func reset_game():
	character_id = -1
	character_name = ""
	character_class = ""
	level = 1
	experience = 0
	health = 100
	max_health = 100
	mana = 50
	max_mana = 50
	strength = 10
	intelligence = 10
	agility = 10
	gold = 0
	inventory = []
	skills = []
	active_quests = []
	achievements = []
	score = 0
	battles_won = 0
	total_enemies_defeated = 0

# ============================================
# HTTP REQUEST HELPER
# ============================================

func _api_request(method: String, endpoint: String, body: Dictionary = {}) -> Dictionary:
	var http = HTTPRequest.new()
	add_child(http)
	
	var url = API_URL + endpoint
	var headers = ["Content-Type: application/json"]
	var body_string = JSON.stringify(body) if body.size() > 0 else ""
	
	var http_method = HTTPClient.METHOD_GET
	match method:
		"POST": http_method = HTTPClient.METHOD_POST
		"PUT": http_method = HTTPClient.METHOD_PUT
		"DELETE": http_method = HTTPClient.METHOD_DELETE
	
	var error = http.request(url, headers, http_method, body_string)
	
	if error != OK:
		http.queue_free()
		return {"success": false, "error": "Request failed"}
	
	var response = await http.request_completed
	http.queue_free()
	
	var result = response[0]
	var response_code = response[1]
	var response_body = response[3]
	
	if result != HTTPRequest.RESULT_SUCCESS:
		return {"success": false, "error": "Connection failed"}
	
	if response_code >= 200 and response_code < 300:
		var json = JSON.new()
		var parse_result = json.parse(response_body.get_string_from_utf8())
		if parse_result == OK:
			return {"success": true, "data": json.data}
		else:
			return {"success": true, "data": null}
	else:
		return {"success": false, "error": "HTTP " + str(response_code)}