# src/scripts/interactions/ApartmentDeliveryAction.gd
extends InteractionAction
class_name ApartmentDeliveryAction



@export var apartment_number: String = "101"

# ID do diálogo para sucesso na entrega
@export var dialogue_success_id: String = ""
# ID do diálogo para falha na entrega
@export var dialogue_failure_id: String = "delivery_failure"

var style: DialogicStyle = load("res://src/data/dialogic/custom_syle.tres")


func execute(interactor: Node) -> void:
	style.prepare()
	# Captura o estado antes da tentativa de entrega
	var was_holding_package = GameState.get_has_package()
	var former_target_ap = GameState.get_target_ap()

	print ('ta com pacote?' , was_holding_package)
	# Apenas uma chamada, e um retorno simples:
	var delivered_successfully: bool = GameState.try_deliver_package_at_apartment(apartment_number)
	print ('entrego ucorretamentw???', delivered_successfully)

	var timeline_to_start: String = ""

	if delivered_successfully:
		# A entrega ocorreu; GameState já cuidou dos efeitos colaterais (is_creepy)
		timeline_to_start = dialogue_success_id # Diálogo de sucesso genérico

	elif was_holding_package and former_target_ap != apartment_number:
		# Está segurando um pacote, mas é o errado
		timeline_to_start = dialogue_failure_id

	else:
		# Não está segurando nada
		timeline_to_start = "no_package_dialogue"

	if Dialogic.current_timeline != null:
		return

	if timeline_to_start:
		print(timeline_to_start)
		if not Dialogic.is_connected("timeline_ended", Callable(self, "_on_delivery_dialogue_ended")):
			Dialogic.connect("timeline_ended", Callable(self, "_on_delivery_dialogue_ended"))

		Dialogic.start(timeline_to_start)

func _on_delivery_dialogue_ended():
	var is_day_complete = GameState.is_day_task_complete()

	if Dialogic.is_connected("timeline_ended", Callable(self, "_on_delivery_dialogue_ended")):
		Dialogic.disconnect("timeline_ended", Callable(self, "_on_delivery_dialogue_ended"))

	if is_day_complete:
		GameState.start_delivery_end_sequence()
