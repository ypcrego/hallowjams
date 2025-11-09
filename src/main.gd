extends Node

@export var default_mapping_context: GUIDEMappingContext

# Caminho da cena de início (Sua Kitnet)
const INITIAL_SCENE_PATH = "res://src/game/storage.tscn"

# Variáveis para a cena e o jogador
var current_scene: Node = null
@onready var current_scene_container = $CurrentSceneContainer # Certifique-se que o nome do nó bate!
@onready var player_node = $Player # Certifique-se que o nome do nó Player está correto!


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sinal do autoload
	GameState.scene_change_requested.connect(_on_scene_change_requested)

	GameState.scene_change_requested_with_data.connect(_on_scene_change_requested_with_data)

	GUIDE.enable_mapping_context(default_mapping_context)
	show_main_menu.call_deferred()

	# Inicia o jogo carregando a primeira cena (Kitnet)
	#load_scene(INITIAL_SCENE_PATH, "Start_From_Menu")

func start_initial_game() -> void:

	load_scene(INITIAL_SCENE_PATH, "Start_From_Menu")
	GameState.start_day(1)

	$UI.hide_ui("MainMenu")

# Função para carregar e configurar a nova cena
# Função para carregar e configurar a nova cena
# O parâmetro floor_data_resource é OPCIONAL (se for null, carrega a cena normal)
func load_scene(scene_path: String, spawn_point_name: String, floor_data_resource: Resource = null):
	# 1. Libera a cena antiga
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	# 2. Carrega a nova cena de forma eficiente
	var new_scene_resource = load(scene_path)
	if new_scene_resource is PackedScene:
		current_scene = new_scene_resource.instantiate()

		# 🚨 NOVO BLOCO DE LÓGICA: INJEÇÃO DE DADOS 🚨
		if floor_data_resource != null:
			# Procura o nó ApartmentHall (filho da cena Hall.tscn)
			# O 'true, false' permite busca recursiva em filhos, mas apenas no primeiro nível,
			# o que é bom para evitar procurar em toda a árvore.
			var apartment_hall_node = current_scene.find_child("ApartmentHall", true, false)

			if is_instance_valid(apartment_hall_node):
				# Injete o recurso de dados no script ApartmentHall (apartment_hall.gd)
				apartment_hall_node.floor_data = floor_data_resource
				# O print é opcional, mas útil para confirmar o que foi carregado
				# Se você adicionou 'unique_floor_id' ao seu FloorData.gd
				# print("LOG: Dados do andar injetados: ", floor_data_resource.unique_floor_id)
			else:
				push_error("ERRO: Nó 'ApartmentHall' não encontrado na cena: ", scene_path, ". Injeção de dados falhou.")

		# 3. Adiciona ao contêiner
		current_scene_container.add_child(current_scene)

		# 4. Encontra o ponto de spawn na nova cena
		await _wait_scene_ready()

		var spawn_point = current_scene.find_child(spawn_point_name, true, false)
		if spawn_point:
			await get_tree().physics_frame
			# 5. Move o jogador persistente para o ponto de spawn
			player_node.global_position = spawn_point.global_position
		else:
			print("AVISO: Ponto de spawn não encontrado: " + spawn_point_name)

		# Atualiza o estado global da cena
		GameState.current_scene_path = scene_path

func _wait_scene_ready():
	# Aguarda um frame de processamento (ready dos filhos)
	await get_tree().process_frame
	# Aguarda um frame de física (garante colisões/posições corretas)
	await get_tree().physics_frame

func _on_scene_change_requested(scene_path: String, spawn_point_name: String):
	load_scene(scene_path, spawn_point_name)

func _on_scene_change_requested_with_data(scene_path: String, spawn_point_name: String, floor_data_resource: Resource):
	load_scene(scene_path, spawn_point_name, floor_data_resource)

func show_main_menu() -> void:
	if not $UI.is_preset_ready:
		await $UI.preset_ready
	$UI.show_ui("MainMenu")
