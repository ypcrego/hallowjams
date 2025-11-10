extends Area2D
class_name NoteInteraction

# O nome da Timeline do Dialogic que deve ser iniciada
@export var timeline_name: String = "elevator_note_funcionarios" # <-- Configure isso no Inspetor

# Referência à ação de interação (GUIDEAction)
@export var interact_action: GUIDEAction # <-- Arraste seu recurso aqui no Inspetor

var player_in_range = false

func _ready():
	if interact_action:
		interact_action.triggered.connect(handle_interaction)

func handle_interaction():
	if not player_in_range:
		return
	if Dialogic.current_timeline != null:
		return
		
	if not timeline_name.is_empty():
		Dialogic.start(timeline_name)
		
	print("LOG: Diálogo da nota iniciado.")


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": 
		player_in_range = true
		# Se você tiver um nó para mostrar o prompt, ative-o aqui (ex: $PromptLabel.show())

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		# Se você tiver um nó para mostrar o prompt, esconda-o aqui (ex: $PromptLabel.hide())
