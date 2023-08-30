extends Button


@export var level: int


func _ready():
	text = str(level)


func _pressed():
	SoundController.play_sfx("click")
	SoundController.play_game()
	Global.goto_scene("res://scenes/levels/" + str(level) + ".tscn")
