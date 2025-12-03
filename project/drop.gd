@tool

extends Node3D

class_name Drop

@export var drop_type: Drops.Type = Drops.Type.TRASH:
  set(v):
    drop_type = v
    _update()

@export var highlight: bool = false:
  set(v):
    highlight = v
    _update()

@export var freeze_in_wall: bool = false:
  set(v):
    freeze_in_wall = v
    _update()

@onready var glow_mesh: Node3D = %glow
@onready var rigidbody: RigidBody3D = %rigidbody
@onready var mesh_instance: MeshInstance3D = %mesh
@onready var shape: CollisionShape3D = %shape
@onready var label: Label3D = %label

var _in_terrain = false

const ALBEDO = {
  Drops.Type.TRASH: Color(0.5, 0.5, 0.5),
  Drops.Type.BOTTLECAP: Color(0.8, 0.8, 0.2),
  Drops.Type.PENNY: Color(1.0, 0.6, 0.2),
  
  Drops.Type.COAL: Color(0.1, 0.1, 0.1),
  Drops.Type.HEMATITE: Color(0.6, 0.1, 0.1),
  Drops.Type.QUARTZ: Color(0.9, 0.9, 1.0),
  
  Drops.Type.GYPSUM: Color(1.0, 1.0, 0.8),
  Drops.Type.PYRITE: Color(0.9, 0.8, 0.2),
  Drops.Type.MALACHITE: Color(0.2, 0.8, 0.2),
  
  Drops.Type.CINNABAR: Color(0.8, 0.2, 0.2),
  Drops.Type.GOLD: Color(1.0, 0.8, 0.2),
  Drops.Type.PLATINUM: Color(0.9, 0.9, 0.9),
  
  Drops.Type.IRIDIUM: Color(0.7, 0.7, 1.0),
  Drops.Type.OBSIDIAN: Color(0.05, 0.05, 0.05),
  Drops.Type.KIMBERLITE: Color(0.3, 0.3, 0.4)
}

func _ready():
  Global.terrain_modified.connect(_on_terrain_modified)
  _update()
  _check_in_terrain.call_deferred()

func _on_terrain_modified(point: Vector3, radius: float, _p_config: PlayerConfiguration) -> void:
  if rigidbody.global_transform.origin.distance_to(point) <= radius * 2.0:
    _update()
    if _in_terrain:
      _check_in_terrain.call_deferred()

func _check_in_terrain():
  var terrain = Global.get_terrain()
  var vt = terrain.get_voxel_tool()
  vt.channel = VoxelBuffer.CHANNEL_SDF
  _in_terrain = vt.get_voxel_f(rigidbody.global_transform.origin) < 0.1
  if freeze_in_wall and not _in_terrain:
    freeze_in_wall = false
  _update()

func _update():
  if not is_inside_tree():
    return
  var material = mesh_instance.get_active_material(0)
  material.albedo_color = ALBEDO.get(drop_type, Color(1, 0, 1))
  glow_mesh.visible = highlight
  rigidbody.sleeping = false
  rigidbody.freeze = freeze_in_wall and _in_terrain
  # label.text = "%s %s" % [freeze_in_wall, _in_terrain]

# func _process(_delta):
#   var terrain = Global.get_terrain()
#   var vt = terrain.get_voxel_tool()
#   vt.channel = VoxelBuffer.CHANNEL_SDF
#   label.text = "%s %s %.4f" % [freeze_in_wall, _in_terrain, vt.get_voxel_f(rigidbody.global_transform.origin)]
