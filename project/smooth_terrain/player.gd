extends CharacterBody3D

@export var base_speed = 40.0
@export var jump_force = 10.0
@export var gravity = 18.0

@export var mouse_sensitivity = 0.002
@export var dig_reach = 4.0
@export var dig_radius = 1.5

@export var build_reach = 12.0

@onready var mp_sync: MultiplayerSynchronizer = %mp_sync
@onready var viewer: VoxelViewer = %viewer
@onready var label: Label3D = %label

@onready var body: MeshInstance3D = %body
@onready var head: Node3D = %head
@onready var eyes: CSGCombiner3D = %eyes
@onready var flashlight: SpotLight3D = %flashlight

@onready var anim_player: AnimationPlayer = %anim

var id: int
var camera: Camera3D = null
var is_authority: bool = false

var velocity_before_collision: Vector3

func _ready():
  id = int(self.name.split("_")[1])
  is_authority = get_tree().get_multiplayer().get_unique_id() == id
  if is_authority:
    _set_up_camera()
    label.visible = false
  viewer.requires_visuals = true
  viewer.requires_collisions = true
  viewer.requires_data_block_notifications = true
  viewer.set_network_peer_id(id)

  label.text = self.name
  body.mesh.material.albedo_color = Color.from_hsv(float(id % 10) / 10.0, 0.8, 0.8)
  self.set_multiplayer_authority.call_deferred(id, true)
  mp_sync.set_multiplayer_authority.call_deferred(id)

func _unhandled_input(event: InputEvent) -> void:
  if not event is InputEventMouseMotion:
    return
  if not is_authority:
    return
  if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
    return
  rotate_y(-event.relative.x * mouse_sensitivity)
  head.rotate_x(-event.relative.y * mouse_sensitivity)
  head.rotation.x = clamp(head.rotation.x, PI * -0.49, PI * 0.49)
  # eyes look creepy if you let them rotate too much
  eyes.rotation.x = clamp(head.rotation.x, PI * -0.25, PI * 0.25)

func _set_up_camera():
  camera = Camera3D.new()
  head.add_child(camera)
  camera.position = Vector3(0, 0, 0)
  eyes.visible = false
  camera.make_current()

func _physics_process(delta):
  if self.is_on_floor():
    self.velocity *= 0.9
  else:
    self.velocity *= 0.98

  var up = Vector3(0, 1, 0)
  self.velocity -= up * gravity * delta

  if is_authority:
    _handle_input(delta)

  velocity_before_collision = self.velocity
  move_and_slide()
  # _check_collisions()

func _check_collisions():
  var collision_count = self.get_slide_collision_count()
  for i in range(collision_count):
    var collision = self.get_slide_collision(i)
    var collider = collision.get_collider()
    if collider is RigidBody3D:
      var other = (collider as RigidBody3D)
      print('force %d' % self.velocity_before_collision.length())
      other.apply_impulse(-collision.get_normal() * sqrt(self.velocity_before_collision.length()) * 0.1, collision.get_position())

func _handle_input(delta: float):
  var speed = base_speed
  if not self.is_on_floor():
    speed *= 0.5
  if Input.is_action_pressed("move_forward"):
    self.velocity += -transform.basis.z * speed * delta
  elif Input.is_action_pressed("move_backward"):
    self.velocity += transform.basis.z * speed * delta
  
  if Input.is_action_pressed("move_left"):
    self.velocity += -transform.basis.x * speed * delta
  elif Input.is_action_pressed("move_right"):
    self.velocity += transform.basis.x * speed * delta
  
  if self.is_on_floor() and Input.is_action_just_pressed("jump"):
    self.velocity.y = jump_force
  
  if Input.is_action_just_pressed("pause"):
    if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  
  if camera:
    if Input.is_action_pressed("camera_zoom_in"):
      camera.position.z = max(0, camera.position.z - (delta * 10.0))
    elif Input.is_action_pressed("camera_zoom_out"):
      camera.position.z = min(20, camera.position.z + (delta * 10.0))
    
    body.transparency = smoothstep(4.0, 0.5, camera.position.z)
    
    if Input.is_action_just_pressed("toggle_build_mode"):
      var vt = Global.get_terrain().get_voxel_tool()
      var origin = head.global_transform.origin
      var direction = -camera.global_transform.basis.z
      var result = vt.raycast(origin, direction, build_reach)
      if result:
        var pos = Vector3(origin + direction * result.distance)
        var norm = Vector3(result.normal)
        var mesh = CSGBox3D.new()
        mesh.size = Vector3.ONE * 0.3
        get_tree().root.add_child(mesh)
        mesh.transform.origin = pos
        mesh.look_at(pos + norm, Vector3.UP)
        # Global.build(pos, norm, 1)

  if Input.is_action_pressed("dig") and not anim_player.is_playing():
    anim_player.play("swing_pick")
  
  if Input.is_action_just_pressed("toggle_flashlight"):
    flashlight.visible = not flashlight.visible


func start_dig():
  var origin = head.global_transform.origin
  var forward = -camera.global_transform.basis.z
  dig.rpc_id(1, origin, forward, dig_radius)

@rpc("any_peer", "call_local", "reliable")
func dig(origin: Vector3, direction: Vector3, radius: float):
  var vt := Global.get_terrain().get_voxel_tool()
  vt.mode = VoxelTool.MODE_REMOVE
  var point = origin + direction * dig_reach
  var diff = (origin - point).normalized()
  for i in range(dig_reach):
    var dig_point = origin - (i * diff)
    vt.do_sphere(dig_point, radius)
