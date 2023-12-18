class_name Weapon extends Node3D


@export var BULLET: PackedScene
@export var cooldown = 0.1

@export var bulletSpawn : Marker3D
@export var bulletGroup : Node

var cd = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func shoot_bullet(pos):
	if cd > 0:
		return
	cd = cooldown
	var bullet = BULLET.instantiate()
	
	bullet.position = bulletSpawn.global_position
	bullet.transform.basis = bullet.transform.basis.looking_at(pos)
	
	bulletGroup.add_child(bullet)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	cd -= delta
