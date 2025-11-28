extends VoxelTerrain

@export var noises: Array[FastNoiseLite] = []

func _ready() -> void:
  for noise in noises:
    noise.seed = randi()
  Global.register_terrain(self)
  Global.terrain_modified.connect(_on_terrain_modified)

func _sample_noise(pos: Vector3) -> float:
  var out = 0.0
  for noise in noises:
    out += (noise.get_noise_3dv(pos) + 1.0) / 2.0
  return out / float(noises.size())

var _marked = {}

func _on_terrain_modified(pos: Vector3, radius: float) -> void:
  radius *= 2.0
  for x in range(floor(pos.x - radius), ceil(pos.x + radius) + 1):
    for y in range(floor(pos.y - radius), ceil(pos.y + radius) + 1):
      for z in range(floor(pos.z - radius), ceil(pos.z + radius) + 1):
        var sample_pos = Vector3(x, y, z)
        if sample_pos in _marked:
          continue
        _marked[sample_pos] = true
        var sample = _sample_noise(sample_pos)
        if sample > 0.64:
          _create_drop(sample_pos)
        # var sphere = CSGSphere3D.new()
        # sphere.radius = 0.1
        # add_child(sphere)
        # sphere.global_position = sample_pos
        # sphere.material = StandardMaterial3D.new()
        # sphere.material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        # var c = Color(0, sample, 0)
        # if sample > 0.65:
        #   c.r = 1.0
        # elif sample > 0.5:
        #   c.b = 1.0
        # sphere.material.albedo_color = c
        # sphere.material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

func _create_drop(pos: Vector3):
  var drop = RigidBody3D.new()
  # drop.sleeping = true
  add_child(drop)
  drop.global_transform.origin = pos
  drop.contact_monitor = true
  drop.max_contacts_reported = 2
  drop.set_collision_layer_value(1, false)
  drop.set_collision_mask_value(1, true)
  drop.set_collision_layer_value(5, true) # Terrain
  drop.set_collision_layer_value(10, true) # Props
  drop.set_collision_mask_value(10, true) # Props
  drop.set_collision_layer_value(15, true) # Drops
  drop.set_collision_mask_value(15, true) # Drops
  drop.body_exited.connect(func(_b):
    drop.sleeping = false)

  var mesh_instance = MeshInstance3D.new()
  drop.add_child(mesh_instance)
  mesh_instance.mesh = SphereMesh.new()
  mesh_instance.mesh.radius = 0.1
  mesh_instance.mesh.height = 0.2
