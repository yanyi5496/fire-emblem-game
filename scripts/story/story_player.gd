extends CanvasLayer

class_name StoryPlayer

const _story_parser_dep := preload("res://scripts/story/story_parser.gd")

const DEFAULT_BATTLE_MAP_ID := "mvp_map_01"
const DEFAULT_STORY_PATH := "res://data/stories/mvp_story_01.txt"

const STORY_BY_FLAG := {
	"chapter_01_post_battle": "res://data/stories/mvp_story_02.txt",
}

signal story_finished()
signal choice_made(choice_index: int)

@onready var dialogue_box: Panel = $DialogueBox
@onready var character_name_label: Label = $DialogueBox/MarginContainer/VBoxContainer/CharacterNameLabel
@onready var dialogue_text: RichTextLabel = $DialogueBox/MarginContainer/VBoxContainer/DialogueText
@onready var portrait_texture: TextureRect = $DialogueBox/MarginContainer/VBoxContainer/PortraitTexture
@onready var choice_container: VBoxContainer = $ChoiceContainer

var _lines: Array[Dictionary] = []
var _current_index: int = 0
var _current_character: String = ""
var _is_narrator_mode := true
var _cg_overlay: TextureRect = null
var _effect_overlay: ColorRect = null
var _waiting_for_cg := false

func _ready() -> void:
	hide()
	dialogue_box.hide()
	choice_container.hide()
	_cg_overlay = TextureRect.new()
	_cg_overlay.name = "CGOverlay"
	_cg_overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_cg_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cg_overlay.anchors_preset = Control.PRESET_FULL_RECT
	_cg_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_cg_overlay.gui_input.connect(_on_cg_gui_input)
	_cg_overlay.hide()
	add_child(_cg_overlay)
	_effect_overlay = ColorRect.new()
	_effect_overlay.name = "EffectOverlay"
	_effect_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_effect_overlay.anchors_preset = Control.PRESET_FULL_RECT
	_effect_overlay.hide()
	add_child(_effect_overlay)
	if not InputManager.confirm_pressed.is_connected(_on_confirm_pressed):
		InputManager.confirm_pressed.connect(_on_confirm_pressed)
	if not dialogue_box.gui_input.is_connected(_on_dialogue_box_gui_input):
		dialogue_box.gui_input.connect(_on_dialogue_box_gui_input)
	if _lines.is_empty():
		var flag_key := "%s_post_battle_pending" % GameState.current_chapter
		if GameState.current_chapter != "" and GameState.story_flags.get(flag_key, false):
			GameState.story_flags.erase(flag_key)
			var story_key := flag_key.replace("_pending", "")
			var pending_story_path := str(STORY_BY_FLAG.get(story_key, ""))
			if pending_story_path == "":
				push_warning("Pending post-battle story not configured: %s" % story_key)
				pending_story_path = DEFAULT_STORY_PATH
			if not story_finished.is_connected(_on_post_battle_story_end):
				story_finished.connect(_on_post_battle_story_end)
			call_deferred("play_story", pending_story_path)
			return
		call_deferred("play_story", DEFAULT_STORY_PATH)

func play_story(file_path: String) -> void:
	GameState.set_phase(GameState.GamePhase.STORY)
	GameState.set_resume_scene("story")
	_lines = _story_parser_dep.parse_story(file_path)
	_current_index = 0
	_current_character = ""
	_is_narrator_mode = true
	show()
	_advance()

func _advance() -> void:
	if _current_index >= _lines.size():
		_finish()
		return
	var line := _lines[_current_index]
	_current_index += 1
	match line.get("type", _story_parser_dep.LineType.UNKNOWN):
		_story_parser_dep.LineType.NARRATOR:
			_show_narrator()
			_advance()
		_story_parser_dep.LineType.CHARACTER:
			_current_character = line.get("name", "")
			_show_character(_current_character, "")
			_advance()
		_story_parser_dep.LineType.DIALOGUE:
			_show_dialogue(line.get("content", ""))
		_story_parser_dep.LineType.BGM:
			AudioManager.play_bgm(line.get("bgm_id", ""))
			_advance()
		_story_parser_dep.LineType.EVENT:
			_handle_event(line.get("event_id", ""))
		_story_parser_dep.LineType.CONDITION:
			var flag: String = line.get("flag", "")
			if not GameState.story_flags.get(flag, false):
				_skip_to_next_marker()
			else:
				_advance()
		_story_parser_dep.LineType.CG:
			var cg_id: String = line.get("cg_id", "")
			if cg_id != "":
				_show_cg(cg_id)
		_story_parser_dep.LineType.EFFECT:
			var effect_id: String = line.get("effect_id", "")
			if effect_id != "":
				_play_effect(effect_id)
			else:
				_advance()
		_story_parser_dep.LineType.CHOICE:
			_show_choices()
		_:
			_advance()

func _skip_to_next_marker() -> void:
	while _current_index < _lines.size():
		var line := _lines[_current_index]
		if line.get("type", _story_parser_dep.LineType.UNKNOWN) != _story_parser_dep.LineType.DIALOGUE:
			break
		_current_index += 1
	_advance()

