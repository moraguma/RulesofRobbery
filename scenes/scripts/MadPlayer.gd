extends CharacterBody2D

# --------------------------------------------------------------------------------------------------
# CONSTANTS
# --------------------------------------------------------------------------------------------------

const WALK_TOLERANCE = 5.0
const SPEED = 100.0
const ACCEL = 0.1
const DECEL = 0.3
const TURNING_SPEED = PI
const TURNING_ACCEL = 0.1
const TURNING_DECEL = 0.3


# --------------------------------------------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------------------------------------------

@export var texture_path: String

# Movement ---------------------------------------------------------------------
var turning_velocity = 0.0
var starting_pos
var starting_rotation
var base_rotation

# Interaction ------------------------------------------------------------------
var controled = false
var active = true
var inputs = [] # {"turning_dir": float, "dir": vec2, "delta": float}
var pos = 0
var bodies = []
var can_detect = false


# --------------------------------------------------------------------------------------------------
# NODES
# --------------------------------------------------------------------------------------------------

@onready var raycast = $Raycast
@onready var sprite = $Sprite
@onready var vision_cone = $VisionCone
@onready var animation_player = $AnimationPlayer

@onready var rotatables = [sprite, vision_cone]

@onready var noise = FastNoiseLite.new()
var noise_y = 0


# --------------------------------------------------------------------------------------------------
# BUILT-INS
# --------------------------------------------------------------------------------------------------


func _ready():
	randomize()
	noise.seed = randi()
	noise.frequency = 0.001
	
	vision_cone.show()
	
	starting_pos = position
	starting_rotation = rotation
	rotation = 0
	
	reset_rotation()
	
	for rotatable in rotatables:
		rotatable.rotation = starting_rotation
	
	sprite.texture = load(texture_path)


func _physics_process(delta):
	if active:
		_movement_processing(delta)
		_animation_processing()
	else:
		velocity = Vector2(0, 0)
		turning_velocity = 0.0


func _movement_processing(delta):
	# Inputs
	var turning_dir = noise.get_noise_1d(noise_y) * 2
	var dir = Vector2(0, noise.get_noise_1d(noise_y + 9999) * 2).rotated(base_rotation)
	
	noise_y += 1
	
	# Turning
	var turning_accel = TURNING_ACCEL if turning_dir * turning_velocity > 0 else TURNING_DECEL
	turning_velocity = lerp(turning_velocity, turning_dir * TURNING_SPEED, turning_accel)
	
	base_rotation += turning_velocity * delta
	update_rotation()
	
	# Moving
	var accel = ACCEL if dir.dot(velocity) > 0 else DECEL
	velocity = lerp(velocity, dir * SPEED, accel)
	
	move_and_slide()


func _animation_processing():
	if velocity.length() > WALK_TOLERANCE:
		animation_player.play("walk")
	else:
		animation_player.play("idle")


# --------------------------------------------------------------------------------------------------
# METHODS
# --------------------------------------------------------------------------------------------------

func reset_rotation():
	base_rotation = starting_rotation
	update_rotation()


func update_rotation():
	for rotatable in rotatables:
		rotatable.rotation = base_rotation


func enter_vision(body):
	pass


func exit_vision(body):
	pass


func step_left():
	if controled:
		SoundController.play_sfx("step_left")


func step_right():
	if controled:
		SoundController.play_sfx("step_right")
