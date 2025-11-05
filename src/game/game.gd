extends Node2D
# This scene is started by clicking the "Play" button in main.tscn.
# Change Project Settings: application/run/start_scene to game/game.tscn to skip the menus while developing

# TODO: Create your game beginning here
@export var mapping_context:GUIDEMappingContext


func _ready() -> void:
	GUIDE.enable_mapping_context(mapping_context)
	if not $UI.is_preset_ready:
		await $UI.preset_ready
	$UI.show_ui("Game")
