extends AudioStreamPlayer

# É bom ter uma referência para que você possa chamá-lo de qualquer lugar se for preciso
# Por exemplo: MusicManager.play_music()

# Defina a música para tocar assim que o nó estiver pronto
func _ready():
	# Certifique-se de ter um arquivo de música atribuído no inspetor
	# e com a opção 'Autoplay' desativada para controlarmos a partir daqui.
	if stream:
		play()

# Funções auxiliares (opcional) para controle fácil no jogo
func stop_music():
	stop()

func play_music():
	if not playing:
		play()
