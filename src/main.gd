extends Node

@export var default_mapping_context: GUIDEMappingContext
signal guide_ready

# Caminho da cena de início (Sua Kitnet)
const INITIAL_SCENE_PATH = "res://src/game/kitnet.tscn"
# Variáveis para a cena e o jogador
var current_scene: Node = null
@onready var current_scene_container = $CurrentSceneContainer # Certifique-se que o nome do nó bate!
@onready var player_node = $Player # Certifique-se que o nome do nó Player está correto!

@onready var fade_layer: ColorRect = $FadeCanvas/FadeLayer
var first_scene_loaded := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_node.process_mode = Node.PROCESS_MODE_DISABLED
	player_node.visible = false

	# Sinal do autoload
	GameState.scene_change_requested.connect(_on_scene_change_requested)

	GameState.scene_change_requested_with_data.connect(_on_scene_change_requested_with_data)

	GUIDE.enable_mapping_context(default_mapping_context)
	emit_signal("guide_ready")

	show_main_menu.call_deferred()

func start_initial_game() -> void:

	$UI.hide_ui("MainMenu")
	player_node.process_mode = Node.PROCESS_MODE_INHERIT


	if not $UI.is_preset_ready:
		await $UI.preset_ready
	$UI.show_ui("Game")

	player_node.visible = true

	fade_layer.visible = true
	fade_layer.modulate.a = 1.0

	load_scene(INITIAL_SCENE_PATH, "SP_From_Bed")

	GameState.start_day(1)

	Dialogic.signal_event.connect(_on_dialogic_event)




# Função para carregar e configurar a nova cena
# Função para carregar e configurar a nova cena
# O parâmetro floor_data_resource é OPCIONAL (se for null, carrega a cena normal)
func load_scene(scene_path: String, spawn_point_name: String, floor_data_resource: Resource = null):
	if first_scene_loaded:
		await fade_out(1.25)

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

		if first_scene_loaded:
			await fade_in(1.25)
		else:
			first_scene_loaded = true  # Marca que a primeira já foi

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

func fade_in(duration: float = 1.0) -> void:
	fade_layer.visible = true
	var tween = create_tween()
	tween.tween_property(fade_layer, "modulate:a", 0.0, duration)
	await tween.finished
	# Esconde o fade layer no fim (evita sobreposição de input/click)
	fade_layer.visible = false

func fade_out(duration: float = 1.0) -> void:
	fade_layer.visible = true
	var tween = create_tween()
	tween.tween_property(fade_layer, "modulate:a", 1.0, duration)
	await tween.finished

func _on_dialogic_event(argument: String):
	if argument == "mostrar_cena":
		fade_in(1.5)

	if argument == "finished_day_2":
		# Inicia o fluxo de transição forçada
		force_day_transition()
# >>> INÍCIO DA MUDANÇA PARA FIM DE JOGO
	if argument == "morreu":
		print("LOG: Sinal 'morreu' recebido. Iniciando sequência de Fim de Jogo.")
		# Usamos call_deferred para garantir que o evento de diálogo atual termine
		call_deferred("end_game_sequence")
	# <<< FIM DA MUDANÇA PARA FIM DE JOGO

func _input(event: InputEvent):
	# Permite que a função de cheat seja chamada de qualquer lugar no jogo
	if event.is_action_pressed("ui_accept") and Input.is_key_pressed(KEY_V):
		print("cheatou")
		# Nota: "ui_accept" é o input padrão para Enter/Espaço/Joystick A

		# Certifica-se de que GameState está carregado (é um Autoload, então deve estar)
		GameState.cheat_complete_day()


func force_day_transition() -> void:
	# 1. Tela preta (Fade Out)
	await fade_out(1.5)

	# 2. [CORREÇÃO: TROCA DE CENA] Força o retorno para a Kitnet ANTES de avançar o dia
	# O spawn point "SP_From_Bed" deve ser válido na cena da kitnet.
	load_scene(INITIAL_SCENE_PATH, "SP_From_Bed")

	# IMPORTANTE: Garante que a cena nova está pronta para a próxima instrução
	# (load_scene já tem um await para _wait_scene_ready() e load_scene(..))

	# 3. [DELAY MANTIDO] Adiciona o atraso na tela preta.
	await get_tree().create_timer(1.5).timeout

	# 4. Atualizar o estado do jogo para o novo dia
	GameState.advance_day()
	var next_day_number = GameState.current_day
	var new_day_dialogue_timeline: String = "new_day_" + str(next_day_number)

	print("LOG: Transição abrupta concluída. Iniciando diálogo para o dia: ", next_day_number)

	# 5. Iniciar o novo diálogo
	Dialogic.start(new_day_dialogue_timeline)

	# 6. Espera um frame para o Dialogic (mantido)
	await get_tree().process_frame

	# 7. [FADE IN MANTIDO] Força o Fade In para revelar a cena e o diálogo.
	await fade_in(1.5)

func end_game_sequence():
	Dialogic.end_timeline(true)

	await enable_grayscale(3.5)

	# 2. Tela preta (Fade Out)
	await fade_out(6.5)

	# 3. Desabilita o jogador e a UI do jogo
	player_node.process_mode = Node.PROCESS_MODE_DISABLED
	player_node.visible = false
	if $UI.is_shown("Game"):
		await $UI.hide_ui("Game") # Esconde a HUD/UI principal do jogo

	# 4. Mostra a tela de "Obrigado por Jogar"
	# "ThanksForPlaying" é o nome do nó da cena em src/ui/thanks_for_playing/thank_for_playing.tscn
	$UI.show_ui("ThanksForPlaying")

	# 5. Fade In para revelar a tela final
	await fade_in(1.5)

func enable_grayscale(duration := 1.0):
	var grayscale = $PostProcessGrayscale
	grayscale.visible = true
	var mat = grayscale.material as ShaderMaterial
	mat.set_shader_parameter("intensity", 0.0)
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/intensity", 1.0, duration)
