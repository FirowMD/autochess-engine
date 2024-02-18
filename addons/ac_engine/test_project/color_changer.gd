extends AnimatedSprite2D


@export var color: Color = Color(1, 1, 1, 1)


func _ready():
	modulate = color
