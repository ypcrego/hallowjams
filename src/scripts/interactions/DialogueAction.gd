extends InteractionAction
class_name DialogueAction

@export var dialogue_id: String
var style: DialogicStyle = load("res://src/data/dialogic/custom_syle.tres")

func execute(body: Node) -> void:
	style.prepare()

	if Dialogic.current_timeline != null:
		return

	Dialogic.start(dialogue_id)
