extends CharacterBody2D
class_name NpcColega

@export var npc_dialogue_key: String = "DIA_1_NPC_COLEGA"
@onready var sprite = $AnimatedSprite2D
@onready var area_interacao = $Area2D
@onready var agent = $NavigationAgent2D

signal terminou_movimento


const SPEED = 50.0

enum Estado {
	PARADO,
	MOVENDO_PARA_PONTO,
	AGUARDANDO_INTERACAO
}

var estado_atual: Estado = Estado.AGUARDANDO_INTERACAO
var player_na_area: bool = false
var target_position: Vector2 = Vector2.ZERO
var direcao_atual := "frente"

func _ready():
	if is_instance_valid(area_interacao):
		area_interacao.body_entered.connect(_on_area_2d_body_entered)
		area_interacao.body_exited.connect(_on_area_2d_body_exited)
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	match estado_atual:
		Estado.PARADO, Estado.AGUARDANDO_INTERACAO:
			velocity = Vector2.ZERO
		Estado.MOVENDO_PARA_PONTO:
			_handle_movement_to_target(delta)

	# 👇 Atualiza primeiro a animação
	_atualizar_animacao()

	# 👇 Depois move e atualiza a velocidade real
	move_and_slide()

# 💬 Recebe os sinais enviados pelo Dialogic
func _on_dialogic_signal(argument: String):
	print("[DEBUG] Sinal do Dialogic recebido:", argument)

	# Remove possíveis espaços
	argument = argument.strip_edges()

	# Separa por vírgula
	var args = argument.split(",")

	# Pega o primeiro argumento e trata possíveis prefixos "NomeDoNPC."
	var comando = args[0]
	if comando.contains("."):
		comando = comando.split(".")[-1]  # pega só a última parte, ex: mover_para

	print("[DEBUG] Comando interpretado:", comando)

	# Verifica se é o comando de movimento
	if comando == "mover_para" and args.size() >= 3:
		var x = float(args[1])
		var y = float(args[2])
		print("[DEBUG] Chamando mover_para com:", x, y)
		mover_para(x, y)

func _handle_movement_to_target(delta):
	if not is_instance_valid(agent):
		return

	# Atualiza o destino do agente se mudou
	if agent.target_position != target_position:
		agent.target_position = target_position

	# Se chegou
	if agent.is_navigation_finished():
		print("me mata me mata me mate ma me tmaetma")
		emit_signal("terminou_movimento")
		mudar_estado(Estado.AGUARDANDO_INTERACAO)
		velocity = Vector2.ZERO
		return

	# Move-se em direção ao próximo ponto do caminho
	var next_path_position = agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	velocity = direction * SPEED

	move_and_slide()

	# Atualiza a direção visual
	if abs(direction.x) > abs(direction.y):
		direcao_atual = "lado"
		sprite.flip_h = direction.x > 0
	elif direction.y < 0:
		direcao_atual = "costa"
	else:
		direcao_atual = "frente"


func _input(event):
	if player_na_area and estado_atual != Estado.MOVENDO_PARA_PONTO:
		if Input.is_action_just_pressed("interagir"):
			if not Dialogic.is_running():
				iniciar_dialogo_npc()

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_na_area = true

func _on_area_2d_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_na_area = false

func iniciar_dialogo_npc():
	var dialogue_key = npc_dialogue_key
	if GameState.completed_scene_intros.has(dialogue_key):
		Dialogic.start("COLEGA_FALA_REPETIDA")
		return
	Dialogic.start(dialogue_key)
	GameState.completed_scene_intros[dialogue_key] = true

func mover_para(x: float, y: float):
	print("[DEBUG] mover_para chamado com:", x, y)
	target_position = Vector2(x, y)
	print("[DEBUG] target_position definida para:", target_position)
	mudar_estado(Estado.MOVENDO_PARA_PONTO)
	print("[DEBUG] Estado atual:", estado_atual)

func set_dialogue_key(new_key: String):
	npc_dialogue_key = new_key

func mudar_estado(novo_estado: Estado):
	estado_atual = novo_estado

func _atualizar_animacao():
	if not is_instance_valid(sprite):
		return

	if velocity.length() > 0:
		match direcao_atual:
			"lado":
				sprite.play("andando para os lados")
			"costa":
				sprite.play("andando para tras")
			_:
				sprite.play("andando para frente")
	else:
		match direcao_atual:
			"lado":
				sprite.play("parado lado")
			"costa":
				sprite.play("parado costa")
			_:
				sprite.play("parado frente")
