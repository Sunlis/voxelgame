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

@onready var preview_check: PathArea3D = %preview_check

@onready var marker_01: Node3D = %marker_01
@onready var marker_02: Node3D = %marker_02

var _rail_length: float = 0.0
var _transforms = {}

var _preview_valid: bool = false

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
  _hide_preview()

  preview_check.body_entered.connect(func(body: Node3D) -> void:
    print('Body entered preview: ', body.name)
  )
  preview_check.body_exited.connect(func(body: Node3D) -> void:
    print('Body exited preview: ', body.name)
  )

  Global.build_requested.connect(_on_build_requested)
  Global.move_temp_rail.connect(_move_temp_rail)
  Global.player_build_mode_changed.connect(_build_mode_changed)

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
  preview_curve.set_point_position(0, curve.get_point_position(curve.point_count - 1))
  preview_curve.set_point_in(0, curve.get_point_in(curve.point_count - 1))
  preview_curve.set_point_out(0, curve.get_point_out(curve.point_count - 1))
  preview_curve.set_point_position(1, pos)
  preview_curve.set_point_in(1, -out)
  preview_curve.set_point_out(1, out)
  marker_01.global_position = pos
  marker_02.global_position = pos + out
  _last_preview_pos = pos
  _last_preview_in = -out
  _last_preview_out = out
  _show_preview()
  # var collider = _get_preview_collider()
  # if collider:
  #   # collider.set_collision_layer_value(1, false)
  #   # collider.set_collision_mask_value(1, false)
  #   # collider.set_collision_layer_value(5, true)
  #   # collider.set_collision_mask_value(5, true)
  #   var space_state = get_world_3d().direct_space_state
  #   var shape = _get_collision_shape(collider)
  #   if shape:
  #     collision_check_shape.shape = shape.shape.duplicate()
  #     var query = PhysicsShapeQueryParameters3D.new()
  #     query.shape_rid = collider.get_rid()
  #     query.shape = shape.shape
  #     query.transform = collider.global_transform
  #     query.collision_mask = 1 << 5 - 1
  #     var result = space_state.intersect_shape(query)
  #     print(result)

func _build_mode_changed(building: bool, build_type: BuildType.Type) -> void:
  if building and build_type == BuildType.Type.RAIL:
    _show_preview()
  else:
    _hide_preview()

func _hide_preview():
  preview_mesh.visible = false
  # preview_mesh.collision_mode = PathMesh3D.COLLISION_MODE_NONE

func _show_preview():
  preview_mesh.visible = true
  # preview_mesh.collision_mode = PathMesh3D.COLLISION_MODE_TRIMESH