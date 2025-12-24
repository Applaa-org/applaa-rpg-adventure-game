extends CharacterBody2D

const SPEED: float = 200.0

func _physics_process(delta: float):
	# Get input direction
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemy"):
		# Start battle
		var enemy_label = area.get_node_or_null("Label")
		var enemy_name = enemy_label.text if enemy_label else "Enemy"
		get_parent().start_battle(enemy_name)
	elif area.is_in_group("goal"):
		# Complete quest
		complete_current_quest()

func complete_current_quest():
	if Global.active_quests.size() > 0:
		var quest = Global.active_quests[0]
		await Global.complete_quest(quest.id)
		get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")