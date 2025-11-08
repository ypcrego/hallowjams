# src/game/ApartmentHall.gd
extends Node2D

@export var scene_id: String = "HALL_DEFAULT" # Ex: "HALL_100", "HALL_200"
## Lista de todos os objetos decorativos na cena que podem variar.
## Preencha esta lista no Inspector com os nós Sprite2D ou Marker2D.
@export var decorative_objects: Array[Node2D]

@export var floor_data: FloorData
var door_scene: PackedScene = preload("res://src/game/Door.tscn")
# Usado para garantir que a variação visual seja a mesma se o jogador sair e voltar
var current_day_seed: int = 0

# (Remova a lógica 'unique_visit_dialogues' e 'current_scene_path' se o GameState gerenciar a primeira visita)
# Dicionário que mapeia um número de apt para um ID de diálogo de "primeira visita".
#@export var unique_visit_dialogues: Dictionary = {
#	"101": "APT_101_FIRST_VISIT_DIALOGUE",
#	"202": "APT_202_FIRST_VISIT_DIALOGUE",
#}
# Caminho completo da cena atual (definido em GameState)
#var current_scene_path: String = ""


func _ready():
	# Garantir que a seed seja consistente por dia
	current_day_seed = GameState.current_day

	var unique_seed = hash(str(current_day_seed) + scene_id)
	# Aplica as variações visuais
	_apply_visual_variations(unique_seed)

	_build_doors()

	# Dispara o diálogo de "primeira vez" (se houver)
	_check_and_trigger_first_visit_dialogue()


# --- Lógica de Variação Visual (Função Adaptada) ---

func _apply_visual_variations(seed: int):
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	print("Aplicando variações visuais com seed: ", seed)

	for object_node in decorative_objects:
		# Exemplo 1: Movimento sutil (para todos os objetos)
		var offset_x = rng.randi_range(-4, 4)
		var offset_y = rng.randi_range(-4, 4)
		object_node.position.x += offset_x
		object_node.position.y += offset_y

		# Exemplo 2: Ocultar/Mostrar um objeto específico (ex: uma mancha na parede)
		if object_node.name.to_lower().contains("mancha"):
			object_node.visible = rng.randf() < 0.2 # 20% de chance de aparecer

		# Adicione mais regras de variação aqui (cores, sprites etc.)

# --- Lógica de Diálogo Único por CENA ---
func _build_doors():
	if not floor_data:
		push_error("FloorData não está definido para este ApartmentHall.")
		return

	# Limpa portas antigas (se for reusado)
	for child in $Doors.get_children(): # Supondo que você crie um nó 'Doors' Node2D
		child.queue_free()

	for door_data in floor_data.doors:
		var door_instance = door_scene.instantiate()
		$Doors.add_child(door_instance)

		# 3. Posição e Z-index
		door_instance.position = door_data.position
		door_instance.z_index = door_data.z_index_offset

		# 4. Ação de Interação e Configuração Visual
		door_instance.action = door_data.delivery_action
		door_instance.door_texture_region = door_data.door_texture_region
		# (O door_instance.door_tileset_texture, se necessário, pode ser
		# carregado aqui ou no Door.gd se for estático.)

		# O Door.gd usa a propriedade 'action' para interagir.
		# Você deve garantir que a Door.tscn é uma Area2D.

		# O script ApartmentDeliveryAction já tem o apartment_number
		# (Você precisa garantir que o Door.tscn tenha um nó 'Sprite2D' ou similar)



func _check_and_trigger_first_visit_dialogue():
	# O SceneManager (se houver) deve definir a v ariável `current_scene_path` no GameState.
	# Usamos o caminho da cena como um ID único.
	var scene_id = GameState.current_scene_path

	# Geramos uma chave única de estado: "visitado_hall_do_dia_N"
	var visited_flag = "visited_hall_day_" + str(GameState.current_day)

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
	if GameState.current_day == 1 and scene_id == GameState.RECEPTION_SCENE_PATH:
		# Exemplo: um diálogo curto de introdução ao entrar na recepção
		# Dialogic.start("RECEPTION_INTRO_DAY_1")
		pass # Deixamos a lógica de diálogo mais complexa para o GameState/Interactions
