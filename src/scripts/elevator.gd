extends Node2D


const FLOOR_MASTER_LIST = preload("res://src/assets/resources/floors/floor_master.tres")
const HALL_SCENE: PackedScene = preload("res://src/game/Hall.tscn")
const DEFAULT_SPAWN_POINT = "SP_From_Elevator"

var FLOOR_DATA_MAP: Dictionary = {}

func _ready() -> void:
	# Certifique-se de chamar a função de construção
	build_floor_data_map()
	# ... (resto do _ready)

# Esta é a função que o Dialogic chamará (o "calcanhar de Aquiles" da lógica)
func go_to_floor(floor_id: int) -> void:
	print(FLOOR_DATA_MAP)
	print(floor_id)
	if FLOOR_DATA_MAP.has(floor_id):
		var target_data = FLOOR_DATA_MAP[floor_id]
		var floor_data_resource = target_data.data # Pode ser null
		var target_scene_path = target_data.scene_path
		var target_spawn_point_name = target_data.spawn_point

		# Se for um andar (Hall.tscn) que precisa de dados, emite o NOVO sinal:
		if floor_data_resource != null:
			GameState.scene_change_requested_with_data.emit(
				target_scene_path,
				target_spawn_point_name,
				floor_data_resource
			)

		else:
			# Se for uma cena normal (storage.tscn), emite o sinal antigo:
			GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)

		Dialogic.end_timeline()

	else:
		push_error("Andar não mapeado: ", floor_id)


func build_floor_data_map():
	# Limpa o mapa se for chamado várias vezes
	FLOOR_DATA_MAP.clear()

	# Adiciona o andar de recepção (exceção que não usa FloorData)
	FLOOR_DATA_MAP[0] = {
		"scene_path": "res://src/game/storage.tscn", # Exemplo seu
		"spawn_point": DEFAULT_SPAWN_POINT,
		"data": null
	}

	# Itera sobre a lista de FloorData para preencher o mapa
	for floor_data in FLOOR_MASTER_LIST.floor_data_list:
		# Usa o unique_floor_id ("100", "200") como chave do dicionário
		var floor_id = floor_data.unique_floor_id.to_int()
		FLOOR_DATA_MAP[floor_id] = {
			"scene_path": HALL_SCENE.resource_path,
			"spawn_point": DEFAULT_SPAWN_POINT,
			"data": floor_data # O Recurso FloorData inteiro
		}
		print(FLOOR_DATA_MAP)
