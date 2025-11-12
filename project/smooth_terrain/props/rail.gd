@tool

extends Node3D

@export var control_point: Vector3 = Vector3.ZERO:
  set(v):
    control_point = v
    _update()
@export var start_point: Vector3 = Vector3.ZERO:
  set(v):
    start_point = v
    _update()
@export var end_point: Vector3 = Vector3.ZERO:
  set(v):
    end_point = v
    _update()

var control_marker: Node3D
var start_marker: Node3D
var end_marker: Node3D

var segments = []

func _ready():
  _clear()
  _setup_markers()
  _update()

func _clear():
  for child in get_children():
    child.queue_free()
  segments = []

func _setup_markers():
  control_marker = _make_marker(control_point, Color.GREEN)
  start_marker = _make_marker(start_point, Color.RED)
  end_marker = _make_marker(end_point, Color.BLUE)


func _make_marker(pos: Vector3, color: Color = Color.WHITE) -> Node3D:
  var marker = CSGSphere3D.new()
  marker.radius = 0.3
  marker.position = pos
  marker.material = StandardMaterial3D.new()
  marker.material.albedo_color = color
  add_child(marker)
  marker.owner = self
  return marker

func _make_box(color: Color = Color.WHITE) -> CSGBox3D:
  var box = CSGBox3D.new()
  box.material = StandardMaterial3D.new()
  box.material.albedo_color = color
  add_child(box)
  box.owner = self
  return box

func _update():
  if not is_inside_tree():
    return
  _clear()
  _setup_markers()

  control_marker.position = control_point
  start_marker.position = start_point
  end_marker.position = end_point

  var curve = Curve3D.new()
  curve.add_point(end_point)
  curve.add_point(start_point)
  curve.set_point_in(1, start_point - control_point)
  curve.bake_interval = 1.0
  
  var steps = ceil(curve.get_baked_length() / curve.bake_interval)
  var last_segment = null
  for i in range(steps + 1):
    var point = curve.sample_baked((float(i) / float(steps)) * curve.get_baked_length(), true)
    var next = curve.sample_baked((float(i + 1) / float(steps)) * curve.get_baked_length(), true)
    if i == steps:
      next = point + (point - curve.sample_baked((float(i - 1) / float(steps)) * curve.get_baked_length(), true)).normalized()
    var rail_segment = _make_box(Color.SANDY_BROWN)
    rail_segment.position = point
    rail_segment.look_at_from_position(point, next, Vector3.UP)
    rail_segment.scale = Vector3(1.0, 0.06, 0.2)
    segments.append(rail_segment)
    if last_segment:
      _add_connecting_rails(last_segment, rail_segment)
    last_segment = rail_segment

func _add_connecting_rails(previous: Node3D, current: Node3D):
  # Get perpendicular vectors for each tie segment
  var last_direction = (previous.global_transform.basis.z).normalized()  # Direction the last tie is facing
  var current_direction = (current.global_transform.basis.z).normalized()  # Direction current tie is facing

  var last_perpendicular = last_direction.cross(Vector3.UP).normalized()
  var current_perpendicular = current_direction.cross(Vector3.UP).normalized()
  
  var rail_offset = 0.5  # Distance from center to each rail
  
  # Calculate rail positions using each tie's own perpendicular
  var last_left_pos = previous.position + last_perpendicular * rail_offset
  var current_left_pos = current.position + current_perpendicular * rail_offset
  var left_length = (current_left_pos - last_left_pos).length()
  var left_midpoint = (last_left_pos + current_left_pos) / 2.0
  var left_direction = (current_left_pos - last_left_pos).normalized()

  var last_right_pos = previous.position - last_perpendicular * rail_offset
  var current_right_pos = current.position - current_perpendicular * rail_offset
  var right_length = (current_right_pos - last_right_pos).length()
  var right_midpoint = (last_right_pos + current_right_pos) / 2.0
  var right_direction = (current_right_pos - last_right_pos).normalized()
  
  # Create left rail
  var left_rail = _make_box(Color.SILVER)
  left_rail.position = left_midpoint
  left_rail.scale = Vector3(0.08, 0.14, left_length)
  left_rail.look_at_from_position(left_rail.position, left_rail.position + left_direction, Vector3.UP)
  segments.append(left_rail)
  
  # Create right rail
  var right_rail = _make_box(Color.SILVER)
  right_rail.position = right_midpoint
  right_rail.scale = Vector3(0.08, 0.14, right_length)
  right_rail.look_at_from_position(right_rail.position, right_rail.position + right_direction, Vector3.UP)
  segments.append(right_rail)