func _show_cg(cg_id: String) -> void:
	var cg_path := "res://assets/cg/%s.png" % cg_id
	var tex := load(cg_path) as Texture2D
	if tex:
		_cg_overlay.texture = tex
		_cg_overlay.show()
		_waiting_for_cg = true
		dialogue_box.hide()
	else:
		push_warning("CG not found: %s" % cg_path)
		_advance()

func _close_cg() -> void:
	_cg_overlay.hide()
	_cg_overlay.texture = null
	_waiting_for_cg = false
	_advance()

func _play_effect(effect_id: String) -> void:
	match effect_id:
		"fade_out":
			_effect_overlay.color = Color.BLACK
			_effect_overlay.modulate.a = 0.0
			_effect_overlay.show()
			var tween := create_tween()
			tween.tween_property(_effect_overlay, "modulate:a", 1.0, 0.5)
			tween.tween_callback(_advance)
		"fade_in":
			_effect_overlay.color = Color.BLACK
			_effect_overlay.modulate.a = 1.0
			_effect_overlay.show()
			var tween := create_tween()
			tween.tween_property(_effect_overlay, "modulate:a", 0.0, 0.5)
			tween.tween_callback(_effect_overlay.hide)
			tween.tween_callback(_advance)
		_:
			_advance()

func _show_narrator() -> void:
	_is_narrator_mode = true
	portrait_texture.texture = null
	character_name_label.text = ""

func _show_character(name: String, expression: String) -> void:
	_is_narrator_mode = false
	character_name_label.text = name
	var portrait_id := _name_to_portrait_id(name)
	var portrait_path := "res://assets/portraits/portrait_%s.png" % portrait_id
	var tex := load(portrait_path) as Texture2D
	if tex:
		portrait_texture.texture = tex
	else:
		portrait_texture.texture = null

func _show_dialogue(text: String) -> void:
	if _is_narrator_mode:
		character_name_label.text = ""
		portrait_texture.texture = null
	elif _current_character != "":
		character_name_label.text = _current_character
	dialogue_text.text = text
	dialogue_box.show()

func _show_choices() -> void:
	for child in choice_container.get_children():
		child.queue_free()
	choice_container.show()
	var choice_index := 0
	while _current_index < _lines.size():
		var line := _lines[_current_index]
		if line.get("type", _story_parser_dep.LineType.UNKNOWN) != _story_parser_dep.LineType.DIALOGUE:
			break
		_current_index += 1
		var btn := Button.new()
		btn.text = line.get("content", "")
		var ci := choice_index
		btn.pressed.connect(func(): _on_choice_selected(ci))
		choice_container.add_child(btn)
		choice_index += 1

func _on_choice_selected(index: int) -> void:
	for child in choice_container.get_children():
		child.queue_free()
	choice_container.hide()
	choice_made.emit(index)
	_advance()

func _on_confirm_pressed() -> void:
	if GameState.current_phase != GameState.GamePhase.STORY:
		return
	if _waiting_for_cg:
		_close_cg()
		return
	if choice_container.visible:
		return
	_advance()

func _on_cg_gui_input(event: InputEvent) -> void:
	if GameState.current_phase != GameState.GamePhase.STORY:
		return
	if not _waiting_for_cg:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_close_cg()

func _on_dialogue_box_gui_input(event: InputEvent) -> void:
	if GameState.current_phase != GameState.GamePhase.STORY:
		return
	if choice_container.visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_advance()

func _on_post_battle_story_end() -> void:
	var flow: Dictionary = DataManager.get_map(GameState.current_map_id) if GameState.current_map_id != "" else {}
	var next_chapter: String = GameState.story_flags.get("next_chapter", "")
	if next_chapter != "":
		GameState.current_chapter = next_chapter
		GameState.current_map_id = flow.get("id", GameState.current_map_id) if flow.get("id", "") != "" else ""
		GameState.set_resume_scene("story")
		SceneRouter.goto("story")
	elif GameState.completed_maps.size() > 0:
		GameState.current_map_id = ""
		GameState.set_resume_scene("main_menu")

func _handle_event(event_id: String) -> void:
	match event_id:
		"load_map":
			if GameState.current_map_id == "":
				GameState.current_map_id = DEFAULT_BATTLE_MAP_ID
			SceneRouter.goto("battle")
		"chapter_clear":
			_finish()
			SceneRouter.goto("main_menu")
		"game_over":
			_finish()
		_:
			_advance()

func _name_to_portrait_id(display_name: String) -> String:
	match display_name:
		"艾克": return "hero_001"
		"琳娜": return "hero_002"
		"山贼头目": return "enemy_002"
		_: return display_name

func _finish() -> void:
	_lines.clear()
	for child in choice_container.get_children():
		child.queue_free()
	dialogue_box.hide()
	_cg_overlay.hide()
	_effect_overlay.hide()
	_waiting_for_cg = false
	hide()
	choice_container.hide()
	GameState.set_phase(GameState.GamePhase.NONE)
	SaveManager.save_game(1)
	story_finished.emit()
