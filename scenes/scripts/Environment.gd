extends Node2D

signal sinal

# --------------------------------------------------------------------------------------------------
# CONSTANTS
# --------------------------------------------------------------------------------------------------

const RESET_TIME = 2
const MAX_PLAYERS = 5

# --------------------------------------------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------------------------------------------

@export var next_level_path: String
@export var max_time: float = 30.0

var players: Dictionary = {}
var wins: Dictionary = {}
var current_control = 1
var active = true

@onready var timer = $Timer
@onready var alarm_text = $AlarmText
@onready var alarm_timer = $AlarmTimer

# --------------------------------------------------------------------------------------------------
# BUILT-INS
# --------------------------------------------------------------------------------------------------


func _ready():
	max_time = 0
	
	start_alarm()
	
	assert(1 in players, "Must have player number 1")
	players[1].controled = true
	
	for n in players:
		wins[n] = false


func _process(delta):
	if max_time > 0:
		var sec = str(floor(alarm_timer.time_left))
		if len(sec) < 2:
			sec = "0" + sec
		
		var mili = str((alarm_timer.time_left - floor(alarm_timer.time_left)) * 100).get_slice(".", 0)
		if len(mili) < 2:
			mili = "0" + mili
		
		alarm_text.text = "[center]" + sec + ":" + mili


func _physics_process(delta):
	if active:
		_player_processing()
		
		if Input.is_action_just_pressed("reset"):
			instant_reset()
	
	if Input.is_action_just_pressed("menu"):
		Global.goto_scene("res://scenes/Menu.tscn")


func _player_processing():
	for i in range(1, MAX_PLAYERS + 1):
		if Input.is_action_just_pressed(str(i)) and i in players:
			take_control(i)
			break 


# --------------------------------------------------------------------------------------------------
# METHODS
# --------------------------------------------------------------------------------------------------


func take_control(number: int):
	if number != current_control:
		SoundController.play_sfx("swoosh")
		
		wins[number] = false
		players[current_control].controled = false
		players[number].controled = true
		
		current_control = number
		instant_reset()


func win(number: int):
	wins[number] = true
	players[number].controled = false
	
	for n in wins:
		if not wins[n]:
			return
	
	finish()


func finish():
	Global.goto_scene(next_level_path)


func start_alarm():
	
	if max_time > 0:
		alarm_timer.start(max_time)


func alarm():
	players[current_control].active = false
	
	reset()


func instant_reset():
	start_alarm()
	
	for n in players:
		players[n].reset_movement()
		wins[n] = false
	players[current_control].reset_memory()


func reset():
	players[current_control].active = false
	
	alarm_timer.stop()
	
	timer.start(RESET_TIME)
	active = false
	await timer.timeout
	active = true
	
	instant_reset()
