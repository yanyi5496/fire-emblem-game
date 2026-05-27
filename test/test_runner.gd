extends Node

class_name TestRunner

const TEST_CLASSES := [
	preload("res://test/test_data_schema.gd"),
	preload("res://test/test_game_state_flow.gd"),
	preload("res://test/test_scripts_load.gd"),
	preload("res://test/test_resources_load.gd"),
	preload("res://test/test_combat_formula.gd"),
	preload("res://test/test_pathfinding_service.gd"),
	preload("res://test/test_scenes_load.gd"),
	preload("res://test/test_scene_contracts.gd"),
	preload("res://test/test_turn_resolution.gd"),
	preload("res://test/test_status_effects.gd"),
	preload("res://test/test_unit_runtime.gd"),
	preload("res://test/test_story_parser.gd"),
	preload("res://test/test_save_load_flow.gd"),
	preload("res://test/test_ai_behavior.gd"),
	preload("res://test/test_battle_skill_service.gd"),
	preload("res://test/test_battle_lifecycle_service.gd"),
	preload("res://test/test_victory_judge_integration.gd"),
	preload("res://test/test_chapter_flow.gd"),
	preload("res://test/test_main_flow_integration.gd"),
	preload("res://test/test_walk_animation.gd"),
	preload("res://test/test_skill_mp_cost.gd"),
	preload("res://test/test_weapon_job_match.gd"),
]
const TEST_NAMES := [
	"test_data_schema",
	"test_game_state_flow",
	"test_scripts_load",
	"test_resources_load",
	"test_combat_formula",
	"test_pathfinding_service",
	"test_scenes_load",
	"test_scene_contracts",
	"test_turn_resolution",
	"test_status_effects",
	"test_unit_runtime",
	"test_story_parser",
	"test_save_load_flow",
	"test_ai_behavior",
	"test_battle_skill_service",
	"test_battle_lifecycle_service",
	"test_victory_judge_integration",
	"test_chapter_flow",
	"test_main_flow_integration",
	"test_walk_animation",
	"test_skill_mp_cost",
	"test_weapon_job_match",
]

var _results: Array[Dictionary] = []
var _passed: int = 0
var _failed: int = 0

func _ready() -> void:
	run_all()
	get_tree().quit()

func run_all() -> void:
	print("========================================")
	print("  Project Ember - MVP Test Suite")
	print("========================================")
	for i in TEST_CLASSES.size():
		_run_test(TEST_CLASSES[i], TEST_NAMES[i])
	_print_summary()

func _run_test(test_class: GDScript, name: String) -> void:
	print("\n--- %s ---" % name)
	var instance = test_class.new()
	if not instance.has_method("run"):
		push_error("Test class missing run() method: %s" % name)
		return
	var result = instance.run()
	_results.append(result)
	if result.get("passed", false):
		_passed += 1
		print("  PASS")
	else:
		_failed += 1
		print("  FAIL: ", result.get("message", ""))
	for detail in result.get("details", []):
		print("    ", detail)

func _print_summary() -> void:
	print("\n========================================")
	print("  Results: %d/%d passed" % [_passed, _passed + _failed])
	print("========================================")
	if _failed > 0:
		print("  SOME TESTS FAILED")
	else:
		print("  ALL TESTS PASSED")
