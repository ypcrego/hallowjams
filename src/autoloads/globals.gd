extends Node

# What goes into globals.gd?
# If the function depends on the something in the game, it's a global.
# If it's independent, it (probably) belongs in utils.gd

# Variável para reter a cena atual temporariamente
var current_scene_node: Node = null

## Use UI/MessageBox to display a status update message to the player
@warning_ignore("unused_signal")
signal post_ui_message(text: String)

## Emitted by UI/Controls when a action is remapped
@warning_ignore("unused_signal")
signal controls_changed(config: GUIDERemappingConfig)

func _ready():
	# Conecta o sinal de requisição da porta a esta função de manuseio.
	GameState.scene_change_requested.connect(_handle_scene_transition)

func _handle_scene_transition(scene_path: String, spawn_point_name: String):
	print('hii') # AGORA SERÁ CHAMADO E O PRINT VAI FUNCIONAR

	var old_scene = get_tree().current_scene
	# O Player precisa ser um Singleton (Autoload) ou ser o 'current_scene'
	# Se ele for um Singleton, use a referência Singleton.
	var player = old_scene.find_child("Player", true, false)

	# 1. Carrega a nova cena
	var new_scene = load(scene_path).instantiate()

	# 3. Encontra o ponto de spawn (a outra porta) na nova cena
	var spawn_point = new_scene.find_child(spawn_point_name, true, false)
	print(spawn_point)

# --- Reparentamento e Posicionamento Garantido ---
	if player and spawn_point:
		# A. Remove o Player da cena antiga
		old_scene.remove_child(player)

		# B. Adiciona a nova cena na SceneTree e a define como ativa
		get_tree().root.add_child(new_scene)
		get_tree().current_scene = new_scene

		# C. Adiciona o Player à nova cena (como filho da nova cena)
		new_scene.add_child(player)

		# D. Define a Posição Global de forma ADIADA e CORRETA

		# A LINHA MÁGICA: Executa o posicionamento no próximo frame seguro
		# Garante que todos os transforms (TileMap, Marker2D) estejam aplicados.
		await get_tree().physics_frame

		# Offset para alinhar os pés do jogador (mantendo 16px)
		var vertical_offset = 16

		# USAR GLOBAL_POSITION é sempre mais seguro após reparentamento
		var target_global_position = spawn_point.global_position + Vector2(0, vertical_offset)

		# Configura a posição do Player na nova hierarquia
		player.global_position = target_global_position

		# Removi: player.position = target_position (para usar global_position no lugar)

	# 5. Libera a cena antiga
	if old_scene:
		old_scene.queue_free()

	print("Transição concluída para: %s, Spawn point: %s" % [scene_path, spawn_point_name])
