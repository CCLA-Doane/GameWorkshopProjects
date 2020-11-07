extends KinematicBody2D # Everything KinematicBody2D can do, we can too

# Constant variables
const ACCELERATION = 500.0
const FRICTION = 500.0
var velocity = Vector2.ZERO

enum {
	MOVE,
	ROLL,
	ATTACK
}
# Set the default state
var state = MOVE

# Max speed variable
export var MAX_SPEED = 100.0

# Reference to animation nodes
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

# _physics_process(delta) called every frame, reads player input, etc.
func _physics_process(delta):
	# Set up match statement for state machine
	
	match state: 
		MOVE: 
			move_state(delta)
		ROLL: 
			roll_state(delta)
		ATTACK: 
			attack_state(delta)
	
func _ready():
	animation_tree.active = true
	
# Set up input
func move_state(delta: float) -> void:
	# Create an input_vector variable initialize to 0, 0
	var input_vector = Vector2.ZERO
	
	# Get input vectors on x and y by subtracting left from right and top from bottom
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Call a Godot macro function
	input_vector = input_vector.normalized()
	
	# Set up our blend space
	##
	# Are we moving?
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		# Move, finally, using animation
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED,  ACCELERATION * delta)
			# set roll state
		if Input.is_action_just_pressed("ui_accept"):
			state = ROLL
	# Not moving?
	else:
		# Use idle animation		
		animation_state.travel("Idle")
		# Use velocity variable to move the sprite on screen		
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	# Move the character on screen
	move_and_slide(velocity)
	# Did we just press attack?	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		

# Attack State Function
func attack_state(delta: float) -> void:
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

# Roll state animation
func roll_state(delta: float) -> void:
	animation_state.travel("Roll")

# Stop playing roll
func roll_animation_finished():
	state = MOVE

# Stop playing attack
func attack_animation_finished():
	state = MOVE
