extends VoxelTerrain

const DropScene = preload("res://drop.tscn")

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

var _drops = []

func _on_terrain_modified(pos: Vector3, radius: float) -> void:
  if len(_drops) > 0:
    return
  radius *= 2.0
  for x in range(floor(pos.x - radius), ceil(pos.x + radius) + 1):
    for y in range(floor(pos.y - radius), ceil(pos.y + radius) + 1):
      for z in range(floor(pos.z - radius), ceil(pos.z + radius) + 1):
        var sample_pos = Vector3(x, y, z)
        if sample_pos in _marked:
          continue
        if sample_pos.y > 0:
          continue
        _marked[sample_pos] = true
        var sample = _sample_noise(sample_pos)
        if sample > 0.64:
          # print('create drop at %s' % sample_pos)
          _create_drop(sample_pos)
          return

func _create_drop(pos: Vector3):
  var drop = DropScene.instantiate() as Drop
  drop.freeze_in_wall = true
  add_child(drop)
  drop.global_position = pos
  _drops.append(drop)
