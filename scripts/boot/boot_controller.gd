extends Node

class_name BootController

func _ready() -> void:
	_apply_theme()
	if SceneRouter:
		GameState.set_phase(GameState.GamePhase.TITLE)
		SceneRouter.goto("main_menu")
	else:
		push_error("SceneRouter autoload not available")

func _apply_theme() -> void:
	var theme := Theme.new()
	const Normal := preload("res://assets/sprites/ui/ui_button_normal.png")
	const Hover := preload("res://assets/sprites/ui/ui_button_hover.png")
	const Pressed := preload("res://assets/sprites/ui/ui_button_pressed.png")

	var btn_normal := StyleBoxTexture.new()
	btn_normal.texture = Normal
	var btn_hover := StyleBoxTexture.new()
	btn_hover.texture = Hover
	var btn_pressed := StyleBoxTexture.new()
	btn_pressed.texture = Pressed

	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_color("font_color", "Button", Color(0.9, 0.9, 0.85, 1))
	theme.set_color("font_hover_color", "Button", Color(1, 0.95, 0.7, 1))
	theme.set_color("font_pressed_color", "Button", Color(1, 1, 1, 1))
	theme.set_font_size("font_size", "Button", 18)

	var panel_bg := StyleBoxFlat.new()
	panel_bg.bg_color = Color(0.1, 0.12, 0.18, 0.85)
	panel_bg.set_corner_radius_all(6)
	theme.set_stylebox("panel", "Panel", panel_bg)

	theme.set_color("font_color", "Label", Color(0.9, 0.9, 0.85, 1))
	theme.set_font_size("font_size", "Label", 16)
	theme.set_color("font_color", "HSlider", Color(0.9, 0.9, 0.85, 1))
	theme.set_color("font_color", "CheckBox", Color(0.9, 0.9, 0.85, 1))

	get_tree().root.theme = theme
