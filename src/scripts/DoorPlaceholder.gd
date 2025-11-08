extends Marker2D # Marker2D é um nó leve, perfeito para marcar posições.
class_name DoorPlaceholder

# Este é o único dado não-espacial que precisamos para criar a porta.
# É o seu Resource de comportamento/visual (ApartmentConfig)
@export var apartment_config: ApartmentConfig = null

# Opcional: Use isso apenas como rótulo no editor para saber qual porta é qual.
@export var apartment_number: String = ""
