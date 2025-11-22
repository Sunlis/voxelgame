@tool

extends Node3D

@export var drop_type: Drops.Type = Drops.Type.TRASH:
  set(v):
    drop_type = v
    _update()

@onready var rigidbody: RigidBody3D = %rigidbody
@onready var mesh_instance: MeshInstance3D = %mesh

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

func _on_terrain_modified(point: Vector3, radius: float) -> void:
  if rigidbody.global_transform.origin.distance_to(point) <= radius:
    rigidbody.sleeping = false

func _update():
  if not is_inside_tree():
    return
  var material = mesh_instance.get_active_material(0)
  material.albedo_color = ALBEDO.get(drop_type, Color(1, 0, 1))
