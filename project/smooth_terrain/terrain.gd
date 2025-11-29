@tool

extends VoxelTerrain

const DropScene = preload("res://drop.tscn")

@export var cave_noises: Array[FastNoiseLite] = []

@export var drop_noises: Array[ZN_FastNoiseLite] = []

const CavesGeneratorScript = preload("res://caves_generator.gd")

const DRAW_DEBUG_LABELS = true

const CHECK_SIZE = 20.0
var check_area = AABB(Vector3(-CHECK_SIZE / 2.0, -CHECK_SIZE, -CHECK_SIZE / 2.0), Vector3.ONE * CHECK_SIZE)

const DENSITY = 9

var _marks: Array[Label3D] = []

func _ready() -> void:
  for noise in cave_noises:
    noise.seed = randi()
  self.generator = CavesGeneratorScript.new()
  self.generator.noises = cave_noises
  self.run_stream_in_editor = true
  for noise in drop_noises:
    noise.seed = randi()
  Global.register_terrain(self)
  if DRAW_DEBUG_LABELS:
    for x in range(int(check_area.position.x), int(check_area.position.x + check_area.size.x), DENSITY):
      for y in range(int(check_area.position.y), int(check_area.position.y + check_area.size.y), DENSITY):
        for z in range(int(check_area.position.z), int(check_area.position.z + check_area.size.z), DENSITY):
          var pos = Vector3(x, y, z)
          var label = Label3D.new()
          label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
          label.pixel_size = 0.001
          label.fixed_size = true
          label.no_depth_test = true
          add_child(label)
          label.global_position = pos
          _marks.append(label)

func _process(_delta):
  var vt = get_voxel_tool()
  vt.channel = VoxelBuffer.CHANNEL_SDF
  for mark in _marks:
    mark.text = "%.2f (%d)" % [vt.get_voxel_f(mark.global_position), vt.get_voxel(mark.global_position)]

  Global.terrain_modified.connect(_on_terrain_modified)

func _sample_noise(pos: Vector3) -> float:
  var out = 0.0
  for noise in drop_noises:
    out += (noise.get_noise_3dv(pos) + 1.0) / 2.0
  return out / float(drop_noises.size())

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
