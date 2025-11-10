extends AudioStreamPlayer

# O nome do Bus de SFX, defina-o no Inspetor (ex: "SFX" ou "SoundEffects")
@export var sfx_bus_name: String = "SFX"

const SFX_MAP = {
	"scare": "res://src/assets/sounds/sfx/scare.wav",
}

func _ready():
	# Define o Bus de áudio para este player (o que afetará todos os sons tocados por ele)
	var bus_index = AudioServer.get_bus_index(sfx_bus_name)
	if bus_index != -1:
		bus = sfx_bus_name
	else:
		push_error("ERRO: Bus de Áudio '", sfx_bus_name, "' para SFX não encontrado.")

# Função para tocar um som rapidamente.
# O Godot consegue lidar com a reprodução de vários sons em sequência neste player.
func play_sfx_once(audio_stream: AudioStream):
	# Se o player estiver ocupado tocando um som curto, ele é interrompido.
	# Para não interromper o som anterior, você pode usar 'AudioServer.play_bus_effect_instance(bus_index, audio_stream)'
	# ou criar um novo nó AudioStreamPlayer temporariamente (o que é mais caro).
	stream = audio_stream
	play()

# Versão que carrega o som a partir de um caminho (para uso em Dialogic/Call)
func play_sfx_by_name(sfx_name: String):
	var sfx_path = SFX_MAP[sfx_name]
	var sfx_stream = load(sfx_path)

	if sfx_stream is AudioStream:
		play_sfx_once(sfx_stream)
	else:
		push_error("Erro: Não foi possível carregar o SFX em: ", sfx_path)

# 💡 Função de controle de volume global do BUS (como no MusicManager)
func set_sfx_bus_volume_db(db: float):
	var index = AudioServer.get_bus_index(sfx_bus_name)
	if index != -1:
		AudioServer.set_bus_volume_db(index, db)
