extends CharacterBody2D


@export var speed:float = 100
@export var move_action:GUIDEAction
var can_move := true

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	Dialogic.timeline_started.connect(set_physics_process.bind(false))
	Dialogic.timeline_started.connect(set_process_input.bind(false))
	Dialogic.timeline_ended.connect(set_physics_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))




func _physics_process(delta) -> void:
	# 1. Movimento
	# move_action.value_axis_2d é o input de movimento (vetor)
	var input_vector = move_action.value_axis_2d
	
	velocity = input_vector * speed
	
	# 2. Lógica da Animação
	var current_animation = ""
	
	if input_vector.length() > 0:
		# PERSONAGEM ESTÁ SE MOVENDO
		
		# Mapeamento do ângulo do vetor para as animações:
		# -Y (Cima) = Frente
		# +Y (Baixo) = Trás
		# -X / +X (Lados) = Lados
		
		# Se movendo para cima (Frente)
		if input_vector.y < 0 and abs(input_vector.y) > abs(input_vector.x):
			current_animation = "andando para tras"
		# Se movendo para baixo (Trás)
		elif input_vector.y > 0 and input_vector.y > abs(input_vector.x):
			current_animation = "andando para frente"
		# Se movendo para os lados (Diagonal ou Horizontal pura)
		else:
			current_animation = "andando para os lados"
			
			# 3. Gerenciamento do FLIP (Inverter a imagem para L/R)
			if input_vector.x < 0:
				sprite.flip_h = false  # Olhando para a esquerda
			elif input_vector.x > 0:
				sprite.flip_h = true # Olhando para a direita
				
	else:
		# PERSONAGEM ESTÁ PARADO
		
		# Mantém a pose parada na última direção que estava
		if sprite.animation == "andando para frente" or sprite.animation == "parado frente":
			current_animation = "parado frente"
		elif sprite.animation == "andando para tras" or sprite.animation == "parado costas":
			current_animation = "parado costas"
		else:
			# Padrão para "Lado" se não tinha um estado definido ou estava nos lados
			current_animation = "parado lado"
			# O flip_h deve ser mantido do último movimento lateral
			
	# Toca a animação, mas só se ela for diferente da atual para não reiniciar
	if sprite.animation != current_animation:
		sprite.play(current_animation)
	
	# 4. Finaliza o movimento do CharacterBody2D
	move_and_slide()
