extends Panel

class_name AttackPreview

signal attack_confirmed()
signal attack_cancelled()

@onready var attacker_label: Label = $VBoxContainer/AttackerLabel
@onready var defender_label: Label = $VBoxContainer/DefenderLabel
@onready var hit_rate_label: Label = $VBoxContainer/HitRateLabel
@onready var damage_label: Label = $VBoxContainer/DamageLabel
@onready var crit_label: Label = $VBoxContainer/CritLabel
@onready var counter_label: Label = $VBoxContainer/CounterLabel
@onready var follow_up_label: Label = $VBoxContainer/FollowUpLabel

func show_result(result: Dictionary) -> void:
	attacker_label.text = result.get("attacker_id", "???")
	defender_label.text = result.get("defender_id", "???")
	
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
