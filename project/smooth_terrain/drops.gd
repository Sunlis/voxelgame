extends Node3D

const DropScene = preload("res://drop.tscn")

var _count = 0

# func _ready():
#   Global.drop_requested.connect(_on_create_drop)

func _on_create_drop(pos: Vector3, drop_rate: float, force: bool) -> void:
  var drop_result = Drops.select_drop_at_depth(-pos.y, drop_rate)
  if not drop_result.should_drop and not force:
    return
  if force and not drop_result.should_drop:
    drop_result = Drops.DepthDrop.new(Drops.get_random_type(), 0.0, true)
  var drop = DropScene.instantiate()
  drop.drop_type = drop_result.type
  drop.name = "drop_%d" % _count
  _count += 1
  drop.freeze_in_wall = true
  add_child(drop)
  drop.global_position = pos
