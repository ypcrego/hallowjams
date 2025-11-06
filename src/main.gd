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

	GUIDE.enable_mapping_context(default_mapping_context)
	show_main_menu.call_deferred()

	# Inicia o jogo carregando a primeira cena (Kitnet)
	#load_scene(INITIAL_SCENE_PATH, "Start_From_Menu")

func start_initial_game() -> void:
	print("aaaa")

	load_scene(INITIAL_SCENE_PATH, "Start_From_Menu")

	$UI.hide_ui("MainMenu")

# Função para carregar e configurar a nova cena
func load_scene(scene_path: String, spawn_point_name: String):
	# 1. Libera a cena antiga
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	# 2. Carrega a nova cena de forma eficiente
	var new_scene_resource = load(scene_path)
	if new_scene_resource is PackedScene:
		current_scene = new_scene_resource.instantiate()

		# 3. Adiciona ao contêiner
		current_scene_container.add_child(current_scene)

		# 4. Encontra o ponto de spawn na nova cena
		# Espera que a cena e seus filhos estejam prontos antes de procurar o ponto
		await current_scene.ready

		var spawn_point = current_scene.find_child(spawn_point_name)

		if spawn_point:
			# 5. Move o jogador persistente para o ponto de spawn
			player_node.global_position = spawn_point.global_position
		else:
			# Se não encontrou o ponto, usa a posição padrão
			print("AVISO: Ponto de spawn não encontrado: " + spawn_point_name)

		# Atualiza o estado global da cena
		GameState.current_scene_path = scene_path


func _on_scene_change_requested(scene_path: String, spawn_point_name: String):
	load_scene(scene_path, spawn_point_name)

func show_main_menu() -> void:
	if not $UI.is_preset_ready:
		await $UI.preset_ready
	$UI.show_ui("MainMenu")
