extends Area2D


const INACTIVE_FRAME = 1
const ACTIVE_FRAME = 0


@export var connect_paths: Array[NodePath]
var connects = []
var bodies = []


@onready var sprite = $Sprite


func _ready():
	sprite.frame = INACTIVE_FRAME
	
	for path in connect_paths:
		connects.append(get_node(path))


func enter_button(body):
	if not body in bodies and body.get_collision_layer_value(1):
		if len(bodies) == 0:
			for c in connects:
				c.switch()
				
				sprite.frame = ACTIVE_FRAME
		
		bodies.append(body)


func exit_button(body):
	if body in bodies:
		bodies.erase(body)
	
	if len(bodies) == 0:
		for c in connects:
			c.switch()
			
			sprite.frame = INACTIVE_FRAME
