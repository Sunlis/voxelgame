extends Node3D

class_name BuildMarker

@export var directional: bool = true:
  set(v):
    directional = v
    _update()
@export var rot: float = 0.0:
  set(v):
    rot = v
    _update()
@export var forward: Vector3 = Vector3.FORWARD

@onready var arrow: Node3D = %arrow

func _update():
  arrow.visible = directional
  arrow.rotation.z = rot
  forward = arrow.global_transform.basis.y.normalized()
