extends Node2D

func _ready():

	# GARANTIA: Desconecta quaisquer conexões antigas (boa prática)
	if Dialogic.is_connected("timeline_ended", Callable(self, "_on_sleep_dialogue_ended")):
		Dialogic.disconnect("timeline_ended", Callable(self, "_on_sleep_dialogue_ended"))
	if Dialogic.is_connected("timeline_ended", Callable(self, "_on_new_day_dialogue_ended")):
		Dialogic.disconnect("timeline_ended", Callable(self, "_on_new_day_dialogue_ended"))

	print("LOG: Cena da Kitnet carregada. Aguardando interação com a cama.")
	pass

func start_sleep_sequence():
	# 1. Calcule dinamicamente o nome da timeline do sono (FIM DO DIA N)
	var sleep_dialogue_timeline: String = "sleep_day_" + str(GameState.current_day)
	print("LOG: Iniciando diálogo de sono para o dia: ", GameState.current_day, " (Timeline: ", sleep_dialogue_timeline, ")")

	# 2. Conecta o sinal para avançar para o PRÓXIMO diálogo quando o sono terminar.
	_connect_dialogic_signal("_on_sleep_dialogue_ended")

	# 3. Inicia o diálogo de descanso/sono.
	Dialogic.start(sleep_dialogue_timeline)

# Função auxiliar para conectar sinais, usando a referência segura _dialogic
func _connect_dialogic_signal(method_name: String):
	var callback = Callable(self, method_name)
	if Dialogic.is_connected("timeline_ended", callback):
		Dialogic.disconnect("timeline_ended", callback)
	Dialogic.connect("timeline_ended", callback)

# Função auxiliar para desconectar o sinal após o uso
func _disconnect_dialogic_signal(method_name: String):
	var callback = Callable(self, method_name)
	if Dialogic.is_connected("timeline_ended", callback):
		Dialogic.disconnect("timeline_ended", callback)

# Chamado quando o PRIMEIRO diálogo (sono) termina.
func _on_sleep_dialogue_ended():
	print("acabou o soninho")
	_disconnect_dialogic_signal("_on_sleep_dialogue_ended")

	# 1. Define o nome da timeline do NOVO diálogo (começo do dia N+1)
	var next_day_number = GameState.current_day + 1
	var new_day_dialogue_timeline: String = "new_day_" + str(next_day_number)

	print("LOG: Fim do sono. Próxima: Diálogo de novo dia para o dia: ", next_day_number, " (Timeline: ", new_day_dialogue_timeline, ")")

	# 2. Conecta o sinal para avançar o dia quando o NOVO diálogo terminar.
	_connect_dialogic_signal("_on_new_day_dialogue_ended")

	# 3. Inicia o diálogo de novo dia.
	Dialogic.start(new_day_dialogue_timeline)

# Chamado quando o SEGUNDO diálogo (novo dia) termina.
func _on_new_day_dialogue_ended():
	_disconnect_dialogic_signal("_on_new_day_dialogue_ended")

	print("LOG: Fim do diálogo de novo dia. Avançando para o Dia ", GameState.current_day + 1)

	# avança para o próximo dia (que mudará a cena para a Recepção)
	GameState.advance_day()
