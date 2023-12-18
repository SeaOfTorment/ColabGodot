extends Node3D

const DEAD_ZONE = 20.0
var look_dir: Vector2 # Input direction for look/aim
var looking_back = false

var mouse_pos = Vector3.ZERO

@onready var ship_controller = $".."
@onready var camera = $"../Camera3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_input(event):
	if event is InputEventMouse:
		mouse_pos = event.position


func check_input(action):
	if Input.is_action_pressed(action):
		ship_controller.input[action] = true
	else:
		ship_controller.input[action] = false

func handle_input():
	check_input("throttle_up")
	check_input("throttle_down")
	check_input("roll_left")
	check_input("roll_right")
	
	if Input.is_action_pressed("flip_camera"):
		print(get_child_count())
		looking_back = true
		camera.rotation.y = PI
		camera.position.z = -5
	else:
		looking_back = false
		camera.rotation.y = 0
		camera.position.z = 5
	
	if Input.is_action_pressed("shoot"):
		ship_controller.input["shoot"] = true
	else:
		ship_controller.input["shoot"] = false


func grab_mouse_direction():
	var viewport = get_viewport()
	var center = viewport.get_visible_rect().size / 2
	var pos = get_viewport().get_mouse_position() - center
	
	if pos.x > DEAD_ZONE:
		ship_controller.turn_input = -(pos.x - DEAD_ZONE) / center.x
	elif pos.x < -DEAD_ZONE:
		ship_controller.turn_input = -(pos.x + -DEAD_ZONE) / center.x
	else:
		ship_controller.turn_input = 0
	
	if pos.y < -DEAD_ZONE:
		ship_controller.pitch_input = -(pos.y - DEAD_ZONE) / center.y
	elif pos.y > DEAD_ZONE:
		ship_controller.pitch_input = -(pos.y - DEAD_ZONE) / center.y
	else:
		ship_controller.pitch_input = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	grab_mouse_direction()
	handle_input()
