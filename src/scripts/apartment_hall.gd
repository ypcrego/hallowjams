# src/game/ApartmentHall.gd
extends Node2D

const FloorData = preload("res://src/scripts/floor_data.gd")
const DOOR_SCENE: PackedScene = preload("res://src/game/Door.tscn")
const DoorPlaceholder = preload("res://src/scripts/DoorPlaceholder.gd")

@export var floor_data: FloorData = null

@onready var _tile_map = $TileMap
@onready var _elevator_door = $Door_To_Elevator

# 2. VARIÁVEL INTERNA: A seed agora é derivada do FloorData
var current_hall_seed: int = 0

func _ready():
	if floor_data == null:
		push_error("ERRO: O FloorData não foi injetado na cena Hall.tscn!")
		return

	# Garantir que a seed seja consistente por dia
	current_hall_seed = hash(str(GameState.current_day) + str(floor_data.unique_floor_id))

	if floor_data and floor_data.decorative_objects.size() > 0:
		_apply_visual_variations(current_hall_seed, floor_data.decorative_objects)

	_build_doors()

	# Dispara o diálogo de "primeira vez" (se houver)
	_check_and_trigger_first_visit_dialogue()


# --- Lógica de Variação Visual (Função Adaptada) ---

func _apply_visual_variations(seed: int, objects_paths: Array[NodePath]):
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	print("Aplicando variações visuais com seed: ", seed)

	# Itera sobre os CAMINHOS DOS NÓS
	for object_path in objects_paths:
		# Usar get_node() para obter o objeto real
		var object_node = get_node(object_path)

		if not is_instance_valid(object_node) or not object_node is Node2D:
			push_warning("Caminho de nó inválido ou tipo incorreto em FloorData: " + str(object_path))
			continue # Pula para o próximo

		# Exemplo 1: Movimento sutil (para todos os objetos)
		var offset_x = rng.randi_range(-4, 4)
		var offset_y = rng.randi_range(-4, 4)
		object_node.position.x += offset_x
		object_node.position.y += offset_y

		# Exemplo 2: Ocultar/Mostrar um objeto específico
		if object_node.name.to_lower().contains("mancha"):
			object_node.visible = rng.randf() < 0.2


# --- Lógica de Diálogo Único por CENA ---
# --- Lógica de Construção de Portas (CORRIGIDA) ---
func _build_doors():
	print('Iniciando construção de portas a partir dos Placeholders')
	var doors_container = get_node("Doors")
	if not is_instance_valid(doors_container):
		push_error("ApartmentHall precisa de um nó 'Doors' Node2D para o container.")
		return

	for child in doors_container.get_children():
		child.queue_free()


	# Itera sobre os NÓS (Marker2D) que você posicionou na cena
	for placeholder in doors_container.get_children():

		# 1. Checa se o nó tem o script DoorPlaceholder anexado
		if not placeholder is DoorPlaceholder:
			push_warning("Nó não-Placeholder encontrado no container 'Doors': " + placeholder.name + ". Pulando.")
			continue

		var apartment_config = placeholder.apartment_config

		if apartment_config == null:
			push_warning("Placeholder '"+ placeholder.name +"' sem ApartmentConfig. Pulando.")
			continue

		var door_instance = DOOR_SCENE.instantiate()
		doors_container.add_child(door_instance)

		# 2. POSICIONAMENTO: Obtido diretamente do nó Marker2D da cena!
		door_instance.global_position = placeholder.global_position
		door_instance.z_index = placeholder.z_index

		# 3. INICIALIZAÇÃO: Injeta o recurso de comportamento
		door_instance.init_with_config(apartment_config)

		# 4. LIMPEZA: O nó Placeholder (Marker2D) não é mais necessário
		placeholder.queue_free()

	print("FIM DA CONSTRUÇÃO: Portas adicionadas.")


func _check_and_trigger_first_visit_dialogue():
	# Use um ID baseado no FloorData para consistência
	var hall_id = floor_data.hall_dialogue_id # Ex: "HALL_100_INTRO"

	# Lógica de diálogo (que agora usa o ID genérico do recurso)
	var visited_flag = "visited_" + hall_id + "_day_" + str(GameState.current_day)

	# Esta é uma simulação de como você usaria o Dialogic Global Vars.
	# Se você não tem um sistema de variáveis globais, use o GameState para armazenar flags.

	# Se você estiver usando o Dialogic Variables (Dialogic.set_variable, Dialogic.get_variable):
	# if Dialogic.get_variable(visited_flag) != true:
	# 	Dialogic.set_variable(visited_flag, true)
	# 	Dialogic.start("HALL_INTRO_DIALOGUE_DAY_" + str(GameState.current_day))

	# Para o MVP, se você não tem um sistema de save/variáveis,
	# você pode usar a abordagem mais simples, iniciando um diálogo na primeira vez
	# que a cena carrega no dia:

	# CUIDADO: Este é um exemplo, se você não tem um flag de "visitado", ele pode tocar toda vez que a cena for recarregada!
	#if GameState.current_day == 1 and scene_id == GameState.RECEPTION_SCENE_PATH:
		# Exemplo: um diálogo curto de introdução ao entrar na recepção
		# Dialogic.start("RECEPTION_INTRO_DAY_1")
		#pass # Deixamos a lógica de diálogo mais complexa para o GameState/Interactions
