extends Node3D

const SprayScene = preload("res://spray.tscn")

func _ready() -> void:
  Global.spray_created.connect(_create_spray)

func _create_spray(pos: Vector3, forward: Vector3, spray_type: Spray.Type, color: Color, player_id: int) -> void:
  var spray = SprayScene.instantiate()
  spray.type = spray_type
  spray.color = color
  spray.look_at_from_position(pos, pos + forward)
  spray.name = "Spray_%d_%d" % [player_id, Time.get_ticks_usec()]
  add_child(spray)
