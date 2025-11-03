extends CharacterBody3D

@export var base_speed = 40.0
@export var jump_force = 1000.0
@export var gravity = 18.0

@onready var head_camera = %head_camera
@onready var rear_camera = %rear_camera
@onready var head_camera_container = %head_camera_container
@onready var rear_camera_container = %rear_camera_container

@export var mouse_sensitivity = 0.002

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  head_camera.make_current()

func _unhandled_input(event: InputEvent) -> void:
  if not event is InputEventMouseMotion:
    return
  self.rotate_y(-event.relative.x * mouse_sensitivity)
  head_camera_container.rotate_x(-event.relative.y * mouse_sensitivity)

func _physics_process(delta):
  rear_camera_container.global_transform = head_camera_container.global_transform
  var head = self

  var grounded = self.is_on_floor()
  var speed = base_speed

  if grounded:
    self.velocity *= 0.9
  else:
    self.velocity *= 0.98
    speed = base_speed * 0.5

  var forward = -head.transform.basis.z
  var right = head.transform.basis.x
  var up = Vector3(0, 1, 0)
  
  if Input.is_key_pressed(KEY_A):
    self.velocity -= right * speed * delta
  elif Input.is_key_pressed(KEY_D):
    self.velocity += right * speed * delta

  if Input.is_key_pressed(KEY_W):
    self.velocity += forward * speed * delta
  elif Input.is_key_pressed(KEY_S):
    self.velocity -= forward * speed * delta
  
  if grounded and Input.is_key_pressed(KEY_SPACE):
    self.velocity += up * jump_force * delta

  self.velocity -= up * gravity * delta

  move_and_slide()
