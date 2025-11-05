extends CharacterBody2D


@export var speed:float = 100
@export var move_action:GUIDEAction


func _ready() -> void:
	print("a")
	# Ativa o mapeamento de entrada uma vez quando o Player aparecedwq

func _process(delta:float):
	# Get the input value from the action and move the player.
	position += move_action.value_axis_2d * speed * delta

#func _physics_process(delta) -> void:
#	position = move_action.value_axis_2d * SPEED


# --- FUNÇÃO DE INTERAÇÃO (Será usada na ETAPA 3) ---
# A lógica principal de 'interact' será tratada pelas áreas de colisão
# (Area2D - Desk e Door) para manter o Player.gd simples.
# func _input(event):
#     if event.is_action_pressed("interact"):
#         # (A lógica de interação será codificada nos scripts Desk_Interaction.gd e Door.gd)
#         pass
