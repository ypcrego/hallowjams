extends SceneDialogueBase

@onready var colega = $Colega

var signal_falas_emitted = false
var signal_mov_emitted = false

func _ready():
	super._ready()

	if GameState.current_day != 3 and GameState.colega_terminou_todas_falas:
		colega.queue_free()
	if GameState.current_day == 3:
		colega.queue_free()

	else:
		colega.terminou_movimento.connect(_on_colega_terminou_movimento)
		Dialogic.signal_event.connect(_on_colega_terminou_todas_falas)


func _on_colega_terminou_todas_falas(arg : String):
	if arg == 'terminou_todas_falas':
		print('falas terminadas true')
		GameState.colega_terminou_todas_falas = true
		signal_falas_emitted = true
		_check_signals()


func _on_colega_terminou_movimento():
	signal_mov_emitted = true
	print('mov emitted true')
	_check_signals()

func _check_signals():
	if signal_falas_emitted and signal_mov_emitted:
		print('queued')
		colega.queue_free()
