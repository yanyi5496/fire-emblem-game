extends RefCounted

class_name TestSceneContracts

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	details.append("INFO: Verifying scene contract: BootController")
	var boot_check := _check_class("BootController", ["_ready"])
	if not boot_check:
		details.append("FAIL: BootController missing expected methods")
		all_pass = false

	details.append("INFO: Verifying scene contract: MainMenu")
	var menu_check := _check_class("MainMenu", ["_ready", "_on_new_game_pressed", "_on_continue_pressed", "_on_settings_pressed", "_on_quit_pressed"])
	if not menu_check:
		details.append("FAIL: MainMenu missing expected methods")
		all_pass = false

	details.append("INFO: Verifying scene contract: StoryPlayer")
	var story_check := _check_class("StoryPlayer", ["_ready", "play_story", "_advance", "_handle_event", "_finish"])
	if not story_check:
		details.append("FAIL: StoryPlayer missing expected methods")
		all_pass = false

	details.append("INFO: Verifying scene contract: BattleController")
	var bc_check := _check_class("BattleController", ["_ready", "start_battle", "check_victory_condition", "end_battle"])
	if not bc_check:
		details.append("FAIL: BattleController missing expected methods")
		all_pass = false

	details.append("INFO: Verifying scene contract: TurnManager")
	var tm_check := _check_class("TurnManager", ["initialize_battle", "start_turn", "end_turn"])
	if not tm_check:
		details.append("FAIL: TurnManager missing expected methods")
		all_pass = false

	details.append("INFO: Verifying scene contract: BattleHUD")
	var hud_check := _check_class("BattleHUD", ["update_turn_info", "show_unit_info", "show_action_menu", "hide_action_menu", "show_attack_preview", "hide_attack_preview"])
	if not hud_check:
		details.append("FAIL: BattleHUD missing expected methods")
		all_pass = false

	details.append("INFO: Verifying scene contract: ActionMenu")
	var am_check := _check_class("ActionMenu", ["show_for_unit", "_on_move_pressed", "_on_attack_pressed", "_on_wait_pressed"])
	if not am_check:
		details.append("FAIL: ActionMenu missing expected methods")
		all_pass = false

	details.append("INFO: Verifying scene contract: AttackPreview")
	var ap_check := _check_class("AttackPreview", ["show_result", "_on_confirm_pressed", "_on_cancel_pressed"])
	if not ap_check:
		details.append("FAIL: AttackPreview missing expected methods")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Scene contract verification %s" % ["passed" if all_pass else "failed"],
		"details": details
	}

func _check_class(class_name: String, expected_methods: Array[String]) -> bool:
	if not ClassDB.class_exists(class_name):
		return false
	for method in expected_methods:
		if not ClassDB.has_method(class_name, method, false):
			return false
	return true
