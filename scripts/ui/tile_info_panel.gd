extends Panel

class_name TileInfoPanel

@onready var terrain_label: Label = %TerrainLabel
@onready var move_cost_label: Label = %MoveCostLabel
@onready var avoid_label: Label = %AvoidLabel
@onready var defense_label: Label = %DefenseLabel

func show_tile_info(terrain_id: String, tile_data: Dictionary) -> void:
	terrain_label.text = "地形: " + _terrain_name(terrain_id)
	move_cost_label.text = "移动消耗: %d" % tile_data.get("move_cost", 1)
	avoid_label.text = "回避: +%d" % tile_data.get("avoid_bonus", 0)
	defense_label.text = "防御: +%d" % tile_data.get("defense_bonus", 0)
	show()

func clear() -> void:
	hide()

func _terrain_name(id: String) -> String:
	match id:
		"plain": return "平原"
		"forest": return "森林"
		"mountain": return "山地"
		_: return id
