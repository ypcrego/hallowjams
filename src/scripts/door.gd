extends Area2D

# Exporte o caminho da cena de destino e o nome do ponto de spawn
# (Isso permite configurar a porta no editor, e.g., 'Porta do Armazém' -> 'Recepção', 'Start_From_Armazem')
@export var target_scene_path: String
@export var target_spawn_point_name: String

@export var door_tileset_texture: Texture2D

@export var door_texture_region: Rect2 = Rect2(0, 0, 32, 32) # Exemplo: 32x32 pixels

@onready var door_sprite: Sprite2D = $Sprite2D

@export var interact:GUIDEAction

var player_in_range = false


func _ready() -> void:

	# 1. Verifica se a textura e a região estão definidas.
	if door_tileset_texture:
		door_sprite.texture = door_tileset_texture
		door_sprite.region_enabled = true # Habilita o recorte
		door_sprite.region_rect = door_texture_region # Aplica o retângulo de recorte

	# 2. Conecta sinais de transição, etc.
	interact.triggered.connect(handle_door_interaction)


func handle_door_interaction():
	if player_in_range:
		print("interagiu")
		#GameState.next_spawn_point_name = target_spawn_point_name
		# Emite o sinal para o gerenciador de cenas (`main.gd`)
		GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)


# Opção 1: Interação (mais comum para jogos Top-Down)
# Adicione um nó CollisionShape2D e uma Area2D (sua porta)
#func _on_door_interacted(body: Node2D):
	# Verifica se o corpo é o jogador (baseado no nome do nó ou grupo)
#	if body.name == "Player":
		# Define a próxima posição de entrada (importante para o retorno)
#		GameState.next_spawn_point_name = target_spawn_point_name

		# Emite o sinal para o gerenciador de cenas (`main.gd`)
#		GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)

# Opção 2 (Se for baseado em colisão simples, substitua o método acima)
func _on_body_entered(body: Node2D):
	if body.name == "Player":
		player_in_range = true
		print("👣 Jogador perto da porta. Pressione E para entrar.")
#	if body.name == "Player":
#		GameState.next_spawn_point_name = target_spawn_point_name
#		GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
