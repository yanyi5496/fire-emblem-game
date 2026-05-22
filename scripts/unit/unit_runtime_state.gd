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

var action_state: ActionState = ActionState.IDLE
var status_effects: Array[Dictionary] = []
var equipped_weapon: String = ""
var inventory: Array[String] = []
var skills: Array[String] = []

func setup_from_template(template_id: String) -> void:
	var data := DataManager.get_unit(template_id)
	if data.is_empty():
		push_error("Unit template not found: %s" % template_id)
		return
	self.template_id = template_id
	unit_name = data.get("name", "")
	job_id = data.get("job", "")
	level = data.get("level", 1)
	exp = data.get("exp", 0)

	var stats := data.get("stats", {})
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

	inventory = data.get("inventory", []).duplicate()
	skills = data.get("skills", []).duplicate()
	if not inventory.is_empty():
		equipped_weapon = inventory[0]

func get_stats() -> Dictionary:
	return {
		"hp": current_hp, "max_hp": max_hp,
		"mp": current_mp, "max_mp": max_mp,
		"str": str_stat, "mag": mag_stat, "skl": skl_stat,
		"spd": spd_stat, "def": def_stat, "res": res_stat,
		"luk": luk_stat, "mov": mov_stat,
	}
