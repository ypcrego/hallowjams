extends Area2D


# Importa as classes de Recurso para tipagem
const DoorConfigResource = preload("res://src/scripts/apartment_config.gd")

@onready var door_sprite: Sprite2D = $Sprite2D

@export var interact: GUIDEAction
# Estes agora são os valores padrão do TRES (se não houverem dados injetados)
@export var door_tileset_texture: Texture2D = preload("res://src/assets/tileset/Inside_E.png")
@export var door_texture_region: Rect2 = Rect2(692, 635, 48, 85)

# Variáveis que serão preenchidas pelos dados injetados
var door_config: DoorConfigResource = null
@export var action: InteractionAction = null

var player: Node2D = null
var player_in_range = false


func _ready() -> void:
	interact.triggered.connect(handle_door_interaction)

	if door_config == null:
		call_deferred("setup_door_sprite")

func init_with_config(config: DoorConfigResource) -> void:
	self.apartment_config = config
	self.action = config.delivery_action

	# 2. Sobrescreve as propriedades visuais com os dados do Recurso.
	self.door_tileset_texture = config.door_tileset_texture
	self.door_texture_region = config.door_texture_region

	call_deferred("setup_door_sprite")

# Função para configurar o sprite a qualquer momento
func setup_door_sprite():
	# Garante que o nó do sprite é válido (pois estamos usando @onready)
	if not is_instance_valid(door_sprite):
		push_error("Sprite da porta não está disponível.")
		return


	# 1. Verifica se a textura e a região estão definidas.
	if door_tileset_texture:
		door_sprite.texture = door_tileset_texture
		door_sprite.region_enabled = true
		door_sprite.region_rect = door_texture_region
	else:
		door_sprite.texture = null
		door_sprite.region_enabled = false


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
