extends Node

class_name TestRunner

var _results: Array[Dictionary] = []
var _passed: int = 0
var _failed: int = 0

func run_all() -> void:
	print("========================================")
	print("  Project Ember - MVP Test Suite")
	print("========================================")
	_run_test(TestDataSchema, "test_data_schema")
	_run_test(TestScriptsLoad, "test_scripts_load")
	_run_test(TestResourcesLoad, "test_resources_load")
	_run_test(TestCombatFormula, "test_combat_formula")
	_run_test(TestScenesLoad, "test_scenes_load")
	_print_summary()

func _run_test(test_class: GDScript, name: String) -> void:
	print("\n--- %s ---" % name)
	var instance := test_class.new()
	if not instance.has_method("run"):
		push_error("Test class missing run() method: ", name)
		return
	var result := instance.run()
	instance.free()
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
