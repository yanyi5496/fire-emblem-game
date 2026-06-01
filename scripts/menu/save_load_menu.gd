extends CanvasLayer

class_name SaveLoadMenu

signal slot_selected(slot: int, mode: String)

var _mode := "load"

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.SAVE_LOAD)
	if GameState.story_flags.get("_loading_mode", false):
		_mode = "load"
		GameState.story_flags.erase("_loading_mode")
	_build_slot_list()

func set_mode(mode: String) -> void:
	_mode = mode
	_build_slot_list()

func _build_slot_list() -> void:
	var vbox = $MarginContainer/VBoxContainer
	for child in vbox.get_children():
		if child.name != "TitleLabel" and child.name != "BackButton":
			child.queue_free()
	var title: Label = vbox.get_node("TitleLabel")
	title.text = "存档" if _mode == "save" else "读取存档"
	for i in range(1, SaveManager.MAX_SLOTS + 1):
		var slot_data := _get_slot_info(i)
		var is_empty := slot_data.is_empty()
		if _mode == "save":
			var hbox := HBoxContainer.new()
			hbox.name = "SlotRow_%d" % i
			var btn := Button.new()
			btn.name = "SlotButton_%d" % i
			btn.custom_minimum_size = Vector2(400, 60)
			btn.text = "槽位 %d — 空" % i if is_empty else "槽位 %d — %s | %s | 第%d回合 | %s" % [i, str(slot_data.get("chapter", "")) if str(slot_data.get("chapter", "")) != "" else str(slot_data.get("map_id", "")), _mode_text(slot_data), int(slot_data.get("turn", 0)), _format_time(int(slot_data.get("timestamp", 0))))]
			var slot_index := i
			btn.pressed.connect(func(): _on_slot_pressed(slot_index))
			hbox.add_child(btn)
			var del_btn := Button.new()
			del_btn.name = "DeleteButton_%d" % i
			del_btn.text = "删除"
			del_btn.custom_minimum_size = Vector2(80, 30)
			del_btn.disabled = is_empty
			del_btn.pressed.connect(func(): _on_delete_pressed(slot_index))
			hbox.add_child(del_btn)
			vbox.add_child(hbox)
			vbox.move_child(hbox, vbox.get_child_count() - 2)
		else:
			var btn := Button.new()
			btn.name = "SlotButton_%d" % i
			btn.custom_minimum_size = Vector2(400, 60)
			if is_empty:
				btn.text = "槽位 %d — 空" % i
				btn.disabled = true
			else:
				btn.text = "槽位 %d — %s | %s | 第%d回合 | %s" % [i, str(slot_data.get("chapter", "")) if str(slot_data.get("chapter", "")) != "" else str(slot_data.get("map_id", "")), _mode_text(slot_data), int(slot_data.get("turn", 0)), _format_time(int(slot_data.get("timestamp", 0))))]
			var slot_index := i
			btn.pressed.connect(func(): _on_slot_pressed(slot_index))
			vbox.add_child(btn)
			vbox.move_child(btn, vbox.get_child_count() - 2)

func _mode_text(data: Dictionary) -> String:
	var result: String = str(data.get("latest_battle_result", ""))
	match result:
		"victory": return "胜利"
		"defeat": return "败北"
		"": return "进行中"
		_: return result

func _format_time(timestamp: int) -> String:
	if timestamp <= 0:
		return "未知"
	return Time.get_datetime_string_from_unix_time(timestamp)

func _get_slot_info(slot: int) -> Dictionary:
	var path := "user://save_%02d.save" % slot
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var json_str := file.get_as_text()
	file = null
	var json := JSON.new()
	if json.parse(json_str) != OK:
		return {}
	return json.get_data() as Dictionary

func _on_slot_pressed(slot: int) -> void:
	if _mode == "load":
		var slot_data := _get_slot_info(slot)
		if slot_data.is_empty():
			return
		var resume_scene: String = str(slot_data.get("resume_scene", "main_menu"))
		if resume_scene == "":
			resume_scene = "main_menu"
		SaveManager.load_game(slot)
		SceneRouter.goto(resume_scene)
	else:
		SaveManager.save_game(slot)
		_build_slot_list()

func _on_delete_pressed(slot: int) -> void:
	var path := "user://save_%02d.save" % slot
	var dir := DirAccess.open("user://")
	if dir and FileAccess.file_exists(path):
		dir.remove(path)
		_build_slot_list()

func _on_back_pressed() -> void:
	SceneRouter.goto("main_menu")