extends CharacterBody3D

class_name PlayerController

# TODO: Use a raycast to check if there is room to stand up
#       when going from crouch to standing.
#       Combine this update with allowing designers to set
#       stand and crouch height. This need to be integrated with animation.
# TODO: Consistent walk speed / sound / animation

# TODO: Change movement to reduce control in the air.

@export_category("Mouse controls")

@export_range(0.01, 0.9, 0.01)
var mouse_sensitivity := 0.2

@export_range(-90, 90, 1)
var pitch_min := -90.0

@export_range(-90, 90, 1)
var pitch_max := 90.0

var can_look := true

@export_category("Movement")

@export var walk_speed   := 4.0

@export var crouch_speed := 2.5

@export var can_run      := true

@export var run_speed    := 6.5

@export var can_jump     := false

@export var jump_speed   := 3.5	# FIXME: Define jumps in height and length

@export_category("Other properties")

# TODO

@export var stand_height := 1.8: set = _set_stand_height

@export var crouch_height := 1: set = _set_crouch_height

func _set_stand_height(_value) -> void:
	pass
	
func _set_crouch_height(_value) -> void:
	pass

# Throw force along the vertical plane the player is looking

@export var throw_force := Vector2(8.0, 4.5)

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Components

@onready var pivot           := $Pivot
@onready var aim             := $Pivot/Aim
@onready var cursor          := $Pivot/Aim/Cursor

@onready var animationPlayer := $AnimationPlayer

# Minimal inventory
@onready var primary: Item = null

# Player control

func look(offset: Vector2) -> void:
	offset *= mouse_sensitivity
		
	rotate_object_local(Vector3.UP, deg_to_rad(-offset.x))

	pivot.rotate_object_local(Vector3.RIGHT, deg_to_rad(-offset.y))
	pivot.rotation.x = clamp(
		pivot.rotation.x,
		deg_to_rad(pitch_min),
		deg_to_rad(pitch_max)
	)

func crouch() -> void:
	if not _crouching:
		animationPlayer.play("Crouch")
		_crouching = true
		_speed = crouch_speed

func stand() -> void:
	if _crouching:
		animationPlayer.play("Stand")
		_crouching = false
		_speed = walk_speed

func run() -> void:
	stand()
	_speed = run_speed

func walk() -> void:
	stand()
	_speed = walk_speed

func jump() -> void:
	velocity.y = jump_speed

# Inventory management

func pick_up(item: Item) -> void:
	# TODO: If primary and inventory.has_room():
	#         inventory.add(item)
	#       elif not primary:
	#         primary = item

	if primary:
		print("Already carring a %s." % primary.name)
	
	else:
		item.get_parent().remove_child(item)		
		pivot.add_child(item)

		item.freeze = true
		
		# FIXME: This is currently read from the inspector for a flash light,
		# but will vary depending on the item. Introducing arms will probably
		# determine how this should be solved.
		
		item.position = Vector3(0.425, -0.325, -0.35)
		item.rotation = Vector3(0, deg_to_rad(-83.5), 0)

		print("Picked up %s." % item.name)
		primary = item

func drop() -> void:
	if not primary:
		print("I don't have anything to drop.")
		return
		
	pivot.remove_child(primary)			# Change parent
	get_parent().add_child(primary)

	primary.freeze = false				# Physics
	throw(primary)
	
	print("Dropped %s." % primary.name)	# Status
	primary = null

func throw(body: RigidBody3D) -> void:
	body.global_transform.origin = pivot.global_transform.origin
	var f = pivot.global_transform.basis.y * throw_force.y - global_transform.basis.z * throw_force.x
	body.apply_central_impulse(f)

var _speed := walk_speed
var _crouching := false

func _ready() -> void:
	walk()

func _input(event: InputEvent) -> void:
	# Look
	if event is InputEventMouseMotion and can_look:
		look(event.relative)
	
	# Crouch
	elif Input.is_action_just_pressed("crouch"):
		if not _crouching:
			crouch()
		else:
			stand()
	
	# Run
	elif Input.is_action_just_pressed("run") and can_run:
		run()
	elif Input.is_action_just_released("run") and can_run:
		_speed = walk_speed

	# Inventory
#	elif Input.is_action_just_pressed("action1"):
#		if not inventory:
#			print("I don't have a inventory.")
#		elif inventory.visible:
#			inventory.visible = false
#			can_look = true
#			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#		else:
#			inventory.visible = true
#			can_look = false
#			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	elif Input.is_action_just_pressed("action2") and primary:
		primary.use()

func _physics_process(delta: float) -> void:
	var _can_jump = can_jump and not _crouching
	
	if not is_on_floor():
		# Boost gravity on the way down
		var k := 1.1 if velocity.y < 0 else 1.0
		velocity.y -= gravity * k * delta
	
	elif _can_jump and Input.is_action_just_pressed("jump"):
		jump()

	var input := Input.get_vector(
		"strafe_left",
		"strafe_right",
		"forward",
		"backward"
	)

	var direction = transform.basis * Vector3(input.x, 0, input.y)
	direction     = direction.normalized()

	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)

	move_and_slide()
	
	if is_on_floor() and input.length_squared() > 0 and velocity.length_squared() > 0:
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play(last_walk_sound_position)
		if _speed == run_speed:
			$AudioStreamPlayer.pitch_scale = 1.35
			$AudioStreamPlayer.volume_db = -15
		elif _speed == crouch_speed:
			$AudioStreamPlayer.pitch_scale = 0.75
			$AudioStreamPlayer.volume_db = -25
		else:
			$AudioStreamPlayer.pitch_scale = 1.0
			$AudioStreamPlayer.volume_db = -20
			
	elif $AudioStreamPlayer.playing:
		last_walk_sound_position = $AudioStreamPlayer.get_playback_position()
		$AudioStreamPlayer.stop()
		

	if aim.is_colliding() and Input.is_action_just_pressed("action0"):
		pick_up(aim.get_collider() as Item)
	
	if Input.is_action_just_pressed("action4"):
		drop()

var last_walk_sound_position := 0.0
