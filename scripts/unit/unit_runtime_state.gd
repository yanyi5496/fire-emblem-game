extends Node

class_name UnitRuntimeState

enum ActionState { IDLE, MOVED, ACTED, DEAD }

var template_id: String = ""
var unit_name: String = ""
var job_id: String = ""

var max_hp: int = 0
var current_hp: int = 0
var max_mp: int = 0
var current_mp: int = 0

var str_stat: int = 0
var mag_stat: int = 0
var skl_stat: int = 0
var spd_stat: int = 0
var def_stat: int = 0
var res_stat: int = 0
var luk_stat: int = 0
var mov_stat: int = 5

var level: int = 1
var exp: int = 0
var pending_level_ups: Array[Dictionary] = []

var action_state: ActionState = ActionState.IDLE
var status_effects: Array[Dictionary] = []
var ai_type: String = "aggressive"
var tags: Array[String] = []
var equipped_weapon: String = ""
var inventory: Array[String] = []
var skills: Array[String] = []
var skill_cooldowns: Dictionary = {}
var weapon_durability: Dictionary = {}

func get_weapon_durability(weapon_id: String) -> int:
	if weapon_durability.has(weapon_id):
		return int(weapon_durability.get(weapon_id, 0))
	var data: Dictionary = DataManager.get_weapon(weapon_id)
	var dur: int = int(data.get("durability", 0))
	weapon_durability[weapon_id] = dur
	return dur

func consume_weapon_durability(weapon_id: String) -> void:
	var dur: int = get_weapon_durability(weapon_id)
	dur -= 1
	if dur <= 0:
		weapon_durability.erase(weapon_id)
	else:
		weapon_durability[weapon_id] = dur

func is_weapon_broken(weapon_id: String) -> bool:
	if weapon_id == "":
		return true
	return get_weapon_durability(weapon_id) <= 0

func can_use_skill(skill_id: String) -> bool:
	for e in status_effects:
		if e.get("id", "") == "silence" and e.get("duration", 0) > 0:
			return false
	if not skill_cooldowns.has(skill_id):
		return true
	return int(skill_cooldowns.get(skill_id, 0)) <= 0

func trigger_skill_cooldown(skill_id: String) -> void:
	var skill_data: Dictionary = DataManager.get_skill(skill_id)
	skill_cooldowns[skill_id] = int(skill_data.get("cooldown", 0))

func setup_from_template(template_id: String) -> void:
	var data: Dictionary = DataManager.get_unit(template_id)
	if data.is_empty():
		push_error("Unit template not found: %s" % template_id)
		return
	self.template_id = template_id
	unit_name = data.get("name", "")
	job_id = data.get("job", "")
	level = data.get("level", 1)
	exp = data.get("exp", 0)

	var stats: Dictionary = data.get("stats", {})
	max_hp = stats.get("hp", 1)
	current_hp = max_hp
	max_mp = stats.get("mp", 0)
	current_mp = max_mp
	str_stat = stats.get("str", 0)
	mag_stat = stats.get("mag", 0)
	skl_stat = stats.get("skl", 0)
	spd_stat = stats.get("spd", 0)
	def_stat = stats.get("def", 0)
	res_stat = stats.get("res", 0)
	luk_stat = stats.get("luk", 0)
	mov_stat = stats.get("mov", 5)

	inventory = _to_typed_string_array(data.get("inventory", []))
	skills = _to_typed_string_array(data.get("skills", []))
	tags = _to_typed_string_array(data.get("tags", []))
	skill_cooldowns.clear()
	for skill_id in skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("type", "") == "active":
			skill_cooldowns[skill_id] = 0
	if not inventory.is_empty():
		equipped_weapon = inventory[0]
		get_weapon_durability(equipped_weapon)

func get_growth_rates() -> Dictionary:
	var data: Dictionary = DataManager.get_unit(template_id)
	var rates: Dictionary = data.get("growth_rates", {}).duplicate()
	var job_data: Dictionary = DataManager.get_job(job_id)
	var bonus: Dictionary = job_data.get("growth_bonus", {})
	for stat_name in rates:
		rates[stat_name] = int(rates[stat_name]) + int(bonus.get(stat_name, 0))
	return rates

func gain_exp(amount: int) -> Array[Dictionary]:
	exp += amount
	var levels: Array[Dictionary] = []
	while exp >= 80:
		exp -= 80
		level += 1
		var gained: Dictionary = _roll_stats()
		levels.append(gained)
		current_hp = max_hp
	return levels

