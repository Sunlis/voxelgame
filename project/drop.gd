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
  rigidbody.body_entered.connect(_on_body_entered)
  rigidbody.body_exited.connect(_on_body_exited)
  rigidbody.contact_monitor = true
  rigidbody.max_contacts_reported = 4
  _check_in_terrain()
  _update()

func _on_terrain_modified(point: Vector3, radius: float) -> void:
  if rigidbody.global_transform.origin.distance_to(point) <= radius:
    _update()
    if _in_terrain:
      _check_in_terrain.call_deferred()

func _on_body_entered(body: Node) -> void:
  if body.is_in_group("terrain"):
    _in_terrain = true
    _update()

func _on_body_exited(body: Node) -> void:
  if body.is_in_group("terrain"):
    _in_terrain = false
    freeze_in_wall = false
    _update()

func _check_in_terrain():
  var state = get_world_3d().direct_space_state
  var params = PhysicsShapeQueryParameters3D.new()
  params.shape = shape.shape
  params.exclude = [rigidbody.get_rid()]
  params.transform = rigidbody.global_transform
  params.margin = 0.01
  params.collision_mask = 1 << 5 - 1
  var result = state.intersect_shape(params, 4)
  _in_terrain = len(result) > 0
  if len(result) > 0:
    var collider = result[0].collider
    var node = collider.get_parent()
    print('colliding with %s %s' % [collider.name, node.name])
  _update()

func _update():
  if not is_inside_tree():
    return
  var material = mesh_instance.get_active_material(0)
  material.albedo_color = ALBEDO.get(drop_type, Color(1, 0, 1))
  glow_mesh.visible = highlight
  rigidbody.sleeping = false
  rigidbody.freeze = freeze_in_wall and _in_terrain
  label.text = "%s %s" % [freeze_in_wall, _in_terrain]

func _process(_delta):
  _check_in_terrain()
