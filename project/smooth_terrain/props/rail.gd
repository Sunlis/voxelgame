@tool

extends Node3D

class_name Rail

const BuildType = preload("res://smooth_terrain/build_types.gd")

@export var curve: Curve3D = null:
  set(value):
    curve = value
    _update()

@export var preview_curve: Curve3D

@export var handle_strength: float = 8.0

@onready var path: Path3D = %path
@onready var preview_path: Path3D = %preview_path
@onready var path_mesh: PathMesh3D = %mesh
@onready var preview_mesh: PathMesh3D = %preview_mesh

@onready var marker_01: Node3D = %marker_01
@onready var marker_02: Node3D = %marker_02

var _rail_length: float = 0.0
var _transforms = {}

func _ready():
  if curve == null:
    curve = Curve3D.new()
  while curve.point_count < 2:
    curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)
  if preview_curve == null:
    preview_curve = Curve3D.new()
  while preview_curve.point_count < 2:
    preview_curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)
  path.curve_changed.connect(self._curve_changed)
  _curve_changed()
  preview_curve = Curve3D.new()
  var out = curve.get_point_out(curve.point_count - 1)
  if out == Vector3.ZERO:
    out = -curve.get_point_in(curve.point_count - 1)
  preview_curve.add_point(
    curve.get_point_position(curve.point_count - 1),
    curve.get_point_in(curve.point_count - 1),
    out)
  preview_curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)
  preview_path.curve = preview_curve

  Global.build_requested.connect(_on_build_requested)
  Global.move_temp_rail.connect(_move_temp_rail)
  Global.player_build_mode_changed.connect(func(building: bool, build_type: BuildType.Type) -> void:
    preview_mesh.visible = building and build_type == BuildType.Type.RAIL
  )

func _curve_changed():
  _rail_length = curve.get_baked_length()
  _transforms.clear()

func _update():
  if is_inside_tree():
    path.curve = curve

func get_rail_length() -> float:
  return _rail_length

func get_transform_at_distance(distance: float) -> Transform3D:
  if distance in _transforms:
    return _transforms[distance]
  if curve != null:
    var tran = curve.sample_baked_with_rotation(clamp(distance, 0.0, self.get_rail_length()))
    _transforms[distance] = tran
    return tran
  return Transform3D.IDENTITY

func _on_build_requested(pos: Vector3, _norm: Vector3, forward: Vector3, build_type: BuildType.Type) -> void:
  if build_type != BuildType.Type.RAIL:
    return
  var out = forward.normalized() * handle_strength
  curve.add_point(pos, -out, out)
  preview_curve.set_point_position(0, pos)
  preview_curve.set_point_in(0, -out)
  preview_curve.set_point_out(0, out)
  preview_curve.set_point_position(1, pos)
  preview_curve.set_point_in(1, -out)
  preview_curve.set_point_out(1, out)
  preview_mesh.visible = false

func _move_temp_rail(pos: Vector3, _norm: Vector3, forward: Vector3) -> void:
  var out = forward.normalized() * handle_strength
  preview_curve.set_point_position(1, pos)
  preview_curve.set_point_in(1, -out)
  preview_curve.set_point_out(1, out)
  preview_mesh.visible = true
  marker_01.global_position = pos
  marker_02.global_position = pos + out
