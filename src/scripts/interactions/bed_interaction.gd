extends StaticBody2D
class_name BedInteraction

# Referência à ação de interação (ex: 'interact' do GUIDE)
@export var interact: GUIDEAction

var player_in_range = false
var _dialogic = null

# Referência ao script da Kitnet, que contém a lógica de diálogo encadeado.
# Assumimos que o script da Kitnet é o nó pai ou um nó facilmente acessível
@onready var kitnet_manager = get_parent()


func _ready():
	if interact:
		interact.triggered.connect(handle_bed_interaction)

# --- LÓGICA DE INTERAÇÃO ---

func handle_bed_interaction():
	if not player_in_range:
		return

	# 1. Verifica se o Dialogic está ativo (para não interromper algo)
	if Dialogic and Dialogic.current_timeline != null:
		return

	# 2. Requer que o dia de trabalho esteja de fato completo antes de dormir
	# Apenas permitimos dormir se não houver mais pacotes para entregar.
	if not GameState.is_day_task_complete():
		#_dialogic.start("not_all_packages_delivered") # **CRIE ESSA TIMELINE NO DIALOGIC** (Ex: "Ainda tenho entregas a fazer...")
		return

	# 3. Se o dia estiver completo, inicie a sequência de sono na Kitnet
	print("LOG: Interação com a cama bem-sucedida. Iniciando sequência de sono.")

	if kitnet_manager.has_method("start_sleep_sequence"):
		kitnet_manager.start_sleep_sequence()

	else:
		push_error("O script da Kitnet precisa da função 'start_sleep_sequence'.")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Certifique-se que o nome corresponde ao seu Player
		player_in_range = true
		print("PROMPT: Pressione E para descansar.")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
