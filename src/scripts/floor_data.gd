# src/scripts/floor_data.gd (CORRIGIDO)
extends Resource
class_name FloorData

# Novo ID único para a cena de Hall (ex: "Hall_100", "Hall_200")
@export var unique_floor_id: String = ""

# Mapeia o número do apartamento (String) para a configuração de porta (ApartmentConfig)
# Ex: {"101": [Resource:ApartmentConfig], "102": [Resource:ApartmentConfig], ...}
@export var apartment_configs: Dictionary = {}

@export var decorative_objects: Array[NodePath]

# Propriedade para o diálogo (opcional, pode vir de outro lugar)
@export var hall_dialogue_id: String = ""
