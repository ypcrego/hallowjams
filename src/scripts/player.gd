extends CharacterBody2D


@export var speed:float = 100
@export var move_action:GUIDEAction
var can_move := true

@onready var sprite = $AnimatedSprite2D

@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
var footstep_delay: float = 0.3
var footstep_timer: float = 0.0
var tween: Tween


func _ready() -> void:
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(set_physics_process.bind(true))
	Dialogic.timeline_ended.connect(set_process_input.bind(true))

	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(arg : String) -> void:
	if arg == 'morreu':
		set_physics_process(false)
		set_process_input(false)
		_keep_animation()



func _on_timeline_started() -> void:
	set_process_input(false)
	set_physics_process(false)
	_keep_animation()


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

		if not footstep_player.playing:
			if tween:
				tween.kill()
			footstep_player.volume_db = -10  # começa suave
			footstep_player.play()
		else:
			# aumenta suavemente o volume enquanto anda
			footstep_player.volume_db = lerp(footstep_player.volume_db, 0.0, delta * 0.1)
	else:
		_fade_out_footsteps()
		_keep_animation()

	# Toca a animação, mas só se ela for diferente da atual para não reiniciar
	if sprite.animation != current_animation:
		sprite.play(current_animation)

	# 4. Finaliza o movimento do CharacterBody2D
	move_and_slide()

func _keep_animation() -> void:
	var current_animation = ""
	# Mantém a pose parada na última direção que estava
	if sprite.animation == "andando para frente" or sprite.animation == "parado frente":
		current_animation = "parado frente"
	elif sprite.animation == "andando para tras" or sprite.animation == "parado costas":
		current_animation = "parado costas"
	else:
		# Padrão para "Lado" se não tinha um estado definido ou estava nos lados
		current_animation = "parado lado"
		# O flip_h deve ser mantido do último movimento lateral
	sprite.play(current_animation)

func _fade_out_footsteps():
	if footstep_player and footstep_player.playing:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(footstep_player, "volume_db", -40, 0.3)
		tween.finished.connect(footstep_player.stop)
