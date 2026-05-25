extends RefCounted

class_name TestVictoryJudgeIntegration

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var judge = preload("res://scripts/battle/victory_judge.gd").new()

	judge.setup({"victory_condition": "rout", "defeat_condition": "all_dead", "max_turns": 20})
	if judge.check_victory(true, true, 1) == "":
		details.append("PASS: rout - both alive no result")
	else:
		details.append("FAIL: rout both alive should be empty")
		all_pass = false
	if judge.check_victory(false, true, 1) == "victory":
		details.append("PASS: rout - all enemies dead = victory")
	else:
		details.append("FAIL: rout no enemies should be victory")
		all_pass = false
	if judge.check_victory(true, false, 5) == "defeat":
		details.append("PASS: rout - player all dead = defeat")
	else:
		details.append("FAIL: rout no player should be defeat")
		all_pass = false
	if judge.check_victory(true, true, 21) == "defeat":
		details.append("PASS: rout - turn limit exceeded = defeat")
	else:
		details.append("FAIL: rout turn limit should cause defeat")
		all_pass = false

	judge.setup({"victory_condition": "survive", "defeat_condition": "turn_limit", "max_turns": 8})
	if judge.check_victory(false, true, 1) == "":
		details.append("PASS: survive - enemies dead but no turn limit = no result")
	else:
		details.append("FAIL: survive with enemies dead should not trigger victory early")
		all_pass = false
	if judge.check_victory(true, true, 9) == "victory":
		details.append("PASS: survive - survived past max_turns = victory")
	else:
		details.append("FAIL: survive past max_turns should be victory")
		all_pass = false
	if judge.check_victory(true, false, 3) == "defeat":
		details.append("PASS: survive - player dead before limit = defeat")
	else:
		details.append("FAIL: survive with player dead should be defeat")
		all_pass = false
	if judge.check_victory(true, true, 8) == "":
		details.append("PASS: survive - exactly at max_turns still ongoing")
	else:
		details.append("FAIL: survive at max_turns should be ongoing (= not > max)")
		all_pass = false

	judge.setup({"victory_condition": "defend", "defeat_condition": "lord_dead", "max_turns": 10})
	if judge.check_victory(true, true, 11) == "victory":
		details.append("PASS: defend - survived past max_turns = victory")
	else:
		details.append("FAIL: defend past max_turns should be victory")
		all_pass = false
	if judge.check_victory(false, true, 1) == "":
		details.append("PASS: defend - enemy dead but still ongoing (must wait for turn limit)")
	else:
		details.append("FAIL: defend should not end early from enemy death")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Victory judge integration %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
