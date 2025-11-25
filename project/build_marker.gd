extends Node3D

class_name BuildMarker

@export var valid: bool = true:
  set(v):
    valid = v
    _update()
@export var directional: bool = true:
  set(v):
    directional = v
    _update()
@export var rot: float = 0.0:
  set(v):
    rot = v
    _update()
@export var forward: Vector3 = Vector3.FORWARD
@export var material: StandardMaterial3D

@onready var arrow: Node3D = %arrow

var VALID_COLOR: Color = Color.from_string("#0879cd", Color.BLUE)
var INVALID_COLOR: Color = Color.from_string("#cc0808", Color.RED)

func _update():
  if not is_inside_tree():
    return
  arrow.visible = directional
  arrow.rotation.z = rot
  forward = arrow.global_transform.basis.y.normalized()
  if material:
    if valid:
      material.albedo_color = VALID_COLOR
      material.emission = VALID_COLOR
    else:
      material.albedo_color = INVALID_COLOR
      material.emission = INVALID_COLOR
    material.albedo_color.a = 0.5
