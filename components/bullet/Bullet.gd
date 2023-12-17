extends Area3D


var grav: float = ProjectSettings.get_setting("physics/3d/default_gravity") / 10

const MAX_TIME = 5

var count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = -transform.basis.z * 500 * delta
	position += velocity
	
	position.y -= grav * (count / 5)
	count += delta
	if count > MAX_TIME:
		queue_free()


func _on_body_entered(body):
	queue_free()

	pass # Replace with function body.
