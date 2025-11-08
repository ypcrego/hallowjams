extends Area2D
# Se você tiver um recurso para o Dialogic, use-o aqui
# @export var elevator_dialogue: DialogicResource

# Mapeamento simples de Andar (string) para Scene Path (caminho da cena) e Spawn Point.
# ADICIONE AQUI todos os andares (hallways) do seu prédio.
const FLOOR_MAP = {
	0: {
		"scene": "res://src/game/storage.tscn",
		"spawn_point": "SP_From_Elevator"
	},
	1: {
		"scene": "res://src/game/Hall_100.tscn", # Exemplo de arquivo de cena para o andar 1
		"spawn_point": "SP_From_Elevator"
	},
	2: {
		"scene": "res://src/game/Hall_200.tscn", # Se houver um andar 2
		"spawn_point": "SP_From_Elevator"
	},
	3: {
		"scene": "res://src/game/Hall_300.tscn",
		"spawn_point": "SP_From_Elevator"
	},
	4: {
		"scene": "res://src/game/Hall_400.tscn",
		"spawn_point": "SP_From_Elevator"
	},
}

# Esta é a função que o Dialogic chamará (o "calcanhar de Aquiles" da lógica)
func go_to_floor(floor_id: int) -> void:
	if FLOOR_MAP.has(floor_id):
		var target_data = FLOOR_MAP[floor_id]

		# 1. Obter os dados da cena e do ponto de surgimento (spawn point)
		var target_scene_path = target_data.scene
		var target_spawn_point_name = target_data.spawn_point

		# 2. Emitir o sinal de troca de cena (o GameState está ouvindo)
		# O sinal é: scene_change_requested(scene_path: String, spawn_point_name: String)
		GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)

		# (Opcional) Remover o UI do Dialogic para que a transição ocorra
		Dialogic.end_timeline()

	else:
		push_error("Andar não mapeado: ", floor_id)
