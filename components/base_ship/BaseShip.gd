extends CharacterBody3D

var grav: float = ProjectSettings.get_setting("physics/3d/default_gravity") / 10

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
var roll = 1.0
var roll_delta = 0
const ROLL_MAX_TIME = 2.0
const ROLL_SPEED = 4.0
var dead : bool = false;

const EXPLOSION = preload("res://components/particles/explosion.tscn")
const BULLET_IMPACT = preload("res://components/particles/bullet_impact.tscn")

const RAG_DOLL = preload("res://components/ragdoll/ShipDeath.tscn")
@onready var health = max_health

var death_messages = {
	"terrain": "I died myself!",
	"bullet": "Died to %s",
	"plane": "Crashed into %s"
}

var explosions = {
	"death": EXPLOSION,
	"bullet_impact": BULLET_IMPACT,
}

var input = {
	"throttle_up": false,
	"throttle_down": false,
	"roll_right": false,
	"roll_left": false,
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
	print("hit!")
	health -= dmg
	if health <= 0:
		die("bullet")



func handle_controls(delta):
	if input["throttle_up"]:
		target_speed = min(forward_speed + throttle_delta * delta, max_speed)
	if input["throttle_down"]:
		target_speed = max(forward_speed - throttle_delta * delta, min_speed)

	if not input["roll_right"] and not input["roll_left"]:
		roll_delta -= delta * ROLL_SPEED
		roll_delta = max(roll_delta, 0)
	else:
		roll_delta += delta * ROLL_SPEED
		roll_delta = min(roll_delta, ROLL_MAX_TIME)
	if input["shoot"]:
		weapon.shoot_bullet(global_position + velocity * 100)


func explode(explosion_position: Vector3 = Vector3(0,0,0), explosion_type: String = "death"):
	print(explosions, explosions[explosion_type])
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

var dead_spawned = false

func spawn_ragdoll(delta):
	if dead_spawned: 
		return
	dead_spawned = true
	ship.hide()
	var effects = RAG_DOLL.instantiate();
	effects.position = global_position
	get_tree().root.add_child(effects)
	collisionBox.queue_free()
	

func constrain_input():
	turn_input = max(min(turn_input, 1), -1)
	pitch_input = max(min(pitch_input, 1), -1)


func _physics_process(delta):
	if dead:
		spawn_ragdoll(delta)
		return
	handle_controls(delta)
	constrain_input()
	
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, (turn_input * (1 + (roll * (roll_delta / ROLL_MAX_TIME)))) * turn_speed * delta)
	ship.rotation.z = turn_input * (1 + (roll * (roll_delta / ROLL_MAX_TIME)))
	ship.rotation.x = pitch_input / 10
	collisionBox.rotation = ship.rotation
	
	forward_speed = min(lerp(forward_speed, target_speed, acceleration * delta), max_speed)
	velocity = -transform.basis.z * forward_speed
	
	# Sea - added collision & death
	var collision = move_and_collide(velocity * delta)
	
	if collision && !dead:
		var source = collision.get_collider(0)
		if source.has_method("die"):
			source.die("plane", "Me")
			die("plane", "You")
			return
		var hit: String = "terrain" #collision.get_collider().get_meta("id")
		if hit == "terrain":
			die(hit) #collided with, (optional) from who
