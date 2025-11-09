extends InteractionAction
class_name SceneChangeAction

@export var target_scene_path: String
@export var target_spawn_point_name: String

func execute(body: Node) -> void:
	if Dialogic.current_timeline != null:
		return

	GameState.scene_change_requested.emit(target_scene_path, target_spawn_point_name)
