@tool

extends StaticBody3D

@export var size: Vector3 = Vector3.ONE:
  set(v):
    size = v
    _update()

func _ready():
  _update()

func _update():
  if not is_inside_tree():
    return
  var collider = %collider as CollisionShape3D
  var shape = collider.shape as BoxShape3D
  var visual = %mesh as MeshInstance3D
  var mesh = visual.mesh as BoxMesh

  shape.size = self.size
  mesh.size = self.size
