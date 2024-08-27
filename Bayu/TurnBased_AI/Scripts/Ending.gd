class_name Ending
extends FinalLevel

func _on_interactables_enter_gameplay():
	new_target = player.get_child(0)
	$GameBoard/Enemy/Tank.last_direction = Vector2(1,0)
	$GameBoard/Enemy/Tank.fsm.change_state($GameBoard/Enemy/Tank.mallaby_attack_state)
	await $GameBoard/Enemy/Tank.lock_unit
	var e = explosive.instantiate()
	add_child(e)
	e.position = new_target.position
	await get_tree().create_timer(0.5).timeout
	active_unit.visible = false
	$GameOver.visible = true
	$GameOver/AnimationPlayer.play("ending")
