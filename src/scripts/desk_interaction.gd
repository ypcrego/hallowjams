# Desk_Interaction.gd
extends StaticBody2D

# O caminho para o Dialogic deve ser o padrão, a menos que você o tenha alterado.

# Variável de controle local para a interação
@export var interact:GUIDEAction

var player_in_range = false
var current_package: Package = null # Variável para guardar o pacote atual

func _ready():
	interact.triggered.connect(handle_desk_interaction)
	Dialogic.signal_event.connect(_on_dialogic_signal)

	GameState.package_status_changed.connect(_on_package_status_changed)

func _on_package_status_changed(is_holding: bool, ap: String):
	# Exemplo de como reagir ao sinal
	print("STATUS ATUALIZADO VIA SINAL! Pacote? %s. Destino: %s" % [is_holding, ap])

# --- LÓGICA DE INTERAÇÃO ---

func handle_desk_interaction():
	if not player_in_range:
		return

	if Dialogic.current_timeline != null:
		return

	if GameState.is_processing_complete:
		_start_day_end_dialogue()
		return

	_check_for_next_package_and_start_dialogue()


# Recebe o sinal do Dialogic após o jogador fazer a escolha (Espiar/Resistir).
func _on_dialogic_signal(arg : String):
	# O sinal 'package_registered' é enviado no final da timeline do pacote.
	if arg == "package_registered" and current_package != null:
		# Adiciona o pacote processado à fila de entrega
		GameState.add_processed_package_for_delivery(current_package)

		GameState.remove_processed_package()

		print("LOG: Pacote registrado e pronto para entrega. Pacotes na fila de entrega: %s" % GameState.get_packages_to_deliver().size())
		current_package = null # Limpa a variável local

		_check_for_next_package_and_start_dialogue()

# Função central que inicia o diálogo e gerencia o fim da fila. (Loop)
func _check_for_next_package_and_start_dialogue():
	if GameState.is_processing_complete:
		# Cadastro terminou, apenas informa sobre a entrega.
		print("INFO: Cadastro completo. Agora, entregue os pacotes restantes.")
		return

	# 1. Tenta PEGAR o próximo pacote (PEEK, sem remover)
	current_package = GameState.get_next_package_to_process()

	if current_package != null:
		# Pacote encontrado, inicia o diálogo.
		print("LOG: Iniciando processamento do pacote para o AP %s." % current_package.recipient_apartment)
		_start_package_dialogue(current_package)
	else:
		GameState.mark_processing_complete()


func _start_package_dialogue(package: Package):
	Dialogic.VAR.set_variable("apartment", package.recipient_apartment)
	Dialogic.VAR.set_variable("weight", package.weight_description)
	Dialogic.VAR.set_variable("hint", package.surface_hint)
	Dialogic.VAR.set_variable("is_creepy", package.is_creepy)

	#if Dialogic.current_timeline != null:
		#return

	var dialog = Dialogic.start("pacotes")

func _start_day_end_dialogue():

	#
	Dialogic.start('no_more_packages')
	print("LOG: Fim do cadastro do dia. Iniciando diálogo de encerramento.")

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Checa se o corpo que entrou na área é o Player (baseado no nome do nó)
	if body.name == "Player":
		player_in_range = true
		# Em um jogo real, você mostraria uma UI aqui (ex: "Pressione E para Checar Encomendas")
		print("PROMPT: Porteiro na mesa. Pressione E para Interagir.")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		# Em um jogo real, você esconderia a UI aqui
