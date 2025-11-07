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


	if Dialogic.current_timeline != null:
		return

	var dialog = Dialogic.start("pacote_dialogue")

	#Dialogic.start_timeline('pacote_dialogue')
	#get_viewport().set_input_as_handled()

	# Cria a string de diálogo usando BBCode do Dialogic
	#var dialogue_text = "Pacote para o apto: [color=#88FFAA]" + package.recipient_apartment + "[/color].\n"
	#dialogue_text += "[shake rate=5 chars=30]Peso: " + package.weight_description + "[/shake]\n"
	#dialogue_text += "Dica: " + package.surface_hint

	# O Dialogic precisa ser iniciado com a cena/nó onde as opções serão apresentadas
	# Aqui, vamos usar um nó de opção customizado ou esperar que a próxima interação
	# do Dialogic seja a de "escolha".

	# Alternativamente, chame uma timeline simples para apresentar a informação
	# e, em seguida, uma com a opção de escolha.
	# Por simplicidade, para MVP, você pode querer forçar um evento de escolha logo após.

	# Opção 1: Usar uma função (se você tem um sistema customizado de opções)
	# dialogue_box.show_dialogue([dialogue_text], self, "_show_package_options")

	# Opção 2: Se você quer integrar diretamente com o sistema de Choices do Dialogic,
	# você precisa de uma Timeline que contenha o texto e, logo em seguida, a escolha.

	# Exemplo de como você pode disparar a escolha (se o Dialogic estiver configurado para Choices):
	# Dialogic.start('res://data/dialogic/timeline_check_package.dtl', { "package_details": package })

	# Para o MVP, vamos usar um diálogo simples que prepara para a escolha:
#	print(dialogue_text)
	# Próximo passo: Fazer a lógica da escolha (Passo 3)



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
