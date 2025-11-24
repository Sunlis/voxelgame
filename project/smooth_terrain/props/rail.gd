@tool

extends Node3D

class_name Rail

const BuildType = preload("res://smooth_terrain/build_types.gd")


@export var handle_strength: float = 8.0

@onready var path: Path3D = %path
@onready var preview_path: Path3D = %preview_path
@onready var path_mesh: PathMesh3D = %mesh
@onready var preview_mesh: PathMesh3D = %preview_mesh

@onready var preview_check: PathArea3D = %preview_check

@onready var marker_01: Node3D = %marker_01
@onready var marker_02: Node3D = %marker_02

var _rail_length: float = 0.0
var _transforms = {}

var _preview_valid: bool = false

var PREVIEW_COLOR = Color.from_string("#63a5d9", Color.BLUE)

func _ready():
  path.curve_changed.connect(self._curve_changed)
  _curve_changed()
  _hide_preview()

  preview_check.body_entered.connect(func(body: Node3D) -> void:
    if body.is_in_group("terrain"):
      _mark_preview_invalid()
  )
  preview_check.body_exited.connect(func(body: Node3D) -> void:
    if body.is_in_group("terrain"):
      _mark_preview_valid()
  )

  Global.build_requested.connect(_on_build_requested)
  Global.move_temp_rail.connect(_move_temp_rail)
  Global.player_build_mode_changed.connect(_build_mode_changed)

func _curve_changed():
  _rail_length = path.curve.get_baked_length()
  _transforms.clear()

func get_rail_length() -> float:
  return _rail_length

func get_transform_at_distance(distance: float) -> Transform3D:
  if distance in _transforms:
    return _transforms[distance]
  if path.curve != null:
    var tran = path.curve.sample_baked_with_rotation(clamp(distance, 0.0, self.get_rail_length()))
    _transforms[distance] = tran
    return tran
  return Transform3D.IDENTITY

func _on_build_requested(pos: Vector3, _norm: Vector3, forward: Vector3, build_type: BuildType.Type) -> void:
  if build_type != BuildType.Type.RAIL:
    return
  var out = forward.normalized() * handle_strength
  path.curve.add_point(pos, -out, out)
  preview_path.curve.set_point_position(0, pos)
  preview_path.curve.set_point_in(0, -out)
  preview_path.curve.set_point_out(0, out)
  preview_path.curve.set_point_position(1, pos)
  preview_path.curve.set_point_in(1, -out)
  preview_path.curve.set_point_out(1, out)
  _hide_preview()

func _get_preview_collider() -> StaticBody3D:
  for node in preview_mesh.get_children(true):
    if is_instance_of(node, StaticBody3D):
      return node as StaticBody3D
  return null

func _get_collision_shape(body: StaticBody3D) -> CollisionShape3D:
  for node in body.get_children(true):
    if is_instance_of(node, CollisionShape3D):
      return node as CollisionShape3D
  return null

var _last_preview_pos = Vector3.ZERO
var _last_preview_in = Vector3.ZERO
var _last_preview_out = Vector3.ZERO
const PREVIEW_THRESHOLD = 0.001

func _move_temp_rail(pos: Vector3, _norm: Vector3, forward: Vector3) -> void:
  var out = forward.normalized() * handle_strength
  if ((pos - _last_preview_pos).length() < PREVIEW_THRESHOLD and
      (-out - _last_preview_in).length() < PREVIEW_THRESHOLD and
      (out - _last_preview_out).length() < PREVIEW_THRESHOLD):
    return
  preview_path.curve.set_point_position(0, path.curve.get_point_position(path.curve.point_count - 1))
  preview_path.curve.set_point_in(0, path.curve.get_point_in(path.curve.point_count - 1))
  preview_path.curve.set_point_out(0, path.curve.get_point_out(path.curve.point_count - 1))
  preview_path.curve.set_point_position(1, pos)
  preview_path.curve.set_point_in(1, -out)
  preview_path.curve.set_point_out(1, out)
  marker_01.global_position = pos
  marker_02.global_position = pos + out
  _last_preview_pos = pos
  _last_preview_in = -out
  _last_preview_out = out
  _show_preview()

func _build_mode_changed(building: bool, build_type: BuildType.Type) -> void:
  if building and build_type == BuildType.Type.RAIL:
    _show_preview()
  else:
    _hide_preview()

func _hide_preview():
  preview_mesh.visible = false

func _show_preview():
  preview_mesh.visible = true

func _mark_preview_invalid():
  _preview_valid = false
  var mat = preview_mesh.mesh.surface_get_material(0)
  mat.albedo_color = Color.RED
  mat.emission = Color.RED

func _mark_preview_valid():
  _preview_valid = true
  var mat = preview_mesh.mesh.surface_get_material(0)
  mat.albedo_color = PREVIEW_COLOR
  mat.emission = PREVIEW_COLOR
