extends CanvasLayer
class_name AimHud

@export var CrossOffset : Vector2 = Vector2.ZERO
@onready var cross: TextureRect = $AimHud/Cross

func _ready() -> void:
	cross.position = cross.position + CrossOffset

func SetCross(crossTexture : Texture2D):
	cross.texture = crossTexture
