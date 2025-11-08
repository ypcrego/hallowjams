extends Node

# Mapa de dados do dia (Escalável: adicione novos dias aqui)
const DAY_DATA_PATHS = {
	1: "res://src/data/days/day_01.tres",
	# ...
}
var current_day: int = 1 # Começa no dia 1
var packages_to_process: Array[Package] = []
var packages_to_deliver: Array[Package] = [] # Pacotes já cadastrados e prontos para entrega
var is_processing_complete: bool = false # TRUE quando todos os pacotes foram cadastrados na mesa.

# Inicializa o dia e carrega os pacotes
func start_day(day: int):
	var day_data: DayData = load(DAY_DATA_PATHS.get(day))
	print("day_data: " , day_data)

	# Cria uma cópia da lista de pacotes para manipulação (remover, embaralhar)
	packages_to_process = day_data.packages_to_deliver.duplicate()
	packages_to_deliver.clear() # Limpa a lista de pacotes a entregar do dia anterior
	is_processing_complete = false # Reinicia o estado para o novo dia
	# Opcional, se quiser que a ordem seja aleatória: packages_to_process.shuffle()

# Função que a mesa chamará
func get_next_package_to_process() -> Package:
	if packages_to_process.size() > 0:
		return packages_to_process.front()
	return null # Fim do turno de cadastro

# Remove o pacote atual da fila de PROCESSAMENTO. (POP)
func remove_processed_package():
	if packages_to_process.size() > 0:
		# Remove o pacote que acabou de ser processado (pacote na frente)
		packages_to_process.pop_front()

# NOVO: Adiciona um pacote (já processado/espiado) à lista de entrega.
func add_processed_package_for_delivery(package: Package):
	packages_to_deliver.append(package)

# NOVO: Marca que o turno de CADASTRO na mesa terminou. (Resposta à Q2)
func mark_processing_complete() -> void:
	is_processing_complete = true
	# Neste ponto, você pode disparar um sinal para que o script principal (Game.gd)
	# saiba que é hora de ir para a fase de entrega (ex: liberando o elevador).

# Retorna se TODAS as tarefas do dia (cadastro E entrega) estão completas
func is_day_task_complete() -> bool:
	# O dia só está completo se o processamento terminou E não houver pacotes para entregar
	return is_processing_complete and packages_to_deliver.is_empty()


# Sinais para notificar a UI ou outros scripts sobre mudanças
signal package_status_changed(is_holding: bool, target_ap: String)
# Sinal para notificar que um pacote creepy foi entregue.
signal creepy_package_delivered(creepy_scene_path: String)

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


func try_deliver_package_at_apartment(apartment_num: String) -> bool:
	# 1. Verificar se o jogador está segurando o pacote para este apartamento.
	if target_ap == apartment_num:
		var package_to_remove: Package = null
		var index_to_remove: int = -1

		# 2. Procurar o pacote na lista de entregas pendentes
		for i in range(packages_to_deliver.size()):
			var package: Package = packages_to_deliver[i]
			if package.recipient_apartment == apartment_num:
				package_to_remove = package
				index_to_remove = i
				break

		if package_to_remove != null:
					# 3. >>> LÓGICA DE EVENTO MOVIDA PARA CÁ (ENCAPSULAMENTO) <<<
					if package_to_remove.is_creepy:
						# Se for creepy, o GameState dispara a notificação
						print("🚨 Pacote creepy entregue! Disparando evento.")
						creepy_package_delivered.emit(package_to_remove.creepy_scene_path)

					# 4. Remover o pacote e limpar o status do jogador.
					packages_to_deliver.remove_at(index_to_remove)
					set_package_status(false, "")

					# 5. Checar o fim do dia
					if is_day_task_complete():
						print("📦 Dia completo!")
						#var kitnet_path = "res://scenes/kitnet.tscn"
						#var bed_spawn = "Start_From_Bed"
						#scene_change_requested.emit(kitnet_path, bed_spawn) # Dispara encerramento
					return true
	return false
