class_name Player

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

@export var number: int
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
@onready var number_sprite = $Number
@onready var selection_sprite = $Selection
@onready var exclamation_sprite = $Exclamation
@onready var vision_cone = $VisionCone
@onready var animation_player = $AnimationPlayer
@onready var main = get_parent()

@onready var rotatables = [sprite, vision_cone]


# --------------------------------------------------------------------------------------------------
# BUILT-INS
# --------------------------------------------------------------------------------------------------


func _ready():
	call_deferred("update_bodies")
	
	vision_cone.show()
	
	starting_pos = position
	starting_rotation = rotation
	rotation = 0
	
	reset_rotation()
	
	number_sprite.frame = number - 1
	
	for rotatable in rotatables:
		rotatable.rotation = starting_rotation
	
	main.players[number] = self
	sprite.texture = load(texture_path)


func update_bodies():
	bodies = vision_cone.get_overlapping_bodies()
	can_detect = true


func _process(delta):
	if controled:
		if not exclamation_sprite.visible:
			selection_sprite.show()
		number_sprite.hide()
	else:
		selection_sprite.hide()
		number_sprite.show()


func _physics_process(delta):
	if active:
		_movement_processing(delta)
		_animation_processing()
		_vision_processing()
	else:
		velocity = Vector2(0, 0)
		turning_velocity = 0.0


func _movement_processing(delta):
	# Inputs
	var turning_dir
	var dir
	if controled:
		turning_dir = Input.get_action_strength("right") - Input.get_action_strength("left")
		dir = Vector2(0, Input.get_action_strength("backward") - Input.get_action_strength("forward")).rotated(base_rotation)
		
		inputs.append({"turning_dir": turning_dir, "dir": dir, "delta": delta})
	else: 
		if pos < len(inputs):
			turning_dir = inputs[pos]["turning_dir"]
			dir = inputs[pos]["dir"] * inputs[pos]["delta"] / delta
		else:
			turning_dir = 0.0
			dir = Vector2(0, 0)
	pos += 1
	
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


func _vision_processing():
	if can_detect:
		for body in bodies:
			raycast.target_position = (body.position - position)
			raycast.force_raycast_update()
			
			if raycast.get_collider() == body and body.active:
				see_player()
				body.active = false
				
				exit_vision(body)


# --------------------------------------------------------------------------------------------------
# METHODS
# --------------------------------------------------------------------------------------------------


func win():
	main.win(number)
	sprite.hide()
	
	position = Vector2(0, 0)
	
	active = false


func reset_movement():
	active = true
	
	position = starting_pos
	reset_rotation()
	pos = 0
	
	can_detect = false
	bodies = []
	call_deferred("update_bodies")
	
	sprite.show()
	exclamation_sprite.hide()


func reset_rotation():
	base_rotation = starting_rotation
	update_rotation()


func update_rotation():
	for rotatable in rotatables:
		rotatable.rotation = base_rotation


func reset_memory():
	inputs = []


func see_player():
	SoundController.play_sfx("detection")
	
	exclamation_sprite.show()
	selection_sprite.hide()
	
	active = false
	main.reset()


func die():
	if active:
		active = false
		
		main.reset()


func enter_vision(body):
	if not body in bodies and body.get_collision_layer_value(1):
		if body.active:
			bodies.append(body)


func exit_vision(body):
	if body in bodies:
		bodies.erase(body)


func step_left():
	if controled:
		SoundController.play_sfx("step_left")


func step_right():
	if controled:
		SoundController.play_sfx("step_right")
