extends RefCounted

class_name CombatExecService

signal level_up_notification(unit_id: String, stats: Dictionary)

var _units_container: Node2D = null
var _hit_effect: PackedScene = null
var _crit_effect: PackedScene = null
var _skill_effect: PackedScene = null

func initialize(units_container: Node2D, hit_effect: PackedScene, crit_effect: PackedScene, skill_effect: PackedScene) -> void:
	_units_container = units_container
	_hit_effect = hit_effect
	_crit_effect = crit_effect
	_skill_effect = skill_effect

func play_combat_effects(attacker: Node, defender: Node, result: Dictionary) -> void:
	attacker.play_animation("attack")
	if result.get("did_crit", false):
		_spawn_effect(_crit_effect, defender.global_position)
	elif result.get("did_hit", false):
		_spawn_effect(_hit_effect, defender.global_position)
	if not defender.is_alive():
		defender.play_animation("death")
	if result.get("did_counter", false):
		defender.play_animation("attack")
		_spawn_effect(_hit_effect, attacker.global_position)

func distribute_combat_exp(attacker: Node, defender: Node) -> void:
	if not attacker.runtime_state or not defender.runtime_state:
		return
	var def_level: int = defender.runtime_state.level
	var exp_gain: int = def_level * 10 + 20
	if not defender.is_alive():
		exp_gain += 20
	attacker.runtime_state.gain_exp(exp_gain)

func distribute_victory_exp() -> void:
	if not _units_container:
		return
	for unit in _units_container.get_children():
		if unit.is_alive() and unit.team == "player" and unit.runtime_state:
			unit.runtime_state.gain_exp(5)

func process_level_ups() -> void:
	if not _units_container:
		return
	for unit in _units_container.get_children():
		if unit.runtime_state:
			var pending: Array[Dictionary] = unit.runtime_state.pending_level_ups
			if not pending.is_empty():
				unit.runtime_state.pending_level_ups = []
				for lvl_up in pending:
					level_up_notification.emit(unit.unit_id, lvl_up)

func execute_attack(selected_unit: Node, pending_target: Node, weapon_id: String, combat_manager, skill_service, battle_hud: Node) -> void:
	if not selected_unit or not pending_target:
		return
	skill_service.apply_unit_passives(selected_unit, "before_combat")
	skill_service.apply_unit_passives(pending_target, "before_combat")
	selected_unit.attack(pending_target)
	combat_manager.execute(selected_unit, pending_target, weapon_id, skill_service)
	distribute_combat_exp(selected_unit, pending_target)
	skill_service.apply_unit_passives(selected_unit, "after_combat")
	skill_service.apply_unit_passives(pending_target, "after_combat")
	skill_service.clear_temporary_passives(selected_unit)
	skill_service.clear_temporary_passives(pending_target)
	if battle_hud and battle_hud.has_method("hide_attack_preview"):
		battle_hud.hide_attack_preview()
	process_level_ups()

func _spawn_effect(effect_scene: PackedScene, pos: Vector2) -> void:
	if not effect_scene or not _units_container:
		return
	var instance := effect_scene.instantiate()
	instance.global_position = pos
	_units_container.add_child(instance)
	if instance.has_method("play"):
		instance.play()
	if instance.has_signal("animation_finished"):
		instance.animation_finished.connect(instance.queue_free, CONNECT_ONE_SHOT)
	else:
		_units_container.get_tree().create_timer(1.5).timeout.connect(instance.queue_free)