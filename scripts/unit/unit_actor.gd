extends Node2D

class_name UnitActor

const _urs_dep := preload("res://scripts/unit/unit_runtime_state.gd")

signal moved(new_pos: Vector2i)
signal attacked(target: Node)
signal damaged(amount: int)
signal healed(amount: int)
signal died()
signal action_state_changed(new_state: String)

@export var unit_id: String = ""
@export var team: String = "player"

var runtime_state
var grid_pos: Vector2i
var _is_alive: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_animation(anim_name: String) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func is_alive() -> bool:
	return _is_alive and runtime_state != null and runtime_state.action_state != _urs_dep.ActionState.DEAD

func get_current_hp() -> int:
	return runtime_state.current_hp if runtime_state else 0

func get_max_hp() -> int:
	return runtime_state.max_hp if runtime_state else 0

func setup(id: String, unit_team: String, pos: Vector2i) -> void:
	unit_id = id
	team = unit_team
	grid_pos = pos
	position = Vector2(pos.x * 64, pos.y * 64)
	runtime_state = _urs_dep.new()
	runtime_state.setup_from_template(id)
	add_child(runtime_state)
	add_to_group("units")

func reset_action_state() -> void:
	if runtime_state:
		runtime_state.action_state = _urs_dep.ActionState.IDLE

func can_move() -> bool:
	return runtime_state and runtime_state.action_state == _urs_dep.ActionState.IDLE

func can_act() -> bool:
	return runtime_state and runtime_state.action_state in [_urs_dep.ActionState.IDLE, _urs_dep.ActionState.MOVED]

func attack(target: Node) -> void:
	if runtime_state:
		runtime_state.action_state = _urs_dep.ActionState.ACTED
	attacked.emit(target)

func wait() -> void:
	if runtime_state:
		runtime_state.action_state = _urs_dep.ActionState.ACTED

func take_damage(amount: int) -> void:
	if not runtime_state:
		return
	runtime_state.current_hp = max(0, runtime_state.current_hp - amount)
	damaged.emit(amount)
	if runtime_state.current_hp <= 0:
		die()

func heal(amount: int) -> void:
	if not runtime_state:
		return
	var old: int = runtime_state.current_hp
	runtime_state.current_hp = min(runtime_state.max_hp, runtime_state.current_hp + amount)
	healed.emit(runtime_state.current_hp - old)

func die() -> void:
	_is_alive = false
	runtime_state.action_state = _urs_dep.ActionState.DEAD
	died.emit()

func to_save_dict() -> Dictionary:
	return {
		"unit_id": unit_id,
		"team": team,
		"x": grid_pos.x,
		"y": grid_pos.y,
		"is_alive": is_alive(),
		"current_hp": runtime_state.current_hp if runtime_state else 0,
		"current_mp": runtime_state.current_mp if runtime_state else 0,
		"level": runtime_state.level if runtime_state else 1,
		"exp": runtime_state.exp if runtime_state else 0,
		"action_state": int(runtime_state.action_state) if runtime_state else 0,
		"equipped_weapon": runtime_state.equipped_weapon if runtime_state else "",
		"inventory": runtime_state.inventory.duplicate() if runtime_state else [],
		"skills": runtime_state.skills.duplicate() if runtime_state else [],
		"status_effects": runtime_state.status_effects.duplicate(true) if runtime_state else [],
		"skill_cooldowns": runtime_state.skill_cooldowns.duplicate(true) if runtime_state else {},
		"weapon_durability": runtime_state.weapon_durability.duplicate(true) if runtime_state else {},
		"stats": runtime_state.get_stats() if runtime_state else {},
	}

func apply_saved_state(data: Dictionary) -> void:
	grid_pos = Vector2i(int(data.get("x", grid_pos.x)), int(data.get("y", grid_pos.y)))
	position = Vector2(grid_pos.x * 64, grid_pos.y * 64)
	if runtime_state:
		runtime_state.apply_saved_state(data)
	_is_alive = bool(data.get("is_alive", true))
	if not _is_alive and runtime_state:
		runtime_state.current_hp = 0
		runtime_state.action_state = _urs_dep.ActionState.DEAD
