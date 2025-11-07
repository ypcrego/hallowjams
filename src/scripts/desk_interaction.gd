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
	if player_in_range:
		if GameState.is_day_task_complete():
			# Encerra o dia / Passa para a próxima fase (Entregas)
			#Dialogic.start('timeline_fase_entrega')
			return

		current_package = GameState.get_next_package_to_process()
		print(current_package)
		if current_package != null:
			_start_package_dialogue(current_package)
		#else:
			#Dialogic.start('timeline_fim_de_cadastro')

#		if GameState.has_package == false:
	#		receive_package()

func _on_dialogic_signal(arg : String):
	print("a")
	pass

func _start_package_dialogue(package: Package):
	Dialogic.VAR.set_variable("apartment", current_package.recipient_apartment)
	Dialogic.VAR.set_variable("weight", current_package.weight_description)
	Dialogic.VAR.set_variable("hint", current_package.surface_hint)
	Dialogic.VAR.set_variable("is_creepy", current_package.is_creepy)

	if Dialogic.current_timeline != null:
		return

	var dialog = Dialogic.start("pacotes")

#func _peek_package_call():
	#if current_package.is_creepy:
		# Lógica de Quebra de Parede/Choque
		# [Seu código para mostrar a cena de choque e pausar o jogo]
		#Dialogic.start('timeline_peek_shock') # Diálogo pós-choque: "Você olhou...?"
	#else:
		#Dialogic.start('timeline_peek_boring') # Diálogo: "Parece só um livro."


func receive_package():
	var target_ap = ""
	# 2. Define o pacote com base no dia
	if GameState.day_count == 1:
		target_ap = "101"
		print("NOVO: Pacote normal para o AP 101. Entregar.")

	elif GameState.day_count == 2:
		target_ap = "202"
		# Na ETAPA 3, você colocará a escolha de espiar AQUI. Por enquanto, apenas registra.
		print("NOVO: Pacote grande e PESADO para o AP 202. (Gatilho da História)")

	elif GameState.day_count >= 3:
		# Após o Dia 2, o loop se repete com uma entrega comum
		target_ap = "104"
		print("NOVO: Pacote comum para o AP 104.")
	# 1. Marca que está segurando um pacote
	GameState.set_package_status(true, target_ap)


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
