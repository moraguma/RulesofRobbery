extends Node2D


const MENU_POS = Vector2(0, 0)
const LEVEL_SELECT_POS = Vector2(-480, 0)
const CREDITS_POS = Vector2(480, 0)
const LERP_WEIGHT = 0.1


@onready var aim_pos = position


@onready var start = $Menu/Start
@onready var credits_back = $Credits/Back
@onready var level_select_back = $LevelSelect/Back


func _ready():
	SoundController.play_menu()


func _process(delta):
	position = lerp(position, aim_pos, LERP_WEIGHT)


func start_game():
	SoundController.play_sfx("click")
	SoundController.play_game()
	Global.goto_scene("res://scenes/levels/CutsceneStart.tscn")


func menu():
	SoundController.play_sfx("click")
	aim_pos = MENU_POS
	start.grab_focus()


func credits():
	SoundController.play_sfx("click")
	aim_pos = CREDITS_POS
	credits_back.grab_focus()


func level_select():
	SoundController.play_sfx("click")
	aim_pos = LEVEL_SELECT_POS
	level_select_back.grab_focus()
