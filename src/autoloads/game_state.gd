extends Node

# Sinais para notificar a UI ou outros scripts sobre mudanças
signal package_status_changed(is_holding: bool, target_ap: String)
# Disparado para que o 'main.gd' gerencie a troca de cena
signal scene_change_requested(scene_path: String, spawn_point_name: String)

var has_package: bool = false
var target_ap: String = ""
var day_count: int = 1 # Começa no dia 1

# Caminho da última cena visitada (útil para salvar/carregar)
var current_scene_path: String = "res://scenes/kitnet.tscn"
# Nome do nó Marker2D onde o jogador deve aparecer na NOVA cena.
var next_spawn_point_name: String = "Start_From_Bed"


# Atualiza o status do pacote e notifica os ouvintes
func set_package_status(is_holding: bool, ap: String) -> void:
	self.has_package = is_holding
	self.target_ap = ap
	package_status_changed.emit(is_holding, ap)

# Avança o dia, reiniciando o estado do pacote (novo dia = sem pacote)
func advance_day() -> void:
	day_count += 1
	set_package_status(false, "")

	# Solicita a mudança de cena para a Kitnet, entrando pelo ponto de spawn "Start_From_Door_Back"
	# Você precisará criar o caminho correto da cena da Kitnet.
	scene_change_requested.emit("res://game/reception.tscn", "Start_From_Door_Back")
	# Adicione aqui a lógica de salvar o progresso, se for o caso.

# Função placeholder para manter a compatibilidade com a linha antiga,
# mas em Godot 4+ o Autoload já é o singleton.
static func get_or_create_state() -> Node:
	return GameState
