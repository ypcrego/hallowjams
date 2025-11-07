# Desk_Interaction.gd
extends StaticBody2D

# O caminho para o Dialogic deve ser o padrão, a menos que você o tenha alterado.
const DIALOGUE_SCENE = preload("res://addons/dialogic/Dialogic.tscn")
const DIALOGUE_RESOURCE_PATH = "res://dialogues/seu_dialogo.json" # Caminho para a sua TimeLine salva

# Variável de controle local para a interação
@export var interact:GUIDEAction

var player_in_range = false

func _ready():
	interact.triggered.connect(handle_desk_interaction)

	GameState.package_status_changed.connect(_on_package_status_changed)

func _on_package_status_changed(is_holding: bool, ap: String):
	# Exemplo de como reagir ao sinal
	print("STATUS ATUALIZADO VIA SINAL! Pacote? %s. Destino: %s" % [is_holding, ap])

# --- LÓGICA DE INTERAÇÃO ---


func handle_desk_interaction():
	if player_in_range:
		if GameState.has_package == false:
			receive_package()
		else:
			# Mensagem se tentar pegar um novo pacote sem entregar o atual
			print("ALERTA: Entregue o pacote atual para o AP " + GameState.target_ap + " primeiro.")


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
