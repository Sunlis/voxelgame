extends Node3D

@onready var player: CharacterBody3D = %player

@export var base_speed = 40.0
@export var jump_force = 1000.0

@export var mouse_sensitivity = 0.002
@export var dig_reach = 4.0
@export var dig_radius = 1.5

@export var head_camera: Camera3D

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  head_camera.make_current()
  player.mp_id = get_tree().get_multiplayer().get_unique_id()

func _unhandled_input(event: InputEvent) -> void:
  if not event is InputEventMouseMotion or Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
    return
  player.rotate_y(-event.relative.x * mouse_sensitivity)
  head_camera.rotate_x(-event.relative.y * mouse_sensitivity)

func _physics_process(delta):
  if not is_inside_tree():
    return
  if Input.is_action_just_pressed("pause"):
    if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

  var head = head_camera

  var grounded = player.is_on_floor()
  var speed = base_speed if grounded else base_speed * 0.5

  var forward = -head.global_transform.basis.z
  var right = head.global_transform.basis.x
  var up = Vector3(0, 1, 0)
  
  if Input.is_action_pressed("move_left"):
    player.velocity -= right * speed * delta
  elif Input.is_action_pressed("move_right"):
    player.velocity += right * speed * delta

  if Input.is_action_pressed("move_forward"):
    player.velocity += forward * speed * delta
  elif Input.is_action_pressed("move_backward"):
    player.velocity -= forward * speed * delta

  if grounded and Input.is_action_pressed("jump"):
    player.velocity += up * jump_force * delta

  player.move_and_slide()

  if Input.is_action_just_pressed("dig"):
    dig(dig_radius)


func dig(radius: float):
  var vt := Global.get_terrain().get_voxel_tool()
  vt.mode = VoxelTool.MODE_REMOVE
  var origin = head_camera.global_transform.origin
  var forward = -head_camera.global_transform.basis.z
  var point = origin + forward * dig_reach
  var diff = (origin - point).normalized()
  for i in range(dig_reach):
    var dig_point = origin - (i * diff)
    vt.do_sphere(dig_point, radius)
