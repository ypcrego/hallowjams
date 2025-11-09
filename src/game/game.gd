extends SceneDialogueBase
# This scene is started by clicking the "Play" button in main.tscn.
# Change Project Settings: application/run/start_scene to game/game.tscn to skip the menus while developing

# TODO: Create your game beginning here
func _ready() -> void:
	super._ready()

	var persistent_ui = get_parent().get_parent().get_node("UI")

	if persistent_ui:
		# Acessa as propriedades do UI persistente
		if not persistent_ui.is_preset_ready:
			await persistent_ui.preset_ready
		persistent_ui.show_ui("Game") # "Game" é o nome da sub-cena do HUD
	else:
		push_error("Nó UI persistente não encontrado!")
	#if not $UI.is_preset_ready:
	#	await $UI.preset_ready
	#$UI.show_ui("Game")
