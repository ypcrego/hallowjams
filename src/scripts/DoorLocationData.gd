extends Resource
class_name DoorLocationData

# 1. Dados Espaciais: Onde a porta REALMENTE está na cena Hall.
@export var position: Vector2 = Vector2.ZERO
@export var z_index_offset: int = 0

# 2. Referência ao Comportamento: O Resource de configuração reutilizável.
@export var apartment_config: ApartmentConfig = null

# Opcional: Adicionar o número/ID do apartamento aqui para facilitar a visualização no editor.
@export var apartment_number: String = ""
