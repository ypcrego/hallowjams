# Novo Script: src/scripts/floor_data.gd
extends Resource
class_name FloorData

## ID único para o sistema de Seed (e salvamento)
@export var floor_id: String = "TÉRREO"
@export var floor_name: String = "Térreo"

## Caminho da cena para onde o elevador leva neste andar
#@export var next_scene_path: String = ""
#@export var next_spawn_point_name: String = ""

## Lista de todas as portas neste andar
@export var doors: Array[DoorData] # Precisamos de um DoorData Resource

# Você também pode exportar aqui o Tileset/Theme se cada andar tiver um visual bem diferente
# @export var floor_tileset: TileSet
