extends Node

# Mapa de dados do dia (Escalável: adicione novos dias aqui)
const DAY_DATA_PATHS = {
	1: "res://src/data/days/day_01.tres",
	2: "res://src/data/days/day_02.tres",
	3: "res://src/data/days/day_03.tres",

}
var current_day: int = 1 # Começa no dia 1
var packages_to_process: Array[Package] = []
var current_day_data: DayData # Para armazenar o recurso do dia atual
var completed_scene_intros: Dictionary = {}

var _packages_to_deliver: Array[Package] = [] # Pacotes já cadastrados e prontos para entrega
var is_processing_complete: bool = false # TRUE quando todos os pacotes foram cadastrados na mesa.
var colega_terminou_todas_falas: bool = false


func set_packages_to_deliver(new_packages: Array[Package]) -> void:
	_packages_to_deliver = new_packages
	_update_current_delivery_target()

func get_has_package() -> bool:
	# O jogador tem um pacote se a lista de entrega não estiver vazia
	return _packages_to_deliver.size() > 0

func get_target_ap() -> String:
	if get_has_package():
		return _packages_to_deliver.front().recipient_apartment
	return ""

func get_packages_to_deliver() -> Array[Package]:
	return _packages_to_deliver

# Inicializa o dia e carrega os pacotes
func start_day(day: int):
	print("Funcao de comecar dia foi chamada")
	var day_data: DayData = load(DAY_DATA_PATHS.get(day))
	print("Arquivo de dados carregado:", DAY_DATA_PATHS[day])
	print("ESTAMOS INICIANDO UM NOVO DIA: ", day)
	current_day_data = day_data
	completed_scene_intros.clear()
	colega_terminou_todas_falas = false
	# Cria uma cópia da lista de pacotes para manipulação (remover, embaralhar)
	set_packages_to_deliver([]) # Limpa a lista de pacotes a entregar do dia anterior
	packages_to_process = day_data.packages_to_deliver.duplicate()
	is_processing_complete = false # Reinicia o estado para o novo dia

	if Dialogic.current_timeline == null:
		Dialogic.start(day_data.opening_dialogue_key)
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
	_packages_to_deliver.append(package)
	_update_current_delivery_target()


# NOVO: Função Privada para Manter a Consistência do Estado (A ÚNICA AUTORIDADE)
func _update_current_delivery_target() -> void:
	if _packages_to_deliver.size() > 0:
		# O jogador está sempre "segurando" o primeiro pacote da fila de entrega
		# como um marcador para a UI/HUD. A lógica de entrega é flexível.
		var next_package: Package = _packages_to_deliver.front()
		set_package_status(true, next_package.recipient_apartment)
		print("LOG: Jogador está 'segurando' o pacote para o AP ", next_package.recipient_apartment)
	else:
		# Não há mais pacotes para entregar.
		set_package_status(false, "")
		print("LOG: Jogador de 'mãos vazias'.")

	print('printando numero de pacotes pra entregar: ', _packages_to_deliver.size())
	print('printando processamento completo: ', is_processing_complete)


# Marca que o turno de CADASTRO na mesa terminou.
func mark_processing_complete() -> void:
	is_processing_complete = true
	# Neste ponto, você pode disparar um sinal para que o script principal (Game.gd)
	# saiba que é hora de ir para a fase de entrega (ex: liberando o elevador).

# Retorna se TODAS as tarefas do dia (cadastro E entrega) estão completas
func is_day_task_complete() -> bool:
	print('dia terminou ? ', is_processing_complete and _packages_to_deliver.is_empty())
	# O dia só está completo se o processamento terminou E não houver pacotes para entregar
	return is_processing_complete and _packages_to_deliver.is_empty()


# Sinais para notificar a UI ou outros scripts sobre mudanças
signal package_status_changed(is_holding: bool, target_ap: String)
# Sinal para notificar que um pacote creepy foi entregue.
signal creepy_package_delivered(creepy_scene_path: String)

# Disparado para que o 'main.gd' gerencie a troca de cena
signal scene_change_requested(scene_path: String, spawn_point_name: String)

signal scene_change_requested_with_data(scene_path: String, spawn_point_name: String, floor_data_resource: Resource)


# Caminho da última cena visitada (útil para salvar/carregar)
var current_scene_path: String = "res://scenes/kitnet.tscn"
# Nome do nó Marker2D onde o jogador deve aparecer na NOVA cena.
var next_spawn_point_name: String = "SP_From_Bed"

