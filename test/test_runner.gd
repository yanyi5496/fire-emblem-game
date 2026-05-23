extends Node

class_name TestRunner

const TEST_CLASSES := [
	preload("res://test/test_data_schema.gd"),
	preload("res://test/test_game_state_flow.gd"),
	preload("res://test/test_scripts_load.gd"),
	preload("res://test/test_resources_load.gd"),
	preload("res://test/test_combat_formula.gd"),
	preload("res://test/test_scenes_load.gd"),
	preload("res://test/test_scene_contracts.gd"),
]
const TEST_NAMES := [
	"test_data_schema",
	"test_game_state_flow",
	"test_scripts_load",
	"test_resources_load",
	"test_combat_formula",
	"test_scenes_load",
	"test_scene_contracts",
]

var _results: Array[Dictionary] = []
var _passed: int = 0
var _failed: int = 0

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
