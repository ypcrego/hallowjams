# DialogueBox.gd
extends Control

# Variáveis exportadas para fácil ajuste no Inspector
@export var text_speed: float = 0.05 # Tempo de pausa entre cada letra
@export var character_name_node: Label = null # Nó 'name' para o nome do personagem
@export var dialogue_text_node: RichTextLabel = null # Nó 'Dialogue' para o texto principal
@export var faceset_node: TextureRect = null # Nó 'Faceset' para a imagem do personagem

# Fila de textos e nomes a serem exibidos (Exemplo de estrutura)
var dialogue_queue: Array = [
	{"name": "Gatinho Fofo", "text": "Olá! Que bom que você finalmente chegou. Eu estava te esperando!", "faceset_path": "res://assets/faces/gatinho_feliz.png"},
	{"name": "Jogador", "text": "Nossa, que surpresa! Você está com um coelhinho de pelúcia!", "faceset_path": "res://assets/faces/jogador_neutro.png"},
	{"name": "Gatinho Fofo", "text": "É meu amigo! Quer me fazer um carinho? Aperte [Enter]!", "faceset_path": "res://assets/faces/gatinho_sonolento.png"}
]

# Variáveis de estado
var is_writing: bool = false # Verifica se o texto está sendo escrito
var current_dialogue_index: int = 0 # Índice atual na fila de diálogos

# Sinal emitido quando a caixa de diálogo é fechada
signal dialogue_finished

# ----------------------------------------------------------------------
# FUNÇÃO READY: Configuração inicial
# ----------------------------------------------------------------------
func _ready():
	# Esconde a caixa de diálogo no início
	visible = false
	
	# Garante que os nós foram configurados (evita erros)
	if !character_name_node or !dialogue_text_node or !faceset_node:
		print("ERRO: Configure as variáveis 'character_name_node', 'dialogue_text_node' e 'faceset_node' no Inspector!")
		return
	
	# Inicia a conversa se houver textos na fila
	if not dialogue_queue.is_empty():
		start_dialogue()

# ----------------------------------------------------------------------
# FUNÇÃO DE PROCESSAMENTO: Leitura de entrada
# ----------------------------------------------------------------------
func _unhandled_input(event):
	# Se a caixa de diálogo estiver visível e a tecla de interação for pressionada
	if visible and event.is_action_pressed("ui_accept"): # 'ui_accept' é geralmente [Enter] ou [Space]
		if is_writing:
			# Se estiver escrevendo, avança para o texto completo
			finish_writing_text()
		else:
			# Se o texto já estiver completo, avança para o próximo diálogo
			go_to_next_dialogue()
		
		# Marca o evento como manipulado para não ser processado por outros nós
		get_tree().set_input_as_handled()

# ----------------------------------------------------------------------
# FUNÇÕES DE LÓGICA DO DIÁLOGO
# ----------------------------------------------------------------------

# Inicia a exibição da caixa de diálogo
func start_dialogue():
	visible = true
	current_dialogue_index = 0
	display_dialogue(dialogue_queue[current_dialogue_index])

# Exibe um único bloco de diálogo
func display_dialogue(data: Dictionary):
	# 1. Configura o nome do personagem
	character_name_node.text = data.get("name", "")
	
	# 2. Configura o faceset (imagem do personagem)
	var faceset_path = data.get("faceset_path", "")
	if not faceset_path.is_empty() and ResourceLoader.exists(faceset_path):
		# Carrega a imagem do faceset
		faceset_node.texture = load(faceset_path)
	else:
		faceset_node.texture = null # Ou defina uma textura padrão/vazia
	
	# 3. Inicia o efeito typewriter para o texto
	start_writing_text(data.get("text", ""))

# Função principal para o efeito typewriter
func start_writing_text(full_text: String):
	is_writing = true
	dialogue_text_node.text = "" # Limpa o texto antes de começar
	
	# Cria um Timer para controlar a velocidade da escrita
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = text_speed
	timer.one_shot = false # Repete até parar
	
	# Conecta o sinal 'timeout' do Timer a uma função
	timer.connect("timeout", func(): 
		# Adiciona o próximo caractere
		var next_char_index = dialogue_text_node.get_parsed_text().length()
		
		if next_char_index < full_text.length():
			# Adiciona o próximo caractere ao RichTextLabel
			var char_to_add = full_text[next_char_index]
			dialogue_text_node.append_text(char_to_add)
			# Nota: RichTextLabel usa append_text(), Label usa text +=
		else:
			# Terminou de escrever
			is_writing = false
			timer.stop()
			timer.queue_free() # Remove o Timer
	)
	
	timer.start()

# Força a exibição completa do texto
func finish_writing_text():
	if is_writing:
		is_writing = false
		# Pára e remove o Timer (assumindo que há apenas um Timer filho para escrita)
		for child in get_children():
			if child is Timer:
				child.stop()
				child.queue_free()
				break
		
		# Define o texto completo (RichTextLabel tem o método `set_bbcode` ou `text =`)
		# Se você estiver usando um RichTextLabel, certifique-se de usar o texto com BBCode, se aplicável
		dialogue_text_node.text = dialogue_queue[current_dialogue_index].get("text", "")

# Avança para o próximo bloco de diálogo
func go_to_next_dialogue():
	current_dialogue_index += 1
	
	if current_dialogue_index < dialogue_queue.size():
		# Ainda há mais diálogos na fila
		display_dialogue(dialogue_queue[current_dialogue_index])
	else:
		# Fim da conversa
		end_dialogue()

# Fecha a caixa de diálogo
func end_dialogue():
	visible = false
	# Emite o sinal para que o restante do jogo possa responder (ex: liberar o movimento do jogador)
	emit_signal("dialogue_finished")

# Função de exemplo para iniciar um novo diálogo a partir de outro script
func load_and_start_dialogue(new_dialogue_data: Array):
	dialogue_queue = new_dialogue_data
	current_dialogue_index = 0
	start_dialogue()
