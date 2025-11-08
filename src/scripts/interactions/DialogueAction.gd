extends InteractionAction
class_name DialogueAction

@export var dialogue_id: String

func execute(body: Node) -> void:
	if Dialogic.current_timeline != null:
		return

	Dialogic.start(dialogue_id)
