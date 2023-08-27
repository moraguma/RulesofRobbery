extends RayCast2D


const ACTIVE_FRAME = 1
const INACTIVE_FRAME = 0


@export var active = true
@onready var line = $Line
@onready var visual_raycast = $VisualRaycast
@onready var sprite = $Sprite

var last_collider = null


func _ready():
	visual_raycast.target_position = target_position
	
	line.add_point(Vector2(0, 0))
	line.add_point(target_position)
	
	update()


func _physics_process(delta):
	if active:
		var current_collider = get_collider()
		if is_colliding() and current_collider != last_collider:
			if current_collider.has_method("die"):
				current_collider.die()
		
		last_collider = current_collider
		
		if visual_raycast.is_colliding():
			line.set_point_position(1, (visual_raycast.get_collision_point() - get_global_position()).rotated(-rotation))
		else:
			line.set_point_position(1, target_position)


func switch():
	active = not active
	
	update()


func update():
	if active:
		line.show()
		sprite.frame = ACTIVE_FRAME
	else:
		line.hide()
		sprite.frame = INACTIVE_FRAME
