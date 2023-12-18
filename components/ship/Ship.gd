extends CharacterBody3D

const MAX_SPEED = 30.0
const MIN_SPEED = 10.0
const DEAD_ZONE = 20.0
const FORWARD = Vector3(0, 0, 1)
const SIDE = Vector3(1, 0, 0)

const BASIS = Basis()

const BULLET = preload("res://components/bullet/Bullet.tscn")
const EXPLOSION = preload("res://components/particles/explosion.tscn")
const BULLET_IMPACT = preload("res://components/particles/bullet_impact.tscn")
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
var looking_back = false

@onready var ship = $ape_ship2
@onready var camera = $Camera3D
@onready var bulletGroup = $BulletGroup
@onready var bulletSpawn = $Marker3D

var mouse_pos: Vector2

var dead:bool = false;
var death_messages = {
	"terrain" : "I died myself!",
	"bullet"  : "Died to %s",
}
var explosions = {
	"death" : EXPLOSION,
	"bullet_impact" : BULLET_IMPACT,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


func update_input(delta):
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, MAX_SPEED)
	if Input.is_action_pressed("throttle_down"):
		target_speed = max(forward_speed - throttle_delta * delta, MIN_SPEED)
	
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
		var to = camera.project_ray_normal(mouse_pos) * 100
		if looking_back:
			to *= -1
		shoot_bullet(to)
	#turn_input = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")
	#pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")


func shoot_bullet(pos):
	var bullet = BULLET.instantiate()
	
	bullet.position = bulletSpawn.global_position
	bullet.transform.basis = bullet.transform.basis.looking_at(pos)
	
	bulletGroup.add_child(bullet)


func _unhandled_input(event):
	if event is InputEventMouse:
		mouse_pos = event.position


func grab_mouse_direction():
	var viewport = get_viewport()
	var center = viewport.get_visible_rect().size / 2
	var pos = get_viewport().get_mouse_position() - center
	
	if pos.x > DEAD_ZONE:
		turn_input = -(pos.x - DEAD_ZONE) / center.x
	elif pos.x < -DEAD_ZONE:
		turn_input = -(pos.x + -DEAD_ZONE) / center.x
	else:
		turn_input = 0
	
	if pos.y < -DEAD_ZONE:
		pitch_input = -(pos.y - DEAD_ZONE) / center.y
	elif pos.y > DEAD_ZONE:
		pitch_input = -(pos.y - DEAD_ZONE) / center.y
	else:
		pitch_input = 0

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
	grab_mouse_direction()
	update_input(delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	ship.rotation.z = turn_input
	ship.rotation.x = pitch_input / 10 - 0.2
	if Input.is_action_just_pressed("blink"):
		forward_speed = 3000.0
	else:
		forward_speed = min(lerp(forward_speed, target_speed, acceleration * delta), MAX_SPEED)
	velocity = -transform.basis.z * forward_speed
	
	# Sea - added collision & death
	var collision = move_and_collide(velocity * delta)
	if collision && !dead:
		var hit: String = collision.get_collider().get_meta("id")
		if hit == "terrain":
			die(hit) #collided with, (optional) from who
		elif hit == "bullet":
			pass
