@tool

extends StaticBody3D

@export var sections: int = 1:
  set(v):
    sections = clamp(v, 1, 1000)
    _update()

@onready var section: Node3D = %section
@onready var clones: Node3D = %clones
@onready var collider: CollisionShape3D = %collider

func _ready():
  _update()

func _update():
  if not is_inside_tree():
    return
  for c in clones.get_children():
    c.queue_free()
  for i in range(1, sections):
    var s = section.duplicate() as Node3D
    s.position = Vector3(2 * i, 0, 0)
    s.name = "section_%d" % i
    clones.add_child(s)
    s.owner = self
  var shape = collider.shape as BoxShape3D
  shape.size.x = sections * 2.0
  collider.position.x = shape.size.x / 2.0