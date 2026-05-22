extends Node

class_name GameState

var current_chapter: String = ""
var current_map_id: String = ""
var turn_number: int = 0
var current_phase: String = "player"  # player / enemy / npc / round_end

var story_flags: Dictionary = {}
var completed_maps: Array[String] = []
var gold: int = 0
var inventory: Array[String] = []

func reset() -> void:
	current_chapter = ""
	current_map_id = ""
	turn_number = 0
	current_phase = "player"
	story_flags.clear()
	completed_maps.clear()
	gold = 0
	inventory.clear()
