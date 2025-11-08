extends Resource
class_name ApartmentConfig

# O número do apartamento será inferido do nome do nó da porta no Hall.

@export var delivery_action: ApartmentDeliveryAction # Mantém a lógica de interação.
# Mantém as opções visuais como "overrides" opcionais.
@export var door_tileset_texture: Texture2D
@export var door_texture_region: Rect2
