extends Node2D
class_name SceneDialogueBase

func _ready():
	_check_and_run_dialogue()


func _check_and_run_dialogue():
	# 1. Obtém a chave da cena de forma dinâmica (ex: "reception")
	var current_scene_key = _get_scene_key()
	if current_scene_key.is_empty():
		return

	var day_data = GameState.current_day_data
	print ("DAY DATA : ", day_data)

	# NOVO PASSO: Verifica se o diálogo JÁ foi executado HOJE (ou nesta sessão/dia)
	if GameState.completed_scene_intros.has(current_scene_key):
		print("LOG: Diálogo de introdução para ", current_scene_key, " já foi concluído hoje.")
		return # Já foi visto, então sai.

	if !is_instance_valid(day_data):
		push_error("ERRO: Nenhum 'DayData' válido encontrado para o dia atual.")
		return

	# 2. Verifica se há um diálogo mapeado para a cena neste dia
	if day_data.auto_start_dialogues.has(current_scene_key):
		var dialogue_id = day_data.auto_start_dialogues[current_scene_key]
		print("ID DO DIALOGO : ", dialogue_id)

		# 3. Inicia o diálogo
		Dialogic.start(dialogue_id)

		# NOVO PASSO: Marca o diálogo como concluído no estado do jogo
		GameState.completed_scene_intros[current_scene_key] = true

		print("LOG: Iniciando diálogo automático para a cena: ", current_scene_key)

# ... (mantenha a função _get_scene_key() aqui)
func _get_scene_key() -> String:
	var path = scene_file_path
	if path.is_empty():
		push_error("ERRO: O nó não é a raiz de uma cena salva (.tscn). Não é possível obter a chave da cena.")
		return ""
	var file_name_with_extension = path.get_file()
	return file_name_with_extension.get_basename()
