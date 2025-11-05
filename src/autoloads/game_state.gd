extends Node

# Sinais para notificar a UI ou outros scripts sobre mudanças
signal package_status_changed(is_holding: bool, target_ap: String)

var has_package: bool = false
var target_ap: String = ""
var day_count: int = 1 # Começa no dia 1

# Atualiza o status do pacote e notifica os ouvintes
func set_package_status(is_holding: bool, ap: String) -> void:
	self.has_package = is_holding
	self.target_ap = ap
	package_status_changed.emit(is_holding, ap)

# Avança o dia, reiniciando o estado do pacote (novo dia = sem pacote)
func advance_day() -> void:
	day_count += 1
	set_package_status(false, "")
	# Adicione aqui a lógica de salvar o progresso, se for o caso.

# Função placeholder para manter a compatibilidade com a linha antiga,
# mas em Godot 4+ o Autoload já é o singleton.
static func get_or_create_state() -> Node:
	return GameState
