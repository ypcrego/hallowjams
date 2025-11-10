extends Node2D

func _ready():

	print("LOG: Cena da Kitnet carregada. ")
	pass

func start_sleep_sequence():
	# 1. Calcule dinamicamente o nome da timeline do sono (FIM DO DIA N)
	var sleep_dialogue_timeline: String = "sleep_day_" + str(GameState.current_day)
	print("LOG: Iniciando diálogo de sono para o dia: ", GameState.current_day, " (Timeline: ", sleep_dialogue_timeline, ")")

	# 2. Conecta o sinal para avançar para o PRÓXIMO diálogo quando o sono terminar.
	_connect_sleep_signal()

	var main_node = get_tree().get_first_node_in_group("Main")

	# 🚨 NOVO: Inicia o Fade In (Revelar a cena)
	if main_node:
		await main_node.fade_out(1.5) # Aguarda a tela revelar a cena (1.5s)

	# 3. Inicia o diálogo de descanso/sono.
	Dialogic.start(sleep_dialogue_timeline)

# Conexão específica para o diálogo de sono
func _connect_sleep_signal():
	if Dialogic.is_connected("timeline_ended", Callable(self, "_on_sleep_dialogue_ended")):
		Dialogic.disconnect("timeline_ended", Callable(self, "_on_sleep_dialogue_ended"))
	Dialogic.connect("timeline_ended", Callable(self, "_on_sleep_dialogue_ended"))


# Chamado quando o PRIMEIRO diálogo (sono) termina.
func _on_sleep_dialogue_ended():
	print("acabou o soninho")

	# Desconecta o sinal atual
	Dialogic.disconnect("timeline_ended", Callable(self, "_on_sleep_dialogue_ended"))

	var main_node = get_tree().get_first_node_in_group("Main")
	await main_node.fade_in(0.5)

	# 1. Define o nome da timeline do NOVO diálogo (começo do dia N+1)
	var next_day_number = GameState.current_day + 1
	var new_day_dialogue_timeline: String = "new_day_" + str(next_day_number)

	GameState.advance_day()

	print("LOG: Fim do sono. Próxima: Diálogo de novo dia para o dia: ", next_day_number, " (Timeline: ", new_day_dialogue_timeline, ")")
