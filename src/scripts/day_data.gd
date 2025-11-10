extends Resource
class_name DayData

@export var day_number: int
@export var opening_dialogue_key: String = "DIA_1_INTRO"
@export var packages_to_deliver: Array[Package] # Lista de todos os pacotes do dia
@export var next_scene_on_complete: String = "res://src/game/kitnet.tscn"

@export var auto_start_dialogues: Dictionary
