extends Node

class_name InputManager

signal move_cursor(direction: Vector2)
signal confirm_pressed()
signal cancel_pressed()
signal menu_toggle()

enum InputMode { BATTLE, MENU, DIALOGUE, NONE }

var current_mode: InputMode = InputMode.NONE

func set_mode(mode: InputMode) -> void:
	current_mode = mode

func _input(event: InputEvent) -> void:
	if current_mode == InputMode.NONE:
		return
	match current_mode:
		InputMode.BATTLE:
			_handle_battle_input(event)
		InputMode.MENU:
			_handle_menu_input(event)
		InputMode.DIALOGUE:
			_handle_dialogue_input(event)

func _handle_battle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		move_cursor.emit(Vector2.UP)
	elif event.is_action_pressed("ui_down"):
		move_cursor.emit(Vector2.DOWN)
	elif event.is_action_pressed("ui_left"):
		move_cursor.emit(Vector2.LEFT)
	elif event.is_action_pressed("ui_right"):
		move_cursor.emit(Vector2.RIGHT)
	elif event.is_action_pressed("ui_accept"):
		confirm_pressed.emit()
	elif event.is_action_pressed("ui_cancel"):
		cancel_pressed.emit()

func _handle_menu_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		confirm_pressed.emit()
	elif event.is_action_pressed("ui_cancel"):
		cancel_pressed.emit()

func _handle_dialogue_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		confirm_pressed.emit()
