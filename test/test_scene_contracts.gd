extends RefCounted

class_name TestSceneContracts

const CLASS_TO_SCRIPT := {
	"BootController": "res://scripts/boot/boot_controller.gd",
	"MainMenu": "res://scripts/menu/main_menu.gd",
	"StoryPlayer": "res://scripts/story/story_player.gd",
	"BattleController": "res://scripts/battle/battle_controller.gd",
	"TurnManager": "res://scripts/battle/turn_manager.gd",
	"BattleHUD": "res://scripts/ui/battle_hud.gd",
	"ActionMenu": "res://scripts/ui/action_menu.gd",
	"AttackPreview": "res://scripts/ui/attack_preview.gd",
}

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

func _check_class(cls_name: String, expected_methods: Array) -> bool:
	var script_path := CLASS_TO_SCRIPT.get(cls_name, "")
	if script_path.is_empty():
		return false
	var script := load(script_path) as GDScript
	if not script:
		return false
	var method_list: Array[Dictionary] = script.get_script_method_list()
	var method_names: Array[String] = []
	for m in method_list:
		method_names.append(m.get("name", ""))
	for method in expected_methods:
		if not method in method_names:
			return false
	return true
