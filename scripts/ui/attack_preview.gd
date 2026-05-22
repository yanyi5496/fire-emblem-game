extends Panel

class_name AttackPreview

signal attack_confirmed()
signal attack_cancelled()

@onready var attacker_label: Label = $VBoxContainer/AttackerLabel
@onready var defender_label: Label = $VBoxContainer/DefenderLabel
@onready var hit_rate_label: Label = $VBoxContainer/HitRateLabel
@onready var damage_label: Label = $VBoxContainer/DamageLabel
@onready var counter_label: Label = $VBoxContainer/CounterLabel
@onready var follow_up_label: Label = $VBoxContainer/FollowUpLabel

func show_result(result: Dictionary) -> void:
	attacker_label.text = result.get("attacker_id", "???")
	defender_label.text = result.get("defender_id", "???")
	hit_rate_label.text = "命中 %d%%" % result.get("hit_rate", 0)
	damage_label.text = "伤害 %d" % result.get("damage", 0)
	counter_label.text = "反击: 命中 %d%%  伤害 %d" % [result.get("counter_hit_rate", 0), result.get("counter_damage", 0)]
	follow_up_label.text = "追击: %s" % ("有" if result.get("did_follow_up", false) else "无")
	show()

func _on_confirm_pressed() -> void:
	attack_confirmed.emit()

func _on_cancel_pressed() -> void:
	attack_cancelled.emit()
