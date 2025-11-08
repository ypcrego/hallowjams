extends InteractionAction
class_name DialogueAction

@export var dialogue_id: String

func execute(body: Node) -> void:
	Dialogic.start(dialogue_id)
