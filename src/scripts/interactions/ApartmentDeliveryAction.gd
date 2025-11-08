# src/scripts/interactions/ApartmentDeliveryAction.gd
extends InteractionAction
class_name ApartmentDeliveryAction

@export var apartment_number: String = "101"

# ID do diálogo para sucesso na entrega
@export var dialogue_success_id: String = ""
# ID do diálogo para falha na entrega
@export var dialogue_failure_id: String = ""

func execute(interactor: Node) -> void:
	# Apenas uma chamada, e um retorno simples:
	var delivered_successfully: bool = GameState.try_deliver_package_at_apartment(apartment_number)

	var timeline_to_start: String = ""

	if delivered_successfully:
		# A entrega ocorreu; GameState já cuidou dos efeitos colaterais (is_creepy)
		timeline_to_start = dialogue_success_id # Diálogo de sucesso genérico

	elif GameState.has_package and GameState.target_ap != apartment_number:
		# Está segurando um pacote, mas é o errado
		timeline_to_start = dialogue_failure_id

	else:
		# Não está segurando nada
		timeline_to_start = "no_package_dialogue"

	if timeline_to_start and Dialogic:
		Dialogic.start(timeline_to_start)
