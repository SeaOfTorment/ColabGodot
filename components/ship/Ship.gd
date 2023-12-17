extends CharacterBody3D

const MAX_SPEED = 30.0
const MIN_SPEED = 10.0
const DEAD_ZONE = 20.0
const FORWARD = Vector3(0, 0, 1)
const SIDE = Vector3(1, 0, 0)

const BASIS = Basis()

var turn_speed = 0.75
var pitch_speed = 0.5
var level_speed = 3.0
var throttle_delta = 30.0
var acceleration = 6.0

var forward_speed = 0.0
var target_speed = 0.0

var turn_input = 0.0
var pitch_input = 0.0

var look_dir: Vector2 # Input direction for look/aim

@onready var ship = $ship

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


func update_input(delta):
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, MAX_SPEED)
	if Input.is_action_pressed("throttle_down"):
		target_speed = max(forward_speed - throttle_delta * delta, MIN_SPEED)
	
	#turn_input = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")
	#pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
	



func grab_mouse_direction():
	var viewport = get_viewport()
	var center = viewport.get_visible_rect().size / 2
	var pos = get_viewport().get_mouse_position() - center
	
	if pos.x > DEAD_ZONE:
		turn_input = -(pos.x - DEAD_ZONE) / center.x
	elif pos.x < -DEAD_ZONE:
		turn_input = -(pos.x + -DEAD_ZONE) / center.x
	else:
		turn_input = 0
		
	if pos.y < -DEAD_ZONE:
		pitch_input = -(pos.y - DEAD_ZONE) / center.y
	elif pos.y > DEAD_ZONE:
		pitch_input = -(pos.y - DEAD_ZONE) / center.y
	else:
		pitch_input = 0



func _physics_process(delta):
	grab_mouse_direction()
	update_input(delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	ship.rotation.z = turn_input
	ship.rotation.x = pitch_input / 10 - 0.2
	if Input.is_action_just_pressed("blink"):
		forward_speed = 3000.0
	else:
		forward_speed = min(lerp(forward_speed, target_speed, acceleration * delta), MAX_SPEED)
	velocity = -transform.basis.z * forward_speed
	move_and_collide(velocity * delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# apply gravity
	
	# apply lift
	
	# plane will move forward
	# upwards draft if moving forward which cancels out gravity
	# slowing down will lower draft
	# thrust will move plane forward
	# rotation for controlling direction

	pass

