extends Panel

class_name ActionMenu

signal move_selected()
signal attack_selected()
signal skill_selected()
signal wait_selected()
signal switch_weapon_selected()

func show_for_view_model(vm: Dictionary) -> void:
	$VBoxContainer/MoveButton.visible = vm.get("can_move", false)
	$VBoxContainer/AttackButton.visible = vm.get("can_act", false)
	$VBoxContainer/SkillButton.visible = vm.get("can_act", false) and vm.get("has_ready_skill", false)
	$VBoxContainer/WaitButton.visible = true
	$VBoxContainer/SwitchWeaponButton.visible = vm.get("can_act", false) and vm.get("weapon_count", 0) > 1
	show()

func show_for_unit(unit) -> void:
	var vm := {
		"can_move": unit.can_move(),
		"can_act": unit.can_act(),
		"has_ready_skill": false,
		"weapon_count": unit.runtime_state.inventory.size() if unit.runtime_state else 0,
	}
	if unit.runtime_state:
		for skill_id in unit.runtime_state.skills:
			var skill_data: Dictionary = DataManager.get_skill(skill_id)
			if skill_data.get("type", "") == "active" and unit.runtime_state.can_use_skill(skill_id):
				vm["has_ready_skill"] = true
				break
	show_for_view_model(vm)

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