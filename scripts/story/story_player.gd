extends CanvasLayer

class_name StoryPlayer

signal story_finished()
signal choice_made(choice_index: int)

@onready var dialogue_box: Panel = %DialogueBox
@onready var character_name_label: Label = %CharacterNameLabel
@onready var dialogue_text: RichTextLabel = %DialogueText
@onready var portrait_texture: TextureRect = %PortraitTexture
@onready var choice_container: VBoxContainer = %ChoiceContainer

var _lines: Array[Dictionary] = []
var _current_index: int = 0
var _current_character: String = ""

func play_story(file_path: String) -> void:
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
	match line.type:
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

func _show_character(name: String, expression: String) -> void:
	character_name_label.text = name
	var portrait_path := "res://assets/portraits/portrait_%s.png" % name
	var tex := load(portrait_path) as Texture2D
	if tex:
		portrait_texture.texture = tex

func _show_dialogue(text: String) -> void:
	dialogue_text.text = text

func _show_choices() -> void:
	var choice_index := 0
	while _current_index < _lines.size():
		var line := _lines[_current_index]
		if line.type != StoryParser.LineType.DIALOGUE:
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
	choice_made.emit(index)
	_advance()

func _handle_event(event_id: String) -> void:
	match event_id:
		"load_map":
			SceneRouter.goto("battle")
		"chapter_clear":
			story_finished.emit()
		"game_over":
			story_finished.emit()
		_:
			_advance()

func _finish() -> void:
	hide()
	story_finished.emit()
