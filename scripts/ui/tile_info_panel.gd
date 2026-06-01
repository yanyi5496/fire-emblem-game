extends Panel

class_name TileInfoPanel

@onready var terrain_label: Label = $VBoxContainer/TerrainLabel
@onready var move_cost_label: Label = $VBoxContainer/MoveCostLabel
@onready var avoid_label: Label = $VBoxContainer/AvoidLabel
@onready var defense_label: Label = $VBoxContainer/DefenseLabel

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
		"river": return "河流"
		"lake": return "湖泊"
		"castle": return "城堡"
		"indoor": return "室内"
		"volcano": return "火山"
		"snow": return "雪地"
		"desert": return "沙漠"
		"bridge": return "桥梁"
		"wall": return "墙壁"
		"throne": return "王座"
		"gate": return "城门"
		"village": return "村庄"
		"road": return "道路"
		"swamp": return "沼泽"
		"pillar": return "立柱"
		_: return id