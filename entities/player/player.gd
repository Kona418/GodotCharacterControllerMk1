extends CharacterBody3D

@export_range(1.0, 20.0)
var SPEED: float = 5.0

@export_range(1.0, 3.0)
var sprint_multiplier: float = 1.5

@export_range(0.25, 1.0)
var sneak_multiplier: float = 0.5

@export_range(3.0, 10.0)
var JUMP_VELOCITY: float = 4.5

@export_range(0.25, 5.0)
var gravity_multiplier: float = 1.0

@export_range(1, 10)
var air_jump_count: int = 2

@export
var character_camera: Camera3D

@export_range(0.1, 5.0)
var camera_sensitivity: float = 1.0

@export_range(45, 90)
var camera_upper_limit: int = 80

@export_range(-45, -90)
var camera_lower_limit: int = -80

var jumps_left: int

func _init() -> void:
	
	jumps_left = air_jump_count
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	pass


func _physics_process(delta: float) -> void:
	
	
	if is_on_floor() and jumps_left != air_jump_count:
		jumps_left = air_jump_count
	# Add the gravity.
	if not is_on_floor() and not (is_on_wall() and Input.is_action_pressed("move_jump")):
		velocity += get_gravity() * delta * gravity_multiplier

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if(Input.is_action_just_pressed("move_jump") and !is_on_floor() and jumps_left >= 1):
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
	
	if Input.is_action_pressed("move_jump") and is_on_wall():
		velocity.y = 0
	if Input.is_action_just_released("move_jump") and is_on_wall():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction: Vector3 = (transform.basis * Vector3(move_input_dir.x, 0, move_input_dir.y)).normalized()
	
	if Input.is_action_pressed("move_sprint") && !Input.is_action_pressed("move_sneak"): move_direction *= sprint_multiplier
	if !Input.is_action_pressed("move_sprint") && Input.is_action_pressed("move_sneak"): 
		move_direction *= sneak_multiplier
		character_camera.position.z = 0.25
	
	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
# In der _physics_process(delta) oder _process(delta) Funktion:

	var rotation_input_dir: Vector2 = Input.get_vector("camera_up", "camera_down", "camera_left", "camera_right")
	if rotation_input_dir.length() > 0:
		rotation.y -= rotation_input_dir.y * camera_sensitivity * delta
		character_camera.rotation.x -= rotation_input_dir.x * camera_sensitivity * delta
		
		if character_camera.rotation_degrees.x > camera_upper_limit:
			character_camera.rotation_degrees.x = camera_upper_limit
		if character_camera.rotation_degrees.x < camera_lower_limit:
			character_camera.rotation_degrees.x =camera_lower_limit
		
	

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * camera_sensitivity * 0.001
		character_camera.rotation.x -= event.relative.y * camera_sensitivity * 0.001
		
		if character_camera.rotation_degrees.x > camera_upper_limit:
			character_camera.rotation_degrees.x = camera_upper_limit
		if character_camera.rotation_degrees.x < camera_lower_limit:
			character_camera.rotation_degrees.x =camera_lower_limit
		pass
	
	pass
