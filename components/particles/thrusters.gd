extends GPUParticles3D

@onready var ship = $"../../../"
@onready var camera = ship.find_children("Camera3D")[0]
var positions: Array[Vector3]
var mouse_pos: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	positions.resize(3)
	positions[0] = ship.position
	#print()
	#process_material.set("direction", camera.project_ray_normal(mouse_pos) * 100)

func _process(delta):
	#roll positions
	positions[0] = positions[1]
	positions[1] = ship.position
	positions[2] = positions[0]-positions[1]
	#process_material.set("direction", positions[2]*20)
	#process_material.get("direction")
func _unhandled_input(event):
	if event is InputEventMouse:
		mouse_pos = event.position
