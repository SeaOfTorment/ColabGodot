extends Node3D

@onready var ship = $"../"

var ai_inputs = {
	"throttle_up": false,
	"throttle_down": false,
	"shoot": false,
	"blink": false
}

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
	ship.input["throttle_up"] = true
	
	ship.turn_input = 0.3
	
	var dir = perform_raycasting(global_position)
	ship.input["shoot"] = true
	pass


func _physics_process(delta):
	run_ai(delta)
