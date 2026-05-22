extends CanvasLayer

class_name StoryPlayer

const DEFAULT_BATTLE_MAP_ID := "mvp_map_01"
const DEFAULT_STORY_PATH := "res://data/stories/mvp_story_01.txt"

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

func _ready() -> void:
	hide()
	if _lines.is_empty():
		call_deferred("play_story", DEFAULT_STORY_PATH)

func play_story(file_path: String) -> void:
	GameState.set_phase(GameState.GamePhase.STORY)
	_lines = StoryParser.parse_story(file_path)
	_current_index = 0
	show()
	_advance()

func _advance() -> void:
	if _current_index >= _lines.size():
		_finish()
		return
	var line := _lines[_current_index]
	_current_index += 1
	match line.get("type", StoryParser.LineType.UNKNOWN):
		StoryParser.LineType.NARRATOR:
			_show_narrator()
		StoryParser.LineType.CHARACTER:
			_current_character = line.get("name", "")
			_show_character(_current_character, "")
		StoryParser.LineType.DIALOGUE:
			_show_dialogue(line.get("content", ""))
		StoryParser.LineType.BGM:
			AudioManager.play_bgm(line.get("bgm_id", ""))
			_advance()
		StoryParser.LineType.EVENT:
			_handle_event(line.get("event_id", ""))
		StoryParser.LineType.CHOICE:
			_show_choices()
		_:
			_advance()

func _show_narrator() -> void:
	portrait_texture.texture = null
	character_name_label.text = ""
	dialogue_text.text = ""
	dialogue_box.show()

func _show_character(name: String, expression: String) -> void:
	character_name_label.text = name
	var portrait_id := _name_to_portrait_id(name)
	var portrait_path := "res://assets/portraits/portrait_%s.png" % portrait_id
	var tex := load(portrait_path) as Texture2D
	if tex:
		portrait_texture.texture = tex

func _show_dialogue(text: String) -> void:
	dialogue_text.text = text
	dialogue_box.show()

func _show_choices() -> void:
	for child in choice_container.get_children():
		child.queue_free()
	choice_container.show()
	var choice_index := 0
	while _current_index < _lines.size():
		var line := _lines[_current_index]
		if line.get("type", StoryParser.LineType.UNKNOWN) != StoryParser.LineType.DIALOGUE:
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

func _handle_event(event_id: String) -> void:
	match event_id:
		"load_map":
			if GameState.current_map_id == "":
				GameState.current_map_id = DEFAULT_BATTLE_MAP_ID
			SceneRouter.goto("battle")
		"chapter_clear":
			_finish()
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
	hide()
	choice_container.hide()
	GameState.set_phase(GameState.GamePhase.NONE)
	story_finished.emit()
