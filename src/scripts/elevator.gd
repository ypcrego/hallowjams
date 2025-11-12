extends Area2D
# Se você tiver um recurso para o Dialogic, use-o aqui
# @export var elevator_dialogue: DialogicResource

const HALL_SCENE: PackedScene = preload("res://src/game/Hall.tscn")

# 2. Pré-carregue os DADOS (Resources) de cada andar
const FLOOR_100_DATA = preload("res://src/assets/resources/floor_100s.tres")
const FLOOR_200_DATA = preload("res://src/assets/resources/floor_200s.tres")
const FLOOR_300_DATA = preload("res://src/assets/resources/floor_300s.tres")
const FLOOR_400_DATA = preload("res://src/assets/resources/floor_400s.tres")

# const FLOOR_300_DATA = preload("res://src/assets/resources/floor_300s.tres")

const FLOOR_MAP = {
	0: {
		# Exemplo: O storage/recepção ainda pode ser uma cena normal,
		# ou você pode criar um Resource Data para ele também.
		"scene_path": "res://src/game/reception.tscn",
		"spawn_point": "SP_From_Elevator",
		"data": null # Nenhuma injeção de dados necessária aqui
	},
	1: {
		"scene_path": "res://src/game/Hall.tscn", # Sempre a CENA GENÉRICA
		"spawn_point": "SP_From_Elevator",
		"data": FLOOR_100_DATA # O recurso de dados para o Hall 100
	},
	2: {
		"scene_path": "res://src/game/Hall.tscn", # Sempre a CENA GENÉRICA
		"spawn_point": "SP_From_Elevator",
		"data": FLOOR_200_DATA # O recurso de dados para o Hall 200
	},
	3: {
		"scene_path": "res://src/game/Hall.tscn", # Sempre a CENA GENÉRICA
		"spawn_point": "SP_From_Elevator",
		"data": FLOOR_300_DATA # O recurso de dados para o Hall 200
	},
	4: {
		"scene_path": "res://src/game/Hall.tscn", # Sempre a CENA GENÉRICA
		"spawn_point": "SP_From_Elevator",
		"data": FLOOR_400_DATA # O recurso de dados para o Hall 200
	},

	# Adicione os novos andares usando a mesma cena mestre e um novo recurso:
	#3: {
	#	"scene_path": "res://src/game/Hall.tscn",
	#	"spawn_point": "SP_From_Elevator",
	#	"data": FLOOR_300_DATA
	#},
}

# Esta é a função que o Dialogic chamará (o "calcanhar de Aquiles" da lógica)
func go_to_floor(floor_id: int) -> void:
	if FLOOR_MAP.has(floor_id):
		print(floor_id)
		var target_data = FLOOR_MAP[floor_id]
		var target_scene_path = target_data.scene_path
		var target_spawn_point_name = target_data.spawn_point
		var floor_data_resource = target_data.data # Pode ser null

		
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
