extends StateMachine
class_name Actor

onready var animations = $Armature/AnimationPlayer
onready var camera_pivot = $CameraPivot
onready var camera = $CameraPivot/CameraTarget/Camera

# Set gravity, velocity, and initial position
# initial position (local basis)
onready var position = Vector3()
onready var velocity = Vector3()
onready var speed = velocity.length()
# direction is velocity vector with unit length
onready var direction = velocity.normalized()
# If there is an acceleration, then there is a force (I.E. gravity)
onready var acceleration = (
	ProjectSettings.get_setting("physics/3d/default_gravity")
	* ProjectSettings.get_setting("physics/3d/default_gravity_vector")
)

# mouse controls
onready var MOUSE_SENSITIVITY = 0.05  # degrees per pixel??


# Also calls current states _physics_process
func _physics_process(delta):
	# Always apply gravity
	velocity.y += acceleration.y * delta
	velocity = move_and_slide(velocity, Vector3.UP)


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Simple FPS
		# Note
		# 1) Rotation order matters
		# 2) Rotation about the y axis is restricted to the Actor node
		# 3) Rotation about the z axis is restriced to the CameraCenter node
		# Switch these two lines of code for fun ;]
		self.rotate_y(lerp(0, MOUSE_SENSITIVITY, -event.relative.x / 10))
		camera_pivot.rotate_x(lerp(0, MOUSE_SENSITIVITY, -event.relative.y / 10))

		# don't let the camera flip upside down
		var camera_rot = camera_pivot.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		camera_pivot.rotation_degrees = camera_rot

	# Testing junk
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_R:
			get_tree().reload_current_scene()
		if Input.is_key_pressed(KEY_O):
			transform.origin = Vector3()
		if event.pressed and event.scancode == KEY_C:
			camera.transform.origin = camera_pivot.transform.origin
