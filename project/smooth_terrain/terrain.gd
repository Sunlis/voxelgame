@tool

extends VoxelTerrain

@export var noises: Array[ZN_FastNoiseLite] = []

const CavesGeneratorScript = preload("res://caves_generator.gd")

const DRAW_DEBUG_LABELS = false

const CHECK_SIZE = 10.0
var check_area = AABB(Vector3(-CHECK_SIZE / 2.0, -CHECK_SIZE, -CHECK_SIZE / 2.0), Vector3.ONE * CHECK_SIZE)

const DENSITY = 9

var _marks: Array[Label3D] = []

func _ready() -> void:
  for noise in noises:
    noise.seed = randi()
  self.generator = CavesGeneratorScript.new()
  self.generator.noises = noises
  self.run_stream_in_editor = true
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

