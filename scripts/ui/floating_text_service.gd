extends Node

class_name FloatingTextService

var _parent: Node2D = null

func initialize(parent: Node2D) -> void:
	_parent = parent

func spawn_damage_text(world_pos: Vector2, amount: int, is_heal: bool = false, is_crit: bool = false) -> void:
	var label := Label.new()
	if is_crit and amount == 0:
		label.text = "暴击!"
		label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		label.add_theme_font_size_override("font_size", 20)
	elif is_crit:
		label.text = "暴击 %d" % amount
		label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		label.add_theme_font_size_override("font_size", 22)
	elif is_heal:
		label.text = "+%d" % amount
		label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		label.add_theme_font_size_override("font_size", 18)
	else:
		label.text = "%d" % amount
		label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 100
	label.position = world_pos + Vector2(randi_range(-8, 8), -48)
	var target := _parent if _parent else get_tree().current_scene
	target.add_child(label)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 32, 0.7)
	tween.chain().tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)

func spawn_miss_text(world_pos: Vector2) -> void:
	var label := Label.new()
	label.text = "MISS"
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	label.add_theme_font_size_override("font_size", 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 100
	label.position = world_pos + Vector2(randi_range(-6, 6), -48)
	var target := _parent if _parent else get_tree().current_scene
	target.add_child(label)
	var tween := label.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 24, 0.5)
	tween.chain().tween_property(label, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(label.queue_free)