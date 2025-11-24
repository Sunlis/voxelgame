extends Node3D

const DropConfig = preload("res://drop_config.gd")
const DropScene = preload("res://drop.tscn")

var _count = 0

func _ready():
  Global.create_drop.connect(_on_create_drop)

func _on_create_drop(pos: Vector3, drop_rate: float) -> void:
  var drop_result = DropConfig.select_drop_at_depth(-pos.y, drop_rate)
  if not drop_result.should_drop:
    return
  var drop = DropScene.instantiate()
  drop.drop_type = drop_result.type
  drop.name = "drop_%d" % _count
  _count += 1
  add_child(drop)
  drop.global_position = pos
