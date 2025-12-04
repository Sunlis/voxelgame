@tool

extends VoxelTerrain

const DropScene = preload("res://drop.tscn")
const CavesGeneratorScript = preload("res://caves_generator.gd")

@export var cave_noises: Array[ZN_FastNoiseLite] = []
@export var drop_noises: Array[FastNoiseLite] = []

const SPAWN_DROPS_ON_MODIFY = true

func _ready() -> void:
  for noise in cave_noises:
    noise.seed = randi()
  self.generator = CavesGeneratorScript.new()
  self.generator.noises = cave_noises
  self.run_stream_in_editor = true
  for noise in drop_noises:
    noise.seed = randi()
  Global.register_terrain(self)
  if SPAWN_DROPS_ON_MODIFY:
    Global.terrain_modified.connect(_on_terrain_modified)

func _sample_noise(pos: Vector3) -> float:
  var out = 0.0
  for noise in drop_noises:
    out += (noise.get_noise_3dv(pos) + 1.0) / 2.0
  return out / float(drop_noises.size())

var _marked = {}

var _drops = []

func _in_terrain(pos: Vector3) -> bool:
  var vt = get_voxel_tool()
  vt.channel = VoxelBuffer.CHANNEL_SDF
  return vt.get_voxel_f(pos) < 0.0

func _on_terrain_modified(pos: Vector3, radius: float, p_config: PlayerConfig) -> void:
  radius *= 2.0
  for x in range(floor(pos.x - radius), ceil(pos.x + radius) + 1):
    for y in range(floor(pos.y - radius), min(-1, ceil(pos.y + radius) + 1)):
      for z in range(floor(pos.z - radius), ceil(pos.z + radius) + 1):
        var sample_pos = Vector3(x, y, z)
        if sample_pos in _marked:
          continue
        _marked[sample_pos] = true
        if not _in_terrain(sample_pos):
          continue
        var sample = _sample_noise(sample_pos)
        if sample > 0.5 and randf() < p_config.drop_rate:
          _create_drop(sample_pos)

func _create_drop(pos: Vector3):
  var drop = DropScene.instantiate() as Drop
  drop.freeze_in_wall = true
  add_child(drop)
  drop.global_position = pos
  _drops.append(drop)
