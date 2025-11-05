extends CharacterBody3D

@export var base_speed = 40.0
@export var jump_force = 1000.0
@export var gravity = 18.0

@export var mouse_sensitivity = 0.002
@export var dig_reach = 4.0
@export var dig_radius = 1.5

@onready var mp_sync: MultiplayerSynchronizer = %mp_sync
@onready var viewer: VoxelViewer = %viewer

func _ready():
  var id = self.get_multiplayer_authority()
  self.set_multiplayer_authority(id, true)
  mp_sync.set_multiplayer_authority(id)

  var is_authority = get_tree().get_multiplayer().get_unique_id() == id
  if is_authority:
    _set_up_camera()
  viewer.requires_visuals = is_authority
  viewer.requires_collisions = is_authority
  viewer.requires_data_block_notifications = true
  viewer.set_network_peer_id(id)

func _set_up_camera():
  var camera = Camera3D.new()
  add_child(camera)
  camera.position = Vector3(0, 8, 0)
  camera.look_at(Vector3(0, 0, 1), Vector3.UP)
  camera.make_current()

func _physics_process(delta):
  if self.is_on_floor():
    self.velocity *= 0.9
  else:
    self.velocity *= 0.98

  var up = Vector3(0, 1, 0)
  self.velocity -= up * gravity * delta

  self.rotate_y(delta * 0.2)

  move_and_slide()
