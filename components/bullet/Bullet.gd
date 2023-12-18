extends Area3D


const BULLET_IMPACT = preload("res://components/particles/bullet_impact.tscn")

var grav: float = ProjectSettings.get_setting("physics/3d/default_gravity") / 10

const MAX_TIME = 5

var count = 0

# stats
@export var damage = 10
@export var armor_pierce = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer3D.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = -transform.basis.z * 200 * delta
	var space = get_viewport().world_3d.direct_space_state
	velocity.y -= grav * (count / 5)

	position += velocity

	count += delta
	if count > MAX_TIME:
		queue_free()


func bullet_effect(collision_point = global_position):
	var effect = BULLET_IMPACT.instantiate()
	effect.position = collision_point
	effect.emitting = true
	get_tree().root.add_child(effect)
	set_physics_process(false)
	$MeshInstance3D.visible = false


func _on_body_entered(body):
	if body.has_method("damage"):
		body.damage(damage, armor_pierce)
	bullet_effect()
