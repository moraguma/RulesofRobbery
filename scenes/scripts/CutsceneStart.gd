extends Node2D


const TIME_PER_LINE = 4
const TOTAL_LINES = 10


var current_line = 1
var last_lines = []


@export var path: String
@onready var timer = $Timer
@onready var sets = [$"1", $"2", $"3", $"4"]


# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		if current_line >= TOTAL_LINES:
			Global.goto_scene(path)
			break
		
		next_line()
		
		timer.start(TIME_PER_LINE)
		await timer.timeout

func next_line():
	SoundController.play_sfx("dialogue")
	
	for line in last_lines:
		line.hide()
	
	for set in sets:
		for line in set.get_children():
			if line.name == str(current_line):
				last_lines.append(line)
				line.show()
	
	current_line += 1
