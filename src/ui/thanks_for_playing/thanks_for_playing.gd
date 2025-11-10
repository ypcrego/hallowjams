extends UiPage

@export var thank_you_image: Texture2D:
	set(texture):
		thank_you_image = texture
		texture_rect.texture = thank_you_image

@onready var texture_rect: TextureRect = $TextureRect
