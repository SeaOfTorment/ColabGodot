extends CharacterBody3D

const MAX_SPEED = 30.0
const MIN_SPEED = 10.0
const DEAD_ZONE = 20.0
const FORWARD = Vector3(0, 0, 1)
const SIDE = Vector3(1, 0, 0)

const BASIS = Basis()

const BULLET = preload("res://components/bullet/Bullet.tscn")

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
@onready var bulletGroup = $BulletGroup
@onready var bulletSpawn = $Marker3D
@onready var collisionShape = $CollisionShape3D

var mouse_pos: Vector2


var ai_inputs = {
	"throttle_up": false,
	"throttle_down": false,
	"shoot": false,
	"blink": false
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var BULLET_CD = 0.08
var cd = 0

func update_input(delta):
	cd -= delta
	if ai_inputs.get("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, MAX_SPEED)
	if ai_inputs.get("throttle_down"):
		target_speed = max(forward_speed - throttle_delta * delta, MIN_SPEED)
	
	if ai_inputs.get("shoot"):
		shoot_bullet(global_position + velocity * 100)
	#turn_input = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")
	#pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")


func shoot_bullet(pos):
	if cd > 0:
		return
	cd = BULLET_CD
	var bullet = BULLET.instantiate()
	
	bullet.position = bulletSpawn.global_position
	bullet.transform.basis = bullet.transform.basis.looking_at(pos)
	
	bulletGroup.add_child(bullet)



const RAY_COUNT = 10
const RAY_LENGTH = 30

# Perform raycasting to detect obstacles
func perform_raycasting(origin: Vector3) -> Vector3:
	var max_distance : float = 100.0  # Maximum distance for raycasting
	var best_direction : Vector3 = Vector3.ZERO
	var max_collisions : int = -1  # Track the maximum number of collisions
	var space_state = get_world_3d().direct_space_state

	for i in range(RAY_COUNT):
		# Calculate the direction of the ray
		# Based on the transform.basis.z vector; vector pointing forward, create a cone of rays
		var angle = i * (120 / RAY_COUNT)  # Distribute rays evenly in a circle
		var direction = transform.basis.rotated(transform.basis.z, angle)
		# Cast the ray
		var query = PhysicsRayQueryParameters3D.create(origin, origin - direction.z * RAY_LENGTH)
		var collision = space_state.intersect_ray(query)


		# Check for collisions
		if collision:
			# Count the number of collisions
			
			print(collision)

	return best_direction.normalized()


var target_point = Vector3.ZERO


func run_ai(delta):
	ai_inputs["throttle_up"] = true
	
	turn_input = 0.3
	
	var dir = perform_raycasting(global_position)
	ai_inputs["shoot"] = true
	pass


func _physics_process(delta):
	run_ai(delta)
	update_input(delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	ship.rotation.z = turn_input
	ship.rotation.x = pitch_input / 10
	collisionShape.rotation.z = turn_input
	collisionShape.rotation.x = pitch_input / 10
	
	if ai_inputs.get("blink"):
		forward_speed = 3000.0
	else:
		forward_speed = min(lerp(forward_speed, target_speed, acceleration * delta), MAX_SPEED)
	velocity = -transform.basis.z * forward_speed

	move_and_collide(velocity * delta)

