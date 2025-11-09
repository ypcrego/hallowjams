# Novo Script: src/scripts/door_data.gd
extends Resource
class_name DoorData

@export var position: Vector2 = Vector2(823, 368)
@export var apartment_number: String = "101"
@export var delivery_action: ApartmentDeliveryAction # Reutiliza sua ação!
@export var door_tileset_texture: Texture2D = preload("res://src/assets/tileset/Inside_E.png")

## Opções visuais para a porta (TextureRegion da sua Door.tscn)
@export var door_texture_region: Rect2 = Rect2(692, 635, 48, 85)
@export var z_index_offset: int = 0
