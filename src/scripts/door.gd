extends Area2D

@export var door_tileset_texture: Texture2D
@export var door_texture_region: Rect2 = Rect2(0, 0, 32, 32)
@onready var door_sprite: Sprite2D = $Sprite2D

@export var interact:GUIDEAction
@export var action: InteractionAction

var player: Node2D = null
var player_in_range = false


func _ready() -> void:
	setup_door_sprite()

	# 2. Conecta sinais de transição, etc.
	interact.triggered.connect(handle_door_interaction)

# NOVO: Função para configurar o sprite a qualquer momento
func setup_door_sprite():
	# 1. Verifica se a textura e a região estão definidas.
	if door_tileset_texture:
		door_sprite.texture = door_tileset_texture
		door_sprite.region_enabled = true
		door_sprite.region_rect = door_texture_region

		# Se você tiver uma collision shape de sprite, pode querer atualizá-la aqui
		# Ex: door_sprite.set_texture_filter(CanvasItem.TEXTURE_FILTER_NEAREST)

func handle_door_interaction():
	print("aa")
	if player_in_range:
		print("interagiu")
		#GameState.next_spawn_point_name = target_spawn_point_name
		# Emite o sinal para o gerenciador de cenas (`main.gd`)
		action.execute(player)
		#GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)


# Opção 1: Interação (mais comum para jogos Top-Down)
# Adicione um nó CollisionShape2D e uma Area2D (sua porta)
#func _on_door_interacted(body: Node2D):
	# Verifica se o corpo é o jogador (baseado no nome do nó ou grupo)
#	if body.name == "Player":
		# Define a próxima posição de entrada (importante para o retorno)
#		GameState.next_spawn_point_name = target_spawn_point_name

		# Emite o sinal para o gerenciador de cenas (`main.gd`)
#		GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)

func _on_proximity_sensor_body_entered(body: Node2D) -> void:
	print("testando")
	if body.is_in_group("Player"):
		player = body
		player_in_range = true
		print("👣 Jogador perto da porta. Pressione E para entrar.")
#	if body.name == "Player":
#		GameState.next_spawn_point_name = target_spawn_point_name
#		GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)

func _on_proximity_sensor_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_in_range = false
