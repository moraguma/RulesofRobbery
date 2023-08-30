extends Area2D


func win(body):
	if body.get_collision_layer_value(1):
		SoundController.play_sfx("win")
		
		body.win()
