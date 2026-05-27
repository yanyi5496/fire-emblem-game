extends RefCounted

class_name TestWeaponJobMatch

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	DataManager.load_all()

	var urs_script := preload("res://scripts/unit/unit_runtime_state.gd")
	var runtime := urs_script.new()

	runtime.job_id = "swordman"
	if runtime.can_equip_weapon_type("sword"):
		details.append("PASS: swordman can equip sword")
	else:
		details.append("FAIL: swordman should be able to equip sword")
		all_pass = false

	if not runtime.can_equip_weapon_type("axe"):
		details.append("PASS: swordman cannot equip axe")
	else:
		details.append("FAIL: swordman should not be able to equip axe")
		all_pass = false

	if not runtime.can_equip_weapon_type("lance"):
		details.append("PASS: swordman cannot equip lance")
	else:
		details.append("FAIL: swordman should not be able to equip lance")
		all_pass = false

	runtime.job_id = "priest"
	if runtime.can_equip_weapon_type("staff"):
		details.append("PASS: priest can equip staff")
	else:
		details.append("FAIL: priest should be able to equip staff")
		all_pass = false

	if not runtime.can_equip_weapon_type("magic"):
		details.append("PASS: priest cannot equip magic (not in job weapons)")
	else:
		details.append("FAIL: priest should not be able to equip magic")
		all_pass = false

	runtime.job_id = "axefighter"
	if runtime.can_equip_weapon_type("axe"):
		details.append("PASS: axefighter can equip axe")
	else:
		details.append("FAIL: axefighter should be able to equip axe")
		all_pass = false

	runtime.job_id = ""
	if runtime.can_equip_weapon_type("sword"):
		details.append("PASS: empty job_id allows any weapon type")
	else:
		details.append("FAIL: empty job_id should allow any weapon")
		all_pass = false

	if not runtime.can_equip_weapon_type(""):
		details.append("FAIL: empty weapon type should pass")
		all_pass = false
	else:
		details.append("PASS: empty weapon type passes check")

	return {
		"passed": all_pass,
		"message": "Weapon-job match %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