func _roll_stats() -> Dictionary:
	var gained: Dictionary = {}
	var rates: Dictionary = get_growth_rates()
	for stat_name in ["hp", "mp", "str", "mag", "skl", "spd", "def", "res", "luk"]:
		var rate: int = int(rates.get(stat_name, 0))
		if randi() % 100 < rate:
			_apply_stat_growth(stat_name, 1)
			gained[stat_name] = gained.get(stat_name, 0) + 1
	pending_level_ups.append(gained)
	return gained

func _apply_stat_growth(stat_name: String, amount: int) -> void:
	match stat_name:
		"hp": max_hp += amount; current_hp = min(current_hp + amount, max_hp)
		"mp": max_mp += amount; current_mp = min(current_mp + amount, max_mp)
		"str": str_stat = min(30, str_stat + amount)
		"mag": mag_stat = min(30, mag_stat + amount)
		"skl": skl_stat = min(30, skl_stat + amount)
		"spd": spd_stat = min(30, spd_stat + amount)
		"def": def_stat = min(30, def_stat + amount)
		"res": res_stat = min(30, res_stat + amount)
		"luk": luk_stat = min(30, luk_stat + amount)

func promote_to(new_job_id: String) -> void:
	var new_job: Dictionary = DataManager.get_job(new_job_id)
	if new_job.is_empty():
		push_error("Promotion target job not found: %s" % new_job_id)
		return
	job_id = new_job_id
	var new_weapons: Array = new_job.get("weapons", [])
	for wid in new_weapons:
		if str(wid) not in inventory:
			inventory.append(str(wid))
	if equipped_weapon == "" and not inventory.is_empty():
		equipped_weapon = inventory[0]
	var new_skills: Array = new_job.get("skills", [])
	for sid in new_skills:
		var sid_str: String = str(sid)
		if sid_str not in skills:
			skills.append(sid_str)
			var skill_data: Dictionary = DataManager.get_skill(sid_str)
			if skill_data.get("type", "") == "active":
				skill_cooldowns[sid_str] = 0

func get_stats() -> Dictionary:
	return {
		"hp": current_hp, "max_hp": max_hp,
		"mp": current_mp, "max_mp": max_mp,
		"str": str_stat, "mag": mag_stat, "skl": skl_stat,
		"spd": spd_stat, "def": def_stat, "res": res_stat,
		"luk": luk_stat, "mov": mov_stat,
	}

static func _to_typed_string_array(arr) -> Array[String]:
	var result: Array[String] = []
	for item in arr:
		result.append(str(item))
	return result

func apply_saved_state(data: Dictionary) -> void:
	current_hp = int(data.get("current_hp", current_hp))
	current_mp = int(data.get("current_mp", current_mp))
	level = int(data.get("level", level))
	exp = int(data.get("exp", exp))
	inventory = _to_typed_string_array(data.get("inventory", []))
	skills = _to_typed_string_array(data.get("skills", []))
	var raw_effects: Array = data.get("status_effects", []) as Array
	var typed_effects: Array[Dictionary] = []
	for e in raw_effects:
		typed_effects.append(e as Dictionary)
	status_effects = typed_effects
	skill_cooldowns = data.get("skill_cooldowns", skill_cooldowns).duplicate(true)
	equipped_weapon = str(data.get("equipped_weapon", equipped_weapon))
	action_state = int(data.get("action_state", action_state))
	var raw_durability: Dictionary = data.get("weapon_durability", {})
	weapon_durability.clear()
	for key in raw_durability:
		weapon_durability[str(key)] = int(raw_durability[key])
	if equipped_weapon != "" and not weapon_durability.has(equipped_weapon):
		get_weapon_durability(equipped_weapon)
	var stats: Dictionary = data.get("stats", {})
	max_hp = int(stats.get("max_hp", max_hp))
	max_mp = int(stats.get("max_mp", max_mp))
	str_stat = int(stats.get("str", str_stat))
	mag_stat = int(stats.get("mag", mag_stat))
	skl_stat = int(stats.get("skl", skl_stat))
	spd_stat = int(stats.get("spd", spd_stat))
	def_stat = int(stats.get("def", def_stat))
	res_stat = int(stats.get("res", res_stat))
	luk_stat = int(stats.get("luk", luk_stat))
	mov_stat = int(stats.get("mov", mov_stat))
	current_hp = min(current_hp, max_hp)
	current_mp = min(current_mp, max_mp)
