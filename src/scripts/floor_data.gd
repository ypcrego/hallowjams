# src/scripts/floor_data.gd (CORRIGIDO)
extends Resource
class_name FloorData

# Novo ID único para a cena de Hall (ex: "Hall_100", "Hall_200")
@export var unique_floor_id: String = ""

# Lista de recursos DoorData para este andar
@export var doors: Array[DoorData]

@export var decorative_objects: Array[NodePath]

# Propriedade para o diálogo (opcional, pode vir de outro lugar)
@export var hall_dialogue_id: String = ""
