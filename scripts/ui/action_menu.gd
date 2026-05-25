extends Panel

class_name ActionMenu

const _unit_actor_dep := preload("res://scripts/unit/unit_actor.gd")

signal move_selected()
signal attack_selected()
signal skill_selected()
signal wait_selected()
signal switch_weapon_selected()

func show_for_unit(unit) -> void:
	var can_move: bool = unit.can_move()
	var can_act: bool = unit.can_act()
	$VBoxContainer/MoveButton.visible = can_move
	$VBoxContainer/AttackButton.visible = can_act
	var has_ready_skill := false
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("type", "") == "active" and unit.runtime_state.can_use_skill(skill_id):
			has_ready_skill = true
			break
	$VBoxContainer/SkillButton.visible = can_act and has_ready_skill
	$VBoxContainer/WaitButton.visible = true
	$VBoxContainer/SwitchWeaponButton.visible = can_act and unit.runtime_state.inventory.size() > 1
	show()

func _on_move_pressed() -> void:
	move_selected.emit()

func _on_attack_pressed() -> void:
	attack_selected.emit()

func _on_skill_pressed() -> void:
	skill_selected.emit()

func _on_wait_pressed() -> void:
	wait_selected.emit()

func _on_switch_weapon_pressed() -> void:
	switch_weapon_selected.emit()
