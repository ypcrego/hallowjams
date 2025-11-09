extends CharacterBody2D


@export var speed:float = 100
@export var move_action:GUIDEAction
var can_move := true

func _ready() -> void:
	Dialogic.timeline_started.connect(set_physics_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))
	Dialogic.timeline_ended.connect(set_physics_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))




func _physics_process(delta) -> void:
	velocity = move_action.value_axis_2d * speed
	move_and_slide()




# --- FUNÇÃO DE INTERAÇÃO (Será usada na ETAPA 3) ---
# A lógica principal de 'interact' será tratada pelas áreas de colisão
# (Area2D - Desk e Door) para manter o Player.gd simples.
# func _input(event):
#     if event.is_action_pressed("interact"):
#         # (A lógica de interação será codificada nos scripts Desk_Interaction.gd e Door.gd)
#         pass
