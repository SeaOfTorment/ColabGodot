extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	find_children("shockwave")[0].emitting = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_finished():
	queue_free()