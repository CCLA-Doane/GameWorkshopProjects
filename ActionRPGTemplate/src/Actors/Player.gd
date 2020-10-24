extends KinematicBody2D

# constant variables Acceleration, Friction, and Velocity
const ACCELERATION = 500.0
const FRICTION = 500.0
var velocity = Vector2.ZERO

# Animation State variables
enum{
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
	
	# Set up a match (Godot switch) for the state machine
	match state:
		
		# Move state
		MOVE:
			move_state(delta)
		
		# Roll state
		ROLL:
			pass
		
		# Attack
		ATTACK:
			attack_state(delta)

# _ready(): this is called when the object is ready to be used in game
func _ready():
	# Set active animation tree
	animation_tree.active = true
	
	
# Set up input, also move state
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
		
		# Move, finally, using animation
		animation_state.travel("Run")
		
		# Set movement velocity
		velocity = velocity.move_toward(input_vector * MAX_SPEED, FRICTION * delta)
	
	# Not moving?
	else:
		# Use idle animation
		animation_state.travel("Idle")
		
		# Use velocity variable to move the sprite on screen
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide(velocity)
	
	# Did we just press attack?
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
	
# Attack State Function
func attack_state(delta: float) -> void:
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

# Stop playing attack animations
func attack_animation_finished():
	state = MOVE
	

