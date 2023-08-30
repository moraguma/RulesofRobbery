extends Node


const OFF_DB = -80.0
const ON_DB = 0.0


const DECAY_ACCEL = 0.05


var menu_aim_db = -80.0
var game_aim_db = -80.0


@onready var menu = $Music/Menu
@onready var loop = $Music/GameLoop
@onready var sfx = {"switch_off": $SFX/SwitchOff, "switch_on": $SFX/SwitchOn, "laser_off": $SFX/LaserOff, "laser_on": $SFX/LaserOn, "detection": $SFX/Detection, "win": $SFX/Win, "die": $SFX/Die, "step_left": $SFX/StepLeft, "step_right": $SFX/StepRight, "swoosh": $SFX/Swoosh, "click": $SFX/Click, "dialogue": $SFX/Dialogue}


func _process(delta):
	menu.volume_db = lerp(menu.volume_db, menu_aim_db, DECAY_ACCEL)
	loop.volume_db = lerp(loop.volume_db, game_aim_db, DECAY_ACCEL)


func play_menu():
	if menu_aim_db != ON_DB:
		menu.play()
		
		menu_aim_db = ON_DB
		game_aim_db = OFF_DB


func play_game():
	if game_aim_db != ON_DB:
		loop.play()
		loop.volume_db = OFF_DB
		
		menu_aim_db = OFF_DB
		game_aim_db = ON_DB


func mute_game():
	game_aim_db = OFF_DB


func unmute_game():
	game_aim_db = ON_DB


func play_sfx(name):
	sfx[name].stop()
	sfx[name].play()
