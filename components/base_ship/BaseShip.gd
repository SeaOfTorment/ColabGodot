extends CharacterBody3D

const FORWARD = Vector3(0, 0, 1)
const SIDE = Vector3(1, 0, 0)


@export var ship : Node3D
@export var collisionBox : Node3D
@export var weapon : Node3D
@export var max_speed = 30.0
@export var min_speed = 10.0

@export var weight = 10.0

@export var thrust = 10.0

@export var agility = 10.0

@export var max_health = 10.0
@export var armor = 10.0

var turn_speed = 0.75
var pitch_speed = 0.5
var level_speed = 3.0
var acceleration = 6.0
var throttle_delta = 30.0

var forward_speed = 0.0
var target_speed = 0.0

var turn_input = 0.0
var pitch_input = 0.0
var dead : bool = false;

@onready var EXPLOSION = preload("res://components/particles/explosion.tscn")
@onready var BULLET_IMPACT = preload("res://components/particles/bullet_impact.tscn")
@onready var health = max_health

var death_messages = {
	"terrain": "I died myself!",
	"bullet": "Died to %s",
}

var explosions = {
	"death": EXPLOSION,
	"bullet_impact": BULLET_IMPACT,
}

var input = {
	"throttle_up": false,
	"throttle_down": false,
	"shoot": false,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	calculate_stats()


func calculate_stats():
	acceleration = thrust / weight
	turn_speed = agility / weight
	pitch_speed = (agility / weight) * 0.75


func damage(dmg, pierce):
	health -= dmg
	

func handle_controls(delta):
	if input["throttle_up"]:
		target_speed = min(forward_speed + throttle_delta * delta, max_speed)
	if input["throttle_down"]:
		target_speed = max(forward_speed - throttle_delta * delta, min_speed)
	if input["shoot"]:
		weapon.shoot_bullet(global_position + velocity * 100)


func explode(explosion_position: Vector3 = Vector3(0,0,0), explosion_type: String = "death"):
	var explosion = explosions[explosion_type].instantiate()
	add_child(explosion)
	explosion.global_position = explosion_position
	explosion.emitting = true


func die(died_to: String, killer: String = ""):
	dead = true
	if !killer.is_empty():
		print(death_messages[died_to] % killer)
		explode(ship.global_position)
	else:
		print(death_messages[died_to])
		explode(ship.global_position)


func _physics_process(delta):
	handle_controls(delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	ship.rotation.z = turn_input
	ship.rotation.x = pitch_input / 10
	
	collisionBox.rotation.z = turn_input
	collisionBox.rotation.x = pitch_input / 10
	
	forward_speed = min(lerp(forward_speed, target_speed, acceleration * delta), max_speed)
	velocity = -transform.basis.z * forward_speed
	
	# Sea - added collision & death
	var collision = move_and_collide(velocity * delta)
	
	if collision && !dead:
		var hit: String = "terrain" #collision.get_collider().get_meta("id")
		if hit == "terrain":
			die(hit) #collided with, (optional) from who
