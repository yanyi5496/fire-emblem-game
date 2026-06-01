extends Panel

class_name AttackPreview

signal attack_confirmed()
signal attack_cancelled()

@onready var attacker_label: Label = $VBoxContainer/AttackerLabel
@onready var defender_label: Label = $VBoxContainer/DefenderLabel
@onready var weapon_label: Label = $VBoxContainer/WeaponLabel
@onready var hit_rate_label: Label = $VBoxContainer/HitRateLabel
@onready var damage_label: Label = $VBoxContainer/DamageLabel
@onready var crit_label: Label = $VBoxContainer/CritLabel
@onready var counter_label: Label = $VBoxContainer/CounterLabel
@onready var follow_up_label: Label = $VBoxContainer/FollowUpLabel
@onready var advantage_label: Label = $VBoxContainer/AdvantageLabel

var _result_cache: Dictionary = {}

func show_result(result: Dictionary) -> void:
	_result_cache = result
	var attacker: Node = result.get("attacker_ref") as Node
	var defender: Node = result.get("defender_ref") as Node
	attacker_label.text = "攻击: %s" % _unit_display_name(attacker, result.get("attacker_id", "???"))
	defender_label.text = "防守: %s" % _unit_display_name(defender, result.get("defender_id", "???"))
	if attacker and attacker.runtime_state:
		attacker_label.text += "  HP %d/%d" % [attacker.get_current_hp(), attacker.get_max_hp()]
	if defender and defender.runtime_state:
		defender_label.text += "  HP %d/%d" % [defender.get_current_hp(), defender.get_max_hp()]
	var weapon_id: String = result.get("weapon_id", "")
	var wp_data: Dictionary = DataManager.get_weapon(weapon_id) if weapon_id != "" else {}
	var wp_name: String = str(wp_data.get("name", weapon_id)) if not wp_data.is_empty() else "无"
	var wp_dur: String = ""
	if attacker and attacker.runtime_state and weapon_id != "":
		wp_dur = " (%d)" % attacker.runtime_state.get_weapon_durability(weapon_id)
	weapon_label.text = "武器: %s%s" % [wp_name, wp_dur]
	var triangle_adv: bool = result.get("triangle_advantage", false)
	var tri_hit: int = result.get("triangle_hit_bonus", 0)
	if triangle_adv:
		advantage_label.text = "▲ 克制 (命中+%d 伤害+%d)" % [tri_hit, result.get("triangle_dmg_bonus", 0)]
		advantage_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	elif tri_hit < 0:
		advantage_label.text = "▼ 被克制 (命中%d 伤害%d)" % [tri_hit, result.get("triangle_dmg_bonus", 0)]
		advantage_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	else:
		advantage_label.text = ""
	var hit_rate: int = result.get("hit_rate", 0)
	var hit_color := _hit_color(hit_rate)
	hit_rate_label.text = "命中 %d%%" % hit_rate
	hit_rate_label.add_theme_color_override("font_color", hit_color)
	damage_label.text = "伤害 %d" % result.get("damage", 0)
	var crit: int = result.get("crit_rate", 0)
	crit_label.text = "暴击 %d%%" % crit
	var counter_hit: int = result.get("counter_hit_rate", 0)
	var counter_color := _hit_color(counter_hit)
	counter_label.text = "反击: 命中 %d%%  伤害 %d" % [counter_hit, result.get("counter_damage", 0)]
	counter_label.add_theme_color_override("font_color", counter_color)
	follow_up_label.text = "追击: %s" % ("有" if result.get("did_follow_up", false) else "无")
	show()

func _unit_display_name(unit: Node, fallback: String) -> String:
	if unit and unit.runtime_state:
		return unit.runtime_state.unit_name
	var data: Dictionary = DataManager.get_unit(fallback)
	if not data.is_empty():
		return str(data.get("name", fallback))
	return fallback

func _hit_color(rate: int) -> Color:
	if rate >= 80:
		return Color(0.3, 1.0, 0.3)
	elif rate >= 50:
		return Color(1.0, 0.9, 0.3)
	else:
		return Color(1.0, 0.3, 0.3)

func _on_confirm_pressed() -> void:
	attack_confirmed.emit()

func _on_cancel_pressed() -> void:
	attack_cancelled.emit()