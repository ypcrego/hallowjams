extends AudioStreamPlayer

@export var music_bus_name: String = "Music"
var music_bus_index: int = -1

const MUSIC_MAP = {
	"bgm": "res://src/assets/sounds/bgm/Mind's Eye Full.wav",
}

# A função de inicialização pode permanecer a mesma ou tocar um tema padrão
func _ready():
# 1. Tenta obter o índice do Bus de Áudio a partir do nome
	music_bus_index = AudioServer.get_bus_index(music_bus_name)
	AudioServer.set_bus_volume_db(music_bus_index, -10)

	if music_bus_index == -1:
		# ⚠️ Se você vir este erro, verifique se o nome do bus está correto no Inspetor
		push_error("ERRO: Bus de Áudio não encontrado: '", music_bus_name, "'.")
	else:
		# Define explicitamente o AudioStreamPlayer para usar o Bus
		bus = music_bus_name

	if stream:
		play_new_music(stream, true)

# Função atualizada para aceitar o CAMINHO COMPLETO DO RECURSO (Resource Path)
# Mantida para compatibilidade, mas não será usada diretamente pelo Dialogic.
func play_new_music(new_music_stream: AudioStream, start_from_beginning: bool = true):
	if stream != new_music_stream:
		stop()
		stream = new_music_stream

	if stream and (not playing or start_from_beginning):
		play()

# NOVA FUNÇÃO: O "Proxy" que o Dialogic chamará
# Recebe a chave da música, busca o caminho e toca.
func change_music_by_name(music_name: String):
	# 1. Verifica se o nome da música existe no mapa
	if not MUSIC_MAP.has(music_name):
		push_error("Erro: Música com a chave '", music_name, "' não encontrada no MUSIC_MAP.")
		return

	var music_path = MUSIC_MAP[music_name]

	# 2. Carrega o recurso. O 'load' é mais rápido se o recurso já estiver na memória.
	var new_music = load(music_path)

	# 3. Verifica se o recurso é um AudioStream válido
	if new_music is AudioStream:
		# 4. Chama a função de reprodução com o recurso de áudio
		play_new_music(new_music)
	else:
		push_error("Erro: Não foi possível carregar o AudioStream em: ", music_path)

# PASSO 2: Nova função para controlar o volume do Bus.
# Isso afeta TODOS os sons nesse Bus (incluindo o MusicManager e qualquer outro nó configurado para ele).
func set_music_bus_volume_db(db: float):
	"""
	Define o volume do Bus de Áudio da música em decibéis (dB).
	Valores comuns: 0.0 (volume normal/máximo), -10.0 (reduzido), -80.0 (silêncio).
	"""
	if music_bus_index != -1:
		AudioServer.set_bus_volume_db(music_bus_index, db)
	else:
		push_warning("Aviso: O Bus de Áudio da música não foi encontrado. Não é possível definir o volume.")

# Funções auxiliares (opcional) para controle fácil no jogo
func stop_music():
	stop()

func play_music():
	if not playing and stream:
		play()
