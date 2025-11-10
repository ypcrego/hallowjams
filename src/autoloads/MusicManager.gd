extends AudioStreamPlayer

@export var music_bus_name: String = "Music"
var music_bus_index: int = -1

const FADE_TIME: float = 0.0 # Duração do fade em segundos (ajuste este valor!)
const MUTE_DB: float = -60.0 # Volume de silêncio (ou um valor bem baixo)
const DEFAULT_DB: float = 0.0 # Volume normal/máximo

var current_fade_tween: Tween = null

# Função para interpolar o volume do AudioStreamPlayer
func tween_volume(target_db: float, duration: float = FADE_TIME):
	# Para evitar conflitos, pare qualquer tween de fade anterior
	if current_fade_tween:
		current_fade_tween.kill()

	# Cria um novo Tween
	current_fade_tween = create_tween()
	# Interpola (anima) a propriedade volume_db
	# TRANS_LINEAR ou TRANS_SINE são boas opções para áudio
	current_fade_tween.tween_property(self, "volume_db", target_db, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	return current_fade_tween



const MUSIC_MAP = {
	"bgm": "res://src/assets/sounds/bgm/Mind's Eye Full.wav",
	"d2c": "res://src/assets/sounds/bgm/Day 2 Creepy.wav",
	"d2e": "res://src/assets/sounds/bgm/Day 2 Eerie.wav",
	"d3c": "res://src/assets/sounds/bgm/Day 3 Creepy.wav",
	"d3e": "res://src/assets/sounds/bgm/Day 3 Eerie.wav",
	"end": "res://src/assets/sounds/bgm/end.wav",
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
# NOVA FUNÇÃO: O "Proxy" que o Dialogic chamará
func change_music_by_name(music_name: String):
	# ... (Verificações de nome e carregamento do new_music - Mantenha este código)
	if not MUSIC_MAP.has(music_name):
		push_error("Erro: Música com a chave '", music_name, "' não encontrada no MUSIC_MAP.")
		return

	var music_path = MUSIC_MAP[music_name]
	var new_music = load(music_path)

	if new_music is AudioStream:
		# Se a música atual for diferente da nova, faça a transição
		if stream != new_music:
			# 1. FAZER FADE-OUT da música atual
			var fade_out_tween = tween_volume(MUTE_DB)

			# Conecta um 'callback' para quando o fade-out terminar
			# Só inicie a nova música APÓS o fade-out completo.
			fade_out_tween.tween_callback(Callable(self, "_start_new_music_with_fade_in").bind(new_music))
		else:
			# Se for a mesma música, apenas garanta que está tocando no volume normal
			tween_volume(DEFAULT_DB, 0.5)
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

# Chamada por um callback quando o fade-out estiver completo.
func _start_new_music_with_fade_in(new_music_stream: AudioStream):
	# 1. Interrompe a música antiga e define a nova
	stop() # Para o AudioStreamPlayer que agora está silencioso
	stream = new_music_stream

	# 2. Define o volume inicial como MUTE_DB (silêncio)
	volume_db = MUTE_DB

	# 3. Começa a tocar a nova música
	play()

	# 4. FAZER FADE-IN da nova música
	tween_volume(DEFAULT_DB, FADE_TIME)
