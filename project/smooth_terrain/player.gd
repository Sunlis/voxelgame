extends CharacterBody3D

const BuildType = preload("res://smooth_terrain/build_types.gd")

@export var base_speed = 40.0
@export var jump_force = 10.0
@export var gravity = 18.0

@export var mouse_sensitivity = 0.002
@export var dig_reach = 4.0
@export var pickup_reach = 8.0
@export var dig_radius = 1.0
@export var dig_noise: float = 0.02

@export var drop_rate: float = 0.05

@export var build_reach = 12.0
@export var build_rotate_speed = 5.0

@onready var mp_sync: MultiplayerSynchronizer = %mp_sync
@onready var viewer: VoxelViewer = %viewer
@onready var label: Label3D = %label

@onready var body: MeshInstance3D = %body
@onready var head: Node3D = %head
@onready var eyes: CSGCombiner3D = %eyes
@onready var flashlight: SpotLight3D = %flashlight

@onready var player_hud: PlayerHUD = %player_hud
@onready var build_marker: BuildMarker = %build_marker
@onready var anim_player: AnimationPlayer = %anim

@onready var drop_area: Area3D = %drop_area
@onready var drop_area_shape: CollisionShape3D = %drop_area_shape
var _drops = []

var id: int
var camera: Camera3D = null
var is_authority: bool = false

enum Mode {
  MINING,
  BUILDING
}
var mode = Mode.MINING

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

  if is_authority:
    drop_area.body_entered.connect(_body_enter_drop_area)
    drop_area.body_exited.connect(_body_exit_drop_area)

func _body_enter_drop_area(b: Node3D) -> void:
  var drop = b.get_parent_node_3d()
  if not drop or not drop is Drop:
    return
  _drops.append(drop)
  drop.highlight = true

func _body_exit_drop_area(b: Node3D) -> void:
  var drop = b.get_parent_node_3d()
  if not drop or not drop is Drop:
    return
  _drops.erase(drop)
  drop.highlight = false

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
  _movement_controls(delta)
  
  if Input.is_action_just_pressed("toggle_mouse_capture"):
    if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  
  _build_mode_checks()
  _camera_zoom(delta)
  _build_mode_controls(delta)

  if self.mode == Mode.MINING and Input.is_action_pressed("dig") and not anim_player.is_playing():
    anim_player.play("swing_pick")
  
  if Input.is_action_just_pressed("toggle_flashlight"):
    flashlight.visible = not flashlight.visible
  
  _check_drops()
  _debug_stuff()

func _debug_stuff():
  if Input.is_action_just_pressed("debug_spawn_drop"):
    Global.create_drop(self.global_transform.origin + -camera.global_transform.basis.z * 2.0, 1.0, true)

func _check_drops():
  if not camera:
    return
  
  if Input.is_action_just_pressed("pick_up_drops"):
    for drop in _drops:
      Global.notify_message("Picked up %s" % Drops.get_drop_config(drop.drop_type).name)
      drop.queue_free()
    _drops.clear()

func _movement_controls(delta):
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

func _build_mode_controls(delta):
  if not camera:
    return
  if Input.is_action_just_pressed("toggle_build_mode"):
    if mode == Mode.BUILDING:
      self.mode = Mode.MINING
    else:
      self.mode = Mode.BUILDING
    player_hud.build_mode = self.mode == Mode.BUILDING
    Global.player_build_mode_changed.emit(self.mode == Mode.BUILDING, player_hud.get_selected_build_type())

  if self.mode == Mode.BUILDING:
    if Input.is_action_pressed("rotate_build_clockwise"):
      build_marker.rot -= delta * build_rotate_speed
    elif Input.is_action_pressed("rotate_build_counterclockwise"):
      build_marker.rot += delta * build_rotate_speed

func _camera_zoom(delta):
  if not camera:
    return
  if Input.is_action_pressed("camera_zoom_in"):
    camera.position.z = max(0, camera.position.z - (delta * 10.0))
  elif Input.is_action_pressed("camera_zoom_out"):
    camera.position.z = min(20, camera.position.z + (delta * 10.0))
  body.transparency = smoothstep(4.0, 0.5, camera.position.z)

func _build_mode_checks():
  if not camera:
    return

  build_marker.visible = false
  if self.mode != Mode.BUILDING:
    return

  var state = get_world_3d().direct_space_state
  var origin = head.global_transform.origin
  var direction = -camera.global_transform.basis.z
  var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 128.0)
  # only collide with terrain (layer 5)
  query.collision_mask = 1 << 5 - 1
  var result = state.intersect_ray(query)
  var collision = "position" in result
  build_marker.visible = collision
  build_marker.valid = false
  if collision:
    var pos = Vector3(result.position)
    var norm = Vector3(result.normal).normalized()
    var diff = origin - pos
    build_marker.valid = diff.length() <= build_reach
    var build_position = pos + (norm * 0.1)
    build_marker.global_transform.origin = build_position
    # avoid "Target and up vectors are colinear" by choosing a fallback up vector
    var up_vec = Vector3.UP
    if abs(norm.dot(up_vec)) > 0.999:
      up_vec = Vector3(1, 0, 0) # fallback perpendicular vector
    build_marker.look_at(build_marker.global_transform.origin + norm, up_vec)
    var selected_build = player_hud.get_selected_build_type()
    build_marker.directional = BuildType.ROTATABLE.get(selected_build, false)
    if selected_build == BuildType.Type.RAIL:
      build_position += norm * 0.5 # lift rails slightly above ground
      Global.move_temporary_rail_point(build_position, norm, build_marker.forward)
    if build_marker.valid and Input.is_action_just_pressed("build"):
      Global.build(build_position, norm, build_marker.forward, selected_build)


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
  for i in Util.rangef(0.0, dig_reach, radius / 2.0):
    var dig_point = origin - (i * diff)
    vt.do_sphere(dig_point, radius)
    Global.terrain_modified.emit(dig_point, radius * 2.0)
    if TerrainUtil.sphere_intersect(dig_point, radius):
      Global.create_drop(dig_point, drop_rate)
