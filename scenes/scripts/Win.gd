extends Area2D


func win(body):
	if body.get_collision_layer_value(1):
		body.win()
