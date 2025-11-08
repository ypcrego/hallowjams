# src/scripts/floor_list.gd
extends Resource
class_name FloorList # Novo tipo

# Exporta um Array de FloorData (para evitar que o dicionário exclua o tipo)
@export var floor_data_list: Array[FloorData] = []