const RECEPTION_SCENE_PATH = "res://game/reception.tscn"
const KITNET_SCENE_PATH = "res://game/kitnet.tscn"

# Atualiza o status do pacote e notifica os ouvintes
func set_package_status(is_holding: bool, ap: String) -> void:
	package_status_changed.emit(is_holding, ap)

# Avança o dia, reiniciando o estado do pacote (novo dia = sem pacote)
func advance_day() -> void:
	print("avançando o dia !!!!!")
	current_day += 1
	set_package_status(false, "")

	start_day(current_day)

	print("estasos em um novo dia !")


	# Adicione aqui a lógica de salvar o progresso, se for o caso.


func try_deliver_package_at_apartment(apartment_num: String) -> bool:
# Lógica para garantir que o jogador tenha um pacote antes de tentar entregar
	if _packages_to_deliver.is_empty():
		print("AVISO: Jogador tentou entregar sem pacote.")
		return false

	var current_target_ap = _packages_to_deliver.front().recipient_apartment
	print('Tentando entregar para ap:', apartment_num, '. Pacote carregado (UI) para: ', current_target_ap)

	var package_to_remove: Package = null
	var index_to_remove: int = -1

	# 1. Procurar O PRIMEIRO pacote CORRESPONDENTE na lista de entregas pendentes
	# O loop permite a entrega em qualquer ordem, encontrando o pacote correto na fila.
	for i in range(_packages_to_deliver.size()):
		var package: Package = _packages_to_deliver[i]
		if package.recipient_apartment == apartment_num:
			package_to_remove = package
			index_to_remove = i
			break

	# 2. Se encontrou um pacote para este apartamento
	if package_to_remove != null:

		# 3. Lógica de evento creepy
		if package_to_remove.is_creepy:
			print("🚨 Pacote creepy entregue! Disparando evento.")
			creepy_package_delivered.emit(package_to_remove.creepy_scene_path)

		# 4. Remover o pacote.
		_packages_to_deliver.remove_at(index_to_remove)

		_update_current_delivery_target()

		# 5. Checar o fim do dia
		if is_day_task_complete():
			print("📦 Dia completo!")

		return true

	return false

	# NOVO: Inicia a sequência de fim da fase de entregas.
func start_delivery_end_sequence():
	if !current_day_data:
		push_error("DayData não carregado. Não é possível encerrar o dia.")
		return

	# Nome da timeline de encerramento
	var delivery_end_timeline = "delivery_end_day_" + str(current_day)
	print("Iniciando timeline de fim de entrega:", delivery_end_timeline)

	# Evita conexões duplicadas
	if Dialogic.is_connected("timeline_ended", Callable(self, "_on_delivery_end_dialogue_ended")):
		Dialogic.disconnect("timeline_ended", Callable(self, "_on_delivery_end_dialogue_ended"))

	Dialogic.connect("timeline_ended", Callable(self, "_on_delivery_end_dialogue_ended"))
	Dialogic.start(delivery_end_timeline)


# Chamado quando o diálogo de fim de entregas termina.
func _on_delivery_end_dialogue_ended():
	print('delivery ended')

	if Dialogic.is_connected("timeline_ended", Callable(self, "_on_delivery_end_dialogue_ended")):
		Dialogic.disconnect("timeline_ended", Callable(self, "_on_delivery_end_dialogue_ended"))

	if current_day_data:
		var kitnet_path = current_day_data.next_scene_on_complete
		var bed_spawn = "SP_From_Bed"
		scene_change_requested.emit(kitnet_path, bed_spawn)


func cheat_complete_day() -> void:
	print("LOG: Ativando trapaça para completar o dia...")

	# 1. Força a conclusão do turno de cadastro na mesa.
	mark_processing_complete() # Define is_processing_complete = true

	# 2. Limpa a lista de pacotes a entregar (simula que todos foram entregues).
	# Usamos set_packages_to_deliver para garantir que o status seja atualizado corretamente.
	set_packages_to_deliver([]) # Define _packages_to_deliver como vazio

	# Opcional: Chama a função de verificação para garantir que o estado está correto e atualizar a UI
	# (Apesar de set_packages_to_deliver já fazer isso internamente, é um bom check)
	_update_current_delivery_target()

	print("LOG: Cheat de final de dia executado. Você agora pode interagir com a cama.")
