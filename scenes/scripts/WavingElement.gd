extends Sprite2D


@export var FREQUENCY = 0.5
@export var AMPLITUDE = 4

var t = 0

func _process(delta):
	t += delta
	
	offset.y = AMPLITUDE * cos(2 * PI * FREQUENCY * t)
