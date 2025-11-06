extends UiPage

# TODO: Add a title and/or background art to main_menu.tscn

func _ready() -> void:
	call_deferred("_connect_buttons")
	if OS.get_name() == "Web":
		%Exit.hide()


func _connect_buttons() -> void:
	if ui:
		%Play.pressed.connect(_start_game)
		%HowToPlay.pressed.connect(ui.go_to.bind("HowToPlay"))
		%Settings.pressed.connect(ui.go_to.bind("Settings"))
		%Controls.pressed.connect(ui.go_to.bind("Controls"))
		%Credits.pressed.connect(ui.go_to.bind("Credits"))
		%Exit.pressed.connect(get_tree().call_deferred.bind("quit"))


func _start_game() -> void:
	# O nó 'ui' (CanvasLayer) é uma propriedade injetada do UiPage.
	# O pai de 'ui' é o nó 'Main' (onde está src/main.gd).
	var main_node = ui.get_parent()
	if main_node and main_node.has_method("start_initial_game"):
		# Chama a função no script principal para iniciar o jogo sem descarregar a cena principal.
		main_node.start_initial_game()
	else:
		# Se o fluxo estiver errado, o antigo código tentaria trocar a cena, quebrando a persistência
		# TODO: Considerar adicionar alguma transição de cena (isso deve ser feito no Main.gd antes de load_scene)
		get_tree().change_scene_to_file("res://src/game/game.tscn")

	# TODO: Consider adding some kind of scene transition
	#get_tree().change_scene_to_file("res://src/game/game.tscn")
	#if ui:
		#ui.go_to("Game")
	#get_tree().paused = false
