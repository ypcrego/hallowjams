extends SceneDialogueBase

@onready var colega = $ColegaDaRecepcao


func _ready():
	super._ready()

	if GameState.current_day != 1:
		colega.queue_free()
