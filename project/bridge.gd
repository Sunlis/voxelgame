@tool

extends Node3D

class_name BridgeProp

@export var start_point: Vector3 = Vector3.ZERO:
  set(v):
    start_point = v
    _update()
@export var end_point: Vector3 = Vector3.ZERO:
  set(v):
    end_point = v
    _update()
@export var preview: bool = true:
  set(v):
    preview = v
    _update()

@export var display_material: Material
@export var preview_material: BaseMaterial3D

@onready var path: Path3D = %path
@onready var mesh: PathMultiMesh3D = %mesh
@onready var mod: PathModifier3D = %modifier
@onready var static_body: PathStaticBody3D = %static_body

func _ready():
  _update()

func _update():
  if not is_inside_tree():
    return
  if not path:
    return
  path.curve = Curve3D.new()
  path.curve.resource_local_to_scene = true
  path.curve.add_point(start_point)
  path.curve.add_point(end_point)
  var angle = (end_point - start_point).angle_to(Vector3.UP)
  mod.rotation_modifier = Vector3(angle - PI / 2, 0, 0)
  mesh.material_override = preview_material if preview else display_material
  static_body.process_mode = Node.PROCESS_MODE_DISABLED if preview else Node.PROCESS_MODE_INHERIT
