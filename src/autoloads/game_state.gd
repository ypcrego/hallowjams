extends Node

# Mapa de dados do dia (Escalável: adicione novos dias aqui)
const DAY_DATA_PATHS = {
	1: "res://src/data/days/day_01.tres",
	# ...
}
var current_day: int = 1 # Começa no dia 1
var packages_to_process: Array[Package] = []
# Inicializa o dia e carrega os pacotes
func start_day(day: int):
	var day_data: DayData = load(DAY_DATA_PATHS.get(day))
	print("day_data: " , day_data)

	# Cria uma cópia da lista de pacotes para manipulação (remover, embaralhar)
	packages_to_process = day_data.packages_to_deliver.duplicate()
	# Opcional, se quiser que a ordem seja aleatória: packages_to_process.shuffle()

	# Dispara o diálogo inicial do dia
	# [Você implementará isso no próximo passo]
# Função que a mesa chamará
func get_next_package_to_process() -> Package:
	if packages_to_process.size() > 0:
		return packages_to_process.pop_front()
	return null # Fim do turno de cadastro

func is_day_task_complete() -> bool:
	return packages_to_process.is_empty()

# Sinais para notificar a UI ou outros scripts sobre mudanças
signal package_status_changed(is_holding: bool, target_ap: String)
# Disparado para que o 'main.gd' gerencie a troca de cena
signal scene_change_requested(scene_path: String, spawn_point_name: String)

var has_package: bool = false
var target_ap: String = ""

# Caminho da última cena visitada (útil para salvar/carregar)
var current_scene_path: String = "res://scenes/kitnet.tscn"
# Nome do nó Marker2D onde o jogador deve aparecer na NOVA cena.
var next_spawn_point_name: String = "Start_From_Bed"

const RECEPTION_SCENE_PATH = "res://game/reception.tscn"

# Atualiza o status do pacote e notifica os ouvintes
func set_package_status(is_holding: bool, ap: String) -> void:
	self.has_package = is_holding
	self.target_ap = ap
	package_status_changed.emit(is_holding, ap)

# Avança o dia, reiniciando o estado do pacote (novo dia = sem pacote)
func advance_day() -> void:
	current_day += 1
	set_package_status(false, "")

	# Solicita a mudança de cena para a Kitnet, entrando pelo ponto de spawn "Start_From_Door_Back"
	# Você precisará criar o caminho correto da cena da Kitnet.
	scene_change_requested.emit(RECEPTION_SCENE_PATH, "Start_From_Door_Back")
	# Adicione aqui a lógica de salvar o progresso, se for o caso.
