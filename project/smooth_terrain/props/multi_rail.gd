@tool

extends Node3D

const RAIL_SCENE = preload("res://smooth_terrain/props/rail.tscn")

var rail_segments = []

func _ready():
  add_segment(Vector3.ZERO, Vector3(5, 0, 0))
  Global.build_requested.connect(_on_build_requested)

func _on_build_requested(pos: Vector3, _norm: Vector3, block_type: int) -> void:
  if block_type == 2:
    var last_rail = rail_segments[len(rail_segments) - 1]
    self.add_segment(last_rail.end_point, pos)

func get_control_point() -> Vector3:
  if rail_segments.size() > 0:
    return rail_segments[len(rail_segments) - 1].start_point
  return Vector3.ZERO

func add_segment(start_point: Vector3, end_point: Vector3):
  var rail = RAIL_SCENE.instantiate()
  rail.control_point = self.get_control_point()
  rail.start_point = start_point
  rail.end_point = end_point
  add_child(rail)
  rail_segments.append(rail)